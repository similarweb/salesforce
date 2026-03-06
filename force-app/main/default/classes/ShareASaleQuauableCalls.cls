/**
 * @author Itzik Winograd
 * @date 03/03/2021
 * @Description Queueable Integration class to ShareASale.
 * Constructs with a list of SObjects, Limit of BATCH_LIMIT per queueable call.
 */
public with sharing class ShareASaleQuauableCalls implements Queueable, Database.AllowsCallouts {
  private List<SObject> sobjectsList = new List<SObject>();
  private Integer BATCH_LIMIT = Integer.valueOf(
    GeneralUtil.getGeneralConfig('ShareASale_Transaction_Batch_Size')
      .Number_Value__c
  );
  private List<Log_Event__e> logs; //Initialized for each job
  private String action = '';

  /** Constructor */
  public ShareASaleQuauableCalls(List<SObject> sobjectsList, String action) {
    this.sobjectsList = sobjectsList;
    this.action = action;
    System.debug('### Enqueued sobjectsList.size: ' + sobjectsList.size());
  }

  /**
   * @author Itzik Winograd
   * @date 03/03/2021
   * @Description for a given list of sobjects, itereate over them and perform a call for each one.
   * Chekc for a current limit of BATCH_LIMIT records, and if surpass - enqueue another call.
   * @param  QueueableContext context
   * @return none.
   */
  public void execute(QueueableContext context) {
    sobjectsList = removeConvetedContacts(sobjectsList); //filtering contacts out is done on ShareASaleIntegration class
    List<SObject> updateResponses = new List<SObject>();
    logs = new List<Log_Event__e>();
    Integer currentLimit = BATCH_LIMIT;
    while (currentLimit > 0 && sobjectsList.size() > 0) {
      Sobject sobj = sobjectsList.remove(0);
      Http http = new Http();
      HttpRequest request = ShareASaleUtils.createShareASaleNewTransactionRequest(
        sobj,
        action
      );
      HTTPResponse res = http.send(request);
      String responseString = res.getBody();
      System.debug(
        '### call result for ' + sobj.get('Id') + ': ' + responseString
      );
      logs.add(
        getLogEvent(
          new List<SObject>{ sobj },
          sobj,
          request,
          'execute',
          responseString.contains('Transaction Created') ? null : responseString
        )
      );
      currentLimit -= 1;
      updateResponses.add(updateResponsesOnSObject(sobj, responseString));
    }

    //update the updateResponses with the response
    if (updateResponses.size() > 0) {
      updateResponsesOnSObjects(updateResponses);
    }
    //publish log events
    if (logs.size() > 0) {
      System.debug('### published logs: ' + logs);
      EventBus.publish(logs);
    }
    //enqueue next job if recrods still exist
    if (sobjectsList.size() > 0 && !Test.isRunningTest()) {
      System.enqueueJob(new ShareASaleQuauableCalls(sobjectsList, action));
    }
  }

  /**
   * @author Itzik Winograd
   * @date 30/05/2021
   * @description update the responses on the calling sobject
   * @param SObject sobj - the sobject to update the integration result on
   * @param String responseString - the response from ShareASale.
   * @return cloned sobject with the response on.
   * =============================Changes=============================
   * @date 11/08/2021
   * @author Itzik Winograd
   * @description: Set the ShareASale_Retries_Counter__c: 0 if the transaction
   *               was succesfull, or increment the numbers on failiours.
   */
  private SObject updateResponsesOnSObject(
    SObject sobj,
    String responseString
  ) {
    SObject sobjToUpdate = sobj.clone(false, false, false, false);
    sobjToUpdate.put('Id', sobj.get('Id'));
    sobjToUpdate.put('ShareASale_New_Transaction_Response__c', responseString);
    Decimal retriesNumber = (Decimal) sobj.get('ShareASale_Retries_Counter__c');
    if (responseString == 'Transaction Created' || retriesNumber == null) {
      //on success or first fail
      retriesNumber = 0;
    } else {
      retriesNumber += 1;
    }
    sobjToUpdate.put('ShareASale_Retries_Counter__c', retriesNumber);
    return sobjToUpdate;
  }

  /**
   * @author Itzik Winograd
   * @date 10/03/2021
   * @description update the list of sobjects with the reospnse for each record
   * @param List<SObject> sobjectsToUpdate - the sobjects to update the integration result on
   * @return None.
   */
  private void updateResponsesOnSObjects(List<SObject> sobjectsToUpdate) {
    try {
      update sobjectsToUpdate;
    } catch (Exception ex) {
      logs.add(
        getLogEvent(
          sobjectsToUpdate,
          null,
          null,
          'updateResponsesOnSObjects',
          ex.getMessage()
        )
      );
    }
  }

  /**
   * @author Itzik Winograd
   * @date 08/03/2021
   * @description Generate an Log_Event__e record with related values
   * @param List<SObject> sobjects
   * @param SObject sobj,
   * @param HTTPRequest req,
   * @param String apexMethod,
   * @param String err
   * @return Log_Event__e with all fields set.
   */
  public Log_Event__e getLogEvent(
    List<SObject> ids,
    SObject sobj,
    HTTPRequest req,
    String apexMethod,
    String err
  ) {
    return LogEventUtils.createLogEventRecord(
      ids,
      'ShareASaleQuauableCalls',
      apexMethod,
      JSON.serialize(sobj),
      err,
      err == null ? 'Info' : 'Error',
      req == null ? null : req,
      req == null
        ? null
        : new List<String>{ 'x-ShareASale-Date', 'x-ShareASale-Authentication' }
    );
  }

  /**
   * @author Itzik Winograd
   * @date 11/04/2021
   * @Description: Remove converted contacts from the sobjects list.
   * Loop over the sobjects, collect contact Ids and then serch for leads with matching id in ConvertedContactId.
   * @param List<SObject> sobjectsList - map of sobjects ids and records
   * @return List<SObject> filteredRecords filteredRecords
   */
  public List<SObject> removeConvetedContacts(List<SObject> sobjects) {
    String sobjectId;
    Map<String, SObject> filteredRecords = new Map<String, SObject>();
    List<Id> contactsIds = new List<Id>();
    for (SObject sobj : sobjectsList) {
      sobjectId = sobj.Id;
      filteredRecords.put(sobjectId, sobj);
      if (GeneralUtil.getObjectNameFromId(sobjectId) == 'contact') {
        contactsIds.add(sobjectId);
      }
    }
    System.debug('### contactsIds: ' + contactsIds);
    if (contactsIds.size() > 0) {
      String query = 'SELECT Id,ConvertedContactId FROM LEAD WHERE ConvertedContactId IN :contactsIds';
      for (SObject sobj : Database.query(query)) {
        filteredRecords.remove((String) sobj.get('ConvertedContactId'));
        System.debug('### in removeConvetedContact: ' + sobj.get('Id'));
      }
    }
    return filteredRecords.values();
  }
}

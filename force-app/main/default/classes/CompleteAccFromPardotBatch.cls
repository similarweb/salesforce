/**
 * @author Itzik Winograd
 * @date 18/04/2020
 * @description Get missing account values from pardot.
 * Get Authentication token from saleforce, then perform a Read action on pardot.
 * Parse pardot response and assign the missing values to the account.
 * This class is using FieldMapping Custom MetaData
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public class CompleteAccFromPardotBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
  private Map<String, List<String>> accountIdVsFields = new Map<String, List<String>>();
  private FieldMappingNewUtils FMNUtils = new FieldMappingNewUtils(
    'Account Values from Pardot'
  );
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();

  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = createContactsQuery();
    return Database.getQueryLocator(query);
  }

  /**
   * @author Itzik Winograd
   * @date 18/04/2021
   * @description: Execute method of the batch.
   * @param Database.BatchableContext BC.
   * @param List<SObject> scope.
   */
  public void execute(Database.BatchableContext BC, List<SObject> scope) {
    System.debug('### in CompleteAccFromPardotBatch - Execute');
    Map<String, Account> accountsToUpdateMap = new Map<String, Account>();
    Map<Id, String> accountIdsAndPardotIds = createAccountAndPardotMap(scope);
    Map<String, Account> pardotIdsVsAccounts = filterAccounts(
      accountIdsAndPardotIds
    );
    String token = GetSalesforceAccessToken.getAccessToken(
      'Salesforce_Access_Token'
    );
    System.debug('### received token: ' + token);
    Account updatedAccount;
    if (token != null) {
      String responseXML;
      //Loop over the pardotIds to completea and make a Read call to pardot
      for (String pardotProspectId : pardotIdsVsAccounts.keySet()) {
        responseXML = PardotUtils.readPardot(
          'Pardot_Read',
          token,
          pardotProspectId
        );
        if (responseXML != null) {
          //System.debug('### received responseXML: ' + responseXML);
          updatedAccount = parsePardotReadXMLResponse(
            responseXML,
            pardotIdsVsAccounts.get(pardotProspectId).Id
          );
          if (updatedAccount != null) {
            accountsToUpdateMap.put(updatedAccount.Id, updatedAccount);
          }
        }
      }
    } else {
      logEvents.add(
        LogEventUtils.createLogEventRecord(
          pardotIdsVsAccounts.values(),
          'CompleteAccFromPardotBatch',
          'execute',
          '',
          'No Access token received, cant proceed with the process.',
          'Error',
          null,
          null
        )
      );
    }
    if (accountsToUpdateMap.values().size() > 0) {
      updateAccounts(accountsToUpdateMap);
      logEvents.add(
        LogEventUtils.createLogEventRecord(
          new List<String>(accountsToUpdateMap.keySet()),
          'CompleteAccFromPardotBatch',
          'execute',
          'Finished a batch process, the accounts specified above were updated.',
          '',
          'Info',
          null,
          null
        )
      );
    }
  }

  //Finish of the batch execute. Publish logs if there were any.
  public void finish(Database.BatchableContext BC) {
    System.debug('### Finisehd procedutre CompleteAccFromPardotBatch.');
    if (logEvents.size() > 0) {
      EventBus.publish(logEvents);
    }
  }

  /**
   * @author Itzik Winograd
   * @date day/month/2021
   * @description update the accounts with the received values from pardot.
   * @param Map<String,Account> accountsToUpdateMap.
   * @return Void.
   */

  public void updateAccounts(Map<String, Account> accountsToUpdateMap) {
    System.debug('### Finished single batch in CompleteAccFromPardotBatch');
    if (!accountsToUpdateMap.values().isEmpty()) {
      System.debug(
        '### Found accounts to update: ' + accountsToUpdateMap.values()
      );
      try {
        //2021-07-05: changed immidiate update to a QueueableDMLUtils job.
        System.enqueueJob(
          new QueueableDMLUtils(
            accountsToUpdateMap.values(),
            'update',
            false,
            null
          )
        );
      } catch (Exception ex) {
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<String>(accountsToUpdateMap.keySet()),
            'CompleteAccFromPardotBatch',
            'updateAccounts',
            '',
            'Couldnt enqueue a QueueableDMLUtils job: ' + ex.getMessage(),
            'Error'
          )
        );
      }
      /*else {
                List<Database.SaveResult> resultsList = Database.update(accountsToUpdateMap.values(), false);
                for (Integer i = 0; i < resultsList.size(); i++) {
                    Database.SaveResult result = resultsList[i];
                    if (!result.isSuccess()) {
                        logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{accountsToUpdateMap.values()[i].Id}, 'CompleteAccFromPardotBatch', 'updateAccounts', 
                        JSON.serialize(accountsToUpdateMap.values()[i]),result.getErrors().toString(), 'Error'));
                    }
                }
            }*/
    }
  }

  /**
   * @author Itzik Winograd
   * @date 22/04/2021
   * @description: Parse pardot xml response and assign the values from pardot to account.
   * @param String XMLResponse - a string of xml from pardot to parse with prospect data.
   * @param String accountId - the account Id of the account to update
   * @return Account acc - an updated account
   */
  public Account parsePardotReadXMLResponse(
    String XMLResponse,
    String accountId
  ) {
    DOM.Document document = new DOM.Document();
    document.load(XMLResponse.toLowerCase());
    //document.load(XMLResponse);
    DOM.XmlNode responseElements = document.getRootElement()
      .getChildElement('prospect', null); //get prospect data
    String pardotFieldName;
    String pardotFieldValue;
    Account acc;
    FieldMappingNewUtils.FieldMappingUnit FMUnit;
    for (String SFfieldName : accountIdVsFields.get(accountId)) {
      FMUnit = FMNUtils.destinationVsMapping.get(SFfieldName);
      pardotFieldName = FMUnit.source.toLowerCase();
      System.debug(
        '### SF_fieldName: ' +
          SFfieldName +
          ', Pardot_FieldName: ' +
          pardotFieldName
      );
      if (pardotFieldName != null) {
        //System.debug('### responseElements.getChildElement: ' + responseElements.getChildElements());
        if (responseElements.getChildElement(pardotFieldName, null) != null) {
          pardotFieldValue = responseElements.getChildElement(
              pardotFieldName,
              null
            )
            .getText();
          System.debug(
            '### value: ' + FMUnit.convertValue(pardotFieldValue, null)
          );
          if (acc == null) {
            acc = new Account(Id = accountId);
          }
          if (pardotFieldValue != null) {
            acc.put(SFfieldName, FMUnit.convertValue(pardotFieldValue, null));
          }
        }
        /*else { //field not found or is null
                    if (!XMLResponse.containsIgnoreCase('<'+pardotFieldName+'/>')){//field not found
                        logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{acc.Id}, 'CompleteAccFromPardotBatch', 'parsePardotReadXMLResponse', 
                        '','No pardot field with this name: ' + pardotFieldName , 'Error'));
                    }
                }*/
      }
    }
    return acc;
  }

  /**
   * @author Itzik Winograd
   * @date 18/04/2021
   * @description: Filters the accounts. Get all the accounts by the accountIds in the contacts list,
   * then loop over them and create a map of accountIds and a list of fields which needs to be completed from pardot.
   * @param Map<String,String> accountsAndPardotId map of accountId and PardotIds
   * @return Map<String,Account> pardotIdVsAccount map of pardotId vs Accounts
   */
  private Map<String, Account> filterAccounts(
    Map<Id, String> accountIdsAndPardotIds
  ) {
    //String fieldsToComplete = 'Website,Employees_Min__c,Employees_Max__c,BillingCountry,Phone,SW_Industry__c,Polygarph_Website__c,Polygraph_Additional_Email__c,Polygraph_Company_Annual_Revenue__c,Polygraph_Company_City__c,Polygraph_Company_Country_Name__c,Polygraph_Company_Description__c,Polygraph_Company_Domain__c,Polygraph_Company_Employees_Estimated__c,Polygraph_Company_Employees_Range__c,Polygraph_Company_Estimated_ARR__c,Polygraph_Company_Facebook__c,Polygraph_Company_HQ_phone__c,Polygraph_Company_Indexed_at__c,Polygraph_Company_Industry__c,Polygraph_Company_Industry_Group__c,Polygraph_Company_Linkedin__c,Polygraph_Company_Logo__c,Polygraph_Company_Name__c,Polygraph_Company_Other_Domains__c,Polygraph_Company_Parent_Domain__c,Polygraph_Company_Phone_numbers__c,Polygraph_Company_State_Name__c,Polygraph_Company_Sub_Industry__c,Polygraph_Company_Twitter__c,Polygraph_Company_Ultimate_Parent_Domain__c,Polygraph_Employee_Max__c,Polygraph_Employee_Min__c,Polygraph_Error__c,Polygraph_Send_Status__c';
    String fieldsToComplete = String.join(
      new List<String>(FMNUtils.destinationVsMapping.keySet()),
      ','
    );
    System.debug('### fieldsToComplete: ' + fieldsToComplete);
    List<String> fieldsToCompleteList = fieldsToComplete.split(',');
    Set<Id> accountIds = new Set<Id>((Set<Id>) accountIdsAndPardotIds.keySet());
    String accountQuery =
      'SELECT Id,' +
      fieldsToComplete +
      ' FROM Account ' +
      ' WHERE Id IN :accountIds';
    System.debug('###  accountQuery: ' + accountQuery);
    Map<String, Account> pardotIdVsAccount = new Map<String, Account>();
    for (Account acc : Database.query(accountQuery)) {
      for (String fieldName : fieldsToCompleteList) {
        if (
          acc.get(fieldName) == null ||
          acc.get(fieldName) == 0 ||
          acc.get(fieldName) == 'no_website'
        ) {
          if (!accountIdVsFields.containsKey(acc.Id)) {
            accountIdVsFields.put(acc.Id, new List<String>());
          }
          accountIdVsFields.get(acc.Id).add(fieldName);
          pardotIdVsAccount.put(accountIdsAndPardotIds.get(acc.Id), acc);
        }
      }
    }
    System.debug('### filtered pardotIdVsAccount: ' + pardotIdVsAccount);
    System.debug('### filtered accountIdVsFields: ' + accountIdVsFields);
    return pardotIdVsAccount;
  }

  /**
   * @author Itzik Winograd
   * @date 18/04/2021
   * @description: Create a query of new Contacts that has pardotId
   * @param none.
   * @return String a nested query of accounts with contacts.
   */
  private String createContactsQuery() {
    Integer LAST_N_DAYS = Integer.valueOf(
      GeneralUtil.getGeneralConfig('Complete_Acc_from_Pardot_LastNDays')
        .Number_Value__c
    );
    String contactsQuery =
      'SELECT Id, pardot_id__c, AccountId, CreatedDate ' +
      +'FROM Contact ' +
      +'WHERE pardot_id__c != null ' +
      +'AND CreatedDate = LAST_N_DAYS:' +
      LAST_N_DAYS;
    System.debug('### CompleteAccFromPardotBatch fullQuery: ' + contactsQuery);
    return contactsQuery;
  }

  /**
   * @author Itzik Winograd
   * @date 18/04/2021
   * @description: Create a query of new Contacts that has pardotId
   * @param List<Contact> contacts to get the accountId and PardotId from.
   * @return Map<Id,String>  accountsVsPardotId of AccountId vs PardotId
   */
  private Map<Id, String> createAccountAndPardotMap(List<Contact> contacts) {
    Map<Id, String> accountsVsPardotId = new Map<Id, String>();
    for (Contact con : contacts) {
      accountsVsPardotId.put(con.accountId, con.pardot_id__c);
    }
    return accountsVsPardotId;
  }
}

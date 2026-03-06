/**
 * @author Itzik Winograd
 * @date 09/01/2022
 * @description Add '.invalid' to email fields. Use after sandbox refresh.
 *              The fields can be found on the custom metadata called ""
 *              The query can be found on the custom query mdt called Sandbox_Opportunity_Request_Fields and Sandbox_Request_Fields
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -     Itzik Winograd
 * date        -     01/05/2022
 * description -     Added Meeting__c SObject, MEETING_FIELDS_LIST.
 * --------------------------------------------------------------------------------------
 * --------------------------------------------------------------------------------------
 * author      -     Itzik Winograd
 * date        -     19/07/2022
 * description -     Changed the class to a batch.
 */
public without sharing class AddInvalidToEmailFields implements Database.Batchable<sObject> {
  //Run the batch with each of the values here:
  //private static FINAL string OPPORTUNITY_FIELDS_LIST = 'Sandbox_Refresh_Opportunity_Fields';
  //private static FINAL string REQUEST_FIELDS_LIST =     'Sandbox_Refresh_Request_Fields';
  //private static FINAL string MEETING_FIELDS_LIST =     'Sandbox_Refresh_Meeting_Fields';

  private string processName = '';
  private String query = '';
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();

  /**
   * @author Itzik Winograd
   * @date 19/07/2022
   * @description Constructor. Gets the desired records to update based on the given processName - the name in the custom metadata,
   * 							and pass them to the removal process.
   *				              Use the Custom Query and General Config custom metadatada.
   * @param String processName - Name of the process in the Custom Query Custom Metadata to work on.
   */
  public AddInvalidToEmailFields(String processName) {
    this.processName = processName;
  }

  /**
   * @author 	Itzik Winograd
   * @Date 	19/07/2022
   * @description Batch start. query for the records with the 'query' param.
   */
  public Database.QueryLocator start(Database.BatchableContext BC) {
    query = CustomQueriesUtils.getCustomQuery(processName);
    return Database.getQueryLocator(query);
  }

  /**
   * @author 	Itzik Winograd
   * @Date 	19/07/2022
   * @description Batch execute. Get the scope of records and update them
   */
  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    Set<String> emailFieldsToUpdateSet;
    List<SObject> updatedRecordsList;
    try {
      emailFieldsToUpdateSet = new Set<String>(
        GeneralUtil.getGeneralConfig(processName).Text_Value__c.split(';')
      );
      updatedRecordsList = updateEmailFields(scope, emailFieldsToUpdateSet);
      updateInvalidOnRecords(updatedRecordsList);
    } catch (Exception ex) {
      logEvents.add(
        LogEventUtils.createLogEventRecord(
          updatedRecordsList,
          'AddInvalidToEmailFields',
          'execute',
          ex.getStackTraceString(),
          'Error in adding invalid to emails: ' + ex.getMessage(),
          'Error',
          null,
          null
        )
      );
    }
    if (!logEvents.isEmpty()) {
      EventBus.publish(logEvents);
    }
  }

  /**
   * @author  Itzik Winograd
   * @date	19/07/2022
   * @description Batch finish.
   */
  public void finish(Database.BatchableContext BC) {
    System.debug(
      '#### AddInvalidToEmailFields with processName ' +
        processName +
        'is finished.'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 09/01/2022
   * @description For a given list of records, add '.invalid' to the values on specific email fields.
   * @param List<SObject> sObjectsList - list of records to add '.invalid' to their email fields.
   * @param Set<String> emailFieldsToUpdateSet - Set of email field names to update.
   * @return  List<SObject> sObjectsToUpdateList;
   */
  public List<SObject> updateEmailFields(
    List<SObject> sObjectsList,
    Set<String> emailFieldsToUpdateSet
  ) {
    List<SObject> sObjectsToUpdateList = new List<SObject>();
    String currentValue;
    Boolean changed;
    for (SObject record : sObjectsList) {
      changed = false;
      for (String emailField : emailFieldsToUpdateSet) {
        currentValue = (String) record.get(emailField);
        if (currentValue != null && !currentValue.contains('.invalid')) {
          //System.debug('### BEFORE in field ' + emailField + ', value: ' + currentValue);
          record.put(emailField, currentValue + '.invalid');
          changed = true;
          //System.debug('### AFTER: in field ' + emailField + ', value: ' + (String)record.get(emailField));
        }
      }
      if (changed) {
        sObjectsToUpdateList.add(record);
      }
    }
    System.debug(
      '### AddInvalidToEmailFields, size of changed values: ' +
      sObjectsToUpdateList.size()
    );
    return sObjectsToUpdateList;
  }
  /**
   * @author Itzik Winograd
   * @date 09/01/2022
   * @description send the records with the '.invalid' on their email to the QueueableDMLUtils for update
   * @param List<SObject> sObjectsList - list of records to update with invalid on the email fields.
   * @return none
   */
  public void updateInvalidOnRecords(List<SObject> sObjectsList) {
    if (GeneralUtil.getEnvName() != 'prod' || Test.isRunningTest()) {
      //make sure it will never work on production
      Database.update(sObjectsList, false);
    }
  }
}

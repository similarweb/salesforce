/**
 * @author          Itzik Winograd
 * @date            17/07/2022
 * @description     Delete records in batches based on the Custom query
 */
public without sharing class DeleteRecordsBatch implements Database.Batchable<sObject> {
  private String objectName = '';
  private String query = '';
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();
  private final Integer BATCH_SIZE = Integer.valueOf(
    GeneralUtil.getGeneralConfig('DeleteRecordsBatchSize').Number_Value__c
  );

  /**
   * @author Itzik Winograd
   * @description constructor.
   *              builds the name of the custom query with DeleteRecordsBatch_{objectName} and gets it from the custom metadata
   * @param String objectName - name of the object to delete records from.
   */
  public DeleteRecordsBatch(String objectName) {
    this.objectName = objectName;
    query = CustomQueriesUtils.getCustomQuery(
      'DeleteRecordsBatch_' + objectName
    );
    System.debug('### DeleteRecordsBatch query: ' + query);
  }

  /**
   * @author Itzik Winograd
   * @description Batch start. query for the records with the 'query' param.
   */
  public Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  /**
   * @author Itzik Winograd
   * @description Batch execute. Delete the scoped records. Create and publish logs if needed.
   */
  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    try {
      Database.delete(scope, false);
    } catch (Exception ex) {
      logEvents.add(
        LogEventUtils.createLogEventRecord(
          new List<Id>{},
          'DeleteRecordsBatch',
          'execute',
          ex.getStackTraceString(),
          'Error in deleting ' + objectName + ': ' + ex.getMessage(),
          'Error'
        )
      );
    }
    if (!logEvents.isEmpty()) {
      EventBus.publish(logEvents);
    }
  }

  /**
   * @author Itzik Winograd
   * @description Batch finish. Start another batch job if there are records left on the object.
   */
  public void finish(Database.BatchableContext BC) {
    Integer recordListSize = Database.query(query).size();
    if (recordListSize > 0) {
      Database.executeBatch(new DeleteRecordsBatch(objectName), BATCH_SIZE);
    }
  }
}

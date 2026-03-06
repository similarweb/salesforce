/**
* @author Itzik Winograd
* @date 29/08/2021
* @description Batch class to delete sensitive attachments. Get the keywords to delete from GeneralConfig.
*              MIS-1143
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 03/03/2022
* description - Work with custom  DeleteSensitiveAttachments
* --------------------------------------------------------------------------------------
*/
public without sharing class DeleteSensitiveAttachmentsBatch implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC) {
        String CUSTOM_QUERY_PROCESS_NAME = 'DeleteSensitiveAttachments';
        String query = buildQuery(CUSTOM_QUERY_PROCESS_NAME);
        return Database.getQueryLocator(query);
    }
    /**
    * @author Itzik Winograd
    * @date 29/08/2021
    * @description Batch execution method. delete ContentDocument records and log errors/execution.
    * @param Database.BatchableContext BC
    * @param List<SObject> recordsList
    * @return String the query.
    */
    public void execute(Database.BatchableContext BC, List<SObject> recordsList) {
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        List<Sobject> successSobj = new List<Sobject>();
        List<Database.DeleteResult> sObjectSR = Database.delete(recordsList,false);
        for (Integer i = 0; i < sObjectSR.size(); i++) {
            Database.DeleteResult result = sObjectSR[i];
            if (!result.isSuccess()) {
                logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>{recordsList[i].Id}, 'DeleteSensitiveAttachmentsBatch', 'execute', 
                    JSON.serialize(recordsList[i]), result.getErrors().toString(), 'Error',null,null));
            } else { //success
                successSobj.add(recordsList[i]);
            }
        }
        if(!successSobj.isEmpty()){
            logEvents.add(LogEventUtils.createLogEventRecord(successSobj, 'DeleteSensitiveAttachmentsBatch', 'execute', 
                null, 'Records specified were successfully deleted', 'info',null,null));
        }
        Eventbus.publish(logEvents);
    }

    public void finish(Database.BatchableContext jobIdParam) {
        //Do nothing
    }

    /**
    * @author Itzik Winograd
    * @date 03/03/2021
    * @description Get the query from the CustomQueriesUtils according to the processName
    * @param String processName - the processName in the Custom Metadata.
    * @return String the query.
    */
    @testVisible
    public static String buildQuery (String processName) {
        String query = CustomQueriesUtils.getCustomQuery(processName);
        System.debug('### DeleteSensitiveAttachmentsBatch query: ' +query);
        return query;
    }

}
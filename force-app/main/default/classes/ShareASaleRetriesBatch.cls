/**
* @author Itzik Winograd
* @date 10/08/2021
* @description Get sharasale records with errors and resend them. MIS-1084
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
public without sharing class ShareASaleRetriesBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {

    private List<Log_Event__e> logEvents = new List<Log_Event__e>();
    String objectNameToQuery = '';
    public ShareASaleRetriesBatch( String objectNameToQuery){
        this.objectNameToQuery = objectNameToQuery;
    }

    /**
    * @author Itzik Winograd
    * @date 10/08/2021
    * @description Start method of the batch. Get leads and contacts without "Transaction Created" in the response field.
    * @param Database.BatchableContext BC.  
    * @return Database.QueryLocator.
    */
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = createContactsQuery(objectNameToQuery);
        return Database.getQueryLocator(query);
    }
    /** 
    * @author Itzik Winograd
    * @date 10/08/2021
    * @description: Create a query for recoreds with ShareASale errors
    * @param String objectNameToQuery
    * @return String a nested query of accounts with contacts.
    */ 
    private String createContactsQuery(String objectNameToQuery){
        String query ='SELECT Id, ShareASale_New_Transaction_Response__c, Affiliate_ID__c, Order_Number__c, ShareASale_Retries_Counter__c ' + 
                        'FROM ' + objectNameToQuery +' ' +
                        'WHERE Affiliate_Id__c != null ' +
                        'AND Affiliate_Id__c != \'organic\' ' +
                        'AND ShareASale_New_Transaction_Response__c != \'Transaction Created\' '+
                        'AND ShareASale_New_Transaction_Response__c != null';
        return query;
    }

    /**
    * @author Itzik Winograd
    * @date 10/08/2021
    * @description: loop over the found records, create logs for retries>3 
    *               and send retries for new/reference call types.
    * @param Database.BatchableContext jobId
    * @param List<Object> recordList
    * @return Void.
    */
    public void execute(Database.BatchableContext jobId, List<SObject> recordList) {
        List<SObject> newRequestRetryList = new List<SObject>();
        List<SObject> referenceRequestRetryList = new List<SObject>();
        List<SObject> tooManyRetriesList = new List<SObject>();
        System.debug('### ShareASaleRetriesBatch: ' + recordList.size());
        for (SObject sobj:recordList){
            if((Decimal)sobj.get('ShareASale_Retries_Counter__c') > 3){
                tooManyRetriesList.add(sobj);
            } else {
                if(sobj.get('Order_Number__c') == null){//new request
                    newRequestRetryList.add(sobj);
                } else { //reference request
                    referenceRequestRetryList.add(sobj);
                }
            }
        }
        
        sendRertyRequests(newRequestRetryList, referenceRequestRetryList);
        creatTooManyRetriesLog(tooManyRetriesList);
    }
    /**
    * @author Itzik Winograd
    * @date 10/08/2021
    * @description Send ShareASale requests with the right new/reference call type.
    * @param List<SObject> newRequestRetryList - sobjects to send to shareasale with "new" request type
    * @param List<SObject> referenceRequestRetryList -  sobjects to send to shareasale with "reference" request type
    * @return Void.
    */
    public void sendRertyRequests(List<SObject> newRequestRetryList, List<SObject> referenceRequestRetryList){
        //System.debug('### in ShareASaleRetriesBatch: sendRertyRequests');
        if(!newRequestRetryList.isEmpty()){
            System.enqueueJob(new ShareASaleQuauableCalls(newRequestRetryList, 'new')); 
        }
        if(!referenceRequestRetryList.isEmpty()){
            System.enqueueJob(new ShareASaleQuauableCalls(referenceRequestRetryList, 'reference')); 
        }
    }

    /**
    * @author Itzik Winograd
    * @date 10/08/2021
    * @description Create Log_event record with error for over 3 failed attempts.
    * @param List<SObject> tooManyRetriesList - list of records with over 3 retries.  
    * @return Void.
    */
    public void creatTooManyRetriesLog(List<SObject> tooManyRetriesList){
        if(!tooManyRetriesList.isEmpty()){        
            logEvents.add(
                LogEventUtils.createLogEventRecord(tooManyRetriesList, 
                'ShareASaleRetriesBatch', 'creatTooManyRetriesLog', '','The records specified has over 3 failed attempts to ShareASale.' , 'Error',null,null)
            );
        }
    }
    /**
    * @author Itzik Winograd
    * @date 10/08/2021
    * @description Publish log events if created
    * @param None.  
    * @return Void.
    */
    public void finish(Database.BatchableContext jobIdParam) {
        if (!logEvents.isEmpty()){
            EventBus.publish(logEvents);
        }
    }
}
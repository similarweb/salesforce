/**
* @author Itzik Winograd
* @date 27/01/2021
* @description Perform  transition from Most_Recent_Cadence_Cadence_Name__c to SalesLoft1__Most_Recent_Cadence_Name__c
* only if the value in the field SalesLoft1__Most_Recent_Cadence_Name__c already exist as a cmagin.
* Written as a solution to MIS-19.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      -  
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/
global class MostRecentCadenceNameBatch implements Database.Batchable<sObject> {
    String objectName;
    String errorMsg = '';
    String query = '';
    NoTouch_API_log__c logRecord = new NoTouch_API_log__c();
    
    global MostRecentCadenceNameBatch(String objectNameToProcess){
         objectName = objectNameToProcess;
         query = 'SELECT Id, Most_Recent_Cadence_Cadence_Name__c, SalesLoft1__Most_Recent_Cadence_Name__c ' +
                    'FROM ' + objectName + ' ' +
                    //'FROM LEAD ' +
                    'WHERE Most_Recent_Cadence_Cadence_Name__c LIKE \'%Outbound%\' ' + 
                    'AND SalesLoft1__Most_Recent_Cadence_Name__c = null';
     }

    global Database.querylocator start(Database.BatchableContext BC) {
        System.debug('batch query: ' + query);
        //get all leads with data in the old field and empty new field
        return  Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> recordList) {

        //get existing outbound campaings names and put them in a set       
        Set<String> existingOutboundCampains = new Set<String>();
        for(Campaign camp : [SELECT Name
                               FROM Campaign
                              WHERE Name LIKE '%Outbound%']){
        existingOutboundCampains.add (camp.Name);                     
        }
        List<sObject> sObjectsToUpdate = new List<sObject>();
        for (sObject obj : recordList){
            if(existingOutboundCampains.contains((String)obj.get('Most_Recent_Cadence_Cadence_Name__c'))){ 
                //an existing campaign - we can copy from one field to another without generating new lead
                obj.put('SalesLoft1__Most_Recent_Cadence_Name__c', obj.get('Most_Recent_Cadence_Cadence_Name__c'));
            }//for all leads we need to clear the old field
            obj.put('Most_Recent_Cadence_Cadence_Name__c', '');
            sObjectsToUpdate.add(obj);
        }     
        System.debug('sObjectsToUpdate: ' + sObjectsToUpdate.size());
        //Handle logging
        Database.SaveResult[] results = Database.update(sObjectsToUpdate, false);
        for(Integer i = 0, size = results.size(); i < size; i++) {
            if(!results[i].isSuccess()) {
                for(Database.Error error : results[i].getErrors()) {
                    errorMsg += '\n ' + error.getMessage();
                }
            }
        }
       
    }

    global void finish(Database.BatchableContext jobIdParam) {
        if(errorMsg!=''){
            System.debug('Errors Found: '+ errorMsg);
            logRecord.Execution_Log__c = errorMsg;
            insert logRecord;
        }   
    }
}
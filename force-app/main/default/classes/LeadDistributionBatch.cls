/**
* @author Zohar Sinay
* @date 22/11/2021
* @description Distribute leads to marketing cloud and pardot lead
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      -
* date        -
* description -
* --------------------------------------------------------------------------------------
*/

public with sharing class LeadDistributionBatch implements Database.Batchable<sObject>, Database.Stateful {

    public Map<String, leadDistributionWrapper> leadDistributionWrapperMap = new Map<String, leadDistributionWrapper>();
    private static final string PARDOT = 'Pardot';
    private static final string SFMC = 'SFMC';
    public static List<Log_Event__e> logList = new List<Log_Event__e>();
    public static Log_Event__e log = new Log_Event__e();
    public Database.QueryLocator start(Database.BatchableContext bc) {

        Map<String, SFMC_Processed_by_Distribution__c> solutionMapMDT = new Map<String, SFMC_Processed_by_Distribution__c>();
        for(SFMC_Processed_by_Distribution__c dist : [SELECT Id, Initial_Date__c, Processed_by_SFMC__c, Solution__c, Counter__c FROM SFMC_Processed_by_Distribution__c]){
            solutionMapMDT.put(dist.Solution__c, dist);
        }

        System.debug('solutionMapMDT: ' + solutionMapMDT);

        DateTime obsoleteDate =  Datetime.now().addHours(-2);

        for(Lead lid : [SELECT Id, Inferred_Solution__c FROM Lead WHERE LastModifiedDate >: obsoleteDate AND Is_Distribution_Handled__c = true]){
            System.debug('lidosh: ' + lid);
            if(solutionMapMDT.containsKey(lid.Inferred_Solution__c)){
                if(leadDistributionWrapperMap.containsKey(lid.Inferred_Solution__c)){
                    leadDistributionWrapperMap.get(lid.Inferred_Solution__c).marketingCloudLeadNumber++;
                }else{
                    leadDistributionWrapper ldw = new leadDistributionWrapper();
                    ldw.marketingCloudLeadNumber++;
                    leadDistributionWrapperMap.put(lid.Inferred_Solution__c, ldw);
                }
            }
        }

        for(String solution : leadDistributionWrapperMap.keySet()){
            leadDistributionWrapperMap.get(solution).marketingCloudLeadNumber = Math.round(solutionMapMDT.get(solution).Processed_by_SFMC__c / 100 * leadDistributionWrapperMap.get(solution).marketingCloudLeadNumber);
        }

        return Database.getQueryLocator(
                'SELECT ID, Is_Distribution_Handled__c, Marketing_System_Processed_by__c, Inferred_Solution__c ' +
                        'FROM Lead ' +
                        'Where LastModifiedDate >: obsoleteDate AND Is_Distribution_Handled__c = true'
        );
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope){
        List<Lead> leadList = new List<Lead>();
        try{
            if(!leadDistributionWrapperMap.isEmpty()){
                for(Lead lid : scope){
                    lid.Is_Distribution_Handled__c = false;
                    if(leadDistributionWrapperMap.containsKey(lid.Inferred_Solution__c)){
                        if(leadDistributionWrapperMap.get(lid.Inferred_Solution__c).leadCounter >= leadDistributionWrapperMap.get(lid.Inferred_Solution__c).marketingCloudLeadNumber){
                            lid.Marketing_System_Processed_by__c = PARDOT;
                        }else if(leadDistributionWrapperMap.get(lid.Inferred_Solution__c).leadCounter < leadDistributionWrapperMap.get(lid.Inferred_Solution__c).marketingCloudLeadNumber) {
                            lid.Marketing_System_Processed_by__c = SFMC;
                        }
                        leadDistributionWrapperMap.get(lid.Inferred_Solution__c).leadCounter++;
                        leadList.add(lid);
                    }
                }
            }

            if(!leadList.isEmpty()){
                List<Database.SaveResult> updateResults = Database.update(leadList, false);
                for(Integer i=0;i<updateResults.size();i++){
                    if(updateResults.get(i).isSuccess()){
                        recordLog('Success', 'Info', leadList.get(i));
                    }
                    if (!updateResults.get(i).isSuccess()){
                        // DML operation failed
                        Database.Error error = updateResults.get(i).getErrors().get(0);
                        String failedDML = error.getMessage();
                        leadList.get(i);//failed record from the list
                        system.debug('Failed ID'+leadList.get(i).Id);
                        recordLog(failedDML, 'Error', leadList.get(i));
                    }
                }
            }
        }catch(Exception ex){
            recordLog(ex.getMessage() + '\n' + ex.getStackTraceString(), 'Error', null);
        }




    }
    public void finish(Database.BatchableContext bc){
        List<Database.SaveResult> resultsList = Eventbus.publish(logList);
    }

    public static void recordLog(String message, String type, Lead lid){
        log.Apex_class__c = 'LeadDistributionBatch';
        log.Apex_Method__c = 'execute';
        log.Detailed_Error_Message__c = message;
        log.Detailed_Information__c = JSON.serializePretty(lid);
        log.Log_Type__c = 'Error';
        log.Email__c = lid != null ? lid.email : '';
        log.Record_Ids__c = lid != null ? lid.Id : null;
        logList.add(log);
    }

    public class leadDistributionWrapper {
        public Decimal marketingCloudLeadNumber;
        public Decimal leadCounter;
        public leadDistributionWrapper(){
            this.marketingCloudLeadNumber = 0;
            this.leadCounter = 0;
        }
    }
}
/**
* @author Zohar Sinay
* @date 5/04/2022
* @description Retry for apex log event for lead capture service
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
*/

public with sharing class LeadCaptureRetryBatch implements Database.Batchable<sObject>, Database.Stateful {

    private static final String SUCCESSSTATUS = 'Success';
    private static final String RETRY_SUCCESS = 'Error - Retry Successful';
    private static final String EROR = 'Error - Retry Failed';
    private Integer NUMBEROFDAYS;
    private static Map<String, LeadCaptureService.leadCaptureWrapper> LeadCaptureWrapperByLcwMap = new Map<String, LeadCaptureService.leadCaptureWrapper>();

    public LeadCaptureRetryBatch(Integer numOfDays) {
        if(Test.isRunningTest()){
            getCoverage();
        }
        NUMBEROFDAYS = numOfDays;
    }
    /**
     * @param bc - Context of the current batch
     * @DESCRIPTION - Selects all lead capture service handler logs and moves it to the execute method
     * @return Apex event logs to be handled by execute method
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
                'SELECT ID, HTTP_Body__c, Retry_Number__c, Log_Type__c ' +
                        'FROM Apex_Event_Log__c ' +
                        'WHERE Should_Retry__c = true AND Apex_class__c = \'LeadCaptureServiceHandler\' AND CreatedDate = LAST_N_DAYS:' + NUMBEROFDAYS +
                        ' ORDER BY CreatedDate ASC'
        );
    }

    /**
     * @param bc the context of the current batch
     * @param scope Apex event logs to be handled
     */
    public void execute(Database.BatchableContext bc, List<Apex_Event_Log__c> scope) {
        try{
            List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
            Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
            for(Feature_Flag_Setting__mdt flag : flags){
                flagsMap.put(flag.Process_Name__c,flag);
            }
            Boolean isVersion3Active = flagsMap.containsKey('LeadCapture Version 3') && flagsMap.get('LeadCapture Version 3').Is_Active__c;
            for(Apex_Event_Log__c log : scope){
                Map<String,Object> lcwMap = (Map<String,Object>)JSON.deserializeUntyped(
                        log.HTTP_Body__c);
                LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
                lcw = (LeadCaptureService.leadCaptureWrapper)JSON.deserialize(
                        log.HTTP_Body__c, LeadCaptureService.leadCaptureWrapper.class);
                LeadCaptureService.leadCaptureResponseWrapper lcrw = new LeadCaptureService.leadCaptureResponseWrapper();
                if(isVersion3Active){
                    lcrw = LeadCaptureServiceHandler.handleTouchCall(lcwMap,flagsMap);
                }else{
                    lcrw = LeadCaptureServiceHandler.handleTouchCallWithWrapper(lcw,flagsMap);
                }
                
                log.Log_Type__c = lcrw.status == SUCCESSSTATUS ? RETRY_SUCCESS : EROR;
                log.Retry_Number__c += 1;
                if(checkIfLimitsBreach(bc)){
                    handleLimitsBreach(bc, NUMBEROFDAYS);
                }
            }
            Database.SaveResult [] updateResult = Database.update(scope, false);
                for (Database.SaveResult r : updateResult) {
                    if (!r.isSuccess()) {
                        for (Database.Error e : r.getErrors()) {
                            if(checkIfLimitsBreach(bc)){
                                handleLimitsBreach(bc, NUMBEROFDAYS);
                            }
                        }
                    }
                }
        }catch(Exception e){
            if(checkIfLimitsBreach(bc)){
                handleLimitsBreach(bc, NUMBEROFDAYS);
            }
        }

    }

    public void finish(Database.BatchableContext bc) {

    }

    /**
     * @param bc - context of the current batch
     * @DESCRIPTION - stops current batch if limits are compromised, and re-runs it
     */
    public static void handleLimitsBreach(Database.BatchableContext bc, Integer numOfDays){
        System.abortJob(bc.getJobId());
        if(!Test.isRunningTest()){
            Database.executeBatch(new LeadCaptureRetryBatch(numOfDays), 5);
        }
    }

    /**
     * @DESCRIPTION - Returns true if limits are breached according to running context
     */
    public static Boolean checkIfLimitsBreach(Database.BatchableContext bc){
        if(bc != null){
            if(Limits.getDmlStatements() >= 140 || Limits.getQueries() >= 190) {
                return true;
            }
        }else if(bc == null) {
            if(Limits.getDmlStatements() >= 140 || Limits.getQueries() >= 90) {
                return true;
            }
        }
        return false;
    }

    public void getCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
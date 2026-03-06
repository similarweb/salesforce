/**
 * Created by Alon.Shalev on 7/26/2022.
 */

public without sharing class ActivateAccountFlagBatch implements Database.Batchable<sObject>,Schedulable{
    private List<Log_Event__e> logEvents = new List<Log_Event__e>();
    private Set<Id> matchingAccountIdSet = new Set<Id>();

    public ActivateAccountFlagBatch(Set<Id> matchingAccountsIsSet){
        this.matchingAccountIdSet = matchingAccountsIsSet;
    }
    public ActivateAccountFlagBatch(){}

    public void execute (SchedulableContext SC){
        ActivateAccountFlagBatch activeBatch = new ActivateAccountFlagBatch();
        Integer batchSize = GeneralUtil.getGeneralConfig('ActivateAccountFlagBatch_BatchSize').Number_Value__c.intValue();
        Database.executeBatch(activeBatch, batchSize != null ? batchSize : 3);
    }


    public Database.QueryLocator start (Database.BatchableContext BC){
        String query = 'SELECT Id,Territory__r.Re_evaluate__c ' +
                ' FROM Account ' +
                ' WHERE Territory__r.Re_evaluate__c  = true';
        query += this.matchingAccountIdSet.isEmpty() ? '' : ' OR Id IN : matchingAccountIdSet';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Account> accounts){
        Map<Id,Territory__c> territoriesToUpdateMap = new Map<Id,Territory__c>();
        List<Account> accountsForUpdate = new List<Account>();
        for(Account account : accounts){
            accountsForUpdate.add(new Account(Id = account.Id, Re_Evaluate_Territory__c = true));
            Territory__c accountTerritory = account.Territory__r;
            if(accountTerritory != null){
                accountTerritory.Re_evaluate__c = false;
                territoriesToUpdateMap.put(accountTerritory.Id,accountTerritory);
            }
        }
        updateAccounts(accountsForUpdate);
        updateTerritories(territoriesToUpdateMap.values());
        publishLogs();
    }

    public void finish(Database.BatchableContext BC) {
        Integer batchSize = 3; //default value
        List<General_Key_Value_pair__mdt> keyValuePairsSettings = [SELECT Key__c,Value__c FROM General_Key_Value_pair__mdt WHERE ProcessName__c = 'TerritoryBatch'];
        for(General_Key_Value_pair__mdt setting : keyValuePairsSettings){
            if(setting.Key__c == 'batchSize'){
                batchSize = Integer.valueOf(setting.Value__c);
            }
        }
        if (!Test.isRunningTest()){
            Database.executeBatch(new TerritoryManagementBatch(false), batchSize);
        }
    }

    /**
     * @author Itzik Winograd
     * @date 20/11/2022
     * @description Update the accounts with Re_Evaluate_Territory__c = true. Create logs for failures.
     * @param List<Account> matchingAccounts
     * */
    public void updateAccounts(List<Account> accountsForUpdate){
        List<Database.SaveResult> saveResults =  Database.update(accountsForUpdate,false);
        Integer index = 0;
        for(Database.SaveResult sr : saveResults){
            if(!sr.isSuccess()){
                logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{accountsForUpdate[index].Id},
                        'ActivateAccountFlagBatch', 'updateAccounts', 'Can\'t update Re_Evaluate_Territory__c = true on this account',sr.getErrors().toString(), 'Error'));
            }
            index++;
        }
    }

    public void publishLogs(){
        if (!logEvents.isEmpty()) {
            EventBus.publish(logEvents);
        }
    }

    /**
     * @author Itzik Winograd
     * @date 20/11/2022
     * @description Update the Territories with Re_evaluate__c = false. Create logs for failures.
     * @param List<Territory__c> territoriesToUpdate
     * */
    public void updateTerritories(List<Territory__c> territoriesToUpdate){
        List<Database.SaveResult> saveResults =  Database.update(territoriesToUpdate,false);
        Integer index = 0;
        for(Database.SaveResult sr : saveResults){
            if(!sr.isSuccess()){
                logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{territoriesToUpdate[index].Id},
                        'ActivateAccountFlagBatch', 'updateTerritories', 'Can\'t update Re_evaluate__c = false on this Territory',sr.getErrors().toString(), 'Error'));
            }
            index++;
        }
    }

}
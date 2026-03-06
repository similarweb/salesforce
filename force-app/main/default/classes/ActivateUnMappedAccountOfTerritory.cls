/**
 * Created by Alon.Shalev on 11/7/2022.
 */

public with sharing class ActivateUnMappedAccountOfTerritory implements Database.Batchable<sObject>,Schedulable , Database.Stateful{

    private List<Log_Event__e> logEvents = new List<Log_Event__e>();
    private Set<Id> accountIdsSet = new Set<Id>();

    public void execute (SchedulableContext SC){
        ActivateUnMappedAccountOfTerritory activeBatch = new ActivateUnMappedAccountOfTerritory();
        Database.executeBatch(activeBatch, 1); //Always run on batch size 1
    }

    public Database.QueryLocator start (Database.BatchableContext BC){
        String query = 'SELECT Id,Industry_Subtype__c,SW_Industry__c,Sub_Division__c,Strategic_Pod__c ' +
                ' FROM Territory__c ' +
                'WHERE Re_evaluate__c  = true';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Territory__c> territories){
        // this batch will only go 1 territory at a time.
        List<Account> matchingAccounts = new List<Account>();
        System.debug('### ActivateUnMappedAccountOfTerritory - executing single territory: ' + territories[0]);
        if(String.isNotBlank(territories[0].Strategic_Pod__c)){
            matchingAccounts = findAccountsByStrategicPod(territories[0]);
        } else {
            matchingAccounts = findAccountsByIndustryFields(territories[0]);
        }

        collectAccounts(matchingAccounts);
        updateTerritory(territories[0]);
        publishLogs();
    }
    private void collectAccounts(List<Account> matchingAccount){
        for(Account acc : matchingAccount){
            accountIdsSet.add(acc.Id);
        }
    }

    /**
     * === Change ====
     * @date 25/12/2022
     * @author Itzik Winograd
     * @description MIS-3258: return only matching accounts
     * */
    private List<Account> findAccountsByStrategicPod(Territory__c territory){
        String strategicPod = territory.Strategic_Pod__c;
        List<Account> matchingAccounts = [
                SELECT Id
                FROM Account
                WHERE Strategic_Pod__c = :strategicPod AND Territory__c != :territory.Id AND Re_Evaluate_Territory__c = false AND
                      RecordType.Name = 'Default'
                      AND (NOT owner.UserRole.Name LIKE '%108%')
                      AND (NOT owner.UserRole.Name LIKE '%Alpha%')
                      AND (NOT owner.UserRole.Name LIKE '%Altudo%')
                      AND (NOT Owner.UserRole.Name LIKE '%Internal%')
                      AND (NOT Owner.UserRole.Name LIKE '%Product Marketing & Strategy%')
                      AND (Data_Integrator__c = true)
                      AND (NOT Owner.UserRole.Name LIKE '%Panel Acquisition%')
                      AND (NOT Owner.UserRole.Name LIKE '%Self Services%')
                LIMIT 50000
        ];
        return matchingAccounts;
    }

    /**
     * === Change ====
     * @date 25/12/2022
     * @author Itzik Winograd
     * @description MIS-3258: return only matching accounts
     * */
    private List<Account> findAccountsByIndustryFields(Territory__c territory){
//        List<String> subTypeList = String.isNotBlank(territory.Industry_Subtype__c) ? territory.Industry_Subtype__c.split(';') : new List<String>{null};
//        String subTypeListString = '\''+ string.join(subTypeList,'\',\'') + '\'';
//        String industrySubTypeQuery;
//        if(subTypeList.contains('Empty')) {
//            industrySubTypeQuery = ' AND (Industry_Subtype__c IN (' + subTypeListString+') OR Industry_Subtype__c = null) ';
//        } else {
//            industrySubTypeQuery = ' AND Industry_Subtype__c IN (' + subTypeListString+') ';
//        }  22.1.25 -alon shalev removed  : Update to Territory Logic - Remove SubType & NAL assignment by Subdiv fixM IS-6634

        String territoryId = territory.Id;
        String territoryIndustry = territory.SW_Industry__c;
        String territorySubDivision = territory.Sub_Division__c;
        String query = 'SELECT Id ' +
                ' FROM Account ' +
                ' WHERE RecordType.Name = \'Default\' ' +
                ' AND Territory__c != \'' +territoryId + '\' '+
                ' AND SW_Industry__c = \'' +territoryIndustry  + '\' '+
                ' AND Sub_Division__c = \''+ territorySubDivision + '\' '+
//                industrySubTypeQuery +
                ' AND Re_Evaluate_Territory__c = false ' +
                ' AND (NOT Owner.UserRole.Name LIKE \'%Altudo%\') ' +
                ' AND (NOT Owner.UserRole.Name LIKE \'%Alpha%\') ' +
                ' AND (NOT Owner.UserRole.Name LIKE \'%108%\') ' +
                ' AND (NOT Owner.UserRole.Name LIKE \'%Internal%\') ' +
                ' AND (NOT Owner.UserRole.Name LIKE \'%Product Marketing & Strategy%\') ' +
                ' AND (Data_Integrator__c = true) ' +
                ' AND (NOT Owner.UserRole.Name LIKE \'%Panel Acquisition%\') ' +
                ' AND (NOT Owner.UserRole.Name LIKE \'%Self Services%\') ' +
                ' LIMIT 50000';
        System.debug('### findAccountsByIndustryFields query: ' + query);
        List<Account> matchingAccounts = Database.query(query);
        System.debug('matchingAccounts--'+matchingAccounts.size());
        return matchingAccounts;
    }

    /**
     * @author Itzik Winograd
     * @date 20/11/2022
     * @description Update the accounts with Re_Evaluate_Territory__c = true. Create logs for failures
     * @param List<Account> matchingAccounts
     * */
//    public void updateAccounts(List<Account> matchingAccounts){
//        List<Account> accountsForUpdate = new List<Account>();
//        for(Account acc : matchingAccounts){
//            accountsForUpdate.add(new Account(
//                    Id = acc.Id,
//                    Re_Evaluate_Territory__c = true));
//        }
//        System.debug('### ActivateUnMappedAccountOfTerritory accountsForUpdate: ' + accountsForUpdate);
//        List<Database.SaveResult> saveResults =  Database.update(accountsForUpdate,false);
//        Integer index = 0;
//        for(Database.SaveResult sr : saveResults){
//            if(!sr.isSuccess()){
//                logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{accountsForUpdate[index].Id},
//                        'ActivateUnMappedAccountOfTerritory', 'execute', 'Can\'t update Re_Evaluate_Territory__c = true on this account', sr.getErrors().toString(), 'Error'));
//            }
//            index++;
//        }
//    }

    /**
     * @author Itzik Winograd
     * @date 20/11/2022
     * @description Query for related Accounts for a territory, if none found - uncheck Re_evaluate__c on the territory. Create logs for failures
     * @param Territory__c territory
     * */
    public void updateTerritory(Territory__c territory){
        Id territoryId = territory.Id;
        Integer numOfAccounts = database.countQuery('SELECT Count() FROM Account WHERE Territory__c = :territoryId');
        System.debug('### ActivateUnMappedAccountOfTerritory territoryId: + '+ territoryId + ', count: ' + numOfAccounts);
        if (numOfAccounts == 0){
            Territory__c territoryToUpdate = new Territory__c(Id = territory.Id, Re_evaluate__c = false);
            List<Database.SaveResult> saveResults =  Database.update(new List<Territory__c>{territoryToUpdate},false);
            if(!saveResults[0].isSuccess()){
                logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{territoryToUpdate.Id},
                        'ActivateUnMappedAccountOfTerritory', 'updateTerritory', 'Failed to uncheck Re_evaluate__c on this territory. ', saveResults[0].getErrors().toString(), 'Error'));
            }
        }
    }

    /**
     * @author Itzik Winograd
     * @date 20/11/2022
     * @description Publish logs if exists.
     * */
    public void publishLogs(){
        if (!logEvents.isEmpty()) {
            EventBus.publish(logEvents);
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(!Test.isRunningTest()){
            Integer batchSize = GeneralUtil.getGeneralConfig('ActivateAccountFlagBatch_BatchSize').Number_Value__c.intValue();
            Database.executeBatch(new ActivateAccountFlagBatch(this.accountIdsSet), batchSize != null ? batchSize : 3);
        }
    }

}
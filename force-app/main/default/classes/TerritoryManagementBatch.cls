/**
 * Created by Alon.Shalev on 7/19/2022.
 */
/**
* @author Alon  Shalev
* @date  28/07/2022/
* @description: this class is a schedule and a batch for populating all accounts for a specific territory__c object and adding all the territory members to be in the accountTeamMember
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      -
* date        -
* description -
* --------------------------------------------------------------------------------------
*/
public without sharing class TerritoryManagementBatch implements Database.Batchable<sObject>,Schedulable{

    private final String BREAKER = ':&';
    private Boolean activateInfoLogs = false;
    private Boolean activateErrorLogs = true;
    private Boolean ownerChangeLogic;
    private Integer batchSize = 3;
    private Set<String> statusesToExcludeFromOwnerChange = new Set<String>();
    private List<Log_Event__e> logEvents = new List<Log_Event__e>();
    private Boolean isSingleRun = false; //when false, the batch size will be taken from the CMD, and afterwards another batch will run with batch size 1.
    private final static String NT_ROLE_NAME = 'No-Touch MIR';

    /**
     * @description Constructor. Set values from the TerritoryBatch CMD
     * */
    public TerritoryManagementBatch(Boolean isSingleRun){
        List<General_Key_Value_pair__mdt> keyValuePairsSettings = [SELECT Key__c,Value__c FROM General_Key_Value_pair__mdt WHERE ProcessName__c = 'TerritoryBatch'];
        for(General_Key_Value_pair__mdt setting : keyValuePairsSettings){
            switch on setting.Key__c{
                when 'excluded status for owner change'{
                    this.statusesToExcludeFromOwnerChange.add(setting.Value__c);
                }
                when 'activateInfoLogs'{
                    activateInfoLogs = setting.Value__c == 'true' ? true : false;
                }
                when 'activateErrorLogs'{
                    activateErrorLogs = setting.Value__c == 'true' ? true : false;
                }
                when 'ownerChangeLogic'{
                    ownerChangeLogic = setting.Value__c == 'true' ? true : false;
                }
                when 'batchSize'{
                    this.batchSize = Integer.valueOf(setting.Value__c);
                }
            }
        }
        this.isSingleRun = isSingleRun;
    }

    /**
     * @description run the batch with batch size effected from the isSingleRun
      **/
    public void execute (SchedulableContext SC){
        TerritoryManagementBatch territoryBatch = new TerritoryManagementBatch(false);
        Integer runningBatchSize = isSingleRun ? 1 : this.batchSize;
        Database.executeBatch(territoryBatch, runningBatchSize);
    }


    /**
     * @description Batch start, query for flagged accounts.
     * */
    public Database.QueryLocator start (Database.BatchableContext BC){
        String query = 'SELECT Id,SW_Industry__c,Sub_Division__c,Industry_Subtype__c,Strategic_Pod__c,Owner.SysRoleName__c,Status__c,Territory_Owner_Change_Bypass__c,' +
                'Number_of_Open_Opps__c,Number_Of_Open_Meetings__c,Exclude_From_Territory_Owner_Change__c,Owner.Name,Owner.UserRole.Name,No_Touch_Account__c ' +
                ' FROM Account ' +
                'WHERE Re_Evaluate_Territory__c = true';
        if(!isSingleRun){ //this is the regular run, so add limit on the Number_of_Contacts__c
            Integer numberOfContactsLimit = Integer.valueOf(GeneralUtil.getGeneralConfig('Territory_numberOfContactsLimit').Number_Value__c);
            query += ' AND Number_of_Contacts__c <= ' + numberOfContactsLimit;
        }
        return Database.getQueryLocator(query);
    }

    /**
     * @description Main batch execute
     * */
    public void execute(Database.BatchableContext BC, List<Account> accountList){
        System.debug(' i am inside the execute --'+accountList);

        // dataStructures
        List<Account> accountToUpdateList = new List<Account>();
        Set<String> industrySet  = new Set<String>();
        Set<String> subIndustrySet  = new Set<String>();
        Set<String> subDivisionSet  = new Set<String>();
        Set<String> strategicPodSet = new Set<String>();
        Set<Id> failedAccountIdsSet = new Set<Id>();
        List<AccountTeamMember> accountTeamMembersToInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> accountTeamMembersToDelete = new List<AccountTeamMember>();

        // methods
        fillMatchingFieldsSets(accountList,industrySet,subIndustrySet,subDivisionSet,strategicPodSet);
        Map<String, Territory__c> keyToTerritoryMap = generateKeyToTerritoryMap(industrySet,subIndustrySet,subDivisionSet,strategicPodSet);
        System.debug('keyToTerritoryMap--'+keyToTerritoryMap);
        accountTeamMembersToDelete = getOldTeamMembers(accountList);
        populateAccountsAndTeamMembers(accountList, keyToTerritoryMap,accountTeamMembersToInsert,accountToUpdateList);
        Set<String> upsertKeySet = generateATMSet(accountTeamMembersToInsert);
        List<AccountTeamMember> accountTeamMembersToDeleteAfterRemoval = removedUnNecessaryRecords(accountTeamMembersToDelete,upsertKeySet);


        // dml section
        try{
            deleteAccountTemMember(accountTeamMembersToDeleteAfterRemoval, failedAccountIdsSet);
            upsertAccountTeamMember(accountTeamMembersToInsert, failedAccountIdsSet);
            updateAccounts(accountToUpdateList, failedAccountIdsSet);
        } catch (Exception ex){
            logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>(),
                    'TerritoryManagementBatch', 'execute', 'An uncaught error has occured in one of the DML operations',
                    ex.getMessage() + '\n' + ex.getStackTraceString(),'Error'));
        }

        //logs
        publishLogs();
    }

    /**
     * @description Go over list of ATM. if an ATM is not found on the ATMsToPreserveSet, add it to the removals list
     * */
    private List<AccountTeamMember> removedUnNecessaryRecords(List<AccountTeamMember> accountTeamMembers,Set<String> ATMsToPreserveSet){
        List<AccountTeamMember> leftOvers = new List<AccountTeamMember>();
        for(AccountTeamMember accountTeamMember : accountTeamMembers){
            if(!ATMsToPreserveSet.contains(''+accountTeamMember.AccountId+accountTeamMember.UserId)){
                leftOvers.add(accountTeamMember);
            }
        }
        return leftOvers;
    }

    /**
     * @description generate ATM string set - accountId+UserId
     * */
    private Set<String> generateATMSet(List<AccountTeamMember> accountTeamMembers){
        Set<String> accountIdAndUserIdSet = new Set<String>();
        for(AccountTeamMember atmItem : accountTeamMembers){
            String key = ''+atmItem.AccountId+atmItem.UserId;
            accountIdAndUserIdSet.add(key);
        }
        return accountIdAndUserIdSet;
    }

    /**
     * @description Make an upsert dml on ATMs
     * */
    private void upsertAccountTeamMember(List<AccountTeamMember> accountTeamMembersToInsert, Set<Id> failedAccountIdsSet) {
        if (!accountTeamMembersToInsert.isEmpty()) {
            System.debug('### TerritoryManagementBatch upsertAccountTeamMember: ' + accountTeamMembersToInsert);
            Integer index = 0;
            List<Database.UpsertResult> saveResults = Database.upsert(accountTeamMembersToInsert, false);
            for (Database.UpsertResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    failedAccountIdsSet.add(accountTeamMembersToInsert[index].AccountId);
                    if(activateErrorLogs){
                        logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{accountTeamMembersToInsert[index].Id},accountTeamMembersToInsert[index].AccountId,
                                'TerritoryManagementBatch', 'upsertAccountTeamMember', 'cant Upsert this accountTeamMember', sr.getErrors().toString(), 'Error'));
                    }
                } else {
                    System.debug('### TerritoryManagementBatch handleUpsertAccountTeamMember - upserted: ' + accountTeamMembersToInsert);
                }
                index++;
            }
        }
    }

    /**
     * @description Make an update dml on Accounts
     * === changes ===
     * @date 2023-01-12
     * @description loop over failedAccountIdsSet and do not remove the flag from failed accounts (set falg to true).
     * */
    private void updateAccounts(List<Account> accountToUpdateList, Set<Id> failedAccountIdsSet) {
        System.debug('failedAccountIdsSet--'+failedAccountIdsSet);
        System.debug('accountToUpdateList--'+accountToUpdateList);
        if (!accountToUpdateList.isEmpty()) {
            if (!failedAccountIdsSet.isEmpty()){
                for (Account acc : accountToUpdateList){
                    if(failedAccountIdsSet.contains(acc.Id)){
                        acc.Re_Evaluate_Territory__c = true;
                    }
                }
            }
            System.debug('### TerritoryManagementBatch updateAccounts: ' + accountToUpdateList);
            Integer index = 0;
            List<Database.SaveResult> saveResults = Database.update(accountToUpdateList, false);
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    System.debug('didnt make it');
                    if(activateErrorLogs){
                        logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{accountToUpdateList[index].Id}, 'TerritoryManagementBatch',
                                'updateAccounts', 'Cant update this account', sr.getErrors().toString(), 'Error'));
                    }
                }else{
                    System.debug(accountToUpdateList[index].Id + ' updated successfully');
                    System.debug(accountToUpdateList[index].Territory__c);
                }
                index++;
            }
        }
    }

    /**
     * @description Make a delete dml on ATMs
     * */
    private void deleteAccountTemMember(List<AccountTeamMember> accountTeamMembersToDelete, Set<Id> failedAccountIdsSet) {
        if (!accountTeamMembersToDelete.isEmpty()) {
            System.debug('### TerritoryManagementBatch deleteAccountTemMember: ' + accountTeamMembersToDelete);
            Integer index = 0;
            List<Database.DeleteResult> saveResults = Database.delete(accountTeamMembersToDelete, false);
            for (Database.DeleteResult dr : saveResults) {
                if (!dr.isSuccess()) {
                    failedAccountIdsSet.add(accountTeamMembersToDelete[index].AccountId);
                    if(activateErrorLogs){
                        logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{accountTeamMembersToDelete[index].Id},accountTeamMembersToDelete[index].AccountId,
                                'TerritoryManagementBatch', 'deleteAccountTemMember', 'cant delete this accountTeamMember', dr.getErrors().toString(), 'Error'));
                        system.debug('delete account team member id --'+accountTeamMembersToDelete[index].Id);
                    }
                }
                index++;
            }
        }
    }

    /**
     * @description query for existing ATMs of accounts with Member_of_Territory__c = true
     * */
    private List<AccountTeamMember> getOldTeamMembers(List<Account> accountList) {
        return [SELECT Id, AccountId, UserId
        FROM AccountTeamMember
        WHERE AccountId IN :accountList
        AND Member_of_Territory__c = TRUE];
    }

    /**
     * @description Set the Accounts and ATMs list to update later.
     *              Loop over accounts and create a matching key for each one. Look for a matching territory.
     *              If a territory found for the account, update the account and create SalesManager and ATMs for it.
     *              If not, remove the Territory__c from the account and create an info log.
     * */
    private void populateAccountsAndTeamMembers(List<Account> accountList, Map<String, Territory__c> keyToTerritoryMap,List<AccountTeamMember> accountTeamMembersToInsert, List<Account> accountToUpdateList) {
        for (Account acc : accountList) {
            Boolean isResellerOwned = acc.Owner.UserRole != null && acc.Owner.UserRole.Name != null && 
                (acc.Owner.UserRole.Name.contains('108') || 
                 acc.Owner.UserRole.Name.contains('Alpha') || 
                 acc.Owner.UserRole.Name.contains('Altudo'));
            Boolean excludeThisAccountFromOwnerChange = (acc.Exclude_From_Territory_Owner_Change__c && acc.No_Touch_Account__c) || isResellerOwned;
            // alon shalev removed 22.1.25  : (String.isEmpty(acc.Industry_Subtype__c) ? 'Empty': acc.Industry_Subtype__c) +BREAKER it was after the second ":"
            String key = String.isNotBlank(acc.Strategic_Pod__c) ? acc.Strategic_Pod__c.startswith('NAL') ? acc.Strategic_Pod__c + Breaker + acc.Sub_Division__c : acc.Strategic_Pod__c : acc.SW_Industry__c+BREAKER+acc.Sub_Division__c;
            String keyWithoutStrategicPod = acc.SW_Industry__c+BREAKER+acc.Sub_Division__c;

            System.debug('key--'+key);
            if(keyToTerritoryMap.containsKey(key) || keyToTerritoryMap.containsKey(keyWithoutStrategicPod)){
                System.debug('### TerritoryManagementBatch populateAccountsAndTeamMembers--'+acc.Id +'; values: ' + key ); //acc.Industry_Subtype__c +BREAKER+acc.SW_Industry__c+BREAKER+acc.Sub_Division__c);
                Territory__c accountTerritory = keyToTerritoryMap.containsKey(key) ?  keyToTerritoryMap.get(key) : keyToTerritoryMap.get(keyWithoutStrategicPod);

                addSalesManagerFromTerritory(acc,accountTerritory,accountTeamMembersToInsert);
                for(Territory_Member__c territoryMember : accountTerritory.Territory_Members__r){
                    if(!excludeThisAccountFromOwnerChange && territoryMember.Territory_Member_Role__c == 'Sales Manager' && territoryMember.Name__c == acc.OwnerId){
                        excludeThisAccountFromOwnerChange = true;
                    }
                    createTeamMember(acc,territoryMember,accountTeamMembersToInsert);
                }
                populateAccount(acc, accountTerritory, accountToUpdateList,excludeThisAccountFromOwnerChange);
            }else{
                system.debug('### TerritoryManagementBatch not updating-- '+acc.Id+ '; Values: ' + key);
                accountToUpdateList.add(new Account(Id = acc.Id, Territory__c = null, Re_Evaluate_Territory__c = false));
                if(activateInfoLogs){
                    String kindOfMismatch = String.isNotBlank(acc.Strategic_Pod__c) ? 'Strategic_Pod__c of the account-  '+acc.Strategic_Pod__c +' is not a part of any territory ': 'industry: '+acc.SW_Industry__c+' and sub division: '+acc.Sub_Division__c+' is not a part of any territory';
                    logEvents.add(LogEventUtils.createLogEventRecord(
                            new List<String>{ acc.Id }, 'TerritoryManagementBatch', 'populateAccountsAndTeamMembers',kindOfMismatch,
                            'this account has no matching territory', 'Info'));
                }
            }
        }
    }

    /**
     * @description Populate values on the account: Territory__c and owner if needed.
     * */
    private void populateAccount(Account acc, Territory__c accountTerritory, List<Account> accountToUpdateList,Boolean excludeThisAccount) {
        acc.Territory__c = accountTerritory.Id;
        acc.Exclude_From_Territory_Owner_Change__c = excludeThisAccount;
        acc.Re_Evaluate_Territory__c = false;
        System.debug('acc.Re_Evaluate_Territory__c--'+acc.Re_Evaluate_Territory__c);
        if(this.ownerChangeLogic){
            ownerLogic(acc,accountTerritory);
        }
        accountToUpdateList.add(acc);
    }

    /**
     * @description Check if an account owner should be changed
     * */
    private void ownerLogic(Account acc,Territory__c accountTerritory){
        System.debug('statusesToExcludeFromOwnerChange--'+statusesToExcludeFromOwnerChange);
        System.debug('acc.Status__c--'+acc.Status__c);
        System.debug(!statusesToExcludeFromOwnerChange.contains(acc.Status__c));
        System.debug(acc.Number_of_Open_Opps__c == 0);
        System.debug(acc.Number_Of_Open_Meetings__c == 0);
        System.debug(!acc.Exclude_From_Territory_Owner_Change__c);
        Boolean ownerActive = accountTerritory.Owner.IsActive;
        Boolean toUpdate = (!this.statusesToExcludeFromOwnerChange.contains(acc.Status__c)) && acc.Number_of_Open_Opps__c == 0 && acc.Number_Of_Open_Meetings__c == 0 && (!acc.Exclude_From_Territory_Owner_Change__c); //  todo: need to remove th last condition and update notouch process Exclude_From_Territory_Owner_Change__c to be true
// !acc.No_Touch_Account__c && acc.Owner.Name != NT_ROLE_NAME  was added in 17.7.23 alon shalev MIS-4178
        if(ownerActive && (toUpdate || acc.Territory_Owner_Change_Bypass__c)){
            System.debug('changing owner');
            acc.OwnerId = accountTerritory.OwnerId;
            acc.Territory_Owner_Change_Bypass__c = false;
        }
    }

    /**
     * @description Add a Sales Manager ATM to an account
     * */
    private void addSalesManagerFromTerritory(Account acc, Territory__c accountTerritory, List<AccountTeamMember> accountTeamMembersToInsert) {
        if (String.isNotBlank(accountTerritory.OwnerId)) {
            AccountTeamMember accountTeamMember = createAccountTeamMember(accountTerritory.OwnerId, acc.Id, 'Sales Manager');
            accountTeamMembersToInsert.add(accountTeamMember);
        }
    }

    /**
     * @description Add an ATM to an account
     * */
    private void createTeamMember(Account acc , Territory_Member__c territoryMember,List<AccountTeamMember> accountTeamMembersToInsert){
        AccountTeamMember accountTeamMember = createAccountTeamMember(territoryMember.Name__c, acc.Id, territoryMember.Territory_Member_Role__c);
        accountTeamMembersToInsert.add(accountTeamMember);
    }

    /**
     * @author Itzik Winograd
     * @date 20/11/2022
     * @description Create an account team member with edit permissions
     * @param Id userId
     * @param Id accountId
     * @param String role
     * @return AccountTeamMember
     * */
    public AccountTeamMember createAccountTeamMember(Id userId, Id accountId, String role){
        AccountTeamMember accountTeamMember = new AccountTeamMember();
        accountTeamMember.UserId = userId;
        accountTeamMember.AccountId = accountId;
        accountTeamMember.TeamMemberRole = role;
        accountTeamMember.AccountAccessLevel = 'Edit';
        accountTeamMember.ContactAccessLevel = 'Edit';
        accountTeamMember.Member_of_Territory__c = true;
        accountTeamMember.OpportunityAccessLevel = 'Edit';
        return accountTeamMember;
    }

    /**
     * @description Get all territories and members matching for industry+subIndustry+division / strategicPod.
     * */
    private Map<String, Territory__c> generateKeyToTerritoryMap(Set<String> industrySet , Set<String> subIndustrySet , Set<String> subDivisionSet,Set<String> strategicPodSet) {
        Map<String, Territory__c> keyToTerritoryMap = new Map<String, Territory__c>();
        String subIndustrySetString = '(\'' + String.join(new List<String>(subIndustrySet), '\', \'') + '\')';
        String subDivisionSetString = '(\'' + String.join(new List<String>(subDivisionSet), '\', \'') + '\')';
        String query = 'SELECT Id,Industry_Subtype__c,SW_Industry__c,Sub_Division__c,Strategic_Pod__c,OwnerId,Owner.IsActive, ' +
                ' (SELECT Id,Name__c, Name__r.IsActive, Territory_Member_Role__c FROM Territory_Members__r WHERE Name__r.IsActive = True) ' +
                'FROM Territory__c ';
//        query +=      ' WHERE (Industry_Subtype__c INCLUDES '+subIndustrySetString;
        query +=        ' WHERE (SW_Industry__c IN : industrySet';
        query +=        ' AND Sub_Division__c INCLUDES ' +subDivisionSetString+')';
        query +=         ' OR Strategic_Pod__c IN : strategicPodSet';
        query +=      ' LIMIT 50000';
        System.debug('query--'+query);
        List<Territory__c> allTerritories = Database.query(query);
        System.debug('### generateKeyToTerritoryMap - found territories: ' + allTerritories);
        for (Territory__c terItem : allTerritories){
            if(String.isNotBlank(terItem.Strategic_Pod__c)){
                if(terItem.Strategic_Pod__c.startsWith('NAL')){
                    List<String> subDivisionMultiPickList = String.isNotBlank(terItem.Sub_Division__c) ?  terItem.Sub_Division__c.split(';') : new List<String>{'null'};
                    for(String subDivisionStr : subDivisionMultiPickList){
                        String key = terItem.Strategic_Pod__c + BREAKER + subDivisionStr;
                        String key2Str = terItem.SW_Industry__c+BREAKER+subDivisionStr;
                        keyToTerritoryMap.put(key,terItem);
                        keyToTerritoryMap.put(key2Str,terItem);
                    }
//                    keyToTerritoryMap.put(terItem.Strategic_Pod__c+BREAKER+terItem.Sub_Division__c,terItem);
                }else{
                    keyToTerritoryMap.put(terItem.Strategic_Pod__c , terItem);
                }
            }else{
//                List<String> industrySubTypeMultiPickList = String.isNotBlank(terItem.Industry_Subtype__c) ?  terItem.Industry_Subtype__c.split(';') : new List<String>{'null'};
                String key =  terItem.SW_Industry__c+BREAKER+terItem.Sub_Division__c;
                keyToTerritoryMap.put(key, terItem);
//                for(String subTypePicklistOption : industrySubTypeMultiPickList){
//                    String key = subTypePicklistOption +BREAKER+terItem.SW_Industry__c+BREAKER+terItem.Sub_Division__c;
//                    keyToTerritoryMap.put(key, terItem);
//                }
            }
        }
        System.debug('### Final keyToTerritoryMap: ' + keyToTerritoryMap);
        return keyToTerritoryMap;

//        Map<String, Territory__c> keyToTerritoryMap = new Map<String, Territory__c>();
//        String subIndustrySetString = '(\'' + String.join(new List<String>(subIndustrySet), '\', \'') + '\')';
//        String subDivisionSetString = '(\'' + String.join(new List<String>(subDivisionSet), '\', \'') + '\')';
//        String query = 'SELECT Id,Industry_Subtype__c,SW_Industry__c,Sub_Division__c,Strategic_Pod__c,OwnerId,Owner.IsActive, ' +
//        ' (SELECT Id,Name__c, Name__r.IsActive, Territory_Member_Role__c FROM Territory_Members__r WHERE Name__r.IsActive = True) ' +
//        'FROM Territory__c ';
//        query +=      ' WHERE (Industry_Subtype__c INCLUDES '+subIndustrySetString;
//        query +=        ' AND SW_Industry__c IN : industrySet';
//        query +=        ' AND Sub_Division__c INCLUDES ' +subDivisionSetString+')';
//        query +=         ' OR Strategic_Pod__c IN : strategicPodSet';
//        query +=      ' LIMIT 50000';
    }

    /**
     * @description fill all the sets of industry, subIndustry, division, strategicPod
     * */
    private void fillMatchingFieldsSets(List<Account> accountList,Set<String> industrySet, Set<String> subIndustrySet, Set<String> subDivisionSet,Set<String> strategicPodSet) {
        for (Account accountItem : accountList) {
            //subIndustrySet.add(accountItem.Industry_Subtype__c);
//            if(accountItem.Industry_Subtype__c == null || String.isEmpty(accountItem.Industry_Subtype__c)){
//                subIndustrySet.add('Empty');
//            } else {
//                subIndustrySet.add(accountItem.Industry_Subtype__c);
//            }
            if(String.isNotBlank(accountItem.Sub_Division__c)){
                subDivisionSet.add(accountItem.Sub_Division__c);
            }
            if(String.isNotBlank(accountItem.SW_Industry__c)){
                industrySet.add(accountItem.SW_Industry__c);
            }
            if(String.isNotBlank(accountItem.Strategic_Pod__c)){
                strategicPodSet.add(accountItem.Strategic_Pod__c);
            }
        }
    }

    /**
     * @description if any logs created - publish them
     * */
    public void publishLogs(){
        if (!logEvents.isEmpty()) {
            EventBus.publish(logEvents);
        }
    }

    public void finish(Database.BatchableContext BC) {
        Integer batchSize = GeneralUtil.getGeneralConfig('ChurnAccountsBatch_BatchSize')?.Number_Value__c.intValue();
        if(!Test.isRunningTest()){
            if(!isSingleRun){
                Database.executeBatch(new TerritoryManagementBatch(true), 1);
            }
            else { //isSingleRun mode already run, now proceed.
                Database.executeBatch(new ChurnAccountsBatch(), batchSize != null ? batchSize : 3);
            }
        }
    }
}
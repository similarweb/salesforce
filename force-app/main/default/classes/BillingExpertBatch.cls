/**
 * @author                    Itzik Winograd
 * @date                        24/07/2022
 * @description         MIS-2458. Get the changed records on the Billing_expert_Mapping__c object,
 *                                     and pass the appropriate value to the account.
 */
public without sharing class BillingExpertBatch implements Database.Batchable<sObject>, Database.Stateful {
    private List<Log_Event__e> logEvents = new List<Log_Event__e>();

    private String accountsQuery;
    private FINAL String billingExpertQuery =
        'SELECT Id, Change_in_Mapping__c, Owner_Division__c, Billing_expert__c ' +
        'FROM Billing_expert_Mapping__c ' +
        'WHERE Change_in_Mapping__c = TRUE';

    private Map<Id, Billing_expert_Mapping__c> billingExpertsMap = new Map<Id, Billing_expert_Mapping__c>();
    private Map<String, Billing_expert_Mapping__c> ownerDivisionToBillingExpert;
    private Set<Id> failedBillingExpertMappingsSet = new Set<Id>();
    /**
     * @author Itzik Winograd
     * @description constructor.
     *              Query for changed Billing_expert_Mapping__c and if found - defines an Account query for the Execute method.
     */
    public BillingExpertBatch() {
        ownerDivisionToBillingExpert = new Map<String, Billing_expert_Mapping__c>();
        billingExpertsMap = new Map<Id, Billing_expert_Mapping__c>((List<Billing_expert_Mapping__c>) Database.query(billingExpertQuery));
        if (!billingExpertsMap.isEmpty()) {
            generateChangedOwnerDivisionMap(billingExpertsMap.values());
        }
    }

    /**
     * @author Itzik Winograd
     * @description Loop over a list of Billing_expert_Mapping__c and get the appropriate Owner_Division__c
     */
    public void generateChangedOwnerDivisionMap(List<Billing_expert_Mapping__c> billingExpertList) {
        for (Billing_expert_Mapping__c bem : billingExpertList) {
            if(!ownerDivisionToBillingExpert.containsKey(bem.Owner_Division__c)){
                ownerDivisionToBillingExpert.put(bem.Owner_Division__c, bem);
            }
        }
        System.debug('### BillingExpertBatch ownerDivisionToBillingExpert: ' + ownerDivisionToBillingExpert);
    }

    /**
     * @author Itzik Winograd
     * @description Batch start. query for the Account records to update the billingExpert in
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        Set<String> ownerDivisionSet = ownerDivisionToBillingExpert.keySet();
        accountsQuery =
            'SELECT Id, Billing_Expert__c, Owner_Division__c ' +
            'FROM Account ' +
            'WHERE Owner_Division__c IN :ownerDivisionSet';
        System.debug(
            '### BillingExpertBatch query: ' + Database.getQueryLocator(accountsQuery)
        );
        return Database.getQueryLocator(accountsQuery);
    }

    /**
     * @author Itzik Winograd
     * @description Batch execute. Update the Billing Expert on the account according to it's owner division.
     */
    public void execute(Database.BatchableContext BC, List<Account> scopeAccounts) {
        Map<Id, Id> accountIdToBillingExpertIdMap = new Map<Id, Id>();
        List<Account> accountsToUpdateList = new List<Account>();
        for (Account acc : scopeAccounts) {
            if(ownerDivisionToBillingExpert.containsKey(acc.Owner_Division__c)){
                Id accountBillingExpert = ownerDivisionToBillingExpert.get(acc.Owner_Division__c).Billing_Expert__c;
                if(acc.Billing_expert__c != accountBillingExpert){
                    acc.Billing_expert__c = accountBillingExpert;
                    acc.Billing_Expert_Changed__c = true;
                    accountIdToBillingExpertIdMap.put(acc.Id, ownerDivisionToBillingExpert.get(acc.Owner_Division__c).Id);
                    accountsToUpdateList.add(acc);
                }
            }
        }
        if(!accountsToUpdateList.isEmpty()){
            List<Database.SaveResult> resultsList = Database.update(scopeAccounts, false);
            for (Integer i = 0; i < resultsList.size(); i++) {
                Database.SaveResult result = resultsList[i];
                if (!result.isSuccess()) {
                    logEvents.add(LogEventUtils.createLogEventRecord(
                            new List<String>{ scopeAccounts[i].Id }, 'BillingExpertBatch', 'execute', JSON.serialize(resultsList[i]),
                            'Can\'t update the billing expert on the account. Error:' + result.getErrors().toString(), 'Error'));
                    failedBillingExpertMappingsSet.add(accountIdToBillingExpertIdMap.get(scopeAccounts[i].Id));
                }
            }
        }

    }

    /**
     * @author Itzik Winograd
     * @description Batch finish method. Uncheck the mapping records that are not in the failedBillingExpertMappingsSet.
     */
    public void finish(Database.BatchableContext BC) {
        List<Billing_expert_Mapping__c> billIngExpertToUncheck = new List<Billing_expert_Mapping__c>();
        for (Id bemId : billingExpertsMap.keySet()) {
            if (!failedBillingExpertMappingsSet.contains(bemId)) {
                billIngExpertToUncheck.add(createUncheckedBillingExpertChanged(bemId));
            }
        }
        uncheckBillingExpertChanged(billIngExpertToUncheck);

        //Integer BATCH_LIMIT = Integer.valueOf(GeneralUtil.getGeneralConfig('BillingExpertBatchSize').Number_Value__c);
        //Database.executeBatch(new YayPaySetARSpecialistBatch(), BATCH_LIMIT); // commented out until Billing wants it on.

        if (!logEvents.isEmpty()) {
            EventBus.publish(logEvents);
        }
    }

    /**
     * @author Itzik Winograd
     * @description DML Update the unchecked Billing_expert_Mapping__c records
     * @param List<Billing_expert_Mapping__c> billIngExpertToUncheck
     */
    public void uncheckBillingExpertChanged(List<Billing_expert_Mapping__c> billIngExpertToUncheck) {
        List<Database.SaveResult> resultsList = Database.update(billIngExpertToUncheck, false);
        for (Integer i = 0; i < resultsList.size(); i++) {
            Database.SaveResult result = resultsList[i];
            if (!result.isSuccess()) {
                logEvents.add(
                    LogEventUtils.createLogEventRecord(
                        new List<String>{ billIngExpertToUncheck[i].Id }, 'BillingExpertBatch', 'uncheckBillingExpertChanged',
                            JSON.serialize(billIngExpertToUncheck[i]), 'Can\'t uncheck this billing expert record. Error:' + result.getErrors().toString(), 'Error'));
            }
        }
    }

    /**
     * @author Itzik Winograd
     * @description return billing expert record with Change_in_Mapping__c = false
     * @param Id billingExpertId
     */
    public Billing_expert_Mapping__c createUncheckedBillingExpertChanged(Id billingExpertId) {
        return new Billing_expert_Mapping__c(
            Id = billingExpertId,
            Change_in_Mapping__c = false
        );
    }
}
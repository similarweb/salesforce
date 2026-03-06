/**
 * Created by Alon.Shalev on 6/6/2023.
 */

public with sharing class MultisSubQuoteProcess { // run ZQuoteDomainTest.multiSubProcessTest 
    private List<zqu__Quote__c> newList;

    public MultisSubQuoteProcess(List<zqu__Quote__c> newList){
       this.newList = newList;
    }

    public void handleMultiSub(){ // MQ-1722 + MQ-1764
        Map<Id,List<zqu__Quote__c>> accountIdToQuoteListMap = new Map<Id, List<zqu__Quote__c>>();
//        Map<Id,List<zqu__Quote__c>> accountIdToQuoteListMapForParent = new Map<Id, List<zqu__Quote__c>>();
        for(zqu__Quote__c newQuote : this.newList){
            if(newQuote.MultiSubscription__c){
                if(newQuote.zqu__Account__c != null && newQuote.zqu__QuoteBusinessType__c == 'New'){
                    if(!accountIdToQuoteListMap.containsKey(newQuote.zqu__Account__c)){
                        accountIdToQuoteListMap.put(newQuote.zqu__Account__c , new List<zqu__Quote__c>());
                    }
                    accountIdToQuoteListMap.get(newQuote.zqu__Account__c).add(newQuote);
                }
            }
//            if(!accountIdToQuoteListMapForParent.containsKey(newQuote.zqu__Account__c)){
//                accountIdToQuoteListMapForParent.put(newQuote.zqu__Account__c , new List<zqu__Quote__c>());
//            }
//            accountIdToQuoteListMapForParent.get(newQuote.zqu__Account__c).add(newQuote);
        }
        System.debug('accountIdToQuoteListMap--'+accountIdToQuoteListMap.size());
        if(!accountIdToQuoteListMap.isEmpty()){
            populateNewTermedStartDateAndParentAccount(accountIdToQuoteListMap);
        }

//        if(!accountIdToQuoteListMapForParent.isEmpty()){
//            handleParentLookups(accountIdToQuoteListMapForParent);
//        }

    }

    private void populateNewTermedStartDateAndParentAccount(Map<Id, List<zqu__Quote__c>> accountIdToQuoteListMap){
        String activeStr = 'Active';
        String termedStr = 'Termed';
        Date todayDate = Date.today();
        List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Id,Zuora__Account__c,name,Zuora_Parent_Account__c,Zuora__External_Id__c,
        (SELECT Id,Zuora__TermStartDate__c,Zuora__InitialTerm__c FROM Zuora__Subscriptions__r
        WHERE Zuora__Status__c = :activeStr
        AND Zuora__SubscriptionEndDate__c > :todayDate
        AND Zuora__TermSettingType__c = :termedStr )
        FROM Zuora__CustomerAccount__c
        WHERE Zuora__Account__c IN:accountIdToQuoteListMap.keySet()];

        handleStartDateAndParentLookup(billingAccounts, accountIdToQuoteListMap);

    }

    private void handleStartDateAndParentLookup(List<Zuora__CustomerAccount__c> billingAccounts, Map<Id, List<zqu__Quote__c>> accountIdToQuoteListMap) {
        Map<Id, Zuora__CustomerAccount__c> accountIdToBillingAccountMap = new Map<Id, Zuora__CustomerAccount__c>();
        Map<Id, Zuora__Subscription__c> accountIdToOriginalSubScriptionMap = new Map<Id, Zuora__Subscription__c>();
        populateAccountIdToBillingAccountMap(billingAccounts, accountIdToBillingAccountMap, accountIdToOriginalSubScriptionMap);

        List<Zuora__CustomerAccount__c> billingAccountToUpdateList = new List<Zuora__CustomerAccount__c>();

        fillQuoteFields(accountIdToQuoteListMap, accountIdToBillingAccountMap, billingAccountToUpdateList, accountIdToOriginalSubScriptionMap);
        if(!billingAccountToUpdateList.isEmpty()){
            update billingAccountToUpdateList;
        }
    }

    private void fillQuoteFields(Map<Id, List<zqu__Quote__c>> accountIdToQuoteListMap, Map<Id, Zuora__CustomerAccount__c> accountIdToBillingAccountMap, List<Zuora__CustomerAccount__c> billingAccountToUpdateList, Map<Id, Zuora__Subscription__c> accountIdToOriginalSubScriptionMap) {
        for (Id sfAccountId : accountIdToQuoteListMap.keySet()) { // if something is not empty it populates the quote with the fields.
            if (accountIdToBillingAccountMap.containsKey(sfAccountId)) {
                Zuora__CustomerAccount__c billingAccount = accountIdToBillingAccountMap.get(sfAccountId);
                if (String.isBlank(billingAccount.Zuora_Parent_Account__c) || billingAccount.Zuora_Parent_Account__c == 'No') {
                    billingAccount.Zuora_Parent_Account__c = 'Yes';
                    billingAccountToUpdateList.add(billingAccount);
                }
                for (zqu__Quote__c newQuote : accountIdToQuoteListMap.get(sfAccountId)) {
                    newQuote.zqu__ZuoraParentBillingAccountId__c = billingAccount.Zuora__External_Id__c;
                    newQuote.zqu__ZuoraParentBillingAccountName__c = billingAccount.name;
                }
            }
            if (accountIdToOriginalSubScriptionMap.containsKey(sfAccountId)) {
                for (zqu__Quote__c newQuote : accountIdToQuoteListMap.get(sfAccountId)) {
                    newQuote.zqu__TermStartDate__c = accountIdToOriginalSubScriptionMap.get(sfAccountId).Zuora__TermStartDate__c;
                    newQuote.Original_Subscription__c = accountIdToOriginalSubScriptionMap.get(sfAccountId).Id;
                    String initialTermSub = accountIdToOriginalSubScriptionMap.get(sfAccountId).Zuora__InitialTerm__c;
                    if (initialTermSub != null) {
                        List<String> initialTermSubList = initialTermSub.split(' ');
                        if (!initialTermSubList.isEmpty()) {
                            newQuote.zqu__InitialTerm__c = Decimal.valueOf(initialTermSubList[0]);
                        }
                    }
                }
            }
        }
    }

    private void populateAccountIdToBillingAccountMap(List<Zuora__CustomerAccount__c> billingAccounts, Map<Id, Zuora__CustomerAccount__c> accountIdToBillingAccountMap, Map<Id, Zuora__Subscription__c> accountIdToOriginalSubScriptionMap) {
        for (Zuora__CustomerAccount__c billingAccount : billingAccounts) {// this loop itterates over all billingAccounts and decides if there are active subscription or the billing account has the parent picklist marked
            if (String.isNotBlank(billingAccount.Zuora_Parent_Account__c) && billingAccount.Zuora_Parent_Account__c == 'Yes') {
                accountIdToBillingAccountMap.put(billingAccount.Zuora__Account__c, billingAccount);
            }
            if (!billingAccount.Zuora__Subscriptions__r.isEmpty()) {
                accountIdToOriginalSubScriptionMap.put(billingAccount.Zuora__Account__c, billingAccount.Zuora__Subscriptions__r[0]);//MQ-1722 this is what need to be removed. for kori
                if (!accountIdToBillingAccountMap.containsKey(billingAccount.Zuora__Account__c)) {
                    accountIdToBillingAccountMap.put(billingAccount.Zuora__Account__c, billingAccount);
                }
            }

        }
    }

}
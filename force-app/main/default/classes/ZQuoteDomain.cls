/**
 * 
 * @author 
 * @since 
 * 
 * MQ-1419 - Added isCalculationEnabled class attribute.
 */
public with sharing class ZQuoteDomain extends GenericDomain {

    /**
     * Flag for enable/disable Quote trigger logic
     */
    public static Boolean isCalculationEnabled = true;
    
    public ZQuoteDomain(List<SObject> newRecords){
        super(newRecords);
    }

    public override void onBeforeInsert() {
        onBeforeInsertLogic();
    }

    public override void onAfterInsert() {
        onAfterInsertLogic();
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        onBeforeUpdateLogic(existingRecords);
        createRenewalConfirmationTimestampPdf(existingRecords);
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {
        onAfterUpdateLogic(existingRecords);
        checkIfFeldsIsChanged(existingRecords); // when i remove this the refresh doesnt work
//        sendNotificationForScreenLayoutRefresh((Map<Id,zqu__Quote__c>)existingRecords);
    }




    private void onBeforeInsertLogic(){
        System.debug('hadar kedem is checking!! before insert');
        //handleInitialTimes(newRecords);// MQ-1651 alon shalev - ZOHAR -- alon was here!!
        MultisSubQuoteProcess multiSubQuoteProcess = new MultisSubQuoteProcess((List<zqu__Quote__c>)newRecords);
        multiSubQuoteProcess.handleMultiSub();
//        handleMultiSub(); // MQ-1722 + MQ-1764
        fixPeriodTimeIssue(); // ZOHAR alon was here!!

        ZuoraQuoteFlowHelper.calculateQuoteStatus(newRecords);
        ZuoraQuoteFieldCalculationHelper.calculateValidUntil(newRecords);
        List<zqu__Quote__c> quoteFinalizeList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> amendQuoteList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> newSubAndAmendQuoteList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> contractPaymentTermQuoteList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> amendRenewalQuoteList = new List<zqu__Quote__c>();
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            if ((quote_i.zqu_Quote_Status__c=='Terms Approved' || quote_i.zqu_Quote_Status__c=='Trial Approved')
                && Utility.getRecordTypeIdForObject(quote_i.getSObjectType(), 'Amendment') != quote_i.RecordTypeId )
            {
                quoteFinalizeList.add(quote_i);
            }
            if ( Utility.getRecordTypeIdForObject(quote_i.getSObjectType(), 'Amendment') == quote_i.RecordTypeId )
            {
                amendQuoteList.add(quote_i);
            }
            if (quote_i.zqu__SubscriptionType__c == 'New Subscription' || quote_i.zqu__SubscriptionType__c == 'Amend Subscription')
            {
                newSubAndAmendQuoteList.add(quote_i);
            }
            if (quote_i.zqu__SubscriptionType__c == 'Cancel Subscription')
            {
                Date cancelaltionDate = quote_i.zqu__CancellationDate__c;
                if (cancelaltionDate!= null) {        
                    quote_i.zqu__StartDate__c = cancelaltionDate;
                    quote_i.zqu__ValidUntil__c = cancelaltionDate;
                    quote_i.zqu__Service_Activation_Date__c = cancelaltionDate;
                    quote_i.zqu__Customer_Acceptance_Date__c = cancelaltionDate;    
                }
            }
            if(true){
                contractPaymentTermQuoteList.add(quote_i);
            }
            if(String.isNotBlank(quote_i.zqu__ZuoraAccountID__c)){
                quote_i.Is_from_existing_Billing_Account__c = true;
            }
            if(quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'){
                amendRenewalQuoteList.add(quote_i);
            }
            if(quote_i.zqu__PaymentMethod__c != 'Other' && quote_i.zqu__SubscriptionType__c == 'New Subscription' && !quote_i.Is_from_existing_Billing_Account__c){
                quote_i.Payment_Type__c = '';
            }
            if(quote_i.payment_frequency1__c != 'Other') {
                quote_i.Special_Frequency_Reason__c = '';
            }
            if(quote_i.zqu__PaymentTerm__c != 'Other (Non Standard)') {
                quote_i.Special_Payment_Terms_Details__c = '';
            }
        }
        ZuoraQuoteDateCalculationHelper.calculateDates((List<zqu__Quote__c>)newRecords);
        if (!quoteFinalizeList.isEmpty()) {
            ZuoraQuoteFinalizeHelper.finalizeQuote(quoteFinalizeList);
        }
        if (!newSubAndAmendQuoteList.isEmpty()) {
            ZuoraQuoteFieldCalculationHelper.calculateSubsidiaryForAmendQuote(newSubAndAmendQuoteList);
        }
        if (!amendQuoteList.isEmpty()) {
            ZuoraQuoteFieldCalculationHelper.calculateLastSignatureDateForAmendQuote(amendQuoteList);
        }
        System.debug('hadar kedem!!!!---'+contractPaymentTermQuoteList);
        if (!contractPaymentTermQuoteList.isEmpty()) {
            ZuoraQuoteFieldCalculationHelper.calculateContractPaymentTerm(contractPaymentTermQuoteList);
            ZuoraQuoteFieldCalculationHelper.calculateContractAmendmentsPaymentTerm(contractPaymentTermQuoteList);
            ZuoraQuoteFieldCalculationHelper.calculateNewSaleProducts(contractPaymentTermQuoteList);
        }
        ZuoraQuoteMetricsManipulationHelper.calculateQuoteMetrics(newRecords);
    }

    private void fixPeriodTimeIssue(){
        for(zqu__Quote__c quoteItem : (List<zqu__Quote__c>)newRecords){
            if(!quoteItem.Trial_Quote__c || (String.isNotBlank(quoteItem.Trial_Length__c) && quoteItem.Trial_Length__c.contains('Month'))){
                quoteItem.zqu__InitialTermPeriodType__c = 'Month';
                quoteItem.zqu__RenewalTermPeriodType__c = 'Month';
            }
        }

    }

//    private void handleMultiSub(){ // MQ-1722 + MQ-1764
//        Map<Id,List<zqu__Quote__c>> accountIdToQuoteListMap = new Map<Id, List<zqu__Quote__c>>();
////        Map<Id,List<zqu__Quote__c>> accountIdToQuoteListMapForParent = new Map<Id, List<zqu__Quote__c>>();
//        for(zqu__Quote__c newQuote : (List<zqu__Quote__c>)this.newRecords){
//            if(newQuote.MultiSubscription__c){
//                if(newQuote.zqu__Account__c != null && newQuote.zqu__QuoteBusinessType__c == 'New'){
//                    if(!accountIdToQuoteListMap.containsKey(newQuote.zqu__Account__c)){
//                        accountIdToQuoteListMap.put(newQuote.zqu__Account__c , new List<zqu__Quote__c>());
//                    }
//                    accountIdToQuoteListMap.get(newQuote.zqu__Account__c).add(newQuote);
//                }
//            }
////            if(!accountIdToQuoteListMapForParent.containsKey(newQuote.zqu__Account__c)){
////                accountIdToQuoteListMapForParent.put(newQuote.zqu__Account__c , new List<zqu__Quote__c>());
////            }
////            accountIdToQuoteListMapForParent.get(newQuote.zqu__Account__c).add(newQuote);
//        }
//        System.debug('accountIdToQuoteListMap--'+accountIdToQuoteListMap.size());
//        if(!accountIdToQuoteListMap.isEmpty()){
//            populateNewTermedStartDateAndParentAccount(accountIdToQuoteListMap);
//        }
//
////        if(!accountIdToQuoteListMapForParent.isEmpty()){
////            handleParentLookups(accountIdToQuoteListMapForParent);
////        }
//
//    }

//    private void populateNewTermedStartDateAndParentAccount(Map<Id, List<zqu__Quote__c>> accountIdToQuoteListMap){
//        String activeStr = 'Active';
//        String termedStr = 'Termed';
//        Date todayDate = Date.today();
//        List<Zuora__CustomerAccount__c> billingAccounts = [SELECT Id,Zuora__Account__c,name,Zuora_Parent_Account__c,Zuora__External_Id__c,
//                                                            (SELECT Id,Zuora__TermStartDate__c,Zuora__InitialTerm__c FROM Zuora__Subscriptions__r
//                                                            WHERE Zuora__Status__c = :activeStr
//                                                            AND Zuora__SubscriptionEndDate__c > :todayDate
//                                                            AND Zuora__TermSettingType__c = :termedStr )
//                                                        FROM Zuora__CustomerAccount__c
//                                                         WHERE Zuora__Account__c IN:accountIdToQuoteListMap.keySet()];
//
//        handleStartDateAndParentLookup(billingAccounts, accountIdToQuoteListMap);
//
//    }

//    private void handleStartDateAndParentLookup(List<Zuora__CustomerAccount__c> billingAccounts, Map<Id, List<zqu__Quote__c>> accountIdToQuoteListMap) {
//        Map<Id, Zuora__CustomerAccount__c> accountIdToBillingAccountMap = new Map<Id, Zuora__CustomerAccount__c>();
//        Map<Id, Zuora__Subscription__c> accountIdToOriginalSubScriptionMap = new Map<Id, Zuora__Subscription__c>();
//        populateAccountIdToBillingAccountMap(billingAccounts, accountIdToBillingAccountMap, accountIdToOriginalSubScriptionMap);
//
//        List<Zuora__CustomerAccount__c> billingAccountToUpdateList = new List<Zuora__CustomerAccount__c>();
//
//        fillQuoteFields(accountIdToQuoteListMap, accountIdToBillingAccountMap, billingAccountToUpdateList, accountIdToOriginalSubScriptionMap);
//        if(!billingAccountToUpdateList.isEmpty()){
//            update billingAccountToUpdateList;
//        }
//    }

//    private void fillQuoteFields(Map<Id, List<zqu__Quote__c>> accountIdToQuoteListMap, Map<Id, Zuora__CustomerAccount__c> accountIdToBillingAccountMap, List<Zuora__CustomerAccount__c> billingAccountToUpdateList, Map<Id, Zuora__Subscription__c> accountIdToOriginalSubScriptionMap) {
//        for (Id sfAccountId : accountIdToQuoteListMap.keySet()) { // if something is not empty it populates the quote with the fields.
//            if (accountIdToBillingAccountMap.containsKey(sfAccountId)) {
//                Zuora__CustomerAccount__c billingAccount = accountIdToBillingAccountMap.get(sfAccountId);
//                if (String.isBlank(billingAccount.Zuora_Parent_Account__c) || billingAccount.Zuora_Parent_Account__c == 'No') {
//                    billingAccount.Zuora_Parent_Account__c = 'Yes';
//                    billingAccountToUpdateList.add(billingAccount);
//                }
//                for (zqu__Quote__c newQuote : accountIdToQuoteListMap.get(sfAccountId)) {
//                    newQuote.zqu__ZuoraParentBillingAccountId__c = billingAccount.Zuora__External_Id__c;
//                    newQuote.zqu__ZuoraParentBillingAccountName__c = billingAccount.name;
//                }
//            }
//            if (accountIdToOriginalSubScriptionMap.containsKey(sfAccountId)) {
//                for (zqu__Quote__c newQuote : accountIdToQuoteListMap.get(sfAccountId)) {
//                    newQuote.zqu__TermStartDate__c = accountIdToOriginalSubScriptionMap.get(sfAccountId).Zuora__TermStartDate__c;
//                    newQuote.Original_Subscription__c = accountIdToOriginalSubScriptionMap.get(sfAccountId).Id;
//                    String initialTermSub = accountIdToOriginalSubScriptionMap.get(sfAccountId).Zuora__InitialTerm__c;
//                    if (initialTermSub != null) {
//                        List<String> initialTermSubList = initialTermSub.split(' ');
//                        if (!initialTermSubList.isEmpty()) {
//                            newQuote.zqu__InitialTerm__c = Decimal.valueOf(initialTermSubList[0]);
//                        }
//                    }
//                }
//            }
//        }
//    }

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

//    private boolean checkIfConditionForLookUpMet(Zuora__CustomerAccount__c billingAccount){
//        boolean result = String.isNotBlank(billingAccount.Zuora_Parent_Account__c)  || !billingAccount.Zuora__Subscriptions__r.isEmpty(); // if the billing account has a parent account marked or it has at least 1 subscription that active and termed.
//        return result;
//    }

//    private void populateNewTermedStartDateAndParentAccount(Map<Id, List<zqu__Quote__c>> accountIdToQuoteListMap) {//MQ-1722
//        Date todayDate = Date.today();
//        String activeStr = 'Active';
//        String termedStr = 'Termed';
//        List<Zuora__Subscription__c> subscriptions = [
//                SELECT Id, Zuora__Account__c, Zuora__SubscriptionStartDate__c
//                FROM Zuora__Subscription__c
//                WHERE Zuora__Account__c IN :accountIdToQuoteListMap.keySet()
//                AND Zuora__Status__c = :activeStr
//                AND Zuora__SubscriptionEndDate__c > :todayDate
//                AND Zuora__TermSettingType__c = :termedStr
//        ];
//        System.debug('subscriptions--'+subscriptions);
//        Map<Id, Date> accountIdToStartDateMap = new Map<Id, Date>();
//        for (Zuora__Subscription__c subscription : subscriptions) {
//            accountIdToStartDateMap.put(subscription.Zuora__Account__c, subscription.Zuora__SubscriptionStartDate__c);
//        }
//        System.debug('accountIdToQuoteListMap--'+accountIdToQuoteListMap.size());
//        for (Id accountId : accountIdToQuoteListMap.keySet()) {
//            Date newStartDate = accountIdToStartDateMap.get(accountId);
//            if(accountIdToQuoteListMap.containsKey(accountId)){
//                for (zqu__Quote__c accountQuote : accountIdToQuoteListMap.get(accountId)) {
//                    accountQuote.zqu__TermStartDate__c = newStartDate;
//                }
//            }
//        }
//    }

//    private void handleInitialTimesOnUpdate(Map<Id,zqu__Quote__c> existingRecords){ // ZOHAR alon was here!!
//        List<zqu__Quote__c> toUpdateList = new List<zqu__Quote__c>();
//        for (zqu__Quote__c newQuote : (List<zqu__Quote__c>)newRecords) {
//            zqu__Quote__c oldQuote = existingRecords.get(newQuote.Id);
//            if(newQuote.zqu__StartDate__c != null && newQuote.zqu__StartDate__c != oldQuote.zqu__StartDate__c){
//                toUpdateList.add(newQuote);
//            }
//        }
//
//        if(!toUpdateList.isEmpty()){
//            handleInitialTimes(toUpdateList);
//        }
//    }

//    private void handleInitialTimes(List<zqu__Quote__c> newRecords){///MQ-1651 ZOHAR alon was here!!
//        system.debug('alon started.');
//        system.debug(' ido check---'+newRecords[0].zqu__InitialTerm__c);
//        //todo: i think we should always populate zqu__RenewalTermPeriodType__c with the value on zqu__InitialTermPeriodType__c;
//        Map<String,zqu__Quote__c> billingAccountIdToQuoteToUpdateMap = new Map<String, zqu__Quote__c>();
//        for (zqu__Quote__c newQuote : newRecords) {
//            newQuote.zqu__InitialTermPeriodType__c = 'Month';
//            newQuote.zqu__RenewalTermPeriodType__c = 'Month';
//            system.debug('zqu__ZuoraAccountID__c---'+newQuote.zqu__ZuoraAccountID__c);
//            system.debug('newQuote.MultiSubscription__C---'+newQuote.MultiSubscription__c);
//            if (newQuote.zqu__ZuoraAccountID__c != null && newQuote.zqu__QuoteBusinessType__c == 'New' && newQuote.MultiSubscription__c) {
//                billingAccountIdToQuoteToUpdateMap.put(newQuote.zqu__ZuoraAccountID__c,newQuote);
//            }
//        }
//        if(!billingAccountIdToQuoteToUpdateMap.isEmpty()) {
//            updateQuoteInitialFields(billingAccountIdToQuoteToUpdateMap);
//        }
//    }

//    private void updateQuoteInitialFields(Map<String, zqu__Quote__c> billingAccountIdToQuoteToUpdateMap) { ZOHAR alon was here!!
//        String activeStr = 'Active';
//        String termedStr = 'TERMED';
//        Map<String,Zuora__CustomerAccount__c> externalIdToBillingAccountMap = new Map<String, Zuora__CustomerAccount__c>();
//        List<Zuora__CustomerAccount__c> billinigAccountWithSubscriptionList = [
//                                                SELECT Id,Zuora__External_Id__c, (
//                                                        SELECT Id, Zuora__SubscriptionEndDate__c, Zuora__RenewalTerm__c, Zuora__RenewalTermPeriodType__c,Zuora__TermSettingType__c
//                                                        FROM Zuora__Subscriptions__r
//                                                        WHERE Zuora__Status__c = :activeStr
//                                                        AND Zuora__TermSettingType__c =:termedStr
//                                                        LIMIT 1
//                                                )
//                                                FROM Zuora__CustomerAccount__c
//                                                WHERE Zuora__External_Id__c IN :billingAccountIdToQuoteToUpdateMap.keySet()
//                                                ];
//        for(Zuora__CustomerAccount__c billingAccount : billinigAccountWithSubscriptionList){
//            externalIdToBillingAccountMap.put(billingAccount.Zuora__External_Id__c,billingAccount);
//        }
//        for (zqu__Quote__c quoteToUpdate : billingAccountIdToQuoteToUpdateMap.values()) {
//            Zuora__CustomerAccount__c billingAccountWithSubscription = externalIdToBillingAccountMap.get(quoteToUpdate.zqu__ZuoraAccountID__c);
//            for (Zuora__Subscription__c subscription : billingAccountWithSubscription.Zuora__Subscriptions__r) {
//                quoteToUpdate.zqu__InitialTermPeriodType__c = 'Day';
//                quoteToUpdate.zqu__RenewalTermPeriodType__c = subscription.Zuora__RenewalTermPeriodType__c;
//                quoteToUpdate.zqu__RenewalTerm__c =  subscription.Zuora__RenewalTerm__c != null ? Decimal.valueOf(subscription.Zuora__RenewalTerm__c.substringBefore(' ')) : null;
//                quoteToUpdate.zqu__InitialTerm__c = quoteToUpdate.zqu__StartDate__c != null ? quoteToUpdate.zqu__StartDate__c.daysBetween(subscription.Zuora__SubscriptionEndDate__c) : Date.today().daysBetween(subscription.Zuora__SubscriptionEndDate__c) ;
//                quoteToUpdate.zqu__SubscriptionTermEndDate__c = subscription.Zuora__SubscriptionEndDate__c;
//            }
//        }
//    }

    private void onAfterInsertLogic() {
        updateRelAccount((List<zqu__Quote__c>)newRecords);
        Set<Id> validQuoteIds = new Set<Id>();
        List<zqu__Quote__c> newSubQuotes = new List<zqu__Quote__c>();
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            if (Utility.getRecordTypeIdForObject(quote_i.getSObjectType(), 'Cancellation') != quote_i.RecordTypeId) 
            {
                validQuoteIds.add(quote_i.Id);
            }
            if ('New Subscription'.equalsIgnoreCase(quote_i.zqu__SubscriptionType__c)) 
            {
                newSubQuotes.add(quote_i);
            }
        }
        List<zqu__QuoteRatePlanCharge__c> qrpcToUpdate = ZuoraQuoteMetricsManipulationHelper.calculateSpecificBillingPeriod(newSubQuotes,validQuoteIds);
        update qrpcToUpdate;
        ZuoraQuoteMetricsManipulationHelper.updateChargesIfMetricsChanged(newRecords);
    }

    private void onBeforeUpdateLogic(Map<Id,SObject> existingRecords){
        System.debug('onBeforeUpdateLogic--');
        //handleInitialTimesOnUpdate((Map<Id,zqu__Quote__c>)existingRecords); ZOHAR -- alon was here!!
        Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance('Rounding_Resolve_V1');
        Boolean featureFlag = roundingFF.Is_Active__c;
        if(featureFlag){
            handleCalculateZuoraPricing((Map<Id,zqu__Quote__c>) existingRecords);
        }
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> contractPaymentTermQuoteList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> contractWordingDIDescriptionQuoteList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> contractWordingAmendDIDescriptionQuoteList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> previewQuoteList = new List<zqu__Quote__c>();
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            zqu__Quote__c oldQuote_i = (zqu__Quote__c)existingRecords.get(quote_i.Id);
            if((oldQuote_i.Activate_CARR__c != quote_i.Activate_CARR__c && quote_i.Activate_CARR__c) && !system.isQueueable() && !system.isBatch() && !system.isFuture()){
                System.debug('HERE!!');
                if(!featureFlag){
                    ZuoraPriceCalculation.updateQuoteSums((List<zqu__Quote__c>)newRecords, false);
                }
                if (quote_i.zqu__QuoteBusinessType__c == 'New') {
                    System.enqueueJob(new ZuoraCARRCalculationQueueable(quote_i, 'AddDiscount'));
                } else if (quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Co-Term Upsell')) {
                    System.enqueueJob(new ZuoraCARRCalculationQueueable(quote_i, 'CTU'));
                } else if (quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                    System.enqueueJob(new ZuoraCARRCalculationQueueable(quote_i, 'FU'));
                } else if (quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Renewal')) {
                    System.debug('HERE!');
                    System.enqueueJob(new ZuoraCARRCalculationQueueable(quote_i, 'Renewal'));
                }
            }
            System.debug('quote_i ' + quote_i);
            System.debug('quote_i.Recalculate_Charge__c ' + quote_i.Recalculate_Charge__c);
            System.debug('quote_i.zqu__Previewed_SubTotal__c ' + quote_i.zqu__Previewed_SubTotal__c);
            System.debug('quote_i.oldQuote_i.zqu__Previewed_SubTotal__c ' + oldQuote_i.zqu__Previewed_SubTotal__c);
            System.debug('zqu__Previewed_Delta_MRR__c in trigge r' + quote_i.zqu__Previewed_Delta_MRR__c);
            System.debug('zqu__Previewed_Delta_MRR__c    old ' + oldQuote_i.zqu__Previewed_Delta_MRR__c);
            System.debug('Is_Discount_Given__c    old ' + oldQuote_i.Is_Discount_Given__c);
            System.debug('Is_Discount_Given__c    new ' + quote_i.Is_Discount_Given__c);
            Boolean isDiscountProcessEnded = !quote_i.zqu__Is_Charge_Expired__c && quote_i.zqu__Is_Charge_Expired__c != oldQuote_i.zqu__Is_Charge_Expired__c && quote_i.Discount_Status__c == 'Discount Given';
            //|| quote_i.zqu__QuoteBusinessType__c == 'Feature Update' if we want to add the feature update to always turn on the buttons comp
            if(isDiscountProcessEnded && featureFlag){
                System.debug('only preview was changed');
                System.debug('quote_i.zqu__Previewed_Delta_MRR__c--'+quote_i.zqu__Previewed_Delta_MRR__c);
//                if(quote_i.zqu__QuoteBusinessType__c == 'Feature Update' && quote_i.zqu__Previewed_Delta_MRR__c != 0 && quote_i.FU_Discount_Given__c){
//                    System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i,'Fu_Fix'));
//                    quote_i.FU_Discount_Given__c = false;
                quote_i.Is_Quote_Ready__c = true;
                quote_i.Discount_Status__c = 'Discount Process Ended';
                System.debug(' zohar and alon updated preview');
            }

            if (oldQuote_i.zqu__InitialTerm__c != quote_i.zqu__InitialTerm__c || oldQuote_i.Amendment_Initial_Term__c != quote_i.Amendment_Initial_Term__c) {
                quoteList.add(quote_i);
                contractPaymentTermQuoteList.add(quote_i);
            }
            if (
                oldQuote_i.payment_frequency1__c != quote_i.payment_frequency1__c || 
                oldQuote_i.Payment_Type__c != quote_i.Payment_Type__c ||
                oldQuote_i.zqu__PaymentTerm__c != quote_i.zqu__PaymentTerm__c ||
                oldQuote_i.zqu__StartDate__c != quote_i.zqu__StartDate__c ||
                oldQuote_i.Target_Quote_Total_Price__c != quote_i.Target_Quote_Total_Price__c ||
                oldQuote_i.Renewal_fee__c != quote_i.Renewal_fee__c || 
                oldQuote_i.JP_Parent_Name__c != quote_i.JP_Parent_Name__c ||
                oldQuote_i.Recurring_Target_Price__c != quote_i.Recurring_Target_Price__c ||  // alon change in 1.1.25
                oldQuote_i.Amendment_Renewal_Payment_Term__c != quote_i.Amendment_Renewal_Payment_Term__c  ||  // alon shalev added 18.2.25
                oldQuote_i.Amendment_Renewal_Payment_Frequency__c != quote_i.Amendment_Renewal_Payment_Frequency__c // alon shalev added 1.4.25
                )
            {
                contractPaymentTermQuoteList.add(quote_i);
            }
            
            if (oldQuote_i.Contract_Wording_List__c != quote_i.Contract_Wording_List__c ||
                oldQuote_i.dI_reporting_description__c != quote_i.dI_reporting_description__c) {
                contractWordingDIDescriptionQuoteList.add(quote_i);
            }
            if (oldQuote_i.Contract_Wording_List_Amend__c != quote_i.Contract_Wording_List_Amend__c ||
                oldQuote_i.dI_reporting_description__c != quote_i.dI_reporting_description__c) 
            {
                contractWordingAmendDIDescriptionQuoteList.add(quote_i);
            }
            if (quote_i.zqu__SubscriptionType__c == 'Cancel Subscription')
            {
                Date cancelaltionDate = quote_i.zqu__CancellationDate__c;
                System.debug(cancelaltionDate);
                if (cancelaltionDate!= null) {        
                    quote_i.zqu__StartDate__c = cancelaltionDate;
                    quote_i.zqu__ValidUntil__c = cancelaltionDate;
                    quote_i.zqu__Service_Activation_Date__c = cancelaltionDate;
                    quote_i.zqu__Customer_Acceptance_Date__c = cancelaltionDate;    
                }
            }
            if(
                (quote_i.zqu_Quote_Status__c == 'Rejected By Billing' 
                 || quote_i.zqu_Quote_Status__c == 'Processed Directly in Zuora'
                )
                && quote_i.zqu_Quote_Status__c != oldQuote_i.zqu_Quote_Status__c)
            {
                if(Utility.getRecordTypeIdForObject(quote_i.getSObjectType(), 'ReadOnly') != quote_i.RecordTypeId){
                    quote_i.RecordTypeId = Utility.getRecordTypeIdForObject(quote_i.getSObjectType(), 'ReadOnly');
                }
                if(quote_i.zqu_Quote_Status__c == 'Processed Directly in Zuora'){
                    quote_i.Submitted_to_Zuora_Timestamp__c = Datetime.now();
                }
            }
            if(quote_i.zqu_Quote_Status__c == 'Ready for Billing' && quote_i.Ready_for_Billing_Timestamp__c == null){
                quote_i.Ready_for_Billing_Timestamp__c = Datetime.now();
            }
            if(quote_i.zqu__PaymentMethod__c != 'Other' && quote_i.zqu__SubscriptionType__c == 'New Subscription' && !quote_i.Is_from_existing_Billing_Account__c){
                quote_i.Payment_Type__c = '';
            }
            if(quote_i.payment_frequency1__c != 'Other') {
                quote_i.Special_Frequency_Reason__c = '';
            }
            if(quote_i.zqu__PaymentTerm__c != 'Other (Non Standard)') {
                quote_i.Special_Payment_Terms_Details__c = '';
            }
        }
        if (!quoteList.isEmpty()) {
            if(!featureFlag){
                ZuoraQuoteMetricsManipulationHelper.calculateTotalListPrice(quoteList);
            }
        }
        if (!contractPaymentTermQuoteList.isEmpty()) {
            ZuoraQuoteFieldCalculationHelper.calculateContractPaymentTerm(contractPaymentTermQuoteList);
            ZuoraQuoteFieldCalculationHelper.calculateContractAmendmentsPaymentTerm(contractPaymentTermQuoteList);
        }
        if (!contractWordingDIDescriptionQuoteList.isEmpty()) {
            ZuoraQuoteFieldCalculationHelper.calculateNewSaleProducts(contractWordingDIDescriptionQuoteList);
        }
        if (!contractWordingAmendDIDescriptionQuoteList.isEmpty()) {
        }
        ZuoraQuoteMetricsManipulationHelper.calculateQuoteMetrics(newRecords,existingRecords);
        ZuoraQuoteDateCalculationHelper.calculateDates((List<zqu__Quote__c>)newRecords,existingRecords);

        List<zqu__Quote__c> quoteFinalizeList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> quoteAddonChangeList = new List<zqu__Quote__c>();
        List<zqu__Quote__c> quoteDocFormatChangeList = new List<zqu__Quote__c>();

        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            zqu__Quote__c oldQuote_i = (zqu__Quote__c)existingRecords.get(quote_i.Id);
            
            if (quote_i.zqu_Quote_Status__c != oldQuote_i.zqu_Quote_Status__c 
                && (quote_i.zqu_Quote_Status__c=='Terms Approved' || quote_i.zqu_Quote_Status__c=='Trial Approved')
                && Utility.getRecordTypeIdForObject(quote_i.getSObjectType(), 'Amendment') != quote_i.RecordTypeId )
            {
                quoteFinalizeList.add(quote_i);
            }

            if (quote_i.Contract_Wording_List__c != oldQuote_i.Contract_Wording_List__c 
                ||  quote_i.Dynamic_Base_Product_API_Hits__c != oldQuote_i.Dynamic_Base_Product_API_Hits__c 
                ||  quote_i.Dynamic_Base_Product_Country__c != oldQuote_i.Dynamic_Base_Product_Country__c 
                ||  quote_i.Dynamic_Base_Product_Historical_Data__c != oldQuote_i.Dynamic_Base_Product_Historical_Data__c 
                ||  quote_i.Dynamic_Base_Product_Users__c != oldQuote_i.Dynamic_Base_Product_Users__c 
                ||  quote_i.Dynamic_Base_Users_Stand_Alone__c != oldQuote_i.Dynamic_Base_Users_Stand_Alone__c
                ||  quote_i.Default_Base_Product_Addons__c != oldQuote_i.Default_Base_Product_Addons__c)
            {
                quoteAddonChangeList.add(quote_i);
            }

            if (quote_i.document_format__c != oldQuote_i.document_format__c) {
                quoteDocFormatChangeList.add(quote_i);
            }
            if(
                (quote_i.Contacts_Product__c ||quote_i.Exception_Product__c) && // changed by alon MQ-1620
                quote_i.zqu_Quote_Status__c != oldQuote_i.zqu_Quote_Status__c &&
                ((quote_i.zqu_Quote_Status__c == 'Contract Signed' && quote_i.zqu__QuoteBusinessType__c == 'Feature Update') ||
                (quote_i.zqu_Quote_Status__c == 'Sent To Zuora' && quote_i.zqu__QuoteBusinessType__c == 'New' && quote_i.Trial_Quote__c))
            ){
                quote_i.Submitted_Quote_For_Renewal_Timestamp__c = Datetime.now();
            }
        }
        if (!quoteFinalizeList.isEmpty()) {
            ZuoraQuoteFinalizeHelper.finalizeQuote(quoteFinalizeList);
        }
    }

    private void onAfterUpdateLogic(Map<Id,SObject> existingRecords){
        System.debug('quote domain check');
        Set<Id> validQuoteIds = new Set<Id>();
        Set<Id> contractWordingAmendDIDescriptionQuoteIdSet = new Set<Id>();
        Set<Id> pendingRenewalDateQuoteIdSet = new Set<Id>();
        List<zqu__Quote__c> newSubQuotes = new List<zqu__Quote__c>();
        List<zqu__Quote__c> updateRelAccountQuotes = new List<zqu__Quote__c>();
        List<String> quoteIdsToReAddProducts = new List<String>();
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            zqu__Quote__c oldQuote = (zqu__Quote__c)existingRecords.get(quote_i.Id);
            if (quote_i.payment_frequency1__c != oldQuote.payment_frequency1__c) 
            {
                quoteIdsToReAddProducts.add(quote_i.Id);
                if(Utility.getRecordTypeIdForObject(quote_i.getSObjectType(), 'Cancellation') != quote_i.RecordTypeId){

                    validQuoteIds.add(quote_i.Id);
                }
            }
            if ('New Subscription'.equalsIgnoreCase(quote_i.zqu__SubscriptionType__c)) 
            {
                newSubQuotes.add(quote_i);
            }
            if (oldQuote.Contract_Wording_List_Amend__c != quote_i.Contract_Wording_List_Amend__c ||
                oldQuote.dI_reporting_description__c != quote_i.dI_reporting_description__c) 
            {
                contractWordingAmendDIDescriptionQuoteIdSet.add(quote_i.Id);
            }
            if(quote_i.zqu__SubscriptionTermEndDate__c != null){
                updateRelAccountQuotes.add(quote_i);
            }
        }

        if(!quoteIdsToReAddProducts.isEmpty()){
            ZuoraQuoteMetricsManipulationHelper.reAddAllQuotesProducts(quoteIdsToReAddProducts);
        }


        List<zqu__QuoteRatePlanCharge__c> qrpcToUpdate = ZuoraQuoteMetricsManipulationHelper.calculateSpecificBillingPeriod(newSubQuotes,validQuoteIds);
        update qrpcToUpdate;
        Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance('Rounding_Resolve_V1');
        Boolean featureFlag = roundingFF.Is_Active__c;
        if(isCalculationEnabled && !featureFlag){
            ZuoraQuoteMetricsManipulationHelper.updateChargesIfMetricsChanged(newRecords,existingRecords);
        }
        if (!contractWordingAmendDIDescriptionQuoteIdSet.isEmpty()) {
            System.debug('i am in quoteDomain');
            BaseProductAddonCalculationHelper.calculateAmendWording(contractWordingAmendDIDescriptionQuoteIdSet);
        }
        if(!updateRelAccountQuotes.isEmpty()){
            updateRelAccount(updateRelAccountQuotes);
        }
        zqu__Quote__c quote = (zqu__Quote__c)newRecords[0];
        zqu__Quote__c oldQuote = (zqu__Quote__c)existingRecords.get(quote.Id);
        if (quote.zqu_Quote_Status__c == 'Sent To Zuora' && quote.zqu_Quote_Status__c != oldQuote.zqu_Quote_Status__c) {
            System.debug(' we are going to the  z_AccountCustomFieldsUpdate');
            System.enqueueJob(new z_AccountCustomFieldsUpdate());
            Boolean isCertificateIdNotBlank = String.isNotBlank(quote.zqu__Certificate_ID__c);
            Boolean isNewSubscriptionQuote = (quote.zqu__SubscriptionType__c == 'New Subscription');
            if(isCertificateIdNotBlank && isNewSubscriptionQuote && !System.isQueueable()){
                this.launchZuoraAccountFieldUpdateJob(new Set<Id>{quote.Id});
            }
            if((quote.zqu__QuoteBusinessType__c.containsIgnoreCase(' + Renewal')
                || (quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Renewal') && quote.Customer_requests_to_pay_immediately__c)
                )
                && quote.zqu__SubscriptionType__c == 'Amend Subscription'
            )
            {
                System.enqueueJob(new QuoteRenewalProcessQueueableService(new Set<Id>{quote.Id},'createRenewalCloneOfAmendQuote'));
            }
        }

        if(
            (quote.Contacts_Product__c || quote.Exception_Product__c)&& // changed by alon MQ-1620
            quote.zqu_Quote_Status__c != oldQuote.zqu_Quote_Status__c &&
            ((quote.zqu_Quote_Status__c == 'Contract Signed' && quote.zqu__QuoteBusinessType__c == 'Feature Update') ||
            (quote.zqu_Quote_Status__c == 'Sent To Zuora' && quote.zqu__QuoteBusinessType__c == 'New' && quote.Trial_Quote__c))
        ){
            generateContract(quote.Id);
        }
    }

    @TestVisible
    private void launchZuoraAccountFieldUpdateJob(Set<Id> quoteIds){
        ZAccountFieldsUpdate accountFieldUpdateJob = new ZAccountFieldsUpdate(quoteIds);
        if(Test.isRunningTest() == false){
            System.enqueueJob(accountFieldUpdateJob);
        }
    }

    private void updateRelAccount(List<zqu__Quote__c> newList) {
        Set<Id> accIdSet = new Set<Id>();
        Set<String> statusSet = new Set<String>{'Quote Pending Renewal Date','Processed Directly in Zuora','Sent To Zuora'}; // changed by alon shalev 23.5.22
        for (zqu__Quote__c q_i : newList) {
            if(q_i.zqu__Account__c != null 
                && q_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'
                && statusSet.contains(q_i.zqu_Quote_Status__c))
            {
                accIdSet.add(q_i.zqu__Account__c);
            }
        }
        if(accIdSet.isEmpty()){
            return;
        }
        Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, fr_NextRenewalDate__c FROM Account WHERE Id IN: accIdSet]);
        Map<Id,Account> accToUpMap = new Map<Id,Account>();
        for (zqu__Quote__c q_i : newList) {
            if(q_i.zqu__SubscriptionTermEndDate__c != null && accMap.containsKey(q_i.zqu__Account__c)) {
                Account currAcc = accMap.get(q_i.zqu__Account__c);
                if(currAcc.fr_NextRenewalDate__c == null){
                    currAcc.fr_NextRenewalDate__c = q_i.zqu__SubscriptionTermEndDate__c;
                    accToUpMap.put(currAcc.Id,currAcc);
                }else if(currAcc.fr_NextRenewalDate__c < q_i.zqu__SubscriptionTermEndDate__c){
                    currAcc.fr_NextRenewalDate__c = q_i.zqu__SubscriptionTermEndDate__c;
                    accToUpMap.put(currAcc.Id,currAcc);
                }
            }
        }
        if(!accToUpMap.isEmpty()){
            update  accToUpMap.values();
        }
    }

    private void checkIfFeldsIsChanged(Map<Id,SObject> existingRecords){
        System.debug('checkIfFeldsIsChanged');
        List<String> fieldNameList = new List<String>{
            'zqu_Quote_Status__c',
            'zqu__SubscriptionType__c',
            'document_format__c',
            'payment_frequency1__c',
            'zqu__PaymentTerm__c',
            'Irregular_Frequency__c',
            'zqu__PaymentMethod__c',
            'Link_to_SW_System__c',
            'RecordTypeId',
            'zqu__QuoteBusinessType__c',
            'Is_from_existing_Billing_Account__c',
            'Is_Contract_Signed_Manually__c',
            'zqu__Previewed_Delta_MRR__c',
            'zqu__Previewed_Delta_TCV__c', 
            'Sub_total__c',
            'zqu__Previewed_SubTotal__c',
            'Q2C_Green_Lane__c',
            'zqu__StartDate__c',
            'Submit_Button_Timestamp__c',
            'Recurring_Discount_Percentage__c',
            'Is_Quote_Ready__c'
        };
        boolean isChanged = false;
        Map<String,Object> fieldNameToValueMap = new Map<String,Object>();
        fieldNameToValueMap.put('yaronIsStupid','ass');
        List<zqu__Quote__c> changedQuoteList = new List<zqu__Quote__c>();
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            zqu__Quote__c oldQuote = (zqu__Quote__c)existingRecords.get(quote_i.Id);

            for(String fieldName: fieldNameList){
                System.debug('fieldName--'+fieldName);
                System.debug('quote_i.get(fieldName---'+quote_i.get(fieldName));
                System.debug('oldQuote.get(fieldName)---'+oldQuote.get(fieldName));
                if(quote_i.get(fieldName) != oldQuote.get(fieldName)){
                    changedQuoteList.add(quote_i);
                    isChanged = true;
                    System.debug('fieldName is changed---'+fieldName);
                    if(fieldName == 'Is_Quote_Ready__c'){
                        fieldNameToValueMap.put('isQuoteReady',quote_i.Is_Quote_Ready__c);
                        fieldNameToValueMap.put('Is_Quote_Ready__c',quote_i.Is_Quote_Ready__c);
                    }
                }
            }
        }

        if(!changedQuoteList.isEmpty()){
            Map<String,String> newSubQuoteIdToJsonFieldsMap = new Map<String,String>();
            Map<String,String> amendQuoteIdToJsonFieldsMap = new Map<String,String>();
            for(zqu__Quote__c quote_i: changedQuoteList){
                for(String fieldName: fieldNameList){
                    Object fieldValue = quote_i.get(fieldName);
                    fieldNameToValueMap.put(fieldName,fieldValue);
                }

                Boolean isARenewal7day = false;
                Boolean isRefreshAllowed = false;
                zqu__Quote__c oldQuote = (zqu__Quote__c)existingRecords.get(quote_i.Id);
                if (
                    quote_i.zqu__StartDate__c != null 
                    && Date.today().daysBetween(quote_i.zqu__StartDate__c) >= 7
                    && Date.today() < quote_i.zqu__StartDate__c
                ) {
                    isARenewal7day = true;
                }
                fieldNameToValueMap.put('isARenewal7day',isARenewal7day);

                if(quote_i.zqu__SubscriptionType__c == 'Amend Subscription'){
                    amendQuoteIdToJsonFieldsMap.put(quote_i.Id,JSON.serialize(fieldNameToValueMap));
                } else {
                    newSubQuoteIdToJsonFieldsMap.put(quote_i.Id,JSON.serialize(fieldNameToValueMap));
                }
            }
            createCustomEventForRefreshLayout(amendQuoteIdToJsonFieldsMap,newSubQuoteIdToJsonFieldsMap);
        }
    }

    private void createRenewalConfirmationTimestampPdf(Map<Id,SObject> existingRecords){
        Set<Id> quoteIdSet = new Set<Id>();
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            zqu__Quote__c oldQuote = (zqu__Quote__c)existingRecords.get(quote_i.Id);

            Boolean isRenewalByClientConfirmation = quote_i.Renewal_by_client_confirmation__c;
            if(
                quote_i.zqu_Quote_Status__c != oldQuote.zqu_Quote_Status__c && 
                isRenewalByClientConfirmation && 
                quote_i.Submitted_Quote_For_Renewal_Timestamp__c == null &&
                (quote_i.zqu_Quote_Status__c == 'Sent To Zuora' || quote_i.zqu_Quote_Status__c == 'Quote Pending Renewal Date') 
            ){
                quote_i.Submitted_Quote_For_Renewal_Timestamp__c = Datetime.now();
                quoteIdSet.add(quote_i.Id);
            }
        }

        if(!quoteIdSet.isEmpty()){
            ZuoraSubmitQuoteController.createRenewalConfirmationTimestampPdf(quoteIdSet);
        }
    }

    private void createCustomEventForRefreshLayout(Map<String,String> amendQuoteIdToJsonFieldsMap, Map<String,String> newSubQuoteIdToJsonFieldsMap){
        System.debug('createCustomEventForRefreshLayout---');
        List<Quote_is_changed__e> quoteIsChangedEventList = new List<Quote_is_changed__e>();
        List<Amend_quote_is_changed__e> amendQuoteIsChangedEventList = new List<Amend_quote_is_changed__e>();

        for(String quoteId: amendQuoteIdToJsonFieldsMap.keySet()){
            Amend_quote_is_changed__e quoteIsChangedEvent = new Amend_quote_is_changed__e();
            quoteIsChangedEvent.quoteId__c = quoteId;
            quoteIsChangedEvent.fieldsJson__c = amendQuoteIdToJsonFieldsMap.get(quoteId);
            amendQuoteIsChangedEventList.add(quoteIsChangedEvent);
        }

        for(String quoteId: newSubQuoteIdToJsonFieldsMap.keySet()){
            Quote_is_changed__e quoteIsChangedEvent = new Quote_is_changed__e();
            quoteIsChangedEvent.quoteId__c = quoteId;
            quoteIsChangedEvent.fieldsJson__c = newSubQuoteIdToJsonFieldsMap.get(quoteId);
            quoteIsChangedEventList.add(quoteIsChangedEvent);
        }
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if(!amendQuoteIsChangedEventList.isEmpty()){
            results.addAll(EventBus.publish(amendQuoteIsChangedEventList));
        }
        if(!quoteIsChangedEventList.isEmpty()){
            results.addAll(EventBus.publish(quoteIsChangedEventList));
        }

        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess()) {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('Error returned: ' +
                                err.getStatusCode() +
                                ' - ' +
                                err.getMessage());
                }
            }       
        }
    }

    @Future(callout=true)
    private static void generateContract(String quoteId){
        Zuora_Document_Generation_Setting__c defaultRenewalTemplate = Zuora_Document_Generation_Setting__c.getInstance('Default Trial/FU template');
        String templateId = null;
        if(defaultRenewalTemplate != null){
            templateId = defaultRenewalTemplate.Value__c;
        }
        String fileURL = ZuoraContractGenerationHelper.generatePreviewContract(quoteId, false,templateId);
        ZuoraContractGenerationHelper.obtainAndSaveContract(quoteId, fileURL, 'saving', 'Generate contract', true);
    }

    private void handleCalculateZuoraPricing(Map<Id, zqu__Quote__c> oldRecordMap){
        handleToTalSumOfFees(oldRecordMap);
        System.debug('alon is here!!!');
        List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();

        for(zqu__Quote__c quote : (List<zqu__Quote__c>)newRecords){
            System.debug('lets see if zoura is updating me--'+quote.zqu__Previewed_SubTotal__c);
            System.debug('quote.zqu__QuoteBusinessType__c: ' + quote.zqu__QuoteBusinessType__c);
            System.debug('quote.Recurring_Target_Price__c: ' + quote.Recurring_Target_Price__c);
            System.debug('oldRecordMap.get(quote.id).Recurring_Target_Price__c: ' + oldRecordMap.get(quote.id).Recurring_Target_Price__c);
            System.debug('oldRecordMap.get(quote.id).zqu__Is_Charge_Expired__c): ' + oldRecordMap.get(quote.id).zqu__Is_Charge_Expired__c);
            System.debug('quote.zqu__Is_Charge_Expired__c ' + quote.zqu__Is_Charge_Expired__c);
            System.debug('quote.Is_Discount_Given__c: ' + quote.Is_Discount_Given__c);
            System.debug('quote.Duplicate_Quote__c: ' + quote.Duplicate_Quote__c + ' old quote -- '+oldRecordMap.get(quote.Id).Duplicate_Quote__c);
            if((quote.zqu__QuoteBusinessType__c == 'New' ||
                    (quote.zqu__QuoteBusinessType__c.contains('Co-Term Upsell') || quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Renewal'))) &&
                    (quote.Recurring_Target_Price__c != null && (quote.Recurring_Target_Price__c != oldRecordMap.get(quote.id).Recurring_Target_Price__c))
                    ){

                if(!quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')){
                    System.debug('zohar is here! quotesToUpdate! in quote trigger before update');
                    quotesToUpdate.add(quote);
                }
            }
//            if(quote.zqu__QuoteBusinessType__c == 'Feature Update'){
//
//            }
        }
        if(!quotesToUpdate.isEmpty() ){
            //ZuoraPriceCalculation.updateQuoteSums(quotesToUpdate,false);
        }
        System.debug('quotesToUpdate--'+quotesToUpdate);
        System.debug('quotesToUpdate-----alon-----');
        for(zqu__Quote__c quote : quotesToUpdate){
            if(!System.isQueueable()){
                if(quote.Recurring_Target_Price__c != null){
                    quote.Discount_Status__c = 'Discount Started';
                    System.debug('hi this is discount started !!!!');
                    if(quote.zqu__QuoteBusinessType__c == 'New'){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote, 'AddDiscount'));
                        quote.Is_Quote_Ready__c = false;

                    }else if(quote.zqu__QuoteBusinessType__c.contains('Co-Term Upsell')){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote, 'CTU'));
                        System.debug(' i am here!!!! -- '+quote.Is_Quote_Ready__c);
                        System.debug(quote.Is_Quote_Ready__c);
                        quote.Is_Quote_Ready__c = false;
                    }else if(quote.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote, 'Renewal'));
                        quote.Is_Quote_Ready__c = false;

                    }
                }
            }
        }
    }

    private void handleToTalSumOfFees(Map<Id, zqu__Quote__c> oldRecordMap){
        System.debug('yaron started checkings');
        List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
        for(zqu__Quote__c quote : (List<zqu__Quote__c>)newRecords){
            System.debug('quote.Total_Sum_Of_Fees__c---'+quote.Total_Sum_Of_Fees__c);
            boolean recurringTargetPriceChanged = quote.Recurring_Target_Price__c != null &&  quote.Recurring_Target_Price__c != oldRecordMap.get(quote.Id).Recurring_Target_Price__c ;
            boolean discountStarted = quote.Discount_Status__c == 'Discount Started';
            System.debug('quote.Recurring_Target_Price__c---'+quote.Recurring_Target_Price__c);
            System.debug('old.Recurring_Target_Price__c---'+oldRecordMap.get(quote.Id).Recurring_Target_Price__c);
            System.debug('quote.Discount_Status__c---'+quote.Discount_Status__c);
            if((recurringTargetPriceChanged || discountStarted)){
                quotesToUpdate.add(quote);
            }
        }

        if(!quotesToUpdate.isEmpty()){
            //ZuoraPriceCalculation.updateQuoteSums(quotesToUpdate,false);
        }
    }
    public override void onValidate() {
        ZuoraQuoteValidations.checkActiveSubscribtion((List<zqu__Quote__c>)newRecords);
    }

    public class Constructor implements GenericDomain.IConstructable
	{
		public GenericDomain constructDomainInstance(List<SObject> sObjectList)
		{
			return new ZQuoteDomain(sObjectList);
		}
	}
}
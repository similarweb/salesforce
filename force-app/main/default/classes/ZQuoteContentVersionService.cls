public with sharing class ZQuoteContentVersionService {

    public static List<ContentVersion> setSignatureDate(List<ContentVersion> contentVer, Date signDate){
        if(signDate != null){
            for(ContentVersion cv : contentVer){
                cv.Signature_date__c = signDate;
            }
        }
        return contentVer;
    }


    public static void changeQuotefields(List<ContentVersion> contentVer, Boolean isFinalContract){
        System.debug(contentVer);
        System.debug('alion started');
        Set<String> newSubscriptionStatusSet = new Set<String>{'Terms Approved','Approved By Billing'};
        Set<String> AmendSubscriptionUnRelevantStatusSet = new Set<String>{'Quote Pending Renewal Date','Voided'};


        Map<String,ContentVersion> cvWithQuoteIdKey = new Map<String,ContentVersion>();

        for(ContentVersion cv : contentVer){
            cvWithQuoteIdKey.put(cv.Zuora_Quote__c, cv);
        }
        if(!cvWithQuoteIdKey.isEmpty()){
            List<zqu__Quote__c> quotes = [SELECT Id
                                                , zqu_Quote_Status__c
                                                , Contract_Start_Upon__c
                                                , zqu__StartDate__c
                                                , zqu__Service_Activation_Date__c
                                                , zqu__Customer_Acceptance_Date__c
                                                , zqu__TermStartDate__c
                                                , zqu__SubscriptionType__c
                                                , zqu__PaymentMethod__c
                                            FROM zqu__Quote__c
                                            WHERE Id IN : cvWithQuoteIdKey.keySet()];

            for(zqu__Quote__c quote: quotes){
                checkConditionsForManualUpdate(isFinalContract, quote, newSubscriptionStatusSet, AmendSubscriptionUnRelevantStatusSet);
                ContentVersion cv = cvWithQuoteIdKey.get(quote.Id);

//                if((quote.zqu_Quote_Status__c == 'Approved By Billing' || quote.zqu_Quote_Status__c == 'Terms Approved' || quote.zqu__SubscriptionType__c=='Amend Subscription' ) && isFinalContract){
//                    if(!(quote.zqu__SubscriptionType__c =='Amend Subscription' && quote.zqu__PaymentMethod__c == 'Credit Card')){
//                        if(quote.zqu_Quote_Status__c != 'Quote pending renewal date'){
//                            quote.zqu_Quote_Status__c = 'Contract Signed Manually';
//                        }
//                        quote.Is_Contract_Signed_Manually__c = true;
//                    }
//                } this was the old logic almost the same the difference is with Is_Contract_Signed_Manually__c and zqu_Quote_Status__c alon shalev 09.08.22

                if(quote.Contract_Start_Upon__c == 'Signature date' && cv.Signature_date__c != null){
                    quote.zqu__StartDate__c = cv.Signature_date__c;
                    quote.zqu__Service_Activation_Date__c = cv.Signature_date__c;
                    quote.zqu__Customer_Acceptance_Date__c = cv.Signature_date__c;
                    if(quote.zqu__SubscriptionType__c!='Amend Subscription'){
                        quote.zqu__TermStartDate__c = cv.Signature_date__c;
                    }
                }

            }

            update quotes;
        }
    }

    private static void checkConditionsForManualUpdate(Boolean isFinalContract, zqu__Quote__c quote, Set<String> newSubscriptionStatusSet, Set<String> AmendSubscriptionUnRelevantStatusSet) {
        Boolean needToUpdate = isFinalContract;
        system.debug('needToUpdate--'+needToUpdate);
        if (needToUpdate) {
            system.debug('quote.zqu__SubscriptionType__c--'+quote.zqu__SubscriptionType__c);
            if (quote.zqu__SubscriptionType__c == 'New Subscription') {
                needToUpdate = checkNewSubscription(newSubscriptionStatusSet, quote);
            } else if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
                needToUpdate = checkAmendSubscription(AmendSubscriptionUnRelevantStatusSet, quote);
            }
        }
        system.debug(' need to update finish--'+needToUpdate);
        if (needToUpdate) {
            quote.Is_Contract_Signed_Manually__c = true;
            quote.zqu_Quote_Status__c = 'Contract Signed Manually';
        }
    }

    private static boolean checkAmendSubscription(Set<String> AmendSubscriptionUnRelevantStatusSet, zqu__Quote__c quote) {

        boolean needToUpdate = AmendSubscriptionUnRelevantStatusSet.contains(quote.zqu_Quote_Status__c) ? false : true;
        system.debug('AmendSubscriptionUnRelevantStatusSet-'+AmendSubscriptionUnRelevantStatusSet);
        system.debug('needToUpdate--'+needToUpdate);
        system.debug('quote.zqu_Quote_Status__c--'+quote.zqu_Quote_Status__c);
        if (needToUpdate) {
            needToUpdate = quote.zqu__PaymentMethod__c == 'Credit Card' ? false : true;
            system.debug('needToUpdate--'+needToUpdate);
        }
        return needToUpdate;
    }

    private static boolean checkNewSubscription(Set<String> newSubscriptionStatusSet, zqu__Quote__c quote) {
       return newSubscriptionStatusSet.contains(quote.zqu_Quote_Status__c);
    }

    public static void setLastSignatureDate(List<ContentVersion> contentVerList) {

        System.debug(contentVerList);
       
        Date latesSign;

        Map<String,ContentVersion> cvWithQuoteIdKey = new Map<String,ContentVersion>();

        for(ContentVersion cv : contentVerList){
            if(cv.Zuora_Quote__c != null){
                if(cvWithQuoteIdKey.get(cv.Zuora_Quote__c) == null){

                    cvWithQuoteIdKey.put(cv.Zuora_Quote__c, cv);
                } else {
                    ContentVersion existingCv = cvWithQuoteIdKey.get(cv.Zuora_Quote__c);
                    if(cv.Signature_date__c > existingCv.Signature_date__c){
                        cvWithQuoteIdKey.put(cv.Zuora_Quote__c, cv);
                    }
                }
            }
        }
        if (!cvWithQuoteIdKey.isEmpty()) {
            List<zqu__Quote__c> quotes = [SELECT Id
                                                , Contract_Start_Upon__c
                                                , zqu__StartDate__c
                                                , zqu__Service_Activation_Date__c
                                                , zqu__Customer_Acceptance_Date__c
                                                , zqu__TermStartDate__c
                                            FROM zqu__Quote__c
                                            WHERE Id IN : cvWithQuoteIdKey.keySet()];
            
            for(zqu__Quote__c quote: quotes){

                ContentVersion cv = cvWithQuoteIdKey.get(quote.Id);

                quote.Last_Contract_Date__c = cv.Signature_date__c;

            }
            update quotes;
        }
    }
}
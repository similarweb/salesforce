public with sharing class ZuoraQuoteFlowHelper {

    public static Boolean isInitialStatusForTestEnabled = true;

    public static void calculateQuoteStatus(List<SObject> newRecords){
        System.debug(newRecords);
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
            if ((!Test.isRunningTest() || isInitialStatusForTestEnabled)
                && (quote_i.zqu__SubscriptionType__c =='New Subscription' 
                || quote_i.zqu__SubscriptionType__c =='Amend Subscription' )
                && quote_i.zqu_Quote_Status__c !='Quote Pending Renewal Date') // Becasue of duplicate process
            { 
                ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote_i);
                quote_i.zqu_Quote_Status__c = zqsc.initialStatus();
            }
        }
    }

    /*public static void calculateContractType(List<SObject> newRecords){
        for (zqu__Quote__c quote_i : (List<zqu__Quote__c>)newRecords) {
           if (String.isNotBlank(quote_i.document_format__c)) {
                quote_i.Contract_type__c = quote_i.document_format__c == 'Service Order (Terms and Conditions attached)' ? 'doc' : 'pdf'; 
           }
        }
    }*/
}
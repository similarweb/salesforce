public with sharing class ConfirmSubmitModalController {
    private static Set<String> statusSet = new Set<String>{
        'Sent To Zuora',
        'Cancelled',
        'Processed Directly in Zuora',
        'Voided',
        'Accepted',
        'Quote pending renewal date'
    };
    /**
     * @description Set all Quotes that fits the condition as Voided and ReadOnly
     * @param String quoteId - Id of Quote which is submitted
     * @return Response - contains List<zqu__Quote__c> of updated Quotes
     */
    @AuraEnabled
    public static Response voidQuotes(String quoteId, String subscriptionName){
        try {
            ResponseWrapper responseWrapper = new ResponseWrapper();
            responseWrapper.quoteId = quoteId;
            if(!String.isBlank(quoteId) && !String.isBlank(subscriptionName)){
                List<zqu__Quote__c> quoteList = [
                    SELECT
                        Id, zqu_Quote_Status__c, RecordTypeId, zqu__Subscription_Name__c
                    FROM
                        zqu__Quote__c
                    WHERE 
                        zqu__Subscription_Name__c =: subscriptionName
                        AND Id !=: quoteId AND zqu_Quote_Status__c NOT IN: statusSet
                        AND zqu__SubscriptionType__c = 'Amend Subscription'
                ];
                List<zqu__Quote__c> quotesForUpdate = new List<zqu__Quote__c>();
                for(zqu__Quote__c quote_i : quoteList){
                    if(quote_i.id != quoteId){
                        quote_i.zqu_Quote_Status__c = 'Voided';
                        quote_i.RecordTypeId = '012b0000000QNK8AAO';
                        quotesForUpdate.add(quote_i);
                    }
                }
                if(!quotesForUpdate.isEmpty()){
                    responseWrapper.quoteList = quotesForUpdate;
                    update quotesForUpdate;
                }
            }
            return new Response(true, responseWrapper);
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }
    /**
     * @description Check for other Quotes under the Quote's subscription
     * @param String quoteId - Id of Quote which is submitted
     * @return Response - contains List<zqu__Quote__c> of Quotes that fits condition
     */
    @AuraEnabled
    public static Response obtainQuoteList(String quoteId){
        try {
            ResponseWrapper responseWrapper = new ResponseWrapper();
            zqu__Quote__c quote = [SELECT id, zqu__Subscription_Name__c FROM zqu__Quote__c WHERE Id =: quoteId];
            List<zqu__Quote__c> quoteList = [
                SELECT
                    Id, Name, zqu_Quote_Status__c, RecordTypeId, zqu__Subscription_Name__c, Link__c, Link_Raw__c
                FROM
                    zqu__Quote__c
                WHERE 
                    zqu__Subscription_Name__c =: quote.zqu__Subscription_Name__c
                    AND Id !=: quoteId AND zqu_Quote_Status__c NOT IN: statusSet
                    AND zqu__SubscriptionType__c = 'Amend Subscription'
            ];
            responseWrapper.quoteId = quoteId;
            responseWrapper.quoteList = quoteList;
            responseWrapper.subscriptionName = quote.zqu__Subscription_Name__c;
            return new Response(true, responseWrapper);
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }

    public class ResponseWrapper{
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public List<zqu__Quote__c> quoteList;
        @AuraEnabled
        public String subscriptionName;

        public ResponseWrapper(){}
    }
}
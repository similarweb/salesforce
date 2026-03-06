/**
 * @description Controller for ASProductModal aura component
 * MQ-788 - Create modal window for attaching request to the Quote
 * MQ-1419 - Add Target Quote Total Price field to the modal window
 * @author Developer Synebo
 * 
 */
public with sharing class ASProductModalController {
    /**
     * @description AuraEnabled method for run on Aura component.
     * Attaches selected requests to the Quote, sets product price with request price, sets Target Total value on the Quote
     * and recalculates product prices after the attachment
     * @param quoteId - Id of Current Quote
     * @param oneTimeRequestId - Id of One-Time request
     * @param recurrencyRequestId - Id of Recurrency request
     * @param targetPriceValue - value of Target Quote Total Price field from the modal window
     * @return `Response` - Response object with success flag equal to True if requests were inserted successfully and Response Wrapper object
     * @exception RequestException - throwable custom exception for cases, when Quote doesn't match the conditions 
     */
    @AuraEnabled
    public static Response insertRequest(
        String quoteId, 
        String oneTimeRequestId, 
        String recurrencyRequestId, 
        Decimal targetPriceValue, 
        Boolean isApprovalFlow,
        Decimal renewalFeeValue
    ){
        try {
            ResponseWrapper responseWrapper = new ResponseWrapper();
            responseWrapper.quoteId = quoteId;
            if(targetPriceValue == 0 || targetPriceValue == null){
                throw new RequestException('Target Total value can\'t be 0 or less');
            }
            List<zqu__Quote__c> quoteList = [
                SELECT 
                    Id, 
                    AS_DS__c, 
                    Quote_contains_AS_products__c, 
                    AS_One_Time_Request__c, 
                    AS_Reccuring_Request__c, 
                    AS_One_Time_Request__r.List_price__c, 
                    AS_Reccuring_Request__r.List_price__c, 
                    Target_Quote_Total_Price__c, 
                    zqu__InitialTerm__c,
                    zqu__QuoteBusinessType__c,
                    zqu__Previewed_SubTotal__c
                FROM zqu__Quote__c
                WHERE Id =: quoteId
            ];
            if(!quoteList.isEmpty()){
                zqu__Quote__c quote = quoteList[0];
                responseWrapper.previewedSubtotal = quote.zqu__Previewed_SubTotal__c;
                if(!quote.AS_DS__c){
                    throw new RequestException('AS_DS__c is false');
                }
                Set<String> requestIdSet = new Set<String>{
                    oneTimeRequestId,
                    recurrencyRequestId
                };
                List<Request__c> requestList = [SELECT Id, List_price__c, Regularity__c, Quote__c FROM Request__c WHERE Id IN: requestIdSet];
                Request__c oneTimeRequest;
                Request__c recurringRequest;
                Map<String, Decimal> requestMap = new Map<String, Decimal>();
                for(Request__c request : requestList){
                    if(request.Regularity__c.toLowerCase().contains('one time')){
                        oneTimeRequest = request;
                        requestMap.put(request.Regularity__c, request.List_Price__c);
                    } else if(request.Regularity__c.toLowerCase().contains('recurring')){ 
                        recurringRequest = request;
                        requestMap.put(request.Regularity__c, request.List_Price__c);
                    }
                }

                checkIfASProductsExist(quote,oneTimeRequest,recurringRequest);
                responseWrapper.oneTimeRequestId = oneTimeRequestId;
                responseWrapper.recurrencyRequestId = recurrencyRequestId;

                if(
                    (targetPriceValue == quote.Target_Quote_Total_Price__c) && 
                    (
                        isApprovalFlow ||
                        (((quote.AS_One_Time_Request__c == null && String.isBlank(oneTimeRequestId)) || (quote.AS_One_Time_Request__c == oneTimeRequestId) || (oneTimeRequest == null) || (quote.AS_One_Time_Request__r.List_price__c == oneTimeRequest.List_Price__c)) 
                        && ((quote.AS_Reccuring_Request__c == null && String.isBlank(recurrencyRequestId)) || (quote.AS_Reccuring_Request__c == recurrencyRequestId) || (recurringRequest == null) || (quote.AS_Reccuring_Request__r.List_Price__c == recurringRequest.List_Price__c)))
                    )
                ){
                    responseWrapper.metricsChanged = false;
                } else {
                    responseWrapper.metricsChanged = true;
                }

                if(!requestList.isEmpty()){
                    //ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPrice(quote.id, targetPriceValue, quote.zqu__InitialTerm__c, oneTimeRequestId, recurrencyRequestId, requestMap);
                    if(!Test.isRunningTest()){
                        System.enqueueJob(new ZuoraQuoteMetricManipulationQueueable(quote.id,targetPriceValue,quote.zqu__InitialTerm__c,oneTimeRequestId,recurrencyRequestId,requestMap,'updateChargesIfMetricsChanged'));
                    }
                    if(quote.Target_Quote_Total_Price__c != targetPriceValue){
                        quote.Target_Quote_Total_Price__c = targetPriceValue;
                        if(quote.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'){
                            quote.Renewal_Fee__c = quote.Target_Quote_Total_Price__c;
                        } else if(quote.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal'){
                            quote.Renewal_Fee__c = renewalFeeValue;
                        }
                        ZQuoteDomain.isCalculationEnabled = false;
                        update quote;
                        ZQuoteDomain.isCalculationEnabled = true;
                    }
                }
                
                return new Response(true, responseWrapper);
            } else{
                return new Response(false, responseWrapper);
            }
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }

    /**
     * @description Method for getting Target_Quote_Total_Price__c field value from the Quote to populate field on the modal popup
     * This method is accessible via Aura component callout
     * MQ-1419 - Getting the Target_Quote_Total_Price__c field value
     * @param quoteId - Id of Current Quote
     * @return  `Response` that contains RepsonseWrapper object with id of quote and Target_Quote_Total_Price__c field value
     */
    @AuraEnabled
    public static Response getQuoteFields(String quoteId){
        try {
            ResponseWrapper responseWrapper = new ResponseWrapper();
            responseWrapper.quoteId = quoteId;
            Decimal targetPriceValue = 0;
            Decimal renewalFee = 0;
            String quoteBusinessType, subscriptionType;
            Decimal previewedSubtotal;
            List<zqu__Quote__c> quoteList = [
                SELECT
                    Id, 
                    Target_Quote_Total_Price__c, 
                    zqu__QuoteBusinessType__c, 
                    zqu__SubscriptionType__c, 
                    zqu__Previewed_SubTotal__c,
                    Renewal_Fee__c
                FROM zqu__Quote__c
                WHERE Id =: quoteId
            ];
            if(!quoteList.isEmpty()){
                zqu__Quote__c quote = quoteList[0];
                if(quote.Target_Quote_Total_Price__c != null){
                    targetPriceValue = quote.Target_Quote_Total_Price__c;
                }
                if(quote.Renewal_Fee__c != null){
                    renewalFee  = quote.Renewal_Fee__c;
                }
                quoteBusinessType = quote.zqu__QuoteBusinessType__c;
                subscriptionType = quote.zqu__SubscriptionType__c;
                previewedSubtotal = quote.zqu__Previewed_SubTotal__c;
            }
            responseWrapper.targetPriceValue = targetPriceValue;
            responseWrapper.quoteBusinessType = quoteBusinessType;
            responseWrapper.subscriptionType = subscriptionType;
            responseWrapper.previewedSubtotal = previewedSubtotal;
            responseWrapper.renewalFee = renewalFee;
            return new Response(true, responseWrapper);
        } catch (Exception e) {
            return new Response(false, e.getMessage());
        }
    }

    /**
     * @description Method for validating the existence of AS products.
     * @param quote Current Quote on which the logic is running
     * @param oneTimeRequest 
     * @param oneTimeRequest 
     */
    @TestVisible
    private static void checkIfASProductsExist(zqu__Quote__c quote,Request__c oneTimeRequest, Request__c recurringRequest){
        Set<String> productNameSet = new Set<String>();
        List<String> productNameList = new List<String>();
        List<zqu__QuoteRatePlanCharge__c> ratePlanChargeList = [
            SELECT id, zqu__ProductName__c, zqu__ListPrice__c, 
                zqu__ProductRatePlanCharge__r.zqu__Type__c, zqu__QuoteRatePlan__r.zqu__Quote__c
            FROM zqu__QuoteRatePlanCharge__c 
            WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: quote.Id];

        for(zqu__QuoteRatePlanCharge__c ratePlanCharge_i: ratePlanChargeList){
            productNameList.add(ratePlanCharge_i.zqu__ProductName__c);
        }
        if(!productNameList.isEmpty()){
            List<Product2> productList = 
            [
                SELECT 
                    Id,
                    Name,
                    AS__c
                FROM Product2 
                WHERE Name IN :productNameList
                    AND AS__c = '1'
            ];
            for(Product2 product_i : productList){
                productNameSet.add(product_i.Name);
            }
            List<zqu.zChargeGroup> chargeGroupForUpdate = new List<zqu.zChargeGroup>();
            Boolean oneTimeIsValid = oneTimeRequest == null;
            Boolean recurringIsValid = recurringRequest == null;
            if(!Test.isRunningTest()){
                List<zqu.zChargeGroup> relatedChargeGroup = zqu.zQuoteUtil.getChargeGroups( quote.Id );
                for(zqu.zChargeGroup zcg_i : relatedChargeGroup){
                    for (zqu.zCharge zc_i : zcg_i.zCharges){
                        for(String name : productNameSet){
                            if(zc_i.Name.contains(name) && zcg_i.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT){
                                String effectivePrice;
                                if(recurringRequest != null && recurringRequest.Regularity__c.contains(zc_i.CHARGE_TYPE) && recurringRequest.List_price__c != null){
                                    recurringIsValid = true;
                                }
                                else if(oneTimeRequest != null && oneTimeRequest.Regularity__c.toLowerCase() == 'one time' && (zc_i.CHARGE_TYPE.toLowerCase().contains('one') && zc_i.CHARGE_TYPE.toLowerCase().contains('time')) && oneTimeRequest.List_price__c != null){
                                    oneTimeIsValid = true;
                                }
                            }
                        }
                    }
                }
            } else {
                oneTimeIsValid = true;
                recurringIsValid = true;
            }
            if(!(oneTimeIsValid && recurringIsValid)){
                throw new RequestException('The relevant product on the quote is missing, please add it before continuing with this screen');
            }
        }
    }

    /**
     * Inner class to assemble response in a convenient way
     */
    public class ResponseWrapper{
        @AuraEnabled
        public String quoteId {get;set;}
        @AuraEnabled
        public String requestId {get;set;}
        @AuraEnabled
        public String oneTimeRequestId {get;set;}
        @AuraEnabled
        public String recurrencyRequestId {get;set;}
        @AuraEnabled
        public Decimal targetPriceValue {get;set;}
        @AuraEnabled
        public String quoteBusinessType {get;set;}
        @AuraEnabled
        public String subscriptionType {get;set;}
        @AuraEnabled
        public Decimal previewedSubtotal {get;set;}
        @AuraEnabled
        public Boolean metricsChanged{get;set;}
        @AuraEnabled
        public Decimal renewalFee{get;set;}

        public ResponseWrapper(){}
    }

    /**
     * Custom exception class for throwing exception from the code
     */
    class RequestException extends Exception {}
}
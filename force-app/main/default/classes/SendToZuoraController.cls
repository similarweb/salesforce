public with sharing class SendToZuoraController {
    
    @AuraEnabled
    public static Response sendQuoteToZuora(String quoteId){
        Response response;
        try {
            zqu__Quote__c quote = new zqu__Quote__c(Id=quoteId);
            quote.zqu__ElectronicPaymentMethodId__c = TestObjectCreator.randomStream(10,1);
            update quote;
            ZQuoteHandler.testForErrors(quoteId);
            System.enqueueJob(new ZSendQuote(new List <id>{quoteId}));
            response = new Response();
        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }
}
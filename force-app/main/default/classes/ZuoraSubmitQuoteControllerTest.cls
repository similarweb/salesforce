@isTest
public with sharing class ZuoraSubmitQuoteControllerTest {

    @testSetup
    static void setup(){
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();     
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;                
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Add_Finance_Information__c = false;
        quote.email_confirmation_has_been_uploaded__c = true;
        quote.Email_Renewal_by_client_confirmation__c ='test2@gmai.com';
        insert quote;
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,c);
        quote2.zqu__PaymentMethod__c = 'Other';
        quote2.Add_Finance_Information__c = false;
        quote2.email_confirmation_has_been_uploaded__c = false;
        quote2.Email_Renewal_by_client_confirmation__c ='test2@gmai.com';
        insert quote2;
    }
    
//    @isTest
//    static void submitQuoteTest(){
//        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c WHERE email_confirmation_has_been_uploaded__c = true LIMIT 1];
//        Test.startTest();
//        ZuoraSubmitQuoteController.submitQuote(quote.Id,true);
//        Test.stopTest();
//    }
//
//    @isTest
//    static void submitQuoteTestWithoutEmailConfirm(){
//        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c WHERE email_confirmation_has_been_uploaded__c = false LIMIT 1];
//        Test.startTest();
//        ZuoraSubmitQuoteController.submitQuote(quote.Id,true);
//        Test.stopTest();
//    }
    
    @isTest
    static void finalizeQuoteTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c WHERE email_confirmation_has_been_uploaded__c = true LIMIT 1];
        Test.startTest();
        ZuoraSubmitQuoteController.finalizeQuote(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void createRenewalConfirmationTimestampPdfTest(){
        Zuora_Document_Generation_Setting__c defaultRenewalTemplate = new Zuora_Document_Generation_Setting__c();
        defaultRenewalTemplate.Name = 'Default Renewal Quote Template Id';
        defaultRenewalTemplate.Value__c = 'test';

        insert defaultRenewalTemplate;

        String quoteId = 'test';
        String fileUrl = 'test';
        String responseBody = '{'+
                              '    "success": true'+
                              '}';

        HttpResponse testResp = new HttpResponse();
        testResp.setStatusCode(200);
        testResp.setHeader('Content-Type','application/msword');
        testResp.setBody(responseBody);
        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c WHERE email_confirmation_has_been_uploaded__c = true LIMIT 1];
        Test.startTest();
        ZuoraSubmitQuoteController.createRenewalConfirmationTimestampPdf(new Set<Id>{quote.Id});
        Test.stopTest();
    }
    
    @isTest
    static void submitQuoteNegativeTest(){
        Test.startTest();
        ZuoraSubmitQuoteController.submitQuote('a1l1x000000ZiWdDIK',true);
        Test.stopTest();
    }
    
    @isTest
    static void finalizeQuoteNegativeTest(){
        Test.startTest();
        ZuoraSubmitQuoteController.finalizeQuote('a1l1x000000ZiWdDIK');
        Test.stopTest();
    }

    private class ZuoraServiceMock implements HttpCalloutMock {
        private HttpResponse res;

        public ZuoraServiceMock(HttpResponse res){
            this.res = res;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return this.res;
        }
    }

    @isTest
    static void validateSubscriptionTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        ZuoraSubmitQuoteController.validateSubscription(quote.id);
        Test.stopTest();
    }
}
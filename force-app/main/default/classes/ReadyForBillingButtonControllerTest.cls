@isTest
public with sharing class ReadyForBillingButtonControllerTest {
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
        quote.document_format__c = 'Service Order (Terms and Conditions attached)';
        insert quote;
    }
    
    @isTest
    static void readyForBillingQuoteTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        Response rsp = ReadyForBillingButtonController.readyForBillingQuote(quote.Id,true);
        //System.assertEquals(Label.Updated_Ready_For_Billing_popup_message,rsp.message);
        Test.stopTest();
    }

    @isTest
    static void readyForBillingQuoteFaultTest(){
        MockUtil.isSuccessfull = false;
        Test.startTest();
        ReadyForBillingButtonController.readyForBillingQuote(null,false);
        Test.stopTest();
    }

    @isTest
    static void validateSubscriptionTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        Response rsp = ReadyForBillingButtonController.validateSubscription(quote.Id);
        //System.assertEquals(Label.Updated_Ready_For_Billing_popup_message,rsp.message);
        Test.stopTest();
    }
}
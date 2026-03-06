@isTest
public with sharing class ZuoraCancelQuoteButtonControllerTest {
    @testSetup
    public static void setup(){            
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
        upsert TestDataFactory.createZuoraQuoteApprovalSettings_CS();
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        List<String> countries =  TestDataFactory.getCountries();
        Account a = TestDataFactory.createAccount();
        a.billingcountry = countries[countries.size()-1];
        insert a;
        Contact c = TestDataFactory.createContact(a, 'test@testing.com');
        c.MailingCountry = countries[countries.size()-1];
        insert c;
        List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
        insert lcsc;
        Opportunity o = TestDataFactory.createOpportunity (a);
        insert o;                
        zqu__Quote__c quote = TestDataFactory.createZQuote (o,c); 
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Customer_Type__c = 'Company';
        insert quote;        
    }

    @isTest
    public static void test(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        quote.zqu_Quote_Status__c = 'Terms Approved';
        quote.zqu__SubscriptionType__c = 'New Subscription';
        update quote;
        ZQuoteService service = new ZQuoteService();
        Test.startTest();
        ZuoraCancelQuoteButtonController.cancelQuote(quote.Id);
        Test.stopTest();
    }
}
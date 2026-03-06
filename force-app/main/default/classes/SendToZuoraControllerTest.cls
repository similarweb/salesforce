@isTest
public with sharing class SendToZuoraControllerTest {
    @testSetup
    static void setup(){
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        List<String> countries =  TestObjectCreator.getCountries();
        Account a = TestDataFactory.createAccount();
        a.billingcountry = countries[countries.size()-1];
        insert a;
        List<Contact> contacts = new List<Contact>();
        Contact c = TestDataFactory.createContact(a, 'test@testing.com');
        c.MailingCountry = countries[countries.size()-1];
        c.Country_Code__c = 'UK';
        contacts.add(c);
        insert contacts;
        Opportunity o = TestDataFactory.createOpportunity (a);
        insert o;        
        zqu__Quote__c quote = TestDataFactory.createZQuote(o,c);
        insert quote;
    }

    @isTest
    static void test(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        SendToZuoraController.sendQuoteToZuora(quote.Id);
        Test.stopTest();
    }
}
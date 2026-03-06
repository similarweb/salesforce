@isTest
public with sharing class QuoteOppQuoteRelatedListControllerTest {
    
    @testSetup
    static void setup(){
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        List<String> countries =  TestObjectCreator.getCountries();
        Account a = TestObjectCreator.CreateAccount();
        a.billingcountry = countries[countries.size()-1];
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        c.MailingCountry = countries[countries.size()-1];
        insert c;
        list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        Opportunity o = TestObjectCreator.CreateOpportunity (a);
        insert o;                
        zqu__Quote__c q1 = TestDataFactory.CreateZQuote (o,c);
        q1.zqu__Currency__c = 'USD';
        zqu__Quote__c q2 = TestDataFactory.CreateZQuote (o,c);
        q2.zqu__Currency__c = 'USD';
        insert new List<zqu__Quote__c>{q1,q2};
        // ContentVersion cvPdf = TestDataFactory.createContentVersionWithType('pdf');
        // insert cvPdf;
        // cvPdf = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cvPdf.Id LIMIT 1];
        // ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(q.id,cvPdf.ContentDocumentId);
        // insert cdl;
        // Attachment att = TestDataFactory.createAttachment(o.Id);
        // insert att;
    }

    @isTest
    static void obtailnRelatedQuotesTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        Response faultResponse = QuoteOppQuoteRelatedListController.obtailnRelatedQuotes(quote.Id);
        // System.assertEquals(false, faultResponse.success);
        // quote.zqu__Opportunity__c = opp.Id;
        // update quote;
        // Response succesfyllResponse = QuoteOppQuoteRelatedListController.obtainFilesFromRelatedOpportunity(quote.Id);        
        // System.assertEquals(true, succesfyllResponse.success);
        Test.stopTest();
    }

    // @isTest
    // static void deleteFileTest(){
    //     ContentVersion cvPdf = [SELECT Id FROM ContentVersion LIMIT 1];
    //     Test.startTest();
    //     QuoteOppFilesRelatedListController.deleteFile(cvPdf.Id);        
    //     Test.stopTest();
    // }
}
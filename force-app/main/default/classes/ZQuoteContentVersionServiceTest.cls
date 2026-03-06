@isTest
public with sharing class ZQuoteContentVersionServiceTest {
    @testSetup
    static void testSetup(){        
        
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
        zqu__Quote__c q = TestDataFactory.CreateZQuote (o,c);
        q.zqu__Currency__c = 'USD';
        q.zqu__Status__c = 'Terms Approved';
        q.Contract_Start_Upon__c = 'Signature date';
        q.zqu__SubscriptionType__c = 'New Subscription';
        q.zqu__PaymentMethod__c = 'Credit Card';
        insert q;
        ContentVersion cvPdf = TestDataFactory.createContentVersionWithType('pdf');
        insert cvPdf;

    }

    @isTest
    static void testInsert(){
        zqu__Quote__c quoteBefore = [SELECT Id
                                    , zqu__Status__c
                                    , Contract_Start_Upon__c
                                    , zqu__StartDate__c
                                    , zqu__Service_Activation_Date__c
                                    , zqu__Customer_Acceptance_Date__c
                                    , zqu__TermStartDate__c
                                    , Last_Contract_Date__c
                                FROM zqu__Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContentVersion cvPdf = [SELECT Id, ContentDocumentId, Zuora_Quote__c, Signature_date__c FROM ContentVersion LIMIT 1];
        cvPdf.Zuora_Quote__c = quoteBefore.Id;
        List<ContentVersion> cvList = new  List<ContentVersion>();
        cvList.add(cvPdf);

        System.assertEquals(quoteBefore.zqu__StartDate__c, null);
        System.assertEquals(quoteBefore.Last_Contract_Date__c, null);

        Test.startTest();
        // update cvPdf;
        //ZQuoteContentVersionService.changeQuotefields(cvList);
        ZQuoteContentVersionService.setSignatureDate(cvList,Date.today());
        ZQuoteContentVersionService.changeQuotefields(cvList,true);
        ZQuoteContentVersionService.setLastSignatureDate(cvList);
        Test.stopTest();

        zqu__Quote__c quoteAfter = [SELECT Id,zqu__StartDate__c,Last_Contract_Date__c FROM zqu__Quote__c LIMIT 1];
        System.assertEquals(quoteAfter.zqu__StartDate__c, cvPdf.Signature_date__c);
        System.assertEquals(quoteAfter.Last_Contract_Date__c, cvPdf.Signature_date__c);
    }

    /* @isTest
    static void testsetLastSignatureDatew(){
        zqu__Quote__c quoteBefore = [SELECT Id
                                    , zqu__Status__c
                                    , Contract_Start_Upon__c
                                    , zqu__StartDate__c
                                    , zqu__Service_Activation_Date__c
                                    , zqu__Customer_Acceptance_Date__c
                                    , zqu__TermStartDate__c
                                    , Last_Contract_Date__c
                                FROM zqu__Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ContentVersion cvPdf = [SELECT Id, ContentDocumentId, Zuora_Quote__c, Signature_date__c FROM ContentVersion LIMIT 1];
        cvPdf.Zuora_Quote__c = quoteBefore.Id;
        List<ContentVersion> cvList = new  List<ContentVersion>();
        cvList.add(cvPdf);

        System.assertEquals(quoteBefore.zqu__StartDate__c, null);

        Test.startTest();
        ZQuoteContentVersionService.changeQuotefields(cvList);
        Test.stopTest();

        zqu__Quote__c quoteAfter = [SELECT Id,zqu__StartDate__c FROM zqu__Quote__c LIMIT 1];
        System.assertEquals(quoteAfter.zqu__StartDate__c, cvPdf.Signature_date__c);
    } */
}
@isTest
public with sharing class CustomCpqSelectProductControllerTest {
    @TestSetup
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
        insert quote;
    }

    @isTest
	private static void testControllerConstructor() {
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c FROM zqu__Quote__c LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        PageReference createQuote = Page.CustomCpqSelectProductPage;
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('id', quote.Id);
	  	createQuote.getParameters().put('quoteType', 'Subscription');
        createQuote.getParameters().put('stepNumber', '3');
        Test.setCurrentPage(createQuote);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        Test.startTest();
        CustomCpqSelectProductController customCpqSelectProductController = new CustomCpqSelectProductController(sc);
        customCpqSelectProductController.fixProductDiscountPercentage();
        Test.stopTest();
    }

    @isTest
    static void renewalCalculationTest(){
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        CustomCpqSelectProductController.renewalCalculation(quote.Id);
        Test.stopTest();
    }

    @isTest
    static void redirectToRecordPage(){
        zqu__Quote__c quote = [SELECT Id,RecordTypeId,zqu__QuoteBusinessType__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.CustomCpqSelectProductPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',quote.id);
        ApexPages.currentPage().getParameters().put('quoteType','Subscription');
        ApexPages.StandardController sc = new ApexPages.standardController(quote);
        CustomCpqSelectProductController controller = new CustomCpqSelectProductController(sc);
        controller.redirectToRecordPage();
        Test.stopTest();
    }
}
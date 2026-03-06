@isTest
public with sharing class CustomEditQuoteDetailsControllerTest {
    
    @TestSetup
    static void setup(){
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS();
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();     
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
    }

    @isTest
	private static void testControllerConstructor() {
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;  
        Test.startTest();
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
        quote.zqu__PaymentMethod__c = 'Other';
        quote.RecordTypeId = Utility.getRecordTypeIdForObject(quote.getSObjectType(), 'Default');
        insert quote;

        PageReference createQuote = Page.CustomEditQuoteDetailsPage;
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('id', quote.Id);
	  	createQuote.getParameters().put('quoteType', 'Subscription');
        Test.setCurrentPage(createQuote);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        CustomEditQuoteDetailsController customEditQuoteDetailsControllerTest = new CustomEditQuoteDetailsController(sc);
        CustomEditQuoteDetailsController.correctProductsIfPackageMgration(quote.Id, 'No');
        Test.stopTest();
    }
}
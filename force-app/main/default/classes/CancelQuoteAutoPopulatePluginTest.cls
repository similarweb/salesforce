@isTest
public class CancelQuoteAutoPopulatePluginTest {
    @isTest
    private static void test(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Account a = TestObjectCreator.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestObjectCreator.CreateOpportunity (a);
        insert opp;                
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
        quote.zqu__PaymentMethod__c = 'Other';
        quote.zqu__CancellationDate__c = Date.today();
        quote.zqu__Amendment_Name__c = 'TestNameTestNameTestNameTestNameTestNameTestNameTestNameTestNameTestNameTest NameTestNameTestNameT estNameTestNameTestNameTestName ';
        insert quote;

        CancelQuoteAutoPopulatePlugin controller = new CancelQuoteAutoPopulatePlugin();
        PageReference createQuote = Page.zqu__CreateQuote;
        createQuote.getParameters().put('oppId', opp.Id);
        createQuote.getParameters().put('quoteType', 'Subscription');
        createQuote.getParameters().put('stepNumber', '2');
        Test.setCurrentPage(Page.zqu__CreateQuote);

        Test.startTest();
        controller.populateDefaultFieldValue(quote, new zqu.PropertyComponentController.ParentController());
        Test.stopTest();
    }
}
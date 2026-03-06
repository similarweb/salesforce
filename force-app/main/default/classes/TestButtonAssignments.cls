/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestButtonAssignments {

	@TestSetup
	static void setup() {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
		TestDataFactory.createInferredSolutionSettings_CS();
	}

    static testMethod void buttonsControllersTest() {
        // TO DO: implement unit test
        CSSettings__c cs = TestObjectCreator.CreateCSSettings();
    insert cs;
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
		Test.startTest();
		ButtonsController.assignSDR(String.valueof(a.Id));
		ButtonsController.assignSales(String.valueof(a.Id));
		ButtonsController.assignSDR(String.valueof(a.Id));
		// ButtonsController.assignSDRLeads(String.valueof(l.Id));
		ButtonsController.assignCSM(String.valueof(a.Id));
		ButtonsController.newQuoteServerSide(String.valueof(opp.Id),false);
		ButtonsController.newQuoteServerSide(String.valueof(opp.Id),true);
		ButtonsController.openModalServerSide(String.valueof(opp.Id));
		ButtonsController.finQuote(String.valueof(quote.Id));
		AuraResponse.selfTest();
		Test.stopTest();
	}
	
	@isTest
	static void quoteInitTest() {
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
		Test.startTest();
		ButtonsController.assignSDRLeads(a.Id);
		ButtonsController.quoteInit(quote.id);
		Test.stopTest();
    }
}
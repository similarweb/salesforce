@isTest
public with sharing class ZuoraBillingAccountDomainTest {
    
    @TestSetup
	static void setup() {
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
    static void test(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(acc);
        Test.startTest();
        insert billAcc;
        billAcc.Subsidiary__c = 'TestSubsidiary2';
        update billAcc;
        Test.stopTest();
    }
}
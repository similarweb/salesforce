@isTest
public with sharing class UpdatePaymentTypeBatchTest {
    @testSetup
    public static void setup(){    
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
        quote.zqu__ZuoraAccountID__c = '12345678901234567890123456789012';
        insert quote;
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
        insert billAcc;
        Zuora__Payment__c payment = TestDataFactory.createPayment(billAcc);
        insert payment;
    }

    @isTest 
    public static void testBatch(){
        Test.startTest();
        Id batchJobId = Database.executeBatch(new UpdatePaymentTypeBatch());
        Test.stopTest();
        zqu__Quote__c q = [SELECT Id, Payment_Type__c FROM zqu__Quote__c];
        System.assertEquals('Credit Card', q.Payment_Type__c);
    }
}
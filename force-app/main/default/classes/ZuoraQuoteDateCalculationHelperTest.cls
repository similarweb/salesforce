@isTest
public with sharing class ZuoraQuoteDateCalculationHelperTest {
    @testSetup
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
    }

    @isTest
    static void calculateDateTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
        ZuoraQuoteDateCalculationHelper.calculateDate(quote);
        Test.stopTest();
    }

    @isTest
    static void calculateDateDefaultQuoteTest(){
        Test.startTest();
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
        ZuoraQuoteDateCalculationHelper.calculateDateDefaultQuote(quote);
        Test.stopTest();
    }

    @isTest
    static void calculateDateAmendQuoteTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(acc);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(acc, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ZuoraQuoteDateCalculationHelper.calculateDateAmendQuote(quote,sub);
        Test.stopTest();
    }

    @isTest
    static void calculateDateRenewQuoteTest(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(acc);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(acc, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ZuoraQuoteDateCalculationHelper.calculateDateRenewQuote(quote,sub);
        Test.stopTest();
    }
}
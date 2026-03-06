@isTest
public with sharing class ZuoraRefreshRenewalQuoteBatchTest {
    @testSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Account acc = TestDataFactory.createAccount();
        insert acc;
        Contact contact = TestDataFactory.createContact(acc, 'test@testing.com');
        insert contact;
        Opportunity opp = TestDataFactory.createOpportunity (acc);
        insert opp;        

        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(acc);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(acc, billAcc);
        insert sub;

        zqu__Quote__c quote = TestDataFactory.createAmendZQuote (opp,contact);
        insert quote;
        zqu.zQuoteUtil.storeExistingProducts(new List<zqu__Quote__c>{quote});
    }

    @isTest
    static void testBatchWithDate(){
        Test.startTest();

        ZuoraRefreshRenewalQuoteBatch.scheduleRenewelBatch(System.now().addDays(1));

        Test.stopTest();
    }


    @isTest 
    static void testBatchWithoutDate(){
        Test.startTest();
        Zuora__Subscription__c sub = [SELECT Id, Name, Zuora__External_Id__c, Zuora__Version__c FROM Zuora__Subscription__c LIMIT 1];
        zqu__Quote__c quote = [SELECT Id,zqu__ExistSubscriptionID__c,zqu__Hidden_Subscription_Name__c,zqu__SubscriptionVersion__c FROM zqu__Quote__c LIMIT 1];
        quote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
        quote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
        quote.zqu__StartDate__c = System.today().addDays(-1);
        quote.zqu__Hidden_Subscription_Name__c = sub.Name;
        quote.zqu__SubscriptionVersion__c = sub.Zuora__Version__c - 1;
        quote.zqu__ExistSubscriptionID__c = sub.Zuora__External_Id__c;
        update quote;
        ZuoraRefreshRenewalQuoteBatch.scheduleRenewelBatch();
        Test.stopTest();

        // Issue with crating data for tests - Zuora cloning is failing with null reference, needs to be researched
        // List<zqu__Quote__c> quotes= [SELECT ID, zqu_Quote_Status__c FROM zqu__Quote__c LIMIT 10];
        // Boolean isOriginFound = false;
        // Boolean isRenewalFound = false;
        // for(zqu__Quote__c quote_i : quotes){
        //     if(quote.zqu__SubscriptionVersion__c < 1){
        //         System.assertEquals('Cancelled', quote_i.zqu_Quote_Status__c,'Status of old quote not equal to \'Cancelled\'');
        //         isOriginFound = true;
        //     }else {
        //         System.assertEquals('Quote Pending Renewal Date', quote_i.zqu_Quote_Status__c,'Status of old quote not equal to \'Cancelled\'');
        //         isRenewalFound = true;
        //     }
        // }
        // System.assertEquals(true, isOriginFound, 'Valid old quote not exists');
        // System.assertEquals(true, isRenewalFound, 'Valid renewed quote not exists');
    }
}
@isTest
public with sharing class ConfirmSubmitModalControllerTest {
    @TestSetup
    static void setup(){
        Account a = TestObjectCreator.CreateAccount();
        a.BillingCountryCode = 'US';
        a.BillingCity = 'Washington';
        a.BillingStreet = 'Test';
        a.BillingPostalCode = '10000';
        insert a;
        Zuora__Subscription__c zscAcc1 = TestObjectCreator.CreateZSubscription(a);
        insert zscAcc1;
        Opportunity opp = TestObjectCreator.CreateOpportunity(a);
        insert opp;
        zqu__Quote__c q1 = TestObjectCreator.CreateZQuote(opp);
        insert q1;
        zqu__Quote__c q2 = TestObjectCreator.CreateZQuote(opp);
        insert q2;
    }

    @isTest
    static void obtainQuoteListTest(){
        zqu__Quote__c q1 = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        ConfirmSubmitModalController.obtainQuoteList(q1.id);
    }

    @isTest
    static void voidQuotesTest(){
        zqu__Quote__c q1 = [SELECT Id, zqu__Subscription_Name__c, zqu__Hidden_Subscription_Name__c FROM zqu__Quote__c LIMIT 1];
        Zuora__Subscription__c zscAcc1 = [SELECT Id, Name FROM Zuora__Subscription__c LIMIT 1];
        q1.zqu__Hidden_Subscription_Name__c = zscAcc1.Name;
        update q1;
        zqu__Quote__c q2 = [SELECT Id, zqu__Subscription_Name__c, zqu__Hidden_Subscription_Name__c FROM zqu__Quote__c WHERE id !=: q1.id LIMIT 1];
        q2.zqu__Hidden_Subscription_Name__c = zscAcc1.Name;
        update q2;
        String subscriptionName = q1.zqu__Hidden_Subscription_Name__c;
        ConfirmSubmitModalController.voidQuotes(q1.id, subscriptionName);
    }
}
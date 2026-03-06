@isTest
public with sharing class ZuoraQuoteStatusCalculatorTest {
   
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
    static void approvalOther(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(true);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Other';
        quote.zqu_Quote_Status__c = 'New';
        insert quote;
        Test.startTest();
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote.Id);
        zqsc = new ZuoraQuoteStatusCalculator(quote);
        zqsc.checkIfReadOnly();
        zqsc.correctStatusIfWrong();
        quote.zqu_Quote_Status__c = zqsc.initialStatus();
        quote.zqu_Quote_Status__c = zqsc.nextStatus();
        zqsc.getCurrentListStep();
        update quote;
        quote.zqu_Quote_Status__c = zqsc.previousStatus();
        update quote;
        Test.stopTest();
    }

    @isTest
    static void approvalCreditCard(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(true);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Credit Card';
        insert quote;
        Test.startTest();
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        zqsc.checkIfReadOnly();
        zqsc.correctStatusIfWrong();
        quote.zqu_Quote_Status__c = zqsc.initialStatus();
        quote.zqu_Quote_Status__c = zqsc.nextStatus();
        update quote;
        quote.zqu_Quote_Status__c = zqsc.previousStatus();
        update quote;
        Test.stopTest();
    }

    @isTest
    static void approvalWireTransfer(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(true);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Wire Transfer';
        insert quote;
        Test.startTest();
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        zqsc.checkIfReadOnly();
        zqsc.correctStatusIfWrong();
        quote.zqu_Quote_Status__c = zqsc.initialStatus();
        quote.zqu_Quote_Status__c = zqsc.nextStatus();
        update quote;
        quote.zqu_Quote_Status__c = zqsc.previousStatus();
        update quote;
        Test.stopTest();
    }

    @isTest
    static void nonapprovalOther(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(false);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
        Test.startTest();
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote.Id);
        zqsc = new ZuoraQuoteStatusCalculator(quote);
        zqsc.checkIfReadOnly();
        zqsc.correctStatusIfWrong();
        quote.zqu_Quote_Status__c = zqsc.initialStatus();
        quote.zqu_Quote_Status__c = zqsc.nextStatus();
        update quote;
        quote.zqu_Quote_Status__c = zqsc.previousStatus();
        update quote;
        Test.stopTest();
    }

    @isTest
    static void nonapprovalCreditCard(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(false);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Credit Card';
        insert quote;
        Test.startTest();
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        zqsc.checkIfReadOnly();
        zqsc.correctStatusIfWrong();
        quote.zqu_Quote_Status__c = zqsc.initialStatus();
        quote.zqu_Quote_Status__c = zqsc.nextStatus();
        update quote;
        quote.zqu_Quote_Status__c = zqsc.previousStatus();
        update quote;
        Test.stopTest();
    }

    @isTest
    static void nonapprovalWireTransfer(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(false);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu__PaymentMethod__c = 'Wire Transfer';
        insert quote;
        Test.startTest();
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        zqsc.checkIfReadOnly();
        zqsc.correctStatusIfWrong();
        quote.zqu_Quote_Status__c = zqsc.initialStatus();
        quote.zqu_Quote_Status__c = zqsc.nextStatus();
        update quote;
        quote.zqu_Quote_Status__c = zqsc.previousStatus();
        update quote;
        Test.stopTest();
    }

    @isTest
    static void addLegalFlowStatusesTest(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(false);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.zqu_Quote_Status__c = 'Approved By Billing';
        insert quote;

        Test.startTest();
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        Test.stopTest();
    }

    @isTest
    static void exceptionTest(){
        insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(false);
        Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        Test.startTest();
        quote.zqu__SubscriptionType__c = 'Amend Subscription';
        quote.zqu__QuoteBusinessType__c = null;
        try{
            ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        } catch(ZuoraQuoteStatusCalculator.ValueIsMissingException e){
            System.assert(e.getMessage() == 'Quote business type is missing');
        }

        quote.zqu__SubscriptionType__c = null;
        try{
            ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        } catch(ZuoraQuoteStatusCalculator.ValueIsMissingException e){
            System.assert(e.getMessage() == 'Subscription Type is missing');
        }
        quote.RecordTypeId = null;
        try{
            ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        } catch(ZuoraQuoteStatusCalculator.ValueIsMissingException e){
            System.assert(e.getMessage() == 'Record type id is missing');
        }
        Test.stopTest();
    }
}
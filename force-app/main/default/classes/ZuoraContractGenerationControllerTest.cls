@isTest
public with sharing class ZuoraContractGenerationControllerTest {
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
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Add_Finance_Information__c = false;
        insert quote;
    }
    
    @isTest
    static void generatePreviewContractTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        ZuoraContractGenerationController.generatePreviewContract(quote.Id,true);
    }

    @isTest
    static void generatePreviewContractFaultTest(){
        MockUtil.isSuccessfull = false;
        ZuoraContractGenerationController.generatePreviewContract(null,true);
    }

    @isTest
    static void obtainAndSaveContractTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        ZuoraContractGenerationController.obtainAndSaveContract(quote.Id,'','','',true);
    }
    @isTest
    static void obtainAndSaveContractFaultTest(){
        MockUtil.isSuccessfull = false;
        ZuoraContractGenerationController.obtainAndSaveContract(null,'','','',true);
    }
    @isTest
    static void checkIfLegalRequestExistTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        ZuoraContractGenerationController.checkIfLegalRequestExist(quote.id);
    }
    @isTest
    static void checkIfLegalRequestExistFaultTest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='sometrestuser' + DateTime.now().getTime() + '@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser'+ DateTime.now().getTime() +'@testorg.com', Admin_Console__c='CLC');

        System.runAs(u) {
            zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
            ZuoraContractGenerationController.checkIfLegalRequestExist(null);
        }
    }
    @isTest
    static void sendToDocuSignTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        ZuoraContractGenerationController.sendToDocuSign(quote.id);
    }
    @isTest
    static void sendToDocuSignFaultTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
        ZuoraContractGenerationController.sendToDocuSign(null);
    }

    @isTest
    static void checkForASRequestsTest(){
        zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1]; 
        Test.startTest();
        ZuoraContractGenerationHelper.checkForASRequests(quote.Id, 'Generate Contract');
        ZuoraContractGenerationController.checkForASRequests(quote.Id);
        Test.stopTest();
    }
}
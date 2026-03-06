@isTest
public with sharing class DocuSignStatusDomainTest {

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
        insert quote;
        ContentVersion cv = TestDataFactory.createContentVersion();
        cv.Zuora_Quote__c = quote.Id;
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl1 = TestDataFactory.createContentDocumentLink(quote.Id,cv.ContentDocumentId);
        ContentDocumentLink cdl2 = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert new List<ContentDocumentLink> {cdl1,cdl2}; 
        dsfs__DocuSign_Status__c dsStatus = TestDataFactory.createDocuSignStatus(opp);
        insert dsStatus;
        dsfs__DocuSign_Envelope__c dsEnvelop = TestDataFactory.createDocuSignEnvelop();
        insert dsEnvelop;
        dsfs__DocuSign_Envelope_Document__c dsDocument = TestDataFactory.createDocuSignDocument(dsEnvelop.Id,cv.Id);
        insert dsDocument;
    }

    @isTest
    static void test(){
        Test.startTest();
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id,dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c LIMIT 1];
        dsStatus.dsfs__Envelope_Status__c = DocuSignStatusDomain.DOCUSIGN_SIGNED_STATUS;
        update dsStatus;
        Test.stopTest();
    }
}
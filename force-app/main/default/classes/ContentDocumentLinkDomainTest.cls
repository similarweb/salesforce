@isTest
public with sharing class ContentDocumentLinkDomainTest {
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
        dsfs__DocuSign_Status__c dsStatus = TestDataFactory.createDocuSignStatus(opp);
        dsStatus.Zuora_Quote__c = quote.Id;
        insert dsStatus;
    }

    @isTest
    static void testAfterInsert(){
        Test.startTest();
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id FROM dsfs__DocuSign_Status__c LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(dsStatus.Id,cv.ContentDocumentId);
        insert cdl;
        Test.stopTest();
    }

    @isTest
    public static void validateQuoteSendToDocuSignTest(){
        zqu__Quote__c quote = [SELECT id, Send_To_DocuSign_Flow__c FROM zqu__Quote__c LIMIT 1];
        quote.Send_To_DocuSign_Flow__c = true;
        Test.startTest();
        update quote;
        ContentVersion cv = [SELECT Id,ContentDocumentId FROM ContentVersion LIMIT 1];
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id FROM dsfs__DocuSign_Status__c LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(dsStatus.Id,cv.ContentDocumentId);
        try{
            insert cdl;
        }
        catch(Exception e){
            System.System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void docuSignEnvelopeTest(){
        zqu__Quote__c quote = [SELECT id, Send_To_DocuSign_Flow__c FROM zqu__Quote__c LIMIT 1];
        dsfs__DocuSign_Envelope__c dsEnvelop = TestDataFactory.createDocuSignEnvelop();
        dsEnvelop.dsfs__Source_Object__c = quote.id;
        insert dsEnvelop;
        ContentVersion cv = [SELECT id, ContentDocumentId FROM ContentVersion LIMIT 1];

        Test.startTest();
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(dsEnvelop.id, cv.ContentDocumentId);
        try{
            insert cdl;
        }
        catch(Exception e){
            System.assertEquals('Oops! Looks like you\'re trying to send through DocuSign a document that wasn\'t generated in Q2C. Please send the generated contract attached to the quote or have the Legal team review your contract and approve it for submission. For any questions please reach out to salesops@similarweb.com', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void docuSignEnvelopeListTest(){
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        zqu__Quote__c quote = [SELECT id, Send_To_DocuSign_Flow__c FROM zqu__Quote__c LIMIT 1];
        dsfs__DocuSign_Envelope__c dsEnvelop = TestDataFactory.createDocuSignEnvelop();
        dsEnvelop.dsfs__Source_Object__c = quote.id;
        insert dsEnvelop;
        dsfs__DocuSign_Envelope__c dsEnvelop2 = TestDataFactory.createDocuSignEnvelop();
        dsEnvelop2.dsfs__Source_Object__c = quote.id;
        insert dsEnvelop2;
        ContentVersion cv = [SELECT id, ContentDocumentId FROM ContentVersion LIMIT 1];

        Test.startTest();
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(dsEnvelop.id, cv.ContentDocumentId);
        ContentDocumentLink cdl2 = TestDataFactory.createContentDocumentLink(dsEnvelop2.id, cv.ContentDocumentId);
        ContentDocumentLinkList.add(cdl);
        ContentDocumentLinkList.add(cdl2);
        try{
            insert ContentDocumentLinkList;
        }
        catch(Exception e){
            System.assertEquals('Oops! Looks like you\'re trying to send through DocuSign a document that wasn\'t generated in Q2C. Please send the generated contract attached to the quote or have the Legal team review your contract and approve it for submission. For any questions please reach out to salesops@similarweb.com', e.getMessage());
        }
        Test.stopTest();
    }
}
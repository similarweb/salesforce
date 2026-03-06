@isTest
public with sharing class DocuSignRecipientStatusDomainTest {
    
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
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus = TestDataFactory.createDocuSignRecipientStatus(dsStatus);
        insert dsRecipientStatus;
        dsfs__DocuSign_Envelope__c dsEnvelop = TestDataFactory.createDocuSignEnvelop();
        insert dsEnvelop;
        dsfs__DocuSign_Envelope_Document__c dsDocument = TestDataFactory.createDocuSignDocument(dsEnvelop.Id,cv.Id);
        insert dsDocument;
    }

    @isTest
    static void testUpdate(){
        Test.startTest();
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus = [SELECT Id,dsfs__Date_Signed__c FROM dsfs__DocuSign_Recipient_Status__c LIMIT 1];
        dsRecipientStatus.dsfs__Date_Signed__c = Datetime.now();
        update dsRecipientStatus;
        Test.stopTest();
    }

    @isTest
    static void testInsert(){
        List<dsfs__DocuSign_Status__c> dsStatus = [SELECT Id FROM dsfs__DocuSign_Status__c];
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus = TestDataFactory.createDocuSignRecipientStatus(dsStatus[0]);
        insert dsRecipientStatus;
    }

    @isTest
    static void testUpdateFailed(){
        Test.startTest();
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus = [SELECT Id,dsfs__Date_Signed__c FROM dsfs__DocuSign_Recipient_Status__c LIMIT 1];
        dsRecipientStatus.dsfs__Date_Signed__c = null;
        update dsRecipientStatus;
        Test.stopTest();
    }

    @isTest
    static void fewRecipientWithSameRoutingOrderTest(){
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id FROM dsfs__DocuSign_Status__c LIMIT 1];
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus1 = [SELECT Id,dsfs__Date_Signed__c FROM dsfs__DocuSign_Recipient_Status__c LIMIT 1];
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus2 = TestDataFactory.createDocuSignRecipientStatus(dsStatus);
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus3 = TestDataFactory.createDocuSignRecipientStatus(dsStatus);
        dsRecipientStatus2.dsfs__DocuSign_Routing_Order__c = 1;
        dsRecipientStatus2.dsfs__Recipient_Status__c = 'Sent';
        dsRecipientStatus3.dsfs__DocuSign_Routing_Order__c = 2;
        dsRecipientStatus3.dsfs__Recipient_Status__c = 'Sent';
        insert dsRecipientStatus2;
        insert dsRecipientStatus3;

        Test.startTest();
        dsRecipientStatus2.dsfs__Recipient_Status__c = 'Completed';
        update dsRecipientStatus2;
        dsRecipientStatus3.dsfs__Recipient_Status__c = 'Completed';
        update dsRecipientStatus3;
        Test.stopTest();
    }

    @isTest
    static void updateDateFieldsOfRelatedQuoteTest(){
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id FROM dsfs__DocuSign_Status__c LIMIT 1];
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus1 = [SELECT Id,dsfs__Date_Signed__c FROM dsfs__DocuSign_Recipient_Status__c LIMIT 1];
        dsRecipientStatus1.dsfs__DocuSign_Recipient_Email__c = 'test2@similarweb.com';
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus2 = TestDataFactory.createDocuSignRecipientStatus(dsStatus);
        dsfs__DocuSign_Recipient_Status__c dsRecipientStatus3 = TestDataFactory.createDocuSignRecipientStatus(dsStatus);
        dsRecipientStatus2.dsfs__DocuSign_Routing_Order__c = 1;
        dsRecipientStatus2.dsfs__Recipient_Status__c = 'Sent';
        dsRecipientStatus2.dsfs__DocuSign_Recipient_Email__c = 'test@similarweb.com';
        dsRecipientStatus2.Recipient_Type__c = 'Signer';
        dsRecipientStatus3.dsfs__DocuSign_Routing_Order__c = 2;
        dsRecipientStatus3.dsfs__Recipient_Status__c = 'Sent';
        dsRecipientStatus3.Recipient_Type__c = 'Signer';
        dsRecipientStatus3.dsfs__DocuSign_Recipient_Email__c = 'test3@similarweb.com';
        insert dsRecipientStatus2;
        insert dsRecipientStatus3;

        Test.startTest();

        dsRecipientStatus2.dsfs__Recipient_Status__c = 'Completed';
        dsRecipientStatus3.dsfs__Recipient_Status__c = 'Completed';
        dsRecipientStatus2.dsfs__Date_Signed__c = Datetime.now();
        dsRecipientStatus3.dsfs__Date_Signed__c = Datetime.now();
        List<dsfs__DocuSign_Recipient_Status__c> recipToUpdateList = new List<dsfs__DocuSign_Recipient_Status__c>();
        recipToUpdateList.add(dsRecipientStatus1);
        recipToUpdateList.add(dsRecipientStatus2);
        recipToUpdateList.add(dsRecipientStatus3);
        update recipToUpdateList;

        Set<Id> parentStatusIdSet = new Set<Id>();
        parentStatusIdSet.add(dsStatus.Id);
        DocuSignZuoraQuoteHelper.updateDateFieldsOfRelatedQuote(parentStatusIdSet);
        Test.stopTest();
    }

    @isTest
    static void obtainQuoteIdsForUpdateTest(){
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id FROM dsfs__DocuSign_Status__c LIMIT 1];
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        Test.startTest();
        update dsStatus;
        Test.stopTest();
    }
}
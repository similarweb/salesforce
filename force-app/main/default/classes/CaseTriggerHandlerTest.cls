@isTest
private class CaseTriggerHandlerTest {
  @testSetup
  static void testSetup() {
    Utils.CodeOff = true;
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Account a = TestDataFactory.createAccount();
    a.billingcountryCode = 'US';
    insert a;
    List<Contact> contacts = new List<Contact>();
    Contact c2 = TestDataFactory.createContact(a, 'test2@testing.com');
    contacts.add(c2);
    Contact c3 = TestDataFactory.createContact(a, 'test3@testing.com');

    contacts.add(c3);
    insert contacts;
    Opportunity o = TestDataFactory.createOpportunity(a);
    insert o;
    List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
    zqu__Quote__c q = TestDataFactory.createZQuote(o);
    q.zqu__Certificate_ID__c = '1111';
    q.zqu__BillToContact__c = c2.Id;
    q.zqu__SoldToContact__c = c3.Id;
    quotes.add(q);
    insert quotes;
  }

  //    @isTest
  //    static void testUpdateRelatedQuoteOnCreate() {
  //        // Step 1: Setup Test Data
  //        Id dealDeskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Desk').getRecordTypeId();
  //
  //        // Create a related Quote
  //        zqu__Quote__c testQuote = [SELECT Id FROM zqu__Quote__c];
  //
  //        // Create a Case with a related Quote and Deal Desk record type
  //
  //
  //        // Insert the ContentVersion
  //        ContentVersion contentVersion = new ContentVersion(
  //                Title = 'Test Document',
  //                PathOnClient = 'TestDocument.pdf',
  //                VersionData = Blob.valueOf('Test Document Content')
  //        );
  //        insert contentVersion;
  //
  //// Retrieve the ContentVersion to get its associated ContentDocumentId
  //        ContentVersion insertedVersion = [
  //                SELECT Id, ContentDocumentId
  //                FROM ContentVersion
  //                WHERE Id = :contentVersion.Id
  //        ];
  //
  //// Use the ContentDocumentId for further processing
  //        ContentDocumentLink contentLink = new ContentDocumentLink(
  //                LinkedEntityId = testQuote.Id, // Replace with the related record ID
  //                ContentDocumentId = insertedVersion.ContentDocumentId,
  //                ShareType = 'V'
  //        );
  //        insert contentLink;
  //
  //        Test.startTest();
  //        Case testCase = new Case(
  //                Subject = 'New Case',
  //                Status = 'New',
  //                Type = 'Question',
  //                RecordTypeId = dealDeskRecordTypeId,
  //                Quote__c = testQuote.Id,
  //                Green_Lane_Document__c = false
  //        );
  //        insert testCase;
  //        Test.stopTest();
  //
  //        // Step 2: Assertions
  //        zqu__Quote__c updatedQuote = [SELECT Id, Q2C_Green_Lane__c FROM zqu__Quote__c WHERE Id = :testQuote.Id];
  //        System.assertEquals(false, updatedQuote.Q2C_Green_Lane__c, 'The Quote should be updated with Q2C_Green_Lane__c = false');
  //    }

  //    @isTest
  //    static void testUpdateRelatedQuoteOnUpdate() {
  //        // Step 1: Setup Test Data
  //        Id dealDeskRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Desk').getRecordTypeId();
  //
  //        // Create a related Quote
  //        zqu__Quote__c testQuote = [SELECT Id FROM zqu__Quote__c];
  //
  //        // Insert the ContentVersion
  //        ContentVersion contentVersion = new ContentVersion(
  //                Title = 'Test Document',
  //                PathOnClient = 'TestDocument.pdf',
  //                VersionData = Blob.valueOf('Test Document Content')
  //        );
  //        insert contentVersion;
  //
  //// Retrieve the ContentVersion to get its associated ContentDocumentId
  //        ContentVersion insertedVersion = [
  //                SELECT Id, ContentDocumentId
  //                FROM ContentVersion
  //                WHERE Id = :contentVersion.Id
  //        ];
  //
  //// Use the ContentDocumentId for further processing
  //        ContentDocumentLink contentLink = new ContentDocumentLink(
  //                LinkedEntityId = testQuote.Id, // Replace with the related record ID
  //                ContentDocumentId = insertedVersion.ContentDocumentId,
  //                ShareType = 'V'
  //        );
  //        insert contentLink;
  //
  //        // Create Cases with the Deal Desk record type
  //        Case case1 = new Case(
  //                Subject = 'Case 1',
  //                Status = 'Completed',
  //                Type = 'Other',
  //                RecordTypeId = dealDeskRecordTypeId,
  //                Quote__c = testQuote.Id,
  //                Green_Lane_Document__c = true
  //        );
  //        Case case2 = new Case(
  //                Subject = 'Case 2',
  //                Status = 'In Progress',
  //                Type = 'Question',
  //                RecordTypeId = dealDeskRecordTypeId,
  //                Quote__c = testQuote.Id,
  //                Green_Lane_Document__c = false
  //        );
  //        insert new List<Case>{case1, case2};
  //
  //        // Update the Cases to trigger `updateRelatedQuoteOnUpdate`
  //        case2.Status = 'Completed';
  //        case2.Type = 'Other';
  //        case2.Green_Lane_Document__c = true;
  //
  //        Test.startTest();
  //        update case2;
  //        Test.stopTest();
  //
  //        // Step 2: Assertions
  //        zqu__Quote__c updatedQuote = [SELECT Id, Q2C_Green_Lane__c FROM zqu__Quote__c WHERE Id = :testQuote.Id];
  //        System.assertEquals(true, updatedQuote.Q2C_Green_Lane__c, 'The Quote should be updated with Q2C_Green_Lane__c = true');
  //    }
}

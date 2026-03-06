@isTest
public with sharing class QuoteOppRequestsRelatedListTest {
  @testSetup
  static void setup() {
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
    //  Account a = TestDataFactory.CreateAccount();
    //  a.billingcountry = 'Israel';
    //  insert a;
    //  Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    //  c.MailingCountry = 'Israel';
    // insert c;
    // Opportunity opp = TestDataFactory.CreateOpportunity (a);
    // opp.Type='New Sale';
    //insert opp;
    //Request__c rquest = TestDataFactory.createRequest(opp);
    // insert rquest;
    // zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
    //quote.zqu__PaymentMethod__c = 'Other';
    //insert quote;
    // ContentVersion cvPdf = TestDataFactory.createContentVersionWithType('pdf');
    //  insert cvPdf;
    //cvPdf = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cvPdf.Id LIMIT 1];
    //ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(quote.id,cvPdf.ContentDocumentId);
    //insert cdl;
  }

  @isTest
  static void obtainFilesFromRelatedOpportunityTest() {
    Test.startTest();
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'Israel';
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    opp.Type = 'New Sale';
    insert opp;
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    quote.zqu__PaymentMethod__c = 'Other';
    insert quote;
    Request__c rquest = TestDataFactory.createRequest(opp);
    insert rquest;
    QuoteOppRequestsRelatedListController.obtainRequestsFromRelatedOpportunity(
      quote.Id
    );
    Test.stopTest();
  }

  @isTest
  static void obtainRequestsFromRelatedQuoteTest() {
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'Israel';
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    opp.Type = 'New Sale';
    insert opp;

    Test.startTest();

    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    quote.zqu__PaymentMethod__c = 'Other';
    insert quote;
    Request__c rquest = TestDataFactory.createRequest(opp);
    rquest.RecordTypeId = '012b0000000cfDOAAY';
    rquest.Applicable_Quote__c = 'Yes';
    rquest.Quote__c = quote.id;
    insert rquest;
    QuoteOppRequestsRelatedListController.obtainRequestsFromRelatedQuote(
      quote.Id
    );
    Test.stopTest();
  }
}

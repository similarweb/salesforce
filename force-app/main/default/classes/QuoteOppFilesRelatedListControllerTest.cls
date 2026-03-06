@isTest
public with sharing class QuoteOppFilesRelatedListControllerTest {
  @testSetup
  static void setup() {
    String currencyCode = 'USD';
    Decimal exchangeRate = 1;
    Decimal actualExchangeRate = 0;
    Netsuite_Daily_Exchange_Rate__c netsuiteDailyExchangeRateSetting = new Netsuite_Daily_Exchange_Rate__c();
    netsuiteDailyExchangeRateSetting.Name = currencyCode;
    netsuiteDailyExchangeRateSetting.Currency_DDL__c = currencyCode;
    netsuiteDailyExchangeRateSetting.USD_Exchange_Rate__c = exchangeRate;
    insert netsuiteDailyExchangeRateSetting;
    Utils.CodeOff = true;
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    List<String> countries = TestObjectCreator.getCountries();
    Account a = TestObjectCreator.CreateAccount();
    a.billingcountry = countries[countries.size() - 1];
    insert a;
    Contact c = TestDataFactory.createContact(a, 'test@testing.com');
    c.MailingCountry = countries[countries.size() - 1];
    insert c;
    list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
    Opportunity o = TestObjectCreator.CreateOpportunity(a);
    insert o;
    zqu__Quote__c q = TestDataFactory.createZQuote(o, c);
    q.zqu__Currency__c = 'USD';
    q.zqu__Previewed_Total__c = 100001;
    insert q;
    ContentVersion cvPdf = TestDataFactory.createContentVersionWithType('pdf');
    insert cvPdf;
    cvPdf = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cvPdf.Id
      LIMIT 1
    ];
    ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(
      q.id,
      cvPdf.ContentDocumentId
    );
    insert cdl;
    Attachment att = TestDataFactory.createAttachment(q.Id);
    insert att;
  }

  @isTest
  static void obtainFilesFromRelatedOpportunityTest() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    Response faultResponse = QuoteOppFilesRelatedListController.obtainFilesFromRelatedOpportunity(
      quote.Id
    );
    // System.assertEquals(false, faultResponse.success);
    quote.zqu__Opportunity__c = opp.Id;
    update quote;
    Response succesfyllResponse = QuoteOppFilesRelatedListController.obtainFilesFromRelatedOpportunity(
      quote.Id
    );
    // System.assertEquals(true, succesfyllResponse.success);
    Test.stopTest();
  }

  @isTest
  static void deleteFileNotFoundTest() {
    ContentVersion file = [SELECT Id FROM ContentVersion LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    QuoteOppFilesRelatedListController.deleteFile(file.Id);
    Test.stopTest();
  }

  @isTest
  static void deleteFileContentDocumentTest() {
    ContentDocument file = [SELECT Id FROM ContentDocument LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    QuoteOppFilesRelatedListController.deleteFile(file.Id);
    Test.stopTest();
  }

  @isTest
  static void deleteFileAttachmentTest() {
    Attachment file = [SELECT Id FROM Attachment LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    QuoteOppFilesRelatedListController.deleteFile(file.Id);
    Test.stopTest();
  }

  @isTest
  static void editFileNotFoundTest() {
    ContentVersion file = [SELECT Id FROM ContentVersion LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    QuoteOppFilesRelatedListController.editFile(file.Id, 'test', 'test');
    Test.stopTest();
  }

  @isTest
  static void editFileContentDocumentTest() {
    ContentDocument file = [SELECT Id FROM ContentDocument LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    QuoteOppFilesRelatedListController.editFile(file.Id, 'test', 'test');
    Test.stopTest();
  }

  @isTest
  static void editFileAttachmentTest() {
    Attachment file = [SELECT Id FROM Attachment LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    QuoteOppFilesRelatedListController.editFile(file.Id, 'test', 'test');
    Test.stopTest();
  }

  @isTest
  static void validateQuoteStatusTest() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    Response resp = QuoteOppFilesRelatedListController.validateQuoteStatus(
      quote.Id,
      true
    );
    System.assert(resp.success);
    quote.zqu_Quote_Status__c = 'Sent To Zuora';
    update quote;
    resp = QuoteOppFilesRelatedListController.validateQuoteStatus(
      quote.Id,
      true
    );
    System.assert(!resp.success);
    Test.stopTest();
  }

  @isTest
  static void obtainFilesFromRelatedOpportunityWithRequestIdTest() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    quote.zqu__Opportunity__c = opp.Id;
    Request__c request = TestDataFactory.createRequest(opp);
    request.RecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName()
      .get('Technical_Solutions')
      .getRecordTypeId();

    Test.startTest();
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    update quote;
    insert request;
    Response failedResponse = QuoteOppFilesRelatedListController.obtainFilesFromRelatedOpportunity(
      request.Id
    );
    request.Quote__c = quote.id;
    update request;
    Response succesfyllResponse = QuoteOppFilesRelatedListController.obtainFilesFromRelatedOpportunity(
      request.Id
    );
    Test.stopTest();
  }
}

@isTest
with sharing class FileUploadController_Test {
  @testSetup
  static void testSetup() {
    Utils.CodeOff = true;
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    List<String> countries = TestObjectCreator.getCountries();
    Account a = TestObjectCreator.CreateAccount();
    a.billingcountry = countries[countries.size() - 1];
    insert a;
    Contact c = TestObjectCreator.CreateContact(
      a,
      'test' + TestObjectCreator.randomStream(9, 2) + '@testing.com'
    );
    c.MailingCountry = countries[countries.size() - 1];
    insert c;
    list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
    Opportunity o = TestObjectCreator.CreateOpportunity(a);
    insert o;
    zqu__Quote__c q = TestObjectCreator.CreateZQuote(o, c);
    q.zqu__Currency__c = 'USD';
    insert q;
    ContentVersion cvPdf = TestDataFactory.createContentVersionWithType('pdf');
    insert cvPdf;

    /* 
        cvPdf = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cvPdf.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(o.id,cvPdf.ContentDocumentId);
        insert cdl; */
  }

  @isTest
  static void testInsert() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    ContentVersion cvPdf = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      LIMIT 1
    ];
    ContentDocument cd = [SELECT Id, Title FROM ContentDocument LIMIT 1];
    Map<String, String> cdMap = new Map<String, String>();
    cdMap.put('documentId', cd.Id);
    List<Map<String, String>> jsn = new List<Map<String, String>>();
    jsn.add(cdMap);
    String jsonStr = JSON.serialize(jsn);

    Test.startTest();
    FileUploadController.setLookup(
      jsonStr,
      (String) quote.Id,
      (String) opp.Id,
      Date.today(),
      true
    );
    Test.stopTest();
  }

  @isTest
  static void updateQuoteToGreenLineTest() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
    ContentVersion cvPdf = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      LIMIT 1
    ];
    ContentDocument cd = [SELECT Id, Title FROM ContentDocument LIMIT 1];

    ContentVersion cvPdf2 = TestDataFactory.createContentVersion();
    cvPdf2.Origin = 'H';
    cvPdf2.Zuora_Quote__c = quote.Id;
    insert cvPdf2;
    cvPdf2 = [
      SELECT Id, ContentDocumentId, Title
      FROM ContentVersion
      WHERE Id = :cvPdf2.Id
    ];
    id linkedEntityId = quote.Id;
    ContentDocumentLink cd2 = new ContentDocumentLink(
      ContentDocumentId = cvPdf2.ContentDocumentId,
      LINKEDENTITYID = linkedEntityId
    );
    insert cd2;

    Map<String, String> cdMap = new Map<String, String>();
    cdMap.put('documentId', cd.Id);
    List<Map<String, String>> jsn = new List<Map<String, String>>();
    jsn.add(cdMap);
    String jsonStr = JSON.serialize(jsn);

    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    User u = new User(
      Alias = 'standt',
      Email = 'sometrestuser' + DateTime.now().getTime() + '@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com',
      Admin_Console__c = 'CLC'
    );

    Test.startTest();
    Request__c rquest = TestDataFactory.createRequest(opp);
    rquest.Quote__c = quote.id;
    rquest.RecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName()
      .get('Technical_Solutions')
      .getRecordTypeId();
    rquest.Status__c = 'Completed';
    rquest.Green_Lane_Document__c = true;
    rquest.Applicable_Quote__c = 'Yes';
    insert rquest;

    System.assertNotEquals(null, rquest.id);
    System.runAs(u) {
      FileUploadController.setLookup(
        jsonStr,
        (String) quote.Id,
        (String) opp.Id,
        Date.today(),
        true
      );
    }
    Test.stopTest();
  }

  @isTest
  static void validateTest() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    quote.zqu__PaymentMethod__c = 'Other';
    quote.zqu_Quote_Status__c = 'Terms Pending';
    update quote;

    Test.startTest();
    try {
      FileUploadController.validate(quote.id, true);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
    }
    Test.stopTest();
  }
}

@isTest
public class QuoteContactFieldsUpdateTest {
  @testSetup
  static void testSetup() {
    Utils.CodeOff = true;
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    List<String> countries = TestObjectCreator.getCountries();
    Account a = TestDataFactory.createAccount();
    a.billingcountry = countries[countries.size() - 1];
    insert a;
    List<Contact> contacts = new List<Contact>();
    Contact c = TestDataFactory.createContact(a, 'test@testing.com');
    c.MailingCountry = countries[countries.size() - 1];
    c.Country_Code__c = 'UK';
    contacts.add(c);
    Contact c2 = TestDataFactory.createContact(a, 'test2@testing.com');
    c2.MailingCountry = countries[countries.size() - 1];
    c2.Country_Code__c = 'US';
    contacts.add(c2);
    Contact c3 = TestDataFactory.createContact(a, 'test3@testing.com');
    c3.MailingCountry = countries[countries.size() - 1];
    c3.Country_Code__c = 'FR';
    contacts.add(c3);
    insert contacts;
    Opportunity o = TestDataFactory.createOpportunity(a);
    insert o;
    List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
    zqu__Quote__c q = TestDataFactory.createZQuote(o);
    q.zqu__Certificate_ID__c = '1111';
    q.zqu__BillToContact__c = c.Id;
    q.zqu__SoldToContact__c = c.Id;
    quotes.add(q);
    zqu__Quote__c q2 = TestDataFactory.createZQuote(o);
    q2.zqu__BillToContact__c = c2.Id;
    q2.zqu__SoldToContact__c = c3.Id;
    quotes.add(q2);
    insert quotes;
  }

  @isTest
  static void testCheckBillEqualsSold() {
    Contact cont = [
      SELECT Id, Bill_To__c, Sold_To__c
      FROM Contact
      WHERE Country_Code__c = 'UK'
      LIMIT 1
    ];
    cont.Bill_To__c = false;
    cont.Sold_To__c = false;
    update cont;
    List<Id> qId = new List<Id>();
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    qId.add(quote.Id);

    Test.startTest();
    QuoteContactFieldsUpdate.checkAndUpdateSoldToBillTo(qId);
    Test.stopTest();

    zqu__Quote__c quoteAfter = [
      SELECT
        Id,
        zqu__BillToContact__c,
        zqu__SoldToContact__c,
        zqu__Certificate_ID__c,
        zqu__BillToContact__r.Bill_To__c,
        zqu__SoldToContact__r.Sold_To__c,
        zqu__SoldToContact__r.Country_Code__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    System.assertEquals('UK1111', quoteAfter.zqu__Certificate_ID__c);
    System.assertEquals(true, quoteAfter.zqu__SoldToContact__r.Sold_To__c);
    System.assertEquals(true, quoteAfter.zqu__BillToContact__r.Bill_To__c);
  }

  @isTest
  static void testSetCountryCode() {
    List<Id> qId = new List<Id>();
    zqu__Quote__c quote = [
      SELECT Id
      FROM zqu__Quote__c
      WHERE zqu__Certificate_ID__c = '1111'
      LIMIT 1
    ];
    qId.add(quote.Id);

    Test.startTest();
    QuoteContactFieldsUpdate.addCountryCodeToCertificateId(qId);
    Test.stopTest();

    zqu__Quote__c quoteAfter = [
      SELECT
        Id,
        zqu__BillToContact__c,
        zqu__SoldToContact__c,
        zqu__Certificate_ID__c
      FROM zqu__Quote__c
      WHERE Id = :quote.Id
      LIMIT 1
    ];
    System.assertEquals('UK1111', quoteAfter.zqu__Certificate_ID__c);
  }

  @isTest
  static void testCheckBillNull() {
    Contact cont = [
      SELECT Id, Bill_To__c, Sold_To__c
      FROM Contact
      WHERE Country_Code__c = 'UK'
      LIMIT 1
    ];
    cont.Bill_To__c = false;
    cont.Sold_To__c = false;
    update cont;
    List<Id> qId = new List<Id>();
    zqu__Quote__c quote = [
      SELECT Id, zqu__BillToContact__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    quote.zqu__BillToContact__c = null;
    update quote;
    qId.add(quote.Id);

    Test.startTest();
    QuoteContactFieldsUpdate.checkAndUpdateSoldToBillTo(qId);
    Test.stopTest();

    zqu__Quote__c quoteAfter = [
      SELECT
        Id,
        zqu__BillToContact__c,
        zqu__SoldToContact__c,
        zqu__Certificate_ID__c,
        zqu__SoldToContact__r.Sold_To__c,
        zqu__SoldToContact__r.Country_Code__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    System.assertEquals('UK1111', quoteAfter.zqu__Certificate_ID__c);
    System.assertEquals(true, quoteAfter.zqu__SoldToContact__r.Sold_To__c);
    System.assertEquals(null, quoteAfter.zqu__BillToContact__c);
  }

  @isTest
  static void testCheckBillNotEqualsSold() {
    Test.startTest();
    List<Contact> conts = [
      SELECT Id, Bill_To__c, Sold_To__c, Country_Code__c
      FROM Contact
    ];
    for (Contact cont : conts) {
      cont.Bill_To__c = false;
      cont.Sold_To__c = false;
    }
    update conts;

    System.debug('CONTS ' + conts);
    List<Id> qId = new List<Id>();
    List<zqu__Quote__c> quote = [
      SELECT
        Id,
        zqu__Certificate_ID__c,
        zqu__BillToContact__c,
        zqu__SoldToContact__c
      FROM zqu__Quote__c
      WHERE zqu__Certificate_ID__c = '12345'
    ];
    System.debug('QUOTE ' + quote);
    qId.add(quote[0].Id);

    QuoteContactFieldsUpdate.checkAndUpdateSoldToBillTo(qId);

    zqu__Quote__c quoteAfter = [
      SELECT
        Id,
        zqu__BillToContact__c,
        zqu__SoldToContact__c,
        zqu__Certificate_ID__c,
        zqu__BillToContact__r.Bill_To__c,
        zqu__SoldToContact__r.Sold_To__c,
        zqu__SoldToContact__r.Country_Code__c
      FROM zqu__Quote__c
      WHERE ID = :quote[0].Id
      LIMIT 1
    ];

    Test.stopTest();
    System.assertNotEquals(
      quoteAfter.zqu__SoldToContact__c,
      quoteAfter.zqu__BillToContact__c
    );
    System.assertEquals(true, quoteAfter.zqu__SoldToContact__r.Sold_To__c);
    System.assertEquals(true, quoteAfter.zqu__BillToContact__r.Bill_To__c);
  }
}

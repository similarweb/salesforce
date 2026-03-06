@isTest
public class QuoteRenewalSubmitBatchTest {
  @testSetup
  static void setup() {
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
    insert contacts;
    Opportunity o = TestDataFactory.createOpportunity(a);
    insert o;

    List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();

    for (Integer i = 0; i < 1; i++) {
      zqu__Quote__c q = TestDataFactory.createZQuote(o);
      // q.zqu__SubscriptionType__c = 'Amend Subscription';
      q.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
      q.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
      q.zqu__SoldToContact__c = contacts[0].Id;
      q.zqu__BillToContact__c = contacts[0].Id;
      q.zqu__StartDate__c = System.today().addDays(-1);
      quotes.add(q);
    }
    insert quotes;
  }

  @istest
  static void testBatch() {
    Test.startTest();

    QuoteRenewalSubmitBatch.executeBatch();

    Test.stopTest();
  }

  @istest
  static void testBatchWithDate() {
    Test.startTest();

    QuoteRenewalSubmitBatch.scheduleRenewelBatch(System.now().addDays(1));

    Test.stopTest();
  }

  @istest
  static void testBatchWithoutDate() {
    Test.startTest();
    String query = 'SELECT Id,zqu_Quote_Status__c FROM zqu__Quote__c WHERE zqu__QuoteBusinessType__c = \'Renewal (with/without upsell)\' AND zqu__StartDate__c = LAST_N_DAYS:7';
    List<sObject> sobjList = Database.query(query);
    System.debug(sobjList);
    QuoteRenewalSubmitBatch.scheduleRenewelBatch();

    Test.stopTest();

    List<zqu__Quote__c> quotes = [
      SELECT ID, zqu_Quote_Status__c
      FROM zqu__Quote__c
      LIMIT 10
    ];

    for (zqu__Quote__c quote : quotes) {
      // System.assertEquals('Sent To Zuora', quote.zqu_Quote_Status__c);
    }
  }
}

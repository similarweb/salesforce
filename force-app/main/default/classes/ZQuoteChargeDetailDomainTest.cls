@isTest
public class ZQuoteChargeDetailDomainTest {
  @TestSetup
  static void setup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    insert TestDataFactory.createBaseProductContract_CS();
    insert TestDataFactory.createBaseProductConfiguration_CS();
    insert TestDataFactory.createBaseProductControlling_CS();
    insert TestDataFactory.createBaseProductDependent_CS();
    insert TestDataFactory.createBaseProductDefaultAddon_CS();
    insert TestDataFactory.createBaseProductDynamicAddon_CS();
    insert TestDataFactory.createBaseProductNumOfUsers_CS();
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
    zqu__Quote__c q = TestDataFactory.createZQuote(o, c);
    insert q;
    zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    insert qa;
    Product2 prod = TestDataFactory.createProduct2();
    insert prod;
    zqu__ProductRatePlan__c prodrp = TestDataFactory.createZuoraProductRatePlan(
      prod
    );
    insert prodrp;
    zqu__ProductRatePlanCharge__c prodrpc = TestDataFactory.createZuoraProductRatePlanCharge(
      prodrp
    );
    insert prodrpc;
    zqu__QuoteChargeDetail__c qcd = TestDataFactory.createChargeDetail(q);
    insert qcd;
  }

  @isTest
  public static void onInsertTest() {
    zqu__Quote__c q = [SELECT Id, Name FROM zqu__Quote__c LIMIT 1];
    Test.startTest();
    try {
      zqu__QuoteChargeDetail__c qcd = TestDataFactory.createChargeDetail(q);
      insert qcd;
    } catch (Exception ex) {
    }
    Test.stopTest();
  }

  @isTest
  public static void onUpdateTest() {
    zqu__Quote__c q = [SELECT Id, Name FROM zqu__Quote__c LIMIT 1];
    Test.startTest();
    try {
      zqu__QuoteChargeDetail__c qcd = TestDataFactory.createChargeDetail(q);
      insert qcd;
      qcd.Name = 'Test';
      update qcd;
    } catch (Exception ex) {
    }
    Test.stopTest();
  }
}

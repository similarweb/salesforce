@isTest
public with sharing class QuotePackageFirstDetailControllerTest {
  @TestSetup
  static void makeData() {
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
    zqu__Quote__c quote = TestDataFactory.createZQuote(o, c);
    insert quote;
  }

  @isTest
  private static void constructorTest() {
    zqu__Quote__c obj = [
      SELECT Id, Recalculate_Charge__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    Test.startTest();
    PageReference pageRef = Page.CustomQuoteDetailFirstSectionPage;
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('Id', String.valueOf(obj.Id));
    ApexPages.StandardController sc = new ApexPages.StandardController(obj);
    QuotePackageFirstDetailController controller = new QuotePackageFirstDetailController(
      sc
    );
    Test.stopTest();
  }
}

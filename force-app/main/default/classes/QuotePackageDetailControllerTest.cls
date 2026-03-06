@isTest
public with sharing class QuotePackageDetailControllerTest {
  @testSetup
  static void setup() {
    Utils.CodeOff = true;
    ZuoraQuoteMetricsManipulationHelper.isMakeDataGetChargeDisabled = true;
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
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    quote.zqu__PaymentMethod__c = 'Other';
    quote.RecordTypeId = Utility.getRecordTypeIdForObject(
      'zqu__Quote__c',
      'Default'
    );
    quote.Dynamic_Base_Product_Users__c = '1\n2\n3';
    quote.Dynamic_Base_Product_Historical_Data__c = '1\n2\n3';
    quote.Dynamic_Base_Users_Stand_Alone__c = '1\n2\n3';
    quote.Default_Base_Product_Addons__c = '1\n2\n3';
    quote.Amendment_New_Products__c = '1\n2\n3';
    quote.Amendment_Updated_Products__c = '1\n2\n3';
    quote.Amendment_Deleted_Products__c = '1\n2\n3';
    insert quote;
    zqu__QuoteAmendment__c zAmend = TestDataFactory.createZQuoteAmendment(
      quote
    );
    insert zAmend;
    zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan(zAmend);
    insert zqrp;
    zqu__QuoteRatePlanCharge__c zqrpc = TestDataFactory.CreateRatePlanCharge(
      zqrp
    );
    insert zqrpc;
  }

  @isTest
  static void subscriptionTest() {
    zqu__Quote__c quote = [
      SELECT
        Id,
        RecordTypeId,
        Dynamic_Base_Product_Users__c,
        Dynamic_Base_Product_Historical_Data__c,
        Dynamic_Base_Users_Stand_Alone__c,
        Default_Base_Product_Addons__c,
        Dynamic_Base_Product_Unlimited_results__c,
        Dynamic_Base_Product_API_Hits__c,
        Dynamic_Base_Product_Country__c,
        Migrating_to_New_Soultion__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.standardController(quote);
    QuotePackageDetailController controller = new QuotePackageDetailController(
      sc
    );
    Test.stopTest();
  }

  @isTest
  static void amendTest() {
    zqu__Quote__c quote = [
      SELECT
        Id,
        RecordTypeId,
        Amendment_New_Products__c,
        Amendment_Updated_Products__c,
        Amendment_Deleted_Products__c,
        Amendment_New_Updated_Products__c,
        Dynamic_Base_Product_Unlimited_results__c,
        Dynamic_Base_Product_API_Hits__c,
        Dynamic_Base_Product_Country__c,
        Migrating_to_New_Soultion__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    quote.RecordTypeId = Utility.getRecordTypeIdForObject(
      'zqu__Quote__c',
      'Amendment'
    );
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.standardController(quote);
    QuotePackageDetailController controller = new QuotePackageDetailController(
      sc
    );
    Test.stopTest();
  }

  @isTest
  static void checkIfZuoraConflictExist() {
    zqu__Quote__c quote = [
      SELECT Id
      FROM zqu__Quote__c
      LIMIT 1
    ];
    Test.startTest();
    QuotePackageDetailController.checkIfZuoraConflictExist(quote.Id);
    Test.stopTest();
  }
}

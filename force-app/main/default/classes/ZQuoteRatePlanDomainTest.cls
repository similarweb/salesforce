@isTest
public class ZQuoteRatePlanDomainTest {
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
    zqu__Quote__c quote = TestDataFactory.createZQuote(o, c);
    quote.RecordTypeId = Utility.getRecordTypeIdForObject(
      'zqu__Quote__c',
      'Amendment_ReadOnly'
    );
    quote.Legacy_or_New_solution_deal__c = 'Solution 3.0';
    quote.New_solution_use_case__c = 'Competitive Intelligence';
    quote.package__c = 'Competitive Intelligence - Enterprise';
    quote.zqu__QuoteBusinessType__c = 'Co-Term Upsell + Renewal';
    //        q.Product_Compatibility__c = 'AdvancedDS';
    insert quote;
    zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(quote);
    insert qa;
    Product2 prod = TestDataFactory.createProduct2();
    prod.Name = 'API for Marketing Solution - Premium';
    prod.Contract_Wording__c = 'test wording';
    prod.AddOnType__c = 'test addon';
    prod.Contract_Wording_Action__c = 'Quantity';
    prod.ProductType__c = 'New solution';
    prod.AS__c = '1';
    prod.Contactproduct__c = 'Yes';
    insert prod;
    zqu__ProductRatePlan__c prodrp = TestDataFactory.createZuoraProductRatePlan(
      prod
    );
    insert prodrp;
    zqu__ProductRatePlanCharge__c prodrpc = TestDataFactory.createZuoraProductRatePlanCharge(
      prodrp
    );
    insert prodrpc;
  }

  @isTest
  public static void onInsertTest() {
    zqu__QuoteAmendment__c qa = [
      SELECT Id, zqu__Quote__c
      FROM zqu__QuoteAmendment__c
      LIMIT 1
    ];
    zqu__ProductRatePlan__c prodrp = [
      SELECT Id
      FROM zqu__ProductRatePlan__c
      LIMIT 1
    ];
    Test.startTest();
    zqu__QuoteRatePlan__c qrp = TestDataFactory.CreateRatePlan(qa);
    qrp.zqu__ProductRatePlan__c = prodrp.Id;
    insert qrp;
    Test.stopTest();
  }

  @isTest
  public static void onUpdateTest() {
    //  this will cover wording process
    List<zqu__QuoteChargeSummary__c> summaries = new List<zqu__QuoteChargeSummary__c>();
    zqu__QuoteAmendment__c qa = [
      SELECT Id, zqu__Quote__c
      FROM zqu__QuoteAmendment__c
      LIMIT 1
    ];
    zqu__ProductRatePlan__c prodrp = [
      SELECT Id
      FROM zqu__ProductRatePlan__c
      LIMIT 1
    ];
    zqu__ProductRatePlanCharge__c prodrpc = TestDataFactory.createZuoraProductRatePlanCharge(
      prodrp
    );
    prodrpc.zqu__Type__c = 'Recurring';
    insert prodrpc;
    Base_Product_Num_of_Data_Credits__c addon = new Base_Product_Num_of_Data_Credits__c();
    addon.Wording__c = 'test wording';
    addon.Quantity__c = 5.0;
    addon.Controlling__c = 'Digital Suite - Advanced';
    addon.Addon__c = 'test addon';
    addon.Name = 'asdads';
    insert addon;
    zqu__QuoteRatePlan__c qrp2 = TestDataFactory.CreateRatePlan(qa);
    qrp2.zqu__AmendmentType__c = 'RemoveProduct';
    qrp2.zqu__ProductRatePlan__c = prodrp.Id;
    insert qrp2;

    zqu__QuoteChargeSummary__c summary2 = TestDataFactory.createChargeSummary(
      qrp2
    );
    summary2.zqu__Quantity__c = 4.0;
    summaries.add(summary2);

    zqu__QuoteRatePlan__c qrp = TestObjectCreator.CreateRatePlan(qa);
    qrp.zqu__ProductRatePlan__c = prodrp.id;
    insert qrp;
    zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge(
      qrp
    );
    qrpc.zqu__RatePlanName__c = 'Marketing Solution - Premium';
    qrpc.zqu__ListTotal__c = 250;
    qrpc.zqu__Quantity__c = 5.0;
    qrpc.zqu__ProductRatePlanCharge__c = prodrpc.Id;
    insert qrpc;
    zqu__QuoteChargeSummary__c summary = TestDataFactory.createChargeSummary(
      qrp
    );
    summary.zqu__Quantity__c = 4.0;
    summaries.add(summary);
    insert summaries;
    Test.startTest();
    qrp.zqu__ProductRatePlan__c = prodrp.Id;

    update qrp;

    Test.stopTest();

    ///assert
    zqu__Quote__c quoteAfterProcess = [
      SELECT
        Id,
        Amendment_Deleted_Products__c,
        Amendment_Renewal_Prodcuts__c,
        Amendment_New_Products__c
      FROM zqu__Quote__c
    ];
    System.debug('quoteAfterProcess--' + quoteAfterProcess);
    //        System.assertEquals('4 test wording',quoteAfterProcess.Amendment_Deleted_Products__c,'the deleted products is not accurate');
    //        System.assertEquals('10 test wording',quoteAfterProcess.Amendment_New_Products__c,'the new products is not accurate');
    //        System.assertEquals('10 test wording',quoteAfterProcess.Amendment_Renewal_Prodcuts__c,'the renewal products is not accurate');
  }

  @isTest
  static void deletionTest() {
    Test.startTest();
    zqu__QuoteAmendment__c qa = [
      SELECT Id, zqu__Quote__c
      FROM zqu__QuoteAmendment__c
      LIMIT 1
    ];
    zqu__QuoteRatePlan__c qrp = TestDataFactory.CreateRatePlan(qa);
    qrp.zqu__AmendmentType__c = 'RemoveProduct';
    insert qrp;
    delete qrp;
    Test.stopTest();
    List<zqu__QuoteRatePlan__c> qrpList = [
      SELECT ID
      FROM zqu__QuoteRatePlan__c
    ];
    System.assert(
      qrpList.isEmpty(),
      'Quote Rate Plan wasn\'t deleted successfuly'
    );
  }
}

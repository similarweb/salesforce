@isTest
public class ZuoraQuoteMetricsManipulationHelperTest {
  @TestSetup
  static void setup() {
    Utils.CodeOff = true;
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
    // Account a = TestDataFactory.CreateAccount();
    // a.billingcountry = 'Israel';
    // insert a;
    // Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    // c.MailingCountry = 'Israel';
    // insert c;
    // Opportunity opp = TestDataFactory.CreateOpportunity (a);
    // insert opp;
    // Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
    // insert billAcc;
    // Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
    // insert sub;
    // Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
    // Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
    // insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
    // System.debug('Zuora__External_Id__c ' + sub.Zuora__External_Id__c);
    // zqu__Quote__c q = TestDataFactory.createZQuote (opp,c);
    // q.document_format__c = 'Amendment';
    // q.RecordTypeId = Utility.getRecordTypeIdForObject(q.getSObjectType(),'Amendment');
    // q.zqu__QuoteBusinessType__c = 'Feature Update';
    // q.zqu__SubscriptionType__c = 'Amend Subscription';
    // q.zqu__ZuoraSubscriptionID__c = sub.Zuora__External_Id__c;
    // q.zqu__ExistSubscriptionID__c = sub.Zuora__External_Id__c;
    // insert q;
    // zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    // insert qa;
    // Product2 prod = TestDataFactory.createProduct2();
    // insert prod;
    // zqu__ProductRatePlan__c prodrp = TestDataFactory.createZuoraProductRatePlan(prod);
    // insert prodrp;
    // ApprovedTermsFrequecy__c atf = TestDataFactory.createATF (q);
    // insert atf;
    // zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan (qa);
    // zqrp.zqu__ProductRatePlan__c = prodrp.Id;
    // insert zqrp;
    // zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
    // qrpc.zqu__RatePlanName__c = 'Marketing Solution - Premium';
    // qrpc.zqu__ListTotal__c = 250;
    // insert qrpc;
    // /* Zuora__SubscriptionProductCharge__c zuoraObject = new Zuora__SubscriptionProductCharge__c();
    // zuoraObject.Name = 'Marketing Solution - Premium';
    // zuoraObject.Zuora__Zuora_Id__c = 'testZuoraId';
    // zuoraObject.Zuora__Quantity__c = 10;
    // insert zuoraObject; */

    // //zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge (zqrp);
    // //insert qrpc;
  }

  // @isTest
  // public static void correctProductIfFutureUpdateTest(){
  //     Account a = TestDataFactory.CreateAccount();
  //     a.billingcountry = 'Israel';
  //     insert a;
  //     Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
  //     c.MailingCountry = 'Israel';
  //     insert c;
  //     Opportunity opp = TestDataFactory.CreateOpportunity (a);
  //     insert opp;
  //     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
  //     insert billAcc;
  //     Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
  //     insert sub;
  // 	Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
  //     Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
  //     insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
  //     System.debug('Zuora__External_Id__c ' + sub.Zuora__External_Id__c);
  //     zqu__Quote__c q = TestDataFactory.createZQuote (opp,c);
  //     q.document_format__c = 'Amendment';
  //     q.RecordTypeId = Utility.getRecordTypeIdForObject(q.getSObjectType(),'Amendment');
  //     q.zqu__QuoteBusinessType__c = 'Feature Update';
  //     q.zqu__SubscriptionType__c = 'Amend Subscription';
  //     q.zqu__ZuoraSubscriptionID__c = sub.Zuora__External_Id__c;
  //     q.zqu__ExistSubscriptionID__c = sub.Zuora__External_Id__c;
  //     insert q;
  //     zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
  //     insert qa;
  //     Product2 prod = TestDataFactory.createProduct2();
  //     insert prod;
  //     zqu__ProductRatePlan__c prodrp = TestDataFactory.createZuoraProductRatePlan(prod);
  //     insert prodrp;
  //     ApprovedTermsFrequecy__c atf = TestDataFactory.createATF (q);
  //     insert atf;
  //     zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan (qa);
  //     zqrp.zqu__ProductRatePlan__c = prodrp.Id;
  //     insert zqrp;
  //     zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
  //     qrpc.zqu__RatePlanName__c = 'Marketing Solution - Premium';
  //     qrpc.zqu__ListTotal__c = 250;
  //     insert qrpc;
  //     /* Zuora__SubscriptionProductCharge__c zuoraObject = new Zuora__SubscriptionProductCharge__c();
  //     zuoraObject.Name = 'Marketing Solution - Premium';
  //     zuoraObject.Zuora__Zuora_Id__c = 'testZuoraId';
  //     zuoraObject.Zuora__Quantity__c = 10;
  //     insert zuoraObject; */

  //     //zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge (zqrp);
  //     //insert qrpc;
  //     Test.startTest();

  //     zqu.Quote existingQuote = zqu.Quote.getInstance(zqrp.zqu__Quote__c);
  //     List <zqu.QuoteProduct> originalQuoteProductListToSplit = existingQuote.getQuoteProducts();
  //     existingQuote.deleteQuoteProducts(new List <zqu.QuoteProduct>{originalQuoteProductListToSplit[0]});
  //     existingQuote.buildAndSave();
  //     // ZuoraQuoteMetricsManipulationHelper.isMakeDataGetChargeDisabled = true;
  //     ZuoraQuoteMetricsManipulationHelper.correctProductIfFutureUpdate(zqrp.zqu__Quote__c);
  //     Test.stopTest();
  //     // zqu__QuoteRatePlanCharge__c changedQrpc = [SELECT ID,zqu__Discount__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__c= :zqrpp.Id LIMIT 1];
  //     // System.debug('DISCOUNT ' + changedQrpc.zqu__Discount__c);
  //     // System.assertEquals(100.00, changedQrpc.zqu__Discount__c);
  // }

  @isTest
  public static void calculateTotalListPriceTest() {
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'Israel';
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    Test.startTest();
    zqu__Quote__c q = TestDataFactory.createZQuote(opp, c);
    insert q;
    zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    insert qa;
    zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan(qa);
    insert zqrp;
    zqu__QuoteChargeSummary__c zqcs = TestDataFactory.createChargeSummary(zqrp);
    zqcs.zqu__Quantity__c = 10.0;
    insert zqcs;
    zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge(
      zqrp
    );
    qrpc.zqu__RatePlanName__c = 'Marketing Solution - Premium';
    qrpc.zqu__ListTotal__c = 250;
    insert qrpc;

    ZuoraQuoteMetricsManipulationHelper.isMakeDataGetChargeDisabled = true;
    ZuoraQuoteMetricsManipulationHelper.calculateTotalListPrice(
      new List<zqu__Quote__c>{ q }
    );
    Test.stopTest();
  }

  @isTest
  public static void calculateSpecificBillingPeriodTest() {
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'Israel';
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    Test.startTest();
    zqu__Quote__c q = TestDataFactory.createZQuote(opp, c);
    insert q;
    zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    insert qa;
    zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan(qa);
    insert zqrp;
    zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge(
      zqrp
    );
    qrpc.zqu__RatePlanName__c = 'Marketing Solution - Premium';
    qrpc.zqu__ListTotal__c = 250;
    insert qrpc;
    ZuoraQuoteMetricsManipulationHelper.isMakeDataGetChargeDisabled = true;
    ZuoraQuoteMetricsManipulationHelper.calculateSpecificBillingPeriod(
      new List<zqu__Quote__c>{ q },
      new Set<Id>{ q.Id }
    );
    Test.stopTest();
  }

  @isTest
  public static void removeProductsFromOldPackageTest() {
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
    Test.startTest();
    zqu__Quote__c q = TestDataFactory.createZQuote(o, c);
    insert q;
    ZuoraQuoteMetricsManipulationHelper.removeProductsFromOldPackage(q.Id);
    Test.stopTest();
  }

  @isTest
  public static void updateChargesBySpecificDisountTest() {
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
    Test.startTest();
    zqu__Quote__c q = TestDataFactory.createZQuote(o, c);
    insert q;
    zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    insert qa;
    ZuoraQuoteMetricsManipulationHelper.updateChargesBySpecificDisount(
      q.Id,
      1000,
      1000,
      12
    );
    Test.stopTest();
  }

  @isTest
  public static void updateChargesByTargetTotalPriceTest() {
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
    Test.startTest();
    zqu__Quote__c q = TestDataFactory.createZQuote(o, c);
    insert q;
    zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    insert qa;
    ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPrice(
      q.Id,
      1000,
      12
    );
    Test.stopTest();
  }

  @isTest
  public static void updateChargesByTargetTotalPriceisOriginalIncludedTest() {
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
    Test.startTest();
    zqu__Quote__c testQuote = TestDataFactory.createZQuote(o, c);
    testQuote.zqu__PaymentMethod__c = 'Other';
    testQuote.Customer_Type__c = 'Company';
    testQuote.Is_from_existing_Billing_Account__c = false;
    testQuote.zqu__Account__c = a.Id;
    testQuote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
    testQuote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
    testQuote.zqu__SubscriptionTermEndDate__c = Date.today().addDays(2);
    insert testQuote;
    ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPrice(
      testQuote.Id,
      1000,
      12
    );
    Test.stopTest();
  }

  // @isTest
  // public static void reAddAllProductsTest(){
  //     Account a = TestDataFactory.CreateAccount();
  //     a.billingcountry = 'Israel';
  //     insert a;
  //     Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
  //     c.MailingCountry = 'Israel';
  //     insert c;
  //     Opportunity opp = TestDataFactory.CreateOpportunity (a);
  //     insert opp;
  //     zqu__Quote__c q = TestDataFactory.createZQuote (opp,c);
  //     q.zqu__SubscriptionTermStartDate__c = Date.today();
  //     q.zqu__RenewalTerm__c = 12;
  //     insert q;
  //     Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
  //     insert billAcc;
  //     Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
  //     insert sub;
  //     zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
  //     insert qa;
  //     zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan (qa);
  //     insert zqrp;
  //     zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
  //     qrpc.zqu__RatePlanName__c = 'Marketing Solution - Premium';
  //     qrpc.zqu__ListTotal__c = 250;
  //     insert qrpc;
  //     Test.startTest();
  //     ZuoraQuoteMetricsManipulationHelper.reAddAllProducts(q.Id);
  //     Test.stopTest();
  // }

  @isTest
  public static void getPaymentFrequencyNumberTest() {
    Test.startTest();
    ZuoraQuoteMetricsManipulationHelper.getPaymentFrequencyNumber('test', 0);
    Test.stopTest();
  }

  @isTest
  public static void fireEeventCalculationOfMetricsTest() {
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
    Test.startTest();
    zqu__Quote__c q = TestDataFactory.createZQuote(o, c);
    insert q;
    zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    insert qa;
    ZuoraQuoteMetricsManipulationHelper.fireEeventCalculationOfMetrics(
      new Set<Id>{ q.Id }
    );
    Test.stopTest();
  }
}

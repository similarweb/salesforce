@isTest
private class ZuoraUpdateDiscountPriceQueueableTest {
  public static final String DEFAULT_BILLTO_CONTACT_FIRST_NAME = 'Test Bill-To First Name';
  public static final String DEFAULT_BILLTO_CONTACT_LAST_NAME = 'Test Bill-To Last Name';
  public static final String DEFAULT_SOLDTO_CONTACT_FIRST_NAME = 'Test Sold-To First Name';
  public static final String DEFAULT_SOLDTO_CONTACT_LAST_NAME = 'Test Sold-To Last Name';

  public static final String DEFAULT_OPPORTUNITY_NAME = 'Test Opportunity Name';
  public static final String DEFAULT_ACCOUNT_NAME = 'Test Salesforce Account Name';

  public static final String DEFAULT_CURRENCY = 'USD';

  public static final Date DEFAULT_EFFECTIVE_START_DATE = System.today();

  public static final Date DEFAULT_EFFECTIVE_END_DATE = System.today()
    .addYears(1);

  public static final String NEW_SUBSCRIPTION = 'New Subscription';

  public static final String MOCK_ZUORA_PROD_ID = '1118e487366202430136757c960716b6';
  public static final String MOCK_ZUORA_PROD_ID_ROUNDING = '1118e487366202430136757c960716b7';
  @TestSetup
  private static void setupTestData() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;

    InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
    ismTest.SW_Industry__c = 'AdTech and AdNetwork';
    ismTest.Department__c = 'BI / Analytics';
    ismTest.Inferred_Solution__c = 'Research';
    ismTest.Name = 'test';
    insert ismTest;
    //create a test account
    Account testAccount = new Account(Name = DEFAULT_ACCOUNT_NAME);
    testAccount.BillingCountryCode = 'US';
    insert testAccount;
    system.assertEquals([SELECT COUNT() FROM Account], 1);

    //create billto,soldTo contacts
    Contact billToContact = new Contact(
      FirstName = DEFAULT_BILLTO_CONTACT_FIRST_NAME,
      LastName = DEFAULT_BILLTO_CONTACT_LAST_NAME
    );
    billToContact.accountId = testaccount.Id;
    billToContact.Email = 'email@gmail.com';

    Contact soldToContact = new Contact(
      FirstName = DEFAULT_SOLDTO_CONTACT_FIRST_NAME,
      LastName = DEFAULT_SOLDTO_CONTACT_LAST_NAME
    );
    soldToContact.accountId = testaccount.Id;
    soldToContact.Email = 'email@gmail.comm';
    soldToContact.MailingCountry = 'United States';
    insert new List<Contact>{ billToContact, soldToContact };
    system.assertEquals([SELECT COUNT() FROM Contact], 2);

    //create an opportunity
    Opportunity testopportunity = new Opportunity(
      Name = DEFAULT_OPPORTUNITY_NAME,
      AccountId = testaccount.Id
    );
    testopportunity.StageName = 'Closed Won';
    testopportunity.CloseDate = System.today();
    testopportunity.Marketing_Discount__c = 'Other';
    insert testopportunity;
    system.assertEquals([SELECT COUNT() FROM Opportunity], 1);
    //create a zuora quote
    zqu__Quote__c quote = new zqu__Quote__c();
    quote.zqu__Currency__c = DEFAULT_CURRENCY;
    quote.Name = 'Positive Quote';
    quote.zqu__Account__c = testaccount.Id;
    quote.zqu__AutoRenew__c = true;
    quote.zqu__Amendment_Name__c = 'Positive Amendment';
    quote.zqu__Opportunity__c = testopportunity.Id;
    quote.zqu__BillToContact__c = billToContact.Id;
    quote.zqu__SoldToContact__c = soldToContact.Id;
    quote.zqu__InitialTerm__c = 12.0;
    quote.zqu__RenewalTerm__c = 6.0;
    quote.zqu__PaymentMethod__c = 'Credit Card';
    quote.zqu__ValidUntil__c = DEFAULT_EFFECTIVE_START_DATE;
    quote.zqu__StartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    quote.zqu__SubscriptionTermStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    quote.zqu__SubscriptionTermEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
    quote.zqu__SubscriptionType__c = NEW_SUBSCRIPTION;
    quote.zqu__BillingMethod__c = 'Both';
    quote.zqu__Subscription_Term_Type__c = 'Termed';
    quote.Target_Quote_Total_Price__c = 80;
    quote.zqu__ExistSubscriptionID__c = '123';
    quote.zqu__QuoteBusinessType__c = 'New';
    quote.zqu__Currency__c = 'USD';
    insert quote;
    system.assertEquals([SELECT COUNT() FROM zqu__Quote__c], 1);

    //creating ZProducts
    zqu__ZProduct__c zuoraproduct = new zqu__ZProduct__c();
    zuoraproduct.Name = 'CC Testing';
    zuoraproduct.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    zuoraproduct.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
    zuoraproduct.zqu__SKU__c = 'testingsku0001';
    zuoraproduct.zqu__ZuoraId__c = 'zuoraid0000000001';
    zuoraproduct.zqu__Deleted__c = false;

    zqu__ZProduct__c zuoraproduct2 = new zqu__ZProduct__c();
    zuoraproduct2.Name = 'CC Testing rounding';
    zuoraproduct2.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    zuoraproduct2.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
    zuoraproduct2.zqu__SKU__c = 'testingsku0002';
    zuoraproduct2.zqu__ZuoraId__c = 'zuoraid0000000002';
    zuoraproduct2.zqu__Deleted__c = false;
    insert new List<zqu__ZProduct__c>{ zuoraproduct, zuoraproduct2 };

    //creating salesforce product
    Product2 testsfproduct = new Product2();
    testsfproduct.Name = 'CC Testing';
    testsfproduct.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    testsfproduct.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
    testsfproduct.zqu__SKU__c = 'testingsku0001';
    testsfproduct.zqu__ZuoraId__c = 'zuoraid0000000001';
    testsfproduct.zqu__Deleted__c = false;

    Product2 testsfproduct2 = new Product2();
    testsfproduct2.Name = 'CC Testing';
    testsfproduct2.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    testsfproduct2.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
    testsfproduct2.zqu__SKU__c = 'testingsku0002';
    testsfproduct2.zqu__ZuoraId__c = 'zuoraid0000000002';
    testsfproduct2.zqu__Deleted__c = false;
    insert new List<Product2>{ testsfproduct, testsfproduct2 };

    //creating Product rate plan
    zqu__ProductRatePlan__c testProductRatePlan = new zqu__ProductRatePlan__c();
    testProductRatePlan.Name = 'Test Product Rate Plan';
    testProductRatePlan.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    testProductRatePlan.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
    testProductRatePlan.zqu__Product__c = testsfproduct.Id;
    testProductRatePlan.zqu__ZProduct__c = zuoraproduct.Id;
    testProductRatePlan.zqu__ZuoraId__c = MOCK_ZUORA_PROD_ID;
    testProductRatePlan.zqu__Deleted__c = false;
    testProductRatePlan.zqu__ActiveCurrencies__c = DEFAULT_CURRENCY;

    zqu__ProductRatePlan__c testProductRatePlanRounding = new zqu__ProductRatePlan__c();
    testProductRatePlanRounding.Name = 'rounding';
    testProductRatePlanRounding.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
    testProductRatePlanRounding.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
    testProductRatePlanRounding.zqu__Product__c = testsfproduct2.Id;
    testProductRatePlanRounding.zqu__ZProduct__c = zuoraproduct2.Id;
    testProductRatePlanRounding.zqu__ZuoraId__c = MOCK_ZUORA_PROD_ID_ROUNDING;
    testProductRatePlanRounding.zqu__Deleted__c = false;
    testProductRatePlanRounding.zqu__ActiveCurrencies__c = DEFAULT_CURRENCY;
    insert new List<zqu__ProductRatePlan__c>{
      testProductRatePlan,
      testProductRatePlanRounding
    };

    //creating Product rate plan charge with Model as 'Flat Fee Pricing' and Type as 'Recurring'
    zqu__ProductRatePlanCharge__c productrateplancharge = new zqu__ProductRatePlanCharge__c();
    productrateplancharge.Name = 'Test Product Rate Plan Charge';
    productrateplancharge.zqu__Model__c = 'Flat Fee Pricing';
    productrateplancharge.zqu__Type__c = 'Usage';
    productrateplancharge.zqu__UOM__c = 'UOM tesing';
    productrateplancharge.zqu__DefaultQuantity__c = 1;
    productrateplancharge.zqu__MinQuantity__c = 0;
    productrateplancharge.zqu__MaxQuantity__c = 500;
    productrateplancharge.zqu__RecurringPeriod__c = 'Month';
    productrateplancharge.zqu__ZuoraId__c = MOCK_ZUORA_PROD_ID;
    productrateplancharge.zqu__ProductRatePlan__c = testproductrateplan.Id;
    productrateplancharge.zqu__Deleted__c = false;
    if (
      productrateplancharge.zqu__Model__c == 'Discount-Fixed Amount' ||
      productrateplancharge.zqu__Model__c == 'Discount-Percentage'
    ) {
      productrateplancharge.zqu__Discount_Apply_Type__c = 3;
      productrateplancharge.zqu__Upto_How_Many_Periods__c = 5;
      productrateplancharge.zqu__Discount_Level__c = 'RatePlan';
    }
    // Set List Price for non-tiered charge
    productrateplancharge.zqu__ListPrice__c = 1000;

    //creating Product rate plan charge with Model as 'Flat Fee Pricing' and Type as 'Recurring'
    zqu__ProductRatePlanCharge__c productrateplanchargeflatfee = new zqu__ProductRatePlanCharge__c();
    productrateplanchargeflatfee.Name = 'Test Flat Fee Product Rate Plan Charge';
    productrateplanchargeflatfee.zqu__Model__c = 'Flat Fee Pricing';
    productrateplanchargeflatfee.zqu__Type__c = 'Usage';
    productrateplanchargeflatfee.zqu__UOM__c = 'UOM tesing';
    productrateplanchargeflatfee.zqu__DefaultQuantity__c = 1;
    productrateplanchargeflatfee.zqu__MinQuantity__c = 0;
    productrateplanchargeflatfee.zqu__MaxQuantity__c = 500;
    productrateplanchargeflatfee.zqu__RecurringPeriod__c = 'Month';
    productrateplanchargeflatfee.zqu__ZuoraId__c = MOCK_ZUORA_PROD_ID;
    productrateplanchargeflatfee.zqu__ProductRatePlan__c = testproductrateplan.Id;
    productrateplanchargeflatfee.zqu__Deleted__c = false;
    productrateplanchargeflatfee.zqu__ListPrice__c = 1000;

    //creating Product rate plan charge with Model as 'Tiered Pricing' and Type as 'Recurring'
    zqu__ProductRatePlanCharge__c productrateplanchargetierpricing = new zqu__ProductRatePlanCharge__c();
    productrateplanchargetierpricing.Name = 'Test Tiered Pricing Product Rate Plan Charge';
    productrateplanchargetierpricing.zqu__Model__c = 'Tiered Pricing';
    productrateplanchargetierpricing.zqu__Type__c = 'Usage';
    productrateplanchargetierpricing.zqu__UOM__c = 'UOM tesing';
    productrateplanchargetierpricing.zqu__DefaultQuantity__c = 1;
    productrateplanchargetierpricing.zqu__MinQuantity__c = 0;
    productrateplanchargetierpricing.zqu__MaxQuantity__c = 500;
    productrateplanchargetierpricing.zqu__RecurringPeriod__c = 'Month';
    productrateplanchargetierpricing.zqu__ZuoraId__c = '1118e487366202430136757c960715b5';
    productrateplanchargetierpricing.zqu__ProductRatePlan__c = testproductrateplan.Id;
    productrateplanchargetierpricing.zqu__Deleted__c = false;
    productrateplanchargetierpricing.zqu__ListPrice__c = 1000;

    List<zqu__ProductRatePlanCharge__c> productrateplanchargeList = new List<zqu__ProductRatePlanCharge__c>{
      productrateplanchargeflatfee,
      productrateplanchargetierpricing
    };
    insert productrateplanchargeList;
    system.assertEquals([SELECT COUNT() FROM zqu__ProductRatePlanCharge__c], 2);

    //create quote amendment
    zqu__QuoteAmendment__c testQuoteAmendment = new zqu__QuoteAmendment__c();
    testQuoteAmendment.zqu__Quote__c = quote.Id;
    zqu__QuoteAmendment__c testQuoteAmendment2 = new zqu__QuoteAmendment__c();
    testQuoteAmendment2.zqu__Quote__c = quote.Id;
    insert new List<zqu__QuoteAmendment__c>{
      testQuoteAmendment,
      testQuoteAmendment2
    };
    system.assertEquals([SELECT COUNT() FROM zqu__QuoteAmendment__c], 2);

    //create quote rate plan
    zqu__QuoteRatePlan__c testQuoteRatePlan = new zqu__QuoteRatePlan__c();
    testQuoteRatePlan.zqu__Quote__c = quote.Id;
    testQuoteRatePlan.zqu__ProductRatePlan__c = testproductrateplan.Id;
    testQuoteRatePlan.zqu__QuoteAmendment__c = testQuoteAmendment.Id;
    testQuoteRatePlan.zqu__QuoteProductName__c = 'Orange Box';

    zqu__QuoteRatePlan__c testQuoteRatePlanRounding = new zqu__QuoteRatePlan__c();
    testQuoteRatePlanRounding.zqu__Quote__c = quote.Id;
    testQuoteRatePlanRounding.zqu__ProductRatePlan__c = testproductrateplan.Id;
    testQuoteRatePlanRounding.zqu__QuoteAmendment__c = testQuoteAmendment2.Id;
    testQuoteRatePlanRounding.zqu__QuoteProductName__c = 'Rounding';
    testQuoteRatePlanRounding.Name = 'Rounding';
    insert new List<zqu__QuoteRatePlan__c>{
      testQuoteRatePlan,
      testQuoteRatePlanRounding
    };
    system.assertEquals([SELECT COUNT() FROM zqu__QuoteRatePlan__c], 2);

    //create quote rate plan charge
    List<zqu__QuoteRatePlanCharge__c> testQuoteRatePlanChargeList = new List<zqu__QuoteRatePlanCharge__c>();
    List<zqu__QuoteCharge_Tier__c> testquotechargetierList = new List<zqu__QuoteCharge_Tier__c>();
    List<zqu__ProductRatePlanChargeTier__c> testproductrateplanchargetierList = new List<zqu__ProductRatePlanChargeTier__c>();
    for (
      Integer productrateplanchargeIterator = 0;
      productrateplanchargeIterator < productrateplanchargeList.size();
      productrateplanchargeIterator++
    ) {
      zqu__QuoteRatePlanCharge__c testQuoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c();
      testQuoteRatePlanCharge.zqu__QuoteRatePlan__c = testQuoteRatePlan.Id;
      testQuoteRatePlanCharge.zqu__ProductRatePlanCharge__c = productrateplanchargeList[
          productrateplanchargeIterator
        ]
        .Id;
      testQuoteRatePlanCharge.zqu__Model__c = productrateplanchargeList[
          productrateplanchargeIterator
        ]
        .zqu__Model__c;
      testQuoteRatePlanCharge.zqu__ChargeType__c = productrateplanchargeList[
          productrateplanchargeIterator
        ]
        .zqu__Type__c;
      testQuoteRatePlanChargeList.add(testQuoteRatePlanCharge);
      //create product rate plan charge tier
      zqu__ProductRatePlanChargeTier__c prodchargetier = new zqu__ProductRatePlanChargeTier__c(
        zqu__Active__c = false,
        zqu__Currency2__c = DEFAULT_CURRENCY,
        zqu__Currency__c = DEFAULT_CURRENCY,
        zqu__Deleted__c = false,
        zqu__EndingUnit__c = 0.0,
        zqu__IsOveragePrice__c = false,
        Name = '1',
        zqu__PriceFormat2__c = 'Flat Fee',
        zqu__PriceFormat__c = 'Flat Fee',
        zqu__Price__c = 1000,
        zqu__ProductRatePlanCharge__c = productrateplanchargeList[
            productrateplanchargeIterator
          ]
          .Id,
        zqu__StartingUnit__c = 0.0,
        zqu__Tier__c = 1
      );
      testproductrateplanchargetierList.add(prodchargetier);
    }
    insert testQuoteRatePlanChargeList;
    insert testproductrateplanchargetierList;
    system.assertEquals([SELECT COUNT() FROM zqu__QuoteRatePlanCharge__c], 2);
    system.assertEquals(
      [SELECT COUNT() FROM zqu__ProductRatePlanChargeTier__c],
      2
    );

    //create quote charge tier
    for (
      Integer quoterateplanchargeIterator = 0;
      quoterateplanchargeIterator < testQuoteRatePlanChargeList.size();
      quoterateplanchargeIterator++
    ) {
      //create quote charge tier
      if (
        testQuoteRatePlanChargeList[quoterateplanchargeIterator]
          .zqu__Model__c == 'Tiered Pricing'
      ) {
        zqu__QuoteCharge_Tier__c tier = new zqu__QuoteCharge_Tier__c(
          Name = String.valueOf('Tier ' + quoterateplanchargeIterator + 1),
          zqu__Tier__c = quoterateplanchargeIterator + 1,
          zqu__Price__c = quoterateplanchargeIterator + 1,
          zqu__Discount__c = 0,
          zqu__Effective_Price__c = 1000,
          zqu__StartingUnit__c = quoterateplanchargeIterator,
          zqu__EndingUnit__c = quoterateplanchargeIterator + 1,
          zqu__IsOveragePrice__c = false,
          zqu__QuoteRatePlanCharge__c = testQuoteRatePlanChargeList[
              quoterateplanchargeIterator
            ]
            .Id
        );
        testquotechargetierList.add(tier);
      }
    }
    insert testquotechargetierList;
    Zuora__Subscription__c sub = new Zuora__Subscription__c(
      Zuora__External_Id__c = '123',
      Zuora__Account__c = testaccount.Id
    );
    insert sub;
    Zuora__SubscriptionProductCharge__c spb1 = new Zuora__SubscriptionProductCharge__c(
      Zuora__Subscription__c = sub.Id,
      Zuora__MonthlyRecurringRevenue__c = 100,
      Zuora__Type__c = 'Recurring'
    );
    insert spb1;
    system.assertEquals([SELECT COUNT() FROM zqu__QuoteCharge_Tier__c], 1);
  }

  @isTest
  static void testExecuteAddDiscount() {
    // Get the test quote
    Test.startTest();
    zqu__Quote__c testQuote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    List<zqu__QuoteRatePlan__c> testQuoteRatePlanList = [
      SELECT Id, zqu__QuoteProductName__c, zqu__ProductRatePlan__c
      FROM zqu__QuoteRatePlan__c
      WHERE zqu__Quote__c = :testquote.Id
    ];
    savePlan(testQuote, testQuoteRatePlanList);

    // Create the Queueable instance
    ZuoraUpdateDiscountPriceQueueable queueable = new ZuoraUpdateDiscountPriceQueueable(
      testQuote,
      'AddDiscount'
    );
    ZuoraUpdateDiscountPriceQueueable.coverCode();
    ZuoraPriceCalculation.coverCode();

    // Enqueue the Queueable job
    System.enqueueJob(queueable);
    Test.stopTest();

    // Verify the results
    testQuote = [
      SELECT Recurring_Discount_Percentage__c
      FROM zqu__Quote__c
      WHERE Id = :testQuote.Id
    ];
    System.assertNotEquals(null, testQuote.Recurring_Discount_Percentage__c);
  }

  @isTest
  static void testExecuteHandleRenewal() {
    // Get the test quote
    Test.startTest();
    zqu__Quote__c testQuote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    List<zqu__QuoteRatePlan__c> testQuoteRatePlanList = [
      SELECT Id, zqu__QuoteProductName__c, zqu__ProductRatePlan__c
      FROM zqu__QuoteRatePlan__c
      WHERE zqu__Quote__c = :testquote.Id
    ];
    savePlan(testQuote, testQuoteRatePlanList);

    // Create the Queueable instance
    ZuoraUpdateDiscountPriceQueueable queueable = new ZuoraUpdateDiscountPriceQueueable(
      testQuote,
      'Renewal'
    );
    ZuoraCARRCalculationQueueable.coverCode();
    ZuoraCARRCalculation.coverCode();
    // Enqueue the Queueable job

    System.enqueueJob(queueable);
    Test.stopTest();

    // Verify the results
    testQuote = [
      SELECT Recurring_Discount_Percentage__c
      FROM zqu__Quote__c
      WHERE Id = :testQuote.Id
    ];
    System.assertNotEquals(null, testQuote.Recurring_Discount_Percentage__c);
  }

  @isTest
  static void testExecuteHandleFU() {
    // Get the test quote
    Test.startTest();
    zqu__Quote__c testQuote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    List<zqu__QuoteRatePlan__c> testQuoteRatePlanList = [
      SELECT Id, zqu__QuoteProductName__c, zqu__ProductRatePlan__c
      FROM zqu__QuoteRatePlan__c
      WHERE zqu__Quote__c = :testquote.Id
    ];
    savePlan(testQuote, testQuoteRatePlanList);

    // Create the Queueable instance
    ZuoraUpdateDiscountPriceQueueable queueable = new ZuoraUpdateDiscountPriceQueueable(
      testQuote,
      'FU'
    );

    // Enqueue the Queueable job
    System.enqueueJob(queueable);
    Test.stopTest();

    // Verify the results
    testQuote = [
      SELECT Recurring_Discount_Percentage__c
      FROM zqu__Quote__c
      WHERE Id = :testQuote.Id
    ];
    System.assertNotEquals(null, testQuote.Recurring_Discount_Percentage__c);
  }

  @isTest
  static void testExecuteHandleFU2() {
    // Get the test quote

    zqu__Quote__c testQuote = [
      SELECT
        Id,
        QuoteRegion__c,
        zqu__Currency__c,
        zqu__SoldToContact__c,
        zqu__SoldToContact__r.MailingCountry
      FROM zqu__Quote__c
      LIMIT 1
    ];
    Test.startTest();
    List<zqu__ProductRatePlan__c> testProductList = [
      SELECT Id
      FROM zqu__ProductRatePlan__c
      LIMIT 1
    ];
    List<Id> testProductIdList = new List<Id>();
    for (zqu__ProductRatePlan__c prp : [
      SELECT Id
      FROM zqu__ProductRatePlan__c
      LIMIT 1
    ]) {
      testProductIdList.add(prp.Id);
    }
    //List<zqu__QuoteRatePlan__c> testQuoteRatePlanList = [SELECT Id, zqu__QuoteProductName__c, zqu__ProductRatePlan__c from zqu__QuoteRatePlan__c WHERE zqu__Quote__c =:testquote.Id];

    List<zqu.QPlan> plans = zqu.QPlanReader.load(testQuote.Id);
    System.debug(plans);
    List<zqu.QPlan> qPlans = zqu.QPlanBuilder.makeFromCatalog(
      testquote.Id,
      testProductIdList
    );
    plans.addAll(qPlans);
    System.debug(plans);
    for (zqu.QPlan plan : plans) {
      for (zqu.QCharge charge : plan.getCharges()) {
        charge.put('zqu__total__c', 151);
        if (charge.getTiers() != null) {
          for (zqu.QTier tier : charge.getTiers()) {
            tier.put('zqu__Effective_Price__c', 151);
            charge.setTiers(new List<zqu.QTier>{ tier });
          }
        }
      }
    }
    System.debug(plans);
    zqu.QPlanWriter.save(plans);
    //savePlan(testQuote,testQuoteRatePlanList);

    // Create the Queueable instance
    ZuoraUpdateDiscountPriceQueueable queueable = new ZuoraUpdateDiscountPriceQueueable(
      testQuote,
      'FU'
    );

    // Enqueue the Queueable job
    System.enqueueJob(queueable);
    Test.stopTest();

    // Verify the results
    testQuote = [
      SELECT Recurring_Discount_Percentage__c
      FROM zqu__Quote__c
      WHERE Id = :testQuote.Id
    ];
    System.assertNotEquals(null, testQuote.Recurring_Discount_Percentage__c);
  }

  @isTest
  static void testExecuteHandleCTU() {
    // Get the test quote
    Test.startTest();
    zqu__Quote__c testQuote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    List<zqu__QuoteRatePlan__c> testQuoteRatePlanList = [
      SELECT Id, zqu__QuoteProductName__c, zqu__ProductRatePlan__c
      FROM zqu__QuoteRatePlan__c
      WHERE zqu__Quote__c = :testquote.Id
    ];
    savePlan(testQuote, testQuoteRatePlanList);

    // Create the Queueable instance
    ZuoraUpdateDiscountPriceQueueable queueable = new ZuoraUpdateDiscountPriceQueueable(
      testQuote,
      'CTU'
    );

    // Enqueue the Queueable job
    System.enqueueJob(queueable);
    Test.stopTest();

    // Verify the results
    testQuote = [
      SELECT Recurring_Discount_Percentage__c
      FROM zqu__Quote__c
      WHERE Id = :testQuote.Id
    ];
    System.debug('testQuote--' + testQuote.Recurring_Discount_Percentage__c);
    System.assertNotEquals(null, testQuote.Recurring_Discount_Percentage__c);
  }

  private static void savePlan(
    zqu__Quote__c testQuote,
    List<zqu__QuoteRatePlan__c> testQuoteRatePlanList
  ) {
    zqu.DataObject masterObject = new zqu.CommittedDataObject(testquote);
    List<Id> productRatePlanIdLis = new List<Id>();
    for (zqu__QuoteRatePlan__c ratePlan : testQuoteRatePlanList) {
      zqu.DataObject rateplanObj = new zqu.CommittedDataObject(ratePlan);
      masterObject.addChild('zqu__QuoteRatePlan__c', rateplanObj);
      productRatePlanIdLis.add(ratePlan.zqu__ProductRatePlan__c);
    }
    //        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(testquote.Id, new List<Id>{testQuoteRatePlan.zqu__ProductRatePlan__c});
    List<zqu.QPlan> qPlans = zqu.QPlanBuilder.makeFromCatalog(
      testquote.Id,
      productRatePlanIdLis
    );
    System.debug('qPlans---' + qPlans.size());
    for (zqu.QPlan qPlan : qPlans) {
      zqu.QPlanDataObject objList = new zqu.QPlanDataObject(qPlan);
      masterObject.addChild('zqu__QuoteRatePlan__c', objList);
      for (zqu.QCharge qCharge : qPlan.getCharges()) {
        zqu.QChargeDataObject obj = new zqu.QChargeDataObject(qCharge);
        obj.put('zqu__Total__c', 5);
        obj.put('zqu__SpecificBillingPeriod__c', 2);
        masterObject.addChild('zqu__QuoteRatePlanCharge__c', obj);
      }
    }

    zqu.QPlanWriter.save(new List<zqu.QPlan>(qPlans));
  }
}

@isTest
public with sharing class CreateQuoteAmendPageControllerTest {
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
  }

  @isTest
  private static void testControllerConstructor() {
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
    insert quote;
    Test.startTest();
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
    insert billAcc;
    Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
    insert sub;
    Product2 productBase = TestDataFactory.createProduct2();
    productBase.Name = 'Test Product';
    insert productBase;
    Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    subCharge1.Zuora__SpecificBillingPeriod__c = 46;
    Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    subCharge2.Zuora__SpecificBillingPeriod__c = 46;
    insert new List<Zuora__SubscriptionProductCharge__c>{
      subCharge1,
      subCharge2
    };

    PageReference createQuote = Page.CustomCreateQuoteAmend;
    createQuote.getParameters().put('oppId', opp.Id);
    createQuote.getParameters().put('quoteType', 'Amendment');
    createQuote.getParameters().put('stepNumber', '2');
    createQuote.getParameters()
      .put('billingAccountId', TestDataFactory.zuoraExternalAcctId);
    createQuote.getParameters()
      .put('subscriptionId', TestDataFactory.zuoraExternalSubId);
    Test.setCurrentPage(createQuote);
    ApexPages.StandardController sc = new ApexPages.StandardController(quote);

    CreateQuoteAmendPageController createQuoteController = new CreateQuoteAmendPageController(
      sc
    );
    Test.stopTest();
  }

  @isTest
  private static void getInstructionForBusinessTypeTest() {
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
    insert quote;
    Test.startTest();
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
    insert billAcc;
    Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
    insert sub;
    Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    insert new List<Zuora__SubscriptionProductCharge__c>{
      subCharge1,
      subCharge2
    };

    PageReference createQuote = Page.CustomCreateQuoteAmend;
    createQuote.getParameters().put('oppId', opp.Id);
    createQuote.getParameters().put('quoteType', 'Amendment');
    createQuote.getParameters().put('stepNumber', '2');
    createQuote.getParameters()
      .put('billingAccountId', TestDataFactory.zuoraExternalAcctId);
    createQuote.getParameters()
      .put('subscriptionId', TestDataFactory.zuoraExternalSubId);
    Test.setCurrentPage(createQuote);
    ApexPages.StandardController sc = new ApexPages.StandardController(quote);

    CreateQuoteAmendPageController.getInstructionForBusinessType('New Sale');
    Test.stopTest();
  }

  @isTest
  public static void getPackageAmendmentsForPackageValueTest() {
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
    insert quote;
    Test.startTest();
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
    insert billAcc;
    Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
    insert sub;
    Product2 productBase = TestDataFactory.createProduct2();
    productBase.Name = 'Test Product';
    insert productBase;
    Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    subCharge1.Zuora__SpecificBillingPeriod__c = 46;
    Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    subCharge2.Zuora__SpecificBillingPeriod__c = 46;
    insert new List<Zuora__SubscriptionProductCharge__c>{
      subCharge1,
      subCharge2
    };

    ApexPages.StandardController sc = new ApexPages.StandardController(quote);

    CreateQuoteAmendPageController createQuoteController = new CreateQuoteAmendPageController(
      sc
    );
    Object res = CreateQuoteAmendPageController.getPackageAmendmentsForPackageValue();
    Test.stopTest();
  }
}

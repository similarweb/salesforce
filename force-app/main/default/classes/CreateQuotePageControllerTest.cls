@isTest
public with sharing class CreateQuotePageControllerTest {
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
    quote.Legacy_or_New_solution_deal__c = 'Solution 3.0';
    quote.package__c = 'Competitive Intelligence - Business';
    quote.New_solution_use_case__c = 'Competitive Intelligence';
    quote.Product_Compatibility__c = 'CIB';
    quote.zqu__PaymentMethod__c = 'Other';
    insert quote;
    Test.startTest();
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
    billAcc.Zuora__BillToId__c = c.Id;
    billAcc.Zuora__SoldToId__c = c.Id;
    insert billAcc;
    Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
    insert sub;
    Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    subCharge1.Zuora__SpecificBillingPeriod__c = 37;
    Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(
      sub,
      'Month'
    );
    subCharge2.Zuora__SpecificBillingPeriod__c = 37;
    insert new List<Zuora__SubscriptionProductCharge__c>{
      subCharge1,
      subCharge2
    };
    Product2 prod = TestDataFactory.createProduct2();
    prod.Name = 'Test Product';
    insert prod;

    PageReference createQuote = Page.CustomCreateQuoteNewSubcription;
    createQuote.getParameters().put('oppId', opp.Id);
    createQuote.getParameters().put('quoteType', 'Subscription');
    createQuote.getParameters().put('stepNumber', '2');
    createQuote.getParameters()
      .put('billingAccountId', TestDataFactory.zuoraExternalAcctId);
    createQuote.getParameters().put('crmAccountId', a.Id);
    Test.setCurrentPage(createQuote);
    ApexPages.StandardController sc = new ApexPages.StandardController(quote);
    CreateQuotePageController createQuoteController = new CreateQuotePageController(
      sc
    );
    createQuoteController.navigateBack();
    String billingPeriod = CreateQuotePageController.getBaseProductSpecificBillingPeriodFromSubscription(
      sub
    );
    Test.stopTest();
  }

  @isTest
  private static void checkSoldToCountryTest() {
    List<String> countries = TestDataFactory.getCountries();
    Account account = TestDataFactory.createAccount();
    account.billingcountry = countries[countries.size() - 1];
    insert account;
    Contact contact = TestDataFactory.createContact(
      account,
      'test@testing.com'
    );
    contact.MailingCountry = countries[countries.size() - 1];
    insert contact;
    List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
    insert lcsc;

    Test.startTest();
    CreateQuotePageController.checkSoldToCountry(contact.Id, 'Admetricks');
    Test.stopTest();
  }

  @isTest
  private static void validateCertificateIdTest() {
    List<String> countries = TestDataFactory.getCountries();
    Account account = TestDataFactory.createAccount();
    account.billingcountry = countries[countries.size() - 1];
    insert account;
    Contact contact = TestDataFactory.createContact(
      account,
      'test@testing.com'
    );
    contact.MailingCountry = countries[countries.size() - 1];
    insert contact;
    List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
    insert lcsc;
    Test.setMock(
      WebServiceMock.class,
      new CheckVatServiceMockImpl('US', '12345')
    );
    Test.startTest();
    CreateQuotePageController.validateCertificateId(contact.Id, '12345');
    Test.stopTest();
  }

  @isTest
  private static void validateCertificateIdNewTest() {
    List<String> countries = TestDataFactory.getCountries();
    Account account = TestDataFactory.createAccount();
    account.billingcountry = countries[countries.size() - 1];
    insert account;
    Contact contact = TestDataFactory.createContact(
      account,
      'test@testing.com'
    );
    contact.MailingCountry = countries[countries.size() - 1];
    insert contact;
    List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
    insert lcsc;
    Test.setMock(
      WebServiceMock.class,
      new CheckVatServiceMockImpl('US', '12345')
    );
    Test.startTest();
    CreateQuotePageController.validateCertificateIdNew(contact.Id, 'US 12345');
    Test.stopTest();
  }

  @isTest
  private static void getHelpTextTest() {
    Test.startTest();
    CreateQuotePageController.getHelpText('zqu__SoldToContact__c');
    Test.stopTest();
  }

  @isTest
  private static void getSubsidaiaryCountryNameTest() {
    List<String> countries = TestDataFactory.getCountries();
    Account account = TestDataFactory.createAccount();
    account.billingcountry = countries[countries.size() - 1];
    insert account;
    Contact contact = TestDataFactory.createContact(
      account,
      'test@testing.com'
    );
    contact.MailingCountry = countries[countries.size() - 1];
    insert contact;
    List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
    insert lcsc;
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(
      account
    );
    billAcc.Zuora__BillToId__c = contact.Id;
    billAcc.Zuora__SoldToId__c = contact.Id;
    billAcc.Zuora__External_Id__c = 'test';
    insert billAcc;
    Test.startTest();
    CreateQuotePageController.getSubsidaiaryCountryName(
      contact.Id,
      billAcc.Zuora__External_Id__c
    );
    Test.stopTest();
  }
}

@isTest
public with sharing class QuoteRenewalProcessServiceTest {
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
    List<String> countries = TestDataFactory.getCountries();
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'Israel';
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    zqu__Quote__c q = TestDataFactory.createZQuote(opp, c);
    q.zqu__SubscriptionTermStartDate__c = Date.today();
    q.zqu__RenewalTerm__c = 12;
    insert q;

    //Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
    //insert billAcc;st
    //Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
    //insert sub;
  }

  @isTest
  static void createRenewalCloneOfAmendQuoteTest() {
    zqu__Quote__c quote = [
      SELECT
        Id,
        zqu__Status__c,
        zqu__BillingMethod__c,
        QuoteRegion__c,
        zqu__PaymentTerm__c,
        RecordTypeId,
        zqu__Currency__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    zqu.Quote zQuote = zqu.Quote.createNewInstance(quote);
    system.debug(zQuote.getSObject());
    QuoteProductsChangeUnit quoteProductsChangeUnit = new QuoteProductsChangeUnit(
      zQuote
    );
    Test.startTest();
    quote.zqu__Status__c = 'Sent to Z-Billing';
    // QuoteRenewalProcessService.createRenewalCloneOfAmendQuote(new Set<Id>{quote.Id});
    System.enqueueJob(
      new QuoteRenewalProcessQueueableService(
        new Set<Id>{ quote.Id },
        'createRenewalCloneOfAmendQuote'
      )
    );
    Test.stopTest();
  }

  @isTest
  static void refreshRenewalQuoteUnderSubscriptionTest() {
    Test.startTest();
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'Israel';
    insert a;
    Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
    insert billAcc;
    Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
    insert sub;
    zqu__Quote__c quote = [
      SELECT Id, zqu__ExistSubscriptionID__c, zqu__SubscriptionVersion__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    quote.zqu__ExistSubscriptionID__c = sub.Zuora__External_Id__c;
    quote.zqu__SubscriptionVersion__c = sub.Zuora__Version__c - 1;
    update quote;

    // QuoteRenewalProcessService.refreshRenewalQuoteUnderSubscription(new Set<Id>{subscription.Id});
    System.enqueueJob(
      new QuoteRenewalProcessQueueableService(
        new Set<Id>{ sub.Id },
        'refreshRenewalQuoteUnderSubscription'
      )
    );
    Test.stopTest();
  }

  @isTest
  static void sendEmailNotificationAboutErrorTest() {
    zqu__Quote__c quote = [SELECT id FROM zqu__Quote__c LIMIT 1];

    Test.startTest();
    QuoteRenewalProcessService.sendEmailNotificationAboutError(
      new Set<Id>{ quote.Id },
      'Renewal_quote_duplication_process_has_failed',
      'Error'
    );
    QuoteRenewalProcessService.sendEmailNotificationAboutError(
      new Set<Id>{ quote.Id },
      'A_renewal_quote_duplication_process_has_failed_on_the_creation_of_another_amend',
      'Error'
    );
    Test.stopTest();
  }

  @isTest
  static void updateRenewalCloneOfAmendQuoteTest() {
    zqu__Quote__c quote = [
      SELECT Id, zqu__Status__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    List<QuoteProductsChangeUnit> qpcuList = QuoteRenewalProcessService.createRenewalCloneOfAmendQuote(
      new Set<Id>{ quote.Id }
    );
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockUtil.ZQuoteServiceHttpMock());
    System.enqueueJob(
      new QuoteRenewalProcessQueueableService(
        qpcuList,
        'updateRenewalCloneOfAmendQuote'
      )
    );
    Test.stopTest();
  }

  @isTest
  static void deleteOneTimeProductsFromCloneTest() {
    zqu__Quote__c quote = [
      SELECT Id, zqu__Status__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
    List<QuoteProductsChangeUnit> qpcuList = QuoteRenewalProcessService.createRenewalCloneOfAmendQuote(
      new Set<Id>{ quote.Id }
    );
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockUtil.ZQuoteServiceHttpMock());
    System.enqueueJob(
      new QuoteRenewalProcessQueueableService(
        qpcuList,
        'deleteOneTimeProductsFromClone'
      )
    );
    Test.stopTest();
  }
  @IsTest
  static void addCoverage() {
    QuoteRenewalProcessService.addCoverage();
  }
}

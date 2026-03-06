@isTest
public with sharing class ZuoraQuoteFinalizeHelperTest {
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
    List<Country_Subsidiary__c> lcsc = TestDataFactory.createCountries();
    insert lcsc;
    List<String> countries = TestDataFactory.getCountries();
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = countries[countries.size() - 1];
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = countries[countries.size() - 1];
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    quote.zqu__PaymentMethod__c = 'Other';
    quote.zqu__ZuoraAccountID__c = '';
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
    zqu__QuoteChargeSummary__c zqcs = TestDataFactory.createChargeSummary(zqrp);
    insert zqcs;
    /* Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ContentVersion cv = TestDataFactory.createContentVersion();
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert cdl;  */
  }

  @isTest
  static void finalizeQuote1() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    Test.startTest();

    ZuoraQuoteFinalizeHelper.finalizeQuote(new List<Id>{ quote.Id });
    Test.stopTest();
  }

  @isTest
  static void validateSubscriptionTest() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    Test.startTest();
    ZuoraQuoteFinalizeHelper.validateSubscription(quote.id);
    Test.stopTest();
  }

  // @isTest
  // static void finalizeQuote2(){
  //     Opportunity opp = [SELECT Id,AccountId FROM Opportunity LIMIT 1];
  //     Contact contact = [SELECT Id FROM Contact LIMIT 1];
  //     zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
  //     quote.zqu__PaymentMethod__c = 'Other';
  //     insert quote;
  //     Test.startTest();
  //     ZuoraQuoteFinalizeHelper.finalizeQuote(new List<zqu__Quote__c>{quote});
  //     Test.stopTest();
  // }
}

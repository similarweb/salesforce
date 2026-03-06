@isTest
public class ZuoraQuoteValidationsTest {
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
    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'United States';
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'United States';
    c.MailingPostalCode = '123';
    c.MailingState = 'test';
    c.MailingStreet = 'test';
    c.MailingCity = 'test';
    insert c;
    Contact c1 = TestDataFactory.CreateContact(a, 'test1@testing.com');
    c1.MailingCountry = 'Japan';
    c1.MailingPostalCode = '12311';
    c1.MailingState = 'test2';
    c1.MailingStreet = '';
    c1.MailingCity = 'test2';
    insert c1;

    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    quote.zqu__PaymentMethod__c = 'Credit Card';
    quote.Add_Finance_Information__c = false;
    quote.zqu__SoldToContact__c = c1.Id;
    insert quote;
    zqu__Quote__c amendQuote = TestDataFactory.createAmendZQuote(opp, c);
    amendQuote.zqu__PaymentMethod__c = 'Credit Card';
    amendQuote.zqu__BillToContact__c = c1.Id;
    insert amendQuote;
  }

  @isTest
  static void validateSoldToBillToTest() {
    zqu__Quote__c quote = [
      SELECT
        Id,
        zqu__PaymentMethod__c,
        zqu__SubscriptionType__c,
        zqu__SoldToContact__c,
        zqu__SoldToContact__r.FirstName,
        zqu__SoldToContact__r.LastName,
        zqu__SoldToContact__r.MailingAddress,
        zqu__SoldToContact__r.MailingCity,
        zqu__SoldToContact__r.MailingPostalCode,
        zqu__SoldToContact__r.MailingState,
        zqu__SoldToContact__r.MailingStreet,
        zqu__SoldToContact__r.MailingCountry,
        zqu__BillToContact__c,
        zqu__BillToContact__r.FirstName,
        zqu__BillToContact__r.LastName,
        zqu__BillToContact__r.MailingAddress,
        zqu__BillToContact__r.MailingCity,
        zqu__BillToContact__r.MailingPostalCode,
        zqu__BillToContact__r.MailingState,
        zqu__BillToContact__r.MailingStreet,
        zqu__BillToContact__r.MailingCountry
      FROM zqu__Quote__c
      LIMIT 1
    ];
    Test.startTest();
    ZuoraQuoteValidations.validateSoldToBillTo(quote);
    Test.stopTest();
  }

  @isTest
  static void validateSoldToBillToTest2() {
    Test.startTest();

    zqu__Quote__c quote = [
      SELECT
        Id,
        zqu__PaymentMethod__c,
        zqu__SubscriptionType__c,
        zqu__SoldToContact__c,
        zqu__SoldToContact__r.FirstName,
        zqu__SoldToContact__r.LastName,
        zqu__SoldToContact__r.MailingAddress,
        zqu__SoldToContact__r.MailingCity,
        zqu__SoldToContact__r.MailingPostalCode,
        zqu__SoldToContact__r.MailingState,
        zqu__SoldToContact__r.MailingStreet,
        zqu__SoldToContact__r.MailingCountry,
        zqu__BillToContact__c,
        zqu__BillToContact__r.FirstName,
        zqu__BillToContact__r.LastName,
        zqu__BillToContact__r.MailingAddress,
        zqu__BillToContact__r.MailingCity,
        zqu__BillToContact__r.MailingPostalCode,
        zqu__BillToContact__r.MailingState,
        zqu__BillToContact__r.MailingStreet,
        zqu__BillToContact__r.MailingCountry
      FROM zqu__Quote__c
      WHERE zqu__SubscriptionType__c = 'Amend Subscription'
      LIMIT 1
    ];

    ZuoraQuoteValidations.validateSoldToBillTo(quote);
    Test.stopTest();
  }
}

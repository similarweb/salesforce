@isTest
public with sharing class ReadyForSubmitButtonControllerTest {
  @testSetup
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
    quote.Add_Finance_Information__c = false;
    quote.email_confirmation_has_been_uploaded__c = true;
    insert quote;
  }

  @isTest
  static void readyFoSubmitQuoteTest() {
    Test.startTest();
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    ReadyForSubmitButtonController.readyFoSubmitQuote(quote.Id, true);
    Test.stopTest();
  }

  @isTest
  static void readyFoSubmitQuoteFalseTest() {
    Test.startTest();
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    quote.email_confirmation_has_been_uploaded__c = false;
    update quote;
    ReadyForSubmitButtonController.readyFoSubmitQuote(quote.Id, true);
    Test.stopTest();
  }
}

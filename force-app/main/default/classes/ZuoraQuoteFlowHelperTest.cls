@isTest
public with sharing class ZuoraQuoteFlowHelperTest {
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
  }

  @isTest
  static void test() {
    insert TestDataFactory.createZuoraQuoteApprovalSettings_CS(true);
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
    Contact contact = [SELECT Id FROM Contact LIMIT 1];
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, contact);
    quote.zqu__PaymentMethod__c = 'Other';
    quote.zqu_Quote_Status__c = 'New';
    Test.startTest();
    insert quote;
    Test.stopTest();
  }
}

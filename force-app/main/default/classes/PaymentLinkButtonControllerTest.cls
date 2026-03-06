@isTest
private class PaymentLinkButtonControllerTest {
  @testSetup
  static void setup() {
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

    Account a = TestDataFactory.createAccount();
    a.billingcountry = 'Israel';
    insert a;
    Contact c = TestDataFactory.createContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.createOpportunity(a);
    insert opp;
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    insert quote;
  }

  @isTest
  static void testSetRenewalLinkGeneratedTimestamp() {
    zqu__Quote__c quoteBefore = getTestQuote();
    Test.startTest();
    PaymentLinkButtonController.setRenewalLinkGeneratedTimestamp(
      quoteBefore.Id
    );
    Test.stopTest();
    zqu__Quote__c quoteAfter = getTestQuote();
    System.assertNotEquals(
      quoteBefore.Link_Generated_for_Renewal_Timestamp__c,
      quoteAfter.Link_Generated_for_Renewal_Timestamp__c,
      'Link generated timestamp update expected'
    );
  }

  @isTest
  static void testSendEmailNotificationSuccess() {
    zqu__Quote__c quoteBefore = getTestQuote();
    Test.startTest();
    String res = PaymentLinkButtonController.sendEmailNotification(
      quoteBefore.Id,
      'test',
      new List<String>{ 'testing@test.com' }
    );
    Test.stopTest();
    zqu__Quote__c quoteAfter = getTestQuote();
    System.assert(
      quoteAfter.Renewal_Email_Sent__c,
      'Renewal Email sent to client checkbox expected to be true'
    );
  }

  @isTest
  static void testCreateZendeskTicket() {
    zqu__Quote__c quoteBefore = getTestQuote();
    MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, mock);
    String zendeskTicketId = PaymentLinkButtonController.createZendeskTicket(
      quoteBefore.Id
    );
    Test.stopTest();
    zqu__Quote__c quoteAfter = getTestQuote();
    System.assertNotEquals(null, zendeskTicketId, 'Zendesk ticket ID expected');
    System.assertEquals(
      zendeskTicketId,
      quoteAfter.Billing_ticket_number_in_Zendesk__c,
      'Zendesk ticket ID field update expected'
    );
  }

  static zqu__Quote__c getTestQuote() {
    return [
      SELECT
        Id,
        Link_Generated_for_Renewal_Timestamp__c,
        Renewal_Email_Sent__c,
        Billing_ticket_number_in_Zendesk__c
      FROM zqu__Quote__c
      LIMIT 1
    ];
  }
}

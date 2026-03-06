/**
 * @author Itzik Winograd
 * @date 21/02/2021
 * @description: Test class for the TransferEmailSubscriptionRecords
 */
@isTest
public class TransferEmailSubscriptionRecordsTest {
  /**
   * @author Itzik Winograd
   * @date 21/07/2021
   * @description test setup, create Leads with attached email subscriptions.
   * @Expected:  The new Cotact - the converted lead - received the value in the Employees_Min__c from the Account.
   */
  @testSetup
  public static void testEmailSubscription() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );

    Lead myLead = new Lead(
      LastName = 'lastName',
      email = 'testLead@testLead.com',
      Company = 'testComp'
    );
    insert myLead;

    Email_Subscription__c emSub = new Email_Subscription__c(
      Lead__c = myLead.Id
    );
    insert emSub;
  }
  /**
   * @author Itzik Winograd
   * @date 21/07/2021
   * @description Convert leads. make sure Email_Subscription__c records moved to the contact.
   * @Expected:  The new Cotact - the converted one - received all the Email_Subscription__c recrods,
   *             and the lead got none left.
   */
  @isTest
  public static void testEmailSubscriptionLeadConvert() {
    Lead myLead = [SELECT Id FROM Lead LIMIT 1];
    Database.LeadConvert lc = new database.LeadConvert();
    lc.setLeadId(myLead.id);
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    lc.setConvertedStatus(convertStatus.MasterLabel);
    Test.startTest();
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    Test.stopTest();
    List<Email_Subscription__c> emSubsOnLead = new List<Email_Subscription__c>(
      [
        SELECT Id, Lead__c
        FROM Email_Subscription__c
        WHERE Lead__c = :myLead.Id
      ]
    );
    System.debug('@@@ emSubsOnLead: ' + emSubsOnLead);
    System.assert(
      emSubsOnLead.size() > 0,
      'no Email_Subscription__c found under the Lead!'
    );

    List<Email_Subscription__c> emSubsOnContact = new List<Email_Subscription__c>(
      [
        SELECT Id, Contact__c
        FROM Email_Subscription__c
        WHERE Contact__c != NULL
      ]
    );
    System.debug('@@@ emSubsOnContact: ' + emSubsOnContact);

    System.assert(
      emSubsOnContact.size() > 0,
      'not Email_Subscription__c found under the Contact!'
    );
  }
}

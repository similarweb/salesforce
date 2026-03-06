/**
 * Created by Alon.Shalev on 10/20/2024.
 */

@IsTest
public class MqlScoreCtrlTest {
  // Create test data for Lead and Contact
  @TestSetup
  static void setupTestData() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Lead lead = new Lead(
      FirstName = 'Test',
      LastName = 'Lead',
      Company = 'Test Company',
      First_MQL_Date__c = Date.today(),
      SW_Fit_Score__c = 'B',
      First_Owner_Assigned_Timestamp__c = System.now(),
      Email = 'lead1@gmail.com'
    );
    insert lead;

    Contact contact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      First_MQL_Date__c = Date.today(),
      First_Owner_Assigned_Timestamp__c = System.now(),
      SW_Fit_Score__c = 'A',
      Email = 'contact1@gmail.com'
    );
    insert contact;
  }

  // Test for valid Lead record
  @IsTest
  static void testGetRecordDataWithLead() {
    Lead testLead = [SELECT Id FROM Lead LIMIT 1];

    Map<String, Object> result = MqlScoreCtrl.getRecordData(
      testLead.Id,
      'Lead'
    );

    System.assertEquals('Nurture', result.get('mql_status'));
  }

  // Test for valid Contact record
  @IsTest
  static void testGetRecordDataWithContact() {
    Contact testContact = [SELECT Id FROM Contact LIMIT 1];

    Map<String, Object> result = MqlScoreCtrl.getRecordData(
      testContact.Id,
      'Contact'
    );

    System.assertEquals('Nurture', result.get('mql_status'));
  }

  @IsTest
  static void testGetMQLScoreTableInfoFromApex() {
    Contact testContact = [SELECT Id FROM Contact LIMIT 1];
    Campaign campaign = new Campaign(Name = 'Test Campaign');
    insert campaign;
    CampaignMember campaignMember = new CampaignMember(
      CampaignId = campaign.Id,
      ContactId = testContact.Id,
      Status = 'Sent',
      Campaign_name_from_leadcapture__c = 'empty'
    );
    insert campaignMember;

    Map<String, Object> result = MqlScoreCtrl.getMQLScoreTableInfoFromApex(
      testContact.Id,
      'Contact'
    );

    System.assertEquals(true, result.get('isSuccess'));
  }
}

/**
 * Created by Alon.Shalev on 11/20/2023.
 */

@isTest
public class CampaignMemberHandlerTest {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;

    InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
    ismTest.SW_Industry__c = 'AdTech and AdNetwork';
    ismTest.Department__c = 'BI / Analytics';
    ismTest.Inferred_Solution__c = 'Research';
    ismTest.Name = 'test';
    insert ismTest;
  }

  //    @isTest
  //    static void testCampaignMemberInsertTrigger() {
  //        // Create test data for the Campaign Member insert trigger
  //        Campaign campaign = new Campaign(Name = 'Test Campaign');
  //        insert campaign;
  //        Lead lead = TestDataFactory.createLead();
  //        insert lead;
  //
  //        CampaignMember campaignMember = new CampaignMember(
  //                CampaignId = campaign.Id,
  //                LeadId = lead.Id,
  //                ContactId = null,
  //                Status = 'Sent'
  //        );
  //        insert campaignMember;
  //
  //        // Query the Campaign Member History Tracking records and add assertions as needed
  //        List<Campaign_Member_History_Tracking__c> historyRecords = [SELECT Id,Changed_Field__c FROM Campaign_Member_History_Tracking__c WHERE Event_Type__c = 'Created'];
  //        System.debug('historyRecords--'+historyRecords.size());
  //        System.assertEquals(false, historyRecords.isEmpty(), 'Expected 14 history record to be created for insert and the list is empty');
  //
  //        // Add more assertions as needed based on your specific requirements
  //    }

  @isTest
  static void testCampaignMemberUpdateTrigger() {
    // Create test data for the Campaign Member update trigger
    Campaign campaign = new Campaign(Name = 'Test Campaign');
    insert campaign;

    Lead lead = TestDataFactory.createLead();
    insert lead;

    CampaignMember campaignMember = new CampaignMember(
      CampaignId = campaign.Id,
      LeadId = lead.Id,
      ContactId = null,
      Status = 'Sent',
      Campaign_name_from_leadcapture__c = 'empty'
    );
    insert campaignMember;

    // Update the Campaign Member record
    campaignMember.Campaign_name_from_leadcapture__c = 'Updated Value';
    update campaignMember;

    // Query the Campaign Member History Tracking records and add assertions as needed
    List<Campaign_Member_History_Tracking__c> historyRecords = [
      SELECT
        Id,
        Changed_Field__c,
        Campaign__c,
        Original_Value__c,
        Changed_value__c
      FROM Campaign_Member_History_Tracking__c
      WHERE Event_Type__c = 'Updated'
      ORDER BY CreatedDate
    ];
    System.assertEquals(
      false,
      historyRecords.isEmpty(),
      'Expected at least 1 history records to be created for update'
    );
    System.assertEquals('empty', historyRecords[0].Original_Value__c);
    System.assertEquals('Updated Value', historyRecords[0].Changed_value__c);
    System.assertEquals(
      'Campaign_name_from_leadcapture__c',
      historyRecords[0].Changed_Field__c
    );
    System.assertEquals(campaign.Id, historyRecords[0].Campaign__c);

    // Add more assertions as needed based on your specific requirements
  }
}

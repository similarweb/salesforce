/**
 * Created by Alon.Shalev on 4/11/2024.
 */
@IsTest
public with sharing class DeleteCampaignMemberHistorySchedulerTest {

    @TestSetup
    public static void testSetup(){
        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
        iss.Name='Default Value';
        iss.Value__c='Sales';
        insert iss;

        InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
        ismTest.SW_Industry__c = 'AdTech and AdNetwork';
        ismTest.Department__c = 'BI / Analytics';
        ismTest.Inferred_Solution__c = 'Research';
        ismTest.Name = 'test';
        insert ismTest;
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
        Campaign_Member_History_Tracking__c camp = new Campaign_Member_History_Tracking__c();
        camp.Campaign_Member_Id__c = campaignMember.Id;
        camp.Event_Type__c = 'Created';

        insert camp;
        Datetime oldDate = Datetime.now().addDays(-200);
        Test.setCreatedDate(camp.Id, oldDate);
    }

    @IsTest
    public static void testDeleteCampaignHistoryTracking(){
        List<Campaign_Member_History_Tracking__c> campList = [SELECT CreatedDate FROM Campaign_Member_History_Tracking__c];
        System.debug('@@@ before running scheduler - campList: ' + campList);
        String CRON_EXP = '0 0 0 3 9 ? 2100';
        Test.startTest();
        System.schedule('DeleteIndividualEmilSchedulerTest',CRON_EXP, new DeleteCampaignMemberHistoryScheduler());
        Database.executeBatch(new DeleteRecordsBatch('Campaign_Member_History_Tracking__c'), 200);
        Test.stopTest();
        campList = [SELECT Id FROM Campaign_Member_History_Tracking__c];
        System.assertEquals(0, campList.size(), 'not all campaignHistoryTracking were deleted!');
    }

}
@isTest
public class CreateCampaignFromEmailResultBatchTest {

    @testSetup
    static void setup() {
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

        InferralSolutionMapContact__c ismCTest = new InferralSolutionMapContact__c();
        ismCTest.SW_Industry__c = 'AdTech and AdNetwork';
        ismTest.Department__c = 'BI / Analytics';
        ismCTest.Inferred_Solution__c = 'Research';
        ismCTest.Name = 'test';
        insert ismCTest;

        Inferral_Solution_Valid_Criteria_List__c islvcl = new Inferral_Solution_Valid_Criteria_List__c();
        islvcl.Name='department__c';
        islvcl.Is_Valid__c=true;
        insert islvcl;

        Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
        islvcl2.Name='sw_industry__c';
        islvcl2.Is_Valid__c=true;
        insert islvcl2;

        InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
        islcvcl.Name='department__c';
        islcvcl.Is_Valid__c=true;
        insert islcvcl;

        InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
        islcvcl2.Name='sw_industry__c';
        islcvcl2.Is_Valid__c=true;
        insert islcvcl2;
        Campaign campaign = new Campaign(Name = 'Test Campaign');
        insert campaign;
        Lead l1 = TestDataFactory.createLead();
        insert l1;
        // Create test data for et4ae5__IndividualEmailResult__c with the same prefix name
        String prefixName = 'Test Email -- 1'; // Example prefix name
        et4ae5__Automated_Send__c triggeredSend = new et4ae5__Automated_Send__c();
        triggeredSend.Name = 'test';
        insert triggeredSend;
        et4ae5__IndividualEmailResult__c emailResult1 = new et4ae5__IndividualEmailResult__c(
                Name = 'Test Campaign -- for this test',
                et4ae5__Opened__c = true,
                et4ae5__TriggeredSendDefinition__c = triggeredSend.Id,
                et4ae5__Lead__c = l1.Id
        );
        et4ae5__IndividualEmailResult__c emailResult2 = new et4ae5__IndividualEmailResult__c(
                Name = prefixName,
                et4ae5__Opened__c = true,
                et4ae5__TriggeredSendDefinition__c = triggeredSend.Id,
                et4ae5__Lead__c = l1.Id
        );
        insert new List<et4ae5__IndividualEmailResult__c>{emailResult1, emailResult2};
    }

    @isTest
    static void testCreateCampaignsFromEmailResults() {
        // Start the batch job
        Test.startTest();
        CreateCampaignFromEmailResultBatch batchJob = new CreateCampaignFromEmailResultBatch();
        ID batchInstanceId = Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify that only one campaign was created
        List<Campaign> createdCampaigns = [SELECT Name,Type,Channel__c,SFMC_Journey_Name__c FROM Campaign];
        List<CampaignMember> createdCampaignMembersList = [SELECT id,CampaignId,Status FROM CampaignMember WHERE CampaignId IN:createdCampaigns];
        System.debug('createdCampaignMembersList--'+createdCampaignMembersList);
        System.assertEquals(2, createdCampaigns.size());
        System.assertEquals(2, createdCampaignMembersList.size());
//        System.assertEquals('Opened', createdCampaignMembersList[0].Status);
//        System.assertEquals('Opened', createdCampaignMembersList[1].Status);
        System.assertEquals(createdCampaigns[0].Id, createdCampaignMembersList[0].CampaignId);
        System.assertEquals(createdCampaigns[1].Id, createdCampaignMembersList[1].CampaignId);

        // Assert other details about the campaign as needed
        Campaign createdCampaign = createdCampaigns[1];
        System.assertEquals('Test Email', createdCampaign.Name);
        System.assertEquals('Email', createdCampaign.Type);
        System.assertEquals('Email SFMC', createdCampaign.Channel__c);
        System.assertEquals('Test Email', createdCampaign.SFMC_Journey_Name__c);
    }

    @isTest
    public static void testSchedule(){
        String CRON_EXP = '0 0 0 3 9 ? 2050';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('CreateCampaignFromEmailResultBatch '+Datetime.now(),CRON_EXP,
                new CreateCampaignFromEmailResultBatch());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger
        WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2050-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }

}
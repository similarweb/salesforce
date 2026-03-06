/**
 * Created by Alon.Shalev on 9/7/2023.
 */
@isTest
public with sharing class CancelUnTouchOpenMeetingsBatchTest {

    @isTest static void testMeetingBatch() {

        // Setup Test Data
        List<Meeting__c> meetingsToInsert = new List<Meeting__c>();

        // Meeting which should not be affected by the batch due to status
        Meeting__c completedMeeting = new Meeting__c(Status__c = 'Completed');
        meetingsToInsert.add(completedMeeting);

        // Meeting which should be affected by the batch
        Meeting__c openMeeting = new Meeting__c(Status__c = 'Open');
        meetingsToInsert.add(openMeeting);

        // Insert the meetings
        insert meetingsToInsert;

        // Create an instance of the batch class
        CancelUnTouchOpenMeetingsBatch batchInstance = new CancelUnTouchOpenMeetingsBatch(1);

        // Execute the batch
        Test.startTest();
        Id batchProcessId = Database.executeBatch(batchInstance);
        Test.stopTest();

        // Fetch the meetings again after the batch process
        List<Meeting__c> updatedMeetings = [SELECT Id, Status__c FROM Meeting__c WHERE Id IN :meetingsToInsert];

        // Verify that the open meeting has been updated, but the completed one hasn't.
        for(Meeting__c m : updatedMeetings) {
            if(m.Id == openMeeting.Id) {
                System.assertEquals('Cancelled', m.Status__c, 'Open meeting status should be updated to Cancelled');
            } else if(m.Id == completedMeeting.Id) {
                System.assertEquals('Completed', m.Status__c, 'Completed meeting status should not be updated');
            }
        }
    }

    @isTest static void testSchedule() {
        // Schedule the batch
        String CRON_EXP = '0 0 0 11 10 ? 2100';
        CancelUnTouchOpenMeetingsBatch batchInstance = new CancelUnTouchOpenMeetingsBatch(1);
        Test.startTest();
        String jobId = System.schedule('Test Scheduled Batch', CRON_EXP, batchInstance);
        Test.stopTest();
        //assert
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
        FROM CronTrigger
        WHERE id = :jobId];

        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2100-10-11 00:00:00', String.valueOf(ct.NextFireTime));
    }
}
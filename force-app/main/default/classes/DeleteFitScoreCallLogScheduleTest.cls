/**
 * Created by alonshalev on 24/01/2023.
 */

@IsTest
public with sharing class DeleteFitScoreCallLogScheduleTest {

    @IsTest
    public static void DeleteFitScoreCallLogScheduleTest(){

        String CRON_EXP = '0 0 0 3 9 ? 2100';
        Test.startTest();
        String jobId = System.schedule('DeleteFitScoreCallLogScheduleTest',CRON_EXP, new DeleteFitScoreCallLogSchedule());
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                NextFireTime
        FROM CronTrigger WHERE id = :jobId];
        // assert
        System.assertEquals('2100-09-03 00:00:00',
                String.valueOf(ct.NextFireTime));

    }

}
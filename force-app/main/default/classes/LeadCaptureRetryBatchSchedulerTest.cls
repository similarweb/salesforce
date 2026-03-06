/**
 * @author Zohar Sinay
 * @date 5/04/2022
 */
@isTest
public with sharing class LeadCaptureRetryBatchSchedulerTest {
  @isTest
  public static void test() {
    String CRON_EXP = '0 0 0 11 10 ? 2050';
    Test.startTest();
    // Schedule the test job
    String jobId = System.schedule(
      'LeadCaptureRetryBatchScheduler',
      CRON_EXP,
      new LeadCaptureRetryBatchScheduler(7)
    );
    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];
    // Verify the expressions are the same
    System.assertEquals(CRON_EXP, ct.CronExpression);
    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);
    // Verify the next time the job will run
    System.assertEquals('2050-10-11 00:00:00', String.valueOf(ct.NextFireTime));
    Test.stopTest();
  }
}

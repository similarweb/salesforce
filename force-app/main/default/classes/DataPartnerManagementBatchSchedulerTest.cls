/**
 * Created by zohar.sinay on 27/07/2022.
 */

/**
 * @author Zohar Sinay
 * @date 27/07/2022
 * @description DataPartnerManagementBatchScheduler Test class
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public with sharing class DataPartnerManagementBatchSchedulerTest {
  /**
   * @author Zohar Sinay
   * @date 27/07/2022
   * @description: Run a schedulable batch, then verify that the schedulable has not run yet.
   * @expected: No extra jobs are pending
   */
  @isTest
  public static void test() {
    String CRON_EXP = '0 0 0 3 9 ? 2100';
    Test.startTest();
    // Schedule the test job
    String jobId = System.schedule(
      'DataPartnerManagementBatchTest',
      CRON_EXP,
      new DataPartnerManagementBatchScheduler()
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
    System.assertEquals('2100-09-03 00:00:00', String.valueOf(ct.NextFireTime));
    Test.stopTest();
  }
}

/**
 * @author Itzik Winograd
 * @date 10/08/2021
 * @description ShareASaleRetriesScheduler Test class
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public class ShareASaleRetriesSchedulerTest {
  /**
   * @author Itzik Winograd
   * @date 15/08/2021
   * @description: Run a schedulable batch, then verify that the schedulable has not run yet.
   * @expected:
   * @param Database.BatchableContext BC.
   * @param List<SObject> scope.
   */
  @isTest
  public static void test() {
    String CRON_EXP = '0 0 0 3 9 ? 2050';
    Test.startTest();
    // Schedule the test job
    String jobId = System.schedule(
      'ShareASaleRetriesScheduler',
      CRON_EXP,
      new ShareASaleRetriesScheduler()
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
    System.assertEquals('2050-09-03 00:00:00', String.valueOf(ct.NextFireTime));
    Test.stopTest();
  }
}

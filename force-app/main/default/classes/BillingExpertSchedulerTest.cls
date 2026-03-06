/**
 * @author Itzik Winograd
 * @date 04/08/2022
 * @description BillingExpertScheduler Test
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public class BillingExpertSchedulerTest {
  /**
   * @author Itzik Winograd
   * @date 04/08/2022
   * @description: Run a schedulable batch, then verify that the schedulable has not run yet.
   * @expected:
   * @param Database.BatchableContext BC.
   * @param List<SObject> scope.
   */
  @isTest
  public static void billingExpertSchedulerTest() {
    String CRON_EXP = '0 0 0 3 9 ? 2100';
    Test.startTest();
    // Schedule the test job
    String jobId = System.schedule(
      'BillingExpertSchedulerTest',
      CRON_EXP,
      new BillingExpertScheduler()
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

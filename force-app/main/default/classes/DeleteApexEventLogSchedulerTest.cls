/**
 * Created by Alon.Shalev on 5/1/2023.
 */
@IsTest
public with sharing class DeleteApexEventLogSchedulerTest {
  @IsTest
  public static void testSchedule() {
    String CRON_EXP = '0 0 0 3 9 ? 2100';
    Test.startTest();
    System.schedule(
      'DeleteApexEventLogScheduler',
      CRON_EXP,
      new DeleteApexEventLogScheduler()
    );
    Test.stopTest();
  }
}

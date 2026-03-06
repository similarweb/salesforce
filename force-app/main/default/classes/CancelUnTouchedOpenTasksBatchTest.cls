/**
 * Created by Alon.Shalev on 9/7/2023.
 */
@isTest
public with sharing class CancelUnTouchedOpenTasksBatchTest {
  @isTest
  static void testBatch() {
    // Setup Test Data
    List<Task> tasksToInsert = new List<Task>();

    // Task which should not be affected by the batch
    Task completedTask = new Task(
      Subject = 'Recent Task',
      Status = 'Completed'
    );
    tasksToInsert.add(completedTask);

    // Task which should be affected by the batch
    Task oldTask = new Task(Subject = 'Old Task', Status = 'Deferred');
    tasksToInsert.add(oldTask);

    // Insert the tasks
    insert tasksToInsert;

    // Create an instance of the batch class
    CancelUnTouchedOpenTasksBatch batchInstance = new CancelUnTouchedOpenTasksBatch(
      1
    );

    // Execute the batch
    Test.startTest();
    Id batchProcessId = Database.executeBatch(batchInstance);
    Test.stopTest();

    // Fetch the tasks again after the batch process
    List<Task> updatedTasks = [
      SELECT Id, Status
      FROM Task
      WHERE Id IN :tasksToInsert
    ];

    // Verify that the old task has been updated, but the recent one hasn't.
    for (Task t : updatedTasks) {
      if (t.Id == oldTask.Id) {
        System.assertEquals(
          'Cancelled / Irrelevant',
          t.Status,
          'Old task status should be updated'
        );
      } else if (t.Id == completedTask.Id) {
        System.assertEquals(
          'Completed',
          t.Status,
          'Recent task status should not be updated'
        );
      }
    }
  }

  @isTest
  static void testSchedule() {
    // Schedule the batch
    String CRON_EXP = '0 0 0 11 10 ? 2100';
    CancelUnTouchedOpenTasksBatch batchInstance = new CancelUnTouchedOpenTasksBatch(
      1
    );
    Test.startTest();
    String jobId = System.schedule(
      'Test Scheduled Batch',
      CRON_EXP,
      batchInstance
    );
    Test.stopTest();
    //assert
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];

    System.assertEquals(CRON_EXP, ct.CronExpression);
    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);
    // Verify the next time the job will run
    System.assertEquals('2100-10-11 00:00:00', String.valueOf(ct.NextFireTime));
  }
}

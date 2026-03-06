/**
 * Created by Alon.Shalev on 3/10/2025.
 */

@isTest
public class DeleteArchivedTasksBatchTest {

    @testSetup
    static void setupTestData() {
        List<Task> testTasks = new List<Task>();

        // Create archived tasks
        for (Integer i = 0; i < 10; i++) {
            Task t = new Task(
                    Subject = 'Archived Task ' + i,
                    Status = 'Completed',
                    ActivityDate = Date.today().addYears(-3) // Ensure it's old enough to be archived
            );
            testTasks.add(t);
        }

        // Create active tasks (should NOT be deleted)
        for (Integer i = 0; i < 5; i++) {
            Task t = new Task(
                    Subject = 'Active Task ' + i,
                    Status = 'Not Started',
                    ActivityDate = Date.today()
            );
            testTasks.add(t);
        }

        insert testTasks;
    }

    @isTest
    static void testBatchExecution() {
        // Verify setup data
        Test.startTest();

        Integer archivedBefore = [SELECT COUNT() FROM Task WHERE IsArchived = TRUE ALL ROWS];
        Integer activeBefore = [SELECT COUNT() FROM Task WHERE IsArchived = FALSE ALL ROWS];

        // Run the batch
        DeleteArchivedTasksBatch batchJob = new DeleteArchivedTasksBatch();
        Database.executeBatch(batchJob, 5); // Small batch size for test execution

        Test.stopTest();

        // Verify that only archived tasks were deleted
        Integer archivedAfter = [SELECT COUNT() FROM Task WHERE IsArchived = TRUE ALL ROWS];
        Integer activeAfter = [SELECT COUNT() FROM Task WHERE IsArchived = FALSE ALL ROWS];

        System.assertEquals(0, archivedAfter, 'All archived tasks should be deleted.'); // doesnt really works
        System.assertEquals(activeBefore, activeAfter, 'Active tasks should not be deleted.');// doesnt really works
    }
}
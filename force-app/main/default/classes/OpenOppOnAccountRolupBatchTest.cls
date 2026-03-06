@isTest
public class OpenOppOnAccountRolupBatchTest {

    @isTest
    static void testBatchExecution() {
        // Setup - Create test data
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Opportunity openOpp1 = new Opportunity(
                Name = 'Open Opportunity 1',
                CloseDate = System.today().addDays(10),
                StageName = 'Prospecting',
                AccountId = testAcc.Id
        );
        Opportunity openOpp2 = new Opportunity(
                Name = 'Open Opportunity 2',
                CloseDate = System.today().addDays(20),
                StageName = 'Prospecting',
                AccountId = testAcc.Id
        );
        insert new List<Opportunity>{ openOpp1, openOpp2 };
        List<Opportunity> asd = [SELECT Id, IsClosed FROM Opportunity];
        System.debug(asd);

        Test.startTest();
        OpenOppOnAccountRolupBatch batch = new OpenOppOnAccountRolupBatch();
        ID batchProcessID = Database.executeBatch(batch, 50);
        Test.stopTest();

        // After the batch process finishes, validate the results
        Account updatedAcc = [SELECT NumberOfOpenOpps__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(2, updatedAcc.NumberOfOpenOpps__c);
    }

    @isTest
    static void testBatchExecutionWithNoOpportunities() {
        // Setup - Create test data
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        Test.startTest();
        OpenOppOnAccountRolupBatch batch = new OpenOppOnAccountRolupBatch();
        ID batchProcessID = Database.executeBatch(batch, 50);
        Test.stopTest();

        // After the batch process finishes, validate the results
        Account updatedAcc = [SELECT NumberOfOpenOpps__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(0, updatedAcc.NumberOfOpenOpps__c);
    }
    @isTest
    static void testSchedulableExecution() {
        // Schedule the batch job
        String cronExpression = '0 0 0 15 3 ? 2122';
        OpenOppOnAccountRolupBatch batch = new OpenOppOnAccountRolupBatch();
        String jobID = System.schedule('OpenOppOnAccountRolupBatchTest', cronExpression, batch);

        // Query the scheduled job
        CronTrigger scheduledJob = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobID];
        System.assertEquals(cronExpression, scheduledJob.CronExpression);


    }
}
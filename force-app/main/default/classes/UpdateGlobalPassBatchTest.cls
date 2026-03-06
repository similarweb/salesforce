@isTest
public class UpdateGlobalPassBatchTest {

    // Test method for scheduling the batch
    @isTest
    public static void testScheduleUpdateGlobalPassBatch() {
        String CRON_EXP = '0 0 0 3 9 ? 2100';
        String jobId = System.schedule('UpdateGlobalPassBatchTest', CRON_EXP, new UpdateGlobalPassBatch());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                NextFireTime
        FROM CronTrigger WHERE id = :jobId];
        // assert
        System.assertEquals('2100-09-03 00:00:00',
                String.valueOf(ct.NextFireTime));


    }

    // Test method for batch execution using Database.executeBatch
    @isTest
    public static void testExecuteUpdateGlobalPassBatch() {
        // Create test data: Zuora__SubscriptionProductCharge__c and related Account records
        Account testAccount = new Account(Name = 'Test Account', Global_Pass__c = false);
        insert testAccount;

        Zuora__SubscriptionProductCharge__c testCharge = new Zuora__SubscriptionProductCharge__c(
                Name = 'Test Charge',
                Zuora__Account__c = testAccount.Id,
                Zuora__ProductName__c = 'Global User',
                Zuora__Type__c = 'Recurring',
                Zuora__EffectiveEndDate__c = Date.today().addMonths(1)
        );
        insert testCharge;
        Zuora__SubscriptionProductCharge__c letsSee = [SELECT Id,CreatedDate,Zuora__ProductName__c,Status__c FROM Zuora__SubscriptionProductCharge__c WHERE Id =:testCharge.id];
        System.debug('letsSee--'+letsSee);
        System.debug('letsSee--'+letsSee.Status__c);

        // Create and execute the batch using Database.executeBatch
        Test.startTest();
        UpdateGlobalPassBatch updateGlobalPassBatch = new UpdateGlobalPassBatch();
        Id batchInstanceId = Database.executeBatch(updateGlobalPassBatch);

        // Query the AsyncApexJob object to check the batch status if needed
        AsyncApexJob batchJobInfo = [SELECT Id, Status FROM AsyncApexJob WHERE Id = :batchInstanceId];
        Test.stopTest();

        // You can add assertions related to batch job status if needed
        System.assertNotEquals(null, batchInstanceId);
    }
}
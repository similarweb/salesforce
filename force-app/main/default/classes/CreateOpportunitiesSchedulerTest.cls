/**
* @author Itzik Winograd
* @date 10/10/2021
* @description CreateOpportunitiesScheduler Test class
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
@isTest
public class CreateOpportunitiesSchedulerTest {
	 /** 
    * @author Itzik Winograd
    * @date 10/10/2021
    * @description: Run a schedulable batch, then verify that the schedulable has not run yet.
    * @expected: 
    */
    @IsTest
    public static void createOpportunitiesSchedulerTest(){
        String CRON_EXP = '0 0 0 11 10 ? 2100';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('CreateOpportunitiesSchedulerTest',CRON_EXP,
                                       new CreateOpportunitiesScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger 
                          WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2100-10-11 00:00:00', String.valueOf(ct.NextFireTime));
       	Test.stopTest();   
    }
}
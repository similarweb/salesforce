@isTest
private class NoTouchProcessScheduleTest {
  @isTest
  static void testScheduledExecution() {
    // Step 1: Create a mock NoTouchObj with sample data
    NoTouchProcess.NoTouchObj testNoTouchObj = new NoTouchProcess.NoTouchObj();
    testNoTouchObj.uid = '12345';
    testNoTouchObj.email = 'test@example.com';
    testNoTouchObj.cname = 'Test Company';
    testNoTouchObj.fName = 'John';
    testNoTouchObj.lName = 'Doe';
    testNoTouchObj.country = 'US';
    testNoTouchObj.websiteDomain = 'example.com';
    testNoTouchObj.industry = 'Software';
    testNoTouchObj.minEmployees = '10';
    testNoTouchObj.maxEmployees = '100';
    testNoTouchObj.NT_Subscription_FirstCharge_Date = Date.today();

    Integer retryCount = 1;

    // Step 2: Schedule the NoTouchProcessSchedule execution
    Test.startTest();
    String jobId = System.schedule(
      'Test NoTouchProcessSchedule',
      '0 0 0 1 1 ? 2099',
      new NoTouchProcessSchedule(testNoTouchObj, retryCount)
    );
    Test.stopTest();

    // Step 3: Verify that the job was scheduled
    System.assertNotEquals(
      jobId,
      null,
      'Job ID should not be null, meaning the job was scheduled successfully.'
    );

    // Step 4: Verify that the Queueable job was enqueued
    Integer queueableJobs = [
      SELECT COUNT()
      FROM AsyncApexJob
      WHERE JobType = 'Queueable' AND Status = 'Queued'
    ];
    System.assert(
      queueableJobs > 0,
      'Queueable job should have been enqueued after scheduled job execution.'
    );
  }
}

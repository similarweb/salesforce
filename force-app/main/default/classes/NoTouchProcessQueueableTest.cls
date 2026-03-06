/**
 * Created by Alon.Shalev on 2/10/2025.
 */
@isTest
public with sharing class NoTouchProcessQueueableTest {

    @isTest
    static void testQueueableExecution() {
        // Mock NoTouchProcess.NoTouchObj
        NoTouchProcess.NoTouchObj testObj = new NoTouchProcess.NoTouchObj();
        testObj.uid = 'testUID';
        testObj.email = 'test@example.com';
        testObj.cname = 'Test Company';
        testObj.fName = 'Test';
        testObj.lName = 'User';
        testObj.country = 'USA';
        testObj.websiteDomain = 'test.com';
        testObj.industry = 'Tech';
        testObj.minEmployees = '10';
        testObj.maxEmployees = '50';
        testObj.NT_Subscription_FirstCharge_Date = Date.today();

        // Number of retries
        Integer retries = 3;

        // Instantiate Queueable Class
        Test.startTest();
        System.enqueueJob(new NoTouchProcessQueueable(testObj, retries));
        Test.stopTest();
    }
}
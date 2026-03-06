@isTest
private class ZSubscriptionUpdateBatchTest {
    
    @testSetup 
    static void setup() {
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
        upsert TestDataFactory.createZuoraQuoteApprovalSettings_CS();
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS(); 

        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;
        
        List<Country_Subsidiary__c> countrySubsidiaries = TestDataFactory.createCountries();
        insert countrySubsidiaries;
    }

    @isTest 
    static void shouldUpdateRenewalDateWhenBatchRuns() {
        List<String> countries = TestDataFactory.getCountries();

        Account testAcc = TestDataFactory.createAccount();
        testAcc.billingcountry = countries[countries.size()-1];
        testAcc.fr_NextRenewalDate__c = null;
        insert testAcc;

        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(testAcc);
        insert billingAcc;

        Date expectedNextRenewalDate = Date.today().addDays(10);
        Zuora__Subscription__c testSub = TestDataFactory.createSubscription(testAcc, billingAcc);
        testSub.Zuora__NextRenewalDate__c = expectedNextRenewalDate;
        insert testSub;

        Test.startTest();
            Database.executeBatch(new ZSubscriptionUpdateBatch(), 50);
        Test.stopTest();

        Account updatedAccount = [SELECT Id, fr_NextRenewalDate__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(expectedNextRenewalDate, updatedAccount.fr_NextRenewalDate__c);
    }

    @isTest
    static void shouldUpdateRenewalDateWhenScheduledJobRuns() {
        List<String> countries = TestDataFactory.getCountries();

        Account testAcc = TestDataFactory.createAccount();
        testAcc.billingcountry = countries[countries.size()-1];
        testAcc.fr_NextRenewalDate__c = null;
        insert testAcc;

        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(testAcc);
        insert billingAcc;

        Date expectedNextRenewalDate = Date.today().addDays(20);
        Zuora__Subscription__c testSub = TestDataFactory.createSubscription(testAcc, billingAcc);
        testSub.Zuora__NextRenewalDate__c = expectedNextRenewalDate;
        insert testSub;

        Test.startTest();
            new ZSubscriptionUpdateBatch().execute((SchedulableContext)null);
        Test.stopTest();

        Account updatedAccount = [SELECT Id, fr_NextRenewalDate__c FROM Account WHERE Id = :testAcc.Id];
        System.assertEquals(expectedNextRenewalDate, updatedAccount.fr_NextRenewalDate__c);
    }
}
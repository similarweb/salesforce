@isTest
private class ZAccountFieldsUpdateTest {
    @testSetup 
    static void setup() {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();

        ZuoraQuoteFlowHelper.isInitialStatusForTestEnabled = false;
		List<String> countries =  TestDataFactory.getCountries();
        Account testAccount = TestDataFactory.createAccount();
        testAccount.billingcountry = countries[countries.size()-1];
        insert testAccount;
        Contact testContact = TestDataFactory.createContact(testAccount, 'test@testing.com');
        testContact.MailingCountry = 'Lalalend';
        insert testContact;
        List<Country_Subsidiary__c> countrySubsidiaries = TestDataFactory.createCountries();
        insert countrySubsidiaries;
        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount);
        insert testOpportunity;  

        zqu__Quote__c testQuote = TestDataFactory.createZQuote (testOpportunity,testContact); 
                      testQuote.zqu__PaymentMethod__c = 'Other';
                      testQuote.Customer_Type__c = 'Company';
                      testQuote.Is_from_existing_Billing_Account__c = false;
                      testQuote.zqu__Account__c = testAccount.Id;
                      testQuote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
                      testQuote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
                      testQuote.zqu__SubscriptionTermEndDate__c = Date.today().addDays(2);
        insert testQuote;
    }

    @isTest 
    static void testMethod1() {
        Id quoteId = [SELECT Id FROM zqu__Quote__c LIMIT 1].Id;
        ZAccountFieldsUpdate accountUpdateJob = new ZAccountFieldsUpdate(new Set<Id>{quoteId});
        MockUtil.ZuoraApiServiceMockProvider mockServiceInstance = new MockUtil.ZuoraApiServiceMockProvider();
                                             mockServiceInstance.updateAccountCertificateIdResponse = true;
        ZuoraApiService mockService = (ZuoraApiService)Test.createStub(ZuoraApiService.class, mockServiceInstance);
        accountUpdateJob.apiService = mockService;
        Test.startTest();
            System.enqueueJob(accountUpdateJob);
        Test.stopTest();
    }

    @isTest 
    static void testMethod2() {
        Id quoteId = [SELECT Id FROM zqu__Quote__c LIMIT 1].Id;
        ZAccountFieldsUpdate accountUpdateJob = new ZAccountFieldsUpdate(new Set<Id>{quoteId});
        MockUtil.ZuoraApiServiceMockProvider mockServiceInstance = new MockUtil.ZuoraApiServiceMockProvider();
                                             mockServiceInstance.updateAccountCertificateIdResponse = false;
        ZuoraApiService mockService = (ZuoraApiService)Test.createStub(ZuoraApiService.class, mockServiceInstance);
        accountUpdateJob.apiService = mockService;
        try{
            Test.startTest();
                System.enqueueJob(accountUpdateJob);
            Test.stopTest();
        } catch(Exception ex){
            System.assertEquals('Update of the Zuora Account failed', ex.getMessage());
        }
    }

}
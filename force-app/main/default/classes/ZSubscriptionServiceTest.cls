@isTest
private class ZSubscriptionServiceTest {
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
		List<String> countries =  TestDataFactory.getCountries();
        
        Account testAccount = TestDataFactory.createAccount();
                testAccount.billingcountry = countries[countries.size()-1];
            testAccount.SI_Employees_Type__c = '1-10';
            testAccount.Website = 'www.example.com';
            testAccount.AccountDomain__c = 'example.com';
            testAccount.No_Touch_Account__c = true;
        insert testAccount;

        Contact testContact = TestDataFactory.createContact(testAccount, 'test@testing.com');
        insert testContact;

        Opportunity testOpportunity = TestDataFactory.createOpportunity(testAccount);
        insert testOpportunity;
        
        List<Country_Subsidiary__c> countrySubsidiaries = TestDataFactory.createCountries();
        insert countrySubsidiaries;
    }

    @isTest 
    static void SubscriptionWithRelatedQuotes_quoteDate_Test() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id testAccountId = testAccount.Id;
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId = :testAccountId LIMIT 1];
        Opportunity testOpportunity = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :testAccountId LIMIT 1];

        zqu__Quote__c testQuote = TestDataFactory.createZQuote(testOpportunity,testContact); 
                      testQuote.zqu__Account__c = testAccountId;
					  testQuote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
                      testQuote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
                      testQuote.zqu__SubscriptionTermEndDate__c = Date.today().addDays(2);
        insert testQuote;

        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(testAccount);
        billingAccount.Zuora__BillToName__c = 'FirstName LastName';
        insert billingAccount;

        Zuora__Subscription__c testSubscription = TestDataFactory.createSubscription(testAccount, billingAccount);
							   testSubscription.Zuora__NextRenewalDate__c = Date.today().addDays(1);
                               testSubscription.Zuora__Status__c = 'Suspended';
        Utils.CodeOff = true;
        insert testSubscription;
        Utils.CodeOff = false;

        Set<Id> accountIds = new Set<Id>{testAccountId};
        ZSubscriptionService service = new ZSubscriptionService();
        Test.startTest();
            List<Account> updatedAccounts = service.updateRelatedAccounts(accountIds);
        Test.stopTest();
    }

    @isTest
    static void SubscriptionWithRelatedQuotes_subscriptionDate_Test() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id testAccountId = testAccount.Id;
        Contact testContact = [SELECT Id FROM Contact WHERE AccountId = :testAccountId LIMIT 1];
        Opportunity testOpportunity = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :testAccountId LIMIT 1];

        zqu__Quote__c testQuote = TestDataFactory.createZQuote(testOpportunity,testContact); 
                      testQuote.zqu__Account__c = testAccountId;
					  testQuote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
                      testQuote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
                      testQuote.zqu__SubscriptionTermEndDate__c = Date.today().addDays(2);
        insert testQuote;

        Zuora__CustomerAccount__c billingAccount = TestDataFactory.createBillingAccount(testAccount);
        billingAccount.Zuora__BillToName__c = 'FirstName LastName';
        insert billingAccount;

        Zuora__Subscription__c testSubscription = TestDataFactory.createSubscription(testAccount, billingAccount);
							   testSubscription.Zuora__NextRenewalDate__c = Date.today().addDays(3);
                               testSubscription.Zuora__Status__c = 'Suspended';
        Utils.CodeOff = true;
        insert testSubscription;
        Utils.CodeOff = false;

        Set<Id> accountIds = new Set<Id>{testAccountId};
        ZSubscriptionService service = new ZSubscriptionService();
        Test.startTest();
            List<Account> updatedAccounts = service.updateRelatedAccounts(accountIds);
        Test.stopTest();
    }

    @isTest 
    static void SubscriptionWithoutRelatedQuotes_Test() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Id testAccountId = testAccount.Id;

        Zuora__CustomerAccount__c billingAcc = TestDataFactory.createBillingAccount(testAccount);
        billingAcc.Zuora__BillToName__c = 'FirstName LastName';
        insert billingAcc;

        Zuora__Subscription__c testSub = TestDataFactory.createSubscription(testAccount, billingAcc);
                               testSub.Zuora__NextRenewalDate__c = Date.today().addDays(2);
                               testSub.Zuora__Status__c = 'Suspended';
        Utils.CodeOff = true;
        insert testSub;
        Utils.CodeOff = false;

        Set<Id> accountIds = new Set<Id>{testAccountId};
        ZSubscriptionService service = new ZSubscriptionService();
        Test.startTest();
            List<Account> updatedAccounts = service.updateRelatedAccounts(accountIds);
        Test.stopTest();
    }

}
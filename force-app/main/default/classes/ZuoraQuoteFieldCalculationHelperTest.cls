@isTest
public with sharing class ZuoraQuoteFieldCalculationHelperTest {
    @testSetup
    static void setup(){
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();     
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS(); 
    }

    @isTest
    static void calculateSubsidiaryForAmendQuote(){
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,c);
        quote2.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote2.package__c = 'Competitive Intelligence - Business';
        quote2.New_solution_use_case__c = 'Competitive Intelligence';
        quote2.Product_Compatibility__c = 'CIB';
        quote2.zqu__PaymentMethod__c = 'Other';
        quote2.Payment_Type__c = 'Wire Transfer';
        quote2.Renewal_Fee__c = 13;
        quote2.zqu__SubscriptionType__c = 'Amend Subscription';
        quote2.zqu__QuoteBusinessType__c = '+ Renewal';
        quote2.zqu__InitialTerm__c = 10;
        insert quote2;
        Test.startTest();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ContentVersion cv = TestDataFactory.createContentVersion();
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert cdl;
        List<Zuora__CustomerAccount__c> bilAccList = new List<Zuora__CustomerAccount__c>{billAcc};
        ZuoraQuoteFieldCalculationHelper.calculateSubsidiaryForAmendQuote(bilAccList);
        Test.stopTest();

    }
    
    @isTest
    static void calculateContractPaymentTerm(){
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,c);
        quote2.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote2.package__c = 'Competitive Intelligence - Business';
        quote2.New_solution_use_case__c = 'Competitive Intelligence';
        quote2.Product_Compatibility__c = 'CIB';
        quote2.zqu__PaymentMethod__c = 'Other';
        quote2.Payment_Type__c = 'Wire Transfer';
        quote2.Renewal_Fee__c = 13;
        quote2.zqu__SubscriptionType__c = 'Amend Subscription';
        quote2.zqu__QuoteBusinessType__c = '+ Renewal';
        quote2.zqu__InitialTerm__c = 10;
        insert quote2;
        Test.startTest();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ContentVersion cv = TestDataFactory.createContentVersion();
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert cdl;
        ZuoraQuoteFieldCalculationHelper.calculateContractPaymentTerm(new List<zqu__Quote__c>{quote2});
        Test.stopTest();
    }
    
    @isTest
    static void calculateContractAmendmentsPaymentTerm(){
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,c);
        quote2.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote2.package__c = 'Competitive Intelligence - Business';
        quote2.New_solution_use_case__c = 'Competitive Intelligence';
        quote2.Product_Compatibility__c = 'CIB';
        quote2.zqu__PaymentMethod__c = 'Other';
        quote2.Payment_Type__c = 'Wire Transfer';
        quote2.Renewal_Fee__c = 13;
        quote2.zqu__SubscriptionType__c = 'Amend Subscription';
        quote2.zqu__QuoteBusinessType__c = '+ Renewal';
        quote2.zqu__InitialTerm__c = 10;
        insert quote2;
        Test.startTest();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ContentVersion cv = TestDataFactory.createContentVersion();
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert cdl;
        List<zqu__Quote__c> result = ZuoraQuoteFieldCalculationHelper.calculateContractPaymentTerm(new List<zqu__Quote__c>{quote2});
        ZuoraQuoteFieldCalculationHelper.calculateContractAmendmentsPaymentTerm(result);
        Test.stopTest();
    }
    
    @isTest
    static void calculateLastSignatureDateForAmendQuote(){
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,c);
        quote2.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote2.package__c = 'Competitive Intelligence - Business';
        quote2.New_solution_use_case__c = 'Competitive Intelligence';
        quote2.Product_Compatibility__c = 'CIB';
        quote2.zqu__PaymentMethod__c = 'Other';
        quote2.Payment_Type__c = 'Wire Transfer';
        quote2.Renewal_Fee__c = 13;
        quote2.zqu__SubscriptionType__c = 'Amend Subscription';
        quote2.zqu__QuoteBusinessType__c = '+ Renewal';
        quote2.zqu__InitialTerm__c = 10;
        insert quote2;
        Test.startTest();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ContentVersion cv = TestDataFactory.createContentVersion();
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert cdl;
        ZuoraQuoteFieldCalculationHelper.calculateLastSignatureDateForAmendQuote(new List<zqu__Quote__c>{quote2});
        Test.stopTest();
    }
    
    @isTest
    static void calculateSubsidiaryForAmendQuote2(){
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,c);
        quote2.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote2.package__c = 'Competitive Intelligence - Business';
        quote2.New_solution_use_case__c = 'Competitive Intelligence';
        quote2.Product_Compatibility__c = 'CIB';
        quote2.zqu__PaymentMethod__c = 'Other';
        quote2.Payment_Type__c = 'Wire Transfer';
        quote2.Renewal_Fee__c = 13;
        quote2.zqu__SubscriptionType__c = 'Amend Subscription';
        quote2.zqu__QuoteBusinessType__c = '+ Renewal';
        quote2.zqu__InitialTerm__c = 10;
        insert quote2;
        Test.startTest();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ContentVersion cv = TestDataFactory.createContentVersion();
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert cdl;
        ZuoraQuoteFieldCalculationHelper.calculateSubsidiaryForAmendQuote(new List<zqu__Quote__c>{quote2});
        Test.stopTest();
    }

    @isTest
    static void calculateNewSaleProducts() {
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,c);
        quote2.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote2.package__c = 'Competitive Intelligence - Business';
        quote2.New_solution_use_case__c = 'Competitive Intelligence';
        quote2.Product_Compatibility__c = 'CIB';
        quote2.zqu__PaymentMethod__c = 'Other';
        quote2.Payment_Type__c = 'Wire Transfer';
        quote2.Renewal_Fee__c = 13;
        quote2.zqu__SubscriptionType__c = 'Amend Subscription';
        quote2.zqu__QuoteBusinessType__c = '+ Renewal';
        quote2.zqu__InitialTerm__c = 10;
        insert quote2;
        Test.startTest();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(a);
        insert billAcc;
        Zuora__Subscription__c sub = TestDataFactory.createSubscription(a, billAcc);
        insert sub;
		Zuora__SubscriptionProductCharge__c subCharge1 = TestDataFactory.createSubProdCharge(sub, 'Month');
        Zuora__SubscriptionProductCharge__c subCharge2 = TestDataFactory.createSubProdCharge(sub, 'Month');
        insert new List<Zuora__SubscriptionProductCharge__c>{subCharge1,subCharge2};
        ContentVersion cv = TestDataFactory.createContentVersion();
        insert cv;
        cv = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(opp.Id,cv.ContentDocumentId);
        insert cdl;
        ZuoraQuoteFieldCalculationHelper.calculateNewSaleProducts(new List<zqu__Quote__c>{quote2});
        Test.stopTest();
    }

    @isTest
    static void calculateTargetPriceForRenewalTest() {
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
        quote.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote.package__c = 'Competitive Intelligence - Business';
        quote.New_solution_use_case__c = 'Competitive Intelligence';
        quote.Product_Compatibility__c = 'CIB';
        quote.zqu__PaymentMethod__c = 'Other';
        quote.Renewal_Fee__c = 13;
        insert quote;
        Test.startTest();
        ZuoraQuoteFieldCalculationHelper.calculateTargetPriceForRenewal(new List<zqu__Quote__c>{quote});
        Test.stopTest();
    }

    @isTest
    static void calculateValidUntilTest() {
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        insert opp;         
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,c);
        quote.Legacy_or_New_solution_deal__c = 'Solution 3.0';
        quote.package__c = 'Competitive Intelligence - Business';
        quote.New_solution_use_case__c = 'Competitive Intelligence';
        quote.Product_Compatibility__c = 'CIB';
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
        Test.startTest();
        ZuoraQuoteFieldCalculationHelper.calculateTargetPriceForRenewal(new List<zqu__Quote__c>{quote});
        Test.stopTest();
    }
}
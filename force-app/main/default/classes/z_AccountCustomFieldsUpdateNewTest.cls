@isTest (SeeAllData=true)
public with sharing class z_AccountCustomFieldsUpdateNewTest {
    
    // @TestSetup
    // static void setup(){
    //     Utils.CodeOff = true;
    //     TestDataFactory.createSimilarWeb_CS();
    //     TestDataFactory.createBaseProductConfiguration_CS();
    //     TestDataFactory.createInferredSolutionSettings_CS();
    //     insert TestDataFactory.createBaseProductContract_CS();
    //     insert TestDataFactory.createBaseProductConfiguration_CS();
    //     insert TestDataFactory.createBaseProductControlling_CS();
    //     insert TestDataFactory.createBaseProductDependent_CS();     
    //     insert TestDataFactory.createBaseProductDefaultAddon_CS();
    //     insert TestDataFactory.createBaseProductDynamicAddon_CS();
    //     insert TestDataFactory.createBaseProductNumOfUsers_CS();
    //     List<String> countries =  TestDataFactory.getCountries();
    //     Account a = TestDataFactory.CreateAccount();
    //     a.billingcountry = 'Israel';
    //     insert a;
    //     Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    //     c.MailingCountry = 'Israel';
    //     insert c;
    //     Opportunity opp = TestDataFactory.CreateOpportunity (a);
    //     insert opp;                  
    //     zqu__Quote__c q = TestDataFactory.createZQuote (opp,c); 
    //     insert q;
    //     zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
    //     qa.zqu__Type__c = 'NewProduct';
    //     insert qa;
    //     Product2 prod = TestDataFactory.createProduct2();
    //     insert prod;
    //     zqu__ProductRatePlan__c prodrp = TestDataFactory.createZuoraProductRatePlan(prod);
    //     insert prodrp;  
    //     ApprovedTermsFrequecy__c atf = TestDataFactory.createATF (q);
    //     insert atf;
    //     zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan (qa);
    //     zqrp.zqu__ProductRatePlan__c = prodrp.Id;
    //     insert zqrp;
    //     // zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
    //     // insert qrpc;
    // }

    @isTest
    static void testSubmitNewSubQuote() {
        createQuoteZObjectMappings();
        zqu__Quote__c quote = [SELECT Id,zqu__Status__c FROM zqu__Quote__c WHERE zqu__Status__c != 'Sent to Z-Billing' AND Is_from_existing_Billing_Account__c!=true AND zqu__SubscriptionType__c = 'New Subscription' LIMIT 1];
        Test.startTest();
        //Change status on quote from "New" to "Sent to Z-Billing"
        quote.zqu__Status__c = 'Sent to Z-Billing';
        update quote;
        
        Test.stopTest();
        
    }

    public static void createQuoteZObjectMappings() {
        Zuora_Quote_to_ZObject_Mapping__c accountMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        accountMapping.Name = 'Test Account Notes';
        accountMapping.Quote_Field__c = 'Name';
        accountMapping.Enable_for_New_Subscriptions__c = true;
        accountMapping.Enable_for_Amendments__c = true;
        accountMapping.Enable_for_Renewals__c = true;
        accountMapping.Zuora_Object__c = 'Account';
        accountMapping.Zuora_Object_Field__c = 'Notes';

        Zuora_Quote_to_ZObject_Mapping__c billToContactMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        billToContactMapping.Name = 'Test Bill To Description';
        billToContactMapping.Quote_Field__c = 'Name';
        billToContactMapping.Enable_for_New_Subscriptions__c = true;
        billToContactMapping.Enable_for_Amendments__c = true;
        billToContactMapping.Enable_for_Renewals__c = true;
        billToContactMapping.Zuora_Object__c = 'Bill To Contact';
        billToContactMapping.Zuora_Object_Field__c = 'Description';

        Zuora_Quote_to_ZObject_Mapping__c soldToContactMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        soldToContactMapping.Name = 'Test Sold To Description';
        soldToContactMapping.Quote_Field__c = 'Name';
        soldToContactMapping.Enable_for_New_Subscriptions__c = true;
        soldToContactMapping.Enable_for_Amendments__c = true;
        soldToContactMapping.Enable_for_Renewals__c = true;
        soldToContactMapping.Zuora_Object__c = 'Sold To Contact';
        soldToContactMapping.Zuora_Object_Field__c = 'Description';

        Zuora_Quote_to_ZObject_Mapping__c subMapping = new Zuora_Quote_to_ZObject_Mapping__c();
        subMapping.Name = 'Test Subscription Notes';
        subMapping.Quote_Field__c = 'Name';
        subMapping.Enable_for_New_Subscriptions__c = true;
        subMapping.Enable_for_Amendments__c = true;
        subMapping.Enable_for_Renewals__c = true;
        subMapping.Zuora_Object__c = 'Subscription';
        subMapping.Zuora_Object_Field__c = 'Notes';

        insert new List<Zuora_Quote_to_ZObject_Mapping__c>{accountMapping, billToContactMapping, soldToContactMapping, subMapping};
    }
}
@isTest
public class ZQuoteRatePlanChargeDomainTest {
    @TestSetup
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
        List<String> countries =  TestObjectCreator.getCountries();
        Account a = TestObjectCreator.CreateAccount();
        a.billingcountry = countries[countries.size()-1];
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        c.MailingCountry = countries[countries.size()-1];
        insert c;
        list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        Opportunity o = TestObjectCreator.CreateOpportunity (a);
        insert o;                
        zqu__Quote__c q = TestDataFactory.createZQuote (o,c); 
        insert q;
        zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
        qa.zqu__Type__c = 'NewProduct';
        insert qa;
        Product2 prod = TestDataFactory.createProduct2();
        insert prod;
        zqu__ProductRatePlan__c prodrp = TestDataFactory.createZuoraProductRatePlan(prod);
        insert prodrp;  
        ApprovedTermsFrequecy__c atf = TestDataFactory.createATF (q);
        insert atf;
        zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan (qa);
        zqrp.zqu__ProductRatePlan__c = prodrp.Id;
        insert zqrp;
        // zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
        // insert qrpc;
    }

    @isTest
    public static void onAfterInsertTest(){       
        zqu__QuoteRatePlan__c zqrp = [SELECT Id,zqu__Quote__c FROM zqu__QuoteRatePlan__c LIMIT 1];
        // Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
        insert qrpc;
        System.debug(qrpc.Quote__c);
        // Test.stopTest();
    }

    @isTest
    public static void onAfterUpdateTest(){       
        zqu__QuoteRatePlan__c zqrp = [SELECT Id,zqu__Quote__c FROM zqu__QuoteRatePlan__c LIMIT 1];
        zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
        qrpc.zqu__ListTotal__c = 1100;
        insert qrpc;
        // Test.startTest();
        qrpc.zqu__ListTotal__c = 1000;
        update qrpc;
        System.debug(qrpc.Quote__c);
        // Test.stopTest();
    }

    /* @isTest
    public static void apiHitsTest(){       
        Utils.CodeOff = true; 
        zqu__QuoteRatePlan__c zqrp = [SELECT Id FROM zqu__QuoteRatePlan__c LIMIT 1];
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge (zqrp);
        qrpc.Name = 'Marketing Premium 8K Monthly API Hits';
        insert qrpc;
        Test.stopTest();
        zqu__Quote__c quote = [SELECT Id, Dynamic_Base_Product_API_Hits__c FROM zqu__Quote__c LIMIT 1];
        System.assertEquals('Marketing Premium 8K Monthly API Hits', quote.Dynamic_Base_Product_API_Hits__c);
    }

    @isTest
    public static void historicalDataTest(){       
        Utils.CodeOff = true; 
        zqu__QuoteRatePlan__c zqrp = [SELECT Id FROM zqu__QuoteRatePlan__c LIMIT 1];
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge (zqrp);
        qrpc.Name = 'Marketing - 9 Months of Historical Data';
        insert qrpc;
        Test.stopTest();
        zqu__Quote__c quote = [SELECT Id, Dynamic_Base_Product_Historical_Data__c FROM zqu__Quote__c LIMIT 1];
        System.assertEquals('Marketing - 9 Months of Historical Data', quote.Dynamic_Base_Product_Historical_Data__c);
    }

    @isTest
    public static void numOfUsersTest(){       
        Utils.CodeOff = true; 
        zqu__QuoteRatePlan__c zqrp = [SELECT Id FROM zqu__QuoteRatePlan__c LIMIT 1];
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge (zqrp);
        qrpc.Name = 'Marketing Additional Users';
        qrpc.zqu__Quantity__c = 5;
        insert qrpc;
        Test.stopTest();
        zqu__Quote__c quote = [SELECT Id, Dynamic_Base_Product_Users__c FROM zqu__Quote__c LIMIT 1];
        System.assertEquals('7 Named Users', quote.Dynamic_Base_Product_Users__c);
    }

    @isTest
    public static void countryFlterTest(){       
        Utils.CodeOff = true; 
        zqu__QuoteRatePlan__c zqrp = [SELECT Id FROM zqu__QuoteRatePlan__c LIMIT 1];
        zqu__Quote__c quote = [SELECT Id, Dynamic_Base_Product_Country__c FROM zqu__Quote__c LIMIT 1];
        quote.Dynamic_Base_Product_Country__c = '1 Data Sets: Brazil';
        update quote;
        Test.startTest();
        zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge (zqrp);
        qrpc.Name = 'Marketing Standard Country Filter Indonesia plan';
        insert qrpc;
        Test.stopTest();
        quote = [SELECT Id, Dynamic_Base_Product_Country__c FROM zqu__Quote__c LIMIT 1];
        System.assertEquals('2 Data Sets: Brazil, Indonesia', quote.Dynamic_Base_Product_Country__c);
    } */
}
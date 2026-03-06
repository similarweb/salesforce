@isTest
public with sharing class CustomLookupFieldControllerTest {
    @TestSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();

        List<String> countries =  TestObjectCreator.getCountries();
        list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        Account a = TestObjectCreator.CreateAccount();
        a.billingcountry = countries[countries.size()-1];
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        c.MailingCountry = countries[countries.size()-1];
        insert c;
        Opportunity opp = TestObjectCreator.CreateOpportunity(a);
        opp.Primary_Contact__c = c.id;
        insert opp;

        List<Request__c> requestList = new List<Request__c>();
        Request__c rquest1 = new Request__c();
        rquest1.Requester__c = UserInfo.getUserId();
        rquest1.Recipient_Picklist__c = 'Chris Foale';
        rquest1.Applicable_Quote__c = 'Yes';
        rquest1.Opportunity__c = opp.Id;
        rquest1.Account__c = opp.AccountId;
        rquest1.Signed_contract__c = 'Yes';
        rquest1.Currency__c = 'USD';
        rquest1.RecordTypeId = '0120X0000005lrhQAA';
        rquest1.Regularity__c = 'One time';
        rquest1.Status__c = 'Submitted';
        rquest1.List_Price__c = 788;
        rquest1.Account__c = a.id;
        rquest1.Opportunity__c = opp.id;
        rquest1.Manager__c = UserInfo.getUserId();
        requestList.add(rquest1);
        insert requestList;

        zqu__Quote__c quote = TestDataFactory.CreateZQuote(opp, c);
        quote.Quote_contains_AS_products__c = true;
        quote.zqu__QuoteBusinessType__c = 'Co-Term Upsell';
        quote.zqu__SubscriptionType__c = 'Amendment';
        quote.zqu__Previewed_SubTotal__c = 10;
        quote.Target_Quote_Total_Price__c = 10;
        quote.zqu__PaymentMethod__c = 'Other';
        insert quote;
    }
    @isTest
    static void fetchRecordsTest(){
        Request__c req = [SELECT Id, Name FROM Request__c LIMIT 1];
        String objectName = 'Request__c';
        String filterField = 'Regularity__c';
        String searchString = 'One time';
        String value = '';
        Test.startTest();
        List<CustomLookupFieldController.RecordWrapper> records = CustomLookupFieldController.fetchRecords(objectName, filterField, searchString, value);
        value = req.id;
        records = CustomLookupFieldController.fetchRecords(objectName, filterField, searchString, value);
        Test.stopTest();
        System.assert(records.size() > 0, 'Must be returned at least one request');
    }

    @isTest
    static void fetchRequestsTest(){
        Request__c req = [SELECT Id, Name, Status__c FROM Request__c LIMIT 1];
        String searchString = req.Name;
        String quoteId = [SELECT Id FROM zqu__Quote__c LIMIT 1].Id;
        String requestType = 'onetime';
        Test.startTest();
        req.Status__c = 'Submitted';
        update req;
        List<CustomLookupFieldController.RecordWrapper> records = CustomLookupFieldController.fetchRequests(searchString, quoteId, requestType);
        Test.stopTest();
    }
}
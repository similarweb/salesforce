@isTest
public class LegalRequestModalControllerTest {

    @TestSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
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
    }
    
    @isTest
    static void obtainLegalRequestPreFillingDataTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact); 

        Test.startTest();
        insert quote;
        Response resp = LegalRequestModalController.obtainLegalRequestPreFillingData(quote.id);
        Test.stopTest();
        LegalRequestModalController.ResponseWrapper respWrapper = (LegalRequestModalController.ResponseWrapper) resp.content;
        System.assertNotEquals(null, respWrapper.recordTypeId, 'Record type id is null');
        System.assertNotEquals(null, respWrapper.quoteid, 'Id is null');
        System.assertEquals(quote.zqu__Account__c, respWrapper.accountId, 'zqu__Account__c mismatch');
        System.assertEquals(quote.zqu__Opportunity__c, respWrapper.opportunityId, 'zqu__Opportunity__c mismatch');
    }

    @isTest
    static void  obtainLegalRequestPreFillingDataErrorTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact); 

        Test.startTest();
        insert quote;
        Response resp = LegalRequestModalController.obtainLegalRequestPreFillingData(null);
        Test.stopTest();

        System.assert(!resp.success);
        System.assertNotEquals(Null, resp.message);
    }
}
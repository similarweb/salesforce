@isTest
public class RequestActionServiceTest {
    @TestSetup
    static void setup(){
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

        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        opp.Type='New Sale';
        insert opp;             
    }

    @isTest
    static void createTicketTest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Request__c rquest = TestDataFactory.createRequest(opp);
        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        insert rquest;
        RequestActionService.createTicket(new List<Id>{rquest.Id});
        Test.stopTest();
    }

}
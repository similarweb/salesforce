@isTest
public class RequestDomainTest {
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
        RequestDomain.createTicket(new List<Request__c>{rquest});
        Test.stopTest();
    }

    @isTest
    static void updateAccountNumberTest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Zuora__CustomerAccount__c zuoraAcc = TestDataFactory.createBillingAccount(account);
        insert zuoraAcc;
        Request__c rquest = TestDataFactory.createRequest(opp);
        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        insert rquest;
        RequestDomain.createTicket(new List<Request__c>{rquest});
        Test.stopTest();
        rquest = [SELECT Id, Zuora_Account_number__c FROM Request__c LIMIT 1];
        System.assert(String.isNotBlank(rquest.Zuora_Account_number__c));

    }

    @isTest
    static void checkUnsupportedRequestTypeTest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Zuora__CustomerAccount__c zuoraAcc = TestDataFactory.createBillingAccount(account);
        insert zuoraAcc;
        Request__c rquest = TestDataFactory.createRequest(opp);
        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        rquest.Request_Type__c = 'Other';
        insert rquest;
        Test.stopTest();
        rquest = [SELECT Id, Ticket_number_in_Zendesk__c FROM Request__c LIMIT 1];
        System.assertEquals('Error: Unsupported request type', rquest.Ticket_number_in_Zendesk__c);
    }

    @isTest
    static void RequestTypeIsNullTest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Zuora__CustomerAccount__c zuoraAcc = TestDataFactory.createBillingAccount(account);
        insert zuoraAcc;
        Request__c rquest = TestDataFactory.createRequest(opp);
        Test.startTest();
        rquest.Request_Type__c = null;
        try{
            insert rquest;
        }catch(Exception e){
            System.assert(e.getMessage().contains('Request Type cannot be null'));
        }
        Test.stopTest();
    }

    @isTest
    static void updateRequestStatusTest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote(opp);
        insert quote;
        Request__c rquest = new Request__c();
        rquest.Requester__c = UserInfo.getUserId();
        rquest.Recipient_Picklist__c = 'Chris Foale';
        rquest.Applicable_Quote__c = 'Yes';
        rquest.Opportunity__c = opp.Id;
        rquest.Account__c = opp.AccountId;
        rquest.Quote__c = quote.id;
        rquest.Signed_contract__c = 'Yes';
        rquest.Currency__c = 'USD';
        rquest.Request_Type__c = 'Other';
        rquest.RecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Legal_Services').getRecordTypeId();
        

        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        insert rquest;
        RequestDomain.createTicket(new List<Request__c>{rquest});
        rquest.Status__c = 'Completed';
        rquest.Green_Lane_Document__c = true;
        update rquest;
        Test.stopTest();

    }

    @isTest
    static void updateRelatedQuoteOnUpdateTest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote(opp);
        insert quote;
        Request__c rquest = getLegalServiceRequest(opp,quote);
        Request__c rq = getLegalServiceRequest(opp,quote);

        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        insert rquest;
        insert rq;
        RequestDomain.createTicket(new List<Request__c>{rquest});
        RequestDomain.createTicket(new List<Request__c>{rq});
        rquest.Status__c = 'Completed';
        update rquest;
        update rq;
        Test.stopTest();
    }

    @isTest
    static void updateRelatedQuoteOnUpdateGLTest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote(opp);
        insert quote;
        Request__c rquest = getLegalServiceRequest(opp,quote);
        Request__c rq = getLegalServiceRequest(opp,quote);

        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        insert rquest;
        insert rq;
        RequestDomain.createTicket(new List<Request__c>{rquest});
        RequestDomain.createTicket(new List<Request__c>{rq});
        rquest.Status__c = 'Completed';
        rquest.Green_Lane_Document__c = true;
        update rquest;
        Test.stopTest();
        rq.Green_Lane_Document__c = true;
        rq.Status__c = 'Completed';
        update rq;
    }
    
    @isTest
    public static void testLegalServiceRequest(){
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        opp.SalesLoft1__Primary_Contact__c = [SELECT Id FROM Contact LIMIT 1].Id;
        update opp;
        zqu__Quote__c quote = TestDataFactory.createZQuote(opp);
        insert quote;
        Request__c rq = getLegalServiceRequest(opp,quote);
        MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
        Test.setMock(HttpCalloutMock.class, mock);
        
        Test.startTest();
        	insert rq;
            rq.Ticket_number_in_Zendesk__c = null;
            rq.Status__c = 'Pending update from Billing';
            update rq;
        Test.stopTest();
        
        
    }
    
    public static Request__c getLegalServiceRequest(Opportunity opp, zqu__Quote__c quote){
        Request__c rq = new Request__c();
        rq.Requester__c = UserInfo.getUserId();
        rq.Recipient_Picklist__c = 'Chris Foale';
        rq.Applicable_Quote__c = 'Yes';
        rq.Opportunity__c = opp.Id;
        rq.Account__c = opp.AccountId;
        rq.Quote__c = quote.id;
        rq.Signed_contract__c = 'Yes';
        rq.Currency__c = 'USD';
        rq.Request_Type__c = 'Other';
        rq.RecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Legal_Services').getRecordTypeId();
        return rq;
    }
}
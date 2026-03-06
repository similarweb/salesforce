@isTest
public class RequestTicketCreationQueueableTest {
  @TestSetup
  static void setup() {
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
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    opp.Type = 'New Sale';
    insert opp;
  }

  @isTest
  static void executeQueuebleJobSuccessTest() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
    Request__c rquest = TestDataFactory.createRequest(opp);
    MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
    insert rquest;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, mock);
    Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper> requestMap = generateRequestMap(
      new List<Request__c>{ rquest }
    );
    Test.setMock(HttpCalloutMock.class, mock);
    RequestTicketCreationQueueable ticketCreationJob = new RequestTicketCreationQueueable(
      requestMap,
      'Request__c'
    );
    ticketCreationJob.execute(null);
    Test.stopTest();
    rquest = [SELECT Id, Ticket_number_in_Zendesk__c FROM Request__c LIMIT 1];
    System.assert(String.isNotBlank(rquest.Ticket_number_in_Zendesk__c));
    System.assert(!rquest.Ticket_number_in_Zendesk__c.contains('Error'));
  }

  @isTest
  static void updateRequestByUnexpectedErrorTest() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
    Request__c rquest = TestDataFactory.createRequest(opp);
    insert rquest;
    Test.startTest();
    RequestTicketCreationQueueable ticketCreationJob = new RequestTicketCreationQueueable(
      null,
      'Request__c'
    );
    ticketCreationJob.updateRequestByUnexpectedError(
      new List<Id>{ rquest.Id },
      'Error'
    );
    Test.stopTest();
    rquest = [SELECT Id, Zendesk_Integration_Issue__c FROM Request__c LIMIT 1];
    System.assert(String.isNotBlank(rquest.Zendesk_Integration_Issue__c));
    System.assert(rquest.Zendesk_Integration_Issue__c.contains('Error'));
  }

  /* @date: 2021-11-15
   * @author: Itzik Winograd
   * @description: The error field was changed from Ticket_number_in_Zendesk__c to Zendesk_Integration_Issue__c
   */
  @isTest
  static void executeQueuebleJobFailTest() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
    Request__c rquest = TestDataFactory.createRequest(opp);
    MockUtil.ZendeskIntegrationServiceErrorHttpMock mock = new MockUtil.ZendeskIntegrationServiceErrorHttpMock();
    insert rquest;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, mock);
    Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper> requestMap = generateRequestMap(
      new List<Request__c>{ rquest }
    );
    Test.setMock(HttpCalloutMock.class, mock);
    RequestTicketCreationQueueable ticketCreationJob = new RequestTicketCreationQueueable(
      requestMap,
      'Request__c'
    );
    ticketCreationJob.execute(null);
    Test.stopTest();
    rquest = [SELECT Id, Zendesk_Integration_Issue__c FROM Request__c LIMIT 1]; //Ticket_number_in_Zendesk__c
    System.assert(String.isNotBlank(rquest.Zendesk_Integration_Issue__c)); //Ticket_number_in_Zendesk__c
    System.assert(rquest.Zendesk_Integration_Issue__c.contains('Error')); //Ticket_number_in_Zendesk__c
  }

  private static Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper> generateRequestMap(
    List<Request__c> newList
  ) {
    Map<String, List<Id>> requestTypeToIdsMap = new Map<String, List<Id>>();
    for (Request__c request : newList) {
      if (requestTypeToIdsMap.containsKey(request.Request_Type__c)) {
        List<Id> requestIdList = requestTypeToIdsMap.get(
          request.Request_Type__c
        );
        requestIdList.add(request.Id);
        requestTypeToIdsMap.put(request.Request_Type__c, requestIdList);
      } else {
        requestTypeToIdsMap.put(
          request.Request_Type__c,
          new List<Id>{ request.Id }
        );
      }
    }
    Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper> requestMap = ZendeskIntegrationService.generateTicketList(
      requestTypeToIdsMap,
      'Request__c'
    );

    return requestMap;
  }
}

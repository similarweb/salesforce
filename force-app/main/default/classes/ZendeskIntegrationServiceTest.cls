@isTest
public class ZendeskIntegrationServiceTest {
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
    a.fr_NextRenewalDate__c = Date.valueOf('2021-02-28');
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    insert quote;
  }

  @isTest
  static void createTicketTest_Success() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    MockUtil.ZendeskIntegrationServiceHttpMock mock = new MockUtil.ZendeskIntegrationServiceHttpMock();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, mock);
    ZendeskIntegrationService.ZendeskResponseWrapper zendeskResponse = ZendeskIntegrationService.createTicket(
      quote.Id,
      'zqu__Quote__c'
    );
    System.assert(zendeskResponse.isSuccess());
    System.assertEquals('subject', zendeskResponse.ticket.subject);
    Test.stopTest();
  }

  @isTest
  static void createTicketTest_Error() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    MockUtil.ZendeskIntegrationServiceErrorHttpMock mock = new MockUtil.ZendeskIntegrationServiceErrorHttpMock();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, mock);
    try {
      ZendeskIntegrationService.ZendeskResponseWrapper zendeskResponse = ZendeskIntegrationService.createTicket(
        quote.Id,
        'zqu__Quote__c'
      );
      Boolean isSuccess = zendeskResponse.isSuccess();
      Long ticketid = zendeskResponse.getTicketId();
      String errorString = zendeskResponse.getError();
    } catch (AuraHandledException e) {
      Boolean errorMessageSuccess = e.getTypeName()
        .contains('System.AuraHandledException');
      System.assert(errorMessageSuccess, true);
    }

    Test.stopTest();
  }

  @isTest
  static void createTicketListTest_Success() {
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
  static void createTicketExtensionListTest_Success() {
    Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
    Request__c rquest = TestDataFactory.createRequest(opp);
    rquest.Request_Type__c = 'Extensions request';
    rquest.Screenshot_of_Avi_s_Approval__c = '<p><img src="https://similarweb--full--c.documentforce.com/servlet/rtaImage?eid=a2n7a000001M65x&amp;feoid=00N7a000005GsoD&amp;refid=0EM7a000000Adrp" alt="test3.jpg"></img>';
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
  /* @date: 2021-11-15
   * @author: Itzik Winograd
   * @description: The error field was changed from Ticket_number_in_Zendesk__c to Zendesk_Integration_Issue__c
   */
  @isTest
  static void createTicketListTest_Error() {
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
    rquest = [SELECT Id, Zendesk_Integration_Issue__c FROM Request__c LIMIT 1];
    System.assert(String.isNotBlank(rquest.Zendesk_Integration_Issue__c));
    System.assert(rquest.Zendesk_Integration_Issue__c.contains('Error'));
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

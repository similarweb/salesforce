public class RequestActionService {
  @InvocableMethod(
    label='Create Zendesk ticket'
    description='Request to create a ticket in Zendesk'
    category='Request'
  )
  public static void createTicket(List<Id> requestId) {
    System.debug('### in RequestActionService');
    List<Request__c> requestList = [
      SELECT Id, Request_Type__c, RecordType.DeveloperName
      FROM Request__c
      WHERE Id IN :requestId
    ];
    if (!requestList.isEmpty()) {
      RequestDomain.createTicket(requestList);
    }
  }
}

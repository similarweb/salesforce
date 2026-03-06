public with sharing class RequestTicketCreationQueueable implements Queueable, Database.AllowsCallouts {
  private static final String REQUEST_TYPE_NAME = 'Request__c';
  private static final String BILLING_NOTIFICATION_METADATA_NAME = 'Billing_notification_email';
  private static final String BILLING_REQUEST_TEMPLATE_DEVNAME = 'Billing_Request_Unsuccessfully_Submitted';
  private static final Integer MAP_SIZE = 50;

  private Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper> requestWrapperMap;
  private String sObjType;

  public RequestTicketCreationQueueable(
    Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper> requestWrapperMap,
    String sObjType
  ) {
    this.requestWrapperMap = requestWrapperMap;
    this.sObjType = sObjType;
  }

  public void execute(QueueableContext context) {
    Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper> requestScopeMap = new Map<Id, ZendeskIntegrationService.ZendeskRequestWrapper>();
    List<Id> recordIdList = new List<Id>(requestWrapperMap.keySet());
    for (Integer i = 0; i < MAP_SIZE && i < recordIdList.size(); i++) {
      Id recordId = recordIdList[i];
      requestScopeMap.put(recordId, requestWrapperMap.get(recordId));
      requestWrapperMap.remove(recordId);
    }

    try {
      List<ZendeskIntegrationService.ZendeskResponseWrapper> zendeskResponseWrapperList = ZendeskIntegrationService.createTicketList(
        requestScopeMap
      );

      if (sObjType == REQUEST_TYPE_NAME) {
        updateRequestObject(zendeskResponseWrapperList);
      }

      List<Id> unsuccessfullySObjectIdList = new List<Id>();
      for (
        ZendeskIntegrationService.ZendeskResponseWrapper zendeskResponseWrapper : zendeskResponseWrapperList
      ) {
        if (!zendeskResponseWrapper.isSuccess()) {
          unsuccessfullySObjectIdList.add(
            zendeskResponseWrapper.getSObjectId()
          );
        }
      }

      if (!unsuccessfullySObjectIdList.isEmpty()) {
        sendEmailNotification(unsuccessfullySObjectIdList);
      }

      if (!requestWrapperMap.isEmpty()) {
        RequestTicketCreationQueueable ticketCreationJob = new RequestTicketCreationQueueable(
          requestWrapperMap,
          'Request__c'
        );
        Id jobID = System.enqueueJob(ticketCreationJob);
      }
    } catch (Exception e) {
      updateRequestByUnexpectedError(recordIdList, e.getMessage());
    }
  }

  @TestVisible
  private void updateRequestByUnexpectedError(
    List<Id> recordIdList,
    String errorMessage
  ) {
    List<Request__c> requestToUpdateList = new List<Request__c>();

    List<Id> unsuccessfullySObjectIdList = new List<Id>();
    for (Id recordID : recordIdList) {
      Request__c requestToUpdate = new Request__c();
      requestToUpdate.Id = recordID;
      requestToUpdate.Zendesk_Integration_Issue__c = errorMessage;
      requestToUpdateList.add(requestToUpdate);
      unsuccessfullySObjectIdList.add(recordID);
    }
    Database.update(requestToUpdateList, false);

    if (!unsuccessfullySObjectIdList.isEmpty()) {
      sendEmailNotification(unsuccessfullySObjectIdList);
    }
  }

  private void sendEmailNotification(List<Id> unsuccessfullySObjectIdList) {
    EmailTemplate emailTemplate = [
      SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE DeveloperName = :BILLING_REQUEST_TEMPLATE_DEVNAME
      LIMIT 1
    ];
    List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
    List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(
      new Set<String>{ BILLING_NOTIFICATION_METADATA_NAME }
    );
    String emailToSend = generalConfigurationList[0].Text_Value__c;
    for (id sObjectId : unsuccessfullySObjectIdList) {
      Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(
        emailTemplate.Id,
        UserInfo.getUserId(),
        sObjectId
      );
      String emailSubject = email.getSubject();
      String emailTextBody = email.getHtmlBody();
      System.debug(emailTextBody);
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setSubject(emailSubject);
      message.setHtmlBody(emailTextBody);
      message.setSenderDisplayName('Notification');
      message.setUseSignature(false);
      message.setBccSender(false);
      message.setSaveAsActivity(false);
      message.toAddresses = new List<String>{ emailToSend };
      messageList.add(message);
    }
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);

    if (!results[0].success) {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }

  private void updateRequestObject(
    List<ZendeskIntegrationService.ZendeskResponseWrapper> zendeskResponseWrapperList
  ) {
    List<Request__c> requestToUpdateList = new List<Request__c>();

    for (
      ZendeskIntegrationService.ZendeskResponseWrapper zendeskResponseWrapper : zendeskResponseWrapperList
    ) {
      Request__c requestToUpdate = new Request__c();
      requestToUpdate.Id = zendeskResponseWrapper.getSObjectId();
      if (zendeskResponseWrapper.isSuccess()) {
        requestToUpdate.Ticket_number_in_Zendesk__c = String.valueOf(
          zendeskResponseWrapper.getTicketId()
        );
        requestToUpdate.Zendesk_Integration_Issue__c = null;
      } else {
        requestToUpdate.Zendesk_Integration_Issue__c =
          'Error: ' + zendeskResponseWrapper.getError(); //Set the error to Zendesk_Integration_Issue__c and not to Ticket_number_in_Zendesk__c
      }
      requestToUpdateList.add(requestToUpdate);
    }
    update requestToUpdateList;
  }
}

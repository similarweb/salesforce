public class EventChillipaperLeadConverterQueueable implements Queueable {
  private final String ALERT_EMAIL;
  private List<LeadDataUnit> leadDataUnitList;

  public EventChillipaperLeadConverterQueueable(
    List<LeadDataUnit> leadDataUnitList
  ) {
    this.leadDataUnitList = leadDataUnitList;
    List<General_Configuration__mdt> configMdt = GeneralUtil.retrieveConfigurationMetadata(
      new Set<String>{ 'Alert_Email' }
    );
    if (configMdt.size() > 0) {
      ALERT_EMAIL = configMdt[0].Text_Value__c;
    }
  }

  public void execute(QueueableContext context) {
    setLeadOwnerToEventOwner();
    convertLeads();
    setEventWhoIdToResultContact();
    sendEmails();
  }

  private void setLeadOwnerToEventOwner() {
    List<Lead> leadsToUpdate = new List<Lead>();
    for (LeadDataUnit ldu_i : leadDataUnitList) {
      ldu_i.setLeadOwnerId();
      leadsToUpdate.add(ldu_i.lead);
    }
    if (!leadsToUpdate.isEmpty()) {
      update leadsToUpdate;
    }
  }

  private void convertLeads() {
    List<Database.LeadConvert> leadConvertions = new List<Database.LeadConvert>();
    Map<Id, LeadDataUnit> leadDataUnitMap = new Map<Id, LeadDataUnit>();
    for (LeadDataUnit ldu_i : leadDataUnitList) {
      LeadDataUnitMap.put(ldu_i.getLeadId(), ldu_i);
      leadConvertions.add(ldu_i.createLeadConvertion());
    }
    if (!leadConvertions.isEmpty()) {
      List<Database.LeadConvertResult> resultList = Database.convertLead(
        leadConvertions,
        false
      );
      for (Database.LeadConvertResult lcr_i : resultList) {
        LeadDataUnit ldu_i = leadDataUnitMap.get(lcr_i.getLeadId());
        if (lcr_i.isSuccess()) {
          ldu_i.isConvertedSuccessfully = true;
          ldu_i.resultAccountId = lcr_i.getAccountId();
          ldu_i.resultContactId = lcr_i.getContactId();
        } else {
          ldu_i.convertationErrors = lcr_i.getErrors();
        }
      }
    }
  }

  private void setEventWhoIdToResultContact() {
    Map<Id, Id> eventIdToResultContactId = new Map<Id, Id>();
    List<Event> eventsToUpdate = new List<Event>();
    for (LeadDataUnit ldu_i : leadDataUnitList) {
      if (ldu_i.isConvertedSuccessfully && ldu_i.resultContactId != null) {
        for (Event event_i : ldu_i.childEventList) {
          eventIdToResultContactId.put(event_i.Id, ldu_i.resultContactId);
        }
      }
    }
    for (Event event_i : [
      SELECT Id
      FROM Event
      WHERE Id IN :eventIdToResultContactId.keySet()
    ]) {
      event_i.WhoId = eventIdToResultContactId.get(event_i.Id);
      eventsToUpdate.add(event_i);
    }
    if (!eventsToUpdate.isEmpty()) {
      update eventsToUpdate;
    }
  }

  private void sendEmails() {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
    for (LeadDataUnit ldu_i : leadDataUnitList) {
      if (!ldu_i.isConvertedSuccessfully) {
        Boolean isContactUnrelatedToAccount =
          ldu_i.targetAccount != null &&
          ldu_i.targetContact != null &&
          ldu_i.targetContact.AccountId != ldu_i.targetAccount.Id;
        Boolean isContactExistForNewAccount =
          ldu_i.targetAccount == null &&
          ldu_i.targetContact != null;
        if (isContactUnrelatedToAccount || isContactExistForNewAccount) {
          emails.add(
            createSpecificCaseFailureEmail(
              ldu_i,
              isContactUnrelatedToAccount,
              isContactExistForNewAccount
            )
          );
        } else {
          emails.add(createGeneralFailureEmail(ldu_i));
        }
      }
    }
    if (emails.size() > 0 && !Test.isRunningTest()) {
      Messaging.sendEmail(emails);
    }
  }

  private Messaging.SingleEmailMessage createSpecificCaseFailureEmail(
    LeadDataUnit ldu,
    Boolean isContactUnrelatedToAccount,
    Boolean isContactExistForNewAccount
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new List<String>{ ALERT_EMAIL });
    email.setSubject('Lead conversion failed');
    String body =
      '<p>Default lead conversion process failed for Lead (ID=\'' +
      ldu.getLeadId() +
      '\'): </p>';
    if (isContactUnrelatedToAccount) {
      body +=
        '<p>Found existing contact (ID=\'' +
        ldu.targetContact.Id +
        '\') is unrelated to the existing account that was found (ID=\'' +
        ldu.targetAccount.Id +
        '\');</p>';
    }
    if (isContactExistForNewAccount) {
      body +=
        '<p>Found existing contact (ID=\'' +
        ldu.targetContact.Id +
        '\') although no existing account was found;</p>';
    }
    email.setHtmlBody(body);

    return email;
  }

  private Messaging.SingleEmailMessage createGeneralFailureEmail(
    LeadDataUnit ldu
  ) {
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(new List<String>{ ALERT_EMAIL });
    email.setSubject('Lead conversion failed');
    String body =
      '<p>Failed to convert Lead (ID=\'' +
      ldu.getLeadId() +
      '\'): </p>';
    body += '<ul>';
    for (Database.Error err_i : ldu.convertationErrors) {
      body +=
        '<li>' +
        err_i.getStatusCode() +
        ': ' +
        err_i.getMessage() +
        '</li>';
    }
    body += '</ul>';
    email.setHtmlBody(body);

    return email;
  }
}

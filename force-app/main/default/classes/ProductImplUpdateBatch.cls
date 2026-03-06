global class ProductImplUpdateBatch implements Database.Batchable<sObject>, Schedulable {
  private String query;
  private DateTime previousRunTime;

  global ProductImplUpdateBatch() {
    previousRunTime = Date.today().addDays(-10);
  }

  global ProductImplUpdateBatch(DateTime previousTime) {
    previousRunTime = previousTime;
  }

  global void execute(SchedulableContext SC) {
    List<CronTrigger> cts = [
      SELECT ID, PreviousFireTime, NextFireTime
      FROM crontrigger
      WHERE Id = :SC.getTriggerId()
    ];
    DateTime schpreviousRunTime = !cts.isEmpty() &&
      cts[0].PreviousFireTime != null
      ? cts[0].PreviousFireTime.addDays(-1)
      : Date.today().addDays(-1);
    Database.executeBatch(new ProductImplUpdateBatch(schpreviousRunTime));
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('previousRunTime ' + previousRunTime);
    query = 'SELECT ContactId FROM ContactHistory WHERE Field=\'Account\' AND CreatedDate >:previousRunTime';
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<ContactHistory> scope
  ) {
    System.debug('scope ' + scope);
    List<ID> contactIds = new List<Id>();

    for (ContactHistory ch : scope) {
      contactIds.add(ch.ContactId);
    }
    processContacts(contactIds);
  }

  public void processContacts(List<Id> contactIds) {
    Map<Id, List<Contact>> accountToContactMap = new Map<Id, List<Contact>>();
    List<Contact> contacts = [
      SELECT Id, AccountID, Name, ProductImplementation__c
      FROM Contact
      WHERE ID IN :contactIds
    ];
    for (Contact cnt_i : contacts) {
      if (!accountToContactMap.containsKey(cnt_i.AccountId))
        accountToContactMap.put(cnt_i.AccountId, new List<Contact>());
      accountToContactMap.get(cnt_i.AccountId).add(cnt_i);
    }
    System.debug(contacts);
    System.debug('accountToContactMap' + accountToContactMap);

    List<Contact> contactToUpdate = new List<Contact>();
    if (!accountToContactMap.isEmpty()) {
      for (Product_Implementation__c impl_i : [
        SELECT ID, Account__c
        FROM Product_Implementation__c
        WHERE Account__c IN :accountToContactMap.keySet()
        ORDER BY CreatedDate DESC
      ]) {
        if (accountToContactMap.containsKey(impl_i.Account__c)) {
          for (Contact cnt : accountToContactMap.get(impl_i.Account__c)) {
            cnt.ProductImplementation__c = impl_i.Id;
            contactToUpdate.add(cnt);
          }
          accountToContactMap.remove(impl_i.Account__c);
        }
      }
      if (!accountToContactMap.isEmpty()) {
        for (Id acc : accountToContactMap.keySet()) {
          for (Contact cnt : accountToContactMap.get(acc)) {
            cnt.ProductImplementation__c = null;
            contactToUpdate.add(cnt);
          }
        }
      }
    }

    System.debug('contactToUpdate ' + contactToUpdate);
    if (!contactToUpdate.isEmpty())
      update contactToUpdate;
  }

  global void finish(Database.BatchableContext BC) {
  }
}

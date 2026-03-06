public with sharing class ZuoraRefreshRenewalQuoteBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts {
  private Datetime specificDate;
  private Id subscriptionId;

  public ZuoraRefreshRenewalQuoteBatch() {
  }

  public ZuoraRefreshRenewalQuoteBatch(Id subscriptionId) {
    this.subscriptionId = subscriptionId;
  }

  public ZuoraRefreshRenewalQuoteBatch(Datetime specDate) {
    this.specificDate = specDate;
  }

  public static void executeBatch() {
    Database.executeBatch(new ZuoraRefreshRenewalQuoteBatch(), 1);
  }

  public static void scheduleRenewelBatch() {
    new ZuoraRefreshRenewalQuoteBatch().execute(null);
  }

  public static void scheduleRenewelBatch(Datetime specDate) {
    new ZuoraRefreshRenewalQuoteBatch(specDate).execute(null);
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id FROM Zuora__Subscription__c WHERE Zuora__Status__c=\'Active\'';
    if (subscriptionId != null) {
      query += ' AND Id =\'' + subscriptionId + '\'';
    }
    return Database.getQueryLocator(query);
  }

  public void execute(
    Database.BatchableContext BC,
    List<Zuora__Subscription__c> scope
  ) {
    Set<Id> subscriptionIdSet = new Set<Id>();
    for (Zuora__Subscription__c subscription_i : scope) {
      subscriptionIdSet.add(subscription_i.Id);
    }
    if (!subscriptionIdSet.isEmpty()) {
      System.enqueueJob(
        new QuoteRenewalProcessQueueableService(
          subscriptionIdSet,
          'refreshRenewalQuoteUnderSubscription'
        )
      );
    }
  }

  public void execute(SchedulableContext SC) {
    if (SC != null) {
      System.abortJob(Sc.getTriggerId());
    }
    String schedulerName = 'ZuoraRefreshRenewalQuoteBatch';
    if (Test.isRunningTest()) {
      schedulerName = 'ZuoraRefreshRenewalQuoteBatchTest';
    }
    if (specificDate == null) {
      Database.executeBatch(new ZuoraRefreshRenewalQuoteBatch(), 1);
      System.schedule(
        schedulerName,
        Utility.getCronFromDateTime(System.now().addDays(1)),
        new ZuoraRefreshRenewalQuoteBatch()
      );
    } else {
      System.schedule(
        schedulerName,
        Utility.getCronFromDateTime(specificDate),
        new ZuoraRefreshRenewalQuoteBatch()
      );
    }
  }

  public void finish(Database.BatchableContext BC) {
  }
}

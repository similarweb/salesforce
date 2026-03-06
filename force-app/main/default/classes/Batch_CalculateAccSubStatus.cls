global without sharing class Batch_CalculateAccSubStatus implements Database.Batchable<sObject> {
  // CONSTRUCTOR
  public Batch_CalculateAccSubStatus() {
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    system.debug(
      'TESTING Batch Batch_CalculateAccSubStatus querylocator - START '
    );
    datetime d = datetime.now().adddays(-7);
    string s1 = utils.DateFormat(d.year(), d.month(), d.day());
    datetime d2 = datetime.now().adddays(1);
    string s2 = utils.DateFormat(d2.year(), d2.month(), d2.day());

    string query = 'select id,Zuora__Account__c,Zuora__Status__c, Zuora__NextRenewalDate__c';
    query += ' FROM Zuora__Subscription__c';
    if (!utils.isTest)
      query +=
        ' WHERE Zuora__NextRenewalDate__c>=' +
        s1 +
        ' AND Zuora__NextRenewalDate__c<=' +
        s2;
    if (utils.isTest)
      query += ' limit 1500';
    system.debug('TESTING query is ' + query);

    return database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    list<Zuora__Subscription__c> scope
  ) {
    system.debug(
      'TESTING Batch Batch_CalculateAccSubStatus - EXECUTE START,scope size is ' +
      scope.size()
    );
    ZuoraSubscriptionHandler.HandleAfter(scope, null, 'batch');

    system.debug('TESTING Batch Batch_CalculateAccSubStatus - EXECUTE END ');
  }

  global void finish(Database.BatchableContext BC) {
  }
}

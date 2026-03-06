@isTest
public with sharing class ZCreateInvoiceTest {
  @isTest(SeeAllData=true)
  static void testMain() {
    zqu__Quote__c quote = [
      SELECT Id
      FROM zqu__Quote__c
      WHERE
        zqu__ZuoraAccountID__c != NULL
        AND zqu__TermStartDate__c != NULL
        AND zqu__SoldToContact__r.MailingCountry != 'Japan'
        AND zqu__PaymentMethod__c != 'Other'
        AND zqu__PaymentMethod__c != 'Wire Transfer'
      LIMIT 1
    ];
    ZCreateInvoice zCreate = new ZCreateInvoice(new List<Id>{ quote.Id });
    Test.startTest();
    System.enqueueJob(zCreate);
    Test.stopTest();
  }
}

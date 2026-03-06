/**
 *===CHANGES===
 * Itzik Winograd 2022-01-27: Added second account and another suspended subscription
 */
@isTest
public class ZuoraSubscriptionHandlerBatchTest {
  @testSetup
  public static void setup() {
    Account acc = new Account(Name = 'Test', BillingCountry = 'Ukraine');
    insert acc;
    Zuora__Subscription__c zs = new Zuora__Subscription__c();
    zs.Zuora__Account__c = acc.Id;
    zs.Zuora__Status__c = 'active';
    insert zs;

    //Itzik Winograd 2022-02-27: added suspended subscription for additional test
    Account acc2 = new Account(Name = 'Test2', BillingCountry = 'Canada');
    insert acc2;

    Zuora__Subscription__c zs2 = new Zuora__Subscription__c();
    zs2.Zuora__Account__c = acc2.Id;
    zs2.Zuora__Status__c = 'suspended';
    insert zs2;
  }

  @isTest
  public static void test() {
    Test.startTest();
    //new ZuoraSubscriptionHandlerBatch(true).execute(null);
    System.schedule(
      'ZuoraSubscriptionHandlerBatchTest',
      '0 0 01 * * ?',
      new ZuoraSubscriptionHandlerBatch(true)
    );

    Test.stopTest();
  }
}

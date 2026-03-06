/**
 * Created by alon.shalev on 5/13/2025.
 */
@IsTest
public with sharing class ZuoraPaymentHandlerTest {
  @IsTest
  static void setSubscriptionPaymentStatusTest() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    insert TestDataFactory.createBaseProductContract_CS();
    insert TestDataFactory.createBaseProductConfiguration_CS();
    insert TestDataFactory.createBaseProductControlling_CS();
    insert TestDataFactory.createBaseProductDependent_CS();
    insert TestDataFactory.createBaseProductDefaultAddon_CS();
    insert TestDataFactory.createBaseProductDynamicAddon_CS();
    insert TestDataFactory.createBaseProductNumOfUsers_CS();
    Account account = new Account(Name = 'Test  Account');
    insert account;
    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(
      account
    );
    insert zca;

    // Subscription with a future service activation date

    // Subscription with EVERGREEN type (should not be updated)
    Zuora__Subscription__c evergreenSubscription = new Zuora__Subscription__c(
      Zuora__CustomerAccount__c = zca.Id,
      Zuora__ServiceActivationDate__c = Date.today(),
      Zuora__TermSettingType__c = 'TERMED',
      Zuora__Account__c = account.Id
    );
    insert evergreenSubscription;

    Zuora__Payment__c payment = TestDataFactory.createPayment(zca);
    payment.Zuora__Status__c = 'Processed';
    test.startTest();
    insert payment;
    test.stopTest();
  }

  @IsTest
  static void setUpdatedSubscriptionPaymentStatusTest() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    insert TestDataFactory.createBaseProductContract_CS();
    insert TestDataFactory.createBaseProductConfiguration_CS();
    insert TestDataFactory.createBaseProductControlling_CS();
    insert TestDataFactory.createBaseProductDependent_CS();
    insert TestDataFactory.createBaseProductDefaultAddon_CS();
    insert TestDataFactory.createBaseProductDynamicAddon_CS();
    insert TestDataFactory.createBaseProductNumOfUsers_CS();
    Account account = new Account(Name = 'Test  Account');
    insert account;
    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(
      account
    );
    insert zca;

    // Subscription with a future service activation date

    // Subscription with EVERGREEN type (should not be updated)
    Zuora__Subscription__c evergreenSubscription = new Zuora__Subscription__c(
      Zuora__CustomerAccount__c = zca.Id,
      Zuora__ServiceActivationDate__c = Date.today(),
      Zuora__TermSettingType__c = 'EVERGREEN',
      Zuora__Account__c = account.Id
    );
    insert evergreenSubscription;

    Zuora__Payment__c payment = TestDataFactory.createPayment(zca);
    payment.Zuora__Status__c = 'Processing';
    insert payment;
    test.startTest();
    payment.Zuora__Status__c = 'Processed';
    update payment;
    test.stopTest();

    Zuora__Subscription__c updatedSubscription = [
      SELECT Id, Payment_Status__c
      FROM Zuora__Subscription__c
      WHERE Id = :evergreenSubscription.Id
    ];

    System.assertEquals('NT Paid', updatedSubscription.Payment_Status__c);
  }
}

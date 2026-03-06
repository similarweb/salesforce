/**
 * Created by alon.shalev on 5/4/2025.
 */

public with sharing class ZuoraPaymentHandler {
  public void setSubscriptionPaymentStatusOnUpdate(
    List<Zuora__Payment__c> newList,
    Map<Id, Zuora__Payment__c> oldMap
  ) {
    list<Zuora__Payment__c> zpList = new List<Zuora__Payment__c>();
    for (Zuora__Payment__c zp : newList) {
      if (
        zp.Zuora__Status__c == 'Processed' &&
        oldMap.get(zp.id).Zuora__Status__c != 'Processed'
      ) {
        zpList.add(zp);
      }
    }
    if (!zpList.isEmpty()) {
      setSubscriptionPaymentStatus(zpList);
    }
  }

  public void setSubscriptionPaymentStatus(List<Zuora__Payment__c> payments) {
    Integer daysToSubstract = -1;
    Integer daysToAdd = 28;
    Map<Id, Date> billingAccountIdToStartDateMap = new Map<Id, Date>();
    for (Zuora__Payment__c payment : payments) {
      if (payment.Zuora__Status__c == 'Processed') {
        billingAccountIdToStartDateMap.put(
          payment.Zuora__BillingAccount__c,
          payment.Zuora__Effective_Date__c
        );
      }
    }

    if (!billingAccountIdToStartDateMap.isEmpty()) {
      String zuoraTermedSettingTypeForTouch = 'EVERGREEN';
      List<Zuora__Subscription__c> subscriptions = [
        SELECT Id, Zuora__CustomerAccount__c, Zuora__ServiceActivationDate__c
        FROM Zuora__Subscription__c
        WHERE
          Zuora__CustomerAccount__c IN :billingAccountIdToStartDateMap.keySet()
          AND Zuora__TermSettingType__c = :zuoraTermedSettingTypeForTouch
      ];
      for (Zuora__Subscription__c subscription : subscriptions) {
        Date paymentEffectiveDate = billingAccountIdToStartDateMap.get(
          subscription.Zuora__CustomerAccount__c
        );
        if (paymentEffectiveDate != null) {
          subscription.Payment_Status__c = paymentEffectiveDate >=
            subscription.Zuora__ServiceActivationDate__c.addDays(
              daysToSubstract
            ) &&
            paymentEffectiveDate <=
            subscription.Zuora__ServiceActivationDate__c.addDays(daysToAdd)
            ? 'NT Paid'
            : 'NT CC Trial';
        }
      }
      update subscriptions;
    }
  }
}

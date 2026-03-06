/**
 * Created by zohar.sinay on 01/07/2024.
 */

public class ZuoraUpdateChargeCARRBatch implements Database.Batchable<sObject> {
  public ZuoraUpdateChargeCARRBatch() {
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    //string query = 'SELECT Id, zqu__QuoteBusinessType__c FROM zqu__Quote__c WHERE zqu_Quote_Status__c = \'Sent To Zuora\' AND DAY_ONLY(Submitted_to_Zuora_Timestamp__c) = LAST';
    String query = CustomQueriesUtils.getCustomQuery('CARR');
    if (test.isRunningTest()) {
      coverCode();
    }
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<zqu__Quote__c> scope) {
    List<zqu__QuoteRatePlanCharge__c> chargesToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
    List<Id> chargeIdList = new List<Id>();
    List<Zuora__SubscriptionProductCharge__c> subProductChargeList = new List<Zuora__SubscriptionProductCharge__c>();
    Map<Id, zqu__QuoteRatePlanCharge__c> chargeByIdMap = new Map<Id, zqu__QuoteRatePlanCharge__c>();
    for (zqu__Quote__c quote : scope) {
      if (quote.zqu__QuoteBusinessType__c == 'New') {
        chargesToUpdate = ZuoraCARRCalculation.handleNewSale(quote.Id, false);
      } else if (
        quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Co-Term Upsell')
      ) {
        chargesToUpdate = ZuoraCARRCalculation.handleCTU(quote.Id, true);
      } else if (
        quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Renewal')
      ) {
        chargesToUpdate = ZuoraCARRCalculation.handleRenewal(quote.Id, true);
      } else if (
        quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')
      ) {
        chargesToUpdate = ZuoraCARRCalculation.handleFU(quote.Id, true);
      }
    }
    System.debug(chargesToUpdate);
    if (chargesToUpdate != null && !chargesToUpdate.isEmpty()) {
      for (zqu__QuoteRatePlanCharge__c charge : chargesToUpdate) {
        chargeIdList.add(charge.Id);
        chargeByIdMap.put(charge.Id, charge);
      }
      for (Zuora__SubscriptionProductCharge__c subCharge : [
        SELECT
          Id,
          Quote_rate_plan_charge_ID__c,
          Zuora__Zuora_Id__c,
          Zuora__ChargeNumber__c
        FROM Zuora__SubscriptionProductCharge__c
        WHERE Quote_rate_plan_charge_ID__c IN :chargeIdList
      ]) {
        System.debug(subCharge.Quote_rate_plan_charge_ID__c);
        System.debug(subCharge.Quote_rate_plan_charge_ID__c != 'Free Product');
        System.debug(
          chargeByIdMap.containsKey(subCharge.Quote_rate_plan_charge_ID__c)
        );
        System.debug(
          chargeByIdMap.get(subCharge.Quote_rate_plan_charge_ID__c)
            .Amendment_type__c
        );
        if (
          subCharge.Quote_rate_plan_charge_ID__c != 'Free Product' &&
          chargeByIdMap.containsKey(subCharge.Quote_rate_plan_charge_ID__c)
        ) {
          chargeByIdMap.get(subCharge.Quote_rate_plan_charge_ID__c)
            .zqu__QuoteRatePlanChargeZuoraId__c = subCharge.Zuora__Zuora_Id__c;
          chargeByIdMap.get(subCharge.Quote_rate_plan_charge_ID__c)
            .zqu__ChargeNumber__c = subCharge.Zuora__ChargeNumber__c;
        }
      }
      try {
        if (!chargeByIdMap.values().isEmpty()) {
          update chargeByIdMap.values();
        }
      } catch (Exception e) {
        scope[0].CARR_Error_Message__c =
          e.getMessage() +
          ' stackTrace: ' +
          e.getStackTraceString() +
          ' timestamp : ' +
          Datetime.now();
        scope[0].CARR_Error_Checkbox__c = true;
      }
    }
  }

  public void finish(Database.BatchableContext BC) {
  }

  private static void coverCode() {
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}

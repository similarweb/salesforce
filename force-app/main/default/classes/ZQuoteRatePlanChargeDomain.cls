public with sharing class ZQuoteRatePlanChargeDomain extends GenericDomain {
  private ZQuoteRatePlanDomain instance;

  public ZQuoteRatePlanChargeDomain(List<SObject> newRecords) {
    super(newRecords);
  }

  public override void onBeforeInsert() {
    //        Map<String,String> productAlligmnentToQuoteAlligMap = new Map<String, String>();
    //        productAlligmnentToQuoteAlligMap.put('Align To Charge','AlignToCharge');
    //        productAlligmnentToQuoteAlligMap.put('Align To Subscription Start','AlignToSubscriptionStart');
    //        productAlligmnentToQuoteAlligMap.put('Align To Term Start','AlignToTermStart');
    //        productAlligmnentToQuoteAlligMap.put('Align To Term End','AlignToTermEnd');
    Boolean isClusterFiveExist = false;
    Set<Id> validQrpcIds = new Set<Id>();
    Set<Id> productRatePlanIdSet = new Set<Id>();
    List<zqu__QuoteRatePlanCharge__c> countryProductList = new List<zqu__QuoteRatePlanCharge__c>();
    for (
      zqu__QuoteRatePlanCharge__c qrpc_i : (List<zqu__QuoteRatePlanCharge__c>) newRecords
    ) {
      System.debug(
        qrpc_i.zqu__EffectivePrice__c + ' -- alon seeing the insert'
      );
      validQrpcIds.add(qrpc_i.zqu__QuoteRatePlan__c);
      productRatePlanIdSet.add(qrpc_i.zqu__ProductRatePlanCharge__c);
    }
    Map<Id, zqu__QuoteRatePlan__c> qrpcValidMap = new Map<Id, zqu__QuoteRatePlan__c>(
      [
        SELECT
          Id,
          zqu__Quote__r.Trial_Quote__c,
          zqu__Quote__r.zqu__InitialTermPeriodType__c,
          zqu__Quote__r.zqu__SubscriptionType__c
        FROM zqu__QuoteRatePlan__c
        WHERE Id IN :validQrpcIds
      ]
    );
    Map<Id, zqu__ProductRatePlanCharge__c> productRateMap = new Map<Id, zqu__ProductRatePlanCharge__c>(
      [
        SELECT zqu__BillingPeriodAlignment__c
        FROM zqu__ProductRatePlanCharge__c
        WHERE Id IN :productRatePlanIdSet
      ]
    );

    for (
      zqu__QuoteRatePlanCharge__c qrpc_i : (List<zqu__QuoteRatePlanCharge__c>) newRecords
    ) {
      zqu__ProductRatePlanCharge__c productPlanCharge = productRateMap.get(
        qrpc_i.zqu__ProductRatePlanCharge__c
      );
      zqu__QuoteRatePlan__c quoteRatePlan = qrpcValidMap.get(
        qrpc_i.zqu__QuoteRatePlan__c
      );
      // we are excluding the update of the zqu__BillingPeriodAlignment__c when the quote is of type amendment
      System.debug(
        'quoteRatePlan.zqu__Quote__r.zqu__SubscriptionType__c ' +
        quoteRatePlan.zqu__Quote__r.zqu__SubscriptionType__c
      );
      System.debug(
        'quoteRatePlan.zqu__Quote__r.Trial_Quote__c ' +
        quoteRatePlan.zqu__Quote__r.Trial_Quote__c
      );
      if (
        productPlanCharge != null &&
        quoteRatePlan.zqu__Quote__r.zqu__SubscriptionType__c !=
        'Amend Subscription' &&
        (quoteRatePlan.zqu__Quote__r.Trial_Quote__c == null ||
        quoteRatePlan.zqu__Quote__r.Trial_Quote__c == false)
      ) {
        qrpc_i.zqu__BillCycleType__c = 'SubscriptionStartDay';
        //qrpc_i.zqu__BillingPeriodAlignment__c = productAlligmnentToQuoteAlligMap.get(productPlanCharge.zqu__BillingPeriodAlignment__c);//alon shalev addition ZOHAR -- alon was here!!
        System.debug(
          'qrpc_i.zqu__BillingPeriodAlignment__c: ' +
          qrpc_i.zqu__BillingPeriodAlignment__c
        );
        //                    qrpc_i.zqu__Period__c = qrpcValidMap.get(qrpc_i.zqu__QuoteRatePlan__c).zqu__Quote__r.zqu__InitialTermPeriodType__c == 'Day' ? 'Subscription Term' : qrpc_i.zqu__Period__c;//alon shalev addition
        //qrpc_i.zqu__BillingPeriodAlignment__c = 'AlignToSubscriptionStart';
      }
      // if (qrpc_i.Name.containsIgnoreCase('Cluster: 5')) {
      //     isClusterFiveExist = true;
      // } else if (qrpc_i.Name.containsIgnoreCase('Country Filter') && countryProductList.size() < 5) {
      //     countryProductList.add(qrpc_i);
      // }
    }
    ZuoraQuoteMetricsManipulationHelper.calculateSpecificBillingPeriod(
      (List<zqu__QuoteRatePlanCharge__c>) newRecords
    );
    // if (isClusterFiveExist) {
    //     for (zqu__QuoteRatePlanCharge__c qrpc_i : countryProductList) {
    //         qrpc_i.Part_Of_Cluster_5__c = true;
    //     }
    // }
  }

  public static void onBefore(List<zqu__QuoteRatePlanCharge__c> newRecords) {
    if (newRecords != null) {
      for (zqu__QuoteRatePlanCharge__c qrpc_i : newRecords) {
        if (qrpc_i.Part_Of_Cluster_5__c) {
          qrpc_i.IsPartOfCluster5__c = 'Yes';
        } else {
          qrpc_i.IsPartOfCluster5__c = 'No';
        }
        if (qrpc_i.zqu__EffectivePrice__c == null) {
          System.debug(
            'zqu__QuoteRatePlanCharge__c changing from null to 0 --' + qrpc_i.Id
          );
          qrpc_i.zqu__EffectivePrice__c = 0;
        }
      }
    }
  }

  /* public override void onValidate() {
        ZuoraQuoteRatePlanChargeValidations.validateCompatibleProducts((List<zqu__QuoteRatePlanCharge__c>)newRecords);
    } */

  //    public override void onAfterInsert() {
  //        Set<Id> forTotalListPriceRecalc = new Set<Id>();
  //        Set<Id> qrpIds = new Set<Id>();
  //        for (zqu__QuoteRatePlanCharge__c qrpc_i : (List <zqu__QuoteRatePlanCharge__c>)newRecords) {
  //            if (qrpc_i.Terms_Total__c != null) {
  //                forTotalListPriceRecalc.add(qrpc_i.Quote__c);
  //            }
  //            qrpIds.add(qrpc_i.zqu__QuoteRatePlan__c);
  //        }
  //    }

  public override void onAfterUpdate(Map<Id, SObject> oldRecordsMap) {
    Set<Id> forTotalListPriceRecalc = new Set<Id>();

    Set<Id> partOfClusterFiveQuoteIds = new Set<Id>(); //set of Ids of quotes, which was updated with the
    for (
      zqu__QuoteRatePlanCharge__c qrpc_i : (List<zqu__QuoteRatePlanCharge__c>) newRecords
    ) {
      zqu__QuoteRatePlanCharge__c oldQrpc_i = (zqu__QuoteRatePlanCharge__c) oldRecordsMap.get(
        qrpc_i.Id
      );
      if (
        (qrpc_i.Terms_Total__c != null &&
        qrpc_i.Terms_Total__c != oldQrpc_i.Terms_Total__c) ||
        (qrpc_i.zqu__BillingSubtotal__c != null &&
        qrpc_i.zqu__BillingSubtotal__c != oldQrpc_i.zqu__BillingSubtotal__c) ||
        (qrpc_i.zqu__ListPrice__c != null &&
        qrpc_i.zqu__ListPrice__c != oldQrpc_i.zqu__ListPrice__c)
      ) {
        forTotalListPriceRecalc.add(qrpc_i.Quote__c);
      }
      partOfClusterFiveQuoteIds = getUpdatedClusterFiveQuote(
        partOfClusterFiveQuoteIds,
        qrpc_i,
        oldQrpc_i
      );
    }
    if (partOfClusterFiveQuoteIds.size() > 0) {
      System.debug('im in zqrpchargeDomain final one');
      BaseProductAddonCalculationHelper.calculateAmendWording(
        partOfClusterFiveQuoteIds
      );
    }
  }

  /**
   * @description getUpdatedClusterFiveQuote
   * @param  partOfClusterFiveQuoteIds Set with Ids of the ZQuote, where Part_Of_Cluster_5__c checkbox was update
   * @param  newQuoteRatePlanCharge    updated record
   * @param  oldQuoteRatePlanCharge    old record
   * @return                           IF Part_Of_Cluster_5__c was update,
   *                                   THEN return Set of Ids, with Id of Quote,
   *                                   ELSE return retrieved set
   */
  private Set<Id> getUpdatedClusterFiveQuote(
    Set<Id> partOfClusterFiveQuoteIds,
    zqu__QuoteRatePlanCharge__c newQuoteRatePlanCharge,
    zqu__QuoteRatePlanCharge__c oldQuoteRatePlanCharge
  ) {
    if (
      newQuoteRatePlanCharge.Part_Of_Cluster_5__c !=
      oldQuoteRatePlanCharge.Part_Of_Cluster_5__c
    ) {
      Id quoteId = newQuoteRatePlanCharge.Quote__c;
      partOfClusterFiveQuoteIds.add(quoteId);
    }
    return partOfClusterFiveQuoteIds;
  }

  public class Constructor implements GenericDomain.IConstructable {
    public GenericDomain constructDomainInstance(List<SObject> sObjectList) {
      return new ZQuoteRatePlanChargeDomain(sObjectList);
    }
  }
}

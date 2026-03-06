public class QuoteTotalFieldsCalcBatch implements Database.Batchable<sObject> {
  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT id,Total_Price__c,Total_List_Price__c FROM zqu__Quote__c';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    Map<id, zqu__Quote__c> fullQuoteMap = new Map<id, zqu__Quote__c>();
    for (SObject sobj_i : scope) {
      zqu__Quote__c zq = (zqu__Quote__c) sobj_i;
      zq.Total_Price__c = 0;
      zq.Total_List_Price__c = 0;
      fullQuoteMap.put(zq.Id, zq);
    }
    Map<Id, zqu__QuoteRatePlanCharge__c> sss = new Map<Id, zqu__QuoteRatePlanCharge__c>(
      [
        SELECT Id, zqu__QuoteRatePlan__c
        FROM zqu__QuoteRatePlanCharge__c
        WHERE zqu__QuoteRatePlan__r.zqu__Quote__r.Id IN :fullQuoteMap.keySet()
      ]
    );
    Set<String> qRatePlanIds = new Set<String>();
    for (zqu__QuoteRatePlanCharge__c qrpc : sss.values()) {
      qRatePlanIds.add(qrpc.zqu__QuoteRatePlan__c);
    }
    Map<id, zqu__QuoteRatePlan__c> fullQRPMap = new Map<id, zqu__QuoteRatePlan__c>(
      [
        SELECT Id, zqu__Quote__c
        FROM zqu__QuoteRatePlan__c
        WHERE ID IN :qRatePlanIds
      ]
    );
    AggregateResult[] groupedResults = [
      SELECT
        zqu__QuoteRatePlan__c,
        SUM(zqu__ListTotal__c) listPrice,
        SUM(zqu__Total__c) listTotal
      FROM zqu__QuoteRatePlanCharge__c
      WHERE Id IN :sss.keySet()
      GROUP BY zqu__QuoteRatePlan__c
    ];
    Map<String, Double> ratePlaneToTotalSum = new Map<String, Double>();
    Map<String, Double> ratePlaneToPriceSum = new Map<String, Double>();
    for (AggregateResult ar : groupedResults) {
      if (ar.get('zqu__QuoteRatePlan__c') != null) {
        ratePlaneToTotalSum.put(
          (String) ar.get('zqu__QuoteRatePlan__c'),
          (Decimal) ar.get('listTotal')
        );
        ratePlaneToPriceSum.put(
          (String) ar.get('zqu__QuoteRatePlan__c'),
          (Decimal) ar.get('listPrice')
        );
      }
    }
    for (String qRatePlaneId : qRatePlanIds) {
      fullQuoteMap.get(fullQRPMap.get(qRatePlaneId).zqu__Quote__c)
        .Total_Price__c += ratePlaneToTotalSum.get(qRatePlaneId);
      fullQuoteMap.get(fullQRPMap.get(qRatePlaneId).zqu__Quote__c)
        .Total_List_Price__c += ratePlaneToPriceSum.get(qRatePlaneId);
    }
    update fullQuoteMap.values();
  }

  public void finish(Database.BatchableContext BC) {
  }
}

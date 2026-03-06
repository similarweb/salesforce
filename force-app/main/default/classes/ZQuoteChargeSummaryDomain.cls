public with sharing class ZQuoteChargeSummaryDomain extends GenericDomain {
    private ZQuoteChargeSummaryDomain instance;

    public ZQuoteChargeSummaryDomain(List<SObject> newRecords){
        super(newRecords);
    }

    //    public override  void onBeforeUpdate(Map<id,SObject> newMap){
//        for(zqu__QuoteChargeSummary__c newRecord : (List<zqu__QuoteChargeSummary__c>)newMap.values()){
//            if(newRecord.zqu__EffectivePrice__c == null){
//                System.debug('zqu__QuoteChargeSummary__c changing from null to 0 --'+newRecord.Id); // alon shalev added 20.2.23 MQ-1743
//                newRecord.zqu__EffectivePrice__c = 0;
//            }
//        }
//    }

    public static void onBeforeUpdate(List<zqu__QuoteChargeSummary__c> newList){
        for(zqu__QuoteChargeSummary__c newRecord : newList ){
            if(newRecord.zqu__EffectivePrice__c == null){
                System.debug('zqu__QuoteChargeSummary__c changing from null to 0 --'+newRecord.Id); // alon shalev added 20.2.23 MQ-1743
                newRecord.zqu__EffectivePrice__c = 0;
            }
        }

    }

    public override void onAfterInsert() {
        system.debug('alon is testing 2');
        Set<Id> forTotalListPriceRecalc = new Set<Id>();
        Set<Id> qcpIds = new Set<Id>();

        for (zqu__QuoteChargeSummary__c qrpc_i : (List <zqu__QuoteChargeSummary__c>)newRecords) {
            if (qrpc_i.Terms_Total__c != null) {
                forTotalListPriceRecalc.add(qrpc_i.Quote__c);
            }
            qcpIds.add(qrpc_i.zqu__QuoteRatePlan__c);
        }     
        if (!forTotalListPriceRecalc.isEmpty()) {
            ZuoraQuoteMetricsManipulationHelper.calculateTotalListPrice(forTotalListPriceRecalc);
        }

        Set<Id> quoteIds = new Set<Id>();
        List<zqu__QuoteRatePlan__c> qrpDDList = [SELECT Id,zqu__Quote__c FROM zqu__QuoteRatePlan__c WHERE Id IN:qcpIds];
        for (zqu__QuoteRatePlan__c qrp_i : qrpDDList) {
            quoteIds.add(qrp_i.zqu__Quote__c);
        }
        if (!quoteIds.isEmpty()) {
            System.debug('i am in zqchargeSummary domain');
            BaseProductAddonCalculationHelper.calculateAmendWording(quoteIds);
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> oldRecordsMap) {
        System.debug('alon is testing 3');
        Set<Id> forTotalListPriceRecalc = new Set<Id>();
        Set<Id> qcpIds = new Set<Id>();

        for (zqu__QuoteChargeSummary__c qrpc_i : (List <zqu__QuoteChargeSummary__c>)newRecords) {
            System.debug(qrpc_i.zqu__EffectivePrice__c+' alon is testing ');
            zqu__QuoteChargeSummary__c oldQrpc_i = (zqu__QuoteChargeSummary__c) oldRecordsMap.get(qrpc_i.Id);
            if ((qrpc_i.Terms_Total__c != null && qrpc_i.Terms_Total__c != oldQrpc_i.Terms_Total__c) || 
                (qrpc_i.zqu__BillingSubtotal__c != null && qrpc_i.zqu__BillingSubtotal__c != oldQrpc_i.zqu__BillingSubtotal__c)||
                (qrpc_i.zqu__ListPrice__c != null && qrpc_i.zqu__ListPrice__c != oldQrpc_i.zqu__ListPrice__c)) {
                forTotalListPriceRecalc.add(qrpc_i.Quote__c);
            }
            if (oldQrpc_i.zqu__Quantity__c != qrpc_i.zqu__Quantity__c) {
                qcpIds.add(qrpc_i.zqu__QuoteRatePlan__c);
            }
        }     
        if (!forTotalListPriceRecalc.isEmpty()) {
            ZuoraQuoteMetricsManipulationHelper.calculateTotalListPrice(forTotalListPriceRecalc);
        }


        Set<Id> quoteIds = new Set<Id>();
        List<zqu__QuoteRatePlan__c> qrpDDList = [SELECT Id,zqu__Quote__c FROM zqu__QuoteRatePlan__c WHERE Id IN:qcpIds];
        for (zqu__QuoteRatePlan__c qrp_i : qrpDDList) {
            quoteIds.add(qrp_i.zqu__Quote__c);
        }
        if (!quoteIds.isEmpty()) {
            System.debug('i am in qcsummary domain 2');
            BaseProductAddonCalculationHelper.calculateAmendWording(quoteIds);
        }
    }

    public class Constructor implements GenericDomain.IConstructable
	{
		public GenericDomain constructDomainInstance(List<SObject> sObjectList)
		{
			return new ZQuoteChargeSummaryDomain(sObjectList);
		}
	}
}
public with sharing class BaseProductAddonCalculationHelper {

    public static void determineRatePlanTypeAndSetDynamicField(List<zqu__QuoteRatePlan__c> qrpRecords){
        List<zqu__Quote__C> quotesToUpdate = new List<zqu__Quote__C>();
        Set<Id> quoteIds = new Set<Id>();
//
        for (zqu__QuoteRatePlan__c qrp_i : qrpRecords) {
            if (String.isNotBlank(qrp_i.zqu__Quote__c)) {
                quoteIds.add(qrp_i.zqu__Quote__c);   
            }           
        }
        WordingProcess process = new WordingProcess('quoteRatePlanUpdate');
        Map<Id,zqu__Quote__c> blackBoxQuoteMap = process.populateObjectWithWording(quoteIds);
        quotesToUpdate.addAll(blackBoxQuoteMap.values());
//        UpdateZQuoteQueueable queueableJob = new UpdateZQuoteQueueable(quotesToUpdate);
//        ID jobID = System.enqueueJob(queueableJob);
        update quotesToUpdate;

    }

    public static void calculateAmendWording(Set<Id> quoteIds){ // alon wording need to add Contract_Wording__c
        WordingProcess process = new WordingProcess('calculateAmendWording');
        Map<Id,zqu__Quote__c> blackBoxQuoteMap = process.populateObjectWithWording(quoteIds);

        List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
        quotesToUpdate.addAll(blackBoxQuoteMap.values());
        update quotesToUpdate;
    }
}
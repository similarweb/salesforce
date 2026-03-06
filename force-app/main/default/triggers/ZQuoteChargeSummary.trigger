trigger ZQuoteChargeSummary on zqu__QuoteChargeSummary__c (after insert,
                                                           after update,before update)
{
    if(Trigger.isBefore && Trigger.isUpdate){
        ZQuoteChargeSummaryDomain.onBeforeUpdate(Trigger.new);
    }
    GenericDomain.triggerHandler(ZQuoteChargeSummaryDomain.class);
}
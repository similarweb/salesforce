trigger ZQuoteRatePlanChargeTrigger on zqu__QuoteRatePlanCharge__c (after delete
                                                            , after insert
                                                            , after undelete
                                                            , after update
                                                            , before delete
                                                            , before insert
                                                            , before update) 
{
    GenericDomain.triggerHandler(ZQuoteRatePlanChargeDomain.class);

}
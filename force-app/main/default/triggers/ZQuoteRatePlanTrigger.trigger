trigger ZQuoteRatePlanTrigger on zqu__QuoteRatePlan__c (after delete
                                                        , after insert
                                                        , after undelete
                                                        , after update
                                                        , before delete
                                                        , before insert
                                                        , before update) 
{
    GenericDomain.triggerHandler(ZQuoteRatePlanDomain.class);

}
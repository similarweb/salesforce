trigger NEW_ZQuoteTrigger on zqu__Quote__c (before insert
                                          , before update
                                          , after insert
                                          , after update)
{
    GenericDomain.triggerHandler(ZQuoteDomain.class);
}
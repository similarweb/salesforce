trigger DocuSignStatusTrigger on dsfs__DocuSign_Status__c (before insert
                                                         , before update
                                                         , after insert
                                                         , after update)
{
    GenericDomain.triggerHandler(DocuSignStatusDomain.class);
}
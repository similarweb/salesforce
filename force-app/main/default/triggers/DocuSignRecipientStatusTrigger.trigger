trigger DocuSignRecipientStatusTrigger on dsfs__DocuSign_Recipient_Status__c (before insert
                                                                            , before update
                                                                            , after insert
                                                                            , after update)
{
    GenericDomain.triggerHandler(DocuSignRecipientStatusDomain.class);
}
trigger EventTrigger on Event (before insert
                                , before update
                                , after insert
                                , after update)
{
    GenericDomain.triggerHandler(EventDomain.class);
}
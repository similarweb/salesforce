trigger ZuoraSubscription on Zuora__Subscription__c (before delete, before insert, 
before update, after insert, after delete, after update, after undelete) {
	if (Utils.CodeOff) {
		return;
	}
	
	
	if (trigger.isBefore)
	{
		if (trigger.isInsert)
		{
			ZuoraSubscriptionHandler.HandleBefore (trigger.new,null,'Insert');
		}
		if (trigger.IsUpdate)
		{
			ZuoraSubscriptionHandler.HandleBefore (trigger.new,trigger.oldmap,'Update');
		}
		if (trigger.isDelete)
		{
			ZuoraSubscriptionHandler.HandleBefore (trigger.old,null,'Delete');
		}
	}
	
	if (trigger.isAfter)
	{
		if (trigger.isInsert)
		{
			ZuoraSubscriptionHandler.HandleAfter (trigger.new,null,'Insert');
		}
		if (trigger.IsUpdate)
		{
			ZuoraSubscriptionHandler.HandleAfter (trigger.new,trigger.oldmap,'Update');
		}
		if (trigger.isDelete)
		{
			ZuoraSubscriptionHandler.HandleAfter (trigger.old,null,'Delete');
		}
	}

}
trigger SubscriptionProductNChargeTrigger on Zuora__SubscriptionProductCharge__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if (trigger.isBefore)
	{						// BEFORE - START
		if (trigger.isInsert)
		{						// INSERT - START
			SubscriptionProductNChargeHandler.HandleBEFORE(trigger.new,null,'Insert');
		}						// INSERT - END
		
		if (trigger.isupdate)
		{						// UPDATE - START
			SubscriptionProductNChargeHandler.HandleBEFORE (trigger.new,trigger.oldmap,'Update');
		}						// UPDATE - END
		
		
	}						// BEFORE - END
	

}
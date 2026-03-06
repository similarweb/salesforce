trigger QuoteRatePlanChargeTrigger on zqu__QuoteRatePlanCharge__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	system.debug('TESTING fired QuoteRatePlanChargeTrigger. Utils is '+Utils.CodeOff);
	//  if (!Utils.Codeoff)
	// {
		if (trigger.isBefore)
		{
			ZQuoteRatePlanChargeDomain.onBefore(Trigger.new);
			// if (trigger.isInsert) QuoteRatePlanChargeTriggerHandler.HandleBefore (trigger.new,null,'Insert'); 
			// if (trigger.isUpdate) QuoteRatePlanChargeTriggerHandler.HandleBefore (trigger.new,trigger.oldmap,'Update');
			// if (trigger.isDelete) QuoteRatePlanChargeTriggerHandler.HandleBefore (trigger.old,null,'Delete');
			// if (trigger.isUndelete) QuoteRatePlanChargeTriggerHandler.HandleBefore (trigger.new,null,'Undelete');

		}
		
		// if (trigger.isAfter)
		// {
		// 	if (trigger.isInsert) QuoteRatePlanChargeTriggerHandler.HandleAfter (trigger.new,null,'Insert');
		// 	if (trigger.isUpdate) QuoteRatePlanChargeTriggerHandler.HandleAfter (trigger.new,trigger.oldmap,'Update');
		// 	if (trigger.isDelete) QuoteRatePlanChargeTriggerHandler.HandleAfter (trigger.old,null,'Delete');
		// 	if (trigger.isUndelete) QuoteRatePlanChargeTriggerHandler.HandleAfter (trigger.new,null,'Undelete');
		// }
	// } 

}
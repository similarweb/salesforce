trigger OppTrigger on Opportunity (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	map <string,CSTriggerControl__c> cstrigControl = CSTriggerControl__c.getall();
    if (!cstrigControl.ContainsKey ('Opportunity') || (cstrigControl.ContainsKey('Opportunity') && cstrigControl.get('Opportunity').on__c))
    {
		if (trigger.isBefore)
		{							// BEFORE - START
			if (trigger.isInsert)
			{						//Insert - START
				OppTriggerHandler.HandleBefore (trigger.new, null, 'Insert');
			}						//Insert - END
		}							// BEFORE - END
    }

}
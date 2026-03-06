trigger BillingAccountTrigger on Zuora__CustomerAccount__c (after update, after insert) {
	
	 map <string,CSTriggerControl__c> cstrigControl = CSTriggerControl__c.getall();
    
     if (!cstrigControl.ContainsKey ('ZbillingAccount') || (cstrigControl.ContainsKey('ZbillingAccount') && cstrigControl.get('ZbillingAccount').on__c))
     {
     	if (trigger.isAfter)
     	{						// AFTER - START
     		if (trigger.isInsert)
     		{						// UPDATE - START
     			ZBillingAccountHandler.HandleAfter (trigger.new, null, 'Insert');
     		}						// UPDATE - END
     		
     		if (trigger.isUpdate)
     		{						// UPDATE - START
     			ZBillingAccountHandler.HandleAfter (trigger.new, trigger.oldmap, 'Update');
     		}						// UPDATE - END
     	}						// AFTER - END
     }

}
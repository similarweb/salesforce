trigger ProformaInvoiceTrigger on Proforma_Invoice__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if (trigger.isAfter)
	{
		if (trigger.isUpdate)
		{
			ProformaHandler.HandleAFter (trigger.new, trigger.oldmap, 'Update');
		}
	}

}
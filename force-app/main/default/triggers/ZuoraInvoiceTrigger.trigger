trigger ZuoraInvoiceTrigger on Zuora__ZInvoice__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	
	if (trigger.isBefore)
	{
		if (trigger.isInsert)
		{
			ZInvoiceHandler.HandleBEFORE (trigger.new,null,'Insert');
		}
	}

}
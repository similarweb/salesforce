trigger ZuoraInvoiceTrigger on Zuora__ZInvoice__c(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      ZInvoiceHandler.HandleBEFORE(Trigger.new, null, 'Insert');
    }
  }

}

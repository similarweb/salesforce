trigger ProformaInvoiceTrigger on Proforma_Invoice__c(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      ProformaHandler.HandleAFter(Trigger.new, Trigger.oldmap, 'Update');
    }
  }

}

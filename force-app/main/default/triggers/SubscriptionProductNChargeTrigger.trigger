trigger SubscriptionProductNChargeTrigger on Zuora__SubscriptionProductCharge__c(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  if (Trigger.isBefore) {
    // BEFORE - START
    if (Trigger.isInsert) {
      // INSERT - START
      SubscriptionProductNChargeHandler.HandleBEFORE(
        Trigger.new,
        null,
        'Insert'
      );
    } // INSERT - END

    if (Trigger.isupdate) {
      // UPDATE - START
      SubscriptionProductNChargeHandler.HandleBEFORE(
        Trigger.new,
        Trigger.oldmap,
        'Update'
      );
    } // UPDATE - END
  } // BEFORE - END

}

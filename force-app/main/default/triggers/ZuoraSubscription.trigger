trigger ZuoraSubscription on Zuora__Subscription__c(
  before delete,
  before insert,
  before update,
  after insert,
  after delete,
  after update,
  after undelete
) {
  if (Utils.CodeOff) {
    return;
  }

  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      ZuoraSubscriptionHandler.HandleBefore(Trigger.new, null, 'Insert');
    }
    if (Trigger.IsUpdate) {
      ZuoraSubscriptionHandler.HandleBefore(
        Trigger.new,
        Trigger.oldmap,
        'Update'
      );
    }
    if (Trigger.isDelete) {
      ZuoraSubscriptionHandler.HandleBefore(Trigger.old, null, 'Delete');
    }
  }

  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      ZuoraSubscriptionHandler.HandleAfter(Trigger.new, null, 'Insert');
    }
    if (Trigger.IsUpdate) {
      ZuoraSubscriptionHandler.HandleAfter(
        Trigger.new,
        Trigger.oldmap,
        'Update'
      );
    }
    if (Trigger.isDelete) {
      ZuoraSubscriptionHandler.HandleAfter(Trigger.old, null, 'Delete');
    }
  }

}

trigger BillingAccountTrigger on Zuora__CustomerAccount__c(
  after update,
  after insert
) {
  map<string, CSTriggerControl__c> cstrigControl = CSTriggerControl__c.getall();

  if (
    !cstrigControl.ContainsKey('ZbillingAccount') ||
    (cstrigControl.ContainsKey('ZbillingAccount') &&
    cstrigControl.get('ZbillingAccount').on__c)
  ) {
    if (Trigger.isAfter) {
      // AFTER - START
      if (Trigger.isInsert) {
        // UPDATE - START
        ZBillingAccountHandler.HandleAfter(Trigger.new, null, 'Insert');
      } // UPDATE - END

      if (Trigger.isUpdate) {
        // UPDATE - START
        ZBillingAccountHandler.HandleAfter(
          Trigger.new,
          Trigger.oldmap,
          'Update'
        );
      } // UPDATE - END
    } // AFTER - END
  }

}

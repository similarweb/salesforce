trigger ZuoraBillingAccountTrigger on Zuora__CustomerAccount__c(
  after insert,
  after update
) {
  GenericDomain.triggerHandler(ZuoraBillingAccountDomain.class);
}

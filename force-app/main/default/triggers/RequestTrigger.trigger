trigger RequestTrigger on Request__c(
  after insert,
  before insert,
  after update
) {
  GenericDomain.triggerHandler(RequestDomain.class);
}

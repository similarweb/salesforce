trigger ZQuoteAmendmentTrigger on zqu__QuoteAmendment__c(
  before insert,
  before update,
  before delete,
  after insert,
  after update,
  after delete
) {
  GenericDomain.triggerHandler(ZQuoteAmendDomain.class);
}

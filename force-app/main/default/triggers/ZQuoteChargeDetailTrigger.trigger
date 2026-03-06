trigger ZQuoteChargeDetailTrigger on zqu__QuoteChargeDetail__c(
  after insert,
  before insert,
  before update
) {
  GenericDomain.triggerHandler(ZQuoteChargeDetailDomain.class);
}

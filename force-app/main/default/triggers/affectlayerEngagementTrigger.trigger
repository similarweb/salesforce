trigger affectlayerEngagementTrigger on affectlayer__Engagement__c(
  after insert
) {
  affectlayerEngagementTriggerHandler.handleAfterInsert(Trigger.new);
}

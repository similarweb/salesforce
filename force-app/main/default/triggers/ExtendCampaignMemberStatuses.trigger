trigger ExtendCampaignMemberStatuses on Campaign(after insert) {
  if (Trigger.isInsert) {
    ExtendMemberStatusesTriggerHandler.ExtendMemberStatuses(Trigger.new);
  }
}

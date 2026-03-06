/**
 * Created by Alon.Shalev on 11/19/2023.
 */
trigger CampaignMemberTrigger on CampaignMember(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  CampaignMemberHandler handler = new CampaignMemberHandler();

  if (Trigger.isInsert && Trigger.isAfter) {
    //        handler.createHistoryRecords(trigger.new,null);
  }

  if (Trigger.isUpdate && Trigger.isAfter) {
    handler.createHistoryRecords(Trigger.new, Trigger.oldMap);
  }

}

/**
 * Created by Alon.Shalev on 11/19/2023.
 */
trigger CampaignMemberTrigger on CampaignMember  (after delete, after insert, after undelete,
        after update, before delete, before insert, before update) {
    CampaignMemberHandler handler = new CampaignMemberHandler();

    if(trigger.isInsert && trigger.isAfter){
//        handler.createHistoryRecords(trigger.new,null);

    }

    if(trigger.isUpdate && trigger.isAfter){
        handler.createHistoryRecords(trigger.new,Trigger.oldMap);
    }

}
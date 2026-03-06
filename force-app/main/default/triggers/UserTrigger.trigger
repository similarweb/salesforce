trigger UserTrigger on User (before insert, after insert, 
                            before update, after update, 
                            before delete, after delete, 
                            after undelete) {
	if (Trigger.isAfter) {
        if (Trigger.isInsert){
            UserTriggerHandler.manageCommunityUserSharing((List<User>)Trigger.new, null);
            UserHistoryService.handleAfterInsert(Trigger.new);
        }    
        if (Trigger.isUpdate) {
            UserTriggerHandler.manageCommunityUserSharing((List<User>)Trigger.new, (Map<Id, User>)Trigger.oldMap);
            UserHistoryService.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
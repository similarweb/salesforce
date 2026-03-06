/**
 * Created by alon.shalev on 5/11/2025.
 */


trigger TerritoryMemberTrigger on Territory_Member__c (before insert, before update, before delete) {

    TerritoryMemberHandler handler = new TerritoryMemberHandler();

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            handler.duplicationValidation(Trigger.new);
        }
		if (Trigger.isDelete) {
			handler.handleBeforeDelete(Trigger.Old);
		}
    }
}
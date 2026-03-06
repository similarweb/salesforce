trigger CLCStageTrigger on CLC_Stage__c (before insert, after insert, 
                                        before update, after update, 
                                        before delete, after delete) {
	CLCStageTriggerhandler hndl = new CLCStageTriggerhandler();
                                            
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            hndl.beforeInsert();
        }
        
        if (Trigger.isUpdate) {
            hndl.beforeUpdate();
        }
    }                                        
}
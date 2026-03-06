trigger TaskTriggerCounter on Task (after insert, after update, after delete, after undelete) {
 	/*
    if(trigger.isInsert){
        System.debug('task counter insert');
    }
    if(trigger.isUpdate){
        System.debug('task counter update');
    }
    
    if(trigger.isDelete){
        System.debug('task counter delete');
    }
    
    sObject[] triggerRecords;
    if(!trigger.isDelete) triggerRecords = trigger.new;
    else triggerRecords = trigger.old;
 
    //Update Open Activity Count
    ActivityUtils au;
    if(trigger.isUpdate){
        au = new ActivityUtils(triggerRecords,Trigger.oldMap);
    } else  {
        au = new ActivityUtils(triggerRecords);
    }
    au.updateAccountActivityCount();
    au.updateContactActivityCount();
    au.updateLeadActivityCount();
    au.updateOpportunityActivityCount();
 	*/
}
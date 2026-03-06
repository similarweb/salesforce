/**
 * Created by Alon.Shalev on 11/10/2024.
 */

trigger CaseTrigger on Case (after delete, after insert, after undelete,
        after update, before delete, before insert, before update) {
    CaseTriggerHandler handler = new CaseTriggerHandler();

    // before
    if(Trigger.isBefore){

    }

    // after
    if(Trigger.isAfter){
        if(Trigger.isInsert){
           // handler.updateRelatedQuoteOnCreate(Trigger.new);
        }
        if(Trigger.isUpdate){
            //handler.updateRelatedQuoteOnUpdate(Trigger.new);
        }

    }
}
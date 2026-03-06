/**
 * Created by Alon.Shalev on 3/27/2024.
 */

trigger TerritoryTrigger on Territory__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TerritoryHandler handler = new TerritoryHandler();

    //before

    if(Trigger.isInsert && Trigger.isBefore){
        handler.nalTerritoryValidation(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        handler.nalTerritoryValidationOnUpdate(Trigger.new , Trigger.oldMap);
        handler.validationOfTerritoryMemberDuplication(Trigger.new , Trigger.oldMap);
    }

}
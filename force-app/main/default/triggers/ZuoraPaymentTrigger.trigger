/**
 * Created by alon.shalev on 5/4/2025.
 */

trigger ZuoraPaymentTrigger on Zuora__Payment__c (after insert, after update) {

    ZuoraPaymentHandler handler = new ZuoraPaymentHandler();

    if(Trigger.isAfter && Trigger.isInsert){
        handler.setSubscriptionPaymentStatus(trigger.new);

    }
    if(Trigger.isAfter && Trigger.isUpdate){
        handler.setSubscriptionPaymentStatusOnUpdate(Trigger.new , Trigger.oldMap);

    }

}
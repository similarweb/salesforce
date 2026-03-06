/**
 * Created by Alon.Shalev on 5/22/2025.
 */

global with sharing class SyncContactOwnerWithAccountOwnerBatch implements Database.Batchable<SObject>,Schedulable {

    global void execute (SchedulableContext SC){
        SyncContactOwnerWithAccountOwnerBatch batch = new SyncContactOwnerWithAccountOwnerBatch();
        Database.executeBatch(batch,5);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id,OwnerId,Account.OwnerId,Account.Owner.Name,Owner_Role__c,Business_Unit__c,pi__notes__c ' +
                'FROM Contact ' +
                'WHERE Account.Owner_Change_Date__c = TODAY ' +
                'OR Account.Owner_Change_Date__c = YESTERDAY ' +
                'OR Owner_Change_Date__c = TODAY ' +
                'OR Owner_Change_Date__c = YESTERDAY';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        for(Contact contact : scope){
            if(contact.Account != null && contact.OwnerId != contact.Account.OwnerId){
                if(checkForAllOtherConditions(contact)){
                    contact.OwnerId = contact.Account.OwnerId;
                }
            }
        }
        update scope;

    }

    global void finish(Database.BatchableContext BC) {

    }

    private Boolean checkForAllOtherConditions(Contact contact){
        String panelString = 'panel';
        String mirString = 'MIR';
        String salesforceAdminStr = 'salesforce admin';
        Boolean accountOwnerAdminBool = contact.Account.Owner == null || !contact.Account.Owner.Name.contains(salesforceAdminStr);
        Boolean engagementNotesBool = String.isBlank(contact.pi__notes__c);
        Boolean ownerRoleMirBool = contact.Owner_Role__c != mirString;
        Boolean ownerRolePanelBool = String.isBlank(contact.Owner_Role__c) || !contact.Owner_Role__c.contains(panelString);
        Boolean businessBool = String.isBlank(contact.Business_Unit__c) || !contact.Business_Unit__c.contains(panelString);

        return ownerRolePanelBool && ownerRoleMirBool && businessBool && accountOwnerAdminBool && engagementNotesBool;
    }


}
public with sharing class DeactivateUsersBatch implements Database.Batchable<SObject>, Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(this, 1);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, User__c
            FROM Manage_Users_Log__c
            WHERE Today_is_Action_Date__c = true
            AND Action__c = 'Deactivate'
            AND Status__c = 'Open'
            AND User__c != NULL
        ]);
    }

    // This batch supposed to run only for 1 user per transaction
    public void execute(Database.BatchableContext bc, List<Manage_Users_Log__c> scope) {
        //try {
            User userToDeactivate = new User(Id = scope[0].User__c, IsActive = false, Level_11__c = false);
            update userToDeactivate;
            // List<AccountTeamMember> accTeamMembers = [SELECT Id, UserId FROM AccountTeamMember WHERE UserId =: scope[0].User__c];
            // List<Territory_Member__c> terrMembers = [SELECT Id, Name__c FROM Territory_Member__c WHERE Name__c =: scope[0].User__c];
            // List<UserPackageLicense> userPackageLicenses = [SELECT Id, UserId FROM UserPackageLicense WHERE UserId =: scope[0].User__c];
            // if (accTeamMembers.size() > 0) {
            //     delete accTeamMembers;
            // }
            // if (terrMembers.size() > 0) {
            //     delete terrMembers;
            // }
            // if (userPackageLicenses.size() > 0) {
            //     delete userPackageLicenses;
            // }
            scope[0].Status__c = 'Completed';
        // }
        // catch (Exception e) {
        //     scope[0].Status__c = 'Failed';
        //     scope[0].Fault_Massage__c = e.getMessage();
        // }
        System.enqueueJob(new LogUpdateQueueable(scope[0]));
    }

    public void finish(Database.BatchableContext bc) {
    }

    public class LogUpdateQueueable implements System.Queueable {
        Manage_Users_Log__c log;

        public LogUpdateQueueable(Manage_Users_Log__c rec) {
            this.log = rec;
        }

        public void execute(System.QueueableContext context) {
            update this.log;
        }
    }
}
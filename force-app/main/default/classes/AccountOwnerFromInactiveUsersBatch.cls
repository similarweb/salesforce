/**
 * Created by Alon.Shalev on 3/4/2024.
 */

public with sharing class AccountOwnerFromInactiveUsersBatch implements Database.Batchable<sObject> ,Schedulable,Database.Stateful{

    Set<Id> accountIdSet = new Set<Id>();
    Set<Id> meetingIdSet = new Set<Id>();
    Set<Id> territoryIdSet = new Set<Id>();

    public void execute (SchedulableContext SC){
        AccountOwnerFromInactiveUsersBatch batch = new AccountOwnerFromInactiveUsersBatch();
        Database.executeBatch(batch,1);
    }

    public Database.QueryLocator start (Database.BatchableContext BC){

        String deactivateAction = 'Deactivate';
        String query = 'SELECT User__c,Status__c,Action__c,Date_For_Action__c' +
                        ' FROM Manage_Users_Log__c' +
                        ' WHERE Action__c =: deactivateAction ' +
                        ' AND Date_For_Action__c = YESTERDAY';
        return Database.getQueryLocator(query);


    }

    public void execute(Database.BatchableContext BC, List<Manage_Users_Log__c> scope){
        Set<Id> userIdSet = new Set<Id>();

        for(Manage_Users_Log__c manageLog : scope){
            userIdSet.add(manageLog.User__c);
        }
        List<Account> ownerAccountList = [SELECT Id FROM Account WHERE OwnerId IN: userIdSet];
        for(Account acc : ownerAccountList){
            accountIdSet.add(acc.Id);
        }
        Set<String> openMeetingsStatus = new Set<String>();
        openMeetingsStatus.add('Rescheduling');
        openMeetingsStatus.add('Scheduling in Progress');
        openMeetingsStatus.add('Placeholder');
        openMeetingsStatus.add('In Progress');
        openMeetingsStatus.add('Pending');
        List<Meeting__c> ownerMeetingList = [SELECT Id FROM Meeting__c WHERE OwnerId IN :userIdSet AND Status__c IN : openMeetingsStatus];
        for(Meeting__c meeting : ownerMeetingList){
            meetingIdSet.add(meeting.Id);
        }

        for(Territory__c terr : [SELECT Id FROM Territory__c WHERE OwnerId IN : userIdSet]){
            territoryIdSet.add(terr.Id);
        }
        System.debug([SELECT Count(id) FROM Territory__c WHERE OwnerId IN : userIdSet] +' asdasdasdasd');

    }



    public void finish(Database.BatchableContext BC){
        Database.executeBatch(new UpdateAccountOwnerBatch(accountIdSet),3);
        Database.executeBatch(new UpdateMeetingOwnerBatch(meetingIdSet),3);
        Database.executeBatch(new UpdateTerritoryOwnerBatch(territoryIdSet),3);
    }

}
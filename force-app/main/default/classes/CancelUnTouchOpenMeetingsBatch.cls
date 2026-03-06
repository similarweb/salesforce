/**
 * Created by Alon.Shalev on 9/7/2023.
 */

public with sharing class CancelUnTouchOpenMeetingsBatch implements Database.Batchable<sObject> ,Schedulable{

    private Set<String> closedStatusSet = new Set<String>{'Cancelled','Completed','Unqualified'};
    private Integer batchSize = 1;
    private String recordTypeToExclude = 'Calendar Event';


    public void execute(SchedulableContext scMain) {

        CancelUnTouchOpenMeetingsBatch batch = new CancelUnTouchOpenMeetingsBatch(this.batchSize);
        Database.executeBatch(batch, this.batchSize);

    }
    public CancelUnTouchOpenMeetingsBatch(Integer batchSize){
        this.batchSize = batchSize;
    }

    public Database.QueryLocator start (Database.BatchableContext BC){
        String query = 'SELECT Id FROM Meeting__c WHERE Status__c NOT IN : closedStatusSet AND RecordType.Name !=:recordTypeToExclude ';
        query += Test.isRunningTest() ? '' : 'AND LastModifiedDate < LAST_N_MONTHS:6';
        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<Meeting__c> scope){
        for(Meeting__c meeting :scope){
            meeting.Status__c = 'Cancelled';
            meeting.Cancelled_Reason__c = 'this meeting was untouched for the last 6 months';
            meeting.Unqualified_Reason__c  = 'this meeting was untouched for the last 6 months';
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC){
    }

}
/**
 * Created by Alon.Shalev on 9/7/2023.
 */

public with sharing class CancelUnTouchedOpenTasksBatch implements Database.Batchable<sObject> ,Schedulable {

    private Set<String> closedStatusSet = new Set<String>{'Completed','Cancelled / Irrelevant','Rejected'};
    private Integer batchSize = 1;

    public CancelUnTouchedOpenTasksBatch(Integer batchSize){
        this.batchSize = batchSize;
    }

    public void execute(SchedulableContext scMain) {

        CancelUnTouchedOpenTasksBatch batch = new CancelUnTouchedOpenTasksBatch(this.batchSize);
        Database.executeBatch(batch, this.batchSize);

    }

    public Database.QueryLocator start (Database.BatchableContext BC){
        String query = 'SELECT Id FROM Task WHERE Status NOT IN : closedStatusSet ';
        query += Test.isRunningTest() ? '' : 'AND LastModifiedDate < LAST_N_YEARS:1';
        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext BC, List<Task> scope){
        for(Task task :scope){
            task.Status = 'Cancelled / Irrelevant';
        }
        update scope;
    }

    public void finish(Database.BatchableContext BC){
    }


}
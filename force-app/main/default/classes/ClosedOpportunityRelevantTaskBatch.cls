global class ClosedOpportunityRelevantTaskBatch implements Database.Batchable<sObject>, Schedulable {
  private static final Integer DUE_DATE_DAYS = 5;

  String query;
  String recordTypeId;

  global ClosedOpportunityRelevantTaskBatch() {
    List<recordtype> rts = [
      SELECT id, developername, name
      FROM recordtype
      WHERE sobjecttype = 'Task' AND (developername = 'task' OR name = 'task')
      LIMIT 1
    ];
    if (!rts.isEmpty()) {
      recordTypeId = rts[0].Id;
    }

    query = 'SELECT Id, Relevant_Task_Creation_Date__c, AccountId, Account.OwnerId FROM Opportunity WHERE Relevant_Task_Creation_Date__c=TODAY';
  }

  global void execute(SchedulableContext SC) {
    Database.executeBatch(new ClosedOpportunityRelevantTaskBatch());
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
    List<Task> newTasks = new List<Task>();
    for (Opportunity opp : scope) {
      newTasks.add(
        getTaskForRelevantOpp(opp.Id, opp.Account.OwnerId, opp.AccountId)
      );
    }
    System.debug('newTasks ' + newTasks);
    insert newTasks;
  }

  private Task getTaskForRelevantOpp(
    String oppId,
    String ownerId,
    String whatId
  ) {
    Task ntask = new Task();

    ntask.Subject = Label.Closed_Opp_relevant_Task_Subject;
    ntask.ActivityDate = Date.today().addDays(DUE_DATE_DAYS);
    nTask.RecordTypeId = recordTypeId;
    ntask.OwnerId = ownerId;
    ntask.Status = 'Not started';
    ntask.Priority = 'Normal';
    ntask.Type__c = 'Internal';
    ntask.Sub_type__c = 'Internal';
    ntask.WhatId = whatId;

    return ntask;
  }

  global void finish(Database.BatchableContext BC) {
  }
}

/**
 * Itzik Winograd 2022-01-26: Added parmeterless constructor and removed self-rescheduling.
 * */
public class TaskCounterBatch implements Database.Batchable<sObject>, Schedulable {
  private static List<String> objectList = new List<String>{
    'account',
    'contact',
    'opportunity',
    'lead'
  };
  private static Map<String, String> IdPrefixToFieldNameMap;

  private static String fieldToUpdate = 'Open_Activity_Count__c';
  private static String openTasksCountField = 'Open_Tasks_Counter__c';
  private static String closedTasksCountField = 'Closed_Tasks_Counter__c';

  private DateTime previousRunTime;
  private Integer pointer;
  private Boolean all = false;

  static {
    IdPrefixToFieldNameMap = new Map<String, String>();
    IdPrefixToFieldNameMap.put('account', 'AccountId');
    IdPrefixToFieldNameMap.put('contact', 'WhoId');
    IdPrefixToFieldNameMap.put('opportunity', 'WhatId');
    IdPrefixToFieldNameMap.put('lead', 'WhoId');
  }

  public TaskCounterBatch() {
  }

  public TaskCounterBatch(DateTime previousRunTime, Integer pointer) {
    this.previousRunTime = previousRunTime;
    this.pointer = pointer;
  }

  public TaskCounterBatch(
    DateTime previousRunTime,
    Integer pointer,
    Boolean all
  ) {
    this.previousRunTime = previousRunTime;
    this.pointer = pointer;
    this.all = all;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('start - ' + pointer);
    List<Id> entityIds = new List<Id>();
    String objName = objectList[pointer];
    String fieldName = IdPrefixToFieldNameMap.get(objName);
    String query;
    if (!all) {
      DateTime activityDateTime = DateTime.now();
      for (Event evnt : [
        SELECT whoId, whatId, AccountId
        FROM Event
        WHERE
          LastModifiedDate > :previousRunTime
          AND ActivityDateTime > :activityDateTime
      ]) {
        String entityId = (String) evnt.get(fieldName);
        if (
          String.isNotBlank(entityId) &&
          entityId.startsWithIgnoreCase(
            getIdPrefixFromObjectNameFromId(objName)
          )
        )
          entityIds.add(entityId);
      }
      for (Task task : [
        SELECT whoId, whatId, AccountId
        FROM Task
        WHERE LastModifiedDate > :previousRunTime
      ]) {
        String entityId = (String) task.get(fieldName);
        System.debug('entityId ' + entityId);

        if (
          String.isNotBlank(entityId) &&
          entityId.startsWithIgnoreCase(
            getIdPrefixFromObjectNameFromId(objName)
          )
        ) {
          System.debug(
            'entityId J' +
            entityId.startsWithIgnoreCase(
              getIdPrefixFromObjectNameFromId(objName)
            )
          );
          entityIds.add(entityId);
        }
      }

      query = 'SELECT Id FROM ' + objName + ' WHERE Id IN :entityIds';
    } else {
      query = 'SELECT Id FROM ' + objName;
    }

    System.debug('query ' + query);
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    System.debug('scope ' + scope);
    String objName = objectList[pointer];

    Map<String, Decimal> entityToOpenTaskMap = new Map<String, Decimal>();
    Map<String, Decimal> entityToClosedTaskMap = new Map<String, Decimal>();
    Map<String, Decimal> entityToEventTaskMap = new Map<String, Decimal>();

    List<String> entityIds = new List<String>();
    for (SObject sobj_i : scope) {
      entityIds.add(sobj_i.Id);
    }

    String opentTaskQuery =
      'SELECT count(id) cnt, ' +
      IdPrefixToFieldNameMap.get(objName) +
      ' FROM Task WHERE isClosed=false AND ' +
      IdPrefixToFieldNameMap.get(objName) +
      ' IN :entityIds group by ' +
      IdPrefixToFieldNameMap.get(objName);
    String closedTaskQuery =
      'SELECT count(id) cnt, ' +
      IdPrefixToFieldNameMap.get(objName) +
      ' FROM Task WHERE isClosed=true AND ' +
      IdPrefixToFieldNameMap.get(objName) +
      ' IN :entityIds group by ' +
      IdPrefixToFieldNameMap.get(objName);
    String eventQuery =
      'SELECT count(id) cnt, ' +
      IdPrefixToFieldNameMap.get(objName) +
      ' FROM Event WHERE ActivityDateTime >' +
      ((Datetime.now() + '').replace(' ', 'T') + 'Z') +
      ' AND ' +
      IdPrefixToFieldNameMap.get(objName) +
      ' IN :entityIds group by ' +
      IdPrefixToFieldNameMap.get(objName);
    System.debug('opentTaskQuery ' + opentTaskQuery);
    for (AggregateResult res : Database.query(opentTaskQuery)) {
      if (res.get(IdPrefixToFieldNameMap.get(objName)) != null) {
        String parentId = (String) res.get(IdPrefixToFieldNameMap.get(objName));
        if (entityToOpenTaskMap.containsKey(parentId)) {
          entityToOpenTaskMap.put(
            parentId,
            entityToOpenTaskMap.get(parentId) + (Decimal) res.get('cnt')
          );
        } else {
          entityToOpenTaskMap.put(parentId, (Decimal) res.get('cnt'));
        }
      }
    }
    if (objName == 'contact') {
      for (AggregateResult res : Database.query(closedTaskQuery)) {
        if (res.get(IdPrefixToFieldNameMap.get(objName)) != null) {
          String parentId = (String) res.get(
            IdPrefixToFieldNameMap.get(objName)
          );
          if (entityToClosedTaskMap.containsKey(parentId)) {
            entityToClosedTaskMap.put(
              parentId,
              entityToClosedTaskMap.get(parentId) + (Decimal) res.get('cnt')
            );
          } else {
            entityToClosedTaskMap.put(parentId, (Decimal) res.get('cnt'));
          }
        }
      }
    }
    for (AggregateResult res : Database.query(eventQuery)) {
      if (res.get(IdPrefixToFieldNameMap.get(objName)) != null) {
        String parentId = (String) res.get(IdPrefixToFieldNameMap.get(objName));
        if (entityToEventTaskMap.containsKey(parentId)) {
          entityToEventTaskMap.put(
            parentId,
            entityToEventTaskMap.get(parentId) + (Decimal) res.get('cnt')
          );
        } else {
          entityToEventTaskMap.put(parentId, (Decimal) res.get('cnt'));
        }
      }
    }
    for (SObject sobj_i : scope) {
      Decimal numOfOpenTasks = entityToOpenTaskMap.containsKey(sobj_i.Id)
        ? entityToOpenTaskMap.get(sobj_i.Id)
        : 0;
      Decimal numOfEvents = entityToEventTaskMap.containsKey(sobj_i.Id)
        ? entityToEventTaskMap.get(sobj_i.Id)
        : 0;

      sobj_i.put(fieldToUpdate, numOfOpenTasks + numOfEvents);
      if (objName == 'contact') {
        Decimal numOfClosedTasks = entityToClosedTaskMap.containsKey(sobj_i.Id)
          ? entityToClosedTaskMap.get(sobj_i.Id)
          : 0;
        sobj_i.put(openTasksCountField, numOfOpenTasks);
        sobj_i.put(closedTasksCountField, numOfClosedTasks);
      }
    }
    try {
      update scope;
    } catch (Exception ex) {
      System.debug('EXCEPTION - ' + ex.getMessage());
      System.debug('EXCEPTION - ' + ex.getCause().getMessage());
    }
  }

  public void finish(Database.BatchableContext BC) {
    if (pointer < 3) {
      Database.executeBatch(
        new TaskCounterBatch(previousRunTime, pointer + 1, all)
      );
    }
  }

  public void execute(SchedulableContext SC) {
    /** Itzik Winograd 2022-01-26: Removed inside rescheduling. All daily scheduling are done via UI.
        previousRunTime = Datetime.now().addDays(-1);
        if(SC != null){
            List<CronTrigger> cts = [SELECT ID, PreviousFireTime, NextFireTime, CronExpression, CronJobDetail.Name  FROM crontrigger 
                                     WHERE Id=: SC.getTriggerId() ];
            
            System.abortJob(SC.getTriggerId());        
        }
        //String CRONEXP = getCronFromDateTime(cts[0].PreviousFireTime.addDays(1));

        Time myTime = Time.newInstance(1, 0, 0, 0);
        Date myDate = Date.today().addDays(1);
        System.schedule('TaskCounterBatch',getCronFromDateTime(DateTime.newInstance(myDate, myTime)), new TaskCounterBatch(previousRunTime,0));
        System.debug('previousRunTime ' + previousRunTime);
         */
    //Itzik Winograd 2022-01-26: Added this:
    previousRunTime = Datetime.now().addDays(-1);
    Database.executeBatch(new TaskCounterBatch(previousRunTime, 0, all));
  }

  public static String getCronFromDateTime(Datetime executeTime) {
    return executeTime.second() +
      ' ' +
      executeTime.minute() +
      ' ' +
      executeTime.hour() +
      ' ' +
      executeTime.day() +
      ' ' +
      executeTime.month() +
      ' ? ' +
      executeTime.year();
  }

  private static String getIdPrefixFromObjectNameFromId(String objName) {
    if (objName == 'account')
      return '001';
    if (objName == 'contact')
      return '003';
    if (objName == 'opportunity')
      return '006';
    if (objName == 'lead')
      return '00q';
    return 'qqq';
  }
}

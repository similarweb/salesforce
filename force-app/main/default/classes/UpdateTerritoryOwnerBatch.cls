/**
 * Created by Alon.Shalev on 5/26/2024.
 */

public with sharing class UpdateTerritoryOwnerBatch implements Database.Batchable<sObject>, Database.Stateful {
  private Set<Id> territoryIdSet = new Set<Id>();
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();
  private Map<String, FlowParamsObj> flowParamMap = new Map<String, FlowParamsObj>();

  public UpdateTerritoryOwnerBatch(Set<Id> territoryIdSet) {
    this.territoryIdSet = territoryIdSet;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('territoryIdSet--' + territoryIdSet);
    String query = 'SELECT Id, Name, OwnerId, TYPEOF Owner WHEN User THEN Name, Email, Manager.Name, Manager.Email WHEN Group THEN Name END FROM Territory__c  WHERE Id IN :territoryIdSet';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Territory__c> scope) {
    System.debug('scope--' + scope.size());
    List<Territory__c> territoryToUpdateList = new List<Territory__c>();
    for (Territory__c terr : scope) {
      SObject owner = terr.Owner;
      if (owner.getSObjectType() == Group.sObjectType) {
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<String>{ terr.Id },
            'UpdateTerritoryOwnerBatch',
            'execute-updateTerritories',
            'Cant update this Territory because the owner is a group',
            'no detailed Error',
            'Error'
          )
        );
      } else {
        User ownerForSure = (User) terr.Owner;
        String managerId = ownerForSure.ManagerId;
        if (!this.flowParamMap.containsKey(managerId)) {
          this.flowParamMap.put(managerId, new FlowParamsObj());
        }
        System.debug('owner before --' + terr.OwnerId);
        terr.OwnerId = managerId;
        System.debug('owner after --' + terr.OwnerId);
        FlowParamsObj thisManagerFlowParams = this.flowParamMap.get(managerId);
        thisManagerFlowParams.currentOwnerName = ownerForSure.Manager.Name;
        thisManagerFlowParams.previousOwnerName = ownerForSure.Name;
        thisManagerFlowParams.currentOwnerEmail = ownerForSure.Manager.Email;
        territoryToUpdateList.add(terr);
      }
    }

    Integer index = 0;
    List<Database.SaveResult> saveResults = Database.update(
      territoryToUpdateList,
      false
    );
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        System.debug('didnt make it--' + sr.getErrors()[0].getMessage());
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<String>{ territoryToUpdateList[index].Id },
            'UpdateTerritoryOwnerBatch',
            'execute-updateTerritory',
            'Cant update this territory',
            sr.getErrors().toString(),
            'Error'
          )
        );
      }
      index++;
    }
  }
  private void publishLogs() {
    if (!logEvents.isEmpty()) {
      EventBus.publish(logEvents);
    }
  }

  public void finish(Database.BatchableContext BC) {
    System.debug('alon finished');
    List<FlowParamsObj> flowParamList = this.flowParamMap.values();
    publishLogs();
    Map<String, Object> inputs = new Map<String, Object>();
    //            String jsonThing = JSON.serialize(flowParamList);
    //            System.debug('jsonThing--'+jsonThing);
    //            System.debug('jsonThing--'+flowParamList);
    inputs.put('JSON_Collection', flowParamList);
    inputs.put('typeOfRecord', 'Territory');
    System.debug('inputs--' + inputs);
    System.debug('inputs--' + inputs.get('JSON_Collection'));
    if (!this.flowParamMap.isEmpty() && !Test.isRunningTest()) {
      Flow.Interview myFlow = new Flow.Interview.Generic_Send_Emails_to_New_Owners_Autolaunched(
        inputs
      );
      myFlow.start();
    }
  }
}

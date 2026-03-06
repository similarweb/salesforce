/**
 * Created by Alon.Shalev on 3/4/2024.
 */

public with sharing class UpdateAccountOwnerBatch implements Database.Batchable<sObject>, Database.Stateful {
  private Set<Id> accountIdSet = new Set<Id>();
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();
  private Map<Id, List<Account>> ownerManagerIdToAccountListMap = new Map<Id, List<Account>>();
  private Map<String, FlowParamsObj> flowParamMap = new Map<String, FlowParamsObj>();

  public UpdateAccountOwnerBatch(Set<Id> accountIdSet) {
    this.accountIdSet = accountIdSet;
    System.debug('accountIdSet--' + accountIdSet);
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    System.debug('accountIdSet--' + accountIdSet);
    String query = 'SELECT Id,status__c,Owner.Manager.Email,Owner.Manager.Name,Owner.ManagerId,Owner.Name,OwnerId,Name FROM Account WHERE Id IN :accountIdSet';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Account> scope) {
    System.debug('scope--' + scope.size());
    List<Account> accountToUpdateList = new List<Account>();
    for (Account acc : scope) {
      if (!this.flowParamMap.containsKey(acc.Owner.ManagerId)) {
        this.flowParamMap.put(acc.Owner.ManagerId, new FlowParamsObj());
      }
      acc.OwnerId = acc.Owner.ManagerId;
      FlowParamsObj thisManagerFlowParams = this.flowParamMap.get(
        acc.Owner.ManagerId
      );
      thisManagerFlowParams.currentOwnerName = acc.Owner.Manager.Name;
      thisManagerFlowParams.previousOwnerName = acc.Owner.Name;
      thisManagerFlowParams.currentOwnerEmail = acc.Owner.Manager.Email;
      accountToUpdateList.add(acc);
    }

    Integer index = 0;
    List<Database.SaveResult> saveResults = Database.update(
      accountToUpdateList,
      false
    );
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        System.debug('didnt make it--' + sr.getErrors()[0].getMessage());
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<String>{ accountToUpdateList[index].Id },
            'UpdateAccountOwnerBatch',
            'execute-updateAccounts',
            'Cant update this account',
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
    inputs.put('typeOfRecord', 'Account');
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

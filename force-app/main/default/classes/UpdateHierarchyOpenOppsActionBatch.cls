/**
 * Created by Alon.Shalev on 7/10/2024.
 */

public with sharing class UpdateHierarchyOpenOppsActionBatch implements Database.Batchable<sObject> {
  private Map<Id, Integer> accountIdToNumberOfOpenOppsInHierarcyMap = new Map<Id, Integer>();

  public UpdateHierarchyOpenOppsActionBatch(
    Map<Id, Integer> accountIdToNumberOfOpenOppsInHierarcyMap
  ) {
    this.accountIdToNumberOfOpenOppsInHierarcyMap = accountIdToNumberOfOpenOppsInHierarcyMap;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    Set<Id> relevantIdSet = this.accountIdToNumberOfOpenOppsInHierarcyMap.keySet();
    System.debug('relevantIdSet--' + relevantIdSet);
    System.debug('relevantIdSet--' + relevantIdSet.size());
    String query =
      'SELECT Id' +
      ' FROM Account ' +
      'WHERE Id IN : relevantIdSet';
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<Account> scope) {
    for (Account account : scope) {
      account.Hierarchy_Total_Open_Opps__c = this.accountIdToNumberOfOpenOppsInHierarcyMap.get(
        account.Id
      );
      account.Number_Of_Open_Opps_Changed_Today__c = false;
    }
    update scope;
  }

  public void finish(Database.BatchableContext param1) {
  }
}

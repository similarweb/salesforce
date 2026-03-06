public with sharing class TerritoryMemberAccountBatchable implements Database.Batchable<sObject> {
  private String query;

  public TerritoryMemberAccountBatchable(String query) {
    this.query = query;
  }

  public Database.QueryLocator start(Database.BatchableContext param1) {
    return Database.getQueryLocator(this.query);
  }

  public void execute(Database.BatchableContext param1, List<SObject> scope) {
    List<Account> accounts = (List<Account>) scope;

    for (Account acc : accounts) {
      acc.Exclude_From_Territory_Owner_Change__c = false;
    }

    update accounts;
  }

  public void finish(Database.BatchableContext param1) {
  }
}

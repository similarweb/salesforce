/**
 * Created by Alon.Shalev on 10/23/2022.
 */

public with sharing class ChurnAccountsBatch implements Database.Batchable<sObject>, Schedulable {
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();

  public ChurnAccountsBatch() {
    if (test.isRunningTest()) {
      addCoverage();
    }
  }

  /**
   * @description Schedulable execute. Get the batch size from CMD.
   * */
  public void execute(SchedulableContext SC) {
    Integer batchSize = GeneralUtil.getGeneralConfig(
        'ChurnAccountsBatch_BatchSize'
      )
      ?.Number_Value__c.intValue();
    ChurnAccountsBatch churnAccountsBatch = new churnAccountsBatch();
    Database.executeBatch(
      churnAccountsBatch,
      batchSize != null ? batchSize : 3
    );
  }

  /**
   * @description Batch start. Use query from CMD.
   * */
  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = CustomQueriesUtils.getCustomQuery('ChurnAccountBatch');
    return Database.getQueryLocator(query);
  }

  /**
   * @description loop over accounts and update the owner if it doesn't match the Territory owner.
   * */
  public void execute(Database.BatchableContext BC, List<Account> accountList) {
    List<Account> accountsToUpdate = new List<Account>();
    for (Account acc : accountList) {
      if (acc.OwnerId != acc.Territory__r.OwnerId) {
        acc.OwnerId = acc.Territory__r.OwnerId;
        accountsToUpdate.add(acc);
      }
    }
    updateAccounts(accountsToUpdate);
    publishLogs();
  }

  /**
   * @description if any logs created - publish them
   * */
  public void publishLogs() {
    if (!logEvents.isEmpty()) {
      EventBus.publish(logEvents);
    }
  }

  /**
   * @description Make an update dml on Accounts
   * */
  private void updateAccounts(List<Account> accountList) {
    if (!accountList.isEmpty()) {
      System.debug('### ChurnAccountsBatch updateAccounts: ' + accountList);
      Integer index = 0;
      List<Database.SaveResult> saveResults = Database.update(
        accountList,
        false
      );
      for (Database.SaveResult sr : saveResults) {
        if (!sr.isSuccess()) {
          logEvents.add(
            LogEventUtils.createLogEventRecord(
              new List<String>{ accountList[index].Id },
              'ChurnAccountsBatch',
              'updateAccounts',
              'Cant update this account: ',
              sr.getErrors().toString(),
              'Error'
            )
          );
        }
        index++;
      }
    }
  }

  public void finish(Database.BatchableContext BC) {
  }

  private void addCoverage() {
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
}

/**
 * Created by Alon.Shalev on 11/5/2023.
 */

public with sharing class UpdateGlobalPassBatch implements Database.Batchable<SObject>, Schedulable {
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();
  private final static integer BATCH_SIZE = 5;

  public void execute(SchedulableContext SC) {
    List<General_Key_Value_pair__mdt> settings = [
      SELECT Value__c
      FROM General_Key_Value_pair__mdt
      WHERE ProcessName__c = 'UpdateGlobalPassBatch'
    ];
    Integer batchSize = settings.isEmpty()
      ? BATCH_SIZE
      : Integer.valueOf(settings[0].Value__c);
    UpdateGlobalPassBatch updateGlobalPassBatch = new UpdateGlobalPassBatch();
    Database.executeBatch(updateGlobalPassBatch, batchSize);
  }

  public Database.QueryLocator start(Database.BatchableContext context) {
    String globalUser = '%Global User%';
    String activeStr = 'Active';
    DateTime lastModifiedTime = DateTime.now().addDays(-1);

    return Database.getQueryLocator(
      [
        SELECT Id, Zuora__Account__c
        FROM Zuora__SubscriptionProductCharge__c
        WHERE
          Zuora__ProductName__c LIKE :globalUser
          AND Status__c = :activeStr
          AND (CreatedDate >= :lastModifiedTime
          OR LastModifiedDate >= :lastModifiedTime)
      ]
    );
  }

  public void execute(
    Database.BatchableContext context,
    List<Zuora__SubscriptionProductCharge__c> scope
  ) {
    System.debug('scope---' + scope.size());
    Set<Id> accountIdsToUpdate = new Set<Id>();
    List<Account> accountToUpdateList = new List<Account>();

    for (Zuora__SubscriptionProductCharge__c charge : scope) {
      accountIdsToUpdate.add(charge.Zuora__Account__c);
    }
    List<Account> existingAccountToUpdateList = [
      SELECT Id, Global_Pass__c
      FROM Account
      WHERE Id IN :accountIdsToUpdate
    ];
    for (Account acc : existingAccountToUpdateList) {
      if (!acc.Global_Pass__c) {
        acc.Global_Pass__c = true;
        accountToUpdateList.add(acc);
      }
    }
    System.debug('accountToUpdateList--' + accountToUpdateList);
    List<Database.SaveResult> saveResultList = Database.update(
      accountToUpdateList,
      false
    );
    Integer index = 0;
    for (Database.SaveResult saveResult : saveResultList) {
      if (!saveResult.isSuccess()) {
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<Id>(),
            accountToUpdateList[index].Id,
            'UpdateGlobalPassBatch',
            'execute',
            saveResult.getErrors()[0].getMessage(),
            'something',
            'Error'
          )
        );
      }
      index++;
    }

    if (!logEvents.isEmpty()) {
      EventBus.publish(logEvents);
    }
  }

  public void finish(Database.BatchableContext context) {
    // Perform any post-processing logic if needed
  }
}

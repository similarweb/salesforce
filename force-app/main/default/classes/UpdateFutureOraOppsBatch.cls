/**
 * Created by Alon.Shalev on 9/8/2024.
 */

public with sharing class UpdateFutureOraOppsBatch implements Database.Batchable<sObject>, Schedulable {
  public void execute(SchedulableContext SC) {
    Database.executeBatch(new UpdateFutureOraOppsBatch(), 1);
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    Set<String> businessTypeSet = new Set<String>{
      'Co-Term Upsell + Renewal',
      'Co-Term Upsell'
    };
    String status = 'Sent To Zuora';
    String query =
      'SELECT Id,zqu__Account__c ' +
      'FROM zqu__Quote__c ' +
      'WHERE Future_CTU_Flag__c = true ' +
      'AND zqu__StartDate__c = TODAY ' +
      'AND zqu_Quote_Status__c = : status ' +
      'AND zqu__QuoteBusinessType__c IN : businessTypeSet';
    return Database.getQueryLocator(query);
  }
  public void execute(Database.BatchableContext BC, List<zqu__Quote__c> scope) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    Set<Id> accountIdSet = new Set<Id>();
    String activeStatus = 'Active';
    List<Opportunity> oppRenewalToUpsertList = new List<Opportunity>();
    for (zqu__Quote__c quote : scope) {
      quote.Future_CTU_Flag__c = false;
      accountIdSet.add(quote.zqu__Account__c);
    }
    Set<String> closedOppStages = new Set<String>{
      'Closed Won',
      'Closed Lost'
    };
    List<Account> accounts = [
      SELECT
        Id,
        OwnerId,
        (
          SELECT
            Id,
            StageName,
            Cycle__c,
            Original_Renewal_Date__c,
            closeDate,
            Type
          FROM Opportunities
          WHERE StageName NOT IN :closedOppStages AND Type = 'Renewal'
          ORDER BY Original_Renewal_Date__c DESC
        ),
        (
          SELECT
            Id,
            Zuora__MRR__c,
            Zuora__NextRenewalDate__c,
            Zuora__CustomerAccount__r.Zuora__Currency__c,
            Zuora__TermStartDate__c
          FROM Zuora__Subscriptions__r
          WHERE
            Zuora__NextRenewalDate__c != NULL
            AND Zuora__Status__c = :activeStatus
          ORDER BY Zuora__NextRenewalDate__c DESC
        )
      FROM Account
      WHERE Id IN :accountIdSet
    ];

    Map<Id, Map<String, Opportunity>> accountIdToOppTypeMap = handler.getAccountIdToOppTypeMap(
      accounts
    );
    handler.handleRenewalAndUpsells(
      accounts,
      accountIdToOppTypeMap,
      closedOppStages,
      oppRenewalToUpsertList
    );

    if (!oppRenewalToUpsertList.isEmpty()) {
      upsert oppRenewalToUpsertList;
    }
    update scope;
  }

  public void finish(Database.BatchableContext BC) {
  }
}

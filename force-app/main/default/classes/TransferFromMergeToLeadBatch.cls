/**
 * Created by Alon.Shalev on 4/10/2023.
 */

public with sharing class TransferFromMergeToLeadBatch implements Database.Batchable<sObject>, Schedulable {
  public void execute(SchedulableContext SC) {
    General_Configuration__mdt mdt = GeneralUtil.getGeneralConfig(
      'TransferFromMergeToLeadBatch'
    );
    Integer BATCH_LIMIT = mdt == null
      ? 20
      : integer.valueOf(mdt.Number_Value__c);
    TransferFromMergeToLeadBatch transferBatch = new TransferFromMergeToLeadBatch();
    Database.executeBatch(transferBatch, BATCH_LIMIT);
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id,Name,Last_Name__c,Company__c FROM Lead_To_Merge_Fields__c';
    return Database.getQueryLocator(query);
  }

  public void execute(
    Database.BatchableContext BC,
    List<Lead_To_Merge_Fields__c> mergeList
  ) {
    List<Lead> leadToUpdateList = new List<Lead>();
    for (Lead_To_Merge_Fields__c mergeItem : mergeList) {
      System.debug('mergeItem.Name--' + mergeItem.Name);
      Lead leadToUpdate = new Lead(Id = mergeItem.Name);
      leadToUpdate.LastName = String.isNotBlank(mergeItem.Last_Name__c)
        ? mergeItem.Last_Name__c
        : leadToUpdate.LastName;
      leadToUpdate.Company = String.isNotBlank(mergeItem.Company__c)
        ? mergeItem.Company__c
        : leadToUpdate.Company;
      leadToUpdateList.add(leadToUpdate);
    }
    if (!leadToUpdateList.isEmpty()) {
      Database.update(leadToUpdateList, false);
    }
    delete mergeList;
  }

  public void finish(Database.BatchableContext BC) {
  }
}

global class BatchBIDataPopulateRelatedRecords implements Database.Batchable<sObject>, Database.Stateful {
  public BatchStats batchChunkStats = new BatchStats();

  private Boolean isRerun;
  private Boolean isDataFix;

  global BatchBIDataPopulateRelatedRecords(Boolean dataFix) {
    isRerun = false;
    isDataFix = dataFix;
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id, Pro_User_Type__c, Base_Product__c, ARR__c, Related_Record_18_ID__c FROM Bi_Data__c';
    if (isDataFix == false) {
      query += ' WHERE LastModifiedDate = LAST_N_DAYS:2 ORDER BY Related_Record_18_ID__c';
    }
    if (Test.isRunningTest()) {
      query += ' LIMIT 3';
    }
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    batchChunkStats = new BatchStats();
    try {
      System.debug('!scope' + scope.size());
      batchChunkStats.NumberOfBiRecordsInBatch = scope.size();
      List<String> relatedBiDataIds = new List<String>();
      Map<String, Bi_Data__c> entityToBiDataMap = new Map<String, Bi_Data__c>();
      for (Bi_Data__c biData : (List<Bi_Data__c>) scope) {
        relatedBiDataIds.add(biData.Id);
        entityToBiDataMap.put(biData.Id, biData);
      }
      List<Lead> leadsList = [
        SELECT Id, Base_Product__c, Pro_User_Type__c, BI_Data__c
        FROM Lead
        WHERE BI_Data__c IN :relatedBiDataIds
      ];
      List<Contact> contactsList = [
        SELECT Id, Base_Product__c, Pro_User_Type__c, BI_Data__c
        FROM Contact
        WHERE BI_Data__c IN :relatedBiDataIds
      ];
      List<Account> accountsList = [
        SELECT Id, ARR__c, Base_Product__c, BI_Data__c
        FROM Account
        WHERE BI_Data__c IN :relatedBiDataIds
      ];

      List<Lead> leadsToUpdate = new List<Lead>();
      if (!leadsList.isEmpty()) {
        for (Lead ld : leadsList) {
          if (
            ld.Pro_User_Type__c !=
            entityToBiDataMap.get(ld.BI_Data__c).Pro_User_Type__c ||
            ld.Base_Product__c !=
            entityToBiDataMap.get(ld.BI_Data__c).Base_Product__c
          ) {
            ld.Base_Product__c = entityToBiDataMap.get(ld.BI_Data__c)
              .Base_Product__c;
            ld.Pro_User_Type__c = entityToBiDataMap.get(ld.BI_Data__c)
              .Pro_User_Type__c;
            leadsToUpdate.add(ld);
          }
        }
        System.debug('!BATCHleadsList' + leadsToUpdate.size());
        batchChunkStats.NumberOfLeadRecordsToUpdate = leadsToUpdate.size();
        if (!leadsToUpdate.isEmpty()) {
          updateEntity(leadsToUpdate, batchChunkStats);
        }
      }
      List<Contact> contactsToUpdate = new List<Contact>();
      if (!contactsList.isEmpty()) {
        for (Contact cnt : contactsList) {
          if (
            cnt.Pro_User_Type__c !=
            entityToBiDataMap.get(cnt.BI_Data__c).Pro_User_Type__c ||
            cnt.Base_Product__c !=
            entityToBiDataMap.get(cnt.BI_Data__c).Base_Product__c
          ) {
            cnt.Base_Product__c = entityToBiDataMap.get(cnt.BI_Data__c)
              .Base_Product__c;
            cnt.Pro_User_Type__c = entityToBiDataMap.get(cnt.BI_Data__c)
              .Pro_User_Type__c;
            contactsToUpdate.add(cnt);
          }
        }
        System.debug('!BATCHcontactsList' + contactsToUpdate.size());
        batchChunkStats.NumberOfContactRecordsToUpdate = contactsToUpdate.size();
        if (!contactsToUpdate.isEmpty()) {
          updateEntity(contactsToUpdate, batchChunkStats);
        }
      }
      List<Account> accountsToUpdate = new List<Account>();
      if (!accountsList.isEmpty()) {
        for (Account acc : accountsList) {
          if (
            acc.ARR__c != entityToBiDataMap.get(acc.BI_Data__c).ARR__c ||
            acc.Base_Product__c !=
            entityToBiDataMap.get(acc.BI_Data__c).Base_Product__c
          ) {
            acc.ARR__c = entityToBiDataMap.get(acc.BI_Data__c).ARR__c;
            acc.Base_Product__c = entityToBiDataMap.get(acc.BI_Data__c)
              .Base_Product__c;
            accountsToUpdate.add(acc);
          }
        }
        System.debug('!BATCHaccountsList' + accountsList.size());
        batchChunkStats.NumberOfAccountRecordsToUpdate = accountsList.size();
        if (!accountsToUpdate.isEmpty()) {
          updateEntity(accountsToUpdate, batchChunkStats);
        }
      }
      if (batchChunkStats.FaiedRecordsList.size() > 0) {
        recordLog(JSON.serializePretty(batchChunkStats));
      }
    } catch (Exception e) {
      recordLog(JSON.serializePretty(batchChunkStats) + '/n' + e.getMessage());
    }
  }

  global void finish(Database.BatchableContext BC) {
  }

  public static void updateEntity(
    List<sObject> updateList,
    BatchStats batchChunkStats
  ) {
    if (!updateList.isEmpty()) {
      List<Database.SaveResult> resultsList = Database.update(
        updateList,
        false
      );
      for (Integer i = 0; i < resultsList.size(); i++) {
        Database.SaveResult result = resultsList[i];
        Object origRecord = updateList[i];
        if (!result.isSuccess()) {
          batchChunkStats.addFailedRecordLog(
            origRecord + ' ' + result.getErrors()
          );
        }
      }
    }
  }

  private static void recordLog(String message) {
    Bi_Batch_Debug_log__c biLog = new Bi_Batch_Debug_log__c();
    biLog.Message__c = message;
    insert biLog;
  }

  private class BatchStats {
    public Integer NumberOfBiRecordsInBatch;
    public Integer NumberOfLeadRecordsToUpdate;
    public Integer NumberOfContactRecordsToUpdate;
    public Integer NumberOfAccountRecordsToUpdate;
    public List<String> FaiedRecordsList;
    public BatchStats() {
      NumberOfBiRecordsInBatch = 0;
      NumberOfLeadRecordsToUpdate = 0;
      NumberOfContactRecordsToUpdate = 0;
      NumberOfAccountRecordsToUpdate = 0;
      FaiedRecordsList = new List<String>();
    }
    public void addFailedRecordLog(String log) {
      FaiedRecordsList.add(log);
    }
  }
}

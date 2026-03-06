/**
 * @author Itzik Winograd
 * @date 17/02/2020
 * @description Pass values from account to the related contacts
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public class DistributeAccountValuesToContact {
  private Integer BATCH_LIMIT = Integer.valueOf(
    GeneralUtil.getGeneralConfig('Account_to_Related_Contacts_Batch_Size')
      .Number_Value__c
  );
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();

  /**
   * @author Itzik Winograd
   * @date 16/02/2021
   * @description: Main method. filter the records, get the field mapping and the list of fields to track changes from custom metadata,
   * and pass it all the the SObjectFieldsToRelatedRecords class
   * @param List<Account> newList - new list of Accounts
   * @param List<Id,Account> oldMap - old map
   * @return none.
   */
  public void handle(List<Account> newList, Map<Id, Account> oldMap) {
    Boolean updatedRecords;
    if (newList != null) {
      List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
        'Account to Related Contacts'
      );
      FieldMappingUtil.FieldMappingData fmd = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(
        fieldsMappingList
      );
      Set<String> accFieldSet = fmd.sourceFieldSet;
      //2022-03-16: make sure there is no other holding processes awaits by quering AsyncApexJob
      if (
        filterAndFlagRecords(newList, oldMap, accFieldSet) &&
        !System.isFuture() &&
        !ExecuteDistibuteAccountValuesToCons.isDistributeJobsExists()
      ) {
        Id batchInstanceId = Database.executeBatch(
          new DistributeAccValuesToConsBatch(),
          BATCH_LIMIT
        );
      }
    } else {
      //it's an after-delete trigger
      checkForMergeOperation(oldMap);
    }
    if (logEvents.size() > 0) {
      EventBus.publish(logEvents);
    }
  }

  /**
   * @author Itzik Winograd
   * @date 16/02/2021
   * @description: Filter the records where changes were made to the custom metadata fields
   * @param List<Account> newList - new list of Accounts
   * @param List<Id,Account> oldMap - old map
   * @param List<String> accFieldSet - fields to track changes in the biData records.
   * @return Boolean updatedRecords - true if records were update, flase otherwise.
   */
  private Boolean filterAndFlagRecords(
    List<Account> newList,
    Map<Id, Account> oldMap,
    Set<String> accFieldSet
  ) {
    Boolean updatedRecords = false;
    for (Account acc : newList) {
      //loop over newList
      for (String accField : accFieldSet) {
        //loop over fields to check if this record has been changed
        if (acc.get(accField) != oldMap.get(acc.Id).get(accField)) {
          acc.put('Pass_Values_to_Related_Records__c', true); //flag this record as true;
          if (updatedRecords == false) {
            updatedRecords = true;
          }
          break; //one match is enough to update the fields
        }
      } //end of customMetadata fields list
    } //end of newList Loop
    System.debug(
      '### DistributeAccountValuesToContact updatedRecords: ' + updatedRecords
    );
    return updatedRecords;
  }

  /**
   * @author Itzik Winograd
   * @date 13/06/2021
   * @description: Look for merged records. on the losing records, the field MasterRecordId will hold the winning Id.
   * @param List<String> accFieldSet - fields to track changes in the biData records.
   * @return Integer updatedRecords - Number of changed records
   */
  private void checkForMergeOperation(Map<Id, Account> oldMap) {
    List<Account> accountsToMark = new List<Account>();
    for (Id accId : oldMap.keySet()) {
      if (oldMap.get(accId).MasterRecordId != null) {
        accountsToMark.add(
          new Account(
            Id = oldMap.get(accId).MasterRecordId,
            Pass_Values_to_Related_Records__c = true
          )
        );
      }
    }
    if (!accountsToMark.isEmpty()) {
      String errorMessage = '';
      System.enqueueJob(
        new QueueableDMLUtils(
          accountsToMark,
          'update',
          false,
          'ExecuteDistibuteAccountValuesToCons'
        )
      );
    }
  }
}

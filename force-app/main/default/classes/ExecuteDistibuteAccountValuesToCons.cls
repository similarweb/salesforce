/**
 * @author Itzik Winograd
 * @date 17/06/2021
 * @description Execute a run of the "DistributeAccValuesToConsBatch"
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public class ExecuteDistibuteAccountValuesToCons implements AdditionalLogicForAfterDML {
  /**
   * @author Itzik Winograd
   * @date 17/06/2021
   * @description Execute DistributeAccValuesToConsBatch
   * @param Set<Id> successIds - set of Ids that went through successful DML operation.
   * @param Set<Id> failIds - set of Ids that went through failed DML operation.
   * @return Void.
   */
  public void handle(Set<Id> successIds, Set<Id> failIds) {
    if (!isDistributeJobsExists()) {
      final String CUSTOM_META_DATA_NAME = 'Account_to_Related_Contacts_Batch_Size';
      Integer BATCH_LIMIT = Integer.valueOf(
        GeneralUtil.getGeneralConfig(CUSTOM_META_DATA_NAME).Number_Value__c
      );
      Id batchInstanceId = Database.executeBatch(
        new DistributeAccValuesToConsBatch(),
        BATCH_LIMIT
      );
    }
  }

  /**
   * @author Itzik Winograd
   * @date 16/03/2022
   * @description: Make sure there is no holding/processing "DistributeAccValuesToConsBatch" jobs
   * @return boolean true if jobs are holding/processing, false if not
   */
  public static Boolean isDistributeJobsExists() {
    List<AsyncApexJob> jobs = [
      SELECT Id, Status
      FROM AsyncApexJob
      WHERE
        ApexClass.Name = 'DistributeAccValuesToConsBatch'
        AND Status IN ('Holding', 'Queued', 'Processing')
    ];
    return !jobs.isEmpty();
  }
}

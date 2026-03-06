/**
 * @author Itzik Winograd
 * @date 29/12/2022
 * @description MIS-3176: Schedulable class to delete et4ae5__IndividualEmailResult__c. Use current DeleteRecordsBatch.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
global class DeleteIndividualEmailScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    Database.executeBatch(
      new DeleteRecordsBatch('et4ae5__IndividualEmailResult__c'),
      200
    );
  }
}

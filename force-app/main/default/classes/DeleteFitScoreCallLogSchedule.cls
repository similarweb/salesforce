/**
 * Created by alonshalev on 24/01/2023.
 */
/**
 * @author Alon Shalev
 * @date 24/01/2023
 * @description MIS-3484: Schedulable class to delete Fit_Score_Call_Log. Use current DeleteRecordsBatch.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
global with sharing class DeleteFitScoreCallLogSchedule implements Schedulable {
  global void execute(SchedulableContext sc) {
    Database.executeBatch(new DeleteRecordsBatch('Fit_Score_Call_Log__c'), 200);
  }
}

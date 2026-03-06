/**
 * Created by Alon.Shalev on 5/1/2023.
 */

global class DeleteApexEventLogScheduler implements Schedulable {
  global void execute(SchedulableContext sc) {
    Database.executeBatch(new DeleteRecordsBatch('Apex_Event_Log__c'), 200);
  }
}

public with sharing class DeactivateUsersSchedulable implements Schedulable {
  public void execute(SchedulableContext context) {
    List<Manage_Users_Log__c> logs = [
      SELECT Id, User__c
      FROM Manage_Users_Log__c
      WHERE
        Today_is_Action_Date__c = TRUE
        AND Action__c = 'Deactivate'
        AND Status__c = 'Open'
        AND User__c != NULL
    ];
    if (logs.size() > 0) {
      DeactivateUsersQueueable queueable = new DeactivateUsersQueueable(
        logs,
        0,
        false
      );
      System.enqueueJob(queueable);
    }
  }
}

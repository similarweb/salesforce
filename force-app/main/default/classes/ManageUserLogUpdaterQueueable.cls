/**
 * Created by alon.shalev on 2/12/2023.
 */

public with sharing class ManageUserLogUpdaterQueueable implements Queueable {
  private List<Manage_Users_Log__c> manageUserLogs;

  public ManageUserLogUpdaterQueueable(
    List<Manage_Users_Log__c> manageUserLogs
  ) {
    this.manageUserLogs = manageUserLogs;
  }

  public void execute(QueueableContext param1) {
    update this.manageUserLogs;
  }
}

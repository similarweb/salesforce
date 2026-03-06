/**
 * Created by alon.shalev on 2/12/2023.
 */

public with sharing class ManageUserLogUpdater {
  @InvocableMethod(
    label='Update Manage User Log'
    description='Updates a Manage User Log record'
  )
  public static void updateManageUserLog(
    List<ManageUserLogInput> manageUserLogInputs
  ) {
    List<Manage_Users_Log__c> manageUserLogs = new List<Manage_Users_Log__c>();
    for (ManageUserLogInput manageUserLogInput : manageUserLogInputs) {
      Manage_Users_Log__c manageUserLog = new Manage_Users_Log__c();
      manageUserLog.Id = manageUserLogInput.Manage_User_Log_ID;
      manageUserLog.User__c = manageUserLogInput.User;
      manageUserLog.Status__c = manageUserLogInput.Status;
      manageUserLog.Date_For_Action__c = manageUserLogInput.Date_For_Action;
      manageUserLog.Employee_Hire_Date__c = manageUserLogInput.Employee_Hire_Date;
      manageUserLog.Business_Applications_Assignments__c = manageUserLogInput.Business_Applications_Assignments;
      manageUserLog.Permission_Set_Assignments__c = manageUserLogInput.Permission_Set_Assignments;
      manageUserLog.Public_Group_Assignments__c = manageUserLogInput.Public_Group_Assignments;
      manageUserLog.Approved_By__c = manageUserLogInput.Approved_By;
      manageUserLogs.add(manageUserLog);
    }
    system.enqueueJob(new ManageUserLogUpdaterQueueable(manageUserLogs));
  }

  public class ManageUserLogInput {
    @InvocableVariable(required=true)
    public Id Manage_User_Log_ID;
    @InvocableVariable
    public String User;
    @InvocableVariable
    public String Status;
    @InvocableVariable
    public Date Date_For_Action;
    @InvocableVariable
    public Date Employee_Hire_Date;
    @InvocableVariable
    public String Business_Applications_Assignments;
    @InvocableVariable
    public String Permission_Set_Assignments;
    @InvocableVariable
    public String Public_Group_Assignments;
    @InvocableVariable
    public String Approved_By;
  }
}

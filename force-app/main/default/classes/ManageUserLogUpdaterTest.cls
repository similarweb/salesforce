/**
 * Created by alon.shalev on 2/12/2023.
 */

@IsTest
public class ManageUserLogUpdaterTest {
  @isTest
  static void testUpdateManageUserLog() {
    Manage_Users_Log__c manageUserLog = new Manage_Users_Log__c(
      User__c = UserInfo.getUserId(),
      Status__c = 'Completed',
      Date_For_Action__c = Date.today(),
      Employee_Hire_Date__c = Date.today(),
      Business_Applications_Assignments__c = 'Assigned',
      Permission_Set_Assignments__c = 'Assigned',
      Public_Group_Assignments__c = 'Assigned'
    );
    insert manageUserLog;
    Test.startTest();

    List<ManageUserLogUpdater.ManageUserLogInput> manageUserLogInputs = new List<ManageUserLogUpdater.ManageUserLogInput>();
    ManageUserLogUpdater.ManageUserLogInput manageUserLogInput = new ManageUserLogUpdater.ManageUserLogInput();
    manageUserLogInput.Manage_User_Log_ID = manageUserLog.Id;
    manageUserLogInput.User = UserInfo.getUserId();
    manageUserLogInput.Status = 'Completed';
    manageUserLogInput.Date_For_Action = Date.today().addDays(1);
    manageUserLogInput.Employee_Hire_Date = Date.today().addDays(1);
    manageUserLogInput.Business_Applications_Assignments = 'Not Assigned';
    manageUserLogInput.Permission_Set_Assignments = 'Not Assigned';
    manageUserLogInput.Public_Group_Assignments = 'Not Assigned';
    manageUserLogInputs.add(manageUserLogInput);
    ManageUserLogUpdater.updateManageUserLog(manageUserLogInputs);
    Test.stopTest();

    manageUserLog = [
      SELECT
        Id,
        Status__c,
        Date_For_Action__c,
        Employee_Hire_Date__c,
        Business_Applications_Assignments__c,
        Permission_Set_Assignments__c,
        Public_Group_Assignments__c
      FROM Manage_Users_Log__c
      WHERE Id = :manageUserLog.Id
    ];

    System.assertEquals('Completed', manageUserLog.Status__c);
    System.assertEquals(
      Date.today().addDays(1),
      manageUserLog.Date_For_Action__c
    );
    System.assertEquals(
      Date.today().addDays(1),
      manageUserLog.Employee_Hire_Date__c
    );
    System.assertEquals(
      'Not Assigned',
      manageUserLog.Business_Applications_Assignments__c
    );
    System.assertEquals(
      'Not Assigned',
      manageUserLog.Permission_Set_Assignments__c
    );
    System.assertEquals(
      'Not Assigned',
      manageUserLog.Public_Group_Assignments__c
    );
  }
}

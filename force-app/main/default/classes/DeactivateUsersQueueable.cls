public with sharing class DeactivateUsersQueueable implements System.Queueable {
    
    List<Manage_Users_Log__c> logs;
    Integer i;
    Boolean shouldStop, isSetupDml;

    public DeactivateUsersQueueable(List<Manage_Users_Log__c> logs, Integer i, Boolean isSetupDml) {
        this.isSetupDml = isSetupDml;
        this.shouldStop = false;
        this.logs = logs;
        this.i = i;
        if (this.i == this.logs.size()) {
            this.shouldStop = true;
        }
    }

    public void execute(System.QueueableContext context) {
        if (shouldStop) {
            update logs;
        }
        else {
            try {
                if (isSetupDml) {
                    List<UserPackageLicense> userPackageLicenses = [SELECT Id, UserId FROM UserPackageLicense WHERE UserId =: logs[i].User__c];
                    delete userPackageLicenses;
                    User userToDeactivate = new User(Id = logs[i].User__c, IsActive = false, Level_11__c = false);
                    update userToDeactivate;
                    logs[i].Status__c = 'Completed';
                }
                else {
                    List<AccountTeamMember> accTeamMembers = [SELECT Id, UserId FROM AccountTeamMember WHERE UserId =: logs[i].User__c];
                    List<Territory_Member__c> terrMembers = [SELECT Id, Name__c FROM Territory_Member__c WHERE Name__c =: logs[i].User__c];
                    delete accTeamMembers;
                    delete terrMembers;
                }
            }
            catch (Exception e) {
                logs[i].Status__c = 'Failed';
                logs[i].Fault_Massage__c = e.getMessage();
            }
            if (!Test.isRunningTest()) {
                System.enqueueJob(new DeactivateUsersQueueable(logs, isSetupDml ? i + 1 : i, !isSetupDml));
            }
        }
    }
}
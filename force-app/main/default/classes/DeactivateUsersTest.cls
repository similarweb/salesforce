@IsTest
public with sharing class DeactivateUsersTest {

    @TestSetup
    static void setup() {
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Deactivate',
            Email = 'testdeactivate@example.com',
            Username = 'testdeactivate' + DateTime.now().getTime() + '@example.com',
            Alias = 'tdeact',
            ProfileId = stdProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            IsActive = true
        );
        insert testUser;

        Manage_Users_Log__c log = new Manage_Users_Log__c(
            User__c = testUser.Id,
            Action__c = 'Deactivate',
            Status__c = 'Open',
            Date_For_Action__c = Date.today()
        );
        insert log;
    }

    @IsTest
    static void coverNonSetupDmlPart() {
        
        Test.startTest();
        DeactivateUsersSchedulable sb = new DeactivateUsersSchedulable();
        sb.execute(null);
        Test.stopTest();
    }

    @IsTest
    static void coverSetupDmlPart() {
        
        Test.startTest();
        System.enqueueJob(new DeactivateUsersQueueable([SELECT Id, User__c FROM Manage_Users_Log__c WHERE Today_is_Action_Date__c = true AND Action__c = 'Deactivate' AND Status__c = 'Open' AND User__c != NULL], 0, true));
        Test.stopTest();

        User deactivated = [SELECT IsActive FROM User WHERE LastName = 'Deactivate' LIMIT 1];
        System.assertEquals(false, deactivated.IsActive);
    }

    @IsTest
    static void coverStopPart() {

        Test.startTest();
        System.enqueueJob(new DeactivateUsersQueueable([SELECT Id, User__c FROM Manage_Users_Log__c WHERE Today_is_Action_Date__c = true AND Action__c = 'Deactivate' AND Status__c = 'Open' AND User__c != NULL], 1, false));
        Test.stopTest();
    }
    
}
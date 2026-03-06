@isTest
public class UpdateMeetingOwnerBatchTest {
  static User managerUser;
  static User ownerUser;

  @testSetup
  static void setup() {
    System.debug('started');
    // Create Users and Groups
    Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
    System.runAs(new User(Id = UserInfo.getUserId())) {
      managerUser = createUser('Manager', p, null);
      insert managerUser;
      ownerUser = createUser('Owner', p, managerUser.Id);
      insert ownerUser;
    }

    // Create Meetings
    Meeting__c meeting1 = new Meeting__c(OwnerId = ownerUser.Id);
    insert meeting1;
  }

  static User createUser(String userType, Profile p, Id managerId) {
    // Implement user creation logic here
    // Return a new User instance based on userType
    User newUser = new User /* User fields here */();
    newUser.Username = 'Test' + userType + '@gmail.commmmmmm';
    newUser.LastName = userType;
    newUser.Email = userType + '@gmail.com';
    System.debug(newUser.Email);
    newUser.Alias = 'test';
    newUser.LocaleSidKey = 'en_US';
    newUser.ProfileId = p.Id;
    newUser.LanguageLocaleKey = 'en_US';
    newUser.TimeZoneSidKey = 'America/Los_Angeles';
    newUser.EmailEncodingKey = 'UTF-8';
    newUser.ManagerId = managerId != null ? managerId : null;
    System.debug('newUser.ManagerId--- ' + newUser.ManagerId);
    return newUser;
  }

  @isTest
  static void testUpdateMeetingOwnerBatch() {
    // Fetch meeting Ids
    Set<Id> meetingIdSet = new Set<Id>();
    for (Meeting__c meeting : [SELECT Id FROM Meeting__c]) {
      meetingIdSet.add(meeting.Id);
    }

    // Start the batch job
    Test.startTest();
    UpdateMeetingOwnerBatch batch = new UpdateMeetingOwnerBatch(meetingIdSet);
    Database.executeBatch(batch);
    Test.stopTest();

    // Verify the results
    Meeting__c meeting1 = [SELECT OwnerId FROM Meeting__c LIMIT 1];
    User manager = [
      SELECT Id
      FROM User
      WHERE Username = 'TestManager@gmail.commmmmmm'
      LIMIT 1
    ];
    System.debug('manager.Id--' + manager.Id);
    System.debug('mmeeting1.OwnerId-' + meeting1.OwnerId);
    System.assertEquals(
      manager.Id,
      meeting1.OwnerId,
      'Meeting 1 owner should be updated to the manager'
    );
  }
}

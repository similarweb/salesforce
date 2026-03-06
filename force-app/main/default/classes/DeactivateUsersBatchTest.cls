@IsTest
private class DeactivateUsersBatchTest {
  @TestSetup
  static void setup() {
    Profile stdProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Standard User'
      LIMIT 1
    ];

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
  static void testBasicDeactivation() {
    Test.startTest();
    DeactivateUsersBatch sb = new DeactivateUsersBatch();
    sb.execute(null);
    Test.stopTest();

    User deactivated = [
      SELECT IsActive
      FROM User
      WHERE LastName = 'Deactivate'
      LIMIT 1
    ];
    Manage_Users_Log__c log = [
      SELECT Status__c, Fault_Massage__c
      FROM Manage_Users_Log__c
      WHERE User__c = :deactivated.Id
      LIMIT 1
    ];
    System.debug('log: ' + log);
    System.assertEquals('Completed', log.Status__c);
    System.assertEquals(false, deactivated.IsActive);
  }
}

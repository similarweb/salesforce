@isTest
private class AccountOwnerFromInactiveUsersBatchTest {
  @TestSetup
  static void setup() {
    // Create test users
    User activeUser = createUser('Active UserSimilarWeb', true); // Assuming second parameter is isActive
    User inactiveUser = createUser('Inactive UserSimilarWeb', false);
    insert new List<User>{ activeUser, inactiveUser };

    // Create test accounts owned by the inactive user
    Account testAccountForInactiveUser = new Account(
      Name = 'Test Account for Inactive User',
      OwnerId = inactiveUser.Id
    );
    insert testAccountForInactiveUser;

    // Create Manage_Users_Log__c record for the inactive user
    Manage_Users_Log__c logRecord = new Manage_Users_Log__c(
      User__c = inactiveUser.Id,
      Status__c = 'Completed',
      Action__c = 'Deactivate',
      Date_For_Action__c = Date.today().addDays(-1) // Setting to YESTERDAY
    );
    insert logRecord;
  }

  static User createUser(String name, Boolean isActive) {
    // Setup method to create a user
    User newUser = new User(
      Username = name.toLowerCase().replace(' ', '.') + '@testorg.com',
      LastName = name,
      Email = name.toLowerCase().replace(' ', '.') + '@testorg.com',
      Alias = name.substring(0, 5),
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1]
      .Id,
      TimeZoneSidKey = 'America/New_York',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      IsActive = isActive
    );
    return newUser;
  }

  @isTest
  static void testBatchExecution() {
    Test.startTest();
    // Execute the scheduled job
    AccountOwnerFromInactiveUsersBatch schedulableBatch = new AccountOwnerFromInactiveUsersBatch();
    String cronExp = '0 0 * * * ?';
    System.schedule(
      'Test Schedule AccountOwnerFromInactiveUsersBatch',
      cronExp,
      schedulableBatch
    );
    Test.stopTest();

    // Add assertions here to validate expected outcomes, such as the Manage_Users_Log__c records being processed,
    // and accounts being identified for owner update. Since actual owner update logic might be in UpdateAccountOwnerBatch,
    // you might need to assert that accountIdSet in AccountOwnerFromInactiveUsersBatch has the expected IDs.
    // Direct assertions on the change in Account owner would require querying or mocking UpdateAccountOwnerBatch execution.
  }
}

@isTest
public class UpdateAccountOwnerBatchTest {

    static User managerUser;
    static User ownerUser;

    @TestSetup
    static void setup() {
        // Create and insert User records in their own transaction context
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            managerUser = createUser('Manager',p,null);
            insert managerUser;
            ownerUser = createUser('Owner',p,managerUser.Id);
            insert ownerUser;
        }

        // Now that Users are inserted, Accounts can be created and associated with those Users
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account a = new Account(Name='Test Account ' + i, OwnerId=ownerUser.Id);
            testAccounts.add(a);
        }
        insert testAccounts;

        // Optionally, associate the Accounts with the managerUser in a separate transaction if necessary
        // This might require a separate approach or manual update post-creation
    }

    static User createUser(String userType,Profile p,Id managerId) {
        // Implement user creation logic here
        // Return a new User instance based on userType
        User newUser = new User(/* User fields here */);
        newUser.Username = 'Test'+userType+'@gmail.commmm';
        newUser.LastName = userType;
        newUser.Email = userType+'@gmail.com';
        System.debug(newUser.Email);
        newUser.Alias = 'test';
        newUser.LocaleSidKey='en_US';
        newUser.ProfileId = p.Id;
        newUser.LanguageLocaleKey='en_US';
        newUser.TimeZoneSidKey='America/Los_Angeles';
        newUser.EmailEncodingKey='UTF-8';
        newUser.ManagerId = managerId != null ? managerId : null;
        return newUser;
    }

    @isTest
    static void testExecute() {
        Test.startTest();
        Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account]).keySet();
        UpdateAccountOwnerBatch batch = new UpdateAccountOwnerBatch(accountIds);
        Database.executeBatch(batch);
        Test.stopTest();

        // Perform assertions here
    }
}
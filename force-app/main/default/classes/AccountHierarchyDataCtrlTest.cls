@isTest
public class AccountHierarchyDataCtrlTest {
    @testSetup
    static void setupTestData() {
        TestDataFactory.createInferredSolutionSettings_CS();
        // Create parent accounts
        Account parentAccount = new Account(
                Name = 'Parent Account',
                Parent_Company_Domain__c = 'example.com'
        );
        insert parentAccount;

        // Create child accounts with different attributes
        Account payingAccount = new Account(
                Name = 'Paying Account',
                Parent_Company_Domain__c = 'example.com',
                Stage__c = 'Paying Account'
        );

        Account noTouchAccount = new Account(
                Name = 'No Touch Account',
                Parent_Company_Domain__c = 'example.com',
                No_Touch_Account__c = true
        );

        Account normalAccount = new Account(
                Name = 'Normal Account',
                Parent_Company_Domain__c = 'example.com'
        );
        Account childAccount = new Account(
                Name = 'Normal Account',
                Parent_Company_Domain__c = 'example.com',ParentId = parentAccount.id
                );


        insert new List<Account> { payingAccount, noTouchAccount, normalAccount,childAccount };


        // Create opportunities related to the accounts
        Opportunity opp1 = new Opportunity(
                Name = 'Opportunity 1',
                AccountId = payingAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(1)
        );

        Opportunity opp2 = new Opportunity(
                Name = 'Opportunity 2',
                AccountId = noTouchAccount.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(1)
        );

        insert new List<Opportunity> { opp1, opp2 };

        // Create meetings related to the accounts
        Meeting__c meeting1 = new Meeting__c(Account__c = payingAccount.Id);


        Meeting__c meeting2 = new Meeting__c(
                Account__c = payingAccount.Id
        );

        insert new List<Meeting__c> { meeting1, meeting2 };

        // Create subscriptions related to the accounts
        Zuora__Subscription__c subscription1 = new Zuora__Subscription__c(
                Name = 'Subscription 1',
                Zuora__Account__c = payingAccount.Id
        );

        Zuora__Subscription__c subscription2 = new Zuora__Subscription__c(
                Name = 'Subscription 2',
                Zuora__Account__c = noTouchAccount.id
        );

        insert new List<Zuora__Subscription__c> { subscription1, subscription2 };

        // Create contacts related to the accounts
        Contact contact1 = new Contact(
                LastName = 'Champion Contact',
                AccountId = payingAccount.Id,
                Champion__c = true,
                Pro_User_Type__c = 'Admin',
                Email = 'asdasd@asdasd.com'
        );

        Contact contact2 = new Contact(
                LastName = 'Regular Contact',
                AccountId = noTouchAccount.Id,
                Pro_User_Type__c = 'User',
                Email = 'asdasd@asdasd.coom'
        );

        Contact contact3 = new Contact(
                LastName = 'Normal Contact',
                AccountId = normalAccount.Id,
                Email = 'asdasd@asdasd.cooom'
        );

        insert new List<Contact> { contact1, contact2, contact3 };
    }

    @isTest
    static void testGetHierarchyData() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name = 'Parent Account'];

        // Test method for getHierarchyData
        Test.startTest();
        Map<String, Object> result = AccountHierarchyDataCtrl.getHierarchyData('example.com','exemple.example.com',parentAccount.Id);
        Test.stopTest();

        // Assertions to verify the result
        System.assertEquals(5, result.get('totalAccounts'), 'Total accounts should be 4');
        System.assertEquals(2, result.get('totalOpportunities'), 'Total opportunities should be 2');
        System.assertEquals(2, result.get('totalSubscriptions'), 'Total subscriptions should be 2');
        System.assertEquals(2, result.get('totalMeetings'), 'Total meetings should be 2');
        System.assertEquals(3, result.get('totalContacts'), 'Total contacts should be 3');
        System.assertEquals(1, result.get('totalChampions'), 'Total champions should be 1');
        System.assertEquals(2, result.get('totalAdmins'), 'Total admins/users should be 2');
    }

    @isTest
    static void testQueryMainAccount() {
        // Setup data
        Account parentAccount = [SELECT Id FROM Account WHERE Name = 'Parent Account'];
        Map<Id, AccountHierarchyDataCtrl.AccountMapObj> accountIdToRelationMap = new Map<Id, AccountHierarchyDataCtrl.AccountMapObj>();

        // Test queryMainAccount
        Test.startTest();
        AccountHierarchyDataCtrl.queryMainAccount(parentAccount.Id, accountIdToRelationMap);
        Test.stopTest();

    }


}
@isTest
public class UserHistoryServiceTest {

	@TestSetup
	static void makeData() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		User testUser = new User(
				Username = 'testuser1231VeryUnique@example.com',
				Email = 'testuser@example.com',
				LastName = 'TestUser',
				Alias = 'tuser',
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				ProfileId = p.Id,
				LanguageLocaleKey = 'en_US'
		);
		insert testUser;
	}

	@isTest
	static void testHandleAfterInsert() {
		User testUser = [SELECT Id, Name, Email, Username FROM User WHERE Username = 'testuser1231VeryUnique@example.com' LIMIT 1];
		List<User> newUsers = new List<User>{testUser};

		Test.startTest();
		UserHistoryService.handleAfterInsert(newUsers);
		Test.stopTest();

		List<User_History__c> histories = [SELECT Id, Field__c, Old_Value__c, New_Value__c, User__c FROM User_History__c WHERE User__c = :testUser.Id];
		System.assert(histories.size() > 0, 'Histories should be created for insert');
	}

	@isTest
	static void testHandleAfterUpdateNonReferenceField() {
		User testUser = [SELECT Id, Name, Email, Username FROM User WHERE Username = 'testuser1231VeryUnique@example.com' LIMIT 1];
		User oldUser = testUser.clone();
		testUser.Email = 'updated@example.com';

		Map<Id, User> oldMap = new Map<Id, User>{testUser.Id => oldUser};
		List<User> newList = new List<User>{testUser};

		Test.startTest();
		UserHistoryService.handleAfterUpdate(newList, oldMap);
		Test.stopTest();

		List<User_History__c> histories = [SELECT Id, Field__c, Old_Value__c, New_Value__c, User__c FROM User_History__c WHERE User__c = :testUser.Id AND Field__c = 'Email' AND Old_Value__c != null];
		System.assertEquals(1, histories.size(), 'Should have one history for Email change');
		System.assertEquals('testuser@example.com', histories[0].Old_Value__c);
		System.assertEquals('updated@example.com', histories[0].New_Value__c);
	}

	@isTest
	static void testHandleAfterUpdateReferenceField() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
		User manager = new User(
				Username = 'managerTest1231@example.com',
				Email = 'manager@example.com',
				LastName = 'Manager',
				Alias = 'mgr',
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'UTF-8',
				ProfileId = p.Id,
				LanguageLocaleKey = 'en_US'
		);
		insert manager;

		User testUser = [SELECT Id, Name, Email, Username, ManagerId FROM User WHERE Username = 'testuser1231VeryUnique@example.com' LIMIT 1];
//		User oldUser = testUser.clone();
		testUser.ManagerId = manager.Id;

//		Map<Id, User> oldMap = new Map<Id, User>{testUser.Id => oldUser};
//		List<User> newList = new List<User>{testUser};

		Test.startTest();
		update testUser;
		Test.stopTest();

		List<User_History__c> idHistories = [SELECT Id, Field__c, Old_Value__c, New_Value__c, User__c FROM User_History__c WHERE User__c = :testUser.Id AND Field__c = 'ManagerId (Id)'];
		List<User_History__c> nameHistories = [SELECT Id, Field__c, Old_Value__c, New_Value__c, User__c FROM User_History__c WHERE User__c = :testUser.Id AND Field__c = 'ManagerId'];

		System.assertEquals(1, idHistories.size(), 'Should have one history for ManagerId (Id)');
		System.assertEquals(1, nameHistories.size(), 'Should have one history for ManagerId name');
		System.assertEquals(null, idHistories[0].Old_Value__c);
		System.assertEquals(manager.Id, idHistories[0].New_Value__c);
		System.assertEquals(null, nameHistories[0].Old_Value__c);
		System.assertEquals('Manager', nameHistories[0].New_Value__c);
	}

	@isTest
	static void testHandleAfterUpdateNoChanges() {
		User testUser = [SELECT Id, Name, Email, Username FROM User WHERE Username = 'testuser1231VeryUnique@example.com' LIMIT 1];
		User oldUser = testUser.clone();

		Map<Id, User> oldMap = new Map<Id, User>{testUser.Id => oldUser};
		List<User> newList = new List<User>{testUser};

		Test.startTest();
		UserHistoryService.handleAfterUpdate(newList, oldMap);
		Test.stopTest();

		List<User_History__c> histories = [SELECT Id FROM User_History__c WHERE User__c = :testUser.Id AND Old_Value__c != null];
		System.assertEquals(0, histories.size(), 'No histories should be created when no changes');
	}
}
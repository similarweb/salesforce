@isTest
private class TerritoryMemberHandlerTest {

    @testSetup
    static void setupData() {
        // Create test Users
        User u1 = new User(
                Alias = 'user1', Email='user1@test.com', EmailEncodingKey='UTF-8',
                LanguageLocaleKey='en_US', LocaleSidKey='en_US',
                ProfileId = UserInfo.getProfileId(),
                TimeZoneSidKey='America/Los_Angeles', UserName='user12341@test.com',LastName = 'test'
        );
        insert u1;

        User u2 = new User(
                Alias = 'user2', Email='user2@test.com', EmailEncodingKey='UTF-8',
                LanguageLocaleKey='en_US', LocaleSidKey='en_US',
                ProfileId = UserInfo.getProfileId(),
                TimeZoneSidKey='America/Los_Angeles', UserName='user23451@test.com',LastName = 'test'
        );
        insert u2;

        // Create Territory and assign u1 as owner
        Territory__c t1 = new Territory__c(Name = 'Test Territory', OwnerId = u1.Id);
        insert t1;

        // Existing member - should cause duplication error if inserted again
        Territory_Member__c existingMember = new Territory_Member__c(
                Territory__c = t1.Id,
                Name__c = u2.Id,
				Territory_Member_Role__c = 'Sales Manager'
		);
        insert existingMember;

//		Territory_Member__c testMember = new Territory_Member__c(
//				Territory__c = t1.Id,
//				Name__c = u2.Id,
//				Territory_Member_Role__c = 'Sales Manager'
//		);
//		insert testMember;
    }

    @isTest
    static void testDuplicationValidation_insert() {
        // Get test records
        Territory__c t1 = [SELECT Id FROM Territory__c LIMIT 1];
        User u1 = [SELECT Id FROM User WHERE Alias = 'user1' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE Alias = 'user2' LIMIT 1];

        // Attempt to add a duplicate member
        Territory_Member__c duplicateMember = new Territory_Member__c(
                Territory__c = t1.Id,
                Name__c = u2.Id
        );

        Test.startTest();
        try{
            insert duplicateMember;
        }catch (Exception ex){
            System.assertEquals(true,ex.getMessage().contains('The user is already assigned to this territory'));
        }

    }

	@isTest
	static void testBeforeDelete() {
		User u = [SELECT Id FROM User WHERE Alias = 'user1'];
		Territory__c t1 = [SELECT Id FROM Territory__c LIMIT 1];

		Account acc = new Account(Name = 'Test Account', Territory__c = t1.Id, Exclude_From_Territory_Owner_Change__c = true, OwnerId = u.Id);
		insert acc;

		Territory_Member__c tm = [SELECT Id FROM Territory_Member__c WHERE Territory_Member_Role__c = 'Sales Manager' LIMIT 1];

		Test.startTest();
		delete tm;
		Test.stopTest();

		Account accAfter = [SELECT Exclude_From_Territory_Owner_Change__c FROM Account WHERE Id = :acc.Id];
		System.assertEquals(false, accAfter.Exclude_From_Territory_Owner_Change__c,
				'Account Exclude_From_Territory_Owner_Change__c should be set to false after Territory Member delete');
	}
}
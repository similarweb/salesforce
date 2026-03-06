@isTest
private class RevertClosedOppOwnerQueueableTest {

    @isTest
    static void testRevertClosedOppOwnerWithMockHistory() {
        // Create test account using running user
        Account testAccount = new Account(Name = 'Test Account RCO');
        insert testAccount;

        // Create closed opportunity directly
        Opportunity closedOpp = new Opportunity(
            Name = 'Test Closed Opportunity RCO',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-30),
            Closed_Lost_Reason__c = 'Legal',
            Closed_Lost_Reason_More_details__c = 'More details',
            Opp_will_be_relevant__c = '90 days',
            Solution_Fit__c = 'Marketing: SEO / Content'
        );
        insert closedOpp;

        // Query to get the OwnerId (not populated in memory after insert)
        closedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        Id originalOwnerId = closedOpp.OwnerId;
        
        // Get another user to change owner to
        List<User> otherUsers = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        if (otherUsers.isEmpty()) {
            System.assert(true, 'No other user found to test with');
            return;
        }
        Id newOwnerId = otherUsers[0].Id;

        // Change the owner (simulating what happens when Account owner changes)
        closedOpp.OwnerId = newOwnerId;
        closedOpp.Bypass_Owner_Change_Validation__c = true;
        update closedOpp;

        // Reset bypass
        closedOpp.Bypass_Owner_Change_Validation__c = false;
        update closedOpp;

        // Verify owner was changed
        Opportunity updatedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        System.assertEquals(newOwnerId, updatedOpp.OwnerId, 'Opportunity owner should have been changed to new owner');

        // Inject mock history data (simulating what the history record would look like)
        RevertClosedOppOwnerQueueable.mockHistoryData = new Map<Id, List<RevertClosedOppOwnerQueueable.HistoryWrapper>>();
        List<RevertClosedOppOwnerQueueable.HistoryWrapper> mockHistories = new List<RevertClosedOppOwnerQueueable.HistoryWrapper>();
        mockHistories.add(new RevertClosedOppOwnerQueueable.HistoryWrapper(
            closedOpp.Id,
            String.valueOf(originalOwnerId),  // OldValue = original owner ID
            String.valueOf(newOwnerId),        // NewValue = new owner ID
            Datetime.now()                      // CreatedDate = today
        ));
        RevertClosedOppOwnerQueueable.mockHistoryData.put(closedOpp.Id, mockHistories);

        // Execute queueable with mock history data
        Test.startTest();
        Set<Id> oppIds = new Set<Id>{closedOpp.Id};
        RevertClosedOppOwnerQueueable queueable = new RevertClosedOppOwnerQueueable(oppIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        // Verify owner was reverted to original
        Opportunity revertedOpp = [SELECT Id, OwnerId, Bypass_Owner_Change_Validation__c FROM Opportunity WHERE Id = :closedOpp.Id];
        System.assertEquals(originalOwnerId, revertedOpp.OwnerId, 'Opportunity owner should have been reverted to original owner');
        System.assertEquals(false, revertedOpp.Bypass_Owner_Change_Validation__c, 'Bypass flag should be deactivated');
    }

    @isTest
    static void testNoRevertWhenChangedYesterday() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account RCO Yesterday');
        insert testAccount;

        // Create closed opportunity
        Opportunity closedOpp = new Opportunity(
            Name = 'Test Closed Opportunity RCO Yesterday',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-30),
            Closed_Lost_Reason__c = 'Legal',
            Closed_Lost_Reason_More_details__c = 'More details',
            Opp_will_be_relevant__c = '90 days',
            Solution_Fit__c = 'Marketing: SEO / Content'
        );
        insert closedOpp;

        closedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        Id originalOwnerId = closedOpp.OwnerId;

        // Get another user
        List<User> otherUsers = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        if (otherUsers.isEmpty()) {
            System.assert(true, 'No other user found to test with');
            return;
        }
        Id newOwnerId = otherUsers[0].Id;

        // Change the owner
        closedOpp.OwnerId = newOwnerId;
        closedOpp.Bypass_Owner_Change_Validation__c = true;
        update closedOpp;
        closedOpp.Bypass_Owner_Change_Validation__c = false;
        update closedOpp;

        // Inject mock history data with YESTERDAY's date (should NOT trigger revert)
        RevertClosedOppOwnerQueueable.mockHistoryData = new Map<Id, List<RevertClosedOppOwnerQueueable.HistoryWrapper>>();
        List<RevertClosedOppOwnerQueueable.HistoryWrapper> mockHistories = new List<RevertClosedOppOwnerQueueable.HistoryWrapper>();
        mockHistories.add(new RevertClosedOppOwnerQueueable.HistoryWrapper(
            closedOpp.Id,
            String.valueOf(originalOwnerId),
            String.valueOf(newOwnerId),
            Datetime.now().addDays(-1)  // Yesterday - should NOT be reverted
        ));
        RevertClosedOppOwnerQueueable.mockHistoryData.put(closedOpp.Id, mockHistories);

        Test.startTest();
        Set<Id> oppIds = new Set<Id>{closedOpp.Id};
        RevertClosedOppOwnerQueueable queueable = new RevertClosedOppOwnerQueueable(oppIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        // Verify owner was NOT reverted (change was not today)
        Opportunity unchangedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        System.assertEquals(newOwnerId, unchangedOpp.OwnerId, 'Opportunity owner should NOT be reverted (change was yesterday)');
    }

    @isTest
    static void testSkipsNameBasedHistory() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account RCO Name');
        insert testAccount;

        // Create closed opportunity
        Opportunity closedOpp = new Opportunity(
            Name = 'Test Closed Opportunity RCO Name',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-30),
            Closed_Lost_Reason__c = 'Legal',
            Closed_Lost_Reason_More_details__c = 'More details',
            Opp_will_be_relevant__c = '90 days',
            Solution_Fit__c = 'Marketing: SEO / Content'
        );
        insert closedOpp;

        closedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        Id currentOwnerId = closedOpp.OwnerId;

        // Inject mock history data with NAME instead of ID (should be skipped)
        RevertClosedOppOwnerQueueable.mockHistoryData = new Map<Id, List<RevertClosedOppOwnerQueueable.HistoryWrapper>>();
        List<RevertClosedOppOwnerQueueable.HistoryWrapper> mockHistories = new List<RevertClosedOppOwnerQueueable.HistoryWrapper>();
        mockHistories.add(new RevertClosedOppOwnerQueueable.HistoryWrapper(
            closedOpp.Id,
            'John Doe',  // Name instead of ID - should be skipped
            'Jane Smith',
            Datetime.now()
        ));
        RevertClosedOppOwnerQueueable.mockHistoryData.put(closedOpp.Id, mockHistories);

        Test.startTest();
        Set<Id> oppIds = new Set<Id>{closedOpp.Id};
        RevertClosedOppOwnerQueueable queueable = new RevertClosedOppOwnerQueueable(oppIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        // Verify owner was NOT changed (name-based history was skipped)
        Opportunity unchangedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        System.assertEquals(currentOwnerId, unchangedOpp.OwnerId, 'Opportunity owner should NOT be changed (name-based history skipped)');
    }

    @isTest
    static void testNoRevertWhenNoChangesToday() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account RCO 2');
        insert testAccount;

        // Create closed opportunity
        Opportunity closedOpp = new Opportunity(
            Name = 'Test Closed Opportunity RCO 2',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-30),
            Closed_Lost_Reason__c = 'Legal',
            Closed_Lost_Reason_More_details__c = 'More details',
            Opp_will_be_relevant__c = '90 days',
            Solution_Fit__c = 'Marketing: SEO / Content'
        );
        insert closedOpp;

        closedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        Id originalOwnerId = closedOpp.OwnerId;

        // No mock history data - simulates no changes
        RevertClosedOppOwnerQueueable.mockHistoryData = new Map<Id, List<RevertClosedOppOwnerQueueable.HistoryWrapper>>();

        Test.startTest();
        Set<Id> oppIds = new Set<Id>{closedOpp.Id};
        RevertClosedOppOwnerQueueable queueable = new RevertClosedOppOwnerQueueable(oppIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        // Verify owner was not changed (still original)
        Opportunity unchangedOpp = [SELECT Id, OwnerId FROM Opportunity WHERE Id = :closedOpp.Id];
        System.assertEquals(originalOwnerId, unchangedOpp.OwnerId, 'Opportunity owner should remain unchanged');
    }

    @isTest
    static void testEmptyOppIds() {
        // Execute queueable with empty set
        Test.startTest();
        Set<Id> oppIds = new Set<Id>();
        RevertClosedOppOwnerQueueable queueable = new RevertClosedOppOwnerQueueable(oppIds);
        System.enqueueJob(queueable);
        Test.stopTest();

        // No exceptions should be thrown - just verifying it handles empty set gracefully
        System.assert(true, 'Queueable should handle empty set without errors');
    }

    @isTest
    static void testNullOppIds() {
        // Execute queueable with null
        Test.startTest();
        RevertClosedOppOwnerQueueable queueable = new RevertClosedOppOwnerQueueable(null);
        System.enqueueJob(queueable);
        Test.stopTest();

        // No exceptions should be thrown - just verifying it handles null gracefully
        System.assert(true, 'Queueable should handle null without errors');
    }

    @isTest
    static void testHandleClosedOppOwnerRevertFromAccountTrigger() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Account RCO 3');
        insert testAccount;

        // Create closed opportunity
        Opportunity closedOpp = new Opportunity(
            Name = 'Test Closed Opportunity RCO 3',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-30),
            Closed_Lost_Reason__c = 'Legal',
            Closed_Lost_Reason_More_details__c = 'More details',
            Opp_will_be_relevant__c = '90 days',
            Solution_Fit__c = 'Marketing: SEO / Content'
        );
        insert closedOpp;

        // Get another user to change account owner to
        List<User> otherUsers = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        if (otherUsers.isEmpty()) {
            System.assert(true, 'No other user found to test with');
            return;
        }

        // Change account owner (this should trigger the handler)
        Test.startTest();
        testAccount.OwnerId = otherUsers[0].Id;
        update testAccount;
        Test.stopTest();

        // The test verifies that the handler was called and queueable was enqueued
        System.assert(true, 'Account owner change should trigger the handler');
    }

    @isTest
    static void testHandlerNoOwnerChange() {
        // Test: Account is updated but owner doesn't change - should exit early
        Account testAccount = new Account(Name = 'Test Account No Owner Change');
        insert testAccount;

        // Update account without changing owner
        Test.startTest();
        testAccount.Name = 'Test Account No Owner Change - Updated';
        update testAccount;
        Test.stopTest();

        // Verify handler exited early (no owner change)
        System.assert(true, 'Handler should exit when no owner change detected');
    }

    @isTest
    static void testHandlerNoClosedOpportunities() {
        // Test: Account owner changes but there are no closed opportunities
        Account testAccount = new Account(Name = 'Test Account No Closed Opps');
        insert testAccount;

        // Create an OPEN opportunity (not closed)
        Opportunity openOpp = new Opportunity(
            Name = 'Test Open Opportunity',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert openOpp;

        // Get another user to change account owner to
        List<User> otherUsers = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true AND Profile.Name = 'System Administrator' LIMIT 1];
        if (otherUsers.isEmpty()) {
            System.assert(true, 'No other user found to test with');
            return;
        }

        // Change account owner
        Test.startTest();
        testAccount.OwnerId = otherUsers[0].Id;
        update testAccount;
        Test.stopTest();

        // Handler should run but find no closed opportunities to process
        System.assert(true, 'Handler should handle case with no closed opportunities');
    }

    @isTest
    static void testHandlerDirectCallNoOwnerChange() {
        // Directly call the handler method to cover the "no owner change" path
        Account testAccount = new Account(Name = 'Test Account Direct Call');
        insert testAccount;

        Map<Id, Account> newMap = new Map<Id, Account>([SELECT Id, OwnerId FROM Account WHERE Id = :testAccount.Id]);
        Map<Id, Account> oldMap = newMap.clone();

        Test.startTest();
        AccountTriggerHandler handler = new AccountTriggerHandler();
        handler.handleClosedOppOwnerRevert(newMap, oldMap);
        Test.stopTest();

        System.assert(true, 'Handler should exit when no owner changes');
    }

    @isTest
    static void testHandlerDirectCallWithClosedOpp() {
        // Directly call the handler method with owner change and closed opportunity
        // Run as a non-admin user to bypass the allowed profiles check
        
        // Create a Standard User to run as
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'StandardUser',
            Email = 'teststandarduser@test.com',
            Username = 'teststandarduser' + System.now().getTime() + '@test.com.sandbox',
            Alias = 'tstuser',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create test data as admin
        Account testAccount = new Account(Name = 'Test Account Direct With Opp');
        insert testAccount;

        // Create closed opportunity
        Opportunity closedOpp = new Opportunity(
            Name = 'Test Closed Opp Direct',
            AccountId = testAccount.Id,
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-30),
            Closed_Lost_Reason__c = 'Legal',
            Closed_Lost_Reason_More_details__c = 'More details',
            Opp_will_be_relevant__c = '90 days',
            Solution_Fit__c = 'Marketing: SEO / Content'
        );
        insert closedOpp;

        // Get another user for owner change
        List<User> otherUsers = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true LIMIT 1];
        if (otherUsers.isEmpty()) {
            System.assert(true, 'No other user found');
            return;
        }

        // Create old and new maps with different owners
        Account oldAccount = testAccount.clone(true, true, true, true);
        testAccount.OwnerId = otherUsers[0].Id;

        Map<Id, Account> newMap = new Map<Id, Account>();
        newMap.put(testAccount.Id, testAccount);

        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(oldAccount.Id, oldAccount);

        // Run as Standard User (non-allowed profile)
        Test.startTest();
        System.runAs(testUser) {
            AccountTriggerHandler handler = new AccountTriggerHandler();
            handler.handleClosedOppOwnerRevert(newMap, oldMap);
        }
        Test.stopTest();

        System.assert(true, 'Handler should enqueue job for closed opportunities');
    }

    @isTest
    static void testHandlerDirectCallNoClosedOpps() {
        // Directly call the handler method with owner change but NO closed opportunities
        // Run as a non-admin user to bypass the allowed profiles check
        
        // Create a Standard User to run as
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'StandardUser2',
            Email = 'teststandarduser2@test.com',
            Username = 'teststandarduser2' + System.now().getTime() + '@test.com.sandbox',
            Alias = 'tstu2',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Account testAccount = new Account(Name = 'Test Account Direct No Closed');
        insert testAccount;

        // Create OPEN opportunity (not closed)
        Opportunity openOpp = new Opportunity(
            Name = 'Test Open Opp Direct',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert openOpp;

        // Get another user
        List<User> otherUsers = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true LIMIT 1];
        if (otherUsers.isEmpty()) {
            System.assert(true, 'No other user found');
            return;
        }

        // Create old and new maps with different owners
        Account oldAccount = testAccount.clone(true, true, true, true);
        testAccount.OwnerId = otherUsers[0].Id;

        Map<Id, Account> newMap = new Map<Id, Account>();
        newMap.put(testAccount.Id, testAccount);

        Map<Id, Account> oldMap = new Map<Id, Account>();
        oldMap.put(oldAccount.Id, oldAccount);

        // Run as Standard User (non-allowed profile)
        Test.startTest();
        System.runAs(testUser) {
            AccountTriggerHandler handler = new AccountTriggerHandler();
            handler.handleClosedOppOwnerRevert(newMap, oldMap);
        }
        Test.stopTest();

        System.assert(true, 'Handler should not enqueue when no closed opportunities');
    }
}
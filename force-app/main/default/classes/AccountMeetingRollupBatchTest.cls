@isTest
private class AccountMeetingRollupBatchTest {

    static final Integer ACCOUNT_NUM = 10;
    static final Integer MEETING_PER_ACCOUNT_NUM = 5;

    @testSetup 
    static void setup() {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < ACCOUNT_NUM; i++) {
            accounts.add(TestDataFactory.createAccount());
        }
        insert accounts;
        List<Meeting__c> meetings = new List<Meeting__c>();
        for (Account acc_i : accounts) {
            for (Integer i = 0; i < MEETING_PER_ACCOUNT_NUM; i++) {
                meetings.add(
                    new Meeting__c(
                        Account__c = acc_i.Id,
                        Status__c = 'Rescheduling'
                    )
                );
            }
        }
        insert meetings;
    }

    @isTest 
    static void testBatch() {
        AccountMeetingRollupBatch batch = new AccountMeetingRollupBatch();
        Test.startTest();
        Database.executeBatch(batch, 50);
        Test.stopTest();
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Number_Of_Open_Meetings__c FROM Account]);
        List<Meeting__c> meetingList = [SELECT Id, Account__c, Status__c FROM Meeting__c WHERE Account__c IN :accountMap.keySet()];
        Map<Id, List<Meeting__c>> accountToMeetingsMap = new Map<Id, List<Meeting__c>>();
        for (Meeting__c meet_i : meetingList) {
            if (accountToMeetingsMap.get(meet_i.Account__c) == null) {
                accountToMeetingsMap.put(meet_i.Account__c, new List<Meeting__c>());
            }
            accountToMeetingsMap.get(meet_i.Account__c).add(meet_i);
        }
        for (Id accId_i : accountToMeetingsMap.keySet()) {
            Account acc_i = accountMap.get(accId_i);
            List<Meeting__c> meetings_i = accountToMeetingsMap.get(accId_i);
            System.assertEquals(acc_i.Number_Of_Open_Meetings__c, meetings_i.size());
        }
    }

    @isTest
    static void testScheduler() {
        AccountMeetingRollupBatch batch = new AccountMeetingRollupBatch();
        Test.startTest();
        System.schedule('AccountMeetingRollupBatch', '0 0 8 * * ?', batch);
        Test.stopTest();
    }

    @isTest
    static void testScheduler_batchScopeConfig() {
        AccountMeetingRollupBatch batch = new AccountMeetingRollupBatch(100);
        Test.startTest();
        System.schedule('AccountMeetingRollupBatch', '0 0 8 * * ?', batch);
        Test.stopTest();
    }
}
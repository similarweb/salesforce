@isTest
private class FeedCommentHandlerTest {

    @isTest
    static void testCallFlowWhenCaseRelated() {
        // Step 1: Setup Test Data
        // Create a test user to act as the Requester
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
                FirstName = 'Test',
                LastName = 'User',
                Alias = 'tuser',
                Email = 'testuser@example.com',
                Username = 'testuser' + System.currentTimeMillis() + '@example.com',
                CommunityNickname = 'testuser',
                ProfileId = profile.Id,
                TimeZoneSidKey = 'America/New_York',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        // Create a test case
        Case testCase = new Case(
                Subject = 'Test Case',
                Status = 'New',
                Type = 'Question',
                RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Desk').getRecordTypeId(),
                Requester__c = testUser.Id
        );
        insert testCase;

        // Create a feed comment related to the test case
        FeedItem feeditem = new FeedItem (

                parentid = testCase.id,

                type = 'ContentPost',

                Body = 'Hello'

        );

        insert feeditem;
        Test.startTest();
        FeedComment feedComment = new FeedComment();
        feedComment.FeedItemId = feeditem.Id;
        feedComment.CommentBody = '@Testing Chatter Check';
        insert  feedComment;


        // Step 2: Execute the Method

        // Instantiate the handler and call the method
        Test.stopTest();

        // assert
        List<FeedComment> feedComments = [SELECT Id FROM FeedComment];
        System.debug('feedComments---'+feedComments);

    }
}
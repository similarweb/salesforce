@istest
public class AccountFilesToFoldersBatchTest {
  @testSetup
  public static void setup() {
    Account acc = new Account(Name = 'test', ARR__c = 5);
    insert acc;
    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S';
    cv.PathOnClient = 'test';
    cv.Origin = 'H';
    cv.OwnerId = UserInfo.getUserId();
    cv.Title = 'title';
    cv.VersionData = Blob.valueOf('Body');
    insert cv;

    cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

    ContentDocumentLink cl = new ContentDocumentLink(
      LinkedEntityId = acc.Id,
      ContentDocumentId = cv.ContentDocumentId,
      ShareType = 'I'
    );

    insert cl;
  }

  @istest
  public static void testBatch() {
    Test.startTest();
    Database.executeBatch(new AccountFilesToFoldersBatch('TestTestTest'), 500);
    Test.stopTest();
  }

  @istest
  public static void testBatch2() {
    Test.startTest();
    Database.executeBatch(
      new AccountFilesToFoldersBatch('TestTestTest', 1),
      500
    );
    Test.stopTest();
  }
}

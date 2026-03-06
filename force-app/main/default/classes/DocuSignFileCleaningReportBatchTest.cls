@isTest
public class DocuSignFileCleaningReportBatchTest {
  @TestSetup
  public static void setup() {
    dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c();
    dsStatus.dsfs__Sender_Email__c = 'sd.ds@similarweb.com';
    insert dsStatus;
    ContentVersion contentVersionInsert = new ContentVersion(
      Title = 'Test',
      PathOnClient = 'Test.jpg',
      VersionData = Blob.valueOf('Test Content Data'),
      IsMajorVersion = true
    );
    insert contentVersionInsert;
    contentVersionInsert = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersionInsert.Id
      LIMIT 1
    ];

    ContentDocumentLink contentlink2 = new ContentDocumentLink();
    contentlink2.ShareType = 'I';
    contentlink2.LinkedEntityId = dsStatus.id;
    contentlink2.ContentDocumentId = contentVersionInsert.contentDocumentId;
    contentlink2.Visibility = 'AllUsers';
    insert contentlink2;
  }

  @isTest
  public static void testBatch() {
    Test.startTest();
    DocuSignFileCleaningReportBatch dsfBatch = new DocuSignFileCleaningReportBatch(
      UserInfo.getUserId()
    );
    Database.executeBatch(dsfBatch);
    Test.stopTest();
  }

  @isTest
  public static void testScheduler() {
    Test.startTest();
    DocuSignFileCleaningReportBatch dsfBatch = new DocuSignFileCleaningReportBatch(
      UserInfo.getUserId()
    );
    Datetime workTime = System.now().addHours(1);
    String CRONEXP = DocuSignFileCleaningBatch.getCronFromDateTime(workTime);
    System.schedule('DocuSignFileCleaningBatchTest', CRONEXP, dsfBatch);
    Test.stopTest();
  }
}

/**
 * @author Itzik Winograd
 * @date 29/08/2021
 * @description Test class for DeleteSensitiveAttachmentsBatchTest
 * ====================================
 * @author Itzik Winograd
 * @date 03/03/2022
 * @description Changed the test class to work with custom query and not general config keywords
 */
@isTest
public class DeleteSensitiveAttachmentsBatchTest {
  /**
   * @author Itzik Winograd
   * @date 29/08/2021
   * @description: Create a Content document with a name from the custom Meta Data "AttachmentsDeletionKeywords"
   */
  @testSetup
  public static void DeleteSensitiveAttachmentsBatchTestSetup() {
    Blob bodyBlob = Blob.valueOf(
      'Unit Test ContentVersion Body to be insert in test class for testing the'
    );
    ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'Offer Letter,Commission Plan,Commission Letter,Employment agreement,Salary Increase',
      PathOnClient = 'SampleTitle.pdf',
      VersionData = bodyBlob,
      origin = 'H'
    );
    insert contentVersion_1;
  }

  /**
   * @author Itzik Winograd
   * @date 29/08/2021
   * @description: Make sure that 1 Content version exists. Use the metadata to build the query. Run the batch.
   * @expected: after the batch run there will be no CD records left.
   * @expected: a log record will be found.
   * ====================================
   * @author Itzik Winograd
   * @date 03/03/2022
   * @description Changed the test class to work with custom query and not general config keywords
   */
  @isTest
  public static void deleteSensitiveAttachmentsBatchTest() {
    String CUSTOM_QUERY_PROCESS_NAME = 'DeleteSensitiveAttachments';

    //        String rawKeywords = GeneralUtil.getGeneralConfig('AttachmentsDeletionKeywords').Text_Value__c;
    //        List<String> keywords = rawKeywords.split(',');
    List<ContentDocument> CDs = Database.query(
      DeleteSensitiveAttachmentsBatch.buildQuery(CUSTOM_QUERY_PROCESS_NAME)
    );
    System.assertNotEquals(CDs.size(), 0, 'No Content documents found');
    Test.startTest();
    Database.executeBatch(new DeleteSensitiveAttachmentsBatch());
    Test.stopTest();
    CDs = Database.query(
      DeleteSensitiveAttachmentsBatch.buildQuery(CUSTOM_QUERY_PROCESS_NAME)
    );
    System.assertEquals(
      CDs.size(),
      0,
      'Content documents were found, while there was supposed to be none.'
    );
    List<Apex_Event_Log__c> eventLogs = [
      SELECT Id
      FROM Apex_Event_Log__c
      WHERE Apex_Class__c = 'DeleteSensitiveAttachmentsBatch'
      LIMIT 1
    ];
    System.assertEquals(eventLogs.size(), 1, 'No logs were found');
  }
}

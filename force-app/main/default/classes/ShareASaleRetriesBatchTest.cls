/**
 * @author Itzik Winograd
 * @date 10/08/2021
 * @description Test class for ShareASaleRetriesBatch
 */
@isTest
public class ShareASaleRetriesBatchTest {
  @testSetup
  /**
   * @author Itzik Winograd
   * @date 10/08/2021
   * @description: Create a lead with shareasale error.
   */
  public static void shareASaleTestSetup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Lead myLead = new Lead(
      LastName = 'lastName',
      email = 'testLead@testLead.com',
      Company = 'testComp',
      Country = 'Austria',
      Affiliate_Id__c = '5555'
    );
    Test.setMock(
      HttpCalloutMock.class,
      new ShareASaleIntegrationTest.ShareASaleMockError()
    );
    insert myLead;
  }
  /**
   * @author Itzik Winograd
   * @date 11/08/2021
   * @Description: query for an error lead. make sure it has "retry = 0". run the batch.
   * @Expect: the value on ShareASale_Retries_Counter__c will be > 0
   */
  @isTest
  public static void shareASaleRetryTest() {
    Lead newLead = queryLead();
    System.assertEquals(
      newLead.ShareASale_Retries_Counter__c,
      0,
      'The ShareASale_Retries_Counter__c is not 0!'
    );

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new ShareASaleIntegrationTest.ShareASaleMockError()
    );
    Database.executeBatch(new ShareASaleRetriesBatch('Lead'), 5);
    Test.stopTest();

    newLead = queryLead();
    System.debug('@@@ newLead.ShareASale_Retries_Counter__c: ' + newLead);
    System.assert(
      newLead.ShareASale_Retries_Counter__c > 0,
      'The ShareASale_Retries_Counter__c is not more then 0: ' +
      newLead.ShareASale_Retries_Counter__c
    );
  }

  /**
   * @author Itzik Winograd
   * @date 11/08/2021
   * @Description: query for an error lead. make sure it has "retry = 0". set the number of retries to 4 and run the batch .
   * @Expect: an error record with 'creatTooManyRetriesLog' will be created
   */
  @isTest
  public static void shareASaleRetryTestWithLog() {
    Lead newLead = queryLead();
    System.assertEquals(
      newLead.ShareASale_Retries_Counter__c,
      0,
      'The ShareASale_Retries_Counter__c is not 0!'
    );
    newLead.ShareASale_Retries_Counter__c = 4;
    update newLead;
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new ShareASaleIntegrationTest.ShareASaleMockError()
    );
    Database.executeBatch(new ShareASaleRetriesBatch('Lead'), 5);
    Test.stopTest();

    newLead = queryLead();
    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>(
      [
        SELECT
          Id,
          Log_Type__c,
          Apex_Class__c,
          Detailed_Information__c,
          Detailed_Error_Message__c,
          Apex_Method__c,
          Http_Endpoint__c
        FROM Apex_Event_Log__c
        WHERE Apex_Method__c = 'creatTooManyRetriesLog'
      ]
    );
    System.assert(
      logs.size() > 0,
      'No creatTooManyRetriesLog record was created!'
    );
  }

  //Retrieve a lead
  private static Lead queryLead() {
    return [
      SELECT
        Id,
        Affiliate_Id__c,
        ShareASale_Retries_Counter__c,
        ShareASale_New_Transaction_Response__c
      FROM Lead
      WHERE Affiliate_Id__c = '5555'
      LIMIT 1
    ];
  }
}

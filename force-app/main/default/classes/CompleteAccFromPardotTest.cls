/**
 * @author Itzik Winograd
 * @date 26/04/2020
 * @description Test classes for CompleteAccFromPardotBatch and CompleteAccFromPardotSchedulable
 *
 *
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        -  2022-05-19
 * description - Change the number of contacts to not exceed the Complete_Account_From_Pardot_Batch_Size value
 * --------------------------------------------------------------------------------------
 */
@isTest
public class CompleteAccFromPardotTest {
  /**
   * @author Itzik Winograd
   * @date 22/04/2021
   * @description: Test Setup
   * @param Database.BatchableContext BC.
   * @param List<SObject> scope.
   */
  @testSetup
  public static void completeAccFromPardotTestSetup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );

    //Insert 1 accounts
    List<Account> acc_lst = AccountUtils.getAccounts(1);
    insert acc_lst;
    //Insert X contact
    Integer BATCH_SIZE = Integer.valueOf(
      GeneralUtil.getGeneralConfig('Complete_Account_From_Pardot_Batch_Size')
        .Number_Value__c
    );
    List<Contact> contact_lst = new List<Contact>();
    contact_lst.addAll(
      ContactUtils.getContactsForAccount(BATCH_SIZE, acc_lst[0])
    );

    for (Integer i = 0; i < contact_lst.size(); i++) {
      contact_lst[i].pi__url__c = 'http://pi.pardot.com/prospect/read?id=' + i;
    }
    System.debug('@@@ contact_lst: ' + contact_lst);
    insert contact_lst;
  }

  /**
   * @author Itzik Winograd
   * @date 27/04/2021
   * @description: Run a schedulable batch, then verify that the schedulable has not run yet.
   * @expected:
   * @param Database.BatchableContext BC.
   * @param List<SObject> scope.
   */
  @isTest
  public static void testCompleteAccFromPardotSchedulable() {
    String CRON_EXP = '0 0 0 3 9 ? 2100';

    Test.startTest();
    // Schedule the test job
    String jobId = System.schedule(
      'CompleteAccFromPardotSchedulable',
      CRON_EXP,
      new CompleteAccFromPardotSchedulable()
    );
    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression, TimesTriggered, NextFireTime
      FROM CronTrigger
      WHERE id = :jobId
    ];
    // Verify the expressions are the same
    System.assertEquals(CRON_EXP, ct.CronExpression);
    // Verify the job has not run
    System.assertEquals(0, ct.TimesTriggered);
    // Verify the next time the job will run
    System.assertEquals('2100-09-03 00:00:00', String.valueOf(ct.NextFireTime));
    Test.stopTest();
  }

  /**
   * @author Itzik Winograd
   * @date 28/04/2021
   * @description: Run the batch
   * @expected:
   * @param Database.BatchableContext BC.
   * @param List<SObject> scope.
   */
  @isTest
  public static void testCompleteAccFromPardotBatch() {
    Test.startTest();
    //Test.setMock(HttpCalloutMock.class, new GetSalesforceAccessTokenTest.SalesforceTokenMock());
    Test.setMock(
      HttpCalloutMock.class,
      new PardotUtilsTest.PardotTokenMock('ok', 200)
    );
    Integer BATCH_SIZE = Integer.valueOf(
      GeneralUtil.getGeneralConfig('Complete_Account_From_Pardot_Batch_Size')
        .Number_Value__c
    );
    Id batchInstanceId = Database.executeBatch(
      new CompleteAccFromPardotBatch(),
      BATCH_SIZE
    );
    Test.stopTest();
    //Assert that on the account with pardot Id=1, the Phone field was updated with 123456
    //This phone value can be found in class PardotUtilsTest in the XML mock.
    System.debug(
      '@@@ cons' +
      [
        SELECT AccountId, Account.Phone
        FROM Contact
        WHERE pardot_id__c = '1'
      ]
    );
    String phone = [
      SELECT Id, phone
      FROM Account
      WHERE
        Id IN (
          SELECT AccountId
          FROM Contact
          WHERE pardot_id__c = '1'
        )
    ][0]
    .phone;
    System.assertEquals('123456', phone, 'Phone mismatch!');
  }
}

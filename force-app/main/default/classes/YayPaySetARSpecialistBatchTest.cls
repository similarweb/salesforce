@IsTest
/**
 * @author Itzik Winograd
 * @date 03/08/2022
 * @description MIS-2458: Test class for the YayPaySetARSpecialistBatch class
 */
public with sharing class YayPaySetARSpecialistBatchTest {
  private static final Integer NUMBER_OF_RECORDS = 5;
  private static Integer BATCH_LIMIT = Integer.valueOf(
    GeneralUtil.getGeneralConfig('BillingExpertBatchSize').Number_Value__c
  );

  @TestSetup
  public static void billingExpertTestSetup() {
    List<Account> accountsList = AccountUtils.getAccounts(NUMBER_OF_RECORDS);
    for (Account acc : accountsList) {
      acc.Billing_expert__c = [
        SELECT Id
        FROM User
        WHERE IsActive = TRUE AND Division != NULL
        LIMIT 1
      ]
      .Id;
      acc.Billing_Expert_Changed__c = true;
      acc.Latest_Zuora_Account_ID__c = 'success Id';
    }
    insert accountsList;
  }

  /**
   * @author          Itzik Winograd
   * @date            03/08/2022
   * @description     Run the batch.
   * @Expected        After the batch run the Billing_Expert_Changed__c is false.
   */
  @IsTest
  public static void setARSpecialistSuccessTest() {
    List<Account> accountsList = [
      SELECT Id, Latest_Zuora_Account_ID__c
      FROM Account
    ];
    System.debug('@@@ Found accounts before update: ' + accountsList);

    Test.setMock(HttpCalloutMock.class, new YayPayARSpecialistMock());

    Test.startTest();
    YayPaySetARSpecialistBatch batchInstance = new YayPaySetARSpecialistBatch();
    batchInstance.alreadyScheduled = true;
    Database.executeBatch(batchInstance, BATCH_LIMIT);
    //Call methods that cant be tested directly with the business logic
    batchInstance.createCronExpression();
    batchInstance.abortCurrentBatchJobs();
    batchInstance.rescheduleJob();
    Test.stopTest();

    accountsList = [
      SELECT Id, Billing_expert__c, Billing_Expert_Changed__c
      FROM Account
    ];
    System.debug('@@@ Found accounts after update: ' + accountsList);
    for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
      System.assertEquals(
        accountsList[i].Billing_Expert_Changed__c,
        false,
        'Error: Billing_Expert_Changed__c flag is on, but should be off'
      );
    }
  }

  /**
   * @author          Itzik Winograd
   * @date            03/08/2022
   * @description     Run the batch.
   * @Expected        After the batch run the Billing_Expert_Changed__c is still On
   * @Expected        After the batch run there are Logs created
   */
  @IsTest
  public static void setARSpecialistFailedTest() {
    List<Account> accountsList = [
      SELECT Id, Latest_Zuora_Account_ID__c
      FROM Account
    ];
    System.debug('@@@ Found accounts before update: ' + accountsList);
    for (Account acc : accountsList) {
      acc.Latest_Zuora_Account_ID__c = 'error';
    }
    update accountsList;

    Test.setMock(HttpCalloutMock.class, new YayPayARSpecialistMock());

    Test.startTest();
    Database.executeBatch(new YayPaySetARSpecialistBatch(), BATCH_LIMIT);
    Test.stopTest();

    accountsList = [
      SELECT Id, Billing_expert__c, Billing_Expert_Changed__c
      FROM Account
    ];
    System.debug('@@@ Found accounts after update: ' + accountsList);
    for (Integer i = 0; i < NUMBER_OF_RECORDS; i++) {
      System.assertEquals(
        accountsList[i].Billing_Expert_Changed__c,
        true,
        'Error: Billing_Expert_Changed__c flag is off, but should be on'
      );
    }

    System.assert(
      [
        SELECT Id
        FROM Apex_Event_Log__c
        WHERE Apex_class__c = 'YayPaySetARSpecialistBatch'
      ]
      .size() > 0,
      'Error: No error logs found!'
    );
  }
  /**
   * @author Itzik Winograd
   * @date 03/08/2022
   * @description - Mock an HTTPS response for YayPay Set ARSpecialist Test
   */
  public class YayPayARSpecialistMock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
      System.debug('@@@ req: ' + req.toString());
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{}');
      res.setStatusCode(req.getEndpoint()?.contains('error') ? 400 : 201);
      return res;
    }
  }
}

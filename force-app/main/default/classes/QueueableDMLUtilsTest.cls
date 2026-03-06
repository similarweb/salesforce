/**
 * @author Itzik Winograd
 * @date 17/06/2021
 * @description Test class for QueueableDMLUtilsTest.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public class QueueableDMLUtilsTest {
  /**
   * @author Itzik Winograd
   * @date 23/06/2021
   * @description Create Apex_Log_Event__c records to manipulate.
   * @Expected:
   */
  @testSetup
  public static void queueableDMLTestStuep() {
    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>();
    for (Integer i = 0; i < 5; i++) {
      logs.add(createLogRecord());
    }
    insert logs;
  }

  /**
   * @author Itzik Winograd
   * @date 23/06/2021
   * @description test the DML Utils Insert method. Insert 5 log records and execute ExecuteDistibuteAccountValuesToCons aftewards.
   * @Expected: there will be 10 (5+5) records in the Apex_Event__c object
   */
  @istest
  public static void queueableDMLUtilsInsert() {
    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>();
    for (Integer i = 0; i < 5; i++) {
      logs.add(createLogRecord());
    }
    Test.startTest();
    System.enqueueJob(
      new QueueableDMLUtils(
        logs,
        'insert',
        false,
        'ExecuteDistibuteAccountValuesToCons'
      )
    );
    Test.stopTest();
    System.assertEquals(
      [
          SELECT Id
          FROM Apex_Event_Log__c
          WHERE Apex_class__c = 'QueueableDMLUtilsTest'
        ]
        .size(),
      10,
      'error in insert'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 23/06/2021
   * @description test the DML Utils Upsert method: get existing records, add new and upsert all
   * @Expected: 6 records will be (5 from setup + 1 from this method)
   */
  @istest
  public static void queueableDMLUtilsUpsert() {
    List<Apex_Event_Log__c> logs = [
      SELECT Id
      FROM Apex_Event_Log__c
      WHERE Apex_class__c = 'QueueableDMLUtilsTest'
    ];
    logs.add(createLogRecord());
    Test.startTest();
    System.enqueueJob(new QueueableDMLUtils(logs, 'upsert', false, null));
    Test.stopTest();
    System.assertEquals(
      6,
      [
          SELECT Id
          FROM Apex_Event_Log__c
          WHERE Apex_class__c = 'QueueableDMLUtilsTest'
        ]
        .size(),
      'Error in upsert'
    );
  }
  /**
   * @author Itzik Winograd
   * @date 23/06/2021
   * @description test the DML Utils Update method. get existing records then update them
   * @Expected: 5 records will have "error" type
   */
  @istest
  public static void queueableDMLUtilsUpdate() {
    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>();
    for (Apex_Event_Log__c log : [
      SELECT Id, Log_Type__c
      FROM Apex_Event_Log__c
      WHERE Apex_class__c = 'QueueableDMLUtilsTest'
    ]) {
      log.Log_Type__c = 'Error';
      logs.add(log);
    }
    Test.startTest();
    System.enqueueJob(new QueueableDMLUtils(logs, 'update', false, null));
    Test.stopTest();
    System.assertEquals(
      5,
      [
          SELECT Id
          FROM Apex_Event_Log__c
          WHERE Log_Type__c = 'Error'
        ]
        .size(),
      'Error in upsert'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 23/06/2021
   * @description: test the DML Utils Delete method - delete the setup records.
   * 				Delete one of the records so when deleting the full list it will create an error.
   * @Expected: 1 log recrod will be found.
   */
  @istest
  public static void queueableDMLUtilsDelete() {
    List<Apex_Event_Log__c> logs = [SELECT Id FROM Apex_Event_Log__c];
    delete logs[0]; //delete one of the record so an error will come up.
    Test.startTest();
    System.enqueueJob(new QueueableDMLUtils(logs, 'delete', false, null));
    Test.stopTest();

    System.assertEquals(
      1,
      [
          SELECT Id
          FROM Apex_Event_Log__c
          WHERE Log_Type__c = 'Error'
        ]
        .size(),
      'Error in upsert'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 23/06/2021
   * @description: call AdditionalLogicForAfterDML with false name
   * @Expected: 1 log recrod will be found.
   */
  @istest
  public static void queueableDMLUtilsErrorAdditionlLogic() {
    Test.startTest();
    System.enqueueJob(
      new QueueableDMLUtils(
        new List<Apex_Event_Log__c>(),
        'insert',
        false,
        'FalseClassName'
      )
    );
    Test.stopTest();

    System.assertEquals(
      1,
      [
          SELECT Id
          FROM Apex_Event_Log__c
          WHERE Log_Type__c = 'Error'
        ]
        .size(),
      'Error in upsert'
    );
  }

  public static Apex_Event_Log__c createLogRecord() {
    return new Apex_Event_Log__c(
      Record_Ids__c = null,
      Log_Type__c = 'info',
      Apex_class__c = 'QueueableDMLUtilsTest'
    );
  }
}

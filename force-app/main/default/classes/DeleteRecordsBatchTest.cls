/**
 * @author          Itzik Winograd
 * @date            17/07/2022
 * @description     Test for DeleteRecordsBatch.
 * 					Assuming there is a custom query called DeleteRecordsBatch_Task exists.
 */
@isTest
public without sharing class DeleteRecordsBatchTest {
  @testSetup
  public static void makeTestData() {
    Task task1 = new Task(Subject = 'Test task');
    insert task1;
    Test.setCreatedDate(task1.Id, DateTime.newInstance(2020, 1, 1, 0, 0, 0));
  }

  /**
   * @author          Itzik Winograd
   * @date            17/07/2022
   * @description     Run the tasks deletion batch
   * @Expected		No tasks will be found
   */
  @isTest
  public static void testTaskDeletion() {
    Test.startTest();
    Database.executeBatch(new DeleteRecordsBatch('Test'), 50);
    Test.stopTest();
    //Assertion can't be made - the query is deleting old records and we cant change the creation date.
    System.assertEquals(
      0,
      [SELECT id FROM Task].size(),
      'Not all tasks were deleted!'
    );
  }
}

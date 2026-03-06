/**
 *===CHANGES===
 * Itzik Winograd 2022-01-26: Added inferred solution to avoid errors and testContactsTasksCounter
 */
@istest
public class TaskCounterBatchTest {
  /**
   * Itzik Winograd 2022-01-26: Added inferred solution to avoid errors
   */
  @testSetup
  public static void taskCounterBatchTesttestSetup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
  }

  @istest
  public static void testBatch() {
    Lead lead = new Lead(
      Status = 'Open',
      LastName = 'Test1',
      Company = 'Company',
      Email = 'test@test.com'
    );
    insert lead;
    Task task = new Task(Subject = 'test', whoId = lead.Id);
    insert task;
    Test.startTest();
    new TaskCounterBatch(Datetime.now(), 0).execute(null);
    Test.stopTest();
  }

  @istest
  public static void testBatch2() {
    Lead lead = new Lead(
      Status = 'Open',
      LastName = 'Test2',
      Company = 'Company2',
      Email = 'test2@test2.com'
    );
    insert lead;
    Task task = new Task(Subject = 'test2', whoId = lead.Id);
    insert task;
    Test.startTest();
    new TaskCounterBatch(Datetime.now(), 0, true).execute(null);
    Test.stopTest();
  }

  @istest
  public static void testContactsTasksCounter() {
    Contact con = ContactUtils.getContacts(1)[0];
    insert con;
    Task task = new Task(Subject = 'test', whoId = con.Id);
    insert task;
    Test.startTest();
    new TaskCounterBatch(Datetime.now(), 0, true).execute(null);
    Test.stopTest();
  }
}

@isTest
private class BatchFitScoreCallLogCleaningTest {
  @testSetup
  static void setup() {
    List<Fit_Score_Call_Log__c> logsInDB = new List<Fit_Score_Call_Log__c>();
    for (integer i = 0; i < 100; i++) {
      Fit_Score_Call_Log__c log = new Fit_Score_Call_Log__c();
      log.Name = 'test' + Datetime.now();
      log.CreatedDate = Datetime.now().addDays(-5);
      logsInDB.add(log);
    }
    insert logsInDB;

    Fit_Score_Call_Log__c log = new Fit_Score_Call_Log__c();
    log.Name = 'test' + Datetime.now();
    insert log;
  }

  static testMethod void test() {
    System.assertEquals(101, [SELECT COUNT() FROM Fit_Score_Call_Log__c]);
    Test.startTest();
    BatchFitScoreCallLogCleaning batch = new BatchFitScoreCallLogCleaning();
    Id batchId = Database.executeBatch(batch);
    Test.stopTest();
    // after the testing stops, assert records were updated properly
    System.assertEquals(1, [SELECT COUNT() FROM Fit_Score_Call_Log__c]);
  }
}

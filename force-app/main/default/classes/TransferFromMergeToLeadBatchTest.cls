/**
 * Created by Alon.Shalev on 4/10/2023.
 */

@IsTest
private class TransferFromMergeToLeadBatchTest {
  @TestSetup
  static void setup() {
    // Create test data for Lead_To_Merge_Fields__c object
    List<Lead_To_Merge_Fields__c> testData = new List<Lead_To_Merge_Fields__c>();
    SFMC_Processed_by_Distribution__c processedByDistribution8 = setDistribution(
      80,
      8,
      'AI / PI'
    );
    insert processedByDistribution8;
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;

    Lead lead1 = new Lead(
      LastName = 'ZoharIsStupid',
      Company = 'ABC Company 1',
      email = 'jumbo101@mumbo.com'
    );
    insert lead1;
    testData.add(
      new Lead_To_Merge_Fields__c(
        Name = lead1.id,
        Last_Name__c = 'Smith',
        Company__c = 'ABC Company'
      )
    );
    insert testData;
  }

  @IsTest
  static void testBatchJob() {
    // Start batch job
    Test.startTest();
    TransferFromMergeToLeadBatch batchJob = new TransferFromMergeToLeadBatch();
    Database.executeBatch(batchJob);
    Test.stopTest();
  }
  private static SFMC_Processed_by_Distribution__c setDistribution(
    Decimal SFMCPercent,
    Decimal counter,
    String solution
  ) {
    return new SFMC_Processed_by_Distribution__c(
      Processed_by_SFMC__c = SFMCPercent,
      Initial_Date__c = date.today() - 1,
      Counter__c = counter,
      Solution__c = solution
    );
  }

  @IsTest
  static void testScheduledJob() {
    Test.startTest();
    String CRON_EXP = '0 0 0 3 9 ? 2100';
    System.schedule(
      'TransferFromMergeToLeadBatchTest',
      CRON_EXP,
      new TransferFromMergeToLeadBatch()
    );
    Test.stopTest();
  }
}

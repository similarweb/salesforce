@isTest
public class UpdateHierarchyOpenOppsAccountBatchTest {
  @testSetup
  static void setupTestData() {
    // Create test data for Accounts with different domains and open opportunities
    Account parentAccount1 = new Account(
      Name = 'Parent Account 1',
      Parent_Company_Domain__c = 'parent1.com',
      Number_Of_Open_Opps_Changed_Today__c = true
    );
    insert parentAccount1;

    Account childAccount1 = new Account(
      Name = 'Child Account 1',
      Parent_Company_Domain__c = 'parent1.com',
      Number_Of_Open_Opps_Changed_Today__c = true
    );
    insert childAccount1;

    Opportunity opp1 = new Opportunity(
      Name = 'Opportunity 1',
      AccountId = parentAccount1.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today().addMonths(1)
    );
    Opportunity opp2 = new Opportunity(
      Name = 'Opportunity 2',
      AccountId = childAccount1.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today().addMonths(1)
    );
    insert new List<Opportunity>{ opp1, opp2 };

    Account parentAccount2 = new Account(
      Name = 'Parent Account 2',
      Parent_Company_Domain__c = 'parent2.com',
      Number_Of_Open_Opps_Changed_Today__c = true
    );
    insert parentAccount2;

    Account childAccount2 = new Account(
      Name = 'Child Account 2',
      Parent_Company_Domain__c = 'parent2.com',
      Number_Of_Open_Opps_Changed_Today__c = true
    );
    insert childAccount2;

    Opportunity opp3 = new Opportunity(
      Name = 'Opportunity 3',
      AccountId = parentAccount2.Id,
      StageName = 'Prospecting',
      CloseDate = Date.today().addMonths(1)
    );
    insert opp3;
  }

  @isTest
  static void testBatchExecution() {
    Test.startTest();

    // Instantiate the batch class
    UpdateHierarchyOpenOppsAccountBatch batch = new UpdateHierarchyOpenOppsAccountBatch(
      10
    );

    // Execute the batch job
    Database.executeBatch(batch);

    Test.stopTest();

    // Verify the results
    Account[] updatedAccounts = [
      SELECT
        Id,
        Hierarchy_Total_Open_Opps__c,
        Number_Of_Open_Opps_Changed_Today__c
      FROM Account
      WHERE Parent_Company_Domain__c IN ('parent1.com', 'parent2.com')
    ];

    System.assertEquals(
      2,
      updatedAccounts[0].Hierarchy_Total_Open_Opps__c,
      'Parent Account 1 should have 2 open opportunities.'
    );
    System.assertEquals(
      false,
      updatedAccounts[0].Number_Of_Open_Opps_Changed_Today__c,
      'Number_Of_Open_Opps_Changed_Today__c should be false.'
    );

    System.assertEquals(
      2,
      updatedAccounts[1].Hierarchy_Total_Open_Opps__c,
      'Parent Account 2 should have 2 open opportunity.'
    );
    System.assertEquals(
      false,
      updatedAccounts[1].Number_Of_Open_Opps_Changed_Today__c,
      'Number_Of_Open_Opps_Changed_Today__c should be false.'
    );
  }

  @isTest
  static void testSchedulableExecution() {
    Test.startTest();

    // Schedule the batch job
    String sch = '0 0 0 15 3 ? 2057';
    UpdateHierarchyOpenOppsAccountBatch schedulableBatch = new UpdateHierarchyOpenOppsAccountBatch(
      10
    );
    String jobId = System.schedule('Test Schedule', sch, schedulableBatch);

    // Verify the scheduled job
    CronTrigger ct = [
      SELECT Id, CronJobDetail.Name, State
      FROM CronTrigger
      WHERE Id = :jobId
    ];
    System.assertEquals('Test Schedule', ct.CronJobDetail.Name);
    System.assertEquals('WAITING', ct.State);

    Test.stopTest();
  }
}

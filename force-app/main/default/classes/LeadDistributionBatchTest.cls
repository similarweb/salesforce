/**
 * @author Zohar Sinay
 * @date 22/11/2021
 * @description Distribute leads to marketing cloud and pardot lead test
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */

@istest
public with sharing class LeadDistributionBatchTest {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;

    SFMC_Processed_by_Distribution__c processedByDistribution = setDistribution(
      20,
      0,
      'Sales'
    );
    insert processedByDistribution;
    SFMC_Processed_by_Distribution__c processedByDistribution1 = setDistribution(
      10,
      1,
      'Investors'
    );
    insert processedByDistribution1;
    SFMC_Processed_by_Distribution__c processedByDistribution2 = setDistribution(
      20,
      2,
      'Research'
    );
    insert processedByDistribution2;
    SFMC_Processed_by_Distribution__c processedByDistribution3 = setDistribution(
      30,
      3,
      'Marketing'
    );
    insert processedByDistribution3;
    SFMC_Processed_by_Distribution__c processedByDistribution4 = setDistribution(
      40,
      4,
      'Sales (SI)'
    );
    insert processedByDistribution4;
    SFMC_Processed_by_Distribution__c processedByDistribution5 = setDistribution(
      50,
      5,
      'Agency (MI)'
    );
    insert processedByDistribution5;
    SFMC_Processed_by_Distribution__c processedByDistribution6 = setDistribution(
      60,
      6,
      'Investors (II)'
    );
    insert processedByDistribution6;
    SFMC_Processed_by_Distribution__c processedByDistribution7 = setDistribution(
      70,
      7,
      'Publishers & Media'
    );
    insert processedByDistribution7;
    SFMC_Processed_by_Distribution__c processedByDistribution8 = setDistribution(
      80,
      8,
      'AI / PI'
    );
    insert processedByDistribution8;
    SFMC_Processed_by_Distribution__c processedByDistribution9 = setDistribution(
      90,
      9,
      'Marketing (MI)'
    );
    insert processedByDistribution9;
  }

  @isTest
  static void createDistributionedLeads0() {
    Lead lead1 = new Lead(
      LastName = 'Test 1',
      Company = 'Test comp',
      email = 'jumbo101@mumbo.com',
      Inferred_Solution__c = 'Sales',
      Is_Distribution_Handled__c = true
    );

    List<Lead> leadList = new List<Lead>();
    for (Integer i = 0; i < 3; i++) {
      leadList.add(
        new Lead(
          LastName = 'Test ' + i,
          Company = 'Test comp' + i,
          email = 'jumbo' + i + '@mumbo.com',
          Inferred_Solution__c = 'Sales'
        )
      );
    }

    insert lead1;
    DateTime obsoleteDate = Datetime.now().addMinutes(-15);
    Test.startTest();
    insert leadList;
    LeadDistributionBatch ldb = new LeadDistributionBatch();
    Database.executebatch(ldb, 5);
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
}

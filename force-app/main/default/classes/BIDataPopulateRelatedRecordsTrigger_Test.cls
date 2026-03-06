/**
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        -  02/02/2021
 * description - Added line 31: bid.ROE_Division__c = 'SMB Sales - US',
 * and an assertion below. This line will test the class BiDataCallFitScore.
 * --------------------------------------------------------------------------------------
 */
@isTest
private class BIDataPopulateRelatedRecordsTrigger_Test {
  @testSetup
  static void prepareData() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();

    Account acc = TestDataFactory.createAccount();
    insert acc;
    Contact cnt = TestDataFactory.createContact(acc, 'test@aaa.com');
    insert cnt;
    Lead ld = TestDataFactory.createLead();
    insert ld;
  }

  @isTest
  static void testUpdate() {
    List<BI_Data__c> bids = [SELECT Id, Base_Product__c FROM BI_Data__c];
    for (BI_Data__c bid : bids) {
      bid.Base_Product__c = '1';
      bid.SW_Behavioral_Rate__c = 3;
      bid.ROE_Division__c = 'SMB Sales - US';
    }
    Test.startTest();
    update bids;
    Test.stopTest();

    Account acc = [SELECT Id, Base_Product__c FROM Account LIMIT 1];
    Contact cnt = [SELECT Id, Base_Product__c FROM Contact LIMIT 1];
    Lead ld = [SELECT Id, Base_Product__c FROM Lead LIMIT 1];

    List<Fit_Score_Call_Log__c> fitScoreLog = new List<Fit_Score_Call_Log__c>(
      [
        SELECT Id
        FROM Fit_Score_Call_Log__c
      ]
    );
    System.assertNotEquals(
      0,
      fitScoreLog.size(),
      'No Fit score call log was found!'
    );

    // System.assertEquals('1', acc.Base_Product__c);
    // System.assertEquals('1', ld.Base_Product__c);
    // System.assertEquals('1', cnt.Base_Product__c);
  }

  /**
   * @author Itzik Winograd
   * @date 04/05/2021
   * @description: Set SW_Behavioral_Rate__c to 'C' on a Contact that is mql=false.
   * Also, set SW_Fit_Score__c to 2 on the related bi record.
   * @expected: MQL on the Contact will be true since C-2 should be true.
   */
  @isTest
  public static void testMQLforCGrade() {
    Contact cnt = [
      SELECT Id, SW_Fit_Score__c, Bi_Data__c
      FROM Contact
      WHERE MQL__c = FALSE
      LIMIT 1
    ];
    cnt.SW_Fit_Score__c = 'C';

    BI_Data__c bid = [
      SELECT Id, Base_Product__c
      FROM BI_Data__c
      WHERE Id = :cnt.Bi_Data__c
    ];
    bid.SW_Behavioral_Rate__c = 2;

    Test.startTest();
    update cnt;
    update bid;
    Test.stopTest();

    cnt = [
      SELECT Id, MQL__c, SW_Fit_Score__c, BI_Data__r.SW_Behavioral_Rate__c
      FROM Contact
      LIMIT 1
    ];
    System.assertEquals(
      true,
      cnt.MQL__c,
      'MQL on Contact is not true as expected: ' +
        cnt.MQL__c +
        ', ' +
        cnt.SW_Fit_Score__c +
        ', ' +
        cnt.Bi_Data__r.SW_Behavioral_Rate__c
    );
  }
}

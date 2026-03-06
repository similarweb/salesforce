/**
 * @author Itzik Winograd
 * @date 27/01/2021
 * @description Test class for MostRecentCadenceNameBatch
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public with sharing class MostRecentCadenceNameBatchTest {
  /**
   * @Desctiption: Create campaigns for
   * */
  @TestSetup
  static void makeDataForCadenceName() {
    Utils.CodeOff = true;
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();

    Lead tesLead = TestDataFactory.createLead();
    tesLead.Most_Recent_Cadence_Cadence_Name__c = 'Outbound Test';
    insert tesLead;

    Account acc = TestDataFactory.createAccount();
    Contact con = TestDataFactory.createContact(acc, 'test@tesData.com');
    con.Most_Recent_Cadence_Cadence_Name__c = 'Outbound Test';
    insert con;

    Campaign camp = CampaignUtils.getCampaigns(1)[0];
    camp.Name = 'Outbound Test';
    insert camp;
  }

  /**
   * @Desctiption: Run the batch job to move most recent cadence name to
   * @Expected: no value will be in "Most_recent..." field
   * */
  @isTest
  static void testDataCadensNameBatch() {
    MostRecentCadenceNameBatch job = new MostRecentCadenceNameBatch('Lead');
    Id batchJobId = Database.executeBatch(job, 100);

    job = new MostRecentCadenceNameBatch('Contact');
    Id batchJobId2 = Database.executeBatch(job, 100);
  }
}

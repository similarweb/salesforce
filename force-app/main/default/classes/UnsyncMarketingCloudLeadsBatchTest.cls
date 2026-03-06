/**
 * Created by zohar.sinay on 08/06/2023.
 */
@isTest
public with sharing class UnsyncMarketingCloudLeadsBatchTest {
  @TestSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;
  }

  static testMethod void testLeadBatch() {
    // Create test data
    List<Lead> leads = new List<Lead>();
    leads.add(
      new Lead(
        LastName = 'Test1',
        Company = 'TestCo1',
        Email = 'alon@sostupid.com',
        Status = 'Open - Not Contacted',
        Sync_to_Sfmc__c = true,
        Pro_User_Type__c = 'Demo',
        Manual_Unsync_SFMC__c = false,
        Employees_Min__c = 5,
        SW_Fit_Score__c = 'e'
      )
    );
    leads.add(
      new Lead(
        LastName = 'Test2',
        Company = 'TestCo2',
        Email = 'alon@sostupids.com',
        Status = 'Open - Not Contacted',
        Sync_to_Sfmc__c = true,
        Pro_User_Type__c = 'Demo',
        Manual_Unsync_SFMC__c = false,
        Employees_Min__c = 5,
        SW_Fit_Score__c = 'e'
      )
    );
    insert leads;

    // Set CreatedDate to a date in 2021
    DateTime createdDate = DateTime.newInstance(2021, 2, 1);
    Test.setCreatedDate(leads[0].Id, createdDate);
    Test.setCreatedDate(leads[1].Id, createdDate);

    // Convert the first Lead
    Database.LeadConvert lc = new Database.LeadConvert();
    lc.setLeadId(leads[0].Id);
    lc.setConvertedStatus('Qualified');
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    System.assert(lcr.isSuccess());

    // Execute the batch job
    Test.startTest();
    UnsyncMarketingCloudLeadsBatch leadBatch = new UnsyncMarketingCloudLeadsBatch();
    ID batchProcessId = Database.executeBatch(leadBatch, 1);
    Test.stopTest();

    // Assert that only the first Lead was updated
    List<Lead> updatedLeads = [
      SELECT Id, Manual_Unsync_SFMC__c
      FROM Lead
      WHERE Manual_Unsync_SFMC__c = TRUE
    ];
    System.assertEquals(
      1,
      updatedLeads.size(),
      'Incorrect number of Leads updated'
    );
    System.assertEquals(
      leads[1].Id,
      updatedLeads[0].Id,
      'Incorrect Lead was updated'
    );
  }
}

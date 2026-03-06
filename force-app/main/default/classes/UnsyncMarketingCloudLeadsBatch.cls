/**
 * Created by zohar.sinay on 08/06/2023.
 */

global class UnsyncMarketingCloudLeadsBatch implements Database.Batchable<sObject> {
  global UnsyncMarketingCloudLeadsBatch() {
    // We'll build the SOQL query in the constructor.
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query =
      'SELECT Id, Manual_Unsync_SFMC__c FROM Lead WHERE (CreatedDate > 2021-01-01T00:00:00Z AND CreatedDate < 2021-12-31T00:00:00Z AND Sync_to_Sfmc__c = true AND ' +
      'Manual_Unsync_SFMC__c = false AND IsConverted = false AND ' +
      '(Employees_Min__c < 10 OR SW_Fit_Score__c = \'e\' OR SW_Fit_Score__c = \'f\')) OR (CreatedDate < 2020-12-31T00:00:00Z AND Sync_to_Sfmc__c = true AND ' +
      'Manual_Unsync_SFMC__c = false AND IsConverted = true AND ' +
      '(Pro_User_Type__c != \'Admin\' OR Pro_User_Type__c != \'User\'))';

    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<sObject> scope) {
    List<Lead> leadsToUpdate = (List<Lead>) scope;

    // Iterate through the leads and update the Manual_Unsync_SFMC__c field
    for (Lead lead : leadsToUpdate) {
      lead.Manual_Unsync_SFMC__c = true;
    }

    // Perform the update
    Database.SaveResult[] srList = Database.update(leadsToUpdate, false);
    for (Database.SaveResult sr : srList) {
      if (!sr.isSuccess()) {
        // there were errors during the update operation, log them
        for (Database.Error err : sr.getErrors()) {
          System.debug('Errors: ' + err);
        }
      }
    }
  }

  global void finish(Database.BatchableContext BC) {
    // Any post-processing logic.
  }
}

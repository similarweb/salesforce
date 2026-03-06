public with sharing class FunelMonitorHandler {

    @TestVisible
    private static final String JOURNEY_DROPPED_OWNER_ID = '005b0000002iwIAAAY';
    @TestVisible
    private static final String JOURNEY_OLD_OWNER_ID = '005b0000002iwIAAAY';
    
    public void funelMonitorUpdateLogic(List<Lead> recordList,Map<Id,Lead> oldMap) {
        for (Lead lead_i : recordList) {
            Lead oldLead_i = oldMap.get(lead_i.Id);
            if (lead_i.New_Behavioral_Rate__c != oldLead_i.New_Behavioral_Rate__c) {
                lead_i.Behavioral_Rate_Counter__c = lead_i.Behavioral_Rate_Counter__c == null ? 1 : lead_i.Behavioral_Rate_Counter__c + 1;
                lead_i.Behavioral_Rate_Timestamp__c = Datetime.now();
                if (lead_i.First_Behavioral_Rate_Timestamp__c == null) {
                    lead_i.First_Behavioral_Rate_Timestamp__c = Datetime.now();
                }
            }
            if (lead_i.SW_Fit_Score__c != oldLead_i.SW_Fit_Score__c) {
                lead_i.Fit_Score_Counter__c = lead_i.Fit_Score_Counter__c == null ? 1 : lead_i.Fit_Score_Counter__c + 1;
                lead_i.SW_Fit_Score_Timestamp__c = Datetime.now();
            }
            if (lead_i.Business_Unit__c != oldLead_i.Business_Unit__c) {
                lead_i.Business_unit_timestamp__c = Datetime.now();
                lead_i.Business_unit_timestamp_del__c = Datetime.now();
            }
            if (lead_i.OwnerId != oldLead_i.OwnerId 
                && lead_i.OwnerId != JOURNEY_DROPPED_OWNER_ID
                && 
                    (
                        oldLead_i.OwnerId == JOURNEY_OLD_OWNER_ID
                        && lead_i.Journey_Completed_Timestamp__c == null
                    )
                ) 
            {
                lead_i.Journey_Completed_Timestamp__c = Datetime.now();
            } else if(lead_i.LeadSource != oldLead_i.LeadSource 
                      && String.IsBlank(oldLead_i.LeadSource)
                      && String.isBlank(lead_i.Original_Lead_Source__c)) 
            {
                lead_i.Original_Lead_Source_Last_Updated__c = Datetime.now();
                lead_i.Original_Lead_Source__c = lead_i.LeadSource;
            }
        }
    }

    public void funelMonitorInsertLogic(List<Lead> recordList) {
        for (Lead lead_i : recordList) {
            if (lead_i.LeadSource != '') {
                lead_i.Original_Lead_Source_Last_Updated__c = Datetime.now();
                lead_i.Original_Lead_Source__c = lead_i.LeadSource;
            }
        }
    }
}
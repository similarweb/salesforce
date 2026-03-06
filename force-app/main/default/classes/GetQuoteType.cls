public class GetQuoteType {
    @AuraEnabled
    public static Boolean getQType(String firstName) {
        
        Boolean result = false;

        /* zqu__Quote__c qType = [Select RecordType.Name From zqu__Quote__c where Id = :firstName]; */
        Zuora_Quote_Approval_Settings__c customSettingValue = Zuora_Quote_Approval_Settings__c.getOrgDefaults();
        
        if(customSettingValue.Enable_Approval_process_for_Quote__c == true){
            result = true;
        }
        
        return result;
    }
}
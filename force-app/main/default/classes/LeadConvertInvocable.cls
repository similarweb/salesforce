/**
 * Created by Alon.Shalev on 2/15/2024.
 */

public with sharing class LeadConvertInvocable {

    private static Id accountIdCreated;
    private static Id contactIdCreated;

    @InvocableMethod(label='Convert lead' description='Convert lead')
    public static List<LeadConvertOutput> convertLead(List<LeadConvertInput> leadConvertInputs) { // should be only one

        for (LeadConvertInput leadConvertInput : leadConvertInputs) {
            convertLead(leadConvertInput.AccountId , leadConvertInput.LeadId);
        }
        LeadConvertOutput output =  new LeadConvertOutput();
        output.AccountId = accountIdCreated;
        output.ContactId = contactIdCreated;
        return new List<LeadConvertOutput>{output};

    }
    private static void convertLead(String accountIdToConvertTo,String leadId){
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        LeadStatus convertedStatus = getConvertLeadStatus();
        lc.setConvertedStatus(convertedStatus.MasterLabel);
        if(String.isNotBlank(accountIdToConvertTo)){
            lc.setAccountId(accountIdToConvertTo);
        }

        lc.setDoNotCreateOpportunity(true);
        lc.setSendNotificationEmail(false);
        List<Database.LeadConvertResult> results = Database.convertLead(new List<Database.LeadConvert>{lc});
        Database.LeadConvertResult lcr = results[0];
        if (!lcr.isSuccess()) {
            throw new LeadConvertInvocableException('Lead convertation failed');
        }

        accountIdCreated = lcr.getAccountId();
        contactIdCreated = lcr.getContactId();

    }

    private static LeadStatus getConvertLeadStatus(){


        LeadStatus convertStatus = null;
        CS_LeadConvert__c leadConvertSettings = CS_LeadConvert__c.getinstance('LeadConvertStatus');
        if(leadConvertSettings == null){
            convertStatus = [SELECT Id, MasterLabel
                            FROM LeadStatus
                            WHERE IsConverted = TRUE LIMIT 1];

        }else{
            convertStatus = [SELECT Id, MasterLabel
                            FROM LeadStatus
                            WHERE IsConverted = TRUE
                            AND MasterLabel =: leadConvertSettings.value__c LIMIT 1];
        }

        return convertStatus;
    }


    public class LeadConvertInput {
        @InvocableVariable(required=true)
        public Id LeadId;
        @InvocableVariable
        public Id AccountId;
    }

    public class LeadConvertOutput{
        @InvocableVariable
        public Id AccountId;
        @InvocableVariable
        public Id ContactId;
    }

    public class LeadConvertInvocableException extends Exception{}

}
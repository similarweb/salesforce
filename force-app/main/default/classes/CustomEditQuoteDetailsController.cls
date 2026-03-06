public without sharing class CustomEditQuoteDetailsController {
    public zqu__Quote__c thisQuote {get; set;}
    public Boolean isApprovalProcessEnabled {get; set;}
    public Boolean isAdminOrBilling {get; set;}
    public Boolean isLegalProfile {get; set;}
    public String quoteRecordTypeName {get; set;}
    public String specialPaymentTermsDetails {get;set;}
    public String specialFrequencyReason {get;set;}
    public Boolean isTrialQuote {get;set;}

    public String quotePaymentTerm {get;set;}
    public String quoteBillingAccountId {get;set;}
    public String currentPaymentTerm {get;set;}
    public Boolean isRenewalByClientConfirmation {get;set;}
    
    public CustomEditQuoteDetailsController(ApexPages.StandardController standardController) {
        thisQuote = (zqu__Quote__c)standardController.getRecord();
        zqu__Quote__c fullQuoteObject = zqu.Quote.getInstance(thisQuote.Id).getSObject();
        currentPaymentTerm = fullQuoteObject.zqu__PaymentTerm__c;
        quoteRecordTypeName = Utility.getDevNameForRecordTypeID(thisQuote.getSObjectType(), thisQuote.RecordTypeId);
        isApprovalProcessEnabled = Zuora_Quote_Approval_Settings__c.getOrgDefaults().Enable_Approval_process_for_Quote__c;
        isRenewalByClientConfirmation = [SELECT Renewal_by_client_confirmation__c FROM zqu__Quote__c WHERE Id = :thisQuote.Id].Renewal_by_client_confirmation__c;
        System.debug(thisQuote);
        Profile currUserProfile = [
            SELECT Id, Name 
            FROM Profile 
            WHERE Id = :UserInfo.getProfileId()
        ];
        isAdminOrBilling = currUserProfile != null && 
                            (currUserProfile.Name.equalsIgnoreCase('System Administrator') 
                            || currUserProfile.Name.equalsIgnoreCase('SW Billing')
                            || currUserProfile.Name.equalsIgnoreCase('SW Billing Extended'));

        isLegalProfile =    currUserProfile != null && 
                            (currUserProfile.Name.equalsIgnoreCase('System Administrator') 
                            || currUserProfile.Name.equalsIgnoreCase('SW Billing')
                            || currUserProfile.Name.equalsIgnoreCase('SW Legal')
							|| currUserProfile.Name.equalsIgnoreCase('SW Billing Extended'));
        specialPaymentTermsDetails = thisQuote.Special_Payment_Terms_Details__c;
        specialFrequencyReason = thisQuote.Special_Frequency_Reason__c;
        isTrialQuote = thisQuote.Trial_Quote__c;
        /* System.debug(zqu.QuoteDetailController.isEditMode); */

        quoteBillingAccountId = thisQuote.zqu__ZuoraAccountID__c;
        Zuora__CustomerAccount__c customerAccount = getRelatedBillingAccount(quoteBillingAccountId);
        quotePaymentTerm = customerAccount?.Zuora__PaymentTerm__c;
    }

    @RemoteAction
    public static void correctProductsIfPackageMgration(String quoteId, String migrationToNewSol) {
        
        if(String.isNotBlank(quoteId)){
            Id amendmentRecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName().get('Amendment').getRecordTypeId();
            zqu__Quote__c thisQuote = (zqu__Quote__c)zqu.Quote.getInstance(quoteId).getSObject();
            if (thisQuote.RecordTypeId == amendmentRecordTypeId && migrationToNewSol == 'Yes') {
                ZuoraQuoteMetricsManipulationHelper.removeProductsFromOldPackage(quoteId);
            }
        } 
    }

    private static Zuora__CustomerAccount__c getRelatedBillingAccount(String billingAccountId){
        if(String.isBlank(billingAccountId)){
            return null;
        }
        List <Zuora__CustomerAccount__c> relatedBillingAccountList = [SELECT Id
                                                                       , Name
                                                                       , Zuora__DefaultPaymentMethod__c
                                                                       , Zuora__PaymentTerm__c
                                                                       , (SELECT Id, Zuora__PaymentMethod__c FROM Zuora__Payments__r Order By CreatedDate DESC LIMIT 1)
                                                                    FROM Zuora__CustomerAccount__c
                                                                   WHERE Zuora__External_Id__c = :billingAccountId
        ];
        if (!relatedBillingAccountList.isEmpty()) {
            return relatedBillingAccountList[0];
        } 
        return null;
    }
}
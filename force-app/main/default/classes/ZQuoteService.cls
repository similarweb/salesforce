/**
 * Description 		:	Service class for zqu__Quote__c object 						
 * Created By 		:	Dmitry Trufanov from Synebo Jan'20
 */
public with sharing class ZQuoteService {

    public static final String API_HITS_ADDON_POSTFIX = 'API Hits';
    public static final String HISTORICAL_DATA_ADDON_PREFIX = 'Last';
    public static final String HISTORICAL_DATA_ADDON_POSTFIX = 'Months of Historical Data';
    public static final String HISTORICAL_DATA_ONAPI_ADDON_POSTFIX = 'Months of Historical Data on API';
    public static final String WEBSITE_RESULT_POSTFIX = 'Website Table Results';
    public static final String WW_ONLY_HISTORICAL_DATA_ADDON_PREFIX = 'PRO Permissions: Worldwide view only and Last';
    public static final String LITE_ACCESS_DATA_ADDON_PREFIX = 'Lite Access';
    public static final String WW_HISTORICAL_DATA_ADDON_POSTFIX = 'Months of Historical Data only';
    public static final String ALL_CFS_WITH_WW_ON_API_FULLNAME = 'ALL available CF\'s including WW on API';
    public static final String ALL_CFS_WITH_WW_ON_API_POSTFIX= 'including WW on API';

    public ZQuoteService() {
    }

    /**
     * Retrieve records from Base_Product_Contract__c custom setting
     * 
     * @return list of PicklistValue objects - wrapper for 
     *         Base_Product_Contract__c record which contains Label
     *         and Value fields.
     */
    public List<PicklistValue> retreiveBaseProductContractValues() {
        return BaseProductMetadataManipulationHelper.retreiveBaseProductContractValues(); 
    }
    
    /**
     * Retrieve records from Base_Product_Controlling_Obj__c custom setting
     * 
     * @return list of PicklistValue objects - wrapper for 
     *         Base_Product_Contract__c record which contains Label
     *         and Value fields.
     */
    public List<PicklistValue> retreiveBaseProductPicklistValues() {                
        return BaseProductMetadataManipulationHelper.retreiveBaseProductPicklistValues(); 
    }
    
    /**
     * Add values to Base product picklist - to Base_Product_Controlling_Obj__c custom setting
     * and to Base product picklist field
     * 
     * @param  fullNameListRaw string with picklist values separated by "\n" character.
     * @return                 return errors which occured during work of SF Metadata API, which
     *                         inserted new value into picklist field . If no errors occured - 
     *                         return blank string.
     */
    public String addBaseProductPicklistValues(String fullNameListRaw) {  
        return BaseProductMetadataManipulationHelper.addBaseProductPicklistValues(fullNameListRaw);
    }

    /**
     * Delete values from Base product picklist - from Base_Product_Controlling_Obj__c custom
     * setting and from Base product picklist field
     * 
     * @param  fullNameToDelete api name of picklist value which need to be deleted.
     * @return                  return errors which occured during work of SF Metadata API, which
     *                          inserted new value into picklist field . If no errors occured - 
     *                          return blank string.
     */
    public String deleteBaseProductPicklistValues(String fullNameToDelete) {
        return BaseProductMetadataManipulationHelper.deleteBaseProductPicklistValues(fullNameToDelete);
    }

    /**
     * Edit label of specific value from Base product picklist - in the Base product field
     * itself and in Base_Product_Controlling_Obj__c custom setting
     * 
     * @param  fullName api name of picklist value which need to be edited.
     * @param  label    new label of Base Product picklist value.
     * @return          return errors which occured during work of SF Metadata API, which
     *                  edited picklist value. If no errors occured - return blank string.
     */
    public String editBaseProductPicklistValues(String fullName, String label) {
        return BaseProductMetadataManipulationHelper.editBaseProductPicklistValues(fullName, label);
    }

    /**
     * Retrieve records from Base_Product_Dependent__c custom setting
     * where Controlling__c field equals to a specific value from a param.
     * 
     * @param  controllingFieldValue value which is used to filter Base_Product_Dependent__c
     *                               records which will be returned.
     * @return                       list of PicklistValue objects - wrapper for 
     *                               Base_Product_Contract__c record which contains Label
     *                               and Value fields.
     */
    public List<PicklistValue> retreiveWorldListPicklistValuesForDependentValue(String controllingFieldValue) {
        return BaseProductMetadataManipulationHelper.retreiveWorldListPicklistValuesForDependentValue(controllingFieldValue);
    }

    /**
     * Add values to Word list picklist - to Base_Product_Contract__c custom setting
     * and to Word list picklist field.
     * 
     * @param  fullNameListRaw string with picklist values separated by "\n" character.
     * @return                 return errors which occured during work of SF Metadata API, which
     *                         inserted new value into picklist field . If no errors occured - 
     *                         return blank string.
     */
    public String addWorldListPicklistValue(String fullNameListRaw) {           
        return BaseProductMetadataManipulationHelper.addWorldListPicklistValue(fullNameListRaw);
    }

    /**
     * Make certain values of Word List picklist dependant from the value of 
     * Base product picklist
     * 
     * @param  controllingFieldValue value which is used to set Dependent__c
     *                               value of Base_Product_Dependent__c
     *                               records which will be created.
     * @param  fullNameListRaw       string with picklist values separated by "\n" character.
     * @return                       return errors which occured during work of SF Metadata API, which
     *                               inserted new value into picklist field. If no errors occured - 
     *                               return blank string.
     */
    public String addDependencyWorldListPicklistValue(String controllingFieldValue,String fullNameListRaw) {
        return BaseProductMetadataManipulationHelper.addDependencyWorldListPicklistValue(controllingFieldValue, fullNameListRaw);
    }
    

    /**
     * Delete value of Word List picklist
     *  
     * @param  fullNameToDelete api name of value from Word List picklist
     * @return                  return errors which occured during work of SF Metadata API, which
     *                          deleted value from picklist field. If no errors occured - 
     *                          return blank string.
     */
    public String deleteWorldListPicklistValue(String fullNameToDelete) {
        return BaseProductMetadataManipulationHelper.deleteWorldListPicklistValue(fullNameToDelete);
    }

    /**
     * Edit label of specific value from Word List picklist - in the Word List field
     * itself and in Base_Product_Contract__c custom setting
     * 
     * @param  fullName api name of picklist value which need to be edited.
     * @param  label    new label of Word lsit picklist value.
     * @return          return errors which occured during work of SF Metadata API, which
     *                  edited picklist value. If no errors occured - return blank string.
     */
    public String editWorldListPicklistValues(String fullName, String label) {
        return BaseProductMetadataManipulationHelper.editWorldListPicklistValues(fullName, label);
    }

     /**
      * Retrieve records of Base_Product_Default_Addon__c custom settings, filtered by
      * Controlling__c field
      * 
      * @param  controllingName value of Controlling__c field which is used to filter.
      *                         Base_Product_Default_Addon__c records which will be returned.
      * @return                 list of Addons names.
     */
    public List<String> retrieveDefaultAddonsForBaseProduct(String controllingName) {
        return BaseProductMetadataManipulationHelper.retrieveDefaultAddonsForBaseProduct(controllingName);
    }

    public Map<String,List<String>> retrieveBaseProductsRestrictOptions() {
        return BaseProductMetadataManipulationHelper.retrieveBaseProductsRestrictOptions();
    }


    
    /**
     * Retrieve records of Base_Product_Dynamic_Addon__c custom settings, filtered by
     * Controlling__c field.
     * 
     * @param  controllingName value of Controlling__c field which is used to filter
     *                         Base_Product_Dynamic_Addon__c records which will be returned.
     * @return                 list of Addons names
     */
    public List<String> retrieveDynamicAddonsForBaseProduct(String controllingName) { 
        return BaseProductMetadataManipulationHelper.retrieveDynamicAddonsForBaseProduct(controllingName);
    }

    /**
     * Retrieve record of Base_Product_Num_of_Users__c custom settings, with certain
     * value in Controlling__c field.
     * 
     * @param  controllingName value of Controlling__c field which is used to get specific
     *                         Base_Product_Num_of_Users__c record.
     * @return                 list of Addons names
     */
    public Integer retrieveDefaultNumberOfUsersForBaseProduct(String controllingName) { 
        return BaseProductMetadataManipulationHelper.retrieveDefaultNumberOfUsersForBaseProduct(controllingName);
    }

    /**
     * Add records of Base_Product_Default_Addon__c custom setting with specific Controlling__c
     * value, and delete all current Base_Product_Default_Addon__c record with that Controlling__c
     * value.
     * 
     * @param  fullNameListRaw string with picklist values separated by "\n" character.
     * @param  controllingName value of Controlling__c field.
     */
    public void setDefaultAddonsForBaseProduct(String fullNameListRaw, String controllingName) {
        BaseProductMetadataManipulationHelper.setDefaultAddonsForBaseProduct(fullNameListRaw, controllingName);
    }

    /**
     * Add records of Base_Product_Dynamic_Addon__c custom setting with specific Controlling__c
     * value, and delete all current Base_Product_Dynamic_Addon__c record with that Controlling__c
     * value.
     * @param  fullNameListRaw string with picklist values separated by "\n" character.
     * @param  controllingName value of Controlling__c field.
     */
    public void setDynamicAddonsForBaseProduct(String fullNameListRaw, String controllingName) {
        BaseProductMetadataManipulationHelper.setDynamicAddonsForBaseProduct(fullNameListRaw, controllingName);
     }

    /**
     * Upsert record of Base_Product_Num_of_Users__c custom setting with specific Controlling__c
     * value.
     * 
     * @param  numberOfUsers   value of Number_of_User__c field
     * @param  controllingName value of Controlling__c field
     */
    public void setDefaultNumberOfUsersForBaseProduct(Integer numberOfUsers, String controllingName) {
        BaseProductMetadataManipulationHelper.setDefaultNumberOfUsersForBaseProduct(numberOfUsers, controllingName);
    }

    /**
     * Send a data of zqu__Quote__c record to ROI calculation webservice
     * @param  quoteId Id of zqu__Quote__c record
     * @return eturn Boolean value - is call successfull or not
     */
    public Boolean generateProposals(String quoteId) {
        return ZuoraQuoteProposalGenerationHelper.generateProposals(quoteId);
    }

    public String generatePreviewContract(String quoteId,Boolean isValidate){  
        return ZuoraContractGenerationHelper.generatePreviewContract(quoteId,isValidate);
    }

    public String obtainAndSaveContract(String quoteId, String fileUrl, String modeRaw, String buttonMode, Boolean isFinalize){
        return ZuoraContractGenerationHelper.obtainAndSaveContract(quoteId,fileUrl,modeRaw, buttonMode, isFinalize);
    }

    public String submitQuoteForApproval(String quoteId, String approvalRequestComment, String sourceName) {
        return ZuoraQuoteApprovalProcessHelper.submitQuoteForApproval(quoteId, approvalRequestComment, sourceName);
    }

    public zqu__Quote__c setQuoteAsReadyForBilling(String quoteId, Boolean autoFinalizeQuote){
        return ZuoraQuoteApprovalProcessHelper.setQuoteAsReadyForBilling(quoteId, autoFinalizeQuote);
    }

    public void recallQuote(String quoteId){
        ZuoraQuoteApprovalProcessHelper.recallQuote(quoteId);
    }

    public static List<zqu__Quote__c> finalizeQuote(List<String> quoteIdList) {
        List<zqu__Quote__c> quoteList = [SELECT Id
                                       , Is_Finalized__c
                                       , RecordTypeId
                                       , zqu__QuoteTemplate__c
                                       , zqu__PaymentMethod__c
                                       , zqu__AutoRenew__c
                                       , zqu__SoldToContact__c
                                       , subsidiary__c
                                       , Tax_Region__c
                                       , zqu__Certificate_ID__c
                                       , zqu__TermStartDate__c
                                       , zqu__BillCycleDay__c
                                       , zqu__SubscriptionTermStartDate__c
                                       , Is_Discount_10__c
                                       , Is_Discount_20__c
                                       , Is_Discount_40__c
                                       , Is_Product_to_App__c
                                       , Is_No_Annual__c
                                       , zqu__Account__c
                                       , zqu__ZuoraAccountID__c
                                       , account_users__c
                                       , quote_users__c
                                       , Payment_Frequency__c
                                       , zqu__InvoiceTemplate__c
                                       , zqu__CommunicationProfile__c
                                       , zqu__BillingBatch__c
                                       , zqu__opportunity__c
                                       , zqu__SubscriptionType__c
                                  FROM zqu__Quote__c
                                  WHERE Id IN :quoteIdList
        ];
        return ZuoraQuoteFinalizeHelper.finalizeQuote(quoteList);
    }

    public static List<zqu__Quote__c> finalizeQuote(List<zqu__Quote__c> quoteList) {
        return ZuoraQuoteFinalizeHelper.finalizeQuote(quoteList);
    }
    
    /**
     * Sending document to DocuSign using generateDocuSign
     * @param  quoteId Id of zqu__Quote__c record
     * @return return Response object with success flag true and legalRequestExist true
     */
    public static Response sendToDocuSign(String quoteId){
        return ZuoraContractGenerationHelper.sendToDocuSign(quoteId);
    }

    /**
     * Checks legal request existing
     * @param  quoteId Id of zqu__Quote__c record
     * @return return Response object with success flag true and legalRequestExist true
     */
    public static Response checkIfLegalRequestExist(String quoteId){
        return ZuoraContractGenerationHelper.checkIfLegalRequestExist(quoteId);
    }

    /**
     * @description Check for other Quotes under the Quote's subscription
     * @param quoteId - Id of Quote which is submitted
     * @return Response - return Response object with success flag true and content value true if there is any other Amendment Quote that fits the condition 
     */
    public static Response validateSubscription(String quoteId) {
        return ZuoraQuoteFinalizeHelper.validateSubscription(quoteId);
    }
    /*
     * Checks Advisory Services requests existing
     * @param  quoteId Id of zqu__Quote__c record
     * @return return Response object with success flag equals to value of AS_DS__c and needToProcess true or false
     */
    public static Response checkForASRequests(String quoteId, String buttonName){
        return ZuoraContractGenerationHelper.checkForASRequests(quoteId, buttonName);
    }

    private class NoParamException extends Exception {  }
    private class InvalidAddonPostfixException extends Exception {  }
    private class InvalidSettingException extends Exception {  }
}
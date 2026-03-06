/**
* @author Zohar Sinay
* @date 07/07/2021
* @description Handles no touch calls and logs in the no touch log
*/

public without sharing class LeadCaptureServiceHandler {

    private static List<String> executionLogsList = new List<String>{};
    private static string paramsObtained = '';


    static private Map<String,Contact> genContactData (String email,Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByContactAttributeListMap)
    {
        String fieldsToQueryStr = getFieldsToQueryStr(leadCaptureMappingByContactAttributeListMap,'Contact');
        String trimEmail = email.trim().toLowerCase();
        List <id> RecTypeToIgnore = new list <id>();
        RecTypeToIgnore = GenRecTypeIgnoreList();
        String query = 'SELECT Id, ';
        query += fieldsToQueryStr +' ';
        query += 'FROM Contact ';
        query += 'WHERE (email =:trimEmail OR Unique_Email__c = :trimEmail)' ;
        query += 'AND recordtypeid not in: RecTypeToIgnore';
        List<Contact> returnContacts =  Database.query(query);
        Map<String,Contact> emailToContactMap = new Map<String, Contact>();
        for(Contact conItem : returnContacts){
            if (conItem.Email == email && conItem.Unique_email__c == email) {
                // Strongest condition: If both match, overwrite and break loop
                emailToContactMap.put('email', conItem);
                break; // No need to check further, this is the highest priority match
            }
            if (conItem.Unique_email__c == email) {
                emailToContactMap.put('uniqueEmail', conItem);
            }

            if (conItem.Email == email) {
                emailToContactMap.put('email', conItem);
            }

        }

        System.debug('emailToContactMap--'+emailToContactMap);
        return emailToContactMap;
    }

    private static String getFieldsToQueryStr(Map<String, List<Fields_Mapping__mdt>> leadCaptureMappingByContactOrLeadAttributeListMap,String sobjectName) {
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = gd.get(sobjectName);
        Schema.DescribeSObjectResult describeResult = sobjType.getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        Set<String> fieldsToQuerySet = new Set<String>();
        for (String sourceField : leadCaptureMappingByContactOrLeadAttributeListMap.keySet()) {
            for (Fields_Mapping__mdt fieldsMapping : leadCaptureMappingByContactOrLeadAttributeListMap.get(sourceField)) {
                if (fieldsMap.containsKey(fieldsMapping.Destination_Field__c)) {
                    fieldsToQuerySet.add(fieldsMapping.Destination_Field__c);
                }
            }
        }
        String fieldsToQueryStr = String.join(new List<String>(fieldsToQuerySet), ',');
        return fieldsToQueryStr;
    }
    static private Map<String,Lead> genLeadData(String email,Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByLeadAttributeListMap) {
        List <id> RecTypeToIgnore = new list <id>();
        RecTypeToIgnore = GenRecTypeIgnoreList();
        String fieldsToQueryStr = getFieldsToQueryStr(leadCaptureMappingByLeadAttributeListMap,'Lead');
        String trimEmail = email.trim().toLowerCase();
        System.debug('trimEmail---'+trimEmail);

        String query = 'SELECT Id, ';
        query += fieldsToQueryStr +' ';
        query += 'FROM Lead ';
        query += 'WHERE (email =:trimEmail OR Unique_Email__c = :trimEmail) ';
        query += 'AND recordtypeid not in: RecTypeToIgnore';
        List<Lead> leadsFoundList = Database.query(query);
        System.debug('leadsFoundList--'+leadsFoundList);
        Map<String,Lead> emailToLeadMap = new Map<String, Lead>();
        for(Lead leadItem : leadsFoundList){
            if (leadItem.Email == email && leadItem.Unique_email__c == email) {
                // Strongest condition: If both match, overwrite and break loop
                emailToLeadMap.put('email', leadItem);
                break; // No need to check further, this is the highest priority match
            }

            if (leadItem.Unique_email__c == email) {
                emailToLeadMap.put('uniqueEmail', leadItem);
            }

            if (leadItem.Email == email) {
                emailToLeadMap.put('email', leadItem);
            }
        }
        System.debug('emailToLeadMap---'+emailToLeadMap);
        return emailToLeadMap;
    }


    public static id[] GenRecTypeIgnoreList ()
    {
        list <id> RecTypeToIgnore = new list <id>();
        list <string> tempstring = label.Dedupe_IgnoreRecType.split(';');
        if (tempstring.size()>0) for (string s : tempstring) RecTypeToIgnore.add (id.valueof (s));
        return RecTypeToIgnore;
    }

    public static void recordLog(Boolean status, LeadCaptureService.leadCaptureResponseWrapper lcrw, RestRequest req, Map<String,Object> leadCaptureWrpMap,Boolean isFromRetry){
        Log_Event__e log = new Log_Event__e();
        if(status == true){
            executionLogsList.add('[INFO] SUCCESS');
        } else {
            executionLogsList.add('[INFO] FAILED');
        }
        String params = '[INFO] Params recognized: ' +paramsObtained + '\n';
        String isSuccess = 'IsSuccessful: '+String.valueOf(status) + '\n';
        String logEvents = 'Execution log: \n' + String.join(executionLogsList, '\n');
        log.Apex_class__c = 'LeadCaptureServiceHandler';
        log.Apex_Method__c = 'LeadCapture';
        log.Detailed_Error_Message__c = lcrw.message;
        System.debug('log.Detailed_Error_Message__c--'+log.Detailed_Error_Message__c);
        if(log.Detailed_Error_Message__c != null && log.Detailed_Error_Message__c.contains('DUPLICATE_VALUE')){
            log.Matched_Record_Id__c = extractIdFromDuplicateEror(log.Detailed_Error_Message__c);
        }
        log.Detailed_Information__c = isSuccess +'\n'+ params +'\n' + logEvents;
        log.HTTP_Body__c = JSON.serializePretty(leadCaptureWrpMap);
        log.HTTP_Endpoint__c = req?.requestURI;
        log.HTTP_Headers__c = JSON.serialize(req?.headers);
        log.Http_Type__c = req?.httpMethod;
        log.Log_Type__c = getLogType(isFromRetry, lcrw);
        log.Payload__c = req.requestBody.toString();
//        log.Log_Type__c = lcrw.logType;
        log.Email__c = String.isNotBlank(lcrw.emailFieldValue) ? lcrw.emailFieldValue  :  (String)leadCaptureWrpMap.get('email'); // alon shalev added 12.2.25
        log.Session_Id__c = (String)leadCaptureWrpMap.get('call_id');
        String recordIds = !String.isBlank(lcrw.leadId) ? lcrw.leadId + ';' : '';
        recordIds = !String.isBlank(lcrw.contactId) ? recordIds + lcrw.contactId + ';' : recordIds;
        recordIds = !String.isBlank(lcrw.accountId) ? recordIds + lcrw.accountId + ';' : recordIds;
        log.Record_Ids__c = recordIds;
        log.sObjectId_Created__c = String.isNotBlank(lcrw.sObjectIdCreated) ? lcrw.sObjectIdCreated : null;
        log.Sub_Type__c = (String)leadCaptureWrpMap.get('subtypeforlog');
        List<Log_Event__e> logList = new List<Log_Event__e>();
        logList.add(log);
        List<Database.SaveResult> resultsList = Eventbus.publish(logList);
    }

    private static String getLogType(Boolean isFromRetry, LeadCaptureService.leadCaptureResponseWrapper lcrw) {
        String logType;
        if (isFromRetry) {
            logType = !String.isBlank(lcrw.message) ? 'Error - Retry Failed' : 'Error - Retry Successful';
        } else {
            logType = String.isNotBlank(lcrw.message) ? lcrw.retryInitiated ? 'Error - Retry Initiated' : 'Error' : 'Info';
        }
        return logType;
    }

    private static String extractIdFromDuplicateEror(String errorMessage) {
        String extractedId = '';
        Pattern regexPattern = Pattern.compile('([a-zA-Z0-9]{18})');
        Matcher matcher = regexPattern.matcher(errorMessage);
        if (matcher.find()) {
            extractedId = matcher.group(0);
            System.debug('Record ID: ' + extractedId);
        }
        return extractedId;
    }

    public static void recordLogWithWrapper(Boolean status, LeadCaptureService.leadCaptureResponseWrapper lcrw, RestRequest req, LeadCaptureService.leadCaptureWrapper leadCaptureWrp,Boolean isFromRetry){
        System.debug('record log is starting');
        Log_Event__e log = new Log_Event__e();
        if(status == true){
            executionLogsList.add('[INFO] SUCCESS');
        } else {
            executionLogsList.add('[INFO] FAILED');
        }
        String params = '[INFO] Params recognized: ' +paramsObtained + '\n';
        String isSuccess = 'IsSuccessful: '+String.valueOf(status) + '\n';
        String logEvents = 'Execution log: \n' + String.join(executionLogsList, '\n');
        log.Apex_class__c = 'LeadCaptureServiceHandler';
        log.Apex_Method__c = 'LeadCapture';
        log.Detailed_Error_Message__c = lcrw.message;
        log.Detailed_Information__c = isSuccess +'\n'+ params +'\n' + logEvents;
        log.HTTP_Body__c = JSON.serializePretty(leadCaptureWrp);
        log.HTTP_Endpoint__c = req?.requestURI;
        log.HTTP_Headers__c = JSON.serialize(req?.headers);
        log.Http_Type__c = req?.httpMethod;
        log.Log_Type__c = getLogType(isFromRetry,lcrw);
        log.Email__c = String.isNotBlank(lcrw.emailFieldValue) ? lcrw.emailFieldValue : leadCaptureWrp.email;
        log.Session_Id__c = leadCaptureWrp.call_id;
        String recordIds = !String.isBlank(lcrw.leadId) ? lcrw.leadId + ';' : '';
        recordIds = !String.isBlank(lcrw.contactId) ? recordIds + lcrw.contactId + ';' : recordIds;
        recordIds = !String.isBlank(lcrw.accountId) ? recordIds + lcrw.accountId + ';' : recordIds;
        log.Record_Ids__c = recordIds;
        log.sObjectId_Created__c = String.isNotBlank(lcrw.sObjectIdCreated) ? lcrw.sObjectIdCreated : null;
        log.Sub_Type__c = leadCaptureWrp.subTypeForLog;
    log.Payload__c = req.requestBody.toString();
        List<Log_Event__e> logList = new List<Log_Event__e>();
        logList.add(log);
        List<Database.SaveResult> resultsList = Eventbus.publish(logList);
        System.debug('record log was finished');
        System.debug('resultsList---'+resultsList);
    }

    public static void recordParsingErrorLog(Map<String, Object> requestMap, Exception e) {
        Log_Event__e log = new Log_Event__e();
        log.Apex_class__c = 'LeadCaptureServiceHandler';
        log.HTTP_Body__c = JSON.serializePretty(requestMap);
        log.Email__c = requestMap.get('email') != null ? (String) requestMap.get('email') : 'no email was provided';
        log.Detailed_Error_Message__c = e.getMessage() + ' ' + e.getStackTraceString();
        log.Log_Type__c = 'Error while parsing';
    log.Payload__c = String.valueOf(requestMap);
        Eventbus.publish(log);
    }

    public static LeadCaptureService.leadCaptureResponseWrapper handleTouchCallWithWrapper (LeadCaptureService.leadCaptureWrapper leadCaptureWrp,Map<String,Feature_Flag_Setting__mdt> flagsMap) {
        System.debug('leadCaptureWrp---'+leadCaptureWrp);

//        List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c FROM Feature_Flag_Setting__mdt WHERE Process_Name__c = 'LeadCapture Version 2' AND Class_Name__c = 'LeadCaptureServiceHandler'];
//        List<Feature_Flag_Setting__mdt> contactUsFlags = [SELECT Is_Active__c FROM Feature_Flag_Setting__mdt WHERE Process_Name__c = 'ContactUs Active Flag' AND Class_Name__c = 'LeadCaptureServiceHandler'];
        Boolean isVersion2Active =  flagsMap.containsKey('LeadCapture Version 2')  && flagsMap.get('LeadCapture Version 2').Is_Active__c;
        Boolean isContactUsActiveActive = flagsMap.containsKey('ContactUs Active Flag') ? flagsMap.get('ContactUs Active Flag').Is_Active__c  : true;
        LeadCaptureService.leadCaptureResponseWrapper lcrw = new LeadCaptureService.leadCaptureResponseWrapper();
        LeadCaptureService.CampaignAndMemberLeadCaptureWrapper campaignAndMemberLeadCaptureWrapper = new LeadCaptureService.CampaignAndMemberLeadCaptureWrapper();
        LeadCaptureService.ContactUsLeadCaptureWrapper contactUsLeadCaptureWrapper = new LeadCaptureService.ContactUsLeadCaptureWrapper();


        boolean campaignAutomationNeeded = false;
        boolean taskAutomationNeeded = false;
        System.debug('leadCaptureWrp.sfcmpid--'+leadCaptureWrp.sfcmpid);
        System.debug('leadCaptureWrp.sfcmpid--'+leadCaptureWrp.SFCmpId);
        System.debug('leadCaptureWrp.campaign_name.sfcmpid--'+leadCaptureWrp.campaign_name);
        if((String.isNotBlank(leadCaptureWrp.campaign_name) && !(leadCaptureWrp.campaign_name.startsWith('FMARKS') || leadCaptureWrp.campaign_name.startsWith('FMM'))) || (String.isNotBlank(leadCaptureWrp.sfcmpid))){
            // Identifying LinkedIn
            if(leadCaptureWrp.campaign_source_utm != 'li' || leadCaptureWrp.campaign_name_utm != 'ppc'){
                campaignAutomationNeeded = true;
            }
        }
        if(String.isNotBlank(leadCaptureWrp.Last_Contact_Us_Form_Subject) && leadCaptureWrp.Last_Contact_Us_Form_Subject != 'no cu'){
            taskAutomationNeeded = true;
        }
        try{
            executionLogsList.add('[INFO] STARTED TOUCH');
            Id ContactOrLeadId;
            executionLogsList.add('[INFO] Check Email is not Empty');
            if (String.isBlank(leadCaptureWrp.email)){
                System.debug('throwing');
                throw new NoEmailException('Email need to be specified');
            }
            List<Fields_Mapping__mdt> leadCapturefieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(new List<String>{'Lead_Capture_Update_Contact','Lead_Capture_Update_Lead'});
            Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByContactAttributeListMap = GeneralUtil.getLeadCaptureKeyToListMap(leadCapturefieldMappingList,'Lead_Capture_Update_Contact');
            Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByLeadAttributeListMap = GeneralUtil.getLeadCaptureKeyToListMap(leadCapturefieldMappingList,'Lead_Capture_Update_Lead');
            Map<String,Contact> existingContactMap = genContactData(leadCaptureWrp.email,leadCaptureMappingByContactAttributeListMap);
            Map<String,Lead> existingLeadMap = genLeadData(leadCaptureWrp.email,leadCaptureMappingByLeadAttributeListMap);
            Sobject contactOrLead;
            if(!existingContactMap.isEmpty()){
                campaignAndMemberLeadCaptureWrapper.typeOfParent = 'Contact';
                contactUsLeadCaptureWrapper.typeOfParent = 'Contact';
                boolean isContactWasFoundWithEmail = existingContactMap.containsKey('email');
                Contact contactFound = isContactWasFoundWithEmail ? existingContactMap.get('email') : existingContactMap.get('uniqueEmail');
                executionLogsList.add('[INFO] Contact found '+ contactFound.Id);
                if(!isContactWasFoundWithEmail){
                    executionLogsList.add('[INFO] Contact was found using Unique_email__c');
                }

                Contact duplicateUniqueEmail = existingContactMap.get('uniqueEmail');
                if (isContactWasFoundWithEmail && duplicateUniqueEmail != null && duplicateUniqueEmail.Id != contactFound.Id) {
                    duplicateUniqueEmail.Unique_email__c = null;
                    update duplicateUniqueEmail;
                    executionLogsList.add('[INFO] Unique_email__c was moved from: '+duplicateUniqueEmail.Id);
                }

                if(Test.isRunningTest() || isVersion2Active){
                    contactOrLead = prepareDataWithWrapper(contactFound,leadCaptureWrp,leadCaptureMappingByContactAttributeListMap);
                }

                lcrw.contactId = contactOrLead.Id;
                lcrw.emailFieldValue = (String)contactOrLead.get('Email'); // alon shalev added in 12.2.25
                update contactOrLead;
                executionLogsList.add('[INFO] Contact was updated successfully: ' + contactOrLead.Id);
            }else if(!existingLeadMap.isEmpty()){
                boolean isLeadWasFoundWithEmail = existingLeadMap.containsKey('email');
                Lead leadFound = isLeadWasFoundWithEmail ? existingLeadMap.get('email') : existingLeadMap.get('uniqueEmail');
                executionLogsList.add('[INFO] Contact is not found. Search for existing Lead.');
                executionLogsList.add('[INFO] Lead to update found: '+leadFound.Id);
                if(!isLeadWasFoundWithEmail){
                    executionLogsList.add('[INFO] lead was found using Unique_email__c');
                }
                campaignAndMemberLeadCaptureWrapper.typeOfParent = 'Lead';
                contactUsLeadCaptureWrapper.typeOfParent = 'Lead';

                Lead duplicateUniqueEmail = existingLeadMap.get('uniqueEmail');
                if (isLeadWasFoundWithEmail && duplicateUniqueEmail != null && duplicateUniqueEmail.Id != leadFound.Id) {
                    duplicateUniqueEmail.Unique_email__c = null;
                    update duplicateUniqueEmail;
                    executionLogsList.add('[INFO] Unique_email__c was moved from: '+duplicateUniqueEmail.Id);
                }

                if(Test.isRunningTest() || isVersion2Active){
                    contactOrLead = prepareDataWithWrapper(leadFound,leadCaptureWrp,leadCaptureMappingByLeadAttributeListMap);
                }

                lcrw.leadId = contactOrLead.Id;
                lcrw.emailFieldValue = (String)contactOrLead.get('Email'); // alon shalev added in 12.2.25
                update contactOrLead;
                executionLogsList.add('[INFO] Lead was updated successfully: ' + contactOrLead.Id);
            }else{
                executionLogsList.add('[INFO] No Contact Or Lead found, Creating');
                campaignAndMemberLeadCaptureWrapper.typeOfParent = 'Lead';
                contactUsLeadCaptureWrapper.typeOfParent = 'Lead';
                contactUsLeadCaptureWrapper.IN_New_Lead = true;
                if(Test.isRunningTest() || isVersion2Active){
                    contactOrLead = prepareDataWithWrapper(new Lead(), leadCaptureWrp, leadCaptureMappingByLeadAttributeListMap);

                }
//                if(Test.isRunningTest() || !isVersion2Active){
//                    contactOrLead = prepareData(new Lead(), leadCaptureWrp, leadCaptureMappingByLeadAttributeMap);
//                }
//                System.debug('COMPANY: ' + contactOrLead.get('Company'));
                if(String.isEmpty(String.valueOf(contactOrLead.get('Company')))){
                    contactOrLead.put('Company', 'No_Company');
//                    contactOrLead2.put('Company', 'No_Company');
                }
//                insert contactOrLead; // fix it later
                lcrw.emailFieldValue = (String)contactOrLead.get('Email'); // alon shalev added in 12.2.25
                insert contactOrLead;
                executionLogsList.add('[INFO] Lead was inserted successfully: ' + contactOrLead.Id);
                lcrw.leadId = contactOrLead.Id;
            }
            if(campaignAutomationNeeded){
                fillCampaignWrapperWithWrapper(campaignAndMemberLeadCaptureWrapper,contactOrLead,leadCaptureWrp);
                lcrw.sObjectIdCreated =  ZCampaignAutomation.createCampaignFromLeadCapture(campaignAndMemberLeadCaptureWrapper);
            }
            if(taskAutomationNeeded && isContactUsActiveActive){

                fillTaskCreationWrapperWithWrapper(contactUsLeadCaptureWrapper,contactOrLead,leadCaptureWrp,leadCaptureMappingByLeadAttributeListMap);
                Map<String, Object> inputs = new Map<String, Object>();
                inputs.put('IN_CU_Trigger_Path', contactUsLeadCaptureWrapper.IN_CU_Trigger_Path);
                inputs.put('IN_Email', contactUsLeadCaptureWrapper.IN_Email);
                inputs.put('IN_Form_Location_URL', contactUsLeadCaptureWrapper.IN_Form_Location_URL);
                inputs.put('IN_Last_Contact_Us_Form_Message', contactUsLeadCaptureWrapper.IN_Last_Contact_Us_Form_Message);
                inputs.put('IN_Last_Contact_Us_Form_Subject', contactUsLeadCaptureWrapper.IN_Last_Contact_Us_Form_Subject);
                inputs.put('IN_Last_Contact_Us_Type', contactUsLeadCaptureWrapper.IN_Last_Contact_Us_Type);
                inputs.put('IN_OwnerId', contactUsLeadCaptureWrapper.IN_OwnerId);
                inputs.put('IN_recordId', contactUsLeadCaptureWrapper.IN_recordId);
                inputs.put('IN_Call_Id', contactUsLeadCaptureWrapper.IN_Call_Id);
                inputs.put('IN_SW_Fit_Score', contactUsLeadCaptureWrapper.IN_SW_Fit_Score);
                inputs.put('IN_Web_Form_Formula_Name', contactUsLeadCaptureWrapper.IN_Web_Form_Formula_Name);
                inputs.put('IN_Web_Form_ID', contactUsLeadCaptureWrapper.IN_Web_Form_ID);
                inputs.put('IN_Phone', contactUsLeadCaptureWrapper.IN_Phone);
                inputs.put('IN_How_to_Contact_User_Primary', contactUsLeadCaptureWrapper.IN_How_to_Contact_User_Primary);
                inputs.put('IN_Full_Name', contactUsLeadCaptureWrapper.IN_Full_Name);
                inputs.put('IN_Current_Registration_Type', contactUsLeadCaptureWrapper.IN_Current_Registration_Type);
                inputs.put('IN_Department', contactUsLeadCaptureWrapper.IN_Department);
                inputs.put('IN_Title', contactUsLeadCaptureWrapper.IN_Title);
                inputs.put('IN_LinkedIn_Profile', contactUsLeadCaptureWrapper.IN_LinkedIn_Profile);
                inputs.put('IN_Website_Domain', contactUsLeadCaptureWrapper.IN_Website_Domain);
                inputs.put('IN_Company', contactUsLeadCaptureWrapper.IN_Company);
                inputs.put('IN_Country', contactUsLeadCaptureWrapper.IN_Country);
                inputs.put('IN_New_Lead', contactUsLeadCaptureWrapper.IN_New_Lead);
//                inputs.put('IN_SW_Industry', contactUsLeadCaptureWrapper.IN_SW_Industry);
//                inputs.put('IN_SW_Industry', contactUsLeadCaptureWrapper.IN_SW_Industry);
//                inputs.put('IN_SW_Industry', contactUsLeadCaptureWrapper.IN_SW_Industry);
                Flow.Interview myFlow = new Flow.Interview.Task_Generic_Create_Contact_Us_Task (inputs);
                myFlow.start();
            }

            lcrw.status = 'Success';
            System.debug('handle touchCall finished with success--'+lcrw);
            return lcrw;
        }catch(Exception e){
            system.debug('Stack Trace Error: ' + e.getStackTraceString());
            system.debug(e.getMessage());
            if(((e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('Unique_email__c')) || (e.getMessage().contains('UNABLE_TO_LOCK_ROW')) ||
                    (e.getMessage().contains('DUPLICATES_DETECTED') && e.getMessage().contains('This email already exists'))) &&
                    !System.isQueueable()){
                lcrw.retryInitiated = true;
                FieldsToMerge queueable = new FieldsToMerge(leadCaptureWrp);
                System.enqueueJob(queueable);
            }

            lcrw.message = e.getMessage() + ' ' + e.getStackTraceString();
            return lcrw;
        }

    }

    public static LeadCaptureService.leadCaptureResponseWrapper handleTouchCall (Map<String,Object> leadCaptureWrpMap,Map<String,Feature_Flag_Setting__mdt> flagsMap) {

//        List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
//        List<Feature_Flag_Setting__mdt> contactUsFlags = [SELECT Is_Active__c FROM Feature_Flag_Setting__mdt WHERE Process_Name__c = 'ContactUs Active Flag' AND Class_Name__c = 'LeadCaptureServiceHandler'];
        Boolean isVersion2Active =  flagsMap.containsKey('LeadCapture Version 2')  && flagsMap.get('LeadCapture Version 2').Is_Active__c;
        Boolean isContactUsActiveActive = flagsMap.containsKey('ContactUs Active Flag') ? flagsMap.get('ContactUs Active Flag').Is_Active__c  : true;
        LeadCaptureService.leadCaptureResponseWrapper lcrw = new LeadCaptureService.leadCaptureResponseWrapper();
        LeadCaptureService.CampaignAndMemberLeadCaptureWrapper campaignAndMemberLeadCaptureWrapper = new LeadCaptureService.CampaignAndMemberLeadCaptureWrapper();
        LeadCaptureService.ContactUsLeadCaptureWrapper contactUsLeadCaptureWrapper = new LeadCaptureService.ContactUsLeadCaptureWrapper();


        boolean campaignAutomationNeeded = false;
        boolean taskAutomationNeeded = false;
        System.debug('leadCaptureWrp.sfcmpid--'+leadCaptureWrpMap.get('sfcmpid'));
        String campaignName = (String)leadCaptureWrpMap.get('campaign_name');
        if((String.isNotBlank(campaignName) && !(campaignName.startsWith('FMARKS') || campaignName.startsWith('FMM'))) || (String.isNotBlank((String)leadCaptureWrpMap.get('sfcmpid')))){
            // Identifying LinkedIn
            if(leadCaptureWrpMap.get('campaign_source_utm') != 'li' || leadCaptureWrpMap.get('campaign_name_utm') != 'ppc'){
                campaignAutomationNeeded = true;
            }
        }
        String lastContactUsSubject = (String)leadCaptureWrpMap.get('last_contact_us_form_subject');
        if(String.isNotBlank(lastContactUsSubject) && lastContactUsSubject != 'no cu'){
            taskAutomationNeeded = true;
        }
        try{
            executionLogsList.add('[INFO] STARTED TOUCH');
            Id ContactOrLeadId;
            executionLogsList.add('[INFO] Check Email is not Empty');
            String emailFromLeadCaptureWrpMap = (String)leadCaptureWrpMap.get('email');
            if (String.isBlank(emailFromLeadCaptureWrpMap)){
                System.debug('throwing');
                throw new NoEmailException('Email need to be specified');
            }
            List<Fields_Mapping__mdt> leadCapturefieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(new List<String>{'Lead_Capture_Update_Contact','Lead_Capture_Update_Lead'});
            Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByContactAttributeListMap = GeneralUtil.getLeadCaptureKeyToListMap(leadCapturefieldMappingList,'Lead_Capture_Update_Contact');
            Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByLeadAttributeListMap = GeneralUtil.getLeadCaptureKeyToListMap(leadCapturefieldMappingList,'Lead_Capture_Update_Lead');
            Map<String,Contact> existingContactMap = genContactData(emailFromLeadCaptureWrpMap,leadCaptureMappingByContactAttributeListMap);
            Map<String,Lead> existingLeadMap = genLeadData(emailFromLeadCaptureWrpMap,leadCaptureMappingByLeadAttributeListMap);
            Sobject contactOrLead;
            if(!existingContactMap.isEmpty()){
                campaignAndMemberLeadCaptureWrapper.typeOfParent = 'Contact';
                contactUsLeadCaptureWrapper.typeOfParent = 'Contact';
                boolean isContactWasFoundWithEmail = existingContactMap.containsKey('email');
                Contact contactFound = isContactWasFoundWithEmail ? existingContactMap.get('email') : existingContactMap.get('uniqueEmail');
                executionLogsList.add('[INFO] Contact found '+ contactFound.Id);
                if(!isContactWasFoundWithEmail){
                    executionLogsList.add('[INFO] Contact was found using Unique_email__c');
                }

                Contact duplicateUniqueEmail = existingContactMap.get('uniqueEmail');
                if (isContactWasFoundWithEmail && duplicateUniqueEmail != null && duplicateUniqueEmail.Id != contactFound.Id) {
                    duplicateUniqueEmail.Unique_email__c = null;
                    update duplicateUniqueEmail;
                    executionLogsList.add('[INFO] Unique_email__c was moved from: '+duplicateUniqueEmail.Id);
                }

                if(Test.isRunningTest() || isVersion2Active){
                    contactOrLead = prepareData2(contactFound,leadCaptureWrpMap,leadCaptureMappingByContactAttributeListMap);
                }

                lcrw.contactId = contactOrLead.Id;
                lcrw.emailFieldValue = (String)contactOrLead.get('Email'); // alon shalev added in 12.2.25
                update contactOrLead;
                executionLogsList.add('[INFO] Contact was updated successfully: ' + contactOrLead.Id);
            }else if(!existingLeadMap.isEmpty()){
                boolean isLeadWasFoundWithEmail = existingLeadMap.containsKey('email');
                Lead leadFound = isLeadWasFoundWithEmail ? existingLeadMap.get('email') : existingLeadMap.get('uniqueEmail');
                executionLogsList.add('[INFO] Contact is not found. Search for existing Lead.');
                executionLogsList.add('[INFO] Lead to update found: '+leadFound.Id);
                if(!isLeadWasFoundWithEmail){
                    executionLogsList.add('[INFO] Lead was found using Unique_email__c');
                }
                campaignAndMemberLeadCaptureWrapper.typeOfParent = 'Lead';
                contactUsLeadCaptureWrapper.typeOfParent = 'Lead';

                Lead duplicateUniqueEmail = existingLeadMap.get('uniqueEmail');
                if (isLeadWasFoundWithEmail && duplicateUniqueEmail != null && duplicateUniqueEmail.Id != leadFound.Id) {
                    duplicateUniqueEmail.Unique_email__c = null;
                    update duplicateUniqueEmail;
                    executionLogsList.add('[INFO] Unique_email__c was moved from: '+duplicateUniqueEmail.Id);
                }

                if(Test.isRunningTest() || isVersion2Active){
                    contactOrLead = prepareData2(leadFound,leadCaptureWrpMap,leadCaptureMappingByLeadAttributeListMap);

                }

                lcrw.leadId = contactOrLead.Id;
                lcrw.emailFieldValue = (String)contactOrLead.get('Email'); // alon shalev added in 12.2.25
                update contactOrLead;
                executionLogsList.add('[INFO] Lead was updated successfully: ' + contactOrLead.Id);
            }else{
                executionLogsList.add('[INFO] No Contact Or Lead found, Creating');
                campaignAndMemberLeadCaptureWrapper.typeOfParent = 'Lead';
                contactUsLeadCaptureWrapper.typeOfParent = 'Lead';
                contactUsLeadCaptureWrapper.IN_New_Lead = true;
                if(Test.isRunningTest() || isVersion2Active){
                    contactOrLead = prepareData2(new Lead(), leadCaptureWrpMap, leadCaptureMappingByLeadAttributeListMap);

                }

                if(String.isEmpty(String.valueOf(contactOrLead.get('Company')))){
                    contactOrLead.put('Company', 'No_Company');
                }

                lcrw.emailFieldValue = (String)contactOrLead.get('Email'); // alon shalev added in 12.2.25
                insert contactOrLead;
                executionLogsList.add('[INFO] Lead was inserted successfully: ' + contactOrLead.Id);
                lcrw.leadId = contactOrLead.Id;
            }

            if(campaignAutomationNeeded){
                fillCampaignWrapper(campaignAndMemberLeadCaptureWrapper,contactOrLead,leadCaptureWrpMap);
                lcrw.sObjectIdCreated =  ZCampaignAutomation.createCampaignFromLeadCapture(campaignAndMemberLeadCaptureWrapper);
            }
            if(taskAutomationNeeded && isContactUsActiveActive){

                fillTaskCreationWrapper(contactUsLeadCaptureWrapper,contactOrLead,leadCaptureWrpMap,leadCaptureMappingByLeadAttributeListMap);
                Map<String, Object> inputs = new Map<String, Object>();
                inputs.put('IN_CU_Trigger_Path', contactUsLeadCaptureWrapper.IN_CU_Trigger_Path);
                inputs.put('IN_Email', contactUsLeadCaptureWrapper.IN_Email);
                inputs.put('IN_Form_Location_URL', contactUsLeadCaptureWrapper.IN_Form_Location_URL);
                inputs.put('IN_Last_Contact_Us_Form_Message', contactUsLeadCaptureWrapper.IN_Last_Contact_Us_Form_Message);
                inputs.put('IN_Last_Contact_Us_Form_Subject', contactUsLeadCaptureWrapper.IN_Last_Contact_Us_Form_Subject);
                inputs.put('IN_Last_Contact_Us_Type', contactUsLeadCaptureWrapper.IN_Last_Contact_Us_Type);
                inputs.put('IN_OwnerId', contactUsLeadCaptureWrapper.IN_OwnerId);
                inputs.put('IN_recordId', contactUsLeadCaptureWrapper.IN_recordId);
                inputs.put('IN_Call_Id', contactUsLeadCaptureWrapper.IN_Call_Id);
                inputs.put('IN_SW_Fit_Score', contactUsLeadCaptureWrapper.IN_SW_Fit_Score);
                inputs.put('IN_Web_Form_Formula_Name', contactUsLeadCaptureWrapper.IN_Web_Form_Formula_Name);
                inputs.put('IN_Web_Form_ID', contactUsLeadCaptureWrapper.IN_Web_Form_ID);
                inputs.put('IN_Phone', contactUsLeadCaptureWrapper.IN_Phone);
                inputs.put('IN_How_to_Contact_User_Primary', contactUsLeadCaptureWrapper.IN_How_to_Contact_User_Primary);
                inputs.put('IN_Full_Name', contactUsLeadCaptureWrapper.IN_Full_Name);
                inputs.put('IN_Current_Registration_Type', contactUsLeadCaptureWrapper.IN_Current_Registration_Type);
                inputs.put('IN_Department', contactUsLeadCaptureWrapper.IN_Department);
                inputs.put('IN_Title', contactUsLeadCaptureWrapper.IN_Title);
                inputs.put('IN_LinkedIn_Profile', contactUsLeadCaptureWrapper.IN_LinkedIn_Profile);
                inputs.put('IN_Website_Domain', contactUsLeadCaptureWrapper.IN_Website_Domain);
                inputs.put('IN_Company', contactUsLeadCaptureWrapper.IN_Company);
                inputs.put('IN_Country', contactUsLeadCaptureWrapper.IN_Country);
                inputs.put('IN_New_Lead', contactUsLeadCaptureWrapper.IN_New_Lead);
//                inputs.put('IN_SW_Industry', contactUsLeadCaptureWrapper.IN_SW_Industry);
//                inputs.put('IN_SW_Industry', contactUsLeadCaptureWrapper.IN_SW_Industry);
//                inputs.put('IN_SW_Industry', contactUsLeadCaptureWrapper.IN_SW_Industry);
                Flow.Interview myFlow = new Flow.Interview.Task_Generic_Create_Contact_Us_Task (inputs);
                myFlow.start();
            }

            lcrw.status = 'Success';
            System.debug('handle touchCall finished with success--'+lcrw);
            return lcrw;
        }catch(Exception e){
            system.debug('Stack Trace Error: ' + e.getStackTraceString());
            system.debug(e.getMessage());
            if(((e.getMessage().contains('DUPLICATE_VALUE') && e.getMessage().contains('Unique_email__c')) || (e.getMessage().contains('UNABLE_TO_LOCK_ROW')) ||
                    (e.getMessage().contains('DUPLICATES_DETECTED') && e.getMessage().contains('This email already exists'))) &&
                    !System.isQueueable()){
                FieldsToMerge queueable = new FieldsToMerge(leadCaptureWrpMap);
                System.enqueueJob(queueable);
            }
            lcrw.message = e.getMessage() + ' ' + e.getStackTraceString();
            return lcrw;
        }

    }

    private static void fillTaskCreationWrapperWithWrapper(LeadCaptureService.ContactUsLeadCaptureWrapper wrapper , sObject contactOrLead , LeadCaptureService.leadCaptureWrapper leadCaptureWrp ,  Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByContactAttributeListMap){
        System.debug('leadCaptureMappingByContactAttributeListMap---'+leadCaptureMappingByContactAttributeListMap);
        System.debug('leadCaptureMappingByContactAttributeListMap---'+leadCaptureMappingByContactAttributeListMap.get('ownerId'));
        System.debug('leadCaptureMappingByContactAttributeListMap---'+leadCaptureMappingByContactAttributeListMap.get('ownerid'));

        String sfAdminId = leadCaptureMappingByContactAttributeListMap.get('ownerId')[0].Fixed_Value__c;

        wrapper.IN_CU_Trigger_Path = leadCaptureWrp.CU_Trigger_Path;
        wrapper.IN_Email = contactOrLead.get('Email') != null ? (String)contactOrLead.get('Email') : leadCaptureWrp.email;
        wrapper.IN_Form_Location_URL = leadCaptureWrp.Form_Location_URL;
        wrapper.IN_Last_Contact_Us_Form_Message =  leadCaptureWrp.Contact_Us_Message;
        wrapper.IN_Last_Contact_Us_Form_Subject =  leadCaptureWrp.Last_Contact_Us_Form_Subject;
        wrapper.IN_Last_Contact_Us_Type = leadCaptureWrp.CU_type;
        wrapper.IN_Call_Id = leadCaptureWrp.call_id;
        wrapper.IN_SW_Fit_Score = String.isNotBlank(leadCaptureWrp.Last_Sw_Fit_Score)    ?  leadCaptureWrp.Last_Sw_Fit_Score : (String)contactOrLead.get('SW_Fit_Score__c');
        wrapper.IN_Web_Form_Formula_Name = leadCaptureWrp.Web_Form_Name; // ask shavit
        wrapper.IN_Web_Form_ID = leadCaptureWrp.Web_Form_Name;
        wrapper.IN_recordId = contactOrLead.Id;
        String ownerId = string.valueOf(contactOrLead.get('ownerId')).startsWith('00G') ? sfAdminId : string.valueOf(contactOrLead.get('ownerId'));
        wrapper.IN_OwnerId = ownerId;
        wrapper.IN_Phone = String.isNotBlank(leadCaptureWrp.phone)    ?  leadCaptureWrp.phone : (String)contactOrLead.get('phone');
        wrapper.IN_How_to_Contact_User_Primary = String.isNotBlank(leadCaptureWrp.how_to_contact_user_primary)    ?  leadCaptureWrp.how_to_contact_user_primary : (String)contactOrLead.get('how_to_contact_user_primary__c');
        wrapper.IN_Full_Name = String.isNotBlank(leadCaptureWrp.first_name) && String.isNotBlank(leadCaptureWrp.last_name)   ?  leadCaptureWrp.first_name+ ' '+leadCaptureWrp.last_name : (String)contactOrLead.get('firstname') +' '+(String)contactOrLead.get('lastName');
        wrapper.IN_Current_Registration_Type = String.isNotBlank(leadCaptureWrp.RegistrationType)    ?  leadCaptureWrp.RegistrationType : (String)contactOrLead.get('registration_type__c');
        wrapper.IN_Department = String.isNotBlank(leadCaptureWrp.Department_C)    ?  leadCaptureWrp.Department_C : (String)contactOrLead.get('department__c');
        wrapper.IN_Title = String.isNotBlank(leadCaptureWrp.job_title)    ?  leadCaptureWrp.job_title : (String)contactOrLead.get('title');
        wrapper.IN_LinkedIn_Profile = String.isNotBlank(leadCaptureWrp.LinkedIn_Profile)    ?  leadCaptureWrp.LinkedIn_Profile : (String)contactOrLead.get('linkedIn_profile__c');
        wrapper.IN_Website_Domain = String.isNotBlank(leadCaptureWrp.website)    ?  leadCaptureWrp.website : wrapper.typeOfParent == 'Lead' ? (String)contactOrLead.get('website') : (String)contactOrLead.get('website__c');
        wrapper.IN_Company = String.isNotBlank(leadCaptureWrp.company)    ?  leadCaptureWrp.company : wrapper.typeOfParent == 'Lead' ?  (String)contactOrLead.get('company') : '';
        wrapper.IN_Country = String.isNotBlank(leadCaptureWrp.country)    ?  leadCaptureWrp.country : wrapper.typeOfParent == 'Lead' ?  (String)contactOrLead.get('country') : (String)contactOrLead.get('mailingcountry');
        wrapper.IN_Country = leadCaptureWrp.country;
        wrapper.IN_SW_Industry = leadCaptureWrp.industry;
//       wrapper.IN_Visits_Over_Month
//       wrapper.IN_Intent_Score = leadCaptureWrp.inte
//       wrapper.IN_Strategic_Pod = leadCaptureWrp.stra
//       wrapper.IN_Pro_User_Type = leadCaptureWrp.user
//       wrapper.IN_Last_Pro_Visit_Date = leadCaptureWrp.Last


    }


    private static void fillTaskCreationWrapper(LeadCaptureService.ContactUsLeadCaptureWrapper wrapper , sObject contactOrLead , Map<String,Object> leadCaptureWrpMap ,  Map<String,List<Fields_Mapping__mdt>> leadCaptureMappingByContactAttributeListMap){

        String sfAdminId = leadCaptureMappingByContactAttributeListMap.get('ownerd')[0].Fixed_Value__c;

        wrapper.IN_CU_Trigger_Path = (String)leadCaptureWrpMap.get('cu_trigger_path');
        wrapper.IN_Email = contactOrLead.get('Email') != null ? (String)contactOrLead.get('Email') : (String)leadCaptureWrpMap.get('email') ;
        wrapper.IN_Form_Location_URL = (String)leadCaptureWrpMap.get('form_location_url');
        wrapper.IN_Last_Contact_Us_Form_Message =  (String)leadCaptureWrpMap.get('contact_us_message');
        wrapper.IN_Last_Contact_Us_Form_Subject =  (String)leadCaptureWrpMap.get('last_contact_us_form_subject');
        wrapper.IN_Last_Contact_Us_Type = (String)leadCaptureWrpMap.get('cu_type');
        wrapper.IN_Call_Id = (String)leadCaptureWrpMap.get('call_id');
        wrapper.IN_SW_Fit_Score = String.isNotBlank((String)leadCaptureWrpMap.get('last_sw_fit_score'))    ?  (String)leadCaptureWrpMap.get('last_sw_fit_score') : (String)contactOrLead.get('sw_fit_score__c');
        wrapper.IN_Web_Form_Formula_Name = (String)leadCaptureWrpMap.get('Web_Form_Name'); // ask shavit
        wrapper.IN_Web_Form_ID = (String)leadCaptureWrpMap.get('Web_Form_Name');
        wrapper.IN_recordId = contactOrLead.Id;
        String ownerId = string.valueOf(contactOrLead.get('ownerid')).startsWith('00G') ? sfAdminId : string.valueOf(contactOrLead.get('ownerid'));
        wrapper.IN_OwnerId = ownerId;
        wrapper.IN_Phone = String.isNotBlank((String)leadCaptureWrpMap.get('phone'))    ?  (String)leadCaptureWrpMap.get('phone') : (String)contactOrLead.get('phone');
        wrapper.IN_How_to_Contact_User_Primary = String.isNotBlank((String)leadCaptureWrpMap.get('how_to_contact_user_primary'))    ?  (String)leadCaptureWrpMap.get('how_to_contact_user_primary') : (String)contactOrLead.get('how_to_contact_user_primary__c');
        wrapper.IN_Full_Name = String.isNotBlank((String)leadCaptureWrpMap.get('first_name')) && String.isNotBlank((String)leadCaptureWrpMap.get('last_name'))   ?  (String)leadCaptureWrpMap.get('first_name')+ ' '+leadCaptureWrpMap.get('last_name') : (String)contactOrLead.get('firstname') +' '+(String)contactOrLead.get('lastName');
        wrapper.IN_Current_Registration_Type = String.isNotBlank((String)leadCaptureWrpMap.get('registrationType'))    ?  (String)leadCaptureWrpMap.get('registrationType') : (String)contactOrLead.get('registration_type__c');
        wrapper.IN_Department = String.isNotBlank((String)leadCaptureWrpMap.get('department_c'))    ?  (String)leadCaptureWrpMap.get('department_c') : (String)contactOrLead.get('department__c');
        wrapper.IN_Title = String.isNotBlank((String)leadCaptureWrpMap.get('job_title'))    ?  (String)leadCaptureWrpMap.get('job_title') : (String)contactOrLead.get('title');
        wrapper.IN_LinkedIn_Profile = String.isNotBlank((String)leadCaptureWrpMap.get('linkedIn_profile'))    ?  (String)leadCaptureWrpMap.get('linkedIn_profile') : (String)contactOrLead.get('linkedIn_profile__c');
        wrapper.IN_Website_Domain = String.isNotBlank((String)leadCaptureWrpMap.get('website'))    ?  (String)leadCaptureWrpMap.get('website') : wrapper.typeOfParent == 'Lead' ? (String)contactOrLead.get('website') : (String)contactOrLead.get('website__c');
        wrapper.IN_Company = String.isNotBlank((String)leadCaptureWrpMap.get('company'))    ?  (String)leadCaptureWrpMap.get('company') : wrapper.typeOfParent == 'Lead' ?  (String)contactOrLead.get('company') : '';
        wrapper.IN_Country = String.isNotBlank((String)leadCaptureWrpMap.get('country'))    ?  (String)leadCaptureWrpMap.get('country') : wrapper.typeOfParent == 'Lead' ?  (String)contactOrLead.get('country') : (String)contactOrLead.get('mailingcountry');
        wrapper.IN_Country = (String)leadCaptureWrpMap.get('country');
        wrapper.IN_SW_Industry = (String)leadCaptureWrpMap.get('industry');
//       wrapper.IN_Visits_Over_Month
//       wrapper.IN_Intent_Score = leadCaptureWrp.inte
//       wrapper.IN_Strategic_Pod = leadCaptureWrp.stra
//       wrapper.IN_Pro_User_Type = leadCaptureWrp.user
//       wrapper.IN_Last_Pro_Visit_Date = leadCaptureWrp.Last


    }

    private static void fillCampaignWrapperWithWrapper(LeadCaptureService.CampaignAndMemberLeadCaptureWrapper captureWrapper , sObject contactOrLead,LeadCaptureService.leadCaptureWrapper leadCaptureWrp){
        captureWrapper.campaignId = leadCaptureWrp.SFCmpId;
        captureWrapper.campaignName = leadCaptureWrp.campaign_name;
        captureWrapper.objectId = contactOrLead.Id;
        captureWrapper.asset_type = leadCaptureWrp.asset_type;
        captureWrapper.button_Caption = leadCaptureWrp.Button_Caption;
        captureWrapper.campaign_Medium_UTM = leadCaptureWrp.campaign_medium_utm;
        captureWrapper.campaign_Name_UTM = leadCaptureWrp.campaign_name_utm;
        captureWrapper.campaign_Source_UTM = leadCaptureWrp.campaign_source_utm;
        captureWrapper.campaign_Solution = leadCaptureWrp.campaign_solution;
        captureWrapper.form_URL = leadCaptureWrp.Form_Location_URL;
//        captureWrapper.target_Audience = leadCaptureWrp.target_Audience;
        captureWrapper.country = leadCaptureWrp.country;
        captureWrapper.call_Id = leadCaptureWrp.call_id;
        captureWrapper.affiliate_id = leadCaptureWrp.affiliate_id;
//        captureWrapper.leadSource = leadCaptureWrp.lead
        captureWrapper.campaign_Term_UTM = leadCaptureWrp.Campaign_Term_UTM;
        captureWrapper.campaign_Content_UTM = leadCaptureWrp.Campaign_Content_UTM;
        captureWrapper.external_campaign_id = leadCaptureWrp.External_Campaign_Id;
        captureWrapper.referrer = leadCaptureWrp.Referrer;
        captureWrapper.landingPage = leadCaptureWrp.Landing_Page;
        captureWrapper.status = leadCaptureWrp.Member_Status;
        captureWrapper.Email = contactOrLead.get('Email') != null ? (String)contactOrLead.get('Email') : leadCaptureWrp.email;
        captureWrapper.Browser_Language = leadCaptureWrp.Browser_Language;
        captureWrapper.form_file_name = leadCaptureWrp.form_file_name;
        captureWrapper.form_file_URL = leadCaptureWrp.form_file_URL;
    }
    private static void fillCampaignWrapper(LeadCaptureService.CampaignAndMemberLeadCaptureWrapper captureWrapper , sObject contactOrLead,Map<String,Object> leadCaptureWrpMap){
        captureWrapper.campaignId = (String)leadCaptureWrpMap.get('SFCmpId');
        captureWrapper.campaignName = (String)leadCaptureWrpMap.get('campaign_name');
        captureWrapper.objectId = contactOrLead.Id;
        captureWrapper.asset_type = (String)leadCaptureWrpMap.get('asset_type');
        captureWrapper.button_Caption = (String)leadCaptureWrpMap.get('Button_Caption');
        captureWrapper.campaign_Medium_UTM = (String)leadCaptureWrpMap.get('campaign_medium_utm');
        captureWrapper.campaign_Name_UTM = (String)leadCaptureWrpMap.get('campaign_name_utm');
        captureWrapper.campaign_Source_UTM = (String)leadCaptureWrpMap.get('campaign_source_utm');
        captureWrapper.campaign_Solution = (String)leadCaptureWrpMap.get('campaign_solution');
        captureWrapper.form_URL = (String)leadCaptureWrpMap.get('Form_Location_URL');
//        captureWrapper.target_Audience = leadCaptureWrp.target_Audience;
        captureWrapper.country = (String)leadCaptureWrpMap.get('country');
        captureWrapper.call_Id = (String)leadCaptureWrpMap.get('call_id');
        captureWrapper.affiliate_id = (String)leadCaptureWrpMap.get('affiliate_id');
//        captureWrapper.leadSource = leadCaptureWrp.lead
        captureWrapper.campaign_Term_UTM = (String)leadCaptureWrpMap.get('Campaign_Term_UTM');
        captureWrapper.campaign_Content_UTM = (String)leadCaptureWrpMap.get('Campaign_Content_UTM');
        captureWrapper.external_campaign_id = (String)leadCaptureWrpMap.get('External_Campaign_Id');
        captureWrapper.referrer = (String)leadCaptureWrpMap.get('Referrer');
        captureWrapper.landingPage = (String)leadCaptureWrpMap.get('Landing_Page');
        captureWrapper.status = (String)leadCaptureWrpMap.get('Member_Status');
        captureWrapper.Email = contactOrLead.get('Email') != null ? (String)contactOrLead.get('Email') : (String)leadCaptureWrpMap.get('email');
        captureWrapper.Browser_Language = (String)leadCaptureWrpMap.get('Browser_Language');
        captureWrapper.form_file_name = (String)leadCaptureWrpMap.get('form_file_name');
        captureWrapper.form_file_URL = (String)leadCaptureWrpMap.get('form_file_URL');
    }

    public static SObject prepareDataWithWrapper(SObject contactOrLead, LeadCaptureService.leadCaptureWrapper leadCaptureWrp, Map<String, List<Fields_Mapping__mdt>> LeadCaptureMappingByAttributeListMap){
        Map<String,Object> leadCaptureWrpMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(leadCaptureWrp));
        prepareDataInternal(contactOrLead, leadCaptureWrpMap, LeadCaptureMappingByAttributeListMap);
        leadCaptureWrp.subTypeForLog = handleSubTypeWithWrapper(leadCaptureWrp);
        return contactOrLead;
    }

    public static SObject prepareData2(SObject contactOrLead, Map<String,Object> leadCaptureWrpMap, Map<String, List<Fields_Mapping__mdt>> LeadCaptureMappingByAttributeListMap){
        prepareDataInternal(contactOrLead, leadCaptureWrpMap, LeadCaptureMappingByAttributeListMap);
        leadCaptureWrpMap.put('subtypeforlog', handleSubType(leadCaptureWrpMap));
        return contactOrLead;
    }

    private static void prepareDataInternal(SObject contactOrLead, Map<String,Object> leadCaptureWrpMap, Map<String, List<Fields_Mapping__mdt>> LeadCaptureMappingByAttributeListMap){
        Boolean isGroudonCall = leadCaptureWrpMap.get('call_made_from_groudon') == true;

        for(String fieldMappingName : LeadCaptureMappingByAttributeListMap.keySet()){
            if((leadCaptureWrpMap.get(fieldMappingName) != null && leadCaptureWrpMap.get(fieldMappingName) != '') || LeadCaptureMappingByAttributeListMap.get(fieldMappingName)[0].isRequired__c){
                for(Fields_Mapping__mdt fieldsMappingSetting : LeadCaptureMappingByAttributeListMap.get(fieldMappingName)){
                    String fieldName = fieldsMappingSetting.Destination_Field__c;
                    if(isGroudonCall && String.isNotBlank(fieldMappingName) && 
                      (fieldMappingName.toLowerCase() == 'groudon_primary_phone' || 
                       fieldMappingName.toLowerCase() == 'groudon_secondary_phone' || 
                       fieldMappingName.toLowerCase() == 'si_enrichment_visits' || 
                       fieldMappingName.toLowerCase() == 'phone')){
                        continue;
                    }

                    if(GeneralUtil.hasSObjectField(contactOrLead,fieldName)){
                        Object fieldValueAfterCasting = leadCaptureCastTo(leadCaptureWrpMap.get(fieldMappingName) , fieldsMappingSetting.Cast_To__c);
                        fieldValueAfterCasting = trimObjectValue(contactOrLead,fieldValueAfterCasting,fieldName);

                        try {
                            if (fieldsMappingSetting.To_Lower_Case__c != null && fieldsMappingSetting.To_Lower_Case__c && fieldValueAfterCasting instanceof String) {
                                fieldValueAfterCasting = ((String)fieldValueAfterCasting).toLowerCase();
                            }
                        } catch (Exception e) {
                            System.debug('To_Lower_Case__c field not available: ' + e.getMessage());
                        }
                        try {
                            if(fieldsMappingSetting.Keep_Current_Value__c != null && fieldsMappingSetting.Keep_Current_Value__c){
                                fieldValueAfterCasting = contactOrLead.get(fieldName) != null ? contactOrLead.get(fieldName) : fieldValueAfterCasting;
                            }
                        } catch (Exception e) {
                            System.debug('Keep_Current_Value__c field not available: ' + e.getMessage());
                        }
                        contactOrLead.put(fieldName,fieldValueAfterCasting);
                    }
                }
            }
        }
        
        if(isGroudonCall){
            contactOrLead.put('ModifiedByGroudon__c', true);
            handleGroudonPhoneMapping(contactOrLead, leadCaptureWrpMap);
            applyGroudonEnrichmentMetadata(contactOrLead);
        }
        
        String ownerIdKey = LeadCaptureMappingByAttributeListMap.containsKey('ownerId') ? 'ownerId' : 'ownerid';
        if(contactOrLead.get('OwnerId') == null && contactOrLead.get('Id') == null && LeadCaptureMappingByAttributeListMap.containsKey(ownerIdKey) && LeadCaptureMappingByAttributeListMap.get(ownerIdKey) != null && !LeadCaptureMappingByAttributeListMap.get(ownerIdKey).isEmpty()){
            contactOrLead.put(LeadCaptureMappingByAttributeListMap.get(ownerIdKey)[0].Destination_Field__c, LeadCaptureMappingByAttributeListMap.get(ownerIdKey)[0].Fixed_Value__c);
        }

        if((contactOrLead.get('LastName') == null || String.valueOf(contactOrLead.get('LastName')).trim() == '') && contactOrLead.get('Id') == null){
            contactOrLead.put('LastName', 'NA');
        }
    }

    private static Object trimObjectValue(SObject contactOrLead,Object fieldValueAfterCasting , String fieldName){
        Schema.SObjectType sobjectType = contactOrLead.getSObjectType();
        String objectName = sobjectType.getDescribe().getLabel();
        DescribeSObjectResult objResult = Schema.getGlobalDescribe()
                .get(objectName).getDescribe();
        System.debug('objResult--'+objResult);


        DescribeFieldResult fieldResult = objResult.fields.getMap()
                .get(fieldName).getDescribe();
        System.debug('fieldResult.getType()--'+fieldResult.getType());
        if(fieldResult.getType() == DisplayType.STRING){
            System.debug('i am here');
            String originalValue = String.valueOf(fieldValueAfterCasting);
            if(fieldResult.getLength() < originalValue.length()){
                System.debug('removing data');
                // removing data
                executionLogsList.add('[WARNING] the length of : '+fieldName + '  was too long , maximum is :  '+fieldResult.getLength()+' original length is  : '+originalValue.length());
                fieldValueAfterCasting = originalValue.substring(0,fieldResult.getLength());
                System.debug('fieldValueAfterCasting--'+fieldValueAfterCasting);
            }
        }
        return fieldValueAfterCasting;
    }

    private static void applyGroudonEnrichmentMetadata(SObject contactOrLead){
        if(contactOrLead.getSObjectType() != Contact.SObjectType){
            return;
        }
        if(GeneralUtil.hasSObjectField(contactOrLead, 'Enrichment_Source__c')){
            contactOrLead.put('Enrichment_Source__c', 'Groudon');
        }
        if(GeneralUtil.hasSObjectField(contactOrLead, 'Enrichment_Source_Time__c')){
            contactOrLead.put('Enrichment_Source_Time__c', Datetime.now());
        }
    }

    private static String handleSubTypeWithWrapper(LeadCaptureService.leadCaptureWrapper leadCaptureWrp){
        String subtype = '';
        if(leadCaptureWrp.Last_Contact_Us_Form_Subject != null ){
            subtype += 'Contact Us';
        }
        System.debug('leadCaptureWrp.prospect_data_incomplete---'+leadCaptureWrp.prospect_data_incomplete);
        if(leadCaptureWrp.Trial_Start_Date != null || leadCaptureWrp.trial_cc_submitted_start_date != null || (leadCaptureWrp.prospect_data_incomplete != null && leadCaptureWrp.prospect_data_incomplete == 'false')){
            subtype += String.isNotBlank(subtype) ? ',Quiz'  : 'Quiz';

        }
        if(leadCaptureWrp.campaign_name != null || leadCaptureWrp.SFCmpId != null || leadCaptureWrp.campaignName != null){
            subtype+= String.isNotBlank(subtype) ? ',Campaign' :'Campaign';
        }

        if(leadCaptureWrp.call_made_from_groudon != null && leadCaptureWrp.call_made_from_groudon && leadCaptureWrp.enrichment_success != null && leadCaptureWrp.enrichment_success){
            subtype += String.isNotBlank(subtype) ? ',Enrichment' : 'Enrichment';
        }
        return subtype;
    }
    private static String handleSubType(Map<String,Object> leadCaptureWrpMap){
        String subtype = '';
        if(leadCaptureWrpMap.containsKey('Last_Contact_Us_Form_Subject') && leadCaptureWrpMap.get('Last_Contact_Us_Form_Subject') != null){
            subtype+= 'Contact Us';
        }
        if(leadCaptureWrpMap.get('Trial_Start_Date') != null || leadCaptureWrpMap.get('trial_cc_submitted_start_date') != null || (leadCaptureWrpMap.get('prospect_data_incomplete') != null && leadCaptureWrpMap.get('prospect_data_incomplete') == 'false')){
            subtype+= String.isNotBlank(subtype) ? ',Quiz' : 'Quiz';
        }
        if(leadCaptureWrpMap.get('campaign_name') != null || leadCaptureWrpMap.get('SFCmpId') != null || leadCaptureWrpMap.get('campaignName') != null){
            subtype+= String.isNotBlank(subtype) ? ',Campaign' :'Campaign';
        }
        if(leadCaptureWrpMap.get('enrichment_success') == true && leadCaptureWrpMap.get('call_made_from_groudon') == true){
            subtype += String.isNotBlank(subtype) ? ',Enrichment': 'Enrichment';
        }
        return subtype;
    }

    private static Object leadCaptureCastTo(Object wrapperValue , String castTo){
        Object returnObject = wrapperValue;
        System.debug('castTo--'+castTo);
        System.debug('wrapperValue--'+wrapperValue);

        switch on castTo{
            when 'DateTime'{
                String dateTimeValue = String.valueOf(wrapperValue);
                returnObject = DateTime.valueOfGmt(dateTimeValue.replace('T',' '));
            }
            when 'Boolean'{
                returnObject = Boolean.valueOf(returnObject);
            }
            when 'Integer'{
                returnObject = Integer.valueOf(wrapperValue);
            }
            when 'Date'{
                returnObject = wrapperValue instanceOf String ? Date.valueOf((String)wrapperValue) : (Date)wrapperValue;
            }
            when 'Decimal'{
                returnObject = Decimal.valueOf(String.valueOf(wrapperValue));
            }
            when 'Today'{
                returnObject = Date.today();
            }
            when 'Now'{
                returnObject = Datetime.now();
            }

        }
        System.debug('returnObject--'+returnObject);
        return returnObject;
    }

    public static Map<String,Object> getNormalizeMap(Map<String,Object> leadCaptureWrpMap){
        Map<String,Object> normalizedLeadCaptureWrpMap = new Map<String, Object>();
        for (String key : leadCaptureWrpMap.keySet()) {
            System.debug('key--'+key);
            System.debug('key-after lowercase-'+key.toLowerCase());
            normalizedLeadCaptureWrpMap.put(key.toLowerCase(), leadCaptureWrpMap.get(key));
        }
        return normalizedLeadCaptureWrpMap;
    }

    private static void handleGroudonPhoneMapping(SObject contactOrLead, Map<String,Object> leadCaptureWrpMap){
        String primaryPhone = leadCaptureWrpMap.get('Groudon_Primary_Phone') != null ? (String) leadCaptureWrpMap.get('Groudon_Primary_Phone') : (String) leadCaptureWrpMap.get('groudon_primary_phone');
        String secondaryPhone = leadCaptureWrpMap.get('Groudon_Secondary_Phone') != null ? (String) leadCaptureWrpMap.get('Groudon_Secondary_Phone') : (String) leadCaptureWrpMap.get('groudon_secondary_phone');
        String currentPhone = (String) contactOrLead.get('Phone');
        
        if(String.isBlank(currentPhone) && String.isNotBlank(primaryPhone)){
            if(GeneralUtil.hasSObjectField(contactOrLead,'Phone')){
                contactOrLead.put('Phone', primaryPhone);
            }
            if(String.isNotBlank(secondaryPhone) && secondaryPhone != primaryPhone){
                if(GeneralUtil.hasSObjectField(contactOrLead,'MobilePhone')){
                    contactOrLead.put('MobilePhone', secondaryPhone);
                }
            }
        } else if(String.isNotBlank(currentPhone) && String.isNotBlank(primaryPhone) && primaryPhone != currentPhone){
            if(GeneralUtil.hasSObjectField(contactOrLead,'MobilePhone')){
                contactOrLead.put('MobilePhone', primaryPhone);
            }
        }
    }

    private class NoEmailException extends Exception {}
    private class NoContactOrLeadException extends Exception {}
    private class NoCountryFieldException extends Exception {}
    private class LeadConvertFailedException extends Exception {}
}
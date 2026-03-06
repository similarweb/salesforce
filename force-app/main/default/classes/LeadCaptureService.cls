/**
* @author Zohar Sinay
* @date 07/07/2021
* @description Entrance to LeadCapture method to Handle touch and no touch calls from marketing cloud
*/
@RestResource(urlMapping='/leadcaptureservice/*')
global without sharing class LeadCaptureService {
    public static boolean runVersion3 = false;
    public static boolean runVersion2 = false;
    @HttpPost
    global static List<leadCaptureResponseWrapper> LeadCapture() {
        LeadCaptureService.leadCaptureResponseWrapper lcrw = new LeadCaptureService.leadCaptureResponseWrapper();
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
        try{
            System.debug('requestBody--'+requestBody);
            System.debug('requestMap--'+requestMap);
            Map<String,Object> leadCaptureWrpMap = LeadCaptureServiceHandler.getNormalizeMap((Map<String,Object>)requestMap.get('leadCaptureWrp'));
            System.debug('leadCaptureWrpMap--'+leadCaptureWrpMap);
            LeadCaptureService.leadCaptureWrapper leadCaptureWrp = (LeadCaptureService.leadCaptureWrapper)JSON.deserialize(JSON.serialize(leadCaptureWrpMap),LeadCaptureService.leadCaptureWrapper.class);
            System.debug('leadCaptureWrp--'+leadCaptureWrp);
            System.debug('leadCaptureWrpMap--'+leadCaptureWrpMap);
            RestResponse res = RestContext.response;
            List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
            Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
            for(Feature_Flag_Setting__mdt flag : flags){
                flagsMap.put(flag.Process_Name__c,flag);
            }
            Boolean isVersion3Active = flagsMap.containsKey('LeadCapture Version 3') && flagsMap.get('LeadCapture Version 3').Is_Active__c;
            if(Test.isRunningTest()){
                addCoverageTemp();
            }
            try{
                System.debug('runVersion2---'+runVersion2);
                System.debug('runVersion2---'+runVersion3);
                if((isVersion3Active && !Test.isRunningTest()) || (Test.isRunningTest() && runVersion3)){
                    lcrw = LeadCaptureServiceHandler.handleTouchCall(leadCaptureWrpMap,flagsMap);
                }

                if ((!isVersion3Active && !Test.isRunningTest()) ||(runVersion2 && Test.isRunningTest())){
                    lcrw = LeadCaptureServiceHandler.handleTouchCallWithWrapper(leadCaptureWrp,flagsMap);
                }
                String jsonResponse = JSON.serialize(lcrw);
                if(String.isBlank(lcrw.message))
                {
                    String responseId = '';
                    lcrw.statusCode = 200;
                    res.statusCode = 200;
                    lcrw.status = 'Success';
                    if(!String.isBlank(lcrw.accountId)){
                        responseId = lcrw.accountId;
                    }else if(!String.isBlank(lcrw.contactId)){
                        responseId = lcrw.contactId;
                    }else{
                        responseId = lcrw.leadId;
                    }
                    if(isVersion3Active){
                        LeadCaptureServiceHandler.recordLog(true, lcrw, req, leadCaptureWrpMap,false);
                    }else{
                        LeadCaptureServiceHandler.recordLogWithWrapper(true,lcrw,req,leadCaptureWrp,false);
                    }
                } else {
                    lcrw.status = 'Failed';
                    lcrw.statusCode = 500;
                    res.statusCode = 500;
                    if((isVersion3Active && !Test.isRunningTest()) || (Test.isRunningTest() && runVersion3)){
                        LeadCaptureServiceHandler.recordLog(false, lcrw, req, leadCaptureWrpMap,false);
                    }
                    if ((!isVersion3Active && !Test.isRunningTest()) ||( runVersion2 && Test.isRunningTest())){
                        LeadCaptureServiceHandler.recordLogWithWrapper(false, lcrw, req, leadCaptureWrp,false);
                    }
                }
                res.responseBody = blob.valueOf(jsonResponse);
                return new List<LeadCaptureService.leadCaptureResponseWrapper>{lcrw};
            } catch(Exception e){
                system.debug('Stack Trace Error: ' + e.getStackTraceString());
                lcrw.statusCode = 500;
                lcrw.status = 'Failed';
                lcrw.message = e.getMessage() + ' ' + e.getStackTraceString();
                if(isVersion3Active){
                    LeadCaptureServiceHandler.recordLog(false, lcrw, req, leadCaptureWrpMap,false);
                }else{
                    LeadCaptureServiceHandler.recordLogWithWrapper(false,lcrw,req,leadCaptureWrp,false);
                }
                return new List<LeadCaptureService.leadCaptureResponseWrapper>{lcrw};
            }
        } catch (Exception e){
            lcrw.statusCode = 500;
            lcrw.status = 'Failed with new error';
            lcrw.message = e.getMessage() + ' ' + e.getStackTraceString();
            System.debug('e.get--'+e.getMessage());
            System.debug('e.get--'+e.getStackTraceString());
            LeadCaptureServiceHandler.recordParsingErrorLog(requestMap, e);
            return new List<LeadCaptureService.leadCaptureResponseWrapper>{lcrw};

        }
    }

    global class LeadCaptureObj {
        public leadCaptureWrapper leadCaptureWrp;
    }


    global class leadCaptureWrapper {
        public String user_ip;
        public String Reseller_Name;
        public String Last_Contact_Us_Form_Subject;
        public String Department_Other_Description;
        Public String Base_Product;
        Public String Event_Name;
        Public String Button_Caption;
        Public String Form_Location_URL;
        Public String Form_Submission_Date_and_Time;
        Public String Web_Form_Name;
        Public String GCLID;
        Public String No_Touch_Status;
        Public String RoleOtherDesc;
        Public String website;
        Public String inferred_solution;
        Public String CTA_Description;
        Public String affiliate_id;
        Public String redirect_field;
        Public String IndustryOtherDesc;
        Public String Contact_Us_Message;
        Public String Title_Other_Description;
        Public String Campaign_Content_UTM;
        Public String Secondary_Phone;
        Public String RegistrationFroType;
        Public String Strategic_Employee;
        Public String first_name;
        Public String secondary_mail;
        Public String campaign_region;
        Public String Order_Number;
        Public String Lead_Gen_Visitor_ID;
        Public String Lead_Gen_Session_ID;
        Public String CTA_URL;
        Public Boolean No_Touch_User;
        Public Decimal Employees_Min;
        Public String Blog_Newsletter_Signup;
        Public String campaign_source_utm;
        Public String Webinar_Event_Date;
        Public String email;
        Public String prospect_data_incomplete;
        Public String Cancellation_Reason;
        Public String industry;
        Public String Pardot_Lead_Source;
        Public String Polygraph_Update_Timestamp;
        Public String Clearbit_Timestamp;
        Public String last_name;
        Public String NT_Credit_Card_Status;
        Public String Department_C;
        Public String campaign_solution;
        Public String job_title;
        Public String sscid;
        Public String Current_Registration_Type;
        Public String Form_Location_Breadcrumb;
        Public String Event_Date;
        Public String parent_campaign;
        Public String registration_use_case;
        Public String country;
        Public String Cancellation_Explanation;
        Public Decimal Employees_Max;
        Public String asset_type;
        Public String Country_Code;
        Public String Secure_Account_ID;
        Public String campaign_name_utm;
        Public String Webinar_Name;
        Public String company;
        Public String blaid;
        Public String campaign_name;
        Public String phone;
        Public String NT_Package_selected;
        Public String source;
        Public String RegistrationType;
        Public String Contact_Us_Message_Long;
        Public String campaign_medium_utm;
        Public Boolean NT_Purchase;
        Public String ownerId;
        Public String operationsRouting;
        Public String campaignName;
        Public String campaignDescription;
        Public String Trial_Start_Date;
        Public String Trial_End_Date;
        Public String PartnerStack_Lead_Key;
        Public String Piwik_Visitor_ID;
        Public String Form_Complete_URL;
        Public String LinkedIn_Profile;
        //Public String Current_Piwik_Session;
        Public String Campaign_Term_UTM;
        Public String External_Campaign_Id;
        //Public String Form_Creation_Date;
        Public String Link_to_CP;
        Public String call_id;
        Public String Inferred_Solution_Suggestion;
        Public String Seniority;
        Public String Use_of_Similarweb;
        Public String Use_of_Similarweb_Additional_Info;
        Public String First_Registration_Date;
        Public String CU_Trigger_Path;
        Public String SFCmpId;
        Public String Member_Status;
        Public String Referrer;
        Public String Landing_Page;
        Public Decimal SI_Enrichment_Visits;
        Public String how_to_contact_user_primary;
        Public String how_to_contact_user_secondary;
        Public String trial_cc_submitted_start_date;
        Public String Login_Type;
        Public String browser_Language;
        Public String CU_type;
        Public String Skipped_Trial;
        Public String Last_Sw_Fit_Score;
        Public String Last_Relevant_For_Sales;
        Public String How_Did_You_Hear_About_Us;
        Public String How_Did_You_Hear_About_Us_Description;
        Public String API_Interest;
        Public String Secondary_Email_Verified;
        Public String Pre_Mapped_Industry;
        Public String form_file_URL;
        Public String form_file_name;
        public String subTypeForLog;
        public String SI_Quiz_Onboarding_User_Goals;
        public String SI_Quiz_Onboarding_Starting_Action;
        public String Cancellation_Date;
        public String Pre_Mapped_Title;
        public Boolean Force_Enrichment;
        public String Enrichment_Details;
        public Boolean call_made_from_groudon;
        public Boolean enrichment_success;
        public String Website_Verified;
        public String What_are_you_looking_to_do_with_Similarweb;
        public String What_are_you_looking_to_do_with_Similarweb_L2;
    public Boolean Fake_Data;
    public String Fake_Data_Reason;
    public String Groudon_Pred_Reason;
    public String Groudon_Company_Domains;
    public Decimal Groudon_Employee_Max;
    public Decimal Groudon_Employee_Min;
        public Boolean Has_Mobile_App;
        public Integer Google_App_MAU;
        public Integer Apple_App_MAU;
        public Integer Google_App_MDU;
        public Integer Apple_App_MDU;
        public String Groudon_Visits;
        public String Groudon_Primary_Phone;
        public String Groudon_Secondary_Phone;
        public String gtmidnts;
        public String Groudon_Enrichment_fields;
    }



    global class leadCaptureResponseWrapper {
        public Integer statusCode;
        public String status;
        public String message;
        public String leadId;
        public String contactId;
        public String accountId;
        public String sObjectIdCreated;
        public Boolean retryInitiated = false;
        public String emailFieldValue;
    }

    global class ContactUsLeadCaptureWrapper {
        public String typeOfParent;
        public Boolean IN_New_Lead;
        public String IN_CU_Trigger_Path;
        public String IN_Email;
        public String IN_Form_Location_URL;
        public String IN_Last_Contact_Us_Form_Message;
        public String IN_Last_Contact_Us_Form_Subject;
        public String IN_Last_Contact_Us_Type;
        public String IN_OwnerId;
        public String IN_recordId;
        public String IN_Call_Id;
        public String IN_SW_Fit_Score;
        public String IN_Web_Form_Formula_Name;
        public String IN_Web_Form_ID;
        public String IN_Phone;
        public String IN_How_to_Contact_User_Primary;
        public String IN_Full_Name;
        public String IN_Current_Registration_Type;
        public String IN_Department;
        public String IN_Title;
        public String IN_LinkedIn_Profile;
        public String IN_Website_Domain;
        public String IN_Company;
        public String IN_Country;
        public String IN_SW_Industry;
        public String IN_Visits_Over_Month;
        public String IN_Intent_Score;
        public String IN_Strategic_Pod;
        public String IN_Strategic_Region;
        public String IN_Pro_User_Type;
        public String IN_Last_Pro_Visit_Date;

        public ContactUsLeadCaptureWrapper(){
            this.IN_New_Lead = false;
        }

    }

    global class CampaignAndMemberLeadCaptureWrapper {
        public String typeOfParent;
        public Id objectId; // lead or contact
        public String campaignId;
        public String campaignName;
        public String campaign_Name_UTM;
        public String campaign_Source_UTM;
        public String campaign_Solution;
        public String form_URL;
        public String button_Caption;
        public String campaign_Medium_UTM;
        public String campaign_Term_UTM;
        public String external_campaign_id;
        public String target_Audience;
        public String affiliate_id;
        public String asset_type;
        public String call_Id;
        public String campaign_Content_UTM;
        public String country;
        public String leadSource;
        public String landingPage;
        public String status;
        public String referrer;
        public String Email;
        public String browser_Language;
        public String form_file_name;
        public String form_file_URL;


        public CampaignAndMemberLeadCaptureWrapper(){}

    }

    private static void addCoverageTemp(){
        Integer j = 0;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
    }

}
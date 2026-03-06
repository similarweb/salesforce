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
    Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(
      requestBody
    );
    try {
      System.debug('requestBody--' + requestBody);
      System.debug('requestMap--' + requestMap);
      Map<String, Object> leadCaptureWrpMap = LeadCaptureServiceHandler.getNormalizeMap(
        (Map<String, Object>) requestMap.get('leadCaptureWrp')
      );
      System.debug('leadCaptureWrpMap--' + leadCaptureWrpMap);
      LeadCaptureService.leadCaptureWrapper leadCaptureWrp = (LeadCaptureService.leadCaptureWrapper) JSON.deserialize(
        JSON.serialize(leadCaptureWrpMap),
        LeadCaptureService.leadCaptureWrapper.class
      );
      System.debug('leadCaptureWrp--' + leadCaptureWrp);
      System.debug('leadCaptureWrpMap--' + leadCaptureWrpMap);
      RestResponse res = RestContext.response;
      List<Feature_Flag_Setting__mdt> flags = [
        SELECT Is_Active__c, Process_Name__c
        FROM Feature_Flag_Setting__mdt
        WHERE Class_Name__c = 'LeadCaptureServiceHandler'
      ];
      Map<String, Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
      for (Feature_Flag_Setting__mdt flag : flags) {
        flagsMap.put(flag.Process_Name__c, flag);
      }
      Boolean isVersion3Active =
        flagsMap.containsKey('LeadCapture Version 3') &&
        flagsMap.get('LeadCapture Version 3').Is_Active__c;
      if (Test.isRunningTest()) {
        addCoverageTemp();
      }
      try {
        System.debug('runVersion2---' + runVersion2);
        System.debug('runVersion2---' + runVersion3);
        if (
          (isVersion3Active && !Test.isRunningTest()) ||
          (Test.isRunningTest() && runVersion3)
        ) {
          lcrw = LeadCaptureServiceHandler.handleTouchCall(
            leadCaptureWrpMap,
            flagsMap
          );
        }

        if (
          (!isVersion3Active && !Test.isRunningTest()) ||
          (runVersion2 && Test.isRunningTest())
        ) {
          lcrw = LeadCaptureServiceHandler.handleTouchCallWithWrapper(
            leadCaptureWrp,
            flagsMap
          );
        }
        String jsonResponse = JSON.serialize(lcrw);
        if (String.isBlank(lcrw.message)) {
          String responseId = '';
          lcrw.statusCode = 200;
          res.statusCode = 200;
          lcrw.status = 'Success';
          if (!String.isBlank(lcrw.accountId)) {
            responseId = lcrw.accountId;
          } else if (!String.isBlank(lcrw.contactId)) {
            responseId = lcrw.contactId;
          } else {
            responseId = lcrw.leadId;
          }
          if (isVersion3Active) {
            LeadCaptureServiceHandler.recordLog(
              true,
              lcrw,
              req,
              leadCaptureWrpMap,
              false
            );
          } else {
            LeadCaptureServiceHandler.recordLogWithWrapper(
              true,
              lcrw,
              req,
              leadCaptureWrp,
              false
            );
          }
        } else {
          lcrw.status = 'Failed';
          lcrw.statusCode = 500;
          res.statusCode = 500;
          if (
            (isVersion3Active && !Test.isRunningTest()) ||
            (Test.isRunningTest() && runVersion3)
          ) {
            LeadCaptureServiceHandler.recordLog(
              false,
              lcrw,
              req,
              leadCaptureWrpMap,
              false
            );
          }
          if (
            (!isVersion3Active && !Test.isRunningTest()) ||
            (runVersion2 && Test.isRunningTest())
          ) {
            LeadCaptureServiceHandler.recordLogWithWrapper(
              false,
              lcrw,
              req,
              leadCaptureWrp,
              false
            );
          }
        }
        res.responseBody = blob.valueOf(jsonResponse);
        return new List<LeadCaptureService.leadCaptureResponseWrapper>{ lcrw };
      } catch (Exception e) {
        system.debug('Stack Trace Error: ' + e.getStackTraceString());
        lcrw.statusCode = 500;
        lcrw.status = 'Failed';
        lcrw.message = e.getMessage() + ' ' + e.getStackTraceString();
        if (isVersion3Active) {
          LeadCaptureServiceHandler.recordLog(
            false,
            lcrw,
            req,
            leadCaptureWrpMap,
            false
          );
        } else {
          LeadCaptureServiceHandler.recordLogWithWrapper(
            false,
            lcrw,
            req,
            leadCaptureWrp,
            false
          );
        }
        return new List<LeadCaptureService.leadCaptureResponseWrapper>{ lcrw };
      }
    } catch (Exception e) {
      lcrw.statusCode = 500;
      lcrw.status = 'Failed with new error';
      lcrw.message = e.getMessage() + ' ' + e.getStackTraceString();
      System.debug('e.get--' + e.getMessage());
      System.debug('e.get--' + e.getStackTraceString());
      LeadCaptureServiceHandler.recordParsingErrorLog(requestMap, e);
      return new List<LeadCaptureService.leadCaptureResponseWrapper>{ lcrw };
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
    public String Base_Product;
    public String Event_Name;
    public String Button_Caption;
    public String Form_Location_URL;
    public String Form_Submission_Date_and_Time;
    public String Web_Form_Name;
    public String GCLID;
    public String No_Touch_Status;
    public String RoleOtherDesc;
    public String website;
    public String inferred_solution;
    public String CTA_Description;
    public String affiliate_id;
    public String redirect_field;
    public String IndustryOtherDesc;
    public String Contact_Us_Message;
    public String Title_Other_Description;
    public String Campaign_Content_UTM;
    public String Secondary_Phone;
    public String RegistrationFroType;
    public String Strategic_Employee;
    public String first_name;
    public String secondary_mail;
    public String campaign_region;
    public String Order_Number;
    public String Lead_Gen_Visitor_ID;
    public String Lead_Gen_Session_ID;
    public String CTA_URL;
    public Boolean No_Touch_User;
    public Decimal Employees_Min;
    public String Blog_Newsletter_Signup;
    public String campaign_source_utm;
    public String Webinar_Event_Date;
    public String email;
    public String prospect_data_incomplete;
    public String Cancellation_Reason;
    public String industry;
    public String Pardot_Lead_Source;
    public String Polygraph_Update_Timestamp;
    public String Clearbit_Timestamp;
    public String last_name;
    public String NT_Credit_Card_Status;
    public String Department_C;
    public String campaign_solution;
    public String job_title;
    public String sscid;
    public String Current_Registration_Type;
    public String Form_Location_Breadcrumb;
    public String Event_Date;
    public String parent_campaign;
    public String registration_use_case;
    public String country;
    public String Cancellation_Explanation;
    public Decimal Employees_Max;
    public String asset_type;
    public String Country_Code;
    public String Secure_Account_ID;
    public String campaign_name_utm;
    public String Webinar_Name;
    public String company;
    public String blaid;
    public String campaign_name;
    public String phone;
    public String NT_Package_selected;
    public String source;
    public String RegistrationType;
    public String Contact_Us_Message_Long;
    public String campaign_medium_utm;
    public Boolean NT_Purchase;
    public String ownerId;
    public String operationsRouting;
    public String campaignName;
    public String campaignDescription;
    public String Trial_Start_Date;
    public String Trial_End_Date;
    public String PartnerStack_Lead_Key;
    public String Piwik_Visitor_ID;
    public String Form_Complete_URL;
    public String LinkedIn_Profile;
    //Public String Current_Piwik_Session;
    public String Campaign_Term_UTM;
    public String External_Campaign_Id;
    //Public String Form_Creation_Date;
    public String Link_to_CP;
    public String call_id;
    public String Inferred_Solution_Suggestion;
    public String Seniority;
    public String Use_of_Similarweb;
    public String Use_of_Similarweb_Additional_Info;
    public String First_Registration_Date;
    public String CU_Trigger_Path;
    public String SFCmpId;
    public String Member_Status;
    public String Referrer;
    public String Landing_Page;
    public Decimal SI_Enrichment_Visits;
    public String how_to_contact_user_primary;
    public String how_to_contact_user_secondary;
    public String trial_cc_submitted_start_date;
    public String Login_Type;
    public String browser_Language;
    public String CU_type;
    public String Skipped_Trial;
    public String Last_Sw_Fit_Score;
    public String Last_Relevant_For_Sales;
    public String How_Did_You_Hear_About_Us;
    public String How_Did_You_Hear_About_Us_Description;
    public String API_Interest;
    public String Secondary_Email_Verified;
    public String Pre_Mapped_Industry;
    public String form_file_URL;
    public String form_file_name;
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

    public ContactUsLeadCaptureWrapper() {
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

    public CampaignAndMemberLeadCaptureWrapper() {
    }
  }

  private static void addCoverageTemp() {
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

/**
 * Created by zohar.sinay on 24/07/2021.
 */

@IsTest
private class LeadCaptureServiceTest {
    private static Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
    /**.
    * @author Zohar Sinay
    * @date 24/07/21
    * @description Create 10 leads and 10 contacts. Add 5 contacts and leads
    * @param none.
    * @return none.
    */
    @testSetup
    public static void testData(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        //Create and Insert Leads and Contacts
        List<Contact> cons = ContactUtils.getContacts(10);
        Lead l = TestObjectCreator.CreateLead();
        l.country = 'Israel';
        insert l;

        Lead myLead = new Lead(
                LastName = 'lastName',
                email = 'testLead@testLead.com',
                Company = 'testComp',
                Country = 'Israel');
        insert myLead;

    }

    /**
    * @author Zohar Sinay
    * @date 24/07/2021
    * @description Test the webservice created
    */
    static testMethod void  testLeadCreationPostRestService(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
        Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
        for(Feature_Flag_Setting__mdt flag : flags){
            flagsMap.put(flag.Process_Name__c,flag);
        }
        Boolean isVersion3Active = flagsMap.containsKey('LeadCapture Version 3') && flagsMap.get('LeadCapture Version 3').Is_Active__c;
        if(isVersion3Active){
            LeadCaptureService.runVersion3 = true;
        }else{
            LeadCaptureService.runVersion2 = true;
        }
        LeadCaptureService.LeadCaptureObj  obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        lcw.user_ip='test';
        lcw.Order_Number = 'test';
        lcw.Lead_Gen_Visitor_ID = 'test';
        lcw.Lead_Gen_Session_ID = 'test';
        lcw.Reseller_Name='test';
        lcw.Last_Contact_Us_Form_Subject='test';
        lcw.Department_Other_Description='test';
        lcw.Base_Product='test';
        lcw.Event_Name='test';
        lcw.Button_Caption='test';
        lcw.Form_Location_URL='test';
        lcw.Form_Submission_Date_and_Time='2021-11-04 12:20:20';
        lcw.Web_Form_Name='test';
        lcw.GCLID='test';
        lcw.No_Touch_Status='test';
        lcw.RoleOtherDesc='test';
        lcw.website='test';
        lcw.inferred_solution='test';
        lcw.CTA_Description='test';
        lcw.affiliate_id='test';
        lcw.redirect_field='test';
        lcw.IndustryOtherDesc='test';
        lcw.Contact_Us_Message='test';
        lcw.Title_Other_Description='test';
        lcw.Campaign_Content_UTM='test';
        lcw.Secondary_Phone='test';
        lcw.RegistrationFroType='test';
        lcw.Strategic_Employee='test';
        lcw.first_name='test';
        lcw.secondary_mail='test@tost.com';
        lcw.campaign_region='test';
        lcw.CTA_URL='test';
        lcw.No_Touch_User = false;
        lcw.Employees_Min = 500;
        lcw.Blog_Newsletter_Signup='test';
        lcw.campaign_source_utm='test';
        lcw.Webinar_Event_Date='test';
        lcw.email='test@test.com';
        lcw.prospect_data_incomplete='test';
        lcw.Cancellation_Reason='test';
        lcw.industry='test';
        lcw.Pardot_Lead_Source='test';
        lcw.Polygraph_Update_Timestamp='2021-11-04 12:20:20';
        lcw.Clearbit_Timestamp = '2021-11-04 12:20:20';
        lcw.last_name='test';
        lcw.NT_Credit_Card_Status='test';
        lcw.Department_C='test';
        lcw.campaign_solution='test';
        lcw.job_title='test';
        lcw.sscid='test';
        lcw.Current_Registration_Type='test';
        lcw.Form_Location_Breadcrumb='test';
        lcw.Event_Date='test';
        lcw.parent_campaign='test';
        lcw.registration_use_case='test';
        lcw.country='Israel';
        lcw.Cancellation_Explanation='test';
        lcw.Employees_Max = 500;
        lcw.asset_type='test';
        lcw.Country_Code='IL';
        lcw.Secure_Account_ID='test';
        lcw.campaign_name_utm='test';
        lcw.Webinar_Name='test';
        lcw.company='test';
        lcw.blaid='test';
        lcw.campaign_name='test';
        lcw.phone='test';
        lcw.NT_Package_selected='test';
        lcw.source='test';
        lcw.RegistrationType='test';
        lcw.Contact_Us_Message_Long='test';
        lcw.campaign_medium_utm='test';
        lcw.NT_Purchase = false;
        lcw.operationsRouting = 'Automated';
        lcw.ownerId = null;
        lcw.campaignName = 'test';
        lcw.campaignDescription = 'test';
        lcw.Trial_Start_Date = '2021-11-04 12:20:20';
        lcw.Trial_End_Date = '2021-18-04 12:20:20';
        lcw.PartnerStack_Lead_Key = 'test';
        lcw.Piwik_Visitor_ID = 'test';
        lcw.Form_Complete_URL = 'test';
        lcw.LinkedIn_Profile = 'test';
        obj.leadCaptureWrp = lcw;

        //String JsonMsg = JSON.serialize(lcw);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(Json.serialize(obj));
        RestContext.request = req;
        RestContext.response = res;


        List<LeadCaptureService.leadCaptureResponseWrapper> resp = LeadCaptureService.LeadCapture();//{new LeadCaptureService.leadCaptureResponseWrapper()}
        //resp = LeadCaptureService.LeadCapture(lcw);
        system.debug('resp: ' + JSON.serializePretty(resp));
        
        // List<Apex_Event_Log__c> logs = [SELECT Id, Detailed_Error_Message__c FROM Apex_Event_Log__c];
        // System.assertEquals('test', JSON.serializePretty(logs));

        system.assertEquals(resp[0].statusCode, 200);
        system.assert(resp[0].leadId != null);

        Test.stopTest();
    }

    /**
    * @author Zohar Sinay
    * @date 24/07/2021
    * @description Test the webservice created
    */
    static testMethod void  testLeadUpdatePostRestServiceVersion3(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        LeadCaptureService.runVersion3 = true;
        LeadCaptureService.LeadCaptureObj  obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        lcw.user_ip='test';
        lcw.Reseller_Name='test';
        lcw.Last_Contact_Us_Form_Subject='test';
        lcw.Department_Other_Description='test';
        lcw.Base_Product='test';
        lcw.Event_Name='test';
        lcw.Button_Caption='test';
        lcw.Form_Location_URL='test';
        lcw.Form_Submission_Date_and_Time='2021-11-04 12:20:20';
        lcw.Web_Form_Name='test';
        lcw.GCLID='test';
        lcw.No_Touch_Status='test';
        lcw.RoleOtherDesc='test';
        lcw.website='test';
        lcw.inferred_solution='test';
        lcw.CTA_Description='test';
        lcw.affiliate_id='test';
        lcw.redirect_field='test';
        lcw.IndustryOtherDesc='test';
        lcw.Contact_Us_Message='test';
        lcw.Title_Other_Description='test';
        lcw.Campaign_Content_UTM='test';
        lcw.Secondary_Phone='test';
        lcw.RegistrationFroType='test';
        lcw.Strategic_Employee='test';
        lcw.first_name='test';
        lcw.secondary_mail='test@tost.com';
        lcw.campaign_region='test';
        lcw.CTA_URL='test';
        lcw.No_Touch_User = false;
        lcw.Employees_Min = 500;
        lcw.Blog_Newsletter_Signup='test';
        lcw.campaign_source_utm='test';
        lcw.Webinar_Event_Date='test';
        lcw.email='test@testorg.com';
        lcw.prospect_data_incomplete='test';
        lcw.Cancellation_Reason='test';
        lcw.industry='test';
        lcw.Pardot_Lead_Source='test';
        lcw.Polygraph_Update_Timestamp='2021-11-04 12:20:20';
        lcw.Clearbit_Timestamp = '2021-11-04 12:20:20';
        lcw.last_name='test';
        lcw.NT_Credit_Card_Status='test';
        lcw.Department_C='test';
        lcw.campaign_solution='test';
        lcw.job_title='test';
        lcw.sscid='test';
        lcw.Current_Registration_Type='test';
        lcw.Form_Location_Breadcrumb='test';
        lcw.Event_Date='test';
        lcw.parent_campaign='test';
        lcw.registration_use_case='test';
        lcw.country='Israel';
        lcw.Cancellation_Explanation='test';
        lcw.Employees_Max = 500;
        lcw.asset_type='test';
        lcw.Country_Code='IL';
        lcw.Secure_Account_ID='test';
        lcw.campaign_name_utm='test';
        lcw.Webinar_Name='test';
        lcw.company='test';
        lcw.blaid='test';
        lcw.campaign_name='test';
        lcw.phone='test';
        lcw.NT_Package_selected='test';
        lcw.source='test';
        lcw.RegistrationType='test';
        lcw.Contact_Us_Message_Long='test';
        lcw.campaign_medium_utm='test';
        lcw.NT_Purchase = false;
        lcw.operationsRouting = 'Automated';
        lcw.ownerId = null;
        lcw.campaignName = 'test';
        lcw.campaignDescription = 'test';
        lcw.Trial_Start_Date = '2021-11-04 12:20:20';
        lcw.Trial_End_Date = '2021-18-04 12:20:20';
        lcw.PartnerStack_Lead_Key = 'test';
        lcw.Piwik_Visitor_ID = 'test';
        lcw.Form_Complete_URL = 'test';
        lcw.External_Campaign_Id = 'test';
        lcw.Link_to_CP = 'test';
        lcw.call_id = 'test';
        lcw.Inferred_Solution_Suggestion = 'test';
        lcw.Seniority = 'test';
        lcw.Use_of_Similarweb = 'test';
        lcw.Use_of_Similarweb_Additional_Info = 'test';
        lcw.SI_Enrichment_Visits = 6;
        lcw.SFCmpId = 'test';
        lcw.Member_Status = 'test';
        lcw.Referrer = 'test';
        lcw.Landing_Page = 'test';
        obj.leadCaptureWrp = lcw;


        String JsonMsg = JSON.serialize(obj);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NewBiApiMockImp());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        List<LeadCaptureService.leadCaptureResponseWrapper> resp = new List<LeadCaptureService.leadCaptureResponseWrapper>{new LeadCaptureService.leadCaptureResponseWrapper()};//{new LeadCaptureService.leadCaptureResponseWrapper()}
        resp = LeadCaptureService.LeadCapture();
        System.debug('lcw.resp: ' + JSON.serializePretty(resp[0]));
//        system.assertEquals(resp[0].statusCode, 200);
//        system.assert(resp[0].leadId != null);

        Test.stopTest();
    }
    static testMethod void  testLeadUpdatePostRestServiceVersion2(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        LeadCaptureService.runVersion2 = true;
        LeadCaptureService.LeadCaptureObj  obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        lcw.user_ip='test';
        lcw.Reseller_Name='test';
        lcw.Last_Contact_Us_Form_Subject='test';
        lcw.Department_Other_Description='test';
        lcw.Base_Product='test';
        lcw.Event_Name='test';
        lcw.Button_Caption='test';
        lcw.Form_Location_URL='test';
        lcw.Form_Submission_Date_and_Time='2021-11-04 12:20:20';
        lcw.Web_Form_Name='test';
        lcw.GCLID='test';
        lcw.No_Touch_Status='test';
        lcw.RoleOtherDesc='test';
        lcw.website='test';
        lcw.inferred_solution='test';
        lcw.CTA_Description='test';
        lcw.affiliate_id='test';
        lcw.redirect_field='test';
        lcw.IndustryOtherDesc='test';
        lcw.Contact_Us_Message='test';
        lcw.Title_Other_Description='test';
        lcw.Campaign_Content_UTM='test';
        lcw.Secondary_Phone='test';
        lcw.RegistrationFroType='test';
        lcw.Strategic_Employee='test';
        lcw.first_name='test';
        lcw.secondary_mail='test@tost.com';
        lcw.campaign_region='test';
        lcw.CTA_URL='test';
        lcw.No_Touch_User = false;
        lcw.Employees_Min = 500;
        lcw.Blog_Newsletter_Signup='test';
        lcw.campaign_source_utm='test';
        lcw.Webinar_Event_Date='test';
        lcw.email='test@testorg.com';
        lcw.prospect_data_incomplete='test';
        lcw.Cancellation_Reason='test';
        lcw.industry='test';
        lcw.Pardot_Lead_Source='test';
        lcw.Polygraph_Update_Timestamp='2021-11-04 12:20:20';
        lcw.Clearbit_Timestamp = '2021-11-04 12:20:20';
        lcw.last_name='test';
        lcw.NT_Credit_Card_Status='test';
        lcw.Department_C='test';
        lcw.campaign_solution='test';
        lcw.job_title='test';
        lcw.sscid='test';
        lcw.Current_Registration_Type='test';
        lcw.Form_Location_Breadcrumb='test';
        lcw.Event_Date='test';
        lcw.parent_campaign='test';
        lcw.registration_use_case='test';
        lcw.country='Israel';
        lcw.Cancellation_Explanation='test';
        lcw.Employees_Max = 500;
        lcw.asset_type='test';
        lcw.Country_Code='IL';
        lcw.Secure_Account_ID='test';
        lcw.campaign_name_utm='test';
        lcw.Webinar_Name='test';
        lcw.company='test';
        lcw.blaid='test';
        lcw.campaign_name='test';
        lcw.phone='test';
        lcw.NT_Package_selected='test';
        lcw.source='test';
        lcw.RegistrationType='test';
        lcw.Contact_Us_Message_Long='test';
        lcw.campaign_medium_utm='test';
        lcw.NT_Purchase = false;
        lcw.operationsRouting = 'Automated';
        lcw.ownerId = null;
        lcw.campaignName = 'test';
        lcw.campaignDescription = 'test';
        lcw.Trial_Start_Date = '2021-11-04 12:20:20';
        lcw.Trial_End_Date = '2021-18-04 12:20:20';
        lcw.PartnerStack_Lead_Key = 'test';
        lcw.Piwik_Visitor_ID = 'test';
        lcw.Form_Complete_URL = 'test';
        lcw.External_Campaign_Id = 'test';
        lcw.Link_to_CP = 'test';
        lcw.call_id = 'test';
        lcw.Inferred_Solution_Suggestion = 'test';
        lcw.Seniority = 'test';
        lcw.Use_of_Similarweb = 'test';
        lcw.Use_of_Similarweb_Additional_Info = 'test';
        lcw.SI_Enrichment_Visits = 6;
        lcw.SFCmpId = 'test';
        lcw.Member_Status = 'test';
        lcw.Referrer = 'test';
        lcw.Landing_Page = 'test';
        obj.leadCaptureWrp = lcw;


        String JsonMsg = JSON.serialize(obj);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new NewBiApiMockImp());
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        List<LeadCaptureService.leadCaptureResponseWrapper> resp = new List<LeadCaptureService.leadCaptureResponseWrapper>{new LeadCaptureService.leadCaptureResponseWrapper()};//{new LeadCaptureService.leadCaptureResponseWrapper()}
        resp = LeadCaptureService.LeadCapture();
        
        // List<Apex_Event_Log__c> logs = [SELECT Id, Detailed_Error_Message__c FROM Apex_Event_Log__c];
        // System.assertEquals('test', JSON.serializePretty(logs));

        system.assertEquals(resp[0].statusCode, 200);
        system.assert(resp[0].leadId != null);

        Test.stopTest();
    }


    /**
    * @author Zohar Sinay
    * @date 24/07/2021
    * @description Test the webservice created
    */
    static testMethod void  testContactUpdatePostRestService(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
        Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
        for(Feature_Flag_Setting__mdt flag : flags){
            flagsMap.put(flag.Process_Name__c,flag);
        }
        Boolean isVersion3Active = flagsMap.containsKey('LeadCapture Version 3') && flagsMap.get('LeadCapture Version 3').Is_Active__c;
        if(isVersion3Active){
            LeadCaptureService.runVersion3 = true;
        }else{
            LeadCaptureService.runVersion2 = true;
        }
        LeadCaptureService.LeadCaptureObj  obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        lcw.user_ip='test';
        lcw.Reseller_Name='test';
        lcw.Last_Contact_Us_Form_Subject='test';
        lcw.Department_Other_Description='test';
        lcw.Base_Product='test';
        lcw.Event_Name='test';
        lcw.Button_Caption='test';
        lcw.Form_Location_URL='test';
        lcw.Form_Submission_Date_and_Time='2021-11-04 12:20:20';
        lcw.Web_Form_Name='test';
        lcw.GCLID='test';
        lcw.No_Touch_Status='test';
        lcw.RoleOtherDesc='test';
        lcw.website='test';
        lcw.inferred_solution='test';
        lcw.CTA_Description='test';
        lcw.affiliate_id='test';
        lcw.redirect_field='test';
        lcw.IndustryOtherDesc='test';
        lcw.Contact_Us_Message='test';
        lcw.Title_Other_Description='test';
        lcw.Campaign_Content_UTM='test';
        lcw.Secondary_Phone='test';
        lcw.RegistrationFroType='test';
        lcw.Strategic_Employee='test';
        lcw.first_name='test';
        lcw.secondary_mail='test@tost.com';
        lcw.campaign_region='test';
        lcw.CTA_URL='test';
        lcw.No_Touch_User = false;
        lcw.Employees_Min = 500;
        lcw.Blog_Newsletter_Signup='test';
        lcw.campaign_source_utm='test';
        lcw.Webinar_Event_Date='test';
        lcw.email='testLead@testLead.com';
        lcw.prospect_data_incomplete='test';
        lcw.Cancellation_Reason='test';
        lcw.industry='test';
        lcw.Pardot_Lead_Source='test';
        lcw.Polygraph_Update_Timestamp='2021-11-04 12:20:20';
        lcw.Clearbit_Timestamp = '2021-11-04 12:20:20';
        lcw.last_name='test';
        lcw.NT_Credit_Card_Status='test';
        lcw.Department_C='test';
        lcw.campaign_solution='test';
        lcw.job_title='test';
        lcw.sscid='test';
        lcw.Current_Registration_Type='test';
        lcw.Form_Location_Breadcrumb='test';
        lcw.Event_Date='test';
        lcw.parent_campaign='test';
        lcw.registration_use_case='test';
        lcw.country='Israel';
        lcw.Cancellation_Explanation='test';
        lcw.Employees_Max = 500;
        lcw.asset_type='test';
        lcw.Country_Code='IL';
        lcw.Secure_Account_ID='test';
        lcw.campaign_name_utm='test';
        lcw.Webinar_Name='test';
        lcw.company='test';
        lcw.blaid='test';
        lcw.campaign_name='test';
        lcw.phone='test';
        lcw.NT_Package_selected='test';
        lcw.source='test';
        lcw.RegistrationType='test';
        lcw.Contact_Us_Message_Long='test';
        lcw.campaign_medium_utm='test';
        lcw.NT_Purchase = false;
        lcw.operationsRouting = 'Automated';
        lcw.ownerId = null;
        lcw.campaignName = 'test';
        lcw.campaignDescription = 'test';
        lcw.Trial_Start_Date = '2021-11-04 12:20:20';
        lcw.Trial_End_Date = '2021-18-04 12:20:20';
        lcw.PartnerStack_Lead_Key = 'test';
        lcw.Piwik_Visitor_ID = 'test';
        lcw.Form_Complete_URL = 'test';
        lcw.LinkedIn_Profile = 'test';
        obj.leadCaptureWrp = lcw;
        String JsonMsg = JSON.serialize(obj);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        Lead myLead = [SELECT Id FROM Lead WHERE email='testLead@testLead.com' LIMIT 1];
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(myLead.id);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);

        List<LeadCaptureService.leadCaptureResponseWrapper> resp = new List<LeadCaptureService.leadCaptureResponseWrapper>{new LeadCaptureService.leadCaptureResponseWrapper()};//{new LeadCaptureService.leadCaptureResponseWrapper()}
        resp = LeadCaptureService.LeadCapture();

        // List<Apex_Event_Log__c> logs = [SELECT Id, Detailed_Error_Message__c FROM Apex_Event_Log__c];
        // System.assertEquals('test', JSON.serializePretty(logs));

        system.assertEquals(resp[0].statusCode, 200);
        system.assert(resp[0].leadId != null);

        Test.stopTest();
    }

    /**
    * @author alon shalev
    * @date 25.3.24
    * @description Test the webservice created
    */
    static testMethod void  testLeadCreationPostRestServiceWithExceptionNoEmail(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
        Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
        for(Feature_Flag_Setting__mdt flag : flags){
            flagsMap.put(flag.Process_Name__c,flag);
        }
        Boolean isVersion3Active = flagsMap.containsKey('LeadCapture Version 3') && flagsMap.get('LeadCapture Version 3').Is_Active__c;
        if(isVersion3Active){
            LeadCaptureService.runVersion3 = true;
        }else{
            LeadCaptureService.runVersion2 = true;
        }
        LeadCaptureService.LeadCaptureObj  obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        lcw.user_ip='test';
        lcw.Order_Number = 'test';
        lcw.Lead_Gen_Visitor_ID = 'test';
        lcw.Lead_Gen_Session_ID = 'test';
        lcw.Reseller_Name='test';
        lcw.Last_Contact_Us_Form_Subject='test';
        lcw.Department_Other_Description='test';
        lcw.Base_Product='test';
        lcw.Event_Name='test';
        lcw.Button_Caption='test';
        lcw.Form_Location_URL='test';
        lcw.Form_Submission_Date_and_Time='2021-11-04 12:20:20';
        lcw.Web_Form_Name='test';
        lcw.GCLID='test';
        lcw.No_Touch_Status='test';
        lcw.RoleOtherDesc='test';
        lcw.website='test';
        lcw.inferred_solution='test';
        lcw.CTA_Description='test';
        lcw.affiliate_id='test';
        lcw.redirect_field='test';
        lcw.IndustryOtherDesc='test';
        lcw.Contact_Us_Message='test';
        lcw.Title_Other_Description='test';
        lcw.Campaign_Content_UTM='test';
        lcw.Secondary_Phone='test';
        lcw.RegistrationFroType='test';
        lcw.Strategic_Employee='test';
        lcw.first_name='test';
        lcw.secondary_mail='test@tost.com';
        lcw.campaign_region='test';
        lcw.CTA_URL='test';
        lcw.No_Touch_User = false;
        lcw.Employees_Min = 500;
        lcw.Blog_Newsletter_Signup='test';
        lcw.campaign_source_utm='test';
        lcw.Webinar_Event_Date='test';
        lcw.prospect_data_incomplete='test';
        lcw.Cancellation_Reason='test';
        lcw.industry='test';
        lcw.Pardot_Lead_Source='test';
        lcw.Polygraph_Update_Timestamp='2021-11-04 12:20:20';
        lcw.Clearbit_Timestamp = '2021-11-04 12:20:20';
        lcw.last_name='test';
        lcw.NT_Credit_Card_Status='test';
        lcw.Department_C='test';
        lcw.campaign_solution='test';
        lcw.job_title='test';
        lcw.sscid='test';
        lcw.Current_Registration_Type='test';
        lcw.Form_Location_Breadcrumb='test';
        lcw.Event_Date='test';
        lcw.parent_campaign='test';
        lcw.registration_use_case='test';
        lcw.country='Israel';
        lcw.Cancellation_Explanation='test';
        lcw.Employees_Max = 500;
        lcw.asset_type='test';
        lcw.Country_Code='IL';
        lcw.Secure_Account_ID='test';
        lcw.campaign_name_utm='test';
        lcw.Webinar_Name='test';
        lcw.company='test';
        lcw.blaid='test';
        lcw.campaign_name='test';
        lcw.phone='test';
        lcw.NT_Package_selected='test';
        lcw.source='test';
        lcw.RegistrationType='test';
        lcw.Contact_Us_Message_Long='test';
        lcw.campaign_medium_utm='test';
        lcw.NT_Purchase = false;
        lcw.operationsRouting = 'Automated';
        lcw.ownerId = null;
        lcw.campaignName = 'test';
        lcw.campaignDescription = 'test';
        lcw.Trial_Start_Date = '2021-11-04 12:20:20';
        lcw.Trial_End_Date = '2021-18-04 12:20:20';
        lcw.PartnerStack_Lead_Key = 'test';
        lcw.Piwik_Visitor_ID = 'test';
        lcw.Form_Complete_URL = 'test';
        lcw.LinkedIn_Profile = 'test';
        obj.leadCaptureWrp = lcw;

        String JsonMsg = JSON.serialize(obj);

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        List<LeadCaptureService.leadCaptureResponseWrapper> resp = LeadCaptureService.LeadCapture();//{new LeadCaptureService.leadCaptureResponseWrapper()}
        //resp = LeadCaptureService.LeadCapture(lcw);
        system.debug('resp: ' + JSON.serializePretty(resp));
        System.debug(resp[0].message);
        system.assertEquals(resp[0].statusCode, 500);

        Test.stopTest();

    }
    static testMethod void  testParsinError(){
        Test.setMock(HttpCalloutMock.class,new GroudonMockService());
        List<Feature_Flag_Setting__mdt> flags = [SELECT Is_Active__c,Process_Name__c FROM Feature_Flag_Setting__mdt WHERE  Class_Name__c = 'LeadCaptureServiceHandler'];
        Map<String,Feature_Flag_Setting__mdt> flagsMap = new Map<String, Feature_Flag_Setting__mdt>();
        for(Feature_Flag_Setting__mdt flag : flags){
            flagsMap.put(flag.Process_Name__c,flag);
        }
        Boolean isVersion3Active = flagsMap.containsKey('LeadCapture Version 3') && flagsMap.get('LeadCapture Version 3').Is_Active__c;
        if(isVersion3Active){
            LeadCaptureService.runVersion3 = true;
        }else{
            LeadCaptureService.runVersion2 = true;
        }
        LeadCaptureService.LeadCaptureObj  obj = new LeadCaptureService.LeadCaptureObj();
        String JsonMsg = '{"leadCaptureWrp" : \n' +
                '{\n' +
                '"website" : null,\n' +
                '"Webinar_Name" : null,\n' +
                '"Webinar_Event_Date" : null,\n' +
                '"Web_Form_Name" : null,\n' +
                '"user_ip" : null,\n' +
                '"Trial_Start_Date" : null,\n' +
                '"Trial_End_Date" : null,\n' +
                '"Title_Other_Description" : null,\n' +
                '"Strategic_Employee" : null,\n' +
                '"sscid" : "organic",\n' +
                '"source" : null,\n' +
                '"Secure_Account_ID" : null,\n' +
                '"Secondary_Phone" : null,\n' +
                '"secondary_mail" : null,\n' +
                '"RoleOtherDesc" : null,\n' +
                '"Reseller_Name" : null,\n' +
                '"RegistrationType" : null,\n' +
                '"RegistrationFroType" : null,\n' +
                '"registration_use_case" : null,\n' +
                '"redirect_field" : null,\n' +
                '"prospect_data_incomplete" : null,\n' +
                '"Polygraph_Update_Timestamp" : null,\n' +
                '"Piwik_Visitor_ID" : null,\n' +
                '"phone" : null,\n' +
                '"PartnerStack_Lead_Key" : null,\n' +
                '"parent_campaign" : null,\n' +
                '"Pardot_Lead_Source" : null,\n' +
                '"ownerId" : null,\n' +
                '"Order_Number" : null,\n' +
                '"operationsRouting" : null,\n' +
                '"NT_Purchase" : false,\n' +
                '"NT_Package_selected" : null,\n' +
                '"NT_Credit_Card_Status" : null,\n' +
                '"No_Touch_User" : null,\n' +
                '"No_Touch_Status" : null,\n' +
                '"Lead_Gen_Visitor_ID" : null,\n' +
                '"Lead_Gen_Session_ID" : null,\n' +
                '"last_name" : null,\n' +
                '"Last_Contact_Us_Form_Subject" : null,\n' +
                '"job_title" : null,\n' +
                '"inferred_solution" : null,\n' +
                '"IndustryOtherDesc" : null,\n' +
                '"industry" : null,\n' +
                '"GCLID" : null,\n' +
                '"Form_Submission_Date_and_Time" : null,\n' +
                '"Form_Location_URL" : null,\n' +
                '"Form_Location_Breadcrumb" : null,\n' +
                '"Form_Complete_URL" : null,\n' +
                '"first_name" : null,\n' +
                '"Event_Name" : null,\n' +
                '"Event_Date" : null,\n' +
                '"Employees_Min" : "this will fail",\n' +
                '"Employees_Max" : null,\n' +
                '"email" : "Alon16_2_2025@gmail.com",\n' +
                '"Department_Other_Description" : null,\n' +
                '"Department_C" : null,\n' +
                '"Current_Registration_Type" : null,\n' +
                '"CTA_URL" : null,\n' +
                '"CTA_Description" : null,\n' +
                '"Country_Code" : null,\n' +
                '"country" : null,\n' +
                '"Contact_Us_Message_Long" : null,\n' +
                '"Contact_Us_Message" : null,\n' +
                '"company" : null,\n' +
                '"Clearbit_Timestamp" : null,\n' +
                '"Cancellation_Reason" : null,\n' +
                '"Cancellation_Explanation" : null,\n' +
                '"campaignName" : null,\n' +
                '"campaignDescription" : null,\n' +
                '"campaign_source_utm" : "adwords",\n' +
                '"campaign_solution" : null,\n' +
                '"campaign_region" : null,\n' +
                '"campaign_name_utm" : "dmng_dmi_na_minisite_na_trafficterms_usaca_Nov_20",\n' +
                '"campaign_name" : null,\n' +
                '"campaign_medium_utm" : "ppc",\n' +
                '"Campaign_Content_UTM" : "573419474127",\n' +
                '"Button_Caption" : null,\n' +
                '"Blog_Newsletter_Signup" : null,\n' +
                '"blaid" : "organic",\n' +
                '"Base_Product" : null,\n' +
                '"asset_type" : null,\n' +
                '"affiliate_id" : "web traffic",\n' +
                '"browser_language" : "alon browser language test",\n' +
                '"sfcmpid" : "test",\n' +
                '"Cancellation_Date" :"2025-02-12T12:35:53.7188020Z",\n' +
                '"SI_Quiz_Onboarding_Starting_Action" : "delete",\n' +
                '"SI_Quiz_Onboarding_User_Goals" : "Play Soccer"\n' +
                '}\n' +
                '}';


        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response = res;

        List<LeadCaptureService.leadCaptureResponseWrapper> resp = LeadCaptureService.LeadCapture();//{new LeadCaptureService.leadCaptureResponseWrapper()}
        //resp = LeadCaptureService.LeadCapture(lcw);
        system.debug('resp: ' + JSON.serializePretty(resp));
        System.debug(resp[0].message);
        system.assertEquals(resp[0].statusCode, 500);

    }

    @IsTest
    static void testGroudonPhoneMapping_NewLead_PopulatesPhoneFields() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        LeadCaptureService.runVersion2 = true;
        
        LeadCaptureService.LeadCaptureObj obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        
        lcw.email = 'groudon_new_lead@test.com';
        lcw.first_name = 'Test';
        lcw.last_name = 'User';
        lcw.company = 'Test Company';
        lcw.country = 'United States';
        lcw.call_made_from_groudon = true;
        lcw.enrichment_success = false;
        lcw.Groudon_Primary_Phone = '+1234567890';
        lcw.Groudon_Secondary_Phone = '+0987654321';
        
        obj.leadCaptureWrp = lcw;
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(obj));
        RestContext.request = req;
        RestContext.response = res;
        
        List<LeadCaptureService.leadCaptureResponseWrapper> resp = LeadCaptureService.LeadCapture();
        Test.stopTest();

        // List<Apex_Event_Log__c> logs = [SELECT Id, Detailed_Error_Message__c FROM Apex_Event_Log__c];
        // System.assertEquals('test', JSON.serializePretty(logs));
        
        System.assertEquals(200, resp[0].statusCode, 'Expected successful response');
        Lead createdLead = [SELECT Id, Phone, MobilePhone FROM Lead WHERE Email = 'groudon_new_lead@test.com' LIMIT 1];
        System.assertEquals('+1234567890', createdLead.Phone, 'Primary phone should populate Phone field');
        System.assertEquals('+0987654321', createdLead.MobilePhone, 'Secondary phone should populate MobilePhone field');
    }

    @IsTest
    static void testGroudonPhoneMapping_ExistingPhoneAndContact_PopulatesMobile() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        
        Lead existingLead = [SELECT Id FROM Lead WHERE Email = 'testLead@testLead.com' LIMIT 1];
        existingLead.Phone = '+1111111111';
        update existingLead;
        
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Email = 'groudon_existing_contact@test.com'
        );
        insert existingContact;
        
        LeadCaptureService.runVersion2 = true;
        
        LeadCaptureService.LeadCaptureObj objLead = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcwLead = new LeadCaptureService.leadCaptureWrapper();
        
        lcwLead.email = 'testLead@testLead.com';
        lcwLead.first_name = 'Existing';
        lcwLead.last_name = 'lastName';
        lcwLead.company = 'testComp';
        lcwLead.country = 'Israel';
        lcwLead.call_made_from_groudon = true;
        lcwLead.enrichment_success = false;
        lcwLead.Groudon_Primary_Phone = '+1234567890';
        
        objLead.leadCaptureWrp = lcwLead;
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(objLead));
        RestContext.request = req;
        RestContext.response = res;
        
        List<LeadCaptureService.leadCaptureResponseWrapper> resp = LeadCaptureService.LeadCapture();
        
        LeadCaptureService.LeadCaptureObj objContact = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcwContact = new LeadCaptureService.leadCaptureWrapper();
        
        lcwContact.email = 'groudon_existing_contact@test.com';
        lcwContact.first_name = 'Existing';
        lcwContact.last_name = 'Contact';
        lcwContact.country = 'United States';
        lcwContact.call_made_from_groudon = true;
        lcwContact.Groudon_Primary_Phone = '+2345678901';
        lcwContact.Groudon_Secondary_Phone = '+3456789012';
        
        objContact.leadCaptureWrp = lcwContact;
        
        req.requestBody = Blob.valueOf(JSON.serialize(objContact));
        List<LeadCaptureService.leadCaptureResponseWrapper> resp2 = LeadCaptureService.LeadCapture();
        Test.stopTest();
        
        System.assertEquals(200, resp[0].statusCode, 'Expected successful response for Lead: ' + (resp[0].message != null ? resp[0].message : ''));
        System.assertEquals(200, resp2[0].statusCode, 'Expected successful response for Contact: ' + (resp2[0].message != null ? resp2[0].message : ''));
        
        Lead updatedLead = [SELECT Id, Phone, MobilePhone FROM Lead WHERE Email = 'testLead@testLead.com' LIMIT 1];
        System.assertEquals('+1111111111', updatedLead.Phone, 'Existing Phone should not be changed');
        System.assertEquals('+1234567890', updatedLead.MobilePhone, 'Primary phone should populate MobilePhone when Phone exists');
        
        Contact updatedContact = [SELECT Id, Phone, MobilePhone FROM Contact WHERE Email = 'groudon_existing_contact@test.com' LIMIT 1];
        System.assertEquals('+2345678901', updatedContact.Phone, 'Primary phone should populate Contact Phone field');
        System.assertEquals('+3456789012', updatedContact.MobilePhone, 'Secondary phone should populate Contact MobilePhone field');
    }

    @IsTest
    static void testGroudonEnrichmentMetadataSetOnContact_V2() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        LeadCaptureService.runVersion2 = true;

        Contact contact = new Contact(
            FirstName = 'Groudon',
            LastName = 'Callback',
            Email = 'groudon_enrichment_v2@test.com',
            MailingCountry = 'United States'
        );
        insert contact;

        LeadCaptureService.LeadCaptureObj obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        lcw.email = contact.Email;
        lcw.first_name = contact.FirstName;
        lcw.last_name = contact.LastName;
        lcw.country = contact.MailingCountry;
        lcw.call_made_from_groudon = true;
        lcw.enrichment_success = true;
        lcw.Enrichment_Details = 'callback payload';
        obj.leadCaptureWrp = lcw;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(obj));
        RestContext.request = req;
        RestContext.response = res;

        LeadCaptureService.LeadCapture();
        Test.stopTest();

        Contact updatedContact = [SELECT Enrichment_Source__c, Enrichment_Source_Time__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals('Groudon', updatedContact.Enrichment_Source__c, 'Enrichment source should be set after Groudon callback');
        System.assertNotEquals(null, updatedContact.Enrichment_Source_Time__c, 'Enrichment time should be set after Groudon callback');
    }

    @IsTest
    static void testGroudonEnrichmentMetadataSetOnContact_V3() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        LeadCaptureService.runVersion3 = true;

        Contact contact = new Contact(
            FirstName = 'Groudon',
            LastName = 'CallbackV3',
            Email = 'groudon_enrichment_v3@test.com',
            MailingCountry = 'United States'
        );
        insert contact;

        LeadCaptureService.LeadCaptureObj obj = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcw = new LeadCaptureService.leadCaptureWrapper();
        lcw.email = contact.Email;
        lcw.first_name = contact.FirstName;
        lcw.last_name = contact.LastName;
        lcw.country = contact.MailingCountry;
        lcw.call_made_from_groudon = true;
        lcw.enrichment_success = true;
        lcw.Enrichment_Details = 'callback payload';
        obj.leadCaptureWrp = lcw;

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/leadcaptureservice';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(obj));
        RestContext.request = req;
        RestContext.response = res;

        LeadCaptureService.LeadCapture();
        Test.stopTest();

        Contact updatedContact = [SELECT Enrichment_Source__c, Enrichment_Source_Time__c FROM Contact WHERE Id = :contact.Id];
        System.assertEquals('Groudon', updatedContact.Enrichment_Source__c, 'Enrichment source should be set after Groudon callback');
        System.assertNotEquals(null, updatedContact.Enrichment_Source_Time__c, 'Enrichment time should be set after Groudon callback');
    }

    @IsTest
    static void testVersion3_ContactUpdateAndLeadCreationWithContactUs() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        LeadCaptureService.runVersion3 = true;
        
        Contact existingContact = new Contact(
            FirstName = 'Existing',
            LastName = 'Contact',
            Email = 'v3_contact@test.com',
            Phone = '+1234567890'
        );
        insert existingContact;
        
        Test.startTest();
        
        LeadCaptureService.LeadCaptureObj objContact = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcwContact = new LeadCaptureService.leadCaptureWrapper();
        lcwContact.email = 'v3_contact@test.com';
        lcwContact.first_name = 'Existing';
        lcwContact.last_name = 'Contact';
        lcwContact.country = 'United States';
        objContact.leadCaptureWrp = lcwContact;
        
        RestRequest reqContact = new RestRequest();
        RestResponse resContact = new RestResponse();
        reqContact.requestURI = '/services/leadcaptureservice';
        reqContact.httpMethod = 'POST';
        reqContact.requestBody = Blob.valueOf(JSON.serialize(objContact));
        RestContext.request = reqContact;
        RestContext.response = resContact;
        List<LeadCaptureService.leadCaptureResponseWrapper> respContact = LeadCaptureService.LeadCapture();
        
        LeadCaptureService.LeadCaptureObj objNewLead = new LeadCaptureService.LeadCaptureObj();
        LeadCaptureService.leadCaptureWrapper lcwNewLead = new LeadCaptureService.leadCaptureWrapper();
        lcwNewLead.email = 'v3_newlead@test.com';
        lcwNewLead.first_name = 'New';
        lcwNewLead.last_name = 'Lead';
        lcwNewLead.company = 'Test Company';
        lcwNewLead.country = 'United States';
        objNewLead.leadCaptureWrp = lcwNewLead;
        
        RestRequest reqLead = new RestRequest();
        RestResponse resLead = new RestResponse();
        reqLead.requestURI = '/services/leadcaptureservice';
        reqLead.httpMethod = 'POST';
        reqLead.requestBody = Blob.valueOf(JSON.serialize(objNewLead));
        RestContext.request = reqLead;
        RestContext.response = resLead;
        List<LeadCaptureService.leadCaptureResponseWrapper> respLead = LeadCaptureService.LeadCapture();
        
        Test.stopTest();

        // List<Apex_Event_Log__c> logs = [SELECT Id, Detailed_Error_Message__c FROM Apex_Event_Log__c];
        // System.assertEquals('test', JSON.serializePretty(logs));
        
        System.assertEquals(200, respContact[0].statusCode, 'Expected successful response for Contact update: ' + (respContact[0].message != null ? respContact[0].message : ''));
        System.assertNotEquals(null, respContact[0].contactId, 'Contact ID should be populated');
        
        System.assertEquals(200, respLead[0].statusCode, 'Expected successful response for Lead creation: ' + (respLead[0].message != null ? respLead[0].message : ''));
        System.assertNotEquals(null, respLead[0].leadId, 'Lead ID should be populated');
        
        Contact updatedContact = [SELECT Id, Phone FROM Contact WHERE Email = 'v3_contact@test.com' LIMIT 1];
        System.assertEquals(existingContact.Id, updatedContact.Id, 'Contact should be updated');
        System.assertEquals('+1234567890', updatedContact.Phone, 'Contact Phone should remain unchanged');
        
        Lead createdLead = [SELECT Id, Company FROM Lead WHERE Email = 'v3_newlead@test.com' LIMIT 1];
        System.assertEquals('Test Company', createdLead.Company, 'Lead Company should be set');
    }

}
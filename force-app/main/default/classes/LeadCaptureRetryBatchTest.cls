/**
 * Created by zohar.sinay on 12/04/2022.
 */
@IsTest
public class LeadCaptureRetryBatchTest {

    @testSetup
    static void setup(){
        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
        iss.Name='Default Value';
        iss.Value__c='Sales';
        insert iss;
    }

    /**
    * @author Zohar Sinay
    * @date 5/04/2022
    * @description Test the webservice created
    */
    static testMethod void  testLeadCreationPostRestService(){
        Test.startTest();
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
        lcw.inferred_solution='';
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
        lcw.Polygraph_Update_Timestamp='test';
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
        lcw.country='test';
        lcw.Cancellation_Explanation='test';
        lcw.Employees_Max = 500;
        lcw.asset_type='test';
        lcw.Country_Code='test';
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

        String JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');
        lcw.email = 'test1@test.com';
        JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');
        lcw.email = 'test2@test.com';
        JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');
        lcw.email = 'test3@test.com';
        JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');
        lcw.email = 'test4@test.com';
        JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');
        lcw.email = 'test5@test.com';
        JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');
        lcw.email = 'test6@test.com';
        JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');
        lcw.email = 'test7@test.com';
        JsonMsg = JSON.serialize(lcw);
        insert new Apex_Event_Log__c(HTTP_Body__c = JsonMsg, Log_Type__c = 'Error', Retry_Number__c = 0, Max_Number_Of_Retries__c = 2, Apex_class__c = 'LeadCaptureServiceHandler');

        LeadCaptureRetryBatch.checkIfLimitsBreach(null);
        Database.executeBatch(new LeadCaptureRetryBatch(7), 100);
        Test.stopTest();
        System.debug('test: ' + JSON.serializePretty([SELECT Id, HTTP_Body__c,Retry_Number__c FROM Apex_Event_Log__c]));
    }
}
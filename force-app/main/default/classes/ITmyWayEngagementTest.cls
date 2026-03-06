@isTest(seealldata=true)
public class ITmyWayEngagementTest {
    static TestMethod void insertTest(){
        Lead ld = new Lead(Company='testcomp',LastName='testld1',Form_Submission_Date_and_Time__c=System.Now(),Web_Form_Name__c='64k8mn',Email='test@gmail.com');
        insert ld;
        Account acc = new Account(Name='test');
        insert acc;
        Contact con = new Contact(Accountid=acc.id,LastName='testld1',Form_Submission_Date_and_Time__c=System.Now(),Web_Form_Name__c='64k8mn',Email='test2@gmail.com');
        insert con;
        ld.Form_Submission_Date_and_Time__c=System.Now();
        con.Form_Submission_Date_and_Time__c=System.Now();
        update ld;
        update con;
    }
    static TestMethod void updateTest(){
        Lead ld = [select id,Form_Submission_Date_and_Time__c,Web_Form_Name__c from Lead limit 1];
        Contact con = [select id,Form_Submission_Date_and_Time__c,Web_Form_Name__c from Contact limit 1];
        ld.Form_Submission_Date_and_Time__c=System.Now();
        ld.Web_Form_Name__c = '64k8ml';
        con.Form_Submission_Date_and_Time__c=System.Now();
        con.Web_Form_Name__c = '64k8ml';
        update ld;
        update con;
        ld.Form_Submission_Date_and_Time__c=System.Now();
        ld.Web_Form_Name__c = 'Event';
        con.Form_Submission_Date_and_Time__c=System.Now();
        con.Web_Form_Name__c = 'Event';
        update ld;
        update con;
    }
    static TestMethod void controllerTest(){
        Lead ld = [select id,Form_Submission_Date_and_Time__c,Web_Form_Name__c from Lead limit 1];
        String prosid = ITmyWayEngagementController.getProspectId(ld.id,'Lead');
        String params = ITmyWayEngagementController.getParams();
        ITmyWayEngagementController.result result = ITmyWayEngagementController.getVisitors(ld.id,prosid,params);
        Map <String, integer> setSummary = ITmyWayEngagementController.setSummary(JSON.serialize(result));
        Map <String,String> getEmailData = ITmyWayEngagementController.getEmailData('',params, JSON.serialize(new Map <String,String>()));
    }
}
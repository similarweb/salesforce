@isTest(seealldata=true)
public class ITmyWayEngagementTest {
  static testMethod void insertTest() {
    Lead ld = new Lead(
      Company = 'testcomp',
      LastName = 'testld1',
      Form_Submission_Date_and_Time__c = System.Now(),
      Web_Form_Name__c = '64k8mn',
      Email = 'test@gmail.com'
    );
    insert ld;
    Account acc = new Account(Name = 'test');
    insert acc;
    Contact con = new Contact(
      Accountid = acc.id,
      LastName = 'testld1',
      Form_Submission_Date_and_Time__c = System.Now(),
      Web_Form_Name__c = '64k8mn',
      Email = 'test2@gmail.com'
    );
    insert con;
    ld.Form_Submission_Date_and_Time__c = System.Now();
    con.Form_Submission_Date_and_Time__c = System.Now();
    update ld;
    update con;
  }
  static testMethod void updateTest() {
    Lead ld = [
      SELECT id, Form_Submission_Date_and_Time__c, Web_Form_Name__c
      FROM Lead
      LIMIT 1
    ];
    Contact con = [
      SELECT id, Form_Submission_Date_and_Time__c, Web_Form_Name__c
      FROM Contact
      LIMIT 1
    ];
    ld.Form_Submission_Date_and_Time__c = System.Now();
    ld.Web_Form_Name__c = '64k8ml';
    con.Form_Submission_Date_and_Time__c = System.Now();
    con.Web_Form_Name__c = '64k8ml';
    update ld;
    update con;
    ld.Form_Submission_Date_and_Time__c = System.Now();
    ld.Web_Form_Name__c = 'Event';
    con.Form_Submission_Date_and_Time__c = System.Now();
    con.Web_Form_Name__c = 'Event';
    update ld;
    update con;
  }
  static testMethod void controllerTest() {
    Lead ld = [
      SELECT id, Form_Submission_Date_and_Time__c, Web_Form_Name__c
      FROM Lead
      LIMIT 1
    ];
    String prosid = ITmyWayEngagementController.getProspectId(ld.id, 'Lead');
    String params = ITmyWayEngagementController.getParams();
    ITmyWayEngagementController.result result = ITmyWayEngagementController.getVisitors(
      ld.id,
      prosid,
      params
    );
    Map<String, integer> setSummary = ITmyWayEngagementController.setSummary(
      JSON.serialize(result)
    );
    Map<String, String> getEmailData = ITmyWayEngagementController.getEmailData(
      '',
      params,
      JSON.serialize(new Map<String, String>())
    );
  }
}

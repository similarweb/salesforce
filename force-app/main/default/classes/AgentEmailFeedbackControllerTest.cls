@isTest
public class AgentEmailFeedbackControllerTest {
  @TestSetup
  static void setUp() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;

    InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
    ismTest.SW_Industry__c = 'AdTech and AdNetwork';
    ismTest.Department__c = 'BI / Analytics';
    ismTest.Inferred_Solution__c = 'Research';
    ismTest.Name = 'test';
    insert ismTest;

    InferralSolutionMapContact__c ismCTest = new InferralSolutionMapContact__c();
    ismCTest.SW_Industry__c = 'AdTech and AdNetwork';
    ismTest.Department__c = 'BI / Analytics';
    ismCTest.Inferred_Solution__c = 'Research';
    ismCTest.Name = 'test';
    insert ismCTest;

    Inferral_Solution_Valid_Criteria_List__c islvcl = new Inferral_Solution_Valid_Criteria_List__c();
    islvcl.Name = 'department__c';
    islvcl.Is_Valid__c = true;
    insert islvcl;

    Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
    islvcl2.Name = 'sw_industry__c';
    islvcl2.Is_Valid__c = true;
    insert islvcl2;

    InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
    islcvcl.Name = 'department__c';
    islcvcl.Is_Valid__c = true;
    insert islcvcl;

    InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
    islcvcl2.Name = 'sw_industry__c';
    islcvcl2.Is_Valid__c = true;
    insert islcvcl2;
    CSSettings__c cs = TestObjectCreator.CreateCSSettings();
    insert cs;
  }

  @isTest
  static void testGetData_WithLead() {
    Lead ld = new Lead(
      LastName = 'L1',
      Company = 'C1',
      Last_Contact_Us_Form_HTML_Template__c = '<p>lead template</p>',
      Email = 'test1@gmail.com'
    );
    insert ld;

    Task t = new Task(
      Subject = 'T1',
      WhoId = ld.Id,
      HTML_Template_Approval_Status__c = 'Approve',
      HTML_Template_Reviewer_Notes__c = 'Please review'
    );
    insert t;

    Test.startTest();
    AgentEmailFeedbackController.AgentEmailDTO dto = AgentEmailFeedbackController.getData(
      t.Id
    );
    Test.stopTest();

    System.assertEquals(t.Id, dto.taskId);
    System.assertEquals('<p>lead template</p>', dto.htmlTemplate);
    System.assertEquals('Approve', dto.approvalStatus);
    System.assertEquals('Please review', dto.reviewerNotes);
  }

  @isTest
  static void testGetData_WithContact_And_NoWho() {
    Contact c = new Contact(
      LastName = 'C1',
      Last_Contact_Us_Form_HTML_Template__c = '<p>contact template</p>',
      Email = 'test1@gmail.com'
    );
    insert c;

    Task tContact = new Task(
      Subject = 'T Contact',
      WhoId = c.Id,
      HTML_Template_Approval_Status__c = 'Approve',
      HTML_Template_Reviewer_Notes__c = 'OK'
    );
    insert tContact;

    Task tNoWho = new Task(
      Subject = 'T NoWho',
      HTML_Template_Approval_Status__c = 'Decline',
      HTML_Template_Reviewer_Notes__c = 'No who'
    );
    insert tNoWho;

    Test.startTest();
    AgentEmailFeedbackController.AgentEmailDTO dtoContact = AgentEmailFeedbackController.getData(
      tContact.Id
    );
    AgentEmailFeedbackController.AgentEmailDTO dtoNoWho = AgentEmailFeedbackController.getData(
      tNoWho.Id
    );
    Test.stopTest();

    System.assertEquals(
      c.Last_Contact_Us_Form_HTML_Template__c,
      dtoContact.htmlTemplate
    );
    System.assertEquals('Approve', dtoContact.approvalStatus);
    System.assertEquals('OK', dtoContact.reviewerNotes);

    System.assertEquals(null, dtoNoWho.htmlTemplate);
    System.assertEquals('Decline', dtoNoWho.approvalStatus);
    System.assertEquals('No who', dtoNoWho.reviewerNotes);
  }

  @isTest
  static void testSaveData_Success() {
    Task t = new Task(
      Subject = 'To Update',
      HTML_Template_Approval_Status__c = 'Approve',
      HTML_Template_Reviewer_Notes__c = 'Old note'
    );
    insert t;

    Map<String, Object> payload = new Map<String, Object>{
      'taskId' => t.Id,
      'approvalStatus' => 'Approve',
      'reviewerNotes' => 'Looks good'
    };
    String jsonInput = JSON.serialize(payload);

    Test.startTest();
    String result = AgentEmailFeedbackController.saveData(jsonInput);
    Test.stopTest();

    System.assertEquals('Success', result);

    Task tAfter = [
      SELECT
        Id,
        HTML_Template_Approval_Status__c,
        HTML_Template_Reviewer_Notes__c
      FROM Task
      WHERE Id = :t.Id
    ];
    System.assertEquals('Approve', tAfter.HTML_Template_Approval_Status__c);
    System.assertEquals('Looks good', tAfter.HTML_Template_Reviewer_Notes__c);
  }

  @isTest
  static void testSaveData_ErrorPath_ReturnsExceptionMessage() {
    String fakeId = '00T000000000000AAA';
    Map<String, Object> payload = new Map<String, Object>{
      'taskId' => fakeId,
      'approvalStatus' => 'X',
      'reviewerNotes' => 'Y'
    };
    String jsonInput = JSON.serialize(payload);

    Test.startTest();
    String result = AgentEmailFeedbackController.saveData(jsonInput);
    Test.stopTest();

    System.assertNotEquals('Success', result);
    System.assert(result != null && result.length() > 0);
  }
}

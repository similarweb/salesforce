@isTest
public class RecordIFrameControllerTest {
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
  static void testGetData_ForAccount() {
    Account acc = new Account(Name = 'Test Account');
    insert acc;

    Test.startTest();
    String iframeUrl = RecordIFrameController.getData(acc.Id);
    Test.stopTest();

    System.assertNotEquals(null, iframeUrl);
    System.assert(
      iframeUrl.contains('/lightning/r/Account/' + acc.Id + '/view')
    );
    System.assert(
      iframeUrl.contains(System.Url.getOrgDomainUrl().toExternalForm())
    );
  }

  @isTest
  static void testGetData_ForLead_NoWebsiteAndLinkedIn() {
    Lead l = TestObjectCreator.CreateLead();
    l.Website = 'no_website';
    l.LinkedIn_Profile__c = 'https://linkedin.com/in/test';
    l.CountryCode = 'US';
    insert l;

    Test.startTest();
    String iframeUrl = RecordIFrameController.getData(l.Id);
    Test.stopTest();

    System.assertNotEquals(null, iframeUrl);
    System.assert(!iframeUrl.contains('no_website'));
    System.assert(iframeUrl.contains('linkedin_url=' + l.LinkedIn_Profile__c));
    System.assert(iframeUrl.contains('country=' + l.CountryCode));
    System.assert(iframeUrl.contains('company_domain='));
  }
}

@istest
public class AccountTriggerHandlerLghtTest {
  @testSetup
  static void setup() {
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

    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["account","lead"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;
    Account testAcc = new Account(
      Name = 'test name',
      BillingCountryCode = 'FR',
      OwnerId = UserInfo.getUserId()
    );
    insert testAcc;
    Contact testCont = new Contact(
      LastName = 'test',
      AccountId = testAcc.Id,
      MailingCountry = 'France',
      Email = 'test@gmail.com'
    );
    insert testCont;
  }

  @isTest
  static void AccountTriggerHandler_Update_TEST_Owner() {
    User nOwner = [
      SELECT id
      FROM User
      WHERE Id != :UserInfo.getUserId() AND isactive = TRUE
      LIMIT 1
    ];
    System.debug('nOwner ' + nOwner);
    Account a = new Account();
    a.Id = '0019E0000000000000';
    a.name = 'test owner';
    a.Business_Unit__c = 'Enterprise';
    a.OwnerId = UserInfo.getUserId();

    Account a2 = new Account();
    a2.name = 'test owner upd';
    a2.Id = a.Id;
    a2.OwnerId = nOwner.Id;

    Test.startTest();
    AccountTriggerHandlerLght.changeContactOwnerAndKeepAccountTeamMember(
      new Map<Id, Account>{ '0019E0000000000000' => a },
      new Map<Id, Account>{ '0019E0000000000000' => a2 }
    );
    Test.stopTest();
  }

  @isTest
  static void testTrigger() {
    Account testAcc = [SELECT Id FROM Account LIMIT 1];

    Test.startTest();
    Id ownerId = [SELECT OwnerId FROM Account WHERE Id = :testAcc.Id LIMIT 1]
    .OwnerId;
    User nOwner = [
      SELECT Id
      FROM User
      WHERE
        Profile.Name = 'System Administrator'
        AND Id != :UserInfo.getUserId()
        AND Id != :ownerId
        AND IsActive = TRUE
      LIMIT 1
    ];
    testAcc.OwnerId = nOwner.Id;
    update testAcc;
    Test.stopTest();
  }
}

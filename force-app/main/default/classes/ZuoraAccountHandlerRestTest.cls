@isTest
public without sharing class ZuoraAccountHandlerRestTest {
  @TestSetup
  static void setup() {
    User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1];

    Pardot_Data_Manipulation_Setting__c pdms1 = new Pardot_Data_Manipulation_Setting__c();
    pdms1.Name = 'JUNK_LEAD_OWNER_ID';
    pdms1.Value__c = u.Id;
    insert pdms1;

    Pardot_Data_Manipulation_Setting__c pdms11 = new Pardot_Data_Manipulation_Setting__c();
    pdms11.Name = 'LDR_LEAD_OWNER_ID';
    pdms11.Value__c = u.Id;
    insert pdms11;

    Pardot_Data_Manipulation_Setting__c pdms111 = new Pardot_Data_Manipulation_Setting__c();
    pdms111.Name = 'FRENEMY_LEAD_OWNER_ID';
    pdms111.Value__c = u.Id;
    insert pdms111;

    Pardot_Data_Manipulation_Setting__c pdms2 = new Pardot_Data_Manipulation_Setting__c();
    pdms2.Name = 'FRENEMY_FLOW_MINUTES';
    pdms2.Value__c = '2';
    insert pdms2;

    Polygraph_Interaction_Setting__c pis = new Polygraph_Interaction_Setting__c();
    pis.Name = 'Token_Password';
    pis.Value__c = '00000000000000000000000000000000';
    insert pis;

    Polygraph_Interaction_Setting__c pis2 = new Polygraph_Interaction_Setting__c();
    pis2.Name = 'UserKey';
    pis2.Value__c = 'test';
    insert pis2;

    Polygraph_Interaction_Setting__c pis3 = new Polygraph_Interaction_Setting__c();
    pis3.Name = 'Endpoint';
    pis3.Value__c = 'https://polygraph-test.similarweb.io/api/test';
    insert pis3;

    List<LDR_Criteria_Settings__c> lcsList = new List<LDR_Criteria_Settings__c>();
    List<String> cr = new List<String>{
      'Company_LDR_Compare__c=False',
      'Country_LDR_Compare__c=FALSE',
      'Email domain type = Private',
      'Is null (Company)',
      'Is null (Country)',
      'Is null (Email)',
      'Is null (Employee Min)',
      'Is null (FirstName)',
      'Is null (Industry)',
      'Is null (Phone)',
      'Is null (Title)',
      'Is null (Website)',
      'LeadSource != NULL',
      'LeadSource not contains Outbound',
      'LeadSource!= Deal Registration',
      'Not(Country=Japan)'
    };
    for (String str : cr) {
      LDR_Criteria_Settings__c lcs = new LDR_Criteria_Settings__c();
      lcs.Name = str;
      lcs.Enabled__c = true;
      lcsList.add(lcs);
    }
    insert lcsList;

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
    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["account"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;

    Services.coverageMethod();

    EmailDomain__c ed = new EmailDomain__c();
    ed.Name = 'bbbb@ajkdha.com';
    ed.RecordTypeId = Schema.SObjectType.EmailDomain__c.getRecordTypeInfosByName()
      .get('Free')
      .getRecordTypeId();
    ed.User__c = UserInfo.getUserId();
    insert ed;
  }

  @isTest
  static void testNoLeadsAndContactsNewAccount() {
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      '',
      'AdTech and AdNetwork',
      '1',
      '2'
    );
  }

  @isTest
  static void testNoLeadsAndContactsMatchedAccountActive() {
    Account acc = new Account(
      Name = 'Test',
      Status__c = 'Active',
      Business_Unit__c = 'Inside Sales',
      BillingCountry = 'Israel'
    );
    insert acc;
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa11@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      '',
      'AdTech and AdNetwork',
      '1',
      '2'
    );
  }

  @isTest
  static void testNoLeadsAndContactsMatchedAccount() {
    Account acc = new Account(
      Name = 'Test',
      Business_Unit__c = 'Inside Sales',
      BillingCountry = 'Israel'
    );
    insert acc;
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa11@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      null,
      'AdTech and AdNetwork',
      '1',
      '2'
    );
  }

  @isTest
  static void testLeadRecordsAccNotExist() {
    Lead lead = new Lead(
      LastName = 'Test 1',
      Company = 'Test comp',
      Email = 'aaaa@ajkdha.com',
      Country = 'Israel'
    );
    insert lead;
    Test.startTest();
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      'google.com',
      'AdTech and AdNetwork',
      '1',
      '2'
    );
    Test.stopTest();

    System.assertEquals([SELECT count(ID) ct FROM Account][0].get('ct'), 1);
    System.assertEquals([SELECT count(ID) ct FROM Contact][0].get('ct'), 1);
    Account accConverted = [
      SELECT ID, OwnerId, No_Touch_Account__c, ParentId
      FROM Account
    ];
    Contact contactConverted = [
      SELECT ID, AccountID, OwnerId, No_Touch_User__c
      FROM Contact
    ];
    //System.assertEquals(ZuoraAccountHandlerRest.OWNER_ID, accConverted.OwnerId);
    //System.assertEquals(ZuoraAccountHandlerRest.OWNER_ID, contactConverted.OwnerId);
    System.assertEquals(contactConverted.AccountID, accConverted.Id);
    System.assertEquals(true, accConverted.No_Touch_Account__c);
    System.assertEquals(true, contactConverted.No_Touch_User__c);
    System.assertEquals(null, accConverted.ParentId);
  }

  @isTest
  static void testContactRecords() {
    //Added 2021-02-10: setMock and start/stop test
    //Test.setMock(HttpCalloutMock.class, new NewBiApiMockImp());
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );
    Account acc = new Account(Name = 'Test', Business_Unit__c = 'Inside Sales');
    insert acc;
    Contact cnt = new Contact(
      LastName = 'Contact',
      AccountId = acc.Id,
      Account_owner_reassigned__c = true,
      Email = 'aaaa@ajkdha.com',
      MailingCountry = 'Israel'
    );
    insert cnt;
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      'google.com',
      'AdTech and AdNetwork',
      '1',
      '2'
    );
  }

  @isTest
  static void testLeadRecordAccountExist() {
    Account acc = new Account(
      Name = 'Test',
      Business_Unit__c = 'Inside Sales',
      BillingCountry = 'Israel'
    );
    insert acc;
    Lead lead = new Lead(
      LastName = 'Test 1',
      Company = 'Test comp',
      Email = 'aaaa@ajkdha.com',
      Country = 'Israel'
    );
    insert lead;
    Account accInserted = [SELECT ID, OwnerId FROM Account WHERE Id = :acc.Id];
    Test.startTest();
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      'google.com',
      'AdTech and AdNetwork',
      '1',
      '2'
    );
    Test.stopTest();
    System.assertEquals([SELECT count(ID) ct FROM Account][0].get('ct'), 2);
    System.assertEquals([SELECT count(ID) ct FROM Contact][0].get('ct'), 1);

    Contact contactConverted = [
      SELECT ID, AccountID, OwnerId, No_Touch_User__c
      FROM Contact
      LIMIT 1
    ];
    Account accConverted = [
      SELECT ID, OwnerId, No_Touch_Account__c, ParentId
      FROM Account
      WHERE Id = :contactConverted.AccountID
      LIMIT 1
    ];
    System.assertEquals(accInserted.OwnerId, accConverted.OwnerId);
    System.assertEquals(accInserted.OwnerId, contactConverted.OwnerId);
    System.assertEquals(contactConverted.AccountID, accConverted.Id);
    System.assertEquals(true, accConverted.No_Touch_Account__c);
    System.assertEquals(true, contactConverted.No_Touch_User__c);
    System.assertEquals(null, accConverted.ParentId);
  }

  @isTest
  static void testLeadRecordAccountExistButActive() {
    Account acc = new Account(
      Name = 'Test',
      Status__c = 'Active',
      Business_Unit__c = 'Inside Sales',
      BillingCountry = 'Israel',
      Website = 'https://www.abc.com'
    );
    insert acc;

    Lead lead = new Lead(
      LastName = 'Test 1',
      Company = 'Test comp',
      Email = 'aaaa@ajkdha.com',
      Country = 'Israel',
      Website = 'https://www.abc.com'
    );
    insert lead;
    Account accInserted = [SELECT ID, OwnerId FROM Account];
    Test.startTest();
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      'abc.com',
      'AdTech and AdNetwork',
      '1',
      '2'
    );
    Test.stopTest();
    System.assertEquals([SELECT count(ID) ct FROM Account][0].get('ct'), 2);
    System.assertEquals([SELECT count(ID) ct FROM Contact][0].get('ct'), 1);

    Account accConverted = [
      SELECT ID, OwnerId, No_Touch_Account__c, ParentId
      FROM Account
      WHERE Status__c != 'Active'
    ];
    Contact contactConverted = [
      SELECT ID, AccountID, OwnerId, No_Touch_User__c
      FROM Contact
    ];
    System.assertEquals(accInserted.OwnerId, accConverted.OwnerId);
    // System.assertEquals(accInserted.OwnerId, contactConverted.OwnerId);
    // System.assertEquals(contactConverted.AccountID, accConverted.Id);
    // System.assertEquals(true, accConverted.No_Touch_Account__c);
    // System.assertEquals(true, contactConverted.No_Touch_User__c);
    // System.assertEquals(accInserted.Id, accConverted.ParentId);
  }

  @isTest
  static void testLeadRecordAccountExistButPrivate() {
    Account acc = new Account(
      Name = 'Test',
      Status__c = 'Active',
      Business_Unit__c = 'Inside Sales',
      BillingCountry = 'Israel'
    );
    insert acc;

    Lead lead = new Lead(
      LastName = 'Test 1',
      Company = 'Test comp',
      Email = 'bbbb@ajkdha.com',
      Country = 'Israel'
    );
    insert lead;
    Account accInserted = [SELECT ID, OwnerId FROM Account];
    Test.startTest();
    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'bbbb@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'IL',
      'google.com',
      'AdTech and AdNetwork',
      '1',
      '2'
    );
    Test.stopTest();
    // System.assertEquals([SELECT count(ID) ct FROM Account][0].get('ct'), 2);
    // System.assertEquals([SELECT count(ID) ct FROM Contact][0].get('ct'), 1);

    Account accConverted = [
      SELECT ID, OwnerId, No_Touch_Account__c, ParentId
      FROM Account
      WHERE Status__c != 'Active'
    ];
    Contact contactConverted = [
      SELECT ID, AccountID, OwnerId, No_Touch_User__c
      FROM Contact
    ];
    // System.assertNotEquals(accInserted.OwnerId, accConverted.OwnerId);
    //System.assertEquals(accInserted.OwnerId, contactConverted.OwnerId);
    //System.assertEquals(contactConverted.AccountID, accConverted.Id);
    //System.assertEquals(true, accConverted.No_Touch_Account__c);
    //System.assertEquals(true, contactConverted.No_Touch_User__c);
    //System.assertEquals(accInserted.Id, null);
  }
}

@istest
private class CloudiusAdditionalTests {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;
  }

  static testMethod void TestWS() {
    test.startTest();
    account a = TestObjectCreator.CreateAccount();
    insert a;

    Contact c = TestObjectCreator.CreateContact(a, 'test@testing.com');
    insert c;
    Opportunity o = TestObjectCreator.CreateOpportunity(a);
    insert o;
    CloudiusWS.CheckBillingAccount(o.Id);
    Zuora__CustomerAccount__c zca = TestDataFactory.CreateBillingAccount(a);
    zca.Zuora__DefaultPaymentMethod__c = 'WireTransfer';
    insert zca;
    CloudiusWS.CheckBillingAccount(o.Id);
    CloudiusWS.fail('failing');
    test.stopTest();
  }

  @istest
  static void TestMerge2() {
    test.startTest();
    Account a = TestObjectCreator.CreateAccount();
    insert a;
    Account a2 = TestObjectCreator.CreateAccount();
    insert a2;
    merge a a2;
    test.stopTest();
  }

  @istest
  static void TestLeadDeduplication_GENERIC() {
    test.startTest();
    //Test.setMock(HttpCalloutMock.class, new MockUtil.SwCurrentSnapshotDateMock());
    LeadTriggerHelperTEMP.isTest = true;
    AccountTriggerHelperTEMP.isTest = true;
    //CSSettings__c cs = TestObjectCreator.CreateCSSettings();
    //insert cs;
    id UserID = UserInfo.getUserId();
    string UserName = UserInfo.getUserName();

    CS_FreeEmailProvidersList__c FreeEmail = TestObjectCreator.CreateFreeEmailProvider(
      'gmail.com'
    );
    insert FreeEmail;

    CSRoundRobin__c csrobinENT = TestObjectCreator.CreateRoundRobin(
      'ENT',
      UserID
    );
    csrobinENT.Bucket__c = 'ENT';
    insert csrobinENT;

    CSRoundRobin__c csrobinSMB = TestObjectCreator.CreateRoundRobin(
      'SMB',
      UserID
    );
    csrobinSMB.Bucket__c = 'SMB';
    insert csrobinSMB;

    CSRoundRobin__c csrobinSMB2 = TestObjectCreator.CreateRoundRobin(
      'SMB',
      UserID
    );
    csrobinSMB2.Bucket__c = 'SMB';
    csrobinSMB2.Order__c = 2;
    insert csrobinSMB2;

    CSRoundRobin__c csrobinSMBRecurly = TestObjectCreator.CreateRoundRobin(
      'SMB Paid Account',
      UserID
    );
    csrobinSMBRecurly.Bucket__c = 'SMB Paid Account';
    insert csrobinSMBRecurly;

    Lead PreExistingLead = TestObjectCreator.CreateLead();
    PreExistingLead.email = 'old@existinglead.com';
    PreExistingLead.Lastname = 'PreExistingLead';
    LeadTriggerHelperTEMP.InactiveLeadTEST.add(PreExistingLead.email);
    insert PreExistingLead;

    Lead PreExistingLead2 = TestObjectCreator.CreateLead();
    PreExistingLead2.email = 'old@existinglead2.com';
    PreExistingLead2.Lastname = 'PreExistingLead2';
    LeadTriggerHelperTEMP.InactiveLeadTEST.add(PreExistingLead2.email);
    insert PreExistingLead2;

    LeadTriggerHelperTEMP.BEFOREAlreadyRUN = false;
    LeadTriggerHelperTEMP.AfterALreadyRUN = false;

    Task t2 = TestObjectCreator.CreateTask(null, PreExistingLead.id);
    insert t2;

    Account a = TestObjectCreator.CreateAccount();
    a.Website = 'www.testdomain.com';
    insert a;

    Account a2clean = TestObjectCreator.CreateAccount();
    a2clean.Website = 'www.testdomain.co.il';
    insert a2clean;

    Contact c = TestObjectCreator.CreateContact(
      a,
      'testcontact@testdomain.com'
    );
    insert c;

    CSCountryAssignment__c CountryAssignment = TestObjectCreator.CreateCountryAssignment(
      'Israel',
      a.id,
      UserID
    );
    insert CountryAssignment;

    Task t = TestObjectCreator.CreateTask(a.id, null);
    insert t;

    list<Lead> L4Create = new List<Lead>();

    Lead l = TestObjectCreator.CreateLead();
    l.Email = 'test1@testdomain.com';
    l.Business_Unit__c = 'SMB';
    l.Lastname = 'l1';
    L4Create.add(l);

    Lead lCLeanDom = TestObjectCreator.CreateLead();
    lCLeanDom.Email = 'test1@testdomain.org';
    lCLeanDom.Business_Unit__c = 'SMB';
    lCLeanDom.Lastname = 'l1';
    L4Create.add(lCLeanDom);

    Lead l2 = TestObjectCreator.CreateLead();
    l2.Email = 'test2@testdomain.com';
    l2.Business_Unit__c = 'ENT';
    l2.LastName = 'l2';
    L4Create.add(l2);

    Lead l3 = TestObjectCreator.CreateLead();
    l3.Email = 'test1@testdomain.com';
    l3.LastName = 'l3';
    L4Create.add(l3);

    Lead lFree = TestObjectCreator.CreateLead();
    lFree.Email = 'test1@gmail.com';
    lFree.LastName = 'lFree';
    L4Create.add(lFree);

    Lead lCountry = TestObjectCreator.CreateLead();
    lCountry.Email = 'test1@gmail.com';
    lCountry.Country = 'Israel';
    lCountry.LastName = 'lCountry';

    L4Create.add(lCountry);

    Lead lExistingLead = TestObjectCreator.CreateLead();
    lExistingLead.Email = 'new@existinglead.com';
    lExistingLead.LastName = 'lExistingLead';
    L4Create.add(lExistingLead);

    Account a1 = TestObjectCreator.CreateAccount();
    a1.website = 'test@test.co.il';
    insert a1;

    Account a2 = TestObjectCreator.CreateAccount();
    a2.website = 'test@test.co.br';
    insert a2;

    Lead lCleanDomain = TestObjectCreator.CreateLead();
    lCleanDomain.email = 'test@test.com';
    lCleanDomain.LastName = 'lCleanDomain';
    L4Create.add(lCleanDomain);

    Lead PreExistingLead3 = TestObjectCreator.CreateLead();
    PreExistingLead3.email = 'new@existinglead2.com';
    PreExistingLead3.Lastname = 'PreExistingLead3';
    L4Create.add(PreExistingLead3);

    insert L4Create;
    test.stopTest();
  }

  @istest
  static void TestLeadDeduplication_FreeEmailDomainMatch() {
    test.startTest();
    LeadTriggerHelperTEMP.isTest = true;
    AccountTriggerHelperTEMP.isTest = true;
    TestObjectCreator.CreateCSBatch();

    system.debug('************************TESTING - Free Email Domain');

    Account EXACTMatchAccount = TestObjectCreator.CreateAccount();
    insert EXACTMatchAccount;

    Lead ExactAccountMatch = TestObjectCreator.CreateLead();
    ExactAccountMatch.Email = 'account@gmail.com';
    ExactAccountMatch.LastName = 'account@gmail.com';
    insert ExactAccountMatch;
    test.stopTest();
  }
}

@isTest  
class LeadTriggerHelper_TEST {

    @testSetup
    static void setup() {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
    }
    
    @istest
    static void TestLeadDeduplication_GENERIC()
    {
        LeadTriggerHelperTEMP.isTest = true;
        AccountTriggerHelperTEMP.isTest = true;
        id UserID = UserInfo.getUserId();
        string UserName = UserInfo.getUserName();
        
        CS_FreeEmailProvidersList__c FreeEmail = TestObjectCreator.CreateFreeEmailProvider('gmail.com');
        insert FreeEmail;

        Lead PreExistingLead = TestObjectCreator.CreateLead();
        PreExistingLead.email = 'old@existinglead.com';
        PreExistingLead.Lastname = 'PreExistingLead';
        LeadTriggerHelperTEMP.InactiveLeadTEST.add (PreExistingLead.email);
        insert PreExistingLead;
        
        Lead PreExistingLead2 = TestObjectCreator.CreateLead();
        PreExistingLead2.email = 'old@existinglead2.com';
        PreExistingLead2.Lastname = 'PreExistingLead2';
        LeadTriggerHelperTEMP.InactiveLeadTEST.add (PreExistingLead2.email);
        insert PreExistingLead2;
        
        
        LeadTriggerHelperTEMP.BEFOREAlreadyRUN = false;
        LeadTriggerHelperTEMP.AfterALreadyRUN = false;
        
        Task t2 = TestObjectCreator.CreateTask(null, PreExistingLead.id);
        insert t2;
        
        Account a = TestObjectCreator.CreateAccount();
        // a.Website = 'www.testdomain.com';
        insert a;
        
        Account a2clean = TestObjectCreator.CreateAccount();
        // a2clean.Website = 'www.testdomain.co.il';
        insert a2clean;
        
        Contact c = TestObjectCreator.CreateContact(a, 'testcontact@testdomain.com');
        insert c;
        
        CSCountryAssignment__c CountryAssignment = TestObjectCreator.CreateCountryAssignment('Israel', a.id, UserID);
        insert CountryAssignment;
        
        Task t = TestObjectCreator.CreateTask(a.id, null);
        insert t;
        
        Test.startTest();
        list <Lead> L4Create = new list <Lead>();
        
        Lead l = TestObjectCreator.CreateLead();
        l.Email = 'test1@testdomain.com';
        l.Business_Unit__c='SMB';
        l.Lastname='l1';
        L4Create.add (l);
        
        Lead lCLeanDom = TestObjectCreator.CreateLead();
        lCLeanDom.Email = 'test1@testdomain.org';
        lCLeanDom.Business_Unit__c='SMB';
        lCLeanDom.Lastname='l1';
        L4Create.add (lCLeanDom);
        
        Lead l2 = TestObjectCreator.CreateLead();
        l2.Email = 'test2@testdomain.com';
        l2.Business_Unit__c='ENT';
        l2.LastName='l2';
        L4Create.add (l2);
        
        Lead l3 = TestObjectCreator.CreateLead();
        l3.Email = 'test1@testdomain.com';
        l3.LastName = 'l3';
        L4Create.add (l3);
        
        Lead lFree = TestObjectCreator.CreateLead();
        lFree.Email = 'test1@gmail.com';
        lFree.LastName = 'lFree';
        L4Create.add (lFree);
        
        Lead lCountry = TestObjectCreator.CreateLead();
        lCountry.Email = 'test1@gmail.com';
        lCountry.CountryCode = 'IL';
        lCountry.LastName = 'lCountry';
        
        L4Create.add (lCountry);
        
        Lead lExistingLead = TestObjectCreator.CreateLead();
        lExistingLead.Email = 'new@existinglead.com';
        lExistingLead.LastName = 'lExistingLead';
        L4Create.add (lExistingLead);
        
        
        Account a1 = TestObjectCreator.CreateAccount();
        // a1.website = 'test@test.co.il';
        a1.BillingCountry = 'France';
        insert a1;
        
        Account a2 = TestObjectCreator.CreateAccount();
        // a2.website = 'test@test.co.br';
        a2.BillingCountry = 'France';
        insert a2;
        Account a3 = TestObjectCreator.CreateAccount();
        // a3.website = 'gmail.com';
        a3.BillingCountry = 'France';
        insert a3;
        
        
        Lead lCleanDomain = TestObjectCreator.CreateLead();
        lCleanDomain.email= 'test@test.com';
        lCleanDomain.LastName = 'lCleanDomain';
        L4Create.add (lCleanDomain);


        Lead lCleanDomain2 = TestObjectCreator.CreateLead();
        lCleanDomain2.email= 'testsdsdsds@gmail.com';
        lCleanDomain2.LastName = 'lCleanDomain';
        lCleanDomain2.CountryCode = 'FR';
        L4Create.add (lCleanDomain2);
        
                
        Lead PreExistingLead3 = TestObjectCreator.CreateLead();
        PreExistingLead3.email = 'new@existinglead2.com';
        PreExistingLead3.Lastname = 'PreExistingLead3';     
        L4Create.add (PreExistingLead3);
        
        insert L4Create;
        Task t4a = TestObjectCreator.CreateTask(null,lCountry.Id);
        insert t4a;
        if (LeadTriggerHelperTEMP.existingAccountList==null)LeadTriggerHelperTEMP.existingAccountList = new list<Account>{a3};
        else LeadTriggerHelperTEMP.existingAccountList.add(a1);
        LeadTriggerHelperTEMP.FindMatch('gmail.com','France');
        LeadTriggerHelperTEMP.IsCountryMatch(lcountry,c);
        LeadTriggerHelperTEMP.IsCountryMatch(a1,a2,'test');
        LeadTriggerHelperTEMP.IsCountryMatch(PreExistingLead3, a1, 'test');
        LeadTriggerHelperTEMP.getDomainFromWebsite('http://www.google.com/test/a.php');
        LeadTriggerHelperTEMP.CaclulateSWTechScore('a,b,c');
        LeadTriggerHelperTEMP.CreateAccountFromLead(PreExistingLead3);
        //LeadTriggerHelperTEMP.forceLeadAllocationClean = true;
        try {
            LeadTriggerHelperTEMP.LeadAllocation(L4Create);
        } catch (Exception e) { }
        try {
            LeadTriggerHelperTEMP.HandleAFTERAction(L4Create);
        } catch (Exception e) { }
        Test.stopTest();
    } 

    @isTest
    static void testGetDomainFrom() {
        LeadTriggerHelperTEMP.getDomainFromEmail('testing@test.com');
        LeadTriggerHelperTEMP.getDomainFromWebsite('https://www.test.com');
        LeadTriggerHelperTEMP.getDomainFromWebsite('https://test.com');
        LeadTriggerHelperTEMP.getDomainFromWebsite('http://www.test.com');
        LeadTriggerHelperTEMP.getDomainFromWebsite('http://.test.com');
        LeadTriggerHelperTEMP.getDomainFromWebsite('www.test.com');
        LeadTriggerHelperTEMP.getDomainFromWebsite('test.com');
    }

    @istest
    static void TestLeadDeduplication_FreeEmailDomainMatch()
    {
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
        
        
    }
    
    
    
    
    
    @istest
    static void TestMassLeadConvert()
    {
        Lead l = TestObjectCreator.CreateLead();
        insert l;
        Account a = TestObjectCreator.CreateAccount();
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test@test.com');
        insert c;
        MassLeadConvert__c mlc = TestObjectCreator.CreateMassLeadConvert(l.id, a.id, c.id);
        
        list <MassLeadConvert__c> mlclist = new list <MassLeadConvert__c>();
        mlclist.add (mlc);
        insert mlclist;
        
         
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(mlclist);
        MassConvertController ext = new MassConvertController(sc);
        ext.con.setSelected(mlclist);
        ext.ConvertLeads();
        LeadStatus convertedStatus = [
            SELECT Id, MasterLabel
            FROM LeadStatus
            WHERE IsConverted = true
            LIMIT 1
        ];
        Database.LeadConvert lc = LeadTriggerHelperTEMP.createLeadConvert(l, a, convertedStatus, true, UserInfo.getUserId());
    }
    
    @istest
    static void TestManualRoundRobin()
    {
    
        TestObjectCreator.CreateCSBatch();
        Lead l = TestObjectCreator.CreateLead();
        insert l;
        ApexPages.currentPage().getParameters().put('Id',l.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);
        AssignmentButtonHandler ext = new AssignmentButtonHandler(sc);
        
        ext.ManualRoundRobinLeadSMB();
        ext.ManualRoundRobinLeadENT();
        ext.ManualLeadReassignment();
        
        
        Account a = TestObjectCreator.CreateAccount();
        insert a;
        ApexPages.currentPage().getParameters().put('Id',a.id);
        ext.ManualAccAssignment();
        //ext.ManualAssignmentSMB();
        //ext.ManualAssignmentSMBAM();
        //ext.ManualAssignmentSMBPaidAccount();
    
    }
    
    @istest
    static void TestSetKey()
    {
        TestObjectCreator.CreateCSBatch();
        LeadTriggerHelperTEMP.SetKey_TeamMap ('Account');
        LeadTriggerHelperTEMP.SetKey_TeamMap ('Lead');
    }
    
    @istest
    static void TestActivityLeadCheckr()
    {
        TestObjectCreator.CreateCSBatch();
        Account a = TestObjectCreator.CreateAccount();
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test@test.com');
        insert c;
        Task t = TestObjectCreator.CreateTask (a.id,c.id);
        t.subject = null;
        insert t;
        Lead l = TestObjectCreator.CreateLead();
        l.email = 'test@test.com';
        
        Utils.CodeOff = false;
        Utils.isTest = true;
        insert l;
        LeadTriggerHelperTEMP helper = new LeadTriggerHelperTEMP(new ApexPages.StandardController(l));
        Utils.isZuora = true;
    }

    @isTest
    static void testSetValidValues() {
        TestObjectCreator.CreateCSBatch();
        CSCountry__c csc = new CSCountry__c();
        csc.Name = 'France';
        csc.Region__c = 'Provence';
        insert csc;
        LeadTriggerHelperTEMP.SetValidValues();
    }
    
    @isTest
    static void testGenerateTechlist() {
        TestObjectCreator.CreateCSBatch();
        TestObjectCreator.CreateCSTeam();
        CSTechScore__c csts = new CSTechScore__c();
        csts.Name = 'Test';
        csts.Long_Name__c = 'TestTest';
        csts.Score__c = 15;
        insert csts;
        LeadTriggerHelperTEMP.GenerateTechlist();
    }
    
}
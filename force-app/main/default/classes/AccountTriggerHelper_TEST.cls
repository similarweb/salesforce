@isTest  
class AccountTriggerHelper_TEST {

    @isTest
    static void deleteAccountsFutureTest() {
      TestDataFactory.createSimilarWeb_CS();
      TestDataFactory.createInferredSolutionSettings_CS();
      Account a = TestObjectCreator.CreateAccount();
      insert a;
      Lead l = TestObjectCreator.CreateLead();
      insert l;
      Test.startTest();
      AccountTriggerHelperTEMP.DeleteAccounts(new List<Id>{a.Id});
      Test.stopTest();
    }
    @istest
    static void TestAccountDeduplication()
    {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        LeadTriggerHelperTEMP.isTest = true;
        AccountTriggerHelperTEMP.isTest = true;
        
        id UserID = UserInfo.getUserId();
        
        CSRoundRobin__c csrobinSMBAccount = TestObjectCreator.CreateRoundRobin('SMB Paid Account', UserID);
        insert csrobinSMBAccount;
        
        CS_FreeEmailProvidersList__c FreeEmail = TestObjectCreator.CreateFreeEmailProvider('gmail.com');
        insert FreeEmail;
        
        Lead lExistingLead = TestObjectCreator.CreateLead();
        lExistingLead.Email = 'newLead@test.com';
        lExistingLead.LastName = 'lExistingLead';
        insert lExistingLead;
        
        Account acc1 = TestObjectCreator.CreateAccount();
        insert acc1;
        
        Contact c = TestObjectCreator.CreateContact(acc1, 'acc1@test.com');
        insert c;
        
        AccountTriggerHelperTEMP.Domain2ParentAccountMap.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap_Trigger.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap.clear();
        
        Account acc2 = TestObjectCreator.CreateAccount();
        insert acc2;
        
        Account accMergeTo = TestObjectCreator.CreateAccount();
        insert accMergeTo;
        
        Contact cMergeTo = TestObjectCreator.CreateContact(accMergeTo, 'test@mergeto.com');
        insert cMergeTo;
        
        AccountTriggerHelperTEMP.Domain2ParentAccountMap.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap_Trigger.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap.clear();
        Test.startTest();
        Account acc3 = TestObjectCreator.CreateAccount();
        insert acc3;
        
        AccountTriggerHelperTEMP.Domain2ParentAccountMap.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap_Trigger.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap.clear();
        
        Task t4a = TestObjectCreator.CreateTask(acc1.id,null);
        insert t4a;
        
        AccountTriggerHelperTEMP.Domain2ParentAccountMap.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap_Trigger.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap.clear();

        AccountTriggerHelperTEMP.Domain2ParentAccountMap.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap_Trigger.clear();
        AccountTriggerHelperTEMP.Domain2ChildAccountMap.clear();
        
        Lead lExistingLead2 = TestObjectCreator.CreateLead();
        lExistingLead2.Email = 'newLead@ActiveLead.com';
        lExistingLead.LastName = 'lExistingLead';
        insert lExistingLead2;
        
        Task t4l = TestObjectCreator.CreateTask(null,lExistingLead2.id);
        insert t4l;
        
        Account acc5 = TestObjectCreator.CreateAccount();
        insert acc5;
                
        Lead ExactGmailMatch = TestObjectCreator.CreateLead();
        ExactGmailMatch.Email = 'lead@gmail.com';
        ExactGmailMatch.LastName = 'Lastname';
        insert ExactGmailMatch;
        
        Account accFREE = TestObjectCreator.CreateAccount();
        insert accFREE;
        Test.stopTest();
    }
     @isTest(SeeAllData=false)
     public static void TestA2(){
      Utils.CodeOff=true;
      TestDataFactory.createSimilarWeb_CS();
      TestDataFactory.createInferredSolutionSettings_CS();
        CSSettings__c csset = TestObjectCreator.CreateCSSettings();
        insert csset;            
       CSTeam__c cs1=new CSTeam__c(Name='A',Bucket__c='SMB',Business_Unit__c='SMB',Lead_Routing_Group__c='Enterprise',PayingAccount__c=false,Team__c='AC');
        insert cs1;
       CS_Countrymatch__c csm1=new CS_CountryMatch__c(Name='Enterprise');
       insert csm1; 
       CS_FreeEmailProvidersList__c FreeEmail =TestObjectCreator.CreateFreeEmailProvider('gmail.com');
         insert FreeEmail;
        
       list<Account> triggerAccounts=new list<Account>();
       list<Account> nonTriggerAccounts=new list<Account>();
       
      
         Account taa1= TestObjectCreator.CreateAccount();
       taa1.Type='Reseller';
       taa1.Business_Unit__c='SMB'; 
       taa1.Domain_Routing_Group__c='Enterprise'; 
       taa1.ownerId=userInfo.getUserId();   
        taa1.BillingCountry='Albania';
        insert taa1;
        Contact tempConTaa1=TestObjectCreator.CreateContact(taa1,'taa1_z@gmail.com');
        insert tempConTaa1; 
                
       Contact tempCon1Taa1=TestObjectCreator.CreateContact(taa1,'taa1_zz1@gmail.com');
        insert tempCon1Taa1;
        
       CSCountryAssignment__c css5=TestObjectCreator.CreateCountryAssignment (taa1.BillingCountry,taa1.id, userInfo.getUserId());
       
       taa1.uid__c=tempConTaa1.Id;  
       taa1.email__c= tempConTaa1.email;

         AccountTriggerHelperTemp.AccountMap.put(taa1.Id,taa1);
         AccountTriggerHelperTemp.uidMap.put(String.valueOf(taa1.Id),taa1); 
        nonTriggerAccounts.add(taa1);
                update taa1;  
       Account taa= TestObjectCreator.CreateAccount();
       taa.Type='Reseller';
       taa.Business_Unit__c='SMB'; 
       taa.Domain_Routing_Group__c='Enterprise'; 
       taa.ownerId=userInfo.getUserId();   
       taa.BillingCountry='Albania';
        insert taa;       
      
       Contact tempConTaa=TestObjectCreator.CreateContact(taa,'taa_z@gmail.com');
        insert tempConTaa;              
        CSCountryAssignment__c css4=TestObjectCreator.CreateCountryAssignment (taa.BillingCountry,taa.id, userInfo.getUserId());
       taa.uid__c=tempConTaa1.Id;   
       taa.email__c= tempConTaa1.email;
        update taa;
      
       nonTriggerAccounts.add(taa);
       AccountTriggerHelperTemp.Domain2ChildAccountMap.put(LeadTriggerHelperTEMP.getDomainFromEmail(taa.email__c),nonTriggerAccounts);  
       AccountTriggerHelperTemp.ExactAccountMatch.put(taa.email__c,taa); 
        AccountTriggerHelperTemp.AccountMap.put(taa.Id,taa);        
        AccountTriggerHelperTemp.uidMap.put(String.valueOf(taa.Id),taa);    
        Test.startTest();//Itzik Winograd 2022-01-23: Moved start test here 
       Account parentAccount=TestObjectCreator.CreateAccount();
       parentAccount.Type='Reseller';
       parentAccount.Domain_Routing_Group__c='Enterprise'; 
       parentAccount.ShippingCountry='Albania';
       parentAccount.BillingCountry='Albania';
       parentAccount.reseller__c=taa.Id;
       parentAccount.ownerId=userInfo.getUserId();       
        insert parentAccount;
      

       CSCountryAssignment__c css3=TestObjectCreator.CreateCountryAssignment (parentAccount.BillingCountry,parentAccount.id, userInfo.getUserId());
       parentAccount.uid__c=tempConTaa1.Id; 
       parentAccount.email__c=tempConTaa1.email; 
       update parentAccount;  
         
       LeadTriggerHelperTemp.AccountMap.put(parentAccount.Id,parentAccount);
       LeadTriggerHelperTemp.ExistingAccountList=new List<Account>();
       LeadTriggerHelperTemp.ExistingAccountList.add(parentAccount);
       
       AccountTriggerHelperTemp.AccountMap.put(parentAccount.Id,parentAccount);
       AccountTriggerHelperTemp.uidMap.put(String.valueOf(parentAccount.Id),parentAccount);    
       
       AccountTriggerHelperTemp.Domain2ParentAccountMap.put(LeadTriggerHelperTEMP.getDomainFromEmail(parentAccount.email__c),parentAccount);     
       AccountTriggerHelperTemp.ExactAccountMatch.put(parentAccount.email__c,parentAccount);  
        //Test.startTest();
       Account acc22=TestObjectCreator.CreateAccount();
       acc22.Type='Reseller';
       acc22.reseller__c=parentAccount.Id;
       acc22.Domain_Routing_Group__c='Enterprise'; 
       acc22.ShippingCountry='Albania';
       acc22.BillingCountry='Albania';
       acc22.ownerId=userInfo.getUserId();
        insert acc22; 
       
       CSCountryAssignment__c css1=TestObjectCreator.CreateCountryAssignment (acc22.BillingCountry, acc22.id, userInfo.getUserId());

       acc22.uid__c=tempConTaa1.Id; 
       acc22.Email__c=tempConTaa1.Email; 
        update acc22; 
       //Test.stopTest(); //Itzik Winograd 2022-01-23: moved stop test here
       AccountTriggerHelperTemp.AccountMap.put(acc22.Id,acc22); 
        AccountTriggerHelperTemp.uidMap.put(String.valueOf(acc22.Id),acc22);    
       triggerAccounts.add(acc22);
       AccountTriggerHelperTemp.ExactAccountMatch.put(taa.email__c,taa);      
       AccountTriggerHelperTemp.ExactAccountMatch.put(acc22.email__c,acc22);
       AccountTriggerHelperTemp.ExactAccountMatch.put(parentAccount.email__c,parentAccount); 
       Lead l1=TestObjectCreator.CreateLead();
       l1.Domain_Routing_Group__c='Enterprise';
       l1.Business_Unit__c='SMB';
       l1.bucket__c='SMB';
       l1.Status='Open';
       l1.Email='z@gmail.com';
       l1.Reseller__c=acc22.Id;
       l1.country='Albania';
       l1.ownerId=userInfo.getUserId();
       l1.team__c=cs1.Team__c; 
        insert l1;
       
       Lead l2=TestObjectCreator.CreateLead();
       l2.Domain_Routing_Group__c='Enterprise';
       l2.Business_Unit__c='SMB';
       l2.bucket__c='SMB';
       l2.Status='Open';
       l2.Email='z@zmail.com';
       l2.Reseller__c=acc22.Id;
       l2.country='Albania';
       l2.ownerId=userInfo.getUserId();
       l2.team__c=cs1.Team__c; 
        insert l2;
        
       AccountTriggerHelperTemp.ExactLeadMatch.put(l1.email,l1);
       AccountTriggerHelperTemp.ExactLeadMatch.put(l2.email,l2); 
        
       triggerAccounts.add(taa);
       AccountTriggerHelperTemp.Domain2ChildAccountMap_Trigger.put(LeadTriggerHelperTEMP.getDomainFromEmail(parentAccount.email__c),triggerAccounts);
      Test.stopTest(); 
    }
    @isTest
    static void GenDataTest(){
      TestDataFactory.createSimilarWeb_CS();
      TestDataFactory.createInferredSolutionSettings_CS();
      CSSettings__c cs = TestObjectCreator.CreateCSSettings();
      insert cs;
      CSTeam__c csTeam = new CSTeam__c(Name='A',Bucket__c='SMB',Business_Unit__c='SMB',Lead_Routing_Group__c='Enterprise',PayingAccount__c=false,Team__c='AC');
      insert csTeam;
      Account a = TestObjectCreator.CreateAccount();
      a.email__c = 'test@mail.invalid';
      a.website = 'test-site@mail.invalid';
      insert a;
      Account a2 = TestObjectCreator.CreateAccount();
      a2.email__c = 'test2@mail.invalid.com';
      insert a2;
      Account a3 = TestObjectCreator.CreateAccount();
      a3.email__c = 'test3@mail.invalid';
      a3.website = 'test3-site@mail.invalid';
      insert a3;
      Contact c = TestObjectCreator.CreateContact(a3, a3.email__c);
      insert c;
      Lead l1=TestObjectCreator.CreateLead();
       l1.Domain_Routing_Group__c='Enterprise';
       l1.Business_Unit__c='SMB';
       l1.bucket__c='SMB';
       l1.Status='Open';
       l1.Email='test@mail.invalid';
       l1.Reseller__c=a.Id;
       l1.country='Albania';
       l1.ownerId=userInfo.getUserId();
       l1.team__c=csTeam.Team__c; 
       insert l1;
       List<Task> taskList = new List<Task>();
      Task t1 = TestObjectCreator.CreateTask(a.id, null);
      t1.subject = 'test';
      taskList.add(t1);
      Task t2 = TestObjectCreator.CreateTask(a.id, null);
      t2.subject = 'test2';
      taskList.add(t2);
      Task t3 = TestObjectCreator.CreateTask(null, c.id);
      t3.subject = 'test2';
      taskList.add(t3);
      Task t4 = TestObjectCreator.CreateTask(null, c.id);
      t4.subject = 'test2';
      taskList.add(t4);
      insert taskList;

      CS_FreeEmailProvidersList__c testEmail = TestObjectCreator.CreateFreeEmailProvider('mail.invalid');
      insert testEmail;
      AccountTriggerHelperTEMP.exactemailmatchlist.add('test@mail.invalid');
      List<Account> accountList = new List<Account>();
      accountList.add(a3);
      AccountTriggerHelperTEMP.GenData(accountList);

      accountList.add(a);
      accountList.add(a2);
      AccountTriggerHelperTEMP.GenData(accountList);
    }

    @isTest
    static void generateTestParentAccountCodeTest(){
      Id parentId;
      Account a = TestObjectCreator.CreateAccount();
      a.email__c = 'test@mail.invalid';
      insert a;

      Test.startTest();
        parentId =AccountTriggerHelperTEMP.generateTestParentAccountCode();
        System.assertNotEquals(a.id, parentId);

        AccountTriggerHelperTEMP.setParentAccount(a);
        parentId = AccountTriggerHelperTEMP.generateTestParentAccountCode();
        System.assertEquals(a.id, parentId);
      Test.stopTest();
    }

    @isTest
    static void ManualAssignmentTest(){
      TestDataFactory.createSimilarWeb_CS();
      TestDataFactory.createInferredSolutionSettings_CS();
      CSRoundRobin__c csrr = TestObjectCreator.CreateRoundRobin('SalesOps', UserInfo.getUserId());
      csrr.bucket__c = 'SMB';
        insert csrr;
      Account a = TestObjectCreator.CreateAccount();
      a.name = 'test1';
      a.email__c = 'test@mail.invalid';
      a.bucket__c = 'SMB';
      a.BillingCountry='Albania';
      insert a;
      Account a2 = TestObjectCreator.CreateAccount();
      a2.name = 'test2';
      a2.email__c = 'test2@mail.invalid';
      a2.bucket__c = 'SMB';
      insert a2;
      Contact c = TestObjectCreator.CreateContact(a, a.email__c);
      insert c;

      Test.startTest();
        AccountTriggerHelperTEMP.ManualAssignment(a.id, a.bucket__c, 'CSM');
        AccountTriggerHelperTEMP.ManualAssignment(a2.id, a2.bucket__c, 'SDR');
        AccountTriggerHelperTEMP.ManualAssignment(a.id, a.bucket__c);
      Test.stopTest();
    }

    @isTest
    static void ZuoraAccountHandlerTest(){
      TestDataFactory.createSimilarWeb_CS();
      TestDataFactory.createInferredSolutionSettings_CS();
      CSSettings__c cs = TestObjectCreator.CreateCSSettings();
      insert cs;
      Account a = TestObjectCreator.CreateAccount();
      a.email__c = 'test@mail.invalid';
      a.uid__c = 'test';
      insert a;
      Account a2 = TestObjectCreator.CreateAccount();
      a2.uid__c = 'test';
      insert a2;
      Account a3 = TestObjectCreator.CreateAccount();
      a.email__c = 'test@mail.invalid';
      insert a3;
      Contact c = TestObjectCreator.CreateContact(a, 'test@mail.invalid.com');
      c.FirstName = 'Test1'; 
      insert c;
      Contact c2 = TestObjectCreator.CreateContact(a, 'test@mail.invalid.com');
      c2.FirstName = 'Test2'; 
      insert c2;

      Map<id, Account> accountMap = new Map<Id, Account>();
      Map<String, Account> domain2ParentAccountMap = new Map<String, Account>();
      Map <string, Account> uidMap = new Map <string,Account>();
      Map <string,Account> exactAccountMatch = new Map <string,Account>();
      accountMap.put(a3.id, a3);

      Test.startTest();
        a = [SELECT id, Name, Email__c, uid__c, OwnerId, parentid, (SELECT id, name, FirstName, ownerid FROM CONTACTS), CodeParentID__c, CodeFutureDelete__c FROM Account WHERE id =: a.id LIMIT 1];
        AccountTriggerHelperTEMP.setParentAccount(a3);
        AccountTriggerHelperTEMP.ZuoraAccountHandler(UserInfo.getUserId(), 'test@mail.invalid.com', 'test2', 'test2', 'test2');
        AccountTriggerHelperTEMP.AccountMap = accountMap;
        AccountTriggerHelperTEMP.ZuoraAccountHandler(UserInfo.getUserId(), 'test@mail.invalid', 'test1', 'test', 'test');
      Test.stopTest();
    }

    @isTest
    static void HandleAfterTest(){
      TestDataFactory.createSimilarWeb_CS();
      TestDataFactory.createInferredSolutionSettings_CS();
      CSSettings__c cs = TestObjectCreator.CreateCSSettings();
      TestObjectCreator.CreateCSBatch();
      
      Account a = TestObjectCreator.CreateAccount();
      a.email__c = 'test@mail.invalid';
      insert a;
      Account a2 = TestObjectCreator.CreateAccount();
      a2.email__c = 'test2@mail.invalid';
      a2.CodeParentID__c = a.id;
      a2.CodeFutureDelete__c = true;
      a2.ownerid = UserInfo.getUserId();
      insert a2;
      Contact c = TestObjectCreator.CreateContact(a, a.email__c);
      insert c;
      Lead l = TestObjectCreator.CreateLead();
      l.email = 'test4@mail.invalid';
      insert l;
      Account a3 = TestObjectCreator.CreateAccount();
      a3.CodeParentID__c = l.id;
      insert a3;
      Account a4 = TestObjectCreator.CreateAccount();
      a4.email__c = 'test4@mail.invalid';
      insert a4;
      Contact c2 = TestObjectCreator.CreateContact(a3, 'test4@mail.invalid.com');
      c2.FirstName = 'Test2'; 
      insert c2;
      a3 = [SELECT id, Email__c, OwnerId, uid__c, name, (SELECT id, FirstName, ownerid FROM CONTACTS), CodeParentID__c, CodeFutureDelete__c FROM Account WHERE id =: a.id LIMIT 1];

      List<Account> accountList = new List<Account>();
      List<Account> ownersList = new List<Account>();
      accountList.add(a2);
      accountList.add(a);
      accountList.add(a3);
      ownersList.add(a);
      AccountTriggerHelperTemp.AccountMap.put(UserInfo.getUserId(), a); 
      LeadTriggerHelperTEMP.ExistingLeadList = new List<Lead>();
      LeadTriggerHelperTEMP.ExistingLeadList.add(l);
      AccountTriggerHelperTEMP.OwnerNotificationMap.put(UserInfo.getUserId(), ownersList);

      Test.startTest();
      AccountTriggerHelperTemp.GenData(accountList);
      AccountTriggerHelperTemp.HandleAfter(accountList);
      Test.stopTest();
    }
}
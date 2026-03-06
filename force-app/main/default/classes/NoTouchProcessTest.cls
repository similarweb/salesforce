/**
 * Created by Alon.Shalev on 1/17/2024.
 */
@isTest
public with sharing class NoTouchProcessTest {

    @testSetup
    static void setup() {
        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
        iss.Name = 'Default Value';
        iss.Value__c = 'Sales';
        insert iss;
    }


    @isTest
    static void  scenario1Test() {
        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);

        Account account = TestDataFactory.createAccount();
        account.Status__c = 'Active';
        account.Website = 'TestWebsite@test.com';
        insert account;

        Contact contact = TestDataFactory.createContact(account,email);
        insert contact;

        system.assert(contact.No_Touch_User__c == false);
        Test.startTest();

        NoTouchProcess nt = new NoTouchProcess();
        String accountId = nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);
        Test.stopTest();

        // assert
        Contact contactAfterProcess = [SELECT No_Touch_User__c  FROM Contact WHERE Id =: contact.Id];
        Account acountAfterProcess = [SELECT NT_Scenario__c FROM Account WHERE Id = :accountId];
        System.debug('contactAfterProcess--'+contactAfterProcess);
        system.assertEquals(true,contactAfterProcess.No_Touch_User__c);
        system.assertEquals(acountAfterProcess.NT_Scenario__c,'Scenario 1');

    }
    @isTest
    static void  scenario2Test() {
        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);

        Account account = TestDataFactory.createAccount();
        account.Status__c = 'Suspended';
        account.Website = 'TestWebsite@test.com';
        insert account;

        Contact contact = TestDataFactory.createContact(account,email);
        contact.MailingCountryCode = 'UA';
        insert contact;

        NoTouchProcess nt = new NoTouchProcess();
        nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);

        // assert
        Account accountAfterProcess = [SELECT No_Touch_Account__c,Name  FROM Account WHERE Id =: account.Id];
        system.assertEquals(true,accountAfterProcess.No_Touch_Account__c);
        system.assertEquals(true,accountAfterProcess.Name.contains('No Touch'));


    }
    @isTest
    static void  scenario3Test() {
        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);

        Account account = TestDataFactory.createAccount();
        account.Status__c = 'Suspended';
        insert account;

        Lead lead = TestDataFactory.createLead();
        lead.Email = email;
        insert lead;

        EmailDomain__c ed = new EmailDomain__c();
        ed.Name = 'gmail.com';
        ed.RecordTypeId = Schema.SObjectType.EmailDomain__c.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        ed.User__c = UserInfo.getUserId();
        insert ed;

        NoTouchProcess nt = new NoTouchProcess();
        String accountId = nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);

        // assert
        Lead leadAfterConvert = [SELECT IsConverted  FROM Lead WHERE Id =: lead.Id];
        Account accountAfterProcess = [SELECT Id,No_Touch_Account__c FROM Account WHERE Id =: accountId];
        System.assert(true,leadAfterConvert.IsConverted);
        system.assertEquals(true,accountAfterProcess.No_Touch_Account__c);
//        system.assertEquals(true,accountAfterProcess.Name.contains('No Touch'));

    }
    @isTest
    static void  scenario4Test() {//this.existingAccount.Status__c == 'Active'
        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);

        Account account = TestDataFactory.createAccount();
        account.Status__c = 'Active';
        account.BillingCountryCode = 'IS';
        account.Website = 'Ikea.com';
        insert account;

        Lead lead = TestDataFactory.createLead();
        lead.Email = email;
        insert lead;

        EmailDomain__c ed = new EmailDomain__c();
        ed.Name = 'gmail.com';
        ed.RecordTypeId = Schema.SObjectType.EmailDomain__c.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        ed.User__c = UserInfo.getUserId();
        insert ed;

        NoTouchProcess nt = new NoTouchProcess();
        String accountId = nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);

        // assert
        Lead leadAfterConvert = [SELECT IsConverted  FROM Lead WHERE Id =: lead.Id];
        Account accountAfterProcess = [SELECT Id,No_Touch_Account__c,ParentId FROM Account WHERE Id =: accountId];
        System.assert(true,leadAfterConvert.IsConverted);
        system.assertEquals(true,accountAfterProcess.No_Touch_Account__c);
        system.assertEquals(account.Id,accountAfterProcess.ParentId);
//        system.assertEquals(true,accountAfterProcess.Name.contains('No Touch'));

    }
    @isTest
    static void  scenario5Test() {//this.existingAccount.Status__c != 'Active'
        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);

        Account account = TestDataFactory.createAccount();
        account.Status__c = 'Suspended';
        account.BillingCountryCode = 'IS';
        account.Website = 'Ikea.com';
        insert account;

        Lead lead = TestDataFactory.createLead();
        lead.Email = email;
        insert lead;

        EmailDomain__c ed = new EmailDomain__c();
        ed.Name = 'gmail.com';
        ed.RecordTypeId = Schema.SObjectType.EmailDomain__c.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        ed.User__c = UserInfo.getUserId();
        insert ed;

        NoTouchProcess nt = new NoTouchProcess();
        String accountId = nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);
        String response = '{"response": {"status": "Success", "message": "", "accountId": "'+accountId+'" }}';
        nt.recordLog(true,response,accountId);

        // assert
        Lead leadAfterConvert = [SELECT IsConverted  FROM Lead WHERE Id =: lead.Id];
        Account accountAfterProcess = [SELECT Id,No_Touch_Account__c,ParentId FROM Account WHERE Id =: accountId];
        System.assert(true,leadAfterConvert.IsConverted);
        system.assertEquals(true,accountAfterProcess.No_Touch_Account__c);
//        system.assertEquals(true,accountAfterProcess.Name.contains('No Touch'));

    }
    @isTest
    static void  scenario6Test() {
        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);

        Account account = TestDataFactory.createAccount();
        account.Status__c = 'Suspended';
        insert account;

        Contact contact = TestDataFactory.createContact(account,email);
        contact.MailingCountryCode = 'UA';
        insert contact;

        EmailDomain__c ed = new EmailDomain__c();
        ed.Name = 'gmail.com';
        ed.RecordTypeId = Schema.SObjectType.EmailDomain__c.getRecordTypeInfosByName().get('Free').getRecordTypeId();
        ed.User__c = UserInfo.getUserId();
        insert ed;

        NoTouchProcess nt = new NoTouchProcess();
        nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);

        // assert
        Account accountAfterProcess = [SELECT No_Touch_Account__c,Name  FROM Account WHERE Id =: account.Id];
//        system.assertEquals(true,accountAfterProcess.No_Touch_Account__c);
//        system.assertEquals(true,accountAfterProcess.Name.contains('No Touch'));

    }
    @isTest
    static void  scenario7Test() {

        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);

        Account account = TestDataFactory.createAccount();
        account.Status__c = 'Suspended';
        account.BillingCountryCode = 'IS';
        account.Website = 'Ikea.com';
        insert account;

        Lead lead = TestDataFactory.createLead();
        lead.Email = email;
        insert lead;

        EmailDomain__c ed = new EmailDomain__c();
        ed.Name = 'gmail.com';
        ed.RecordTypeId = Schema.SObjectType.EmailDomain__c.getRecordTypeInfosByName().get('Free').getRecordTypeId();
        ed.User__c = UserInfo.getUserId();
        insert ed;

        NoTouchProcess nt = new NoTouchProcess();
        String accountId = nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);

        // assert
        Lead leadAfterConvert = [SELECT IsConverted  FROM Lead WHERE Id =: lead.Id];
        Account accountAfterProcess = [SELECT Id,No_Touch_Account__c,ParentId FROM Account WHERE Id =: accountId];
        System.assert(true,leadAfterConvert.IsConverted);
        system.assertEquals(true,accountAfterProcess.No_Touch_Account__c);
//        system.assertEquals(true,accountAfterProcess.Name.contains('No Touch'));

    }
    @isTest
    static void  scenario8Test() {
        String uid;
        String email = 'alonTest@gmail.com';
        string cname = 'alonCompany';
        string fName = 'test';
        String lName = 'tewst ';
        String country = 'IS';
        String websiteDomain = 'Ikea.com';
        String industry = 'Agency';
        String minEmployees = '100';
        String maxEmployees = '500';
        Date todayDate = Date.today();
        String todayDateString = String.valueOf(todayDate);
        NoTouchProcess nt = new NoTouchProcess();
        String accountId = nt.handleNoTouch(uid,email,cname,fName,lName,country,websiteDomain,industry,minEmployees,maxEmployees,todayDateString,0);
        //assert
        List<Account> accountCreated = [SELECT Id FROM Account WHERE Id =:accountId];
        system.assertEquals(false,accountCreated.isEmpty());


    }

}
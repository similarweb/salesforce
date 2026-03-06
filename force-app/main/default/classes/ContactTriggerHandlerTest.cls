@istest public class ContactTriggerHandlerTest {
    
    @testSetup
    static void setup(){
        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
        iss.Name='Default Value';
        iss.Value__c='Sales';
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
        islvcl.Name='department__c';  
        islvcl.Is_Valid__c=true;
        insert islvcl;
        
        Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
        islvcl2.Name='sw_industry__c';  
        islvcl2.Is_Valid__c=true;
        insert islvcl2;
        
        InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
        islcvcl.Name='department__c';  
        islcvcl.Is_Valid__c=true;
        insert islcvcl;
        
        InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
        islcvcl2.Name='sw_industry__c';  
        islcvcl2.Is_Valid__c=true;
        insert islcvcl2;
        
//        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
//        currentSettings.API_Key__c='test';
//        currentSettings.Create_Date_TimeFrame__c='test';
//        currentSettings.Enriched_Entities__c='["account","lead"]';
//        currentSettings.Invisible_Fields__c='test';
//        currentSettings.Refresh_Data_Interval__c=0;
//        currentSettings.Sync_on_create_and_update__c=true;
//        insert currentSettings;
    }
    
    @istest static void testContactHandler(){
        Test.setMock(HttpCalloutMock.class, new BiApiMockImp());
        Contact_Trigger_Setting__c scheduleSetting = new Contact_Trigger_Setting__c(SetupOwnerId=UserInfo.getOrganizationId());
        scheduleSetting.Scheduled__c = true;
        insert scheduleSetting;
        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Default'][0];
        Account acc = new Account(RecordType = accountRecordType, Name = 'Test', Business_Unit__c = 'Inside Sales');
        insert acc;
        Contact cnt = new Contact(LastName='Contact', AccountId = acc.Id,Account_owner_reassigned__c = true, Email='test@gmail.com');
        insert cnt;
        List<Task> tasks = new List<Task>{new Task(Subject='Test Subj1', Priority='Normal', Status='Not Started', WhoId=cnt.Id), 
            new Task(Subject='Test Subj2', Priority='Normal', Status='Not Started', WhoId=cnt.Id), 
            new Task(Subject='Test Subj2', Priority='Normal', Status='Completed', WhoId=cnt.Id), 
            new Task(Subject='Test Subj with Contact us form', Priority='Normal', Status='Deferred', WhoId=cnt.Id), 
            new Task(Subject='Test Subj with Contact us form 2', Priority='Normal', Status='In Progress', WhoId=cnt.Id)};
        insert tasks; 
        
        Id runningUser = UserInfo.getUserId();
        User u = [SELECT Id FROM User WHERE Id !=:runningUser and isActive = true LIMIT 1];
        cnt.OwnerId = u.Id;
        update cnt;
        
        /*Map<Id, Id> newOwnerIdMap = new Map<Id, Id>{cnt.Id=>u.Id};
        Map<Id, Id> oldOwnerIdMap = new Map<Id, Id>{cnt.Id=>runningUser};            
        
        Test.startTest();
        ContactTriggerHandler.changeTasksOwnerFuture(newOwnerIdMap, oldOwnerIdMap);
        Test.stopTest();
        
        String successSubj = 'Test Subj with Contact us form 2';
        Task successTask = [select Id, OwnerId, Subject from Task where WhoId=:cnt.ID and Status='In Progress' limit 1];
        System.assertEquals(u.Id, successTask.OwnerId);
        System.assertEquals('Test Subj with Contact us form 2',successTask.Subject);
        System.assert([select Id, OwnerId, Subject from Task where WhoId=:cnt.ID AND Status='Deferred' LIMIT 1].get(0).OwnerId != u.Id);
        System.assert([select Id, OwnerId, Subject from Task where WhoId=:cnt.ID AND Subject='Test Subj2' LIMIT 1].get(0).OwnerId != u.Id);*/
        
    }
    
    @isTest
    static void testEmailFlow(){
        RecordType freeDomainRT = [SELECT Id FROM RecordType WHERE Name = 'Free' AND SObjectType = 'EmailDomain__c'][0];
        RecordType junkDomainRT = [SELECT Id FROM RecordType WHERE Name = 'Junk Emails' AND SObjectType = 'EmailDomain__c'][0];
        
        RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Default'][0];
        
        Account acc = new Account(RecordType = accountRecordType, Name = 'Test', Business_Unit__c = 'Inside Sales');
        insert acc;     
        
        Contact cnt = new Contact(LastName='Contact', FirstName = 'Test', Email = 'test@11mail.com', AccountId = acc.Id);
        insert cnt;
        
        Contact cnt2 = new Contact(LastName='Contact2', FirstName = 'Test2', AccountId = acc.Id, Email='test@gmail.com');
        insert cnt2;
                    
        cnt = [SELECT Email, Email_address_domain_type__c FROM Contact WHERE Email = 'test@11mail.com' LIMIT 1];
        cnt2 = [SELECT Email_address_domain_type__c FROM Contact WHERE LastName = 'Contact2' LIMIT 1];
        
        //System.assertEquals(null, cnt2.Email_address_domain_type__c);
        
        System.assertEquals('Company', cnt.Email_address_domain_type__c);
        
        EmailDomain__c dom2 = new EmailDomain__c(Name = '12mail.com', RecordTypeId = freeDomainRT.Id);
        insert dom2;
        
        cnt.Email = 'test@12mail.com';
        update cnt;
        cnt = [SELECT Email_address_domain_type__c FROM Contact WHERE Email = 'test@12mail.com' LIMIT 1];
        System.assertEquals('Private',cnt.Email_address_domain_type__c);
        RecordType stratDomainRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Strategic' AND SObjectType = 'EmailDomain__c'][0];
        EmailDomain__c dom3 = new EmailDomain__c(Name = '1mail.com', RecordTypeId = stratDomainRT.Id);
        insert dom3;
        // cnt.Email = 'rest@1mail.com';
        // update cnt;

    }


    @isTest
    static void getContactsToSendEmailTest() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact testContact1 = new contact
        (
            LastName='Contact', 
            FirstName = 'Test1', 
            Email = 'test1@gmail.com', 
            AccountId = acc.id,
            Bill_To__c = true,
            Sold_To__c = false
        );
        insert testContact1;

        Contact testContact2 = new contact
        (
            LastName='Contact', 
            FirstName = 'Test2', 
            Email = 'test2@gmail.com', 
            AccountId = acc.id,
            Bill_To__c = false,
            Sold_To__c = true,
            MailingCountry = 'United States'
        );
        insert testContact2;

        Test.startTest();
        testContact1.Email = 'newtest1@gmail.com';
        update testContact1;
        testContact2.MailingCountry = 'United States';
        testContact2.First_MQL_Date__c = Datetime.now();
        update testContact2;
        Test.stopTest();
    }

    @isTest
    static void testVerifyGroudonAfterInsert() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        
        List<Fake_Domain__mdt> fakeDomains = [SELECT Domain__c FROM Fake_Domain__mdt LIMIT 1];
        Boolean hasFakeDomain = !fakeDomains.isEmpty();
        String blacklistedDomain = hasFakeDomain ? fakeDomains[0].Domain__c : null;
        
        Account acc = new Account(Name = 'Test Account', Website = 'testcompany.com');
        insert acc;
        
        if (hasFakeDomain) {
            RecordType freeEmailRecordType = [SELECT Id FROM RecordType WHERE Name = 'Free' AND SObjectType = 'EmailDomain__c' LIMIT 1];
            EmailDomain__c gmailDomain = new EmailDomain__c(
                Name = 'gmail.com',
                RecordTypeId = freeEmailRecordType.Id
            );
            insert gmailDomain;
        }
        
        Account accFake;
        if (hasFakeDomain) {
            accFake = new Account(Name = 'Fake Domain Account', Website = blacklistedDomain);
            insert accFake;
        }
        
        Test.startTest();
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Email = 'testlead@company.com',
            Company = 'Test Company',
            Website = 'testcompany.com'
        );
        insert testLead;
        
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(
            FirstName = 'Test1',
            LastName = 'Contact1',
            Email = 'test1@company.com',
            AccountId = acc.Id,
            Converted_Lead_ID__c = testLead.Id,
            enrichment_success__c = false,
            Email_address_domain_type__c = 'Company'
        ));
        
        contacts.add(new Contact(
            FirstName = 'Test2',
            LastName = 'Contact2',
            Email = 'test2@company.com',
            AccountId = acc.Id,
            Groudon_Call_Status__c = 'NTS (Need To Send)',
            Email_address_domain_type__c = 'Company'
        ));
        
        contacts.add(new Contact(
            FirstName = 'Test3',
            LastName = 'Contact3',
            Email = 'test3@gmail.com',
            AccountId = acc.Id,
            Converted_Lead_ID__c = testLead.Id,
            enrichment_success__c = false,
            Email_address_domain_type__c = 'Private'
        ));
        
        if (hasFakeDomain) {
            contacts.add(new Contact(
                FirstName = 'Fake',
                LastName = 'Domain',
                Email = 'fake@gmail.com',
                AccountId = accFake.Id,
                Converted_Lead_ID__c = testLead.Id,
                enrichment_success__c = false
            ));
        }
        
        insert contacts;
        Test.stopTest();
        
        List<Contact> updatedContacts = [SELECT Id, Website_Domain__c, Fake_Data__c, Fake_Data_Reason__c 
                                         FROM Contact WHERE Id IN :contacts];
        System.assertEquals(hasFakeDomain ? 4 : 3, updatedContacts.size(), 'All contacts should be processed');
        
        if (hasFakeDomain) {
            Id fakeContactId = contacts[contacts.size() - 1].Id;
            Contact fakeContact = [SELECT Id, Fake_Data__c, Fake_Data_Reason__c
                                   FROM Contact WHERE Id = :fakeContactId];
            System.assertEquals(true, fakeContact.Fake_Data__c, 'Fake domain contact should be marked as fake');
            System.assertEquals('Black list Website', fakeContact.Fake_Data_Reason__c, 'Fake data reason should be set');
        }
    }

    @isTest
    static void testVerifyGroudonAfterUpdate() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        
        List<Fake_Domain__mdt> fakeDomains = [SELECT Domain__c FROM Fake_Domain__mdt LIMIT 1];
        Boolean hasFakeDomain = !fakeDomains.isEmpty();
        String blacklistedDomain = hasFakeDomain ? fakeDomains[0].Domain__c : null;
        
        Account acc = new Account(Name = 'Test Account', Website = 'testcompany.com');
        insert acc;
        
        if (hasFakeDomain) {
            RecordType freeEmailRecordType = [SELECT Id FROM RecordType WHERE Name = 'Free' AND SObjectType = 'EmailDomain__c' LIMIT 1];
            EmailDomain__c gmailDomain = new EmailDomain__c(
                Name = 'gmail.com',
                RecordTypeId = freeEmailRecordType.Id
            );
            insert gmailDomain;
        }
        
        Account accFake;
        if (hasFakeDomain) {
            accFake = new Account(Name = 'Fake Domain Account', Website = blacklistedDomain);
            insert accFake;
        }
        
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(
            FirstName = 'Force',
            LastName = 'Enrichment',
            Email = 'force@company.com',
            AccountId = acc.Id,
            Email_address_domain_type__c = 'Company',
            Force_Enrichment__c = false
        ));
        
        contacts.add(new Contact(
            FirstName = 'NTS',
            LastName = 'Status',
            Email = 'nts@company.com',
            AccountId = acc.Id,
            Email_address_domain_type__c = 'Company'
        ));
        
        contacts.add(new Contact(
            FirstName = 'Fake',
            LastName = 'Domain',
            Email = 'fake@gmail.com',
            AccountId = acc.Id,
            Email_address_domain_type__c = 'Private',
            Force_Enrichment__c = false
        ));
        
        contacts.add(new Contact(
            FirstName = 'No',
            LastName = 'Website',
            Email = 'nowebsite@gmail.com',
            AccountId = acc.Id,
            Email_address_domain_type__c = 'Private',
            Force_Enrichment__c = false
        ));
        
        if (hasFakeDomain) {
            contacts.add(new Contact(
                FirstName = 'Blacklist',
                LastName = 'Test',
                Email = 'blacklist@gmail.com',
                AccountId = acc.Id,
                Force_Enrichment__c = false
            ));
        }
        
        insert contacts;
        
        Test.startTest();
        contacts[0].Force_Enrichment__c = true;
        
        contacts[1].Groudon_Call_Status__c = 'NTS (Need To Send)';
        
        contacts[2].Force_Enrichment__c = true;
        
        contacts[3].Force_Enrichment__c = true;
        
        if (hasFakeDomain) {
            contacts[4].AccountId = accFake.Id;
            contacts[4].Force_Enrichment__c = true;
        }
        
        update contacts;
        Test.stopTest();
        
        List<Contact> updatedContacts = [SELECT Id, Force_Enrichment__c, Groudon_Call_Status__c, 
                                         Fake_Data__c, Fake_Data_Reason__c 
                                         FROM Contact WHERE Id IN :contacts];
        System.assertEquals(hasFakeDomain ? 5 : 4, updatedContacts.size(), 'All contacts should be processed');
        
        if (hasFakeDomain) {
            Id fakeContactId = contacts[contacts.size() - 1].Id;
            Contact fakeContact = [SELECT Id, Fake_Data__c, Fake_Data_Reason__c 
                                   FROM Contact WHERE Id = :fakeContactId];
            System.assertEquals(true, fakeContact.Fake_Data__c, 'Fake domain contact should be marked as fake');
            System.assertEquals('Black list Website', fakeContact.Fake_Data_Reason__c, 'Fake data reason should be set');
        }
    }

}
@isTest
public class GroudonHandlerTest {
    
    @testSetup
    static void setup() {
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
		CSSettings__c cs = TestObjectCreator.CreateCSSettings();
		insert cs;

        List<Lead> testLeads = new List<Lead>();
        for(Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'Test Company ' + i,
                Email = 'testlead' + i + '@test.com',
                Website = 'www.test' + i + '.com',
                Domain__c = 'test' + i + '.com',
                CountryCode = 'US',
                Country = 'United States',
                Department__c = 'Marketing',
                Title = 'Manager',
                Groudon_Call_Status__c = 'NTS (Need To Send)',
                Force_Enrichment__c = false,
                Email_address_domain_type__c = 'Company'
            ));
        }
        insert testLeads;
        
        Account testAccount = new Account(
            Name = 'Test Account',
            Website = 'www.testaccount.com'
        );
        insert testAccount;

        List<Contact> testContacts = new List<Contact>();
        for(Integer i = 0; i < 5; i++) {
            testContacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact' + i,
                AccountId = testAccount.Id,
                Email = 'testcontact' + i + '@test.com',
                MailingCountryCode = 'US',
                MailingCountry = 'United States',
                Department__c = 'Sales',
                Title = 'Director',
                Groudon_Call_Status__c = 'NTS (Need To Send)',
                Force_Enrichment__c = false
            ));
        }
        insert testContacts;
    }

    private static Lead buildTestLead(Integer idx) {
        return new Lead(
            FirstName = 'Test',
            LastName = 'Lead' + idx,
            Company = 'Test Company ' + idx,
            Email = 'triggerlead' + idx + '@test.com',
            Website = 'www.triggerlead' + idx + '.com',
            Domain__c = 'triggerlead' + idx + '.com',
            CountryCode = 'US',
            Country = 'United States',
            Department__c = 'Marketing',
            SW_Industry__c = 'Software',
            Title = 'Manager',
            Force_Enrichment__c = false,
            Email_address_domain_type__c = 'Company'
        );
    }

    private static Contact buildTestContact(Integer idx, Id accountId) {
        return new Contact(
            FirstName = 'Test',
            LastName = 'Contact' + idx,
            AccountId = accountId,
            Email = 'triggercontact' + idx + '@test.com',
            MailingCountryCode = 'US',
            MailingCountry = 'United States',
            Department__c = 'Sales',
            Title = 'Director',
            Force_Enrichment__c = false
        );
    }
    
    @isTest
    static void testLeadGroudonHandlerSingle() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());

        Test.startTest();
        Lead testLead = buildTestLead(10);
        insert testLead;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Force_Enrichment__c, Groudon_Call_Status__c, Groudon_Timestamp__c 
                    FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, updatedLead.Force_Enrichment__c, 'Force_Enrichment__c should be false');
        System.assertEquals('Enrichment_Ended', updatedLead.Groudon_Call_Status__c, 'Status should be Enrichment_Ended');
        System.assertNotEquals(null, updatedLead.Groudon_Timestamp__c, 'Timestamp should be set');
    }
    
    @isTest
    static void testLeadGroudonHandlerBulk() {
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());

        Test.startTest();
        List<Lead> testLeads = new List<Lead>{
            buildTestLead(20),
            buildTestLead(21),
            buildTestLead(22)
        };
        insert testLeads;
        Test.stopTest();
        
        List<Lead> updatedLeads = [SELECT Id, Force_Enrichment__c, Groudon_Call_Status__c, Groudon_Timestamp__c 
                                   FROM Lead WHERE Id IN :testLeads];
        for(Lead lead : updatedLeads) {
            System.assertEquals(false, lead.Force_Enrichment__c, 'Force_Enrichment__c should be false');
            System.assertEquals('Enrichment_Ended', lead.Groudon_Call_Status__c, 'Status should be Enrichment_Ended');
            System.assertNotEquals(null, lead.Groudon_Timestamp__c, 'Timestamp should be set');
        }
    }
    
    @isTest
    static void testContactGroudonHandlerSingle() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        
        Contact testContact = buildTestContact(30, accountId);
        insert testContact;
        
        Test.startTest();
        testContact.Force_Enrichment__c = true;
        update testContact;
        Test.stopTest();
        
        Contact updatedContact = [SELECT Id, Force_Enrichment__c, Groudon_Call_Status__c, 
                                  Groudon_Timestamp__c
                                  FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(false, updatedContact.Force_Enrichment__c, 'Force_Enrichment__c should be false');
        System.assertEquals('Enrichment_Ended', updatedContact.Groudon_Call_Status__c, 'Status should be Enrichment_Ended');
    }
    
    @isTest
    static void testContactGroudonHandlerBulk() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new GroudonMockService());
        
        List<Contact> testContacts = new List<Contact>{
            buildTestContact(40, accountId),
            buildTestContact(41, accountId),
            buildTestContact(42, accountId)
        };
        insert testContacts;
        
        Test.startTest();
        for(Contact c : testContacts) {
            c.Force_Enrichment__c = true;
        }
        update testContacts;
        Test.stopTest();
        
        List<Contact> updatedContacts = [SELECT Id, Force_Enrichment__c, Groudon_Call_Status__c, 
                                         Groudon_Timestamp__c
                                         FROM Contact WHERE Id IN :testContacts];
        for(Contact contact : updatedContacts) {
            System.assertEquals(false, contact.Force_Enrichment__c, 'Force_Enrichment__c should be false');
            System.assertEquals('Enrichment_Ended', contact.Groudon_Call_Status__c, 'Status should be Enrichment_Ended');
        }
    }
    
    @isTest
    static void testLeadGroudonHandlerException() {
        Test.setMock(HttpCalloutMock.class, new GroudonExceptionMockService());
        
        Test.startTest();
        Lead testLead = buildTestLead(50);
        insert testLead;
        Test.stopTest();
        
        Lead updatedLead = [SELECT Id, Force_Enrichment__c, Groudon_Call_Status__c 
                            FROM Lead WHERE Id = :testLead.Id];
        System.assertEquals(false, updatedLead.Force_Enrichment__c, 'Force_Enrichment__c should be false');
        System.assertEquals('Enrichment_Ended', updatedLead.Groudon_Call_Status__c, 'Status should be Enrichment_Ended');
    }
    
    @isTest
    static void testContactGroudonHandlerException() {
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Test.setMock(HttpCalloutMock.class, new GroudonExceptionMockService());
        
        Contact testContact = buildTestContact(60, accountId);
        insert testContact;
        
        Test.startTest();
        testContact.Force_Enrichment__c = true;
        update testContact;
        Test.stopTest();
        
        Contact updatedContact = [SELECT Id, Force_Enrichment__c, Groudon_Call_Status__c 
                                  FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(false, updatedContact.Force_Enrichment__c, 'Force_Enrichment__c should be false');
        System.assertEquals('Enrichment_Ended', updatedContact.Groudon_Call_Status__c, 'Status should be Enrichment_Ended');
    }
    
    @isTest
    static void testGroudonProtectionUtil_ModifiedByGroudonFlag() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        Contact testContact = new Contact(
            FirstName = 'Protected',
            LastName = 'Contact',
            AccountId = testAccount.Id,
            Email = 'protected@test.com',
            Title = 'Original Title',
            Department__c = 'Sales'
        );
        insert testContact;
        
        testContact.Groudon_Enrichment_fields__c = 'title,department';
        update testContact;
        
        Test.startTest();
        
        testContact.Title = 'Attempted Change';
        testContact.Department__c = 'Marketing';
        update testContact;
        
        Contact afterAttempt = [SELECT Title, Department__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('Original Title', afterAttempt.Title, 'Protected field should be restored');
        System.assertEquals('Sales', afterAttempt.Department__c, 'Protected field should be restored');
        
        afterAttempt.ModifiedByGroudon__c = true;
        afterAttempt.Title = 'Updated by Groudon';
        update afterAttempt;
        
        Test.stopTest();
        
        Contact updatedContact = [SELECT Title, ModifiedByGroudon__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals('Updated by Groudon', updatedContact.Title, 'Title should be updated when ModifiedByGroudon flag is true');
        System.assertEquals(false, updatedContact.ModifiedByGroudon__c, 'ModifiedByGroudon flag should be reset to false');
    }
    
    private class GroudonErrorMockService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"error": "Internal Server Error"}');
            res.setStatusCode(500);
            return res;
        }
    }
    
    private class GroudonExceptionMockService implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('{"message": "Lead successfully processed"}');
            res.setStatusCode(201);
            return res;
        }
    }
}
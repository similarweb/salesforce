@isTest
private class EventChillipaperLeadConverterTest {
    @testSetup
    static void setup() {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();      
        Test.setMock(HttpCalloutMock.class, new MockUtil.SwUtilsMock());
        Account a = TestDataFactory.createAccount();
        a.Website = 'testaccount.test.com';
        a.BillingCountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.createContact(a, 'testing@test.com');
        c.MailingCountry = 'Israel';
        insert c;
    }

    @isTest
    static void convertSuccessTest() {
        Lead lead = TestDataFactory.createLead();
        lead.Website = 'testaccount.test.com';
        lead.Country = 'Israel';
        lead.Email = 'testing@test.com';
        insert lead;
        Event eventBefore = new Event(
            Subject = 'Test', 
            WhoId = lead.Id,
            Queue_Name_CP__c = 'MQL - test lead',
            ActivityDate = date.today(), 
            StartDateTime = System.now(),
            EndDateTime = System.now() + 5
        );
        Test.startTest();
        insert eventBefore;
        Test.stopTest();
        Event eventAfter = [SELECT Id, WhoId FROM Event WHERE Id = :eventBefore.Id];
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        System.assertNotEquals(eventBefore.WhoId, eventAfter.WhoId);
        System.assertEquals(eventAfter.WhoId, contactId);
    }

    @isTest
    static void convertSpecificFailureTest() {
        Lead lead = TestDataFactory.createLead();
        lead.Website = 'testaccount2.test.com';
        lead.Country = 'Ukraine';
        lead.Email = 'testing@test.com';
        insert lead;
        Event event = new Event(
            Subject = 'Test', 
            WhoId = lead.Id,
            Queue_Name_CP__c = 'MQL - test lead',
            ActivityDate = Date.today(), 
            StartDateTime = System.now(),
            EndDateTime = System.now() + 5
        );
        Test.startTest();
        insert event;
        Test.stopTest();
        Event eventAfter = [SELECT Id, WhoId FROM Event WHERE Id = :event.Id];
        System.assertEquals(event.WhoId, eventAfter.WhoId);
    }

    @isTest
    static void convertGeneralFailureTest() {
        Lead lead = TestDataFactory.createLead();
        lead.Website = 'testaccount.test.com';
        lead.Country = 'Israel';
        lead.Email = 'testing@test.com';
        insert lead;
        Event event = new Event(
            Subject = 'Test', 
            WhoId = lead.Id,
            Queue_Name_CP__c = 'MQL - test lead',
            ActivityDate = Date.today(), 
            StartDateTime = System.now(),
            EndDateTime = System.now() + 5
        );
        Test.startTest();
        insert event;
        Event anotherEvent = new Event(
            Subject = 'Test', 
            WhoId = lead.Id,
            Queue_Name_CP__c = 'MQL - test lead',
            ActivityDate = Date.today(), 
            StartDateTime = System.now(),
            EndDateTime = System.now() + 5
        );
        insert anotherEvent;
        Test.stopTest();
        Event eventAfter = [SELECT Id, WhoId FROM Event WHERE Id = :event.Id];
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        System.assertNotEquals(event.WhoId, eventAfter.WhoId);
        System.assertEquals(eventAfter.WhoId, contactId);
    }
}
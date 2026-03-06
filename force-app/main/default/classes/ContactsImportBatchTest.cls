@isTest
public with sharing class ContactsImportBatchTest {
    @testSetup 
    static void setup() {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Account acc = TestDataFactory.createAccount();
        insert acc;
        ContactDraft__c cd = TestDataFactory.creatContactDraft(acc);
        insert cd;
    }

    static testmethod void test() {    
        List<Account> acc = [SELECT Id FROM Account];
        List<ContactDraft__c> cd = [SELECT Id FROM ContactDraft__c];
        Map<String,String> emailToCdId = new Map<String,String>();
        List<Contact> cntcts = new List<Contact>();
        Contact newContact = new Contact();
        newContact.AccountId = acc[0].Id;
        newContact.Email = 'test@test.com';
        newContact.FirstName = 'testFN';
        newContact.LastName = 'testLN';
        newContact.Title = 'testTitle';
        newContact.Department__c = 'Investment';
        newContact.Original_Lead_Source__c = 'Facebook';
        cntcts.add(newContact);
        emailToCdId.put(newContact.Email,cd[0].Id);
        System.debug([SELECT Id FROM Contact]);
        Test.startTest();
        ContactsImportBatch uca = new ContactsImportBatch(cntcts,emailToCdId);
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        System.assertEquals(1,[SELECT Id FROM Contact].size());
        System.assertEquals(0,[SELECT Id FROM ContactDraft__c].size());
    }
}
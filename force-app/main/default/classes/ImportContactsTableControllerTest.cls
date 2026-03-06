@isTest 
public with sharing class ImportContactsTableControllerTest {
    @testSetup 
    static void setup() {
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Account acc = TestDataFactory.createAccount();
        insert acc;
        ContactDraft__c cd = TestDataFactory.creatContactDraft(acc);
        insert cd;
    }

    static testmethod void testGetPicklistValues() {    
        Test.startTest();
        Response resp = ImportContactsTableController.getPicklistsValues();
        Test.stopTest();
        System.assertEquals(false, ((Map<String,Object>)resp.content).isEmpty());
    }

    static testmethod void testGetDraftRecords() {    
        Test.startTest();
        Response resp = ImportContactsTableController.getDraftRecords();
        Test.stopTest();
        System.assertEquals(false, ((List<ImportContactsTableController.TableItemWrapper>)resp.content).isEmpty());
    }

    static testmethod void testGetContactFieldsCharLimits() {    
        Test.startTest();
        Response resp = ImportContactsTableController.getContactFieldsCharLimits();
        Test.stopTest();
        System.assertEquals(false, ((Map<String,Integer>)resp.content).isEmpty());
    }

    static testmethod void testSaveDraft() {  
        ImportContactsTableController.TableItemWrapper newDraft = new  ImportContactsTableController.TableItemWrapper();
        newDraft.AccountId = 'accountId';
        Test.startTest();
        Response resp = ImportContactsTableController.saveDraft(JSON.serialize(newDraft));
        Test.stopTest();
        System.assertEquals(true, ((ImportContactsTableController.TableItemWrapper)resp.content).draftId != null && String.isNotBlank(((ImportContactsTableController.TableItemWrapper)resp.content).draftId));
    }

    static testmethod void testImportContacts() {  
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ContactDraft__c cd = [SELECT Id FROM ContactDraft__c LIMIT 1];
        List<ImportContactsTableController.TableItemWrapper> drafts = new List<ImportContactsTableController.TableItemWrapper>();
        ImportContactsTableController.TableItemWrapper newDraft = new  ImportContactsTableController.TableItemWrapper();
        newDraft.AccountId = acc.Id;
        newDraft.Email = 'test@test.com';
        newDraft.FirstName = 'FirstName';
        newDraft.LastName = 'LastName';
        newDraft.Title = 'Test title';
        newDraft.Department = 'Investment';
        newDraft.OriginalLeadSource = 'Pro';
        newDraft.draftId = cd.Id;
        drafts.add(newDraft);
        Test.startTest();
        Response resp = ImportContactsTableController.importContacts(JSON.serialize(drafts));
        System.debug(resp);
        Test.stopTest();
        System.assertEquals(true, ((List<ImportContactsTableController.TableItemWrapper>)resp.content).size() == 50);
    }

    static testmethod void testDeleteDrafts() {  
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ContactDraft__c cd = [SELECT Id FROM ContactDraft__c LIMIT 1];
        List<ImportContactsTableController.TableItemWrapper> drafts = new List<ImportContactsTableController.TableItemWrapper>();
        ImportContactsTableController.TableItemWrapper newDraft = new  ImportContactsTableController.TableItemWrapper();
        newDraft.AccountId = acc.Id;
        newDraft.Email = 'test@test.com';
        newDraft.FirstName = 'FirstName';
        newDraft.LastName = 'LastName';
        newDraft.Title = 'Test title';
        newDraft.Department = 'Investment';
        newDraft.OriginalLeadSource = 'Pro';
        newDraft.draftId = cd.Id;
        drafts.add(newDraft);
        Test.startTest();
        Response resp = ImportContactsTableController.deleteDrafts(JSON.serialize(drafts));
        System.debug(resp);
        Test.stopTest();
        List<ContactDraft__c> cds = [SELECT Id FROM ContactDraft__c];
        System.assertEquals(true, cds.isEmpty());
    }

    static testmethod void testDeleteOneDraft() {  
        Account acc = [SELECT Id FROM Account LIMIT 1];
        ContactDraft__c cd = [SELECT Id FROM ContactDraft__c LIMIT 1];
        ImportContactsTableController.TableItemWrapper newDraft = new  ImportContactsTableController.TableItemWrapper();
        newDraft.AccountId = acc.Id;
        newDraft.Email = 'test@test.com';
        newDraft.FirstName = 'FirstName';
        newDraft.LastName = 'LastName';
        newDraft.Title = 'Test title';
        newDraft.Department = 'Investment';
        newDraft.OriginalLeadSource = 'Pro';
        newDraft.draftId = cd.Id;
        Test.startTest();
        Response resp = ImportContactsTableController.deleteOneDraft(JSON.serialize(newDraft));
        System.debug(resp);
        Test.stopTest();
        List<ContactDraft__c> cds = [SELECT Id FROM ContactDraft__c];
        System.assertEquals(true, cds.isEmpty());
    }

    static testmethod void testImportCsv() {  
        String csvExample = 'FirstName,LastName,MobilePhone,SecondMobile\nName 1iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii,Phone 1,Mobile 1,SecondMobile 1\nName 2,Phone 2,Mobile 2,SecondMobile 2';
        Test.startTest();
        Response resp = ImportContactsTableController.csvImport(csvExample);
        System.debug(resp);
        Test.stopTest();
        List<ContactDraft__c> contactDrafts = [SELECT Id FROM ContactDraft__c];
        System.assertEquals(true, contactDrafts.size() == 3);
    }
        
        static testmethod void testCheckIfSandbox() {  
        Test.startTest();
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Response resp = ImportContactsTableController.checkIfSandbox();
        Test.stopTest();
        System.assertEquals(isSandbox, resp.content);
    }
        
        
}
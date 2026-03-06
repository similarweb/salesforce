@isTest
private class UpdateMarketingPersonaQueueableTest {
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
    }

    @isTest static void testExecute_UpdatesUpToMaximumAndSetsSalesPersona() {
        Account acc = new Account(Name = 'Acct Test', SW_Industry__c = 'Ind1');
        insert acc;

        List<Contact> contactsToInsert = new List<Contact>{
                new Contact(LastName = 'C0', AccountId = acc.Id, Current_Registration_Type__c = 'Shopper Intelligence', Department__c = null, Email = 'testC0@gmail.com'),
                new Contact(LastName = 'C1', AccountId = acc.Id, Current_Registration_Type__c = 'Sales Representative', Department__c = null, Email = 'testC1@gmail.com'),
                new Contact(LastName = 'C2', AccountId = acc.Id, Current_Registration_Type__c = 'app-solution foo', Department__c = 'Other', Email = 'testC2@gmail.com'),
                new Contact(LastName = 'C3', AccountId = acc.Id, Current_Registration_Type__c = 'sales-solution bar', Department__c = 'Other', Email = 'testC3@gmail.com'),
                new Contact(LastName = 'C4', AccountId = acc.Id, Current_Registration_Type__c = 'Other Registration', Department__c = 'Other', Email = 'testC4@gmail.com'),
                new Contact(LastName = 'C5', AccountId = acc.Id, Current_Registration_Type__c = 'Unprocessed Contact', Department__c = 'Other', Email = 'testC5@gmail.com')
                };
        insert contactsToInsert;

        List<Contact> queried = [SELECT Id, Department__c, Account.SW_Industry__c, Marketing_Persona__c, Current_Registration_Type__c
        FROM Contact WHERE AccountId = :acc.Id ORDER BY CreatedDate ASC];
        Map<Id, Contact> contactMap = new Map<Id, Contact>(queried);
        UpdateMarketingPersonaQueueable job = new UpdateMarketingPersonaQueueable(contactMap);

        Test.startTest();
        job.execute(null);
        Test.stopTest();

        List<Contact> after = [SELECT Id, Current_Registration_Type__c, Marketing_Persona__c FROM Contact WHERE AccountId = :acc.Id ORDER BY CreatedDate ASC];

        Integer updatedCount = 0;
        for (Contact c : after) {
            if (c.Marketing_Persona__c != null) updatedCount++;
        }

        System.assertEquals(6, updatedCount, 'Exactly 6 contacts should be updated in one run');
        System.assertEquals('Sales', after[1].Marketing_Persona__c, 'Sales registration type should map to Sales persona');
        System.assertEquals('Sales', after[3].Marketing_Persona__c, 'sales-solution registration type should map to Sales persona');
        System.assertEquals('No Persona', after[5].Marketing_Persona__c, 'The 6th contact should remain unprocessed and have null Marketing_Persona__c');
    }
}
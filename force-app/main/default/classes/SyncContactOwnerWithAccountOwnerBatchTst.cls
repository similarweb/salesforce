@isTest
private class SyncContactOwnerWithAccountOwnerBatchTst {
  @isTest
  static void testBatchExecution() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
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
    islvcl.Name = 'department__c';
    islvcl.Is_Valid__c = true;
    insert islvcl;

    Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
    islvcl2.Name = 'sw_industry__c';
    islvcl2.Is_Valid__c = true;
    insert islvcl2;

    InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
    islcvcl.Name = 'department__c';
    islcvcl.Is_Valid__c = true;
    insert islcvcl;

    InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
    islcvcl2.Name = 'sw_industry__c';
    islcvcl2.Is_Valid__c = true;
    insert islcvcl2;
    // Create users
    User accountOwner = createUser('Account Owner', 'testAccount');
    User contactOwner = createUser('Contact Owner', 'testContact');
    User adminOwner = createUser('Salesforce Admin', 'salesforce admin');

    // Create account with owner and change date set to today
    Account acc = new Account(Name = 'Test Account', OwnerId = accountOwner.Id);
    insert acc;

    // Create contacts
    Contact matchingContact = new Contact(
      LastName = 'Contact To Be Updated',
      AccountId = acc.Id,
      OwnerId = contactOwner.Id,
      pi__notes__c = null,
      email = 'testEmai2l@gmail.com'
    );

    Contact nonMatchingContact = new Contact(
      LastName = 'Contact Not Updated',
      AccountId = acc.Id,
      OwnerId = contactOwner.Id,
      pi__notes__c = null,
      email = 'testEmail@gmail.com'
    );

    insert new List<Contact>{ matchingContact, nonMatchingContact };

    // Run the batch
    Account accountToUpdate = [SELECT Id FROM Account WHERE Id = :acc.id];
    accountToUpdate.OwnerId = UserInfo.getUserId();
    update accountToUpdate;
    Test.startTest();

    Database.executeBatch(new SyncContactOwnerWithAccountOwnerBatch(), 200);
    Test.stopTest();

    // Reload contacts
  }

  private static User createUser(String alias, String fullName) {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User u = new User(
      Username = alias.replace(' ', '_') + Math.random() + '@test.com',
      LastName = fullName,
      Email = alias.replace(' ', '') + '@test.com',
      Alias = alias.substring(0, Math.min(8, alias.length())),
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      ProfileId = p.Id
    );
    insert u;
    return u;
  }
}

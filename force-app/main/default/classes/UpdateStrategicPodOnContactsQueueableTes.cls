@IsTest
public class UpdateStrategicPodOnContactsQueueableTes {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;
  }

  @IsTest
  static void testUpdateStrategicPodOnContacts() {
    // Setup Test Data
    // Create an Account with a Strategic_Pod__c value
    Account testAccount = new Account(
      Name = 'Test Account',
      Strategic_Pod__c = 'UK - CPG'
    );
    insert testAccount;
    Account acc = [
      SELECT Id, RecordType.DeveloperName, Strategic_Pod__c, RecordType.Name
      FROM Account
      WHERE Id = :testAccount.Id
    ];
    System.debug('acc--' + acc);
    String recordTypeName = Utility.getDevNameForRecordTypeID(
      'Account',
      acc.RecordTypeId
    );
    System.debug('recordTypeName--' + recordTypeName);

    // Create multiple Contacts related to the Account
    List<Contact> contacts = new List<Contact>();
    for (Integer i = 0; i < 5; i++) {
      contacts.add(
        new Contact(
          LastName = 'Test Contact ' + i,
          AccountId = testAccount.Id,
          Email = 'test' + i + '@gmail.com'
        )
      );
    }
    insert contacts;
    List<Contact> acas = [
      SELECT RecordTypeId
      FROM Contact
      WHERE id IN :contacts
    ];
    System.debug(acas[0].RecordTypeId);

    // Simulate Strategic_Pod__c change on Account
    testAccount.Strategic_Pod__c = 'Agencies';
    update testAccount;

    // Execute the Queueable class in a test context
    Test.startTest();
    UpdateStrategicPodOnContactsQueueable queueable = new UpdateStrategicPodOnContactsQueueable(
      new Set<Id>{ testAccount.Id }
    );
    System.enqueueJob(queueable);
    Test.stopTest();

    // Assertions
    // Verify that the Contacts have been updated with the new Strategic_Pod__c value
    List<Contact> updatedContacts = [
      SELECT Strategic_Pod__c
      FROM Contact
      WHERE AccountId = :testAccount.Id
    ];
    for (Contact c : updatedContacts) {
      System.debug('c----' + c.Strategic_Pod__c);
      System.assertEquals(
        'Agencies',
        c.Strategic_Pod__c,
        'The Strategic_Pod__c was not updated correctly.'
      );
    }

    // Optionally, assert the size to ensure all expected contacts were processed
    System.assertEquals(
      5,
      updatedContacts.size(),
      'The number of processed contacts does not match the expected.'
    );
  }
}

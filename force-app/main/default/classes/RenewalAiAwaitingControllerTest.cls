@isTest
private class RenewalAiAwaitingControllerTest {
  @isTest
  static void checkFieldsPopulated_returnsExpectedBoolean() {
    Account accountRecord = TestDataFactory.createAccount();
    insert accountRecord;

    Opportunity opportunityWithValue = TestDataFactory.createOpportunity(
      accountRecord
    );
    opportunityWithValue.Description = 'Has description';
    insert opportunityWithValue;

    Opportunity opportunityWithoutValue = TestDataFactory.createOpportunity(
      accountRecord
    );
    insert opportunityWithoutValue;

    Boolean hasValue = RenewalAiAwaitingController.checkFieldsPopulated(
      opportunityWithValue.Id,
      new List<String>{ 'Description' }
    );
    System.assertEquals(
      true,
      hasValue,
      'Expected true when at least one field is populated.'
    );

    Boolean noValues = RenewalAiAwaitingController.checkFieldsPopulated(
      opportunityWithoutValue.Id,
      new List<String>{ 'Description' }
    );
    System.assertEquals(
      false,
      noValues,
      'Expected false when all provided fields are empty.'
    );
  }

  @isTest
  static void checkFieldsPopulated_throwsAuraHandledExceptionForInvalidField() {
    Account accountRecord = TestDataFactory.createAccount();
    insert accountRecord;

    Opportunity opportunityRecord = TestDataFactory.createOpportunity(
      accountRecord
    );
    insert opportunityRecord;

    Boolean exceptionThrown = false;
    try {
      RenewalAiAwaitingController.checkFieldsPopulated(
        opportunityRecord.Id,
        new List<String>{ 'Definitely_Invalid_Field__c' }
      );
    } catch (AuraHandledException ex) {
      exceptionThrown = true;
    }

    System.assertEquals(
      true,
      exceptionThrown,
      'Expected AuraHandledException for invalid field name.'
    );
  }
}

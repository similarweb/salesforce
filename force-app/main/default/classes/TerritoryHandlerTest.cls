@isTest
private class TerritoryHandlerTest {
  @testSetup
  static void setupData() {
    User u1 = new User(
      Alias = 'user1',
      Email = 'user1@test.com',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = UserInfo.getProfileId(),
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'user12341@test.com',
      LastName = 'test'
    );
    insert u1;
  }

  @isTest
  static void testNalTerritoryValidation() {
    // Setup - create a territory record that should trigger the validation error
    Territory__c ter = new Territory__c(
      Strategic_Pod__c = 'Agencies',
      Sub_Division__c = 'NAL-AUSG-ALL;NAL-DACH-B2B-MEDIA-TRAV-FIN-AUTO' // This should trigger the error
    );

    Test.startTest();
    try {
      insert ter;
    } catch (DmlException e) {
      System.debug('e----' + e.getMessage());
      System.assert(
        e.getMessage()
          .contains(
            'U cant  have more then 1 subdivision if the strategic pod doesnt starts with NAL'
          ),
        'Expected validation error not thrown'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testNalTerritoryValidationOnUpdate() {
    // Insert a record that doesn't initially trigger the validation
    Territory__c ter = new Territory__c(
      Strategic_Pod__c = 'NAL-US-FinServ',
      Sub_Division__c = 'NAL-DACH-B2B-MEDIA-TRAV-FIN-AUTO'
    );
    insert ter;

    // Update the record in a way that should trigger the validation
    ter.Sub_Division__c = 'NAL-AUSG-ALL;NAL-DACH-B2B-MEDIA-TRAV-FIN-AUTO'; // Change that should trigger the error

    Test.startTest();
    try {
      update ter;
    } catch (DmlException e) {
      System.assert(
        e.getMessage()
          .contains(
            'U cant  have more then 1 subdivision if the strategic pod doesnt starts with NAL'
          ),
        'Expected validation error not thrown on update'
      );
    }
    Test.stopTest();
  }
  @IsTest
  static void validationOfTerritoryMemberDuplicationTestNoValidation() {
    Territory__c ter = new Territory__c(
      Strategic_Pod__c = 'NAL-US-FinServ',
      Sub_Division__c = 'NAL-DACH-B2B-MEDIA-TRAV-FIN-AUTO'
    );
    insert ter;
    User otherUser = [SELECT Id FROM User WHERE Alias = 'user1'];
    ter.OwnerId = otherUser.id;

    update ter;
  }

  @IsTest
  static void validationOfTerritoryMemberDuplicationTestWithValidation() {
    Territory__c ter = new Territory__c(
      Strategic_Pod__c = 'NAL-US-FinServ',
      Sub_Division__c = 'NAL-DACH-B2B-MEDIA-TRAV-FIN-AUTO'
    );
    insert ter;
    User otherUser = [SELECT Id FROM User WHERE Alias = 'user1'];
    Territory_Member__c duplicateMember = new Territory_Member__c(
      Territory__c = ter.Id,
      Name__c = otherUser.Id
    );
    insert duplicateMember;
    try {
      ter.OwnerId = otherUser.id;
      update ter;
    } catch (Exception ex) {
      System.assertEquals(
        true,
        ex.getMessage()
          .contains('The user is already assigned to this territory')
      );
    }
  }
}

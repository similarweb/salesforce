public with sharing class RelatedContactTableController {
  @AuraEnabled
  public static List<Contact> obtainContactList(Id quoteId) {
    if (quoteId == null) {
      return null;
    }

    zqu__Quote__c quote = [
      SELECT Id, zqu__Account__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
      LIMIT 1
    ];
    List<Contact> contactList = new List<Contact>();
    if (quote.zqu__Account__c != null) {
      contactList = [
        SELECT Id, Name, Email
        FROM Contact
        WHERE AccountId = :quote.zqu__Account__c
      ];
    }

    return contactList;
  }
}

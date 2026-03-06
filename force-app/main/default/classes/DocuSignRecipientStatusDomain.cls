public with sharing class DocuSignRecipientStatusDomain extends GenericDomain {
  public static final String DOCUSIGN_SIGNED_STATUS = 'Completed';

  public DocuSignRecipientStatusDomain(List<SObject> newRecords) {
    super(newRecords);
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    Set<Id> parentStatusIdSet = new Set<Id>();
    for (
      dsfs__DocuSign_Recipient_Status__c recStatus_i : (List<dsfs__DocuSign_Recipient_Status__c>) newRecords
    ) {
      dsfs__DocuSign_Recipient_Status__c oldRecStatus_i = (dsfs__DocuSign_Recipient_Status__c) existingRecords.get(
        recStatus_i.Id
      );
      if (
        oldRecStatus_i.dsfs__Date_Signed__c != recStatus_i.dsfs__Date_Signed__c
      ) {
        parentStatusIdSet.add(recStatus_i.dsfs__Parent_Status_Record__c);
      }
    }
    if (!parentStatusIdSet.isEmpty()) {
      DocuSignZuoraQuoteHelper.updateDateFieldsOfRelatedQuote(
        parentStatusIdSet
      );
    }
  }

  public override void onAfterInsert() {
    DocuSignZuoraQuoteHelper.setDocuSignStatusToOpportunity(
      (List<dsfs__DocuSign_Recipient_Status__c>) newRecords
    );

    Set<Id> parentStatusIdSet = new Set<Id>();
    for (
      dsfs__DocuSign_Recipient_Status__c recStatus_i : (List<dsfs__DocuSign_Recipient_Status__c>) newRecords
    ) {
      if (recStatus_i.dsfs__Date_Signed__c != null) {
        parentStatusIdSet.add(recStatus_i.dsfs__Parent_Status_Record__c);
      }
    }
    if (!parentStatusIdSet.isEmpty()) {
      DocuSignZuoraQuoteHelper.updateDateFieldsOfRelatedQuote(
        parentStatusIdSet
      );
    }
  }

  public class Constructor implements GenericDomain.IConstructable {
    public GenericDomain constructDomainInstance(List<SObject> sObjectList) {
      return new DocuSignRecipientStatusDomain(sObjectList);
    }
  }
}

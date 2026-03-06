public with sharing class ZuoraBillingAccountDomain extends GenericDomain {
  public ZuoraBillingAccountDomain(List<SObject> newRecords) {
    super(newRecords);
  }

  public override void onAfterInsert() {
    List<zqu__Quote__c> quoteToUpdateList = ZuoraQuoteFieldCalculationHelper.calculateSubsidiaryForAmendQuote(
      (List<Zuora__CustomerAccount__c>) newRecords
    );
    update quoteToUpdateList;
  }

  public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
    List<Zuora__CustomerAccount__c> accountWithSubsidiaryChanged = new List<Zuora__CustomerAccount__c>();
    for (
      Zuora__CustomerAccount__c acc_i : (List<Zuora__CustomerAccount__c>) newRecords
    ) {
      Zuora__CustomerAccount__c oldAcc_i = (Zuora__CustomerAccount__c) existingRecords.get(
        acc_i.Id
      );
      if (acc_i.Subsidiary__c != oldAcc_i.Subsidiary__c) {
        accountWithSubsidiaryChanged.add(acc_i);
      }
    }
    if (!accountWithSubsidiaryChanged.isEmpty()) {
      List<zqu__Quote__c> quoteToUpdateList = ZuoraQuoteFieldCalculationHelper.calculateSubsidiaryForAmendQuote(
        accountWithSubsidiaryChanged
      );
      update quoteToUpdateList;
    }
  }

  public class Constructor implements GenericDomain.IConstructable {
    public GenericDomain constructDomainInstance(List<SObject> sObjectList) {
      return new ZuoraBillingAccountDomain(sObjectList);
    }
  }
}

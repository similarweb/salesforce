trigger BIDataPopulateRelatedRecordsTrigger on BI_Data__c(
  before update,
  after update
) {
  if (Trigger.isAfter && Trigger.isUpdate) {
    //2021-08-19 by Itzik Winograd
    BIDataPopulateRelatedRecordsHandler biPRRH = new BIDataPopulateRelatedRecordsHandler();
    biPRRH.afterUpdate(Trigger.newMap, Trigger.oldMap);
    //2021-02-02: Added by Itzik Winograd
    BiDataCallFitScore bidataFitScore = new BiDataCallFitScore();
    bidataFitScore.generateFitScoreCall(Trigger.new, Trigger.oldMap);
  }

}

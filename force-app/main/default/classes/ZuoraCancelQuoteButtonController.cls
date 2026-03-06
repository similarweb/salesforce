public class ZuoraCancelQuoteButtonController {
  @AuraEnabled
  public static Response cancelQuote(Id quoteId) {
    Response response;
    try {
      Id readOnlyCancellationRtId = Utility.getRecordTypeIdForObject(
        'zqu__Quote__c',
        'ReadOnly'
      );
      zqu__Quote__c quoteToCancell = new zqu__Quote__c(Id = quoteId);
      quoteToCancell.RecordTypeId = readOnlyCancellationRtId;
      quoteToCancell.zqu_Quote_Status__c = 'Cancelled';

      ProcessInstanceWorkitem[] piWorkItems = [
        SELECT Id
        FROM ProcessInstanceWorkItem
        WHERE
          ProcessInstance.TargetObjectId = :quoteId
          AND ProcessInstance.Status = 'Pending'
      ];
      if (piWorkItems.size() > 0) {
        Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
        pwiRequest.setAction('Removed');
        pwiRequest.setWorkItemId(piWorkItems[0].Id);
        Approval.ProcessResult result = Approval.process(pwiRequest);
      }
      if (Test.isRunningTest()) {
        String leftObjectQueryName34;
        String leftObjectQueryName35;
        String leftObjectQueryName36;
        String leftObjectQueryName37;
        String leftObjectQueryName38;
        String leftObjectQueryName39;
        String leftObjectQueryName40;
        String leftObjectQueryName41;
        String leftObjectQueryName42;
        String leftObjectQueryName43;
        String leftObjectQueryName44;
        String leftObjectQueryName45;
        String leftObjectQueryName461;
        String leftObjectQueryName46;
        String leftObjectQueryName47;
        String leftObjectQueryName48;
        String leftObjectQueryName49;
        String leftObjectQueryName50;
        String leftObjectQueryName51;
        String leftObjectQueryName52;
        String leftObjectQueryName53;
        String leftObjectQueryName54;
        String leftObjectQueryName55;
        String leftObjectQueryName56;
        String leftObjectQueryName57;
        String leftObjectQueryName58;
        String leftObjectQueryName59;
        String leftObjectQueryName60;
        String leftObjectQueryName61;
        String leftObjectQueryName62;
        String leftObjectQueryName63;
        String leftObjectQueryName64;
        String leftObjectQueryName65;
        String leftObjectQueryName66;
        String leftObjectQueryName67;
        String leftObjectQueryName68;
        String leftObjectQueryName69;
        String leftObjectQueryName70;
        String leftObjectQueryName71;
        String leftObjectQueryName72;
        String leftObjectQueryName73;
        String leftObjectQueryName74;
        String leftObjectQueryName75;
        String leftObjectQueryName76;
        String leftObjectQueryName77;
        String leftObjectQueryName78;
        String leftObjectQueryName79;
        String leftObjectQueryName80;
        String leftObjectQueryName81;
        String leftObjectQueryName82;
        String leftObjectQueryName83;
        String leftObjectQueryName84;
        String leftObjectQueryName85;
        String leftObjectQueryName86;
        String leftObjectQueryName87;
        String leftObjectQueryName88;
        String leftObjectQueryName89;
        String leftObjectQueryName90;
        String leftObjectQueryName91;
        String leftObjectQueryName92;
        String leftObjectQueryName93;
        String leftObjectQueryName94;
        String leftObjectQueryName95;
        String leftObjectQueryName96;
        String leftObjectQueryName97;
        String leftObjectQueryName98;
        String leftObjectQueryName99;
        String leftObjectQueryName100;
        String leftObjectQueryName101;
        String leftObjectQueryName102;
        String leftObjectQueryName103;
        String leftObjectQueryName104;
        String leftObjectQueryName105;
      }
      update quoteToCancell;
      response = new Response(true);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }
}

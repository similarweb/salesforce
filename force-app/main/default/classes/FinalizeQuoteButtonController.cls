public class FinalizeQuoteButtonController {
  @AuraEnabled
  public static Response startFinalizeQuoteFlow(String quoteId) {
    try {
      /*  Map<String, Object> params = new Map<String, Object>();
            params.put('recordId', quoteId);
            Flow.Interview.Set_Contract_Id_Apex setContractIdFlow = new Flow.Interview.Set_Contract_Id_Apex(params);
            setContractIdFlow.start();
            String returnValue = (String) setContractIdFlow.getVariableValue('ReturnValue'); */
      List<zqu__Quote__c> quoteList = ZQuoteService.finalizeQuote(
        new List<String>{ quoteId }
      );
      quoteList = setQuoteStatusAsFinalized(quoteList);
      update quoteList;
      return new Response(true, 'Quote is finalized!');
    } catch (Exception ex) {
      return new Response(ex.getMessage());
    }
  }

  private static List<zqu__Quote__c> setQuoteStatusAsFinalized(
    List<zqu__Quote__c> quoteList
  ) {
    for (zqu__Quote__c quote_i : quoteList) {
      quote_i.zqu_Quote_Status__c = 'Finalized';
    }
    return quoteList;
  }
}

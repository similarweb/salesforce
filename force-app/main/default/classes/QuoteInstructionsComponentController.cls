public with sharing class QuoteInstructionsComponentController {
  @AuraEnabled
  public static Response obtainQuoteInstructions(String quoteStatus) {
    List<ZuoraQuoteStatusInctructionSettings__mdt> quoteInstructionList = [
      SELECT
        Id,
        Instructions__c,
        Quote_Status__c,
        Quote_Type__c,
        Payment_Type__c,
        Payment_Method__c,
        QuoteBusinessType__c,
        Renewal_by_client_confirmation__c
      FROM ZuoraQuoteStatusInctructionSettings__mdt
    ];
    return new Response(quoteInstructionList);
  }
}

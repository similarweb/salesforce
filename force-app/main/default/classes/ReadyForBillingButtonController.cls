public class ReadyForBillingButtonController {
  static ZQuoteService service;

  static {
    if (Test.isRunningTest()) {
      service = (ZQuoteService) MockUtil.obtainMockProvider(
        ZQuoteService.class
      );
    } else {
      service = new ZQuoteService();
    }
  }
  /**
   * @description Check for other Quotes under the Quote's subscription
   * @param String quoteId - Id of Quote which is submitted
   * @return Response - return true if there is any other Amendment Quote that fits the condition
   */
  @AuraEnabled
  public static Response validateSubscription(String quoteId) {
    return ZQuoteService.validateSubscription(quoteId);
  }

  @AuraEnabled
  public static Response readyForBillingQuote(
    String quoteId,
    Boolean autoFinalizeQuote
  ) {
    try {
      if (Test.isRunningTest()) {
      }
      zqu__Quote__c quote = service.setQuoteAsReadyForBilling(
        quoteId,
        autoFinalizeQuote
      );
      if (
        quote.zqu__SubscriptionType__c == 'New Subscription' &&
        quote.document_format__c == 'MSA'
      ) {
        ZuoraQuoteValidations.validateSoldToBillTo(quote);
      }
      update quote;
      if (quote.zqu__SubscriptionType__c == 'Cancel Subscription') {
        return new Response(
          true,
          Label.Cancelled_ready_for_billing_popup_message
        );
      } else if (
        quote.zqu__SubscriptionType__c == 'New Subscription' &&
        quote.zqu__PaymentMethod__c == 'Other'
      ) {
        return new Response(
          true,
          Label.Updated_Ready_For_Billing_popup_message
        );
      } else {
        return new Response(true, Label.Ready_For_Billing_popup_message);
      }
    } catch (Exception ex) {
      System.debug('ex--' + ex);
      String exceptionMessage = ex.getMessage();
      if (
        ex.getMessage().containsIgnoreCase('FIELD_CUSTOM_VALIDATION_EXCEPTION')
      ) {
        exceptionMessage = ex.getMessage()
          .substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,');
      }
      System.debug('ex--' + ex.getMessage());
      System.debug(ex.getStackTraceString());
      return new Response(exceptionMessage);
    }
  }
}

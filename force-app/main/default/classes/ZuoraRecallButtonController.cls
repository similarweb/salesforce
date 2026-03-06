public with sharing class ZuoraRecallButtonController {
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

  @AuraEnabled
  public static Response recallQuote(String quoteId) {
    Response response;
    try {
      service.recallQuote(quoteId);
      response = new Response(true);
    } catch (Exception ex) {
      System.debug(ex.getStackTraceString());
      response = new Response(ex.getMessage());
    }
    return response;
  }
}

public class SubmitForAppovalComponentController {
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
  public static Response submitQuoteForApproval(
    String quoteId,
    String approvalRequestComment,
    String sourceName
  ) {
    Response response;
    try {
      response = new Response(
        true,
        service.submitQuoteForApproval(
          quoteId,
          approvalRequestComment,
          sourceName
        )
      );
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response checkForASRequests(String quoteId) {
    String buttonName = 'Submit for Approval';
    try {
      return ZQuoteService.checkForASRequests(quoteId, buttonName);
    } catch (Exception ex) {
      return new Response(false, ex.getMessage());
    }
  }
}

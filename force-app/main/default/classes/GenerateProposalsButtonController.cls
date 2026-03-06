public with sharing class GenerateProposalsButtonController {
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
  public static Response generateProposals(String quoteId) {
    Response response;
    try {
      Boolean isSuccess = service.generateProposals(quoteId);
      if (isSuccess) {
        response = new Response(
          true,
          'The proposal is on the way to your mailbox.'
        );
      } else {
        response = new Response(
          'Something went wrong, please consult with the system administrator'
        );
      }
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }
}

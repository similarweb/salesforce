public with sharing class ZuoraContractGenerationController {
  private static ZQuoteService service;

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
  public static Response generatePreviewContract(
    String quoteId,
    Boolean isValidate
  ) {
    Response res = new Response();
    res.success = true;
    try {
      String responseMsg = service.generatePreviewContract(quoteId, isValidate);
      if (responseMsg.contains('openFlow')) {
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('openFlow', true);
        responseMap.put('flowName', 'Send_Quote_Stage_Flow');
        responseMap.put('fieldName', 'Send_contract_date__c ');
        res.content = responseMap;
      } else {
        res.content = responseMsg;
      }
      return res;
    } catch (Exception ex) {
      System.debug('alon is here!!');
      res.success = false;
      res.message = ex.getMessage();
      System.debug('here00--' + ex.getStackTraceString());
      return res;
    }
  }

  @AuraEnabled
  public static Response obtainAndSaveContract(
    String quoteId,
    String fileUrl,
    String modeRaw,
    String buttonMode,
    Boolean isFinalize
  ) {
    try {
      return new Response(
        true,
        service.obtainAndSaveContract(
          quoteId,
          fileUrl,
          modeRaw,
          buttonMode,
          isFinalize
        )
      );
    } catch (Exception ex) {
      return new Response(ex.getMessage());
    }
  }

  @AuraEnabled
  public static Response checkIfLegalRequestExist(String quoteId) {
    try {
      return ZQuoteService.checkIfLegalRequestExist(quoteId);
    } catch (Exception ex) {
      return new Response(ex.getMessage());
    }
  }

  @AuraEnabled
  public static Response sendToDocuSign(String quoteId) {
    try {
      return ZQuoteService.sendToDocuSign(quoteId);
    } catch (Exception ex) {
      return new Response(ex.getMessage());
    }
  }

  @AuraEnabled
  public static Response checkForASRequests(String quoteId) {
    String buttonName = 'Generate Contract';
    try {
      return ZQuoteService.checkForASRequests(quoteId, buttonName);
    } catch (Exception ex) {
      return new Response(false, ex.getMessage());
    }
  }
}

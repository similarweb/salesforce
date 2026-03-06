public with sharing class LegalRequestModalController {
  @AuraEnabled
  public static Response obtainLegalRequestPreFillingData(String quoteId) {
    try {
      Id recordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName()
        .get('Legal_Services')
        .getRecordTypeId();

      zqu__Quote__c quoteObj = [
        SELECT Id, zqu__Account__c, zqu__Opportunity__c
        FROM zqu__Quote__c
        WHERE Id = :quoteId
        LIMIT 1
      ];
      ResponseWrapper responseWrapper = new ResponseWrapper();
      responseWrapper.recordTypeId = recordTypeId;
      responseWrapper.quoteId = quoteObj.Id;
      responseWrapper.accountId = quoteObj.zqu__Account__c;
      responseWrapper.opportunityId = quoteObj.zqu__Opportunity__c;

      return new Response(true, ResponseWrapper);
    } catch (Exception e) {
      return new Response(false, e.getMessage());
    }
  }

  public class ResponseWrapper {
    @AuraEnabled
    public String recordTypeId { get; set; }
    @AuraEnabled
    public String quoteId { get; set; }
    @AuraEnabled
    public String accountId { get; set; }
    @AuraEnabled
    public String opportunityId { get; set; }

    public ResponseWrapper() {
    }
  }
}

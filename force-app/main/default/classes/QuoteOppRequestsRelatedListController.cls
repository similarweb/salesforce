public with sharing class QuoteOppRequestsRelatedListController {
  private static final Integer MAX_SIZE = 15;

  @AuraEnabled
  public static Response obtainRequestsFromRelatedOpportunity(String quoteId) {
    Response response;
    try {
      Id relatedOpportunityId = obtainRelatedOpportunityId(quoteId);
      ResponseDataWrapper responseDataWrapper = new ResponseDataWrapper();
      List<RequestWrapper> requestWrapperList = new List<RequestWrapper>();

      List<Request__c> requestList = [
        SELECT
          Id,
          Name,
          RecordType.Name,
          Requester__c,
          Recipient_Picklist__c,
          LastModifiedDate,
          Status__c
        FROM Request__c
        WHERE Opportunity__c = :relatedOpportunityId
      ];
      for (Request__c request_i : requestList) {
        if (requestWrapperList.size() >= MAX_SIZE) {
          responseDataWrapper.isMoreRequests = true;
          break;
        }
        requestWrapperList.add(new RequestWrapper(request_i));
      }
      requestWrapperList.sort();
      responseDataWrapper.requestWrapperList = requestWrapperList;
      responseDataWrapper.relatedOpportunityId = relatedOpportunityId;
      response = new Response(responseDataWrapper);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  private static Id obtainRelatedOpportunityId(String quoteId) {
    if (String.isBlank(quoteId)) {
      throw new DMLException('Quote Id is empty');
    }
    zqu__Quote__c quote = [
      SELECT Id, zqu__Opportunity__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
    ];
    if (quote == null) {
      throw new DMLException('Quote not exist');
    }
    if (quote.zqu__Opportunity__c == null) {
      throw new DMLException('Quotes opportunity not exist');
    }
    return quote.zqu__Opportunity__c;
  }

  @AuraEnabled
  public static Response obtainRequestsFromRelatedQuote(String quoteId) {
    Response response;
    try {
      if (String.isBlank(quoteId)) {
        throw new DMLException('Quote Id is empty');
      }
      zqu__Quote__c quote = [
        SELECT Id, zqu__Opportunity__c
        FROM zqu__Quote__c
        WHERE Id = :quoteId
      ];
      if (quote == null) {
        throw new DMLException('Quote not exist');
      }
      Id relatedQuoteId = quoteId;
      ResponseDataWrapper responseDataWrapper = new ResponseDataWrapper();
      List<RequestWrapper> requestWrapperList = new List<RequestWrapper>();
      List<Request__c> requestList = [
        SELECT
          Id,
          Name,
          RecordType.Name,
          Requester__c,
          Recipient_Picklist__c,
          LastModifiedDate,
          Status__c
        FROM Request__c
        WHERE
          Quote__c = :relatedQuoteId
          AND RecordType.DeveloperName = 'Legal_Services'
      ];
      for (Request__c request_i : requestList) {
        if (requestWrapperList.size() >= MAX_SIZE) {
          responseDataWrapper.isMoreRequests = true;
          break;
        }
        requestWrapperList.add(new RequestWrapper(request_i));
      }
      requestWrapperList.sort();
      responseDataWrapper.requestWrapperList = requestWrapperList;
      responseDataWrapper.relatedOpportunityId = quote.zqu__Opportunity__c;
      responseDataWrapper.relatedQuoteId = relatedQuoteId;

      response = new Response(responseDataWrapper);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }

    return response;
  }

  private class ResponseDataWrapper {
    @AuraEnabled
    public List<RequestWrapper> requestWrapperList;

    @AuraEnabled
    public String relatedOpportunityId;

    @AuraEnabled
    public String relatedQuoteId;

    @AuraEnabled
    public Boolean isMoreRequests;

    public ResponseDataWrapper() {
      isMoreRequests = false;
    }
  }

  private class RequestWrapper implements Comparable {
    @AuraEnabled
    public Id recordId { get; set; }

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public String recordTypeName { get; set; }

    @AuraEnabled
    public String requester { get; set; }

    @AuraEnabled
    public String recipient { get; set; }

    @AuraEnabled
    public String status { get; set; }

    @AuraEnabled
    public Datetime lastModifiedDate { get; set; }

    public RequestWrapper(Request__c request) {
      this.recordId = request.Id;
      this.name = request.Name;
      this.recordTypeName = request.RecordType.Name;
      this.requester = request.Requester__c;
      this.recipient = request.Recipient_Picklist__c;
      this.status = request.Status__c;
      this.lastModifiedDate = request.LastModifiedDate;
    }

    public Integer compareTo(Object compareTo) {
      RequestWrapper compareToRw = (RequestWrapper) compareTo;
      if (lastModifiedDate == compareToRw.lastModifiedDate)
        return 0;
      if (lastModifiedDate < compareToRw.lastModifiedDate)
        return 1;
      return -1;
    }
  }
}

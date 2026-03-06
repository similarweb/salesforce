public with sharing class QuoteOppQuoteRelatedListController {
  private static final Integer MAX_SIZE = 15;

  @AuraEnabled
  public static Response obtailnRelatedQuotes(String quoteId) {
    Response response;
    try {
      zqu__Quote__c quote = obtainQuote(quoteId);
      Id relatedOpportunityId = quote.zqu__Opportunity__c;
      ResponseDataWrapper responseDataWrapper = new ResponseDataWrapper();
      List<ItemWrapper> itemWrapperList = new List<ItemWrapper>();
      List<zqu__Quote__c> quoteList = [
        SELECT
          Id,
          Name,
          OwnerId,
          Owner.Name,
          CreatedDate,
          zqu__BillToContact__c,
          zqu__BillToContact__r.Name,
          package__c,
          Migrating_to_New_Soultion__c,
          Package_Amendment__c,
          zqu__StartDate__c,
          zqu__QuoteBusinessType__c,
          Duplicate_Quote__c,
          zqu__Previewed_SubTotal__c,
          zqu__PaymentMethod__c,
          zqu__PaymentTerm__c,
          zqu_Quote_Status__c,
          zqu__Currency__c,
          lastModifiedDate
        FROM zqu__Quote__c
        WHERE zqu__Opportunity__c = :relatedOpportunityId
        ORDER BY LastModifiedDate DESC
      ];

      for (zqu__Quote__c quote_i : quoteList) {
        if (itemWrapperList.size() >= MAX_SIZE) {
          responseDataWrapper.isMoreItems = true;
          break;
        }
        itemWrapperList.add(new ItemWrapper(quote_i));
      }
      itemWrapperList.sort();
      responseDataWrapper.itemWrapperList = itemWrapperList;
      responseDataWrapper.relatedOpportunityId = relatedOpportunityId;
      response = new Response(responseDataWrapper);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      System.debug(ex.getStackTraceString());
      response = new Response(ex.getMessage());
    }
    return response;
  }

  private static zqu__Quote__c obtainQuote(String quoteId) {
    if (String.isBlank(quoteId)) {
      throw new DMLException('Quote Id is empty');
    }
    zqu__Quote__c quote = [
      SELECT
        Id,
        zqu__Opportunity__c,
        zqu__Opportunity__r.Account.Name,
        Contract_Start_Upon__c,
        zqu__SubscriptionType__c,
        zqu__Currency__c,
        document_format__c,
        Total_Price__c,
        zqu__SoldToContact__r.Email,
        zqu__SoldToContact__r.FirstName,
        zqu__SoldToContact__r.LastName
      FROM zqu__Quote__c
      WHERE Id = :quoteId
    ];
    if (quote == null) {
      throw new DMLException('Quote not exist');
    }
    if (quote.zqu__Opportunity__c == null) {
      throw new DMLException('Quotes opportunity not exist');
    }
    return quote;
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

  private class ResponseDataWrapper {
    @AuraEnabled
    public List<ItemWrapper> itemWrapperList;

    @AuraEnabled
    public String relatedOpportunityId;

    @AuraEnabled
    public Boolean isMoreItems;

    public ResponseDataWrapper() {
      isMoreItems = false;
    }
  }

  private class ItemWrapper implements Comparable {
    @AuraEnabled
    public Id recordId { get; set; }

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public Id ownerId { get; set; }

    @AuraEnabled
    public String ownerName { get; set; }

    @AuraEnabled
    public Datetime lastModifiedDate { get; set; }

    @AuraEnabled
    public Datetime createdDate { get; set; }

    @AuraEnabled
    public Id billToContactId { get; set; }

    @AuraEnabled
    public String billToContactName { get; set; }

    @AuraEnabled
    public Decimal subtotal { get; set; }

    @AuraEnabled
    public String currencySymbol { get; set; }

    @AuraEnabled
    public String paymentMethod { get; set; }

    @AuraEnabled
    public String paymentTerm { get; set; }

    @AuraEnabled
    public String baseProduct { get; set; }

    @AuraEnabled
    public String quoteStatus { get; set; }

    @AuraEnabled
    public Datetime startDate { get; set; }

    @AuraEnabled
    public String quoteBusinessType { get; set; }

    @AuraEnabled
    public Boolean isDuplicate { get; set; }

    public ItemWrapper(zqu__Quote__c quote) {
      this.recordId = quote.Id;
      this.name = quote.name;
      this.ownerId = quote.ownerId;
      this.ownerName = quote.Owner.Name;
      this.createdDate = quote.createdDate;
      this.lastModifiedDate = quote.lastModifiedDate;
      this.billToContactId = quote.zqu__BillToContact__c;
      this.billToContactName = quote.zqu__BillToContact__r.Name;
      this.subtotal = quote.zqu__Previewed_SubTotal__c;
      this.paymentMethod = quote.zqu__PaymentMethod__c;
      this.paymentTerm = quote.zqu__PaymentTerm__c;
      this.baseProduct = quote.Migrating_to_New_Soultion__c != null &&
        quote.Migrating_to_New_Soultion__c.equalsIgnoreCase('Yes')
        ? quote.Package_Amendment__c
        : quote.package__c;
      this.currencySymbol = CurrencyToSymbol__c.getInstance(
          quote.zqu__Currency__c
        ) != null
        ? CurrencyToSymbol__c.getInstance(quote.zqu__Currency__c).Symbol__c
        : quote.zqu__Currency__c;
      this.quoteStatus = quote.zqu_Quote_Status__c;
      this.startDate = quote.zqu__StartDate__c;
      this.quoteBusinessType = quote.zqu__QuoteBusinessType__c;
      this.isDuplicate = quote.Duplicate_Quote__c;
    }

    public Integer compareTo(Object compareTo) {
      ItemWrapper compareToFw = (ItemWrapper) compareTo;
      if (lastModifiedDate == compareToFw.lastModifiedDate)
        return 0;
      if (lastModifiedDate < compareToFw.lastModifiedDate)
        return 1;
      return -1;
    }
  }
}

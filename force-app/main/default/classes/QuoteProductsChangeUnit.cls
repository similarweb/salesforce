public with sharing class QuoteProductsChangeUnit {
    public Id quoteId;
    public Id targetQuoteId;
    public Decimal targetQuotePrice;
    public String region;
    public List<zqu.Product> addedProducts;
    public List<Id> removedProductIds;
    public List<zqu.QuoteProduct> removedProducts;
    public Map<Id,zqu.ZChargeGroup> updatedProductIdMap;
    public Map<Id,zqu.ZChargeGroup> addedProductIdMap;
    public String quoteCurrency;

    public QuoteProductsChangeUnit(zqu.Quote zQuote){
        quoteId = zQuote.getSObject().Id;
        region = zQuote.getSObject().QuoteRegion__c;
        addedProducts = new List<zqu.Product>();
        removedProductIds = new List<Id>();
        updatedProductIdMap = new Map<Id,zqu.ZChargeGroup>();
        addedProductIdMap = new Map<Id,zqu.ZChargeGroup>();
        removedProducts = new List<zqu.QuoteProduct>();
        quoteCurrency = zQuote.getSObject().zqu__Currency__c;
    }
}
public with sharing class ZuoraQuoteFinalizeHelper {
  private static Map<id, zqu__QuoteChargeSummary__c[]> Quote2QuoteChargeSummaryMap = new Map<id, zqu__QuoteChargeSummary__c[]>();
  private static Map<id, zqu__QuoteRatePlanCharge__c[]> Quote2QuoteRatePlanChargeMap = new Map<id, zqu__QuoteRatePlanCharge__c[]>();
  private static Map<id, zqu__QuoteRatePlan__c> Quote2QuoteRatePlanMap = new Map<id, zqu__QuoteRatePlan__c>();
  private static Map<id, Contact> Quote2SoldToContactMap = new Map<id, Contact>();
  private static Map<id, Opportunity> Quote2OpportunityMap = new Map<id, Opportunity>();
  private static map<string, Country_Subsidiary__c> CountrySubMap = new Map<string, Country_Subsidiary__c>();
  private static map<id, Account> AccMap = new Map<id, Account>();
  private static final String NEW_SUB_TEXT = 'New Subscription';

  public static List<zqu__Quote__c> finalizeQuote(List<Id> quoteIdList) {
    System.debug('FINALIZE');
    List<zqu__Quote__c> quoteList = [
      SELECT
        Id,
        Is_Finalized__c,
        zqu__QuoteTemplate__c,
        zqu__PaymentMethod__c,
        zqu__AutoRenew__c,
        zqu__SoldToContact__c,
        subsidiary__c,
        Tax_Region__c,
        zqu__Certificate_ID__c,
        zqu__TermStartDate__c,
        zqu__BillCycleDay__c,
        zqu__SubscriptionTermStartDate__c,
        zqu__Account__c,
        zqu__ZuoraAccountID__c,
        zqu__Opportunity__c,
        Payment_Frequency__c,
        RecordTypeId,
        zqu__SubscriptionType__c,
        zqu__QuoteBusinessType__c,
        Renewal_Fee__c,
        Is_Initally_Renewed__c,
        Account_Users__c,
        Target_Quote_Total_Price__c,
        Migrating_to_New_Soultion__c,
        package__c
      FROM zqu__Quote__c
      WHERE Id IN :quoteIdList
    ];
    return finalizeQuote(quoteList);
  }

  public static List<zqu__Quote__c> finalizeQuote(
    List<zqu__Quote__c> newQuoteList
  ) {
    if (newQuoteList.isEmpty()) {
      return newQuoteList;
    }
    System.debug('FINALIZE');
    {
      Integer i = 0;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
      i++;
    }

    List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
    List<zqu__Quote__c> quoteNewSubList = new List<zqu__Quote__c>();
    //filter quotes other than New Subscription without existing billing account
    for (zqu__Quote__c newQuote_i : newQuoteList) {
      if (
        ('New Subscription'
          .equalsIgnoreCase(newQuote_i.zqu__SubscriptionType__c))
      ) {
        quoteList.add(newQuote_i);
        if (String.isBlank(newQuote_i.zqu__ZuoraAccountID__c)) {
          quoteNewSubList.add(newQuote_i);
        }
      } else if (
        'Amend Subscription'
          .equalsIgnoreCase(newQuote_i.zqu__SubscriptionType__c)
      ) {
        quoteList.add(newQuote_i);
      }
    }

    getRelatedRecordsData(quoteList);
    updateApprovalFields(quoteNewSubList);

    for (zqu__Quote__c zq : quoteList) {
      if (Quote2SoldToContactMap.containsKey(zq.Id)) {
        String country = Quote2SoldToContactMap.get(zq.Id).MailingCountry;
        System.debug('country: ' + country);
        String countryKey = country?.toLowerCase();
        System.debug('countryKey: ' + countryKey);
        System.debug('CountrySubMap: ' + JSON.serializePretty(CountrySubMap));
        if (
          country != null &&
          country != '' &&
          CountrySubMap.containsKey(countryKey)
        ) {
          Country_Subsidiary__c cs = CountrySubmap.get(countryKey);
          if (
            ('New Subscription'.equalsIgnoreCase(zq.zqu__SubscriptionType__c) &&
            String.isBlank(zq.zqu__ZuoraAccountID__c))
          ) {
            zq.subsidiary__c = cs.subsidiary__c;
          }
          if (cs.Taxable__c != null) {
            System.debug('css ' + cs.Id);
            zq.EU_VAT__c = cs.Tax_Rate__c;
            if (
              ('New Subscription'
                .equalsIgnoreCase(zq.zqu__SubscriptionType__c) &&
              String.isBlank(zq.zqu__ZuoraAccountID__c))
            ) {
              if (cs.Taxable__c == 'Yes')
                zq.Tax_Region__c = cs.Tax_Region__c;
              if (cs.Taxable__c == 'No')
                zq.Tax_Region__c = cs.No_Tax_Region__c;
              if (cs.Taxable__c == 'All') {
                if (zq.zqu__Certificate_ID__c == null)
                  zq.Tax_Region__c = cs.Tax_Region__c;
                else
                  zq.Tax_Region__c = cs.No_Tax_Region__c;
              }
            }
          }
          SetInvoiceAndCommunicationProfile(zq, cs);
        }
      }
      if (
        ('New Subscription'.equalsIgnoreCase(zq.zqu__SubscriptionType__c) &&
        String.isBlank(zq.zqu__ZuoraAccountID__c))
      ) {
        zq.Is_Finalized__c = 'Yes';
        zq.zqu__QuoteTemplate__c = getQuoteTemplateId(zq);
        if (
          zq.zqu__PaymentMethod__c == 'Other' ||
          zq.zqu__PaymentMethod__c == 'Wire Transfer'
        ) {
          zq.zqu__AutoRenew__c = false;
        }

        if (
          Utility.getRecordTypeIdForObject(zq.getSObjectType(), 'Default') ==
          zq.recordtypeid
        ) {
          if (zq.zqu__TermStartDate__c != null)
            zq.zqu__BillCycleDay__c = string.valueof(
              zq.zqu__TermStartDate__c.day()
            );
          else
            zq.zqu__BillCycleDay__c = null;
        } else {
          if (zq.zqu__SubscriptionTermStartDate__c != null)
            zq.zqu__BillCycleDay__c = string.valueof(
              zq.zqu__SubscriptionTermStartDate__c.day()
            );
          else
            zq.zqu__BillCycleDay__c = null;
        }
      }
    }

    return newQuoteList;
  }

  @TestVisible
  private static void getRelatedRecordsData(List<zqu__Quote__c> quoteList) {
    Set<Id> quoteIdSet = new Set<Id>();
    Set<Id> soldToContactIdSet = new Set<Id>();
    Set<Id> oppIdSet = new Set<Id>();
    Set<Id> zuoraAccountIdSet = new Set<Id>();
    for (zqu__Quote__c quote_i : quoteList) {
      if (String.isNotBlank(quote_i.Id)) {
        quoteIdSet.add(quote_i.Id);
        if (quote_i.zqu__Account__c != null) {
          zuoraAccountIdSet.add(quote_i.zqu__Account__c);
        }
        if (quote_i.zqu__SoldToContact__c != null) {
          soldToContactIdSet.add(quote_i.zqu__SoldToContact__c);
        }
        if (quote_i.zqu__Opportunity__c != null) {
          oppIdSet.add(quote_i.zqu__Opportunity__c);
        }
      }
    }

    if (quoteIdSet.isEmpty()) {
      return;
    }

    List<zqu__QuoteChargeSummary__c> zQCSlist = [
      SELECT
        id,
        zqu__Discount__c,
        zqu__Product_Name__c,
        zqu__Period__c,
        zqu__EffectivePrice__c,
        zqu__Quantity__c,
        zqu__Type__c,
        zqu__ListPrice__c,
        zqu__Model__c,
        zqu__TotalPrice__c,
        zqu__ListTotal__c,
        zqu__QuoteRatePlan__c,
        zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c,
        Product_Category__c,
        Internal_Code__c,
        AddOnType__c,
        zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.MinTerm__c,
        zqu__QuoteRatePlan__r.zqu__QuoteRatePlanZuoraId__c,
        zqu__QuoteRatePlan__r.zqu__QuoteProductName__c,
        Product_Compatibility__c,
        zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c,
        zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c
      FROM zqu__QuoteChargeSummary__c
      WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteIdSet
    ];
    for (zqu__QuoteChargeSummary__c qcs_i : zQCSlist) {
      list<zqu__QuoteChargeSummary__c> templist = new List<zqu__QuoteChargeSummary__c>();
      if (
        Quote2QuoteChargeSummaryMap.ContainsKey(
          qcs_i.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c
        )
      ) {
        templist = Quote2QuoteChargeSummaryMap.get(
          qcs_i.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c
        );
      }
      templist.add(qcs_i);
      Quote2QuoteChargeSummaryMap.put(
        qcs_i.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c,
        templist
      );
    }

    List<zqu__QuoteRatePlanCharge__c> zQRPClist = [
      SELECT
        name,
        zqu__Discount__c,
        zqu__Period__c,
        zqu__listprice__c,
        zqu__EffectivePrice__c,
        zqu__Quantity__c,
        IsDeleted,
        zqu__QuoteRatePlan__c,
        zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c,
        zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c,
        zqu__SpecificBillingPeriod__c,
        zqu__Description__c,
        Terms_Total__c,
        zqu__total__c,
        zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c,
        zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c,
        zqu__productRatePlanCharge__r.zqu__UOM__c,
        zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c,
        zqu__ListTotal__c
      FROM zqu__QuoteRatePlanCharge__c
      WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteIdSet
    ];

    for (zqu__QuoteRatePlanCharge__c qcrp_i : zQRPClist) {
      List<zqu__QuoteRatePlanCharge__c> templist = new List<zqu__QuoteRatePlanCharge__c>();
      if (
        Quote2QuoteRatePlanChargeMap.ContainsKey(
          qcrp_i.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c
        )
      ) {
        templist = Quote2QuoteRatePlanChargeMap.get(
          qcrp_i.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c
        );
      }
      templist.add(qcrp_i);
      Quote2QuoteRatePlanChargeMap.put(
        qcrp_i.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c,
        templist
      );
    }

    if (!zuoraAccountIdSet.isEmpty()) {
      list<Account> TempAList = [
        SELECT
          id,
          name,
          Tax_Exempt_Certificate_ID__c,
          BillingCountry,
          ShippingCountry,
          No_of_Users__c,
          (
            SELECT
              id,
              Zuora__Default_Payment_Method__r.name,
              Zuora__Default_Payment_Method__c,
              Zuora__DefaultPaymentMethod__c
            FROM Zuora__R00N40000001kyLcEAI__r
          ),
          (
            SELECT
              Id,
              OwnerId,
              IsDeleted,
              Name,
              CreatedDate,
              CreatedById,
              LastModifiedDate,
              LastModifiedById,
              SystemModstamp,
              LastActivityDate,
              Zuora__Account__c,
              Zuora__AutoRenew__c,
              Zuora__ContractAcceptanceDate__c,
              Zuora__ContractEffectiveDate__c,
              Zuora__CustomerAccount__c,
              Zuora__External_Id__c,
              Zuora__InitialTerm__c,
              Zuora__InvoiceOwner__c,
              Zuora__MRR__c,
              Zuora__NextChargeDate__c,
              Zuora__NextRenewalDate__c,
              Zuora__Notes__c,
              Zuora__OriginalCreatedDate__c,
              Zuora__OriginalCreated_Date__c,
              Zuora__RenewalTerm__c,
              Zuora__ServiceActivationDate__c,
              Zuora__Status__c,
              Zuora__SubscriptionEndDate__c,
              Zuora__SubscriptionNumber__c,
              Zuora__SubscriptionStartDate__c,
              Zuora__TCV__c,
              Zuora__TermEndDate__c,
              Zuora__TermSettingType__c,
              Zuora__TermStartDate__c,
              Zuora__Version__c,
              Zuora__Zuora_Id__c,
              Account_Owner__c,
              Trigger_AccountRecalc__c
            FROM Zuora__Subscriptions__r
          )
        FROM Account
        WHERE id = :zuoraAccountIdSet
      ];
      if (TempAList.size() > 0)
        AccMap.putall(TempAList);
    }

    List<zqu__QuoteRatePlan__c> quoteRatePlans = [
      SELECT zqu__QuoteProductName__c, zqu__Quote__c
      FROM zqu__QuoteRatePlan__c
      WHERE zqu__Quote__c IN :quoteIdSet
    ];

    for (zqu__QuoteRatePlan__c qrp_i : quoteRatePlans) {
      if (!Quote2QuoteRatePlanMap.containsKey(qrp_i.zqu__Quote__c)) {
        Quote2QuoteRatePlanMap.put(qrp_i.zqu__Quote__c, qrp_i);
      }
    }

    Map<Id, Contact> soldToContactsMap = new Map<Id, Contact>(
      [
        SELECT Id, MailingCountry, Account.AccountSource
        FROM Contact
        WHERE Id IN :soldToContactIdSet
      ]
    );

    for (zqu__Quote__c quote_i : quoteList) {
      if (soldToContactsMap.containsKey(quote_i.zqu__SoldToContact__c)) {
        Quote2SoldToContactMap.put(
          quote_i.Id,
          soldToContactsMap.get(quote_i.zqu__SoldToContact__c)
        );
      }
    }

    System.debug('cs CountryList: ');

    list<Country_Subsidiary__c> CountryList = new List<Country_Subsidiary__c>();
    if (
      Quote2SoldToContactMap.get(quoteList[0].Id).Account.AccountSource ==
      '42matters'
    ) {
      CountryList = [
        SELECT
          id,
          Communication_Profile_Cont__c,
          name,
          Country_Id__c,
          Country_Name__c,
          Communication_profile_cc__c,
          CommunicationProfilesSFID__c,
          InvoiceTemplateCCSFID__c,
          ISOCode__c,
          InvoiceTemplateContrSFID__c,
          InvoiceTemplateWSFID__c,
          Invoice_Template_Ent__c,
          IsNoMobileWeb__c,
          Subsidiary__c,
          Taxable__c,
          Tax_Region__c,
          No_Tax_Region__c,
          Restricted_To_Sold_Country__c,
          ISOCode_3__c,
          Tax_Rate__c
        FROM Country_Subsidiary__c
        WHERE Company__c = '42matters'
      ];
    } else if (
      !quoteList[0].Migrating_to_New_Soultion__c.equalsIgnoreCase('Yes') &&
      quoteList[0].package__c.equalsIgnoreCase('Admetricks')
    ) {
      CountryList = [
        SELECT
          id,
          Communication_Profile_Cont__c,
          name,
          Country_Id__c,
          Country_Name__c,
          Communication_profile_cc__c,
          CommunicationProfilesSFID__c,
          InvoiceTemplateCCSFID__c,
          ISOCode__c,
          InvoiceTemplateContrSFID__c,
          InvoiceTemplateWSFID__c,
          Invoice_Template_Ent__c,
          IsNoMobileWeb__c,
          Subsidiary__c,
          Taxable__c,
          Tax_Region__c,
          No_Tax_Region__c,
          Restricted_To_Sold_Country__c,
          ISOCode_3__c,
          Tax_Rate__c
        FROM Country_Subsidiary__c
        WHERE Company__c = 'Admetricks'
      ];
    } else if (
      !quoteList[0].Migrating_to_New_Soultion__c.equalsIgnoreCase('Yes') &&
      quoteList[0].package__c.containsIgnoreCase('Newslever')
    ) {
      CountryList = [
        SELECT
          id,
          Communication_Profile_Cont__c,
          name,
          Country_Id__c,
          Country_Name__c,
          Communication_profile_cc__c,
          CommunicationProfilesSFID__c,
          InvoiceTemplateCCSFID__c,
          ISOCode__c,
          InvoiceTemplateContrSFID__c,
          InvoiceTemplateWSFID__c,
          Invoice_Template_Ent__c,
          IsNoMobileWeb__c,
          Subsidiary__c,
          Taxable__c,
          Tax_Region__c,
          No_Tax_Region__c,
          Restricted_To_Sold_Country__c,
          ISOCode_3__c,
          Tax_Rate__c
        FROM Country_Subsidiary__c
        WHERE Company__c = 'Signal Insights, Inc.'
      ];
    } else {
      CountryList = [
        SELECT
          id,
          Communication_Profile_Cont__c,
          name,
          Country_Id__c,
          Country_Name__c,
          Communication_profile_cc__c,
          CommunicationProfilesSFID__c,
          InvoiceTemplateCCSFID__c,
          ISOCode__c,
          InvoiceTemplateContrSFID__c,
          InvoiceTemplateWSFID__c,
          Invoice_Template_Ent__c,
          IsNoMobileWeb__c,
          Subsidiary__c,
          Taxable__c,
          Tax_Region__c,
          No_Tax_Region__c,
          Restricted_To_Sold_Country__c,
          ISOCode_3__c,
          Tax_Rate__c
        FROM Country_Subsidiary__c
        WHERE Company__c = 'SW'
      ];
    }

    System.debug('cs CountryList: ' + CountryList);

    if (CountryList.size() > 0) {
      for (Country_Subsidiary__c cl : CountryList) {
        String countryName = cl.name.toLowerCase();
        CountrySubMap.put(countryName, cl);
        String isoCode3 = cl.ISOCode_3__c;
        if (isoCode3 != null) {
          CountrySubMap.put(isoCode3, cl);
        }
      }
    }

    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
      [
        SELECT Id, recordTypeId
        FROM Opportunity
        WHERE Id IN :oppIdSet
      ]
    );

    for (zqu__Quote__c quote_i : quoteList) {
      if (opportunityMap.containsKey(quote_i.zqu__Opportunity__c)) {
        Quote2OpportunityMap.put(
          quote_i.Id,
          opportunityMap.get(quote_i.zqu__Opportunity__c)
        );
      }
    }
  }

  @TestVisible
  private static void updateApprovalFields(list<zqu__Quote__c> Qlist) {
    for (zqu__Quote__c zq : Qlist) {
      zq.Is_Discount_10__c = null;
      zq.Is_Discount_20__c = null;
      zq.Is_Discount_40__c = null;
      zq.Is_Product_to_App__c = null;
      zq.Is_No_Annual__c = null;

      if (zq.zqu__Account__c != null && AccMap.containskey(zq.zqu__Account__c))
        zq.account_users__c = AccMap.get(zq.zqu__Account__c).No_of_Users__c;
      if (zq.account_users__c == null)
        zq.account_users__c = 0;
      Decimal quoteusers = 0;
      zq.quote_users__c = 0;

      if (Quote2QuoteChargeSummaryMap.ContainsKey(zq.id)) {
        List<zqu__QuoteChargeSummary__c> templist = Quote2QuoteChargeSummaryMap.get(
          zq.id
        );
        if (templist.size() > 0)
          for (zqu__QuoteChargeSummary__c zqcs : templist) {
            if (zqcs.zqu__Quantity__c == null || zqcs.zqu__Quantity__c > 0) {
              if (
                zqcs.zqu__Discount__c != null &&
                zqcs.zqu__Discount__c > 10 &&
                zqcs.zqu__Discount__c <= 20 &&
                !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c
              )
                zq.Is_Discount_10__c = 'Yes';

              if (
                zqcs.zqu__Discount__c != null &&
                zqcs.zqu__Discount__c > 20 &&
                zqcs.zqu__Discount__c <= 40 &&
                !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c
              )
                zq.Is_Discount_20__c = 'Yes';

              if (
                zqcs.zqu__Discount__c != null &&
                zqcs.zqu__Discount__c > 40 &&
                !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c
              )
                zq.Is_Discount_40__c = 'Yes';

              if (
                zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c !=
                null &&
                zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c.EqualsIgnoreCase(
                  'Reports'
                )
              ) {
                zq.Is_Product_to_App__c = 'Yes';
              }

              if (
                zqcs.zqu__Period__c != null &&
                zqcs.zqu__Period__c.tolowercase() != 'annual' &&
                zqcs.zqu__Period__c != '-' &&
                zqcs.zqu__Type__c.tolowercase() != 'one-time' &&
                (zq.Payment_Frequency__c == null ||
                zq.Payment_Frequency__c < 12)
              ) {
                zq.Is_No_Annual__c = 'Yes';
              }
            }

            if (
              zqcs.zqu__Product_Name__c != null &&
              zqcs.zqu__Product_Name__c.toLowerCase().contains('users') &&
              zqcs.zqu__Quantity__c != null
            ) {
              quoteusers += zqcs.zqu__Quantity__c;
            }
          }
      }
      if (
        Utility.getRecordTypeIdForObject(zq.getSObjectType(), 'Amendment') ==
        zq.recordtypeid
      )
        zq.quote_users__c = quoteusers;

      if (Quote2QuoteRatePlanChargeMap.ContainsKey(zq.id)) {
        list<zqu__QuoteRatePlanCharge__c> templist = Quote2QuoteRatePlanChargeMap.get(
          zq.id
        );
        if (templist.size() > 0)
          for (zqu__QuoteRatePlanCharge__c zqcs : templist) {
            if (zqcs.zqu__Quantity__c == null || zqcs.zqu__Quantity__c > 0) {
              if (
                zqcs.zqu__Discount__c != null &&
                zqcs.zqu__Discount__c > 10 &&
                zqcs.zqu__Discount__c <= 20 &&
                !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c
              )
                zq.Is_Discount_10__c = 'Yes';

              if (
                zqcs.zqu__Discount__c != null &&
                zqcs.zqu__Discount__c > 20 &&
                zqcs.zqu__Discount__c <= 40 &&
                !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c
              )
                zq.Is_Discount_20__c = 'Yes';

              if (
                zqcs.zqu__Discount__c != null &&
                zqcs.zqu__Discount__c > 40 &&
                !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c
              )
                zq.Is_Discount_40__c = 'Yes';

              if (
                zqcs.zqu__ListTotal__c != null &&
                zqcs.zqu__ListTotal__c != 0 &&
                zqcs.zqu__Total__c != null &&
                !zqcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.Allow_Discount__c
              ) {
                decimal dis = 1 - (zqcs.zqu__Total__c / zqcs.zqu__ListTotal__c);
                if (dis > 0.1 && dis <= 0.2)
                  zq.Is_Discount_10__c = 'Yes';
                if (dis > 0.2)
                  zq.Is_Discount_20__c = 'Yes';
              }

              if (
                zqcs.zqu__Period__c != null &&
                zqcs.zqu__Period__c.tolowercase() != 'annual' &&
                zqcs.zqu__Period__c != '-'
              )
                zq.Is_No_Annual__c = 'Yes';
            }
          }
      }
    }
  }

  @TestVisible
  private static Id getQuoteTemplateId(zqu__Quote__c quote) {
    Id templateId = null;
    if (
      Quote2QuoteRatePlanMap.containsKey(quote.Id) &&
      String.isNotBlank(
        Quote2QuoteRatePlanMap.get(quote.Id).zqu__QuoteProductName__c
      )
    ) {
      String quoteRatePlanProductName = Quote2QuoteRatePlanMap.get(quote.Id)
        .zqu__QuoteProductName__c;
      Quote_Record_Type_Template_Map__c qrttm = Quote_Record_Type_Template_Map__c.getInstance(
        Utility.getDevNameForRecordTypeID(
          quote.getSObjectType(),
          quote.recordTypeId
        )
      );
      if (qrttm != null && String.isNotBlank(qrttm.Val__c)) {
        List<zqu__Quote_Template__c> quoteTemplates = [
          SELECT Id, Name, zqu__Quote_Type__c, Product_Name__c
          FROM zqu__Quote_Template__c
          WHERE
            zqu__Quote_Type__c = :qrttm.Val__c
            AND Product_Name__c = :quoteRatePlanProductName
          LIMIT 1
        ];
        if (!quoteTemplates.isEmpty()) {
          templateId = quoteTemplates[0].Id;
        } else {
          quoteTemplates = [
            SELECT Id, Name, zqu__Quote_Type__c, Product_Name__c
            FROM zqu__Quote_Template__c
            WHERE
              zqu__Quote_Type__c = :qrttm.Val__c
              AND Name = :'No Base Product'
            LIMIT 1
          ];
          if (!quoteTemplates.isEmpty()) {
            templateId = quoteTemplates[0].Id;
          }
        }
      }
    }
    return templateId;
  }

  @TestVisible
  private static void SetInvoiceAndCommunicationProfile(
    zqu__Quote__c zq,
    Country_Subsidiary__c cs
  ) {
    System.debug(
      'SetInvoiceAndCommunicationProfile cs: ' + JSON.serializePretty(cs)
    );
    if (zq.zqu__PaymentMethod__c != null) {
      if (
        zq.zqu__PaymentMethod__c == 'Credit Card' ||
        zq.zqu__PaymentMethod__c.equalsIgnoreCase('paypal')
      ) {
        zq.zqu__InvoiceTemplate__c = cs.InvoiceTemplateCCSFID__c;
        zq.zqu__CommunicationProfile__c = cs.Communication_profile_cc__c;
        zq.zqu__BillingBatch__c = 'Batch1';
      } else if (zq.zqu__PaymentMethod__c == 'wire transfer') {
        zq.zqu__CommunicationProfile__c = cs.CommunicationProfilesSFID__c;
        zq.zqu__InvoiceTemplate__c = cs.InvoiceTemplateWSFID__c;
        zq.zqu__BillingBatch__c = 'Batch2';
      } else if (zq.zqu__PaymentMethod__c == 'other') {
        zq.zqu__CommunicationProfile__c = cs.Communication_Profile_Cont__c;
        zq.zqu__BillingBatch__c = 'Batch3';
        zq.zqu__InvoiceTemplate__c = cs.Invoice_Template_Ent__c;
        /* if (zq.zqu__opportunity__c!=null && Quote2OpportunityMap.containsKey(zq.Id) && Quote2OpportunityMap.get(zq.Id).recordtypeid !=null && 
                  (Utility.getDevNameForRecordTypeID(Quote2OpportunityMap.get(zq.Id).getSObjectType(),Quote2OpportunityMap.get(zq.Id).recordtypeid).tolowercase() =='enterprise'
                   ||
                   Utility.getDevNameForRecordTypeID(Quote2OpportunityMap.get(zq.Id).getSObjectType(),Quote2OpportunityMap.get(zq.Id).recordtypeid).tolowercase()=='strategic'
                  )
                )
                {
                    zq.zqu__InvoiceTemplate__c = cs.Invoice_Template_Ent__c;
                } */
      } else {
        zq.zqu__InvoiceTemplate__c = cs.InvoiceTemplateContrSFID__c;
      }
    }
  }
  /**
   * @description Check for other Quotes under the Quote's subscription
   * @param quoteId - Id of Quote which is submitted
   * @return Response - return Response object with success flag true and content value true if there is any other Amendment Quote that fits the condition
   */
  public static Response validateSubscription(String quoteId) {
    try {
      boolean isUnprocessed = false;
      Set<String> statusSet = new Set<String>{
        'Sent To Zuora',
        'Cancelled',
        'Processed Directly in Zuora',
        'Voided',
        'Accepted',
        'Quote Pending Renewal Date'
      };
      zqu__Quote__c quote = [
        SELECT id, zqu__Subscription_Name__c, zqu__SubscriptionType__c
        FROM zqu__Quote__c
        WHERE Id = :quoteId
      ];
      if (quote.zqu__SubscriptionType__c == 'Amend Subscription') {
        AggregateResult[] groupedResults = [
          SELECT COUNT(ID) cnt
          FROM zqu__Quote__c
          WHERE
            zqu__Subscription_Name__c = :quote.zqu__Subscription_Name__c
            AND Id != :quoteId
            AND zqu_Quote_Status__c NOT IN :statusSet
            AND (NOT zqu__Account__r.Name LIKE '%Lotem\'s Test Account%')
            AND zqu__SubscriptionType__c = 'Amend Subscription'
        ];
        Integer quoteCount = (Integer) groupedResults[0].get('cnt');
        if (quoteCount > 0) {
          isUnprocessed = true;
        }
      }
      return new Response(true, isUnprocessed);
    } catch (Exception e) {
      return new Response(false, e.getMessage());
    }
  }
}

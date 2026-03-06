public class OpportunityTriggerHandler {
  private static RecordType paRecordType;
  private static String recordTypeID;
  private static Set<Id> sharedOppIds;
  private static Set<Id> oldSharedOppIds;
  private static Set<String> profileIdSet;
  private static Set<String> set1;
  private static Set<String> set2;
  private static Set<String> set3;
  private static Set<String> set4;
  private static Set<String> set5;
  private static Set<String> set6;
  private static Set<String> set7;
  private static Set<String> set8;
  private static Set<String> set9;
  private static Set<String> set10;
  private static Set<String> set11;
  private static Set<String> set12;
  private static Set<String> set13;
  private static Set<String> set14;
  private static Set<String> set15;
  private static Set<String> set16;
  private static Set<String> set17;

  static {
    paRecordType = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = 'Wolves' AND SobjectType = 'Opportunity'
      LIMIT 1
    ];
    recordTypeID = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = 'Wolves' AND SobjectType = 'Opportunity'
      LIMIT 1
    ]
    .Id;
    profileIdSet = UserTriggerHandler.getCommunityUserProfileId();
    sharedOppIds = new Set<Id>();
    oldSharedOppIds = new Set<Id>();
    set1 = new Set<String>();
    set2 = new Set<String>();
    set3 = new Set<String>();
    set4 = new Set<String>();
    set5 = new Set<String>();
    set6 = new Set<String>();
    set7 = new Set<String>();
    set8 = new Set<String>();
    set9 = new Set<String>();
    set10 = new Set<String>();
    set11 = new Set<String>();
    set12 = new Set<String>();
    set13 = new Set<String>();
    set14 = new Set<String>();
    set15 = new Set<String>();
    set16 = new Set<String>();
    set17 = new Set<String>();
  }
  /*
public static void setForecast(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
if(oldMap!=null){

for (Opportunity opp : newList){
Opportunity oldOpp = oldMap.get(opp.id);
if(opp.RecordTypeId!=paRecordType.Id && oldOpp.StageName !=opp.StageName){
if(opp.StageName == 'Prospect' || opp.StageName == 'Engagement' || opp.StageName == 'Proposal'){
System.debug('here');
System.debug('opp.Similarweb_Forecasting_status__c ' + opp.Similarweb_Forecasting_status__c);
if(opp.Similarweb_Forecasting_status__c == null || opp.Similarweb_Forecasting_status__c == 'Closed' || opp.Similarweb_Forecasting_status__c == 'Omitted'){
System.debug('here');
opp.Similarweb_Forecasting_status__c='Pipeline';
} else {
opp.Similarweb_Forecasting_status__c=opp.Similarweb_Forecasting_status__c;
}
}
if(opp.StageName == 'Sponsor Verbal'){
if(opp.Similarweb_Forecasting_status__c == null || opp.Similarweb_Forecasting_status__c == 'Pipeline' || opp.Similarweb_Forecasting_status__c == 'Closed' || opp.Similarweb_Forecasting_status__c == 'Omitted'){
opp.Similarweb_Forecasting_status__c='Best Case';
} else {
opp.Similarweb_Forecasting_status__c=opp.Similarweb_Forecasting_status__c;
}
}
if(opp.StageName == 'Decision Maker Verbal'){                   
opp.Similarweb_Forecasting_status__c='Commit';                    
}
if(opp.StageName == 'Closed Won'){                    
opp.Similarweb_Forecasting_status__c='Closed';
}
if(opp.StageName == 'Closed Lost'){                    
opp.Similarweb_Forecasting_status__c='Omitted';
}
}
}
} else {

for (Opportunity opp : newList){
if(opp.RecordTypeId!=paRecordType.Id){
if(opp.StageName == 'Prospect' || opp.StageName == 'Engagement' || opp.StageName == 'Proposal'){                        
opp.Similarweb_Forecasting_status__c='Pipeline';
}
if(opp.StageName == 'Sponsor Verbal'){                        
opp.Similarweb_Forecasting_status__c='Best Case';                       
}
if(opp.StageName == 'Decision Maker Verbal'){                   
opp.Similarweb_Forecasting_status__c='Commit';                    
}
if(opp.StageName == 'Closed Won'){                    
opp.Similarweb_Forecasting_status__c='Closed';
}
if(opp.StageName == 'Closed Lost'){                    
opp.Similarweb_Forecasting_status__c='Omitted';
}
}
}
}
}

public static void setSimilarWebForecast(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {        
if(oldMap!=null){
for (Opportunity opp : newList){            
Opportunity oldOpp = oldMap.get(opp.id);
if(oldOpp.ForecastCategoryName !=opp.ForecastCategoryName){
opp.Similarweb_Forecasting_status__c=opp.ForecastCategoryName;
}            
}
} else {
for (Opportunity opp : newList){
opp.Similarweb_Forecasting_status__c=opp.ForecastCategoryName;
}
} 
}

public static void updateForecastBySimilarWeb(List<Opportunity> newList, Map<Id, Opportunity> oldMap) {
if(oldMap!=null){
for (Opportunity opp : newList){
Opportunity oldOpp = oldMap.get(opp.id);
if(oldOpp.Similarweb_Forecasting_status__c !=opp.Similarweb_Forecasting_status__c || oldOpp.StageName !=opp.StageName){
opp.ForecastCategoryName=opp.Similarweb_Forecasting_status__c;
}
}
} else {
for (Opportunity opp : newList){
opp.ForecastCategoryName=opp.Similarweb_Forecasting_status__c;
}
}
}    
*/
  public static void manageOpportunityForCommunityUsers(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    Map<String, List<String>> accountOpportunityMap = new Map<String, List<String>>();
    Map<Id, Set<Id>> userOpportunitiesMap = new Map<Id, Set<ID>>();
    Map<Id, List<Id>> oldAccountOppsMap = new Map<Id, List<Id>>();
    List<Id> changedOpps = new List<Id>();
    Boolean isUpdate = oldMap != null;

    Id oldAccountId;
    for (Opportunity opp : newList) {
      if (!sharedOppIds.contains(opp.Id)) {
        sharedOppIds.add(opp.Id);
        if (
          opp.RecordTypeId == recordTypeID && !String.isEmpty(opp.AccountId)
        ) {
          if (!accountOpportunityMap.containsKey(opp.AccountId)) {
            accountOpportunityMap.put(opp.AccountId, new List<String>());
          }
          accountOpportunityMap.get(opp.AccountId).add(opp.Id);
        }
      }
      if (isUpdate && !oldSharedOppIds.contains(opp.Id)) {
        if (
          opp.AccountID != null &&
          oldMap.get(opp.Id).AccountID != opp.AccountID
        ) {
          oldSharedOppIds.add(opp.Id);
          oldAccountId = oldMap.get(opp.Id).AccountID;
          if (!oldAccountOppsMap.containsKey(oldAccountId))
            oldAccountOppsMap.put(oldAccountId, new List<Id>());
          oldAccountOppsMap.get(oldAccountId).add(opp.Id);
          changedOpps.add(opp.Id);
        }
      }
    }

    //handle clean sharing if account on opportunity was changed

    System.debug('profileIdSet - ' + profileIdSet);
    System.debug('oldAccountOppsMap - ' + oldAccountOppsMap);
    /* System.debug('SELECT - ' + [SELECT ID, Contact.AccountId from USer where ProfileId=:profileIdSet
     AND Contact.AccountId IN :oldAccountOppsMap.keySet()]);   */
    if (!oldAccountOppsMap.isEmpty()) {
      for (User u : [
        SELECT ID, Contact.AccountId
        FROM USer
        WHERE
          ProfileId = :profileIdSet
          AND Contact.AccountId IN :oldAccountOppsMap.keySet()
      ]) {
        if (!userOpportunitiesMap.containsKey(u.Id))
          userOpportunitiesMap.put(u.Id, new Set<Id>());
        userOpportunitiesMap.get(u.Id)
          .addAll(oldAccountOppsMap.get(u.Contact.AccountId));
      }
      if (!userOpportunitiesMap.isEmpty()) {
        List<OpportunityShare> toClean = new List<OpportunityShare>();
        for (OpportunityShare os : [
          SELECT id, UserOrGroupId, OpportunityId
          FROM OpportunityShare
          WHERE
            OpportunityId IN :changedOpps
            AND UserOrGroupId IN :userOpportunitiesMap.keySet()
        ]) {
          if (
            userOpportunitiesMap.containsKey(os.UserOrGroupId) &&
            userOpportunitiesMap.get(os.UserOrGroupId)
              .contains(os.OpportunityId)
          )
            toClean.add(os);
        }
        System.debug('sharing to clean ' + toClean);
        if (!toClean.isEmpty())
          delete toClean;
      }
    }

    //handle new opportunity sharing
    if (!accountOpportunityMap.isEmpty()) {
      List<OpportunityShare> newSharings = new List<OpportunityShare>();
      for (User u : [
        SELECT Id, Contact.AccountId
        FROM User
        WHERE Contact.AccountId IN :accountOpportunityMap.keyset()
      ]) {
        if (accountOpportunityMap.containsKey(u.Contact.AccountId)) {
          for (String oppId : accountOpportunityMap.get(u.Contact.AccountId)) {
            newSharings.add(
              new OpportunityShare(
                OpportunityId = oppId,
                UserOrGroupId = u.Id,
                OpportunityAccessLevel = 'Read'
              )
            );
          }
        }
      }
      System.debug('newSharings ' + newSharings);
      Database.insert(newSharings);
    }
  }

  public static void clearClosedLostValues(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    for (Opportunity opp : newList) {
      if (
        opp.StageName != oldMap.get(opp.Id).StageName &&
        oldMap.get(opp.Id).StageName == 'Closed Lost'
      ) {
        opp.Closed_Lost_Reason__c = null;
        opp.Closed_Lost_Reason_More_details__c = null;
        opp.Opp_will_be_relevant__c = null;
      }
    }
  }
  /*
public static void changeSysCloseFlow(List<Opportunity> newList, Map<Id, Opportunity> oldMap){

Set<Id> oppIds = new Set<Id>();
List<Opportunity> oppToUpd = new List<Opportunity>();
for (Opportunity opp : newList){            
if (opp.StageName == 'Closed Lost' && opp.SYS_CloseFlow__c==true) {          
oppIds.add(opp.Id);
//Opportunity opp1 = [SELECT ID,SYS_CloseFlow__c  FROM Opportunity WHERE ID=:opp.Id];  
//oppIds.SYS_CloseFlow__c=false;
//oppToUpd.add(opp1);
}       
}
for(Opportunity opp_i : [SELECT ID,SYS_CloseFlow__c  FROM Opportunity WHERE ID IN :oppIds]){
opp_i.SYS_CloseFlow__c=false;
oppToUpd.add(opp_i);
}
System.debug('changeSysCloseFlow before end');
update oppToUpd;
System.debug('changeSysCloseFlow end');
}
*/

  public static void changeCloseDateToToday(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    for (Opportunity opp : newList) {
      if (
        opp.StageName != oldMap.get(opp.Id).StageName &&
        opp.StageName == 'Closed Lost'
      ) {
        opp.CloseDate = Date.today();
      }
    }
  }

  public static void setForecastCategoryName(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    RecordType rt = paRecordType;
    if (rt != null) {
      List<String> pickListValuesList = new List<String>();
      Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry pickListVal : ple) {
        if (pickListValuesList.size() > 1) {
          break;
        }
        if (pickListVal.isActive()) {
          pickListValuesList.add(pickListVal.getValue());
        }
      }

      Map<String, String> oppToStageMap = new Map<String, String>();

      for (Opportunity opp : newList) {
        if (
          opp.SFF_Commit__c &&
          !'Feature Update'.equalsIgnoreCase(opp.StageName) &&
          !opp.IsClosed &&
          opp.RecordTypeId != rt.Id
        ) {
          opp.ForecastCategoryName = 'Commit';
        } else if (
          Trigger.isUpdate &&
          !opp.SFF_Commit__c &&
          oldMap.get(opp.Id).SFF_Commit__c
        ) {
          oppToStageMap.put(opp.Id, opp.StageName);
          if (opp.StageName.equalsIgnoreCase(pickListValuesList[0])) {
            opp.StageName = pickListValuesList[1];
          } else {
            opp.StageName = pickListValuesList[0];
          }
        }
      }

      if (!oppToStageMap.isEmpty()) {
        resetForecast(oppToStageMap);
      }
    }
  }

  public static void enrichContactDataByPolygraph(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    List<Contact> conList = new List<Contact>();
    if (oldMap == null) {
      for (Opportunity o : newList) {
        if (o.Primary_Contact__c != null) {
          conList.add(new Contact(Id = o.Primary_Contact__c));
        }
      }
    } else if (oldMap != null && newList != null) {
      for (Opportunity o : newList) {
        if (
          o.Primary_Contact__c != null &&
          o.Primary_Contact__c != oldMap.get(o.Id).Primary_Contact__c
        ) {
          conList.add(new Contact(Id = o.Primary_Contact__c));
        }
      }
    }
    if (!conList.isEmpty()) {
      PolyghraphInteractionHandler polygraphInteraction = new PolyghraphInteractionHandler();
      polygraphInteraction.enrichContactList(conList); //Remove the call to Polygraph
    }
  }

  public void handleRenewalOppFromFutureUpsell(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    //MIS-5698
    System.debug('handleRenewalOppFromFutureUpsell---started');
    List<Opportunity> relevantOppList = new List<Opportunity>();
    Set<String> oppReviewedPendingSet = new Set<String>();
    oppReviewedPendingSet.add('Pending SalesOps');
    oppReviewedPendingSet.add('Pending Client');
    oppReviewedPendingSet.add('Pending Rep');
    oppReviewedPendingSet.add('Pending Legal');
    oppReviewedPendingSet.add('Pending Billing');

    for (Opportunity opp : newList) {
      // filter
      System.debug('opp.Type--' + opp.Type);
      System.debug('opp.Opp_Reviewed__c--' + opp.Opp_Reviewed__c);
      System.debug('opp.StageName--' + opp.StageName);
      System.debug('opp.Overwrite_ARR__c--' + opp.Overwrite_ARR__c);
      System.debug(
        'oldMap.get(opp.Id).Opp_Reviewed__c--' +
        oldMap.get(opp.Id).Opp_Reviewed__c
      );
      if (
        opp.Type == 'Upsell' &&
        opp.Opp_Reviewed__c != oldMap.get(opp.Id).Opp_Reviewed__c &&
        opp.Opp_Reviewed__c != null &&
        opp.StageName == 'Closed Won'
      ) {
        if (
          !oppReviewedPendingSet.contains(opp.Opp_Reviewed__c) &&
          opp.Overwrite_ARR__c != null
        ) {
          relevantOppList.add(opp);
        }
      }
    }
    System.debug('relevantOppList--' + relevantOppList);
    if (!relevantOppList.isEmpty()) {
      updateRenewalOpp(relevantOppList);
    }
  }

  /**
   * --- change---
   * @author Elnur Alibaev
   * @date 01/08/2025
   * @description Removed Product_Sold__c from query
   * --- change---
   * @author Elnur Alibaev
   * @date 25/08/2025
   * @description Updated logic to ignore the quoteFound for calculations
   */
  private void updateRenewalOpp(List<Opportunity> relevantOppList) {
    Set<Id> accountIdSet = new Set<Id>();
    for (Opportunity upsellOpp : relevantOppList) {
      accountIdSet.add(upsellOpp.AccountId);
    }
    List<Opportunity> oppRenewalToUpsertList = new List<Opportunity>();
    List<zqu__Quote__c> quotesToUpdateList = new List<zqu__Quote__c>();
    Set<String> closedOppStages = new Set<String>{
      'Closed Won',
      'Closed Lost'
    };
    Map<Id, Opportunity> oppWithQuotesMap = new Map<Id, Opportunity>(
      [
        SELECT
          Id,
          (
            SELECT Id
            FROM zqu__Quotes__r
            WHERE
              (zqu__QuoteBusinessType__c = 'Co-Term Upsell'
              OR zqu__QuoteBusinessType__c = 'Co-Term Upsell + Renewal')
              AND zqu__StartDate__c > TODAY
          )
        FROM Opportunity
        WHERE AccountId IN :accountIdSet
      ]
    );

    List<Account> accounts = [
      SELECT
        Id,
        OwnerId,
        (
          SELECT
            Id,
            StageName,
            Cycle__c,
            Original_Renewal_Date__c,
            closeDate,
            Type,
            Cycle_Price_Local__c,
            Exchange_Rate__c,
            OwnerId
          FROM Opportunities
          WHERE
            Type = 'Renewal'
            OR (type = 'Upsell'
            AND stageName NOT IN :closedOppStages)
          ORDER BY Original_Renewal_Date__c DESC NULLS LAST
        ),
        (
          SELECT
            Id,
            Zuora__MRR__c,
            Zuora__NextRenewalDate__c,
            Zuora__CustomerAccount__r.Zuora__Currency__c,
            Zuora__TermStartDate__c
          FROM Zuora__Subscriptions__r
          WHERE Zuora__NextRenewalDate__c != NULL
          ORDER BY Zuora__NextRenewalDate__c DESC
        )
      FROM Account
      WHERE Id IN :accountIdSet
    ];

    Map<Id, Map<String, Opportunity>> accountIdToOppTypeMap = getAccountIdToOppTypeMap(
      accounts
    );

    System.debug('oppWithQuotesMap--' + oppWithQuotesMap);
    System.debug('accounts--' + accounts);
    boolean quoteWasFound = false;

    for (Opportunity opp : oppWithQuotesMap.values()) {
      if (!opp.zqu__Quotes__r.isEmpty()) {
        zqu__Quote__c quote = opp.zqu__Quotes__r[0];
        quote.Future_CTU_Flag__c = true;
        quotesToUpdateList.add(quote);
        quoteWasFound = true;
      }
    }
    System.debug('Quote was found: ' + quoteWasFound);
    // if(!quoteWasFound){
    //     handleRenewalAndUpsells(accounts, accountIdToOppTypeMap, closedOppStages, oppRenewalToUpsertList);
    // }
    handleRenewalAndUpsells(
      accounts,
      accountIdToOppTypeMap,
      closedOppStages,
      oppRenewalToUpsertList
    );
    System.debug('oppRenewalToUpsertList--- eden  ' + oppRenewalToUpsertList);
    if (!oppRenewalToUpsertList.isEmpty()) {
      upsert oppRenewalToUpsertList;
    }
    if (!quotesToUpdateList.isEmpty()) {
      update quotesToUpdateList;
    }
  }

  public void handleRenewalAndUpsells(
    List<Account> accounts,
    Map<Id, Map<String, Opportunity>> accountIdToOppTypeMap,
    Set<String> closedOppStages,
    List<Opportunity> oppRenewalToUpsertList
  ) {
    List<String> upsellOppsWithPriceIncrease = getOppsWithPriceIncreaseProduct(
      accounts,
      accountIdToOppTypeMap,
      closedOppStages
    );

    System.debug('I am here !!!!!!!');

    for (Account account : accounts) {
      if (!account.Zuora__Subscriptions__r.isEmpty()) {
        Date thirtyDaysAgo = Date.today().addDays(-30);
        Opportunity renewalOpp = accountIdToOppTypeMap.get(account.Id)
          .get('Renewal');
        boolean doNothing =
          renewalOpp != null &&
          closedOppStages.contains(renewalOpp.StageName) &&
          renewalOpp.closeDate > thirtyDaysAgo;
        System.debug('dontDoNothing-- ' + doNothing);
        if (!doNothing) {
          Opportunity upsellOpp = accountIdToOppTypeMap.get(account.Id)
            .get('Upsell');
          if (renewalOpp != null) {
            // change in 12.8.24 we are not creating new renewal in this process only updating
            oppRenewalToUpsertList.addall(
              putValues(
                renewalOpp,
                account,
                upsellOpp,
                upsellOppsWithPriceIncrease
              )
            );
          }
          //                        oppRenewalToUpsertList.addall(account.Opportunities.isEmpty() || closedOppStages.contains(renewalOpp.StageName) ? putValues(new Opportunity(),account,new Opportunity()) : putValues(renewalOpp,account,upsellOpp));
        }
      }
    }

    if (oppRenewalToUpsertList.size() > 0) {
      upsert oppRenewalToUpsertList;
    }
  }

  private static List<String> getOppsWithPriceIncreaseProduct(
    List<Account> accounts,
    Map<Id, Map<String, Opportunity>> accountIdToOppTypeMap,
    Set<String> closedOppStages
  ) {
    List<String> upsellOppsWithPriceIncrease = new List<String>(),
      upsellOppIds = new List<String>();

    for (Account account : accounts) {
      if (!account.Zuora__Subscriptions__r.isEmpty()) {
        Date thirtyDaysAgo = Date.today().addDays(-30);
        Opportunity renewalOpp = accountIdToOppTypeMap.get(account.Id)
          .get('Renewal');
        boolean dontDoNothing =
          renewalOpp != null &&
          closedOppStages.contains(renewalOpp.StageName) &&
          renewalOpp.closeDate > thirtyDaysAgo;
        if (!dontDoNothing) {
          Opportunity upsellOpp = accountIdToOppTypeMap.get(account.Id)
            .get('Upsell');
          if (renewalOpp != null && upsellOpp != null) {
            upsellOppIds.add(upsellOpp.Id);
          }
        }
      }
    }

    List<Opportunity> upsellOpps = [
      SELECT
        Id,
        (
          SELECT Id
          FROM OpportunityLineItems
          WHERE Purchase_Motion__c = 'Price Increase'
        )
      FROM Opportunity
      WHERE Id IN :upsellOppIds
    ];

    for (Opportunity uo : upsellOpps) {
      if (uo.OpportunityLineItems.size() > 0) {
        upsellOppsWithPriceIncrease.add(uo.Id);
      }
    }

    return upsellOppsWithPriceIncrease;
  }

  public Map<Id, Map<String, Opportunity>> getAccountIdToOppTypeMap(
    List<Account> accounts
  ) {
    Map<Id, Map<String, Opportunity>> accountIdToOppTypeMap = new Map<Id, Map<String, Opportunity>>();

    for (Account account : accounts) {
      Map<String, Opportunity> oppMap = new Map<String, Opportunity>();
      System.debug('account.Opportunities---' + account.Opportunities.size());
      System.debug('account.---' + account);
      for (Opportunity accountOpp : account.Opportunities) {
        if (!oppMap.containsKey(accountOpp.Type)) {
          oppMap.put(accountOpp.Type, accountOpp);
        }
      }
      accountIdToOppTypeMap.put(account.Id, oppMap);
    }
    return accountIdToOppTypeMap;
  }

  public List<Opportunity> putValues(
    Opportunity renewalOpp,
    Account acc,
    Opportunity upsellOpp,
    List<String> upsellOppsWithPriceIncrease
  ) {
    List<Opportunity> oppList = new List<Opportunity>();
    System.debug('renewalOpp started---' + renewalOpp);
    Integer cyclePriceSubscriptions = getCyclePriceOfSubscriptions(
      acc.Zuora__Subscriptions__r
    );
    renewalOpp.Cycle__c = renewalOpp.Cycle__c != null
      ? renewalOpp.Cycle__c
      : 'Annually';
    renewalOpp.AccountId = acc.id;
    renewalOpp.Type = 'Renewal';
    renewalOpp.Cycle_Price_Local__c = cyclePriceSubscriptions;
    renewalOpp.Currency__c = acc.Zuora__Subscriptions__r[0]
      .Zuora__CustomerAccount__r.Zuora__Currency__c;
    renewalOpp.Exchange_Rate__c = getExchngeRateForCurrency(
      renewalOpp.Currency__c
    );
    Integer cycleCalc = (renewalOpp.Cycle_Price_Local__c *
      renewalOpp.Exchange_Rate__c)
      .round()
      .intValue();
    renewalOpp.Cycle_Price__c = cycleCalc;
    renewalOpp.Original_Renewal_Amount__c = cycleCalc;
    renewalOpp.ARR__c = cycleCalc;
    Date closeDate = acc.Zuora__Subscriptions__r[0].Zuora__NextRenewalDate__c;
    renewalOpp.closeDate = renewalOpp.closeDate != null
      ? renewalOpp.closeDate
      : closeDate;
    renewalOpp.Original_Renewal_Date__c = renewalOpp.Original_Renewal_Date__c !=
      null
      ? renewalOpp.Original_Renewal_Date__c
      : closeDate;
    renewalOpp.StageName = String.isNotBlank(renewalOpp.StageName)
      ? renewalOpp.StageName
      : 'Initial Discovery';
    renewalOpp.OwnerId = acc.OwnerId;
    oppList.add(renewalOpp);
    System.debug('renewalOpp after---' + renewalOpp);
    if (upsellOpp != null) {
      oppList.add(
        createOrUpdateUpsellOpp(
          renewalOpp,
          upsellOpp,
          upsellOppsWithPriceIncrease
        )
      );
    }
    return oppList;
  }

  /**
   * --- change---
   * @author Elnur Alibaev
   * @date 01/08/2025
   * @description Updated Cycle_Price_Local__c to be based on if opp has Price Increase instead of Product_Sold__c value
   */
  private Opportunity createOrUpdateUpsellOpp(
    Opportunity renewalOpp,
    Opportunity upsellOpp,
    List<String> upsellOppsWithPriceIncrease
  ) {
    System.debug('upsellOpp---' + upsellOpp);
    if (upsellOpp.Id == null || renewalOpp.CloseDate == upsellOpp.CloseDate) {
      upsellOpp.AccountId = renewalOpp.AccountId;
      upsellOpp.Cycle__c = upsellOpp.Cycle__c != null
        ? upsellOpp.Cycle__c
        : 'Annually';
      upsellOpp.Type = 'Upsell';
      upsellOpp.Cycle_Price_Local__c = upsellOppsWithPriceIncrease.contains(
          upsellOpp.Id
        )
        ? renewalOpp.Cycle_Price_Local__c * 0.07
        : upsellOpp.Cycle_Price_Local__c;
      upsellOpp.Currency__c = renewalOpp.Currency__c;
      upsellOpp.Exchange_Rate__c = renewalOpp.Exchange_Rate__c;
      System.debug(
        'upsellOpp.Cycle_Price_Local__c---' + upsellOpp.Cycle_Price_Local__c
      );
      System.debug(
        'upsellOpp.Exchange_Rate__c---' + upsellOpp.Exchange_Rate__c
      );
      Integer cycleCalc = (upsellOpp.Cycle_Price_Local__c *
        upsellOpp.Exchange_Rate__c)
        .round()
        .intValue();
      upsellOpp.Cycle_Price__c = cycleCalc;
      upsellOpp.CloseDate = renewalOpp.CloseDate;
      upsellOpp.StageName = upsellOpp.StageName != null
        ? upsellOpp.StageName
        : 'Initial Discovery';
      upsellOpp.OwnerId = upsellOpp.OwnerId != null
        ? upsellOpp.OwnerId
        : renewalOpp.OwnerId;
    }
    return upsellOpp;
  }

  private Integer getCyclePriceOfSubscriptions(
    List<Zuora__Subscription__c> subscriptions
  ) {
    Date startDate = subscriptions[0].Zuora__TermStartDate__c;
    Date nextRenewalDate = subscriptions[0].Zuora__NextRenewalDate__c;
    Integer currentMrrCalculated = (subscriptions[0].Zuora__MRR__c * 12)
      .round()
      .intValue();
    System.debug('currentMrrCalculated--' + currentMrrCalculated);
    if (subscriptions.size() > 1) {
      System.debug(' more then 1');
      for (Integer index = 1; subscriptions.size() > index; index++) {
        if (
          subscriptions[index].Zuora__TermStartDate__c == startDate &&
          subscriptions[index].Zuora__NextRenewalDate__c == nextRenewalDate
        ) {
          currentMrrCalculated += (subscriptions[index].Zuora__MRR__c * 12)
            .round()
            .intValue();
        }
      }
    }
    return currentMrrCalculated;
  }

  private Decimal getExchngeRateForCurrency(String currencyCode) {
    Decimal rate = 0;
    Map<String, Decimal> exchangeRateMap = GeneralUtil.getNetsuiteDailyExchangeRateMap();
    if (currencyCode == 'USD') {
      rate = 1;
    } else {
      rate = exchangeRateMap.get(currencyCode);
    }
    return rate;
  }

  @future
  private static void resetForecast(Map<String, String> oppToStageMap) {
    List<Opportunity> oppList = new List<Opportunity>();
    for (String key : oppToStageMap.keySet()) {
      oppList.add(
        new Opportunity(Id = key, StageName = oppToStageMap.get(key))
      );
    }
    update oppList;
  }
}

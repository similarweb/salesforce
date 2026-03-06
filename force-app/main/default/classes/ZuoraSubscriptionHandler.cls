public without sharing class ZuoraSubscriptionHandler {
  public static map<id, Account> Acc4Update = new Map<id, Account>();
  public static map<id, Zuora__Subscription__c> oldmap = new Map<id, Zuora__Subscription__c>();
  public static map<id, Account> AccMap = new Map<id, Account>();

  public static map<id, Zuora__Subscription__c> Sub4Reval = new Map<id, Zuora__Subscription__c>();

  static public void CalculateAccountSubscriptionStatus(Account a) {
    evaluateAccountSubscriptionStatus(a);
    Acc4Update.put(a.id, a);
  }

  public static void evaluateAccountSubscriptionStatus(Account a) {
    Boolean isPastRenewalDate =
      a.fr_NextRenewalDate__c != null &&
      a.fr_NextRenewalDate__c < Date.today();
    a.status__c = null;

    boolean hasCancelled = false;
    boolean hasactive = false;
    boolean hasSuspended = false;
    Feature_Flag_Setting__mdt featureFlagSetting = Feature_Flag_Setting__mdt.getInstance(
      'zuoraSubscriptionStatusHandler'
    );
    Boolean featureFlag =
      featureFlagSetting != null && featureFlagSetting.Is_Active__c;
    boolean allsubscriptionIsTrial = true; // lola

    if (a.Zuora__Subscriptions__r.size() > 0) {
      Date subscriptionEndDate;

      for (Zuora__Subscription__c zs : a.Zuora__Subscriptions__r) {
        if (zs.Zuora__Status__c != null) {
          if (zs.Payment_Status__c != 'NT CC Trial') {
            allsubscriptionIsTrial = false;
          }
          if (subscriptionEndDate == null) {
            subscriptionEndDate = zs.Zuora__SubscriptionEndDate__c;
          }
          if (
            zs.Zuora__SubscriptionEndDate__c >= subscriptionEndDate ||
            zs.Zuora__Status__c.tolowercase() == 'active'
          ) {
            subscriptionEndDate = zs.Zuora__SubscriptionEndDate__c;
          } else {
            continue;
          }

          if (
            zs.Zuora__Status__c.tolowercase() == 'active' &&
            (zs.Payment_Status__c != 'NT CC Trial' || !featureFlag)
          ) {
            hasactive = true;
            break;
          }
          if (
            zs.Zuora__Status__c.tolowercase() == 'suspended' &&
            (zs.Payment_Status__c != 'NT CC Trial' || !featureFlag)
          ) {
            hasSuspended = true;
          }
          if (
            zs.Zuora__Status__c.tolowercase() == 'cancelled' &&
            (zs.Payment_Status__c != 'NT CC Trial' || !featureFlag) &&
            (zs.Zuora__NextRenewalDate__c != null &&
            zs.Zuora__NextRenewalDate__c >= date.today())
          ) {
            hasCancelled = true;
          }
        }
      }
    }

    boolean hasNTPaidSubscription = false;
    boolean hasCancelledSubscriptionWithin90Days = false;
    Boolean hasActiveTouchSubscription = false;
    for (Zuora__Subscription__c zs : a.Zuora__Subscriptions__r) {
      if (
        zs.Payment_Status__c == 'NT Paid' &&
        zs.Zuora__Status__c == 'Active'
      ) {
        hasNTPaidSubscription = true;
      }
      if (zs.Payment_Status__c == 'Touch' && zs.Zuora__Status__c == 'Active') {
        hasActiveTouchSubscription = true;
      }
      if (
        zs.Payment_Status__c == 'NT Paid' &&
        zs.Zuora__Status__c == 'Cancelled' &&
        zs.Zuora__SubscriptionEndDate__c > Date.today().addDays(-90)
      ) {
        hasCancelledSubscriptionWithin90Days = true;
      }
    }
    // Boolean shouldBeEligible = hasNTPaidSubscription && (a.status__c == 'Active' || hasCancelledSubscriptionWithin90Days); - If status check is restored, need to put after status calculation
    Boolean shouldBeEligible =
      (hasCancelledSubscriptionWithin90Days || hasNTPaidSubscription) &&
      !hasActiveTouchSubscription;
    a.NT2T_eligible__c = shouldBeEligible;

    Boolean shouldExpire = isPastRenewalDate && !shouldBeEligible;
    if (shouldExpire) {
      a.status__c = 'Expired';
    } else if (hasActive) {
      a.status__c = 'Active';
    } else if (hasSuspended) {
      a.status__c = 'Suspended';
    } else if (hasCancelled) {
      a.status__c = 'Cancelled';
    } else if (allsubscriptionIsTrial && featureFlag) {
      a.status__c = '';
    } else {
      a.status__c = 'Expired';
    }
  }

  public static boolean AccStatusRecReq(
    Zuora__Subscription__c zs,
    string event
  ) {
    system.debug('TESTING - AccStatusRecReq started');
    boolean b = false;
    if (event == 'Insert')
      b = true;
    if (event == 'batch')
      b = true;
    if (oldmap != null && oldmap.containskey(zs.id)) {
      if (oldmap.get(zs.id).Zuora__Account__c != zs.Zuora__Account__c)
        b = true;
      if (oldmap.get(zs.id).Zuora__Status__c != zs.Zuora__Status__c)
        b = true;
      if (
        oldmap.get(zs.id).Zuora__NextRenewalDate__c !=
        zs.Zuora__NextRenewalDate__c
      )
        b = true;
      if (oldmap.get(zs.id).Payment_Status__c != zs.Payment_Status__c)
        b = true;
      if (
        oldmap.get(zs.id).Zuora__SubscriptionEndDate__c !=
        zs.Zuora__SubscriptionEndDate__c
      )
        b = true;
    }
    if (Sub4Reval.ContainsKey(zs.id))
      b = true;
    if (event == 'Delete')
      b = true;

    system.debug('TESTING - AccStatusRecReq is ' + b);
    return b;
  }

  public static void GenDataBefore(
    list<Zuora__Subscription__c> zsList,
    string event
  ) {
    list<id> tempid = new List<id>();
    for (Zuora__Subscription__c zs : zslist) {
      if (zs.Zuora__Account__c != null) {
        if (event == 'Update' && AccStatusRecReq(zs, event)) {
          if (oldmap != null && oldmap.get(zs.id).Zuora__Account__c != null) {
            if (zs.Zuora__Account__c != oldmap.get(zs.id).Zuora__Account__c) {
              tempid.add(oldmap.get(zs.id).Zuora__Account__c);
            }
          }
        }
      }
      if (zs.id != null && event == 'Insert') {
        if (!AccMap.containsKey(zs.Zuora__Account__c)) {
          tempid.add(zs.Zuora__Account__c);
        }
      }
    }
    if (tempid.size() > 0) {
      list<Account> AccList = [
        SELECT
          id,
          Status__c,
          ownerid,
          owner.isactive,
          NT2T_eligible__c,
          fr_Next_Renewal_Date__c,
          fr_NextRenewalDate__c,
          (
            SELECT
              id,
              Zuora__Status__c,
              Zuora__NextRenewalDate__c,
              Zuora__SubscriptionEndDate__c,
              Payment_Status__c
            FROM Zuora__Subscriptions__r
          )
        FROM Account
        WHERE id = :tempid AND Status__c != 'Part Of Another Subscription'
      ];
      if (AccList.size() > 0)
        AccMap.putall(AccList);
    }
  }

  public static void GenDataAfter(
    list<Zuora__Subscription__c> zsList,
    string event
  ) {
    list<id> tempid = new List<id>();
    for (Zuora__Subscription__c zs : zslist) {
      if (zs.Zuora__Account__c != null) {
        if (event == 'Update' && AccStatusRecReq(zs, event)) {
          if (!AccMap.containsKey(zs.Zuora__Account__c)) {
            tempid.add(zs.Zuora__Account__c);
          }
        }
      }
      if (zs.id != null && event == 'Insert') {
        if (!AccMap.containsKey(zs.Zuora__Account__c)) {
          tempid.add(zs.Zuora__Account__c);
        }
      }
    }
    if (tempid.size() > 0) {
      list<Account> AccList = [
        SELECT
          id,
          Status__c,
          ownerid,
          owner.isactive,
          NT2T_eligible__c,
          fr_Next_Renewal_Date__c,
          fr_NextRenewalDate__c,
          (
            SELECT
              id,
              Zuora__Status__c,
              Zuora__NextRenewalDate__c,
              Zuora__SubscriptionEndDate__c,
              Payment_Status__c
            FROM Zuora__Subscriptions__r
            ORDER BY CreatedDate DESC
          )
        FROM Account
        WHERE id = :tempid AND Status__c != 'Part Of Another Subscription'
      ];
      if (AccList.size() > 0)
        AccMap.putall(AccList);
    }
  }

  public static void RecalculateAccSubs(
    list<Zuora__Subscription__c> zsList,
    string event
  ) {
    system.debug('TESTING - RecalculateAccSubs started');
    for (Zuora__Subscription__c zs : zslist) {
      if (AccStatusRecReq(zs, event)) {
        if (
          zs.Zuora__Account__c != null &&
          AccMap.containsKey(zs.Zuora__Account__c)
        ) {
          System.debug('RecalculateAccSubs NOT Update Event');
          CalculateAccountSubscriptionStatus(AccMap.get(zs.Zuora__Account__c));
        }
        if (
          event == 'Update' &&
          oldmap != null &&
          oldmap.containsKey(zs.id) &&
          oldmap.get(zs.id).Zuora__Account__c != null &&
          AccMap.containsKey(oldmap.get(zs.id).Zuora__Account__c) &&
          zs.Zuora__Account__c != oldmap.get(zs.id).Zuora__Account__c
        ) {
          System.debug('RecalculateAccSubs Update Event');
          CalculateAccountSubscriptionStatus(
            AccMap.get(oldmap.get(zs.id).Zuora__Account__c)
          );
        }
      }
    }
  }

  public static void CatchFieldRecalc(
    list<Zuora__Subscription__c> zsList,
    string event
  ) {
    for (Zuora__Subscription__c zs : zsList) {
      if (zs.Trigger_AccountRecalc__c) {
        zs.Trigger_AccountRecalc__c = false;
        Sub4Reval.put(zs.id, zs);
      }
    }
  }

  public static void CalcOwner(
    list<Zuora__Subscription__c> zslist,
    string event
  ) {
    if (event == 'Insert') {
      for (Zuora__Subscription__c zs : zslist) {
        if (
          zs.Zuora__Account__c != null &&
          AccMap.ContainsKey(zs.Zuora__Account__c)
        ) {
          if (AccMap.get(zs.Zuora__Account__c).owner.isactive)
            zs.ownerid = AccMap.get(zs.Zuora__Account__c).ownerid;
        }
      }
    }
  }

  public static void handleStatus(List<Zuora__Subscription__c> newList) {
    System.debug('handleStatus----');
    Set<Id> billingAccountIds = new Set<Id>();
    for (Zuora__Subscription__c subscription : newList) {
      if (
        subscription.Zuora__Status__c == 'Active' ||
        subscription.Zuora__Status__c == 'Cancelled'
      ) {
        billingAccountIds.add(subscription.Zuora__CustomerAccount__c);
      }
    }
    //		Map<Id,List<Zuora__Payment__c>> billingAccountToPaymentListMap = new Map<Id,List<Zuora__Payment__c>>();
    Map<Id, Zuora__CustomerAccount__c> billingAccountsMap = new Map<Id, Zuora__CustomerAccount__c>(
      [
        SELECT
          id,
          Bouncepay__c,
          (
            SELECT Zuora__Effective_Date__c
            FROM Zuora__Payments__r
            WHERE Zuora__Status__c = 'Processed'
          )
        FROM Zuora__CustomerAccount__c
        WHERE Id IN :billingAccountIds
      ]
    );

    //		for(Zuora__Payment__c payment :   [SELECT Id,Zuora__Effective_Date__c,Zuora__BillingAccount__c FROM Zuora__Payment__c WHERE Zuora__Status__c = 'Processed' AND Zuora__BillingAccount__c IN :billingAccountIds]){
    //			if(!billingAccountToPaymentListMap.containsKey(payment.Zuora__BillingAccount__c)){
    //				billingAccountToPaymentListMap.put(payment.Zuora__BillingAccount__c , new List<Zuora__Payment__c>());
    //			}
    //			billingAccountToPaymentListMap.get(payment.Zuora__BillingAccount__c).add(payment);
    //		}

    for (Zuora__Subscription__c subscription : newList) {
      Zuora__CustomerAccount__c billingAccount = billingAccountsMap.get(
        subscription.Zuora__CustomerAccount__c
      );

      if (subscription.Zuora__TermSettingType__c != 'EVERGREEN') {
        subscription.Payment_Status__c = 'Touch';
      } else if (billingAccount != null) {
        subscription.Payment_Status__c = decideAcordingToPayments(
          subscription.Zuora__ServiceActivationDate__c,
          billingAccount
        );
      }
    }
  }

  private static String decideAcordingToPayments(
    Date subscriptionStartDate,
    Zuora__CustomerAccount__c billingAccountWithPayments
  ) {
    System.debug('decideAcordingToPayments--');
    boolean paymentFound = false; //billingAccountWithPayments.Bouncepay__c ;
    Integer daysToSubstract = -1;
    Integer daysToAdd = 28;
    if (!paymentFound) {
      for (
        Zuora__Payment__c payment : billingAccountWithPayments.Zuora__Payments__r
      ) {
        if (
          payment.Zuora__Effective_Date__c >=
          subscriptionStartDate.addDays(daysToSubstract) &&
          payment.Zuora__Effective_Date__c <=
          subscriptionStartDate.addDays(daysToAdd)
        ) {
          paymentFound = true;
          break;
        }
      }
    }
    return paymentFound ? 'NT Paid' : 'NT CC Trial';
  }

  public static void HandleBefore(
    list<Zuora__Subscription__c> zsList,
    map<id, Zuora__Subscription__c> oldtriggermap,
    string event
  ) {
    system.debug('TESTING - HandleBEFORE Started');
    if (oldtriggermap != null)
      oldmap = oldtriggermap;
    GenDataBefore(zsList, event);
    CatchFieldRecalc(zslist, event);
    CalcOwner(zslist, event);
    handleStatus(zsList);
  }

  public static void HandleAFTER(
    list<Zuora__Subscription__c> zsList,
    map<id, Zuora__Subscription__c> oldtriggermap,
    string event
  ) {
    system.debug('TESTING - HandleAFTER Started');
    List<Zuora__Subscription__c> zuoraSubscriptionListToCheck = new List<Zuora__Subscription__c>();
    if (oldtriggermap != null)
      oldmap = oldtriggermap;

    GenDataAfter(zsList, event);
    RecalculateAccSubs(zsList, event);

    utils.Codeoff = true;
    if (Acc4Update.size() > 0) {
      Boolean isAsyncContext = System.isBatch() || System.isFuture();
      String accsToJson = JSON.serialize(Acc4Update);
      if (!isAsyncContext) {
        asyncWork(accsToJson);
      }
      System.debug('TESTING - Acc4Update Updated');
    }
    if (event == 'Insert' || event == 'Update') {
      Set<Id> subscriptionIdSet = new Set<Id>();
      for (Zuora__Subscription__c sub_i : zsList) {
        if (
          oldtriggermap != null &&
          oldtriggermap.get(sub_i.Id).Zuora__NextRenewalDate__c !=
          sub_i.Zuora__NextRenewalDate__c
        ) {
          zuoraSubscriptionListToCheck.add(sub_i);
        }
        if (
          oldtriggermap == null ||
          oldtriggermap.get(sub_i.Id).Zuora__Version__c !=
          sub_i.Zuora__Version__c
        ) {
          System.debug('subscriptionIdSet.add');
          subscriptionIdSet.add(sub_i.Id);
        }
      }
      if (!subscriptionIdSet.isEmpty()) {
        System.debug('subscriptionIdSet.isNotEmpty ' + subscriptionIdSet);
        System.enqueueJob(
          new QuoteRenewalProcessQueueableService(
            subscriptionIdSet,
            'refreshRenewalQuoteUnderSubscription'
          )
        );
      }
    }
    // Update accounts for existing logic (renewal dates, etc.)
    if (!zuoraSubscriptionListToCheck.isEmpty()) {
      updateRelatedAccounts(zuoraSubscriptionListToCheck);
    }
    if (event == 'Insert') {
      updateRelatedAccounts(zsList);
    }

    utils.Codeoff = false;
  }

  @future
  public static void asyncWork(String accs) {
    utils.Codeoff = true;
    map<id, Account> accs2Update = (map<id, Account>) JSON.deserialize(
      accs,
      map<id, Account>.class
    );
    update accs2Update.values();
    utils.Codeoff = false;
  }

  private static void updateRelatedAccounts(
    List<Zuora__Subscription__c> newRecords
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Zuora__Subscription__c sub : newRecords) {
      Id accountId = sub.Zuora__Account__c;
      accountIds.add(accountId);
    }
    ZSubscriptionService subService = new ZSubscriptionService();
    List<Account> updatedAccounts = subService.updateRelatedAccounts(
      accountIds
    );
    update updatedAccounts;
  }
}

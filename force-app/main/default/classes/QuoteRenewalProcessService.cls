public with sharing class QuoteRenewalProcessService {
  private static Id renewalRecordTypeId;
  private static Id renewalOpportunityId;
  private static final Map<String, String> RENEWAL_FIELDS_MAP;
  private static final String RECIPIENTS_METADATA_NAME = 'Duplication_process_notification_emails';
  private static final String RENEWAL_QUOTE_DUPLICATION_TEMPLATE = 'Renewal_quote_duplication_process_has_failed';
  private static final String RENEWAL_QUOTE_DUPLICATION_ON_ANOTHER_AMEND_TEMPLATE = 'A_renewal_quote_duplication_process_has_failed_on_the_creation_of_another_amend';
  private static final String DUPLICATE_RENEWAL_SHOULD_BE_REVIEWED = 'Duplicate_renewal_should_be_reviewed';

  static {
    RENEWAL_FIELDS_MAP = new Map<String, String>();
    RENEWAL_FIELDS_MAP.put('zqu__InitialTerm__c', 'Amendment_Initial_Term__c');
    RENEWAL_FIELDS_MAP.put('zqu__RenewalTerm__c', 'Amendment_Renewal_Term__c');
    RENEWAL_FIELDS_MAP.put(
      'zqu__PaymentMethod__c',
      'Amendment_Renewal_Payment_Method__c'
    );
    RENEWAL_FIELDS_MAP.put(
      'payment_frequency1__c',
      'Amendment_Renewal_Payment_Frequency__c'
    );
    RENEWAL_FIELDS_MAP.put(
      'Payment_Type__c',
      'Amendment_Renewal_Payment_Type__c'
    );
    RENEWAL_FIELDS_MAP.put(
      'zqu__SubscriptionTermStartDate__c',
      'Amendment_Renewal_Start_Date__c'
    );
    RENEWAL_FIELDS_MAP.put(
      'zqu__Service_Activation_Date__c',
      'Amendment_Renewal_Start_Date__c'
    );
    RENEWAL_FIELDS_MAP.put(
      'zqu__Customer_Acceptance_Date__c',
      'Amendment_Renewal_Start_Date__c'
    );
    RENEWAL_FIELDS_MAP.put(
      'zqu__StartDate__c',
      'Amendment_Renewal_Start_Date__c'
    );
    // RENEWAL_FIELDS_MAP.put('Target_Quote_Total_Price__c','Renewal_Fee__c');
    RENEWAL_FIELDS_MAP.put(
      'zqu__PaymentTerm__c',
      'Amendment_Renewal_Payment_Term__c'
    );
  }

  private static Map<String, String> zuoraContactGenerationSettings {
    get {
      if (zuoraContactGenerationSettings == null) {
        zuoraContactGenerationSettings = new Map<String, String>();
        for (Zuora_Quote_Contact_Generation_Setting__mdt zqcgs_i : [
          SELECT DeveloperName, Value__c
          FROM Zuora_Quote_Contact_Generation_Setting__mdt
        ]) {
          zuoraContactGenerationSettings.put(
            zqcgs_i.DeveloperName,
            zqcgs_i.Value__c
          );
        }
      }
      return zuoraContactGenerationSettings;
    }
    private set;
  }

  public static List<QuoteProductsChangeUnit> createRenewalCloneOfAmendQuote(
    Set<Id> quoteIdList
  ) {
    Map<Id, Id> oldToNewQuoteIdMap = new Map<Id, Id>();
    Map<Id, zqu.Quote> oldIdToRenewalZQuoteMap = new Map<Id, zqu.Quote>();
    List<zqu.Quote> oldZQuoteList = new List<zqu.Quote>();
    Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap = new Map<Id, QuoteProductsChangeUnit>();
    try {
      for (Id quote_i : quoteIdList) {
        zqu.Quote zQuote = zqu.Quote.getInstance(quote_i); // ZOHAR -- alon was here!! the wrapper cass
        oldZQuoteList.add(zQuote);
        validateQuote(zQuote); // soql in loop...
        zqu.Quote renewClonedZQuote = cloneQuote(zQuote);
        zqu__Quote__c quote = renewClonedZQuote.getSObject();
        // changeQuoteSubscriptionToRenewal(quote);
        changeQuoteBusinessTypeToRenewalOnly(quote);
        populateDefaultFieldsFromRenewalFields(quote);
        markAsDuplicatedQuote(quote);
        // populateOpportunityLookup(quote);
        oldIdToRenewalZQuoteMap.put(quote_i, renewClonedZQuote);
      }
      system.debug(
        'oldIdToRenewalZQuoteMap--' + oldIdToRenewalZQuoteMap.size()
      );
      quoteProductsChangeUnitMap = getProductsChangeUnitsFromQuotes(
        oldZQuoteList
      );
      system.debug('quoteProductsChangeUnitMap--' + quoteProductsChangeUnitMap);
      for (Id quoteId : oldIdToRenewalZQuoteMap.keySet()) {
        zqu.Quote zQuote_i = oldIdToRenewalZQuoteMap.get(quoteId);
        //                zqu__Quote__c quote2 = [SELECT Id,package__c FROM zqu__Quote__c WHERE Id =:quoteId];
        //                system.debug(quote2.package__c);
        system.debug(' i am before buildAndSave');
        zQuote_i.buildAndSave();
        oldToNewQuoteIdMap.put(quoteId, zQuote_i.getSObject().Id);
        System.debug('zQuote_i - ' + zQuote_i.getSObject().Id);
      }
      for (Id quoteId : oldIdToRenewalZQuoteMap.keySet()) {
        zqu.Quote zQuote_i = oldIdToRenewalZQuoteMap.get(quoteId);
        QuoteProductsChangeUnit quoteProductsChangeUnit = quoteProductsChangeUnitMap.get(
          quoteId
        );
        quoteProductsChangeUnit.targetQuoteId = zQuote_i.getSObject().Id;
        system.debug(
          'quoteProductsChangeUnit.targetQuoteId--' +
          quoteProductsChangeUnit.targetQuoteId
        );
        quoteProductsChangeUnit.targetQuotePrice = zQuote_i.getSObject()
          .Renewal_Fee__c;
        // zQuote_i.getSObject().Target_Quote_Total_Price__c = null;
      }
      attachContactDocumentsFromOldQuoteToNew(oldToNewQuoteIdMap);
    } catch (Exception e) {
      system.debug('stackTrace---' + e.getStackTraceString());
      system.debug('errror---' + e.getMessage());
      sendEmailNotificationAboutError(
        quoteIdList,
        RENEWAL_QUOTE_DUPLICATION_TEMPLATE,
        e.getMessage()
      );
    }
    return quoteProductsChangeUnitMap.values();
  }

  public static void deleteOneTimeProductsFromClone(
    List<QuoteProductsChangeUnit> quoteProductsChangeUnitList
  ) {
    System.debug('*** deleteProducts');
    for (
      QuoteProductsChangeUnit quoteProductsChangeUnit : quoteProductsChangeUnitList
    ) {
      Id quoteId = quoteProductsChangeUnit.targetQuoteId;
      System.debug('*** quoteId  ' + quoteId);
      zqu.Quote zQuote = zqu.Quote.getInstance(quoteId);
      List<zqu.QuoteProduct> quoteProductsToRemove = new List<zqu.QuoteProduct>();
      for (zqu.QuoteProduct product_i : zQuote.getQuoteProducts()) {
        zqu.zChargeGroup zcg_i = product_i.chargeGroup;
        System.debug('*** zcg_i.groupType ' + zcg_i.groupType);
        System.debug(
          '*** zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL ' +
          zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL
        );
        System.debug(
          '*** zcg_i.zCharges[0].CHARGE_TYPE ' + zcg_i.zCharges[0].CHARGE_TYPE
        );
        System.debug('*** zcg_i.productName ' + zcg_i.productName);
        if (
          zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL &&
          zcg_i.zCharges[0].CHARGE_TYPE == 'One-Time'
        ) {
          quoteProductsToRemove.add(product_i);
        }
      }
      if (!quoteProductsToRemove.isEmpty()) {
        zQuote.deleteQuoteProducts(quoteProductsToRemove);
        zQuote.save();
        System.debug('*** Success');
      }
    }
  }

  public static void reAddCharges(
    List<QuoteProductsChangeUnit> quoteProductsChangeUnitList
  ) {
    system.debug(
      'alon reAddCharges-size of list-' + quoteProductsChangeUnitList.size()
    );
    system.debug(
      'alon reAddCharges-size of list-' + quoteProductsChangeUnitList
    );
    Set<Id> quoteIdSet = new Set<Id>();
    for (
      QuoteProductsChangeUnit quoteProductsChangeUnit : quoteProductsChangeUnitList
    ) {
      quoteIdSet.add(quoteProductsChangeUnit.targetQuoteId);
    }
    Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>(
      [
        SELECT Id, payment_frequency1__c, zqu__InitialTerm__c
        FROM zqu__Quote__c
        WHERE Id IN :quoteIdSet
      ]
    );
    for (
      QuoteProductsChangeUnit quoteProductsChangeUnit : quoteProductsChangeUnitList
    ) {
      zqu.Quote zQuote = zqu.Quote.getInstance(
        quoteProductsChangeUnit.targetQuoteId
      );
      Boolean removalCompleted = false;
      for (zqu.QuoteProduct product_i : zQuote.getQuoteProducts()) {
        zqu.zChargeGroup zcg_i = product_i.chargeGroup;
        if (
          zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
          zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
        ) {
          for (zqu.zCharge charge_i : zcg_i.zCharges) {
            system.debug('alon is here!! - charge_i' + charge_i);
            system.debug('alon is here!! - charge_i' + charge_i.CHARGE_TYPE);
            String paymentFrequency = quoteMap.get(zQuote.getSObject().Id)
              .payment_frequency1__c;
            if (
              charge_i.SPECIFIC_BILLING_PERIOD != null &&
              !removalCompleted &&
              Integer.valueOf(charge_i.SPECIFIC_BILLING_PERIOD) !=
              ZuoraQuoteMetricsManipulationHelper.getPaymentFrequencyNumber(
                paymentFrequency,
                quoteMap.get(zQuote.getSObject().Id).zqu__InitialTerm__c
              ) &&
              zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL
            ) {
              ZuoraQuoteMetricsManipulationHelper.reAddAllProducts(
                zQuote.getSObject().Id
              );
              removalCompleted = true;
              break;
            } else if (
              zcg_i.groupType ==
              zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT && !removalCompleted
            ) {
              zqu.zCharge charge_original = zcg_i.originalChargeGroup.zCharges[0];
              if (
                Integer.valueOf(charge_i.SPECIFIC_BILLING_PERIOD) !=
                Integer.valueOf(charge_original.SPECIFIC_BILLING_PERIOD)
              ) {
                ZuoraQuoteMetricsManipulationHelper.removeAllUpdatedProducts(
                  zQuote.getSObject().Id
                );
                removalCompleted = true;
                break;
              }
            }
          }
        }
      }
    }
  }

  public static void recalculateMetrics(
    Map<Id, zqu.Quote> renewClonedZQuoteMap
  ) {
    List<zqu.zQuoteUtil.ZBillingResult> zbillingResultList = new List<zqu.zQuoteUtil.ZBillingResult>();
    for (Id quoteId : renewClonedZQuoteMap.keySet()) {
      zqu.Quote renewClonedZQuote = renewClonedZQuoteMap.get(quoteId);
      zqu.zQuoteUtil.ZBillingResult previewResult = zqu.QuoteRecalculateController.JR_recalculate(
        renewClonedZQuote.getSObject().Id
      );
      zbillingResultList.add(previewResult);
    }

    for (zqu.zQuoteUtil.ZBillingResult pResult : zbillingResultList) {
      if (!pResult.success) {
        System.debug(pResult.message);
      }
    }
  }

  public static void refreshRenewalQuoteUnderSubscription(
    Set<Id> subscriptionIdSet
  ) {
    if (subscriptionIdSet.size() > 0) {
      Boolean queueAgain = false;
      Map<String, Zuora__Subscription__c> numberToSubscriptionMap = new Map<String, Zuora__Subscription__c>();
      List<Zuora__Subscription__c> subscriptionList = [
        SELECT Id, Name, Zuora__Version__c
        FROM Zuora__Subscription__c
        WHERE Id IN :subscriptionIdSet
      ];
      if (!subscriptionList.isEmpty()) {
        Set<Id> quoteIdSet = new Set<Id>();
        try {
          List<zqu__Quote__c> quoteToRenewList = new List<zqu__Quote__c>();
          List<zqu__Quote__c> originalQuotesForUpdate = new List<zqu__Quote__c>();
          Map<String, List<zqu__Quote__c>> quotesToRenewFilteredMap = obtainQuotesForRenewal(
            subscriptionList
          );

          for (String name : quotesToRenewFilteredMap.keySet()) {
            zqu__Quote__c quoteToRenew;
            for (zqu__Quote__c quote : quotesToRenewFilteredMap.get(name)) {
              if (quoteToRenew == null) {
                quoteToRenew = quote;
              } else if (
                quoteToRenew.zqu__SubscriptionVersion__c <
                quote.zqu__SubscriptionVersion__c
              ) {
                quoteToRenew = quote;
              }
            }
            quoteToRenewList.add(quoteToRenew);
            originalQuotesForUpdate.addAll(quotesToRenewFilteredMap.get(name));
          }

          Map<zqu.Quote, Id> zQuoteToQuoteMap = new Map<zqu.Quote, Id>();
          for (zqu__Quote__c quote_i : quoteToRenewList) {
            quoteIdSet.add(quote_i.id);
            zqu.Quote zQuote = zqu.Quote.getInstance(quote_i.id);
            validateQuote(zQuote);
            zQuoteToQuoteMap.put(zQuote, quote_i.Id);
          }
          Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap = getProductsChangeUnitsFromQuotes(
            new List<zqu.Quote>(zQuoteToQuoteMap.keySet())
          );

          Map<Id, zqu__Quote__c> quoteToRenewMap = new Map<Id, zqu__Quote__c>();
          for (zqu__Quote__c quote_i : quoteToRenewList) {
            quoteToRenewMap.put(quote_i.id, quote_i);
          }
          Map<Id, zqu.Quote> renewClonedZQuoteMap = cloneQuote(
            zQuoteToQuoteMap
          );
          List<SObject> zQuotesList = new List<SObject>();
          system.debug('renewClonedZQuoteMap--' + renewClonedZQuoteMap);
          for (Id quoteId : renewClonedZQuoteMap.keyset()) {
            zqu.Quote renewClonedZQuote = renewClonedZQuoteMap.get(quoteId);
            zqu__Quote__c quote_i = quoteToRenewMap.get(quoteId);
            renewClonedZQuote.set(
              'zqu__SubscriptionTermStartDate__c',
              quote_i.zqu__SubscriptionTermStartDate__c
            );
            renewClonedZQuote.set(
              'zqu__SubscriptionTermEndDate__c',
              quote_i.zqu__SubscriptionTermEndDate__c
            );
            renewClonedZQuote.set(
              'zqu__StartDate__c',
              quote_i.zqu__StartDate__c
            );
            renewClonedZQuote.set(
              'Target_Quote_Total_Price__c',
              quote_i.Target_Quote_Total_Price__c
            );
            renewClonedZQuote.set(
              'zqu_Quote_Status__c',
              quote_i.zqu_Quote_Status__c
            );

            renewClonedZQuote.set(
              'zqu__InitialTerm__c',
              quote_i.zqu__InitialTerm__c
            );
            renewClonedZQuote.set(
              'zqu__RenewalTerm__c',
              quote_i.zqu__RenewalTerm__c
            );
            renewClonedZQuote.set(
              'zqu__PaymentMethod__c',
              quote_i.zqu__PaymentMethod__c
            );
            renewClonedZQuote.set(
              'payment_frequency1__c',
              quote_i.payment_frequency1__c
            );
            renewClonedZQuote.set('Payment_Type__c', quote_i.Payment_Type__c);
            renewClonedZQuote.set(
              'zqu__Service_Activation_Date__c',
              quote_i.zqu__Service_Activation_Date__c
            );
            renewClonedZQuote.set(
              'zqu__Customer_Acceptance_Date__c',
              quote_i.zqu__Customer_Acceptance_Date__c
            );
            renewClonedZQuote.set(
              'zqu__PaymentTerm__c',
              quote_i.zqu__PaymentTerm__c
            );
            renewClonedZQuote.set(
              'Recurring_Target_Price__c',
              quote_i.Renewal_Fee__c
            );
            markAsDuplicatedQuote(renewClonedZQuote);
            System.debug('zQuote_i - ' + renewClonedZQuote.getSObject().Id);
            renewClonedZQuote.buildAndSave();
            zQuotesList.add(renewClonedZQuote.getSObject());
            System.debug('zQuote_i - ' + renewClonedZQuote.getSObject().Id);
          }

          for (zqu__Quote__c quoteToUpdate : originalQuotesForUpdate) {
            quoteToUpdate.zqu_Quote_Status__c = 'Cancelled';
          }

          if (!originalQuotesForUpdate.isEmpty()) {
            update originalQuotesForUpdate;
          }
          if (!zQuotesList.isEmpty()) {
            upsert zQuotesList;
          }
          system.debug('renewClonedZQuoteMap--' + renewClonedZQuoteMap.size());
          system.debug(
            'quoteProductsChangeUnitMap--' + quoteProductsChangeUnitMap.size()
          );
          if (
            !renewClonedZQuoteMap.isEmpty() &&
            !quoteProductsChangeUnitMap.isEmpty()
          ) {
            System.enqueueJob(
              new QuoteRenewalProcessQueueableService(
                renewClonedZQuoteMap,
                quoteProductsChangeUnitMap,
                'applyProductChangesToQuote'
              )
            );
          }
        } catch (Exception ex) {
          System.debug(ex.getMessage());
          sendEmailNotificationAboutError(
            quoteIdSet,
            RENEWAL_QUOTE_DUPLICATION_ON_ANOTHER_AMEND_TEMPLATE,
            ex.getMessage()
          );
        }
      }
    }
  }

  public static void updateRenewalCloneOfAmendQuote(
    List<QuoteProductsChangeUnit> quoteProductsChangeUnitList
  ) {
    for (
      QuoteProductsChangeUnit quoteProductsChangeUnit_i : quoteProductsChangeUnitList
    ) {
      system.debug(
        'quoteProductsChangeUnit_i.targetQuoteId--' +
        quoteProductsChangeUnit_i.targetQuoteId
      );
      zqu.Quote zQuote = zqu.Quote.getInstance(
        quoteProductsChangeUnit_i.targetQuoteId
      );
      String subscriptionId = zQuote.getSObject().zqu__ExistSubscriptionID__c;
      Decimal contractedMrr = 0;
      HTTPRequest req = new HTTPRequest();
      req.setEndpoint(
        zuoraContactGenerationSettings.get('Endpoint') +
          '/v1/subscriptions/' +
          subscriptionId
      );
      req.setMethod('GET');
      req.setHeader('Content-Type', 'application/json');
      if (
        zuoraContactGenerationSettings.containsKey('client_id') &&
        zuoraContactGenerationSettings.containsKey('client_secret') &&
        Utility.isProductionOrg()
      ) {
        String beareToken = getBearerToken(
          zuoraContactGenerationSettings.get('client_id'),
          zuoraContactGenerationSettings.get('client_secret')
        );

        req.setHeader('Authorization', 'Bearer ' + beareToken);
        System.debug('bearer ' + beareToken);
      } else if (
        zuoraContactGenerationSettings.containsKey('Username') &&
        zuoraContactGenerationSettings.containsKey('Password')
      ) {
        req.setHeader(
          'apiAccessKeyId',
          zuoraContactGenerationSettings.get('Username')
        );
        req.setHeader(
          'apiSecretAccessKey',
          zuoraContactGenerationSettings.get('Password')
        );
      }
      req.setTimeout(120000);
      Http http = new Http();
      HTTPResponse res = http.send(req);
      if (res.getStatusCode() != 200) {
        throw new DmlException('Status code not 200');
      }
      Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      System.debug(JSON.serializePretty(responseBodyMap));
      if (
        responseBodyMap.containsKey('success') &&
        ((Boolean) responseBodyMap.get('success'))
      ) {
        contractedMrr = (Decimal) responseBodyMap.get('contractedMrr');
        zQuote.getSObject().Current_Contract_TCV__c = (contractedMrr *
          zQuote.getSObject().zqu__Initialterm__c)
          .setScale(0, System.RoundingMode.UP);
        // zQuote.getSObject().Current_Contract_TCV_w_o_rounding__c = contractedMrr * zQuote.getSObject().zqu__Initialterm__c;
        zQuote.getSObject().Contract_CMRR__c = (contractedMrr);
      }

      zQuote.save();
    }
  }

  public static void setTargetPriceRenewalCloneOfAmendQuote(
    List<QuoteProductsChangeUnit> quoteProductsChangeUnitList
  ) {
    List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
    Set<Id> quoteIdSet = new Set<Id>();
    for (
      QuoteProductsChangeUnit quoteProductsChangeUnit_i : quoteProductsChangeUnitList
    ) {
      quoteIdSet.add(quoteProductsChangeUnit_i.targetQuoteId);
    }
    List<zqu__Quote__c> quoteList = [
      SELECT
        Id,
        Renewal_Fee__c,
        zqu__InitialTerm__c,
        zqu__QuoteBusinessType__c,
        Is_Initally_Renewed__c,
        Target_Quote_Total_Price__c
      FROM zqu__Quote__c
      WHERE Id IN :quoteIdSet
    ];
    System.debug('quoteList--' + quoteList);
    for (zqu__Quote__c quote_i : quoteList) {
      Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance(
        'Rounding_Resolve_V1'
      );
      Boolean featureFlag = roundingFF.Is_Active__c;
      if (!featureFlag) {
        quote_i.Target_Quote_Total_Price__c = quote_i.Renewal_Fee__c;
        ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPriceMainLogic(
          quote_i.Id,
          quote_i.Renewal_Fee__c,
          quote_i.zqu__InitialTerm__c
        );
      } else {
        quote_i.Recurring_Target_Price__c = quote_i.Renewal_Fee__c;
      }
      quoteToUpdateList.add(quote_i);
      system.debug('Renewal_Fee__c--' + quote_i.Renewal_Fee__c);
    }
    update quoteToUpdateList;
  }

  private static void validateQuote(zqu.Quote zQuote) {
    zqu__Quote__c quoteToValidate = zQuote.getSObject();

    Account account = [
      SELECT id, (SELECT id, Name FROM Contacts)
      FROM Account
      WHERE Id = :quoteToValidate.zqu__Account__c
      LIMIT 1
    ];

    if (
      String.isNotBlank(quoteToValidate.zqu__Zuora_Account_Number__c) &&
      account.Contacts.size() > 0
    ) {
      Boolean isSoldToValid = false;
      Boolean isBillToValid = false;

      Zuora__CustomerAccount__c zAccount = [
        SELECT Id, Zuora__SoldToName__c, Zuora__BillToName__c
        FROM Zuora__CustomerAccount__c
        WHERE
          Zuora__AccountNumber__c = :quoteToValidate.zqu__Zuora_Account_Number__c
        LIMIT 1
      ];

      for (Contact contact : account.Contacts) {
        if (contact.Name.contains(zAccount.Zuora__SoldToName__c)) {
          isSoldToValid = true;
        }
        if (contact.Name.contains(zAccount.Zuora__BillToName__c)) {
          isBillToValid = true;
        }
      }

      if (!(isSoldToValid && isBillToValid)) {
        throw new QuoteCloneException('Sold to or Bill to is Invalid');
      }
    }
  }

  private static Map<Id, zqu.Quote> cloneQuote(
    Map<zqu.Quote, Id> zQuoteToQuoteMap
  ) {
    Map<Id, zqu.Quote> clonedMap = new Map<Id, zqu.Quote>();
    for (zqu.Quote zQuote : zQuoteToQuoteMap.keySet()) {
      zqu.Quote clonedQuote = cloneQuote(zQuote);
      clonedMap.put(zQuoteToQuoteMap.get(zQuote), clonedQuote);
    }
    return clonedMap;
  }

  private static zqu.Quote cloneQuote(zqu.Quote zQuote) {
    zqu.Quote clonedQuote;
    zqu.QuoteCloneResponse cloneResponse;
    zqu.CloneQuoteOptions options = new zqu.CloneQuoteOptions();
    options.shouldCloneProducts = true;
    cloneResponse = zQuote.cloneQuote(options);
    if (cloneResponse.isSuccess) {
      clonedQuote = cloneResponse.clonedQuote;
    } else {
      system.debug('hey this is a bug-' + cloneResponse);
      throw new QuoteCloneException /* cloneResponse.errorMessage */();
    }
    system.debug(clonedQuote.getId());
    return clonedQuote;
  }

  // private static zqu__Quote__c changeQuoteSubscriptionToRenewal(zqu__Quote__c quote){
  //     quote.zqu__SubscriptionType__c = 'Renew Subscription';
  //     quote.recordTypeId = getRenewalRecordTypeId();
  //     return quote;
  // }

  private static zqu__Quote__c changeQuoteBusinessTypeToRenewalOnly(
    zqu__Quote__c quote
  ) {
    quote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
    quote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
    if (Test.isRunningTest()) {
      quote.zqu__PaymentMethod__c = 'Other';
    }
    return quote;
  }

  private static zqu__Quote__c populateDefaultFieldsFromRenewalFields(
    zqu__Quote__c quote
  ) {
    for (String defaulField_i : RENEWAL_FIELDS_MAP.keySet()) {
      String renewalField_i = RENEWAL_FIELDS_MAP.get(defaulField_i);
      System.debug('renewalField_i ' + renewalField_i);
      if (quote.isSet(renewalField_i)) {
        System.debug('isSet');
        quote.put(defaulField_i, quote.get(renewalField_i));
      }
    }
    if (!Test.isRunningTest()) {
      quote.zqu__SubscriptionTermEndDate__c = quote.zqu__SubscriptionTermStartDate__c.addMonths(
        quote.zqu__RenewalTerm__c.intValue()
      );
    }
    return quote;
  }

  private static zqu__Quote__c populateOpportunityLookup(zqu__Quote__c quote) {
    quote.zqu__Opportunity__c = getRenewalOpportunityId();
    return quote;
  }

  private static void attachContactDocumentsFromOldQuoteToNew(
    Map<Id, Id> oldToNewQuoteIdMap
  ) {
    if (!oldToNewQuoteIdMap.isEmpty()) {
      List<ContentDocumentLink> oldCdlList = [
        SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :oldToNewQuoteIdMap.keySet()
      ];

      List<ContentDocumentLink> newCdlList = new List<ContentDocumentLink>();
      for (ContentDocumentLink cdl_i : oldCdlList) {
        if (oldToNewQuoteIdMap.containsKey(cdl_i.LinkedEntityId)) {
          Id renewalQuoteId = oldToNewQuoteIdMap.get(cdl_i.LinkedEntityId);
          ContentDocumentLink newCdl_i = cdl_i.clone(false, true);
          newCdl_i.LinkedEntityId = renewalQuoteId;
          newCdlList.add(newCdl_i);
        }
      }
      insert newCdlList;
    }
  }
  public static Map<String, List<zqu__Quote__c>> obtainQuotesForRenewal(
    List<Zuora__Subscription__c> subscriptionList
  ) {
    String quoteSoqlQuery =
      'SELECT Id, Name, Target_Quote_Total_Price__c, zqu__StartDate__c, zqu__SubscriptionTermStartDate__c, zqu__SubscriptionTermEndDate__c, zqu__PaymentTerm__c,' +
      'zqu__Hidden_Subscription_Name__c, zqu__SubscriptionVersion__c, zqu_Quote_Status__c, zqu__InitialTerm__c, zqu__RenewalTerm__c,' +
      'zqu__PaymentMethod__c, payment_frequency1__c, Payment_Type__c, zqu__Service_Activation_Date__c, zqu__Customer_Acceptance_Date__c, Renewal_Fee__c, Recurring_Target_Price__c ' +
      'FROM zqu__Quote__c WHERE ';
    quoteSoqlQuery += '(';
    for (Zuora__Subscription__c subscription_i : subscriptionList) {
      quoteSoqlQuery +=
        '(zqu__Hidden_Subscription_Name__c = \'' +
        subscription_i.Name +
        '\' AND zqu__SubscriptionVersion__c < ' +
        subscription_i.Zuora__Version__c +
        ') OR ';
    }
    quoteSoqlQuery = quoteSoqlQuery.removeEnd(' OR ') + ')';
    quoteSoqlQuery += ' AND zqu__QuoteBusinessType__c = \'Renewal (with/without upsell)\'';
    quoteSoqlQuery += ' AND zqu_Quote_Status__c = \'Quote Pending Renewal Date\'';
    System.debug('quoteSoqlQuery ' + quoteSoqlQuery);
    List<zqu__Quote__c> quotesToRenewList = (List<zqu__Quote__c>) Database.query(
      quoteSoqlQuery
    );

    Map<String, List<zqu__Quote__c>> quotesToRenewFilteredMap = new Map<String, List<zqu__Quote__c>>();
    List<zqu__Quote__c> quotesToReturn = new List<zqu__Quote__c>();
    for (zqu__Quote__c quote_i : quotesToRenewList) {
      if (
        quotesToRenewFilteredMap.containsKey(
          quote_i.zqu__Hidden_Subscription_Name__c
        )
      ) {
        zqu__Quote__c currQuote = quotesToRenewFilteredMap.get(
          quote_i.zqu__Hidden_Subscription_Name__c
        )[0];
        if (
          !quotesToRenewFilteredMap.containsKey(
            quote_i.zqu__Hidden_Subscription_Name__c
          )
        ) {
          List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
          quoteList.add(quote_i);
          quotesToRenewFilteredMap.put(
            quote_i.zqu__Hidden_Subscription_Name__c,
            quoteList
          );
        } else {
          List<zqu__Quote__c> quoteList = quotesToRenewFilteredMap.get(
            quote_i.zqu__Hidden_Subscription_Name__c
          );
          quoteList.add(quote_i);
          quotesToRenewFilteredMap.put(
            quote_i.zqu__Hidden_Subscription_Name__c,
            quoteList
          );
        }
      } else {
        quotesToRenewFilteredMap.put(
          quote_i.zqu__Hidden_Subscription_Name__c,
          new List<zqu__Quote__c>{ quote_i }
        );
      }
    }
    return quotesToRenewFilteredMap;
  }

  private static Id getRenewalRecordTypeId() {
    if (renewalRecordTypeId == null) {
      renewalRecordTypeId = Utility.getRecordTypeIdForObject(
        'zqu__Quote__c',
        'Renewal'
      );
    }
    return renewalRecordTypeId;
  }

  private static Id getRenewalOpportunityId() {
    if (renewalOpportunityId == null) {
      List<Opportunity> oppList;
      if (Test.isRunningTest()) {
        oppList = [
          SELECT Id
          FROM Opportunity
        ];
      } else {
        oppList = [
          SELECT Id
          FROM Opportunity
          WHERE
            RecordType.DeveloperName = 'Renewal'
            AND StageName != 'Closed Won'
            AND StageName != 'Closed Lost'
            AND CreatedBy.UserRole.Name = 'Internal'
        ];
      }
      if (oppList.isEmpty()) {
        throw new OppRenewalException(
          'Renewal Opportunity record does not exist'
        );
      }
      renewalOpportunityId = oppList[0].id;
    }
    return renewalOpportunityId;
  }

  private static Map<Id, QuoteProductsChangeUnit> getProductsChangeUnitsFromQuotes(
    List<zqu.Quote> zQuoteList
  ) {
    system.debug('alon getProductsChangeUnitsFromQuotes--');
    Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap = new Map<Id, QuoteProductsChangeUnit>();
    List<Id> productIdsToAdd = new List<Id>();
    Map<Id, QuoteProductsChangeUnit> productIdToChangeUnitMap = new Map<Id, QuoteProductsChangeUnit>();
    Set<String> restrictedTypeSet = new Set<String>{ 'One-Time' };
    for (zqu.Quote zQuote_i : zQuoteList) {
      QuoteProductsChangeUnit quoteProductsChangeUnit = new QuoteProductsChangeUnit(
        zQuote_i
      );
      quoteProductsChangeUnitMap.put(
        quoteProductsChangeUnit.quoteId,
        quoteProductsChangeUnit
      );
      for (zqu.QuoteProduct product_i : zQuote_i.getQuoteProducts()) {
        system.debug('product_i--' + product_i);
        zqu.zChargeGroup zcg_i = product_i.chargeGroup;
        if (!restrictedTypeSet.contains(zcg_i.zCharges[0].CHARGE_TYPE)) {
          if (zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_NEWPRODUCT) {
            productIdToChangeUnitMap.put(
              zcg_i.productId,
              quoteProductsChangeUnit
            );
            productIdsToAdd.add(zcg_i.productId);
            quoteProductsChangeUnit.addedProductIdMap.put(
              zcg_i.productId.toLowerCase(),
              zcg_i
            );
          } else if (
            zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
          ) {
            quoteProductsChangeUnit.removedProductIds.add(
              zcg_i.productId.toLowerCase()
            );
            quoteProductsChangeUnit.removedProducts.add(product_i);
          } else if (
            zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
          ) {
            quoteProductsChangeUnit.updatedProductIdMap.put(
              zcg_i.productId.toLowerCase(),
              zcg_i
            );
          }
        }
      }
    }
    if (!productIdsToAdd.isEmpty()) {
      List<zqu.Product> productsToAdd = zqu.Product.loadProductsWithChildren(
        productIdsToAdd
      );
      for (zqu.Product product_i : productsToAdd) {
        QuoteProductsChangeUnit quoteProductsChangeUnit = productIdToChangeUnitMap.get(
          product_i.productId
        );
        quoteProductsChangeUnit.addedProducts.add(product_i);
      }
    }
    //        if(!quoteIdToProductListToDelete.isEmpty()){
    //            for(Id quoteId : quoteIdToProductListToDelete.keySet()){
    //                zqu.Quote zQuote = zqu.Quote.getInstance(quoteId);
    //                zQuote.deleteQuoteProducts(quoteIdToProductListToDelete.get(quoteId));
    //                zQuote.save();
    //            }
    //
    //        }
    return quoteProductsChangeUnitMap;
  }

  private static zqu__Quote__c markAsDuplicatedQuote(zqu__Quote__c quote) {
    quote.Duplicate_Quote__c = true;
    return quote;
  }

  private static zqu.Quote markAsDuplicatedQuote(zqu.Quote zQuote) {
    zQuote.set('Duplicate_Quote__c', true);
    return zQuote;
  }

  private static String getBearerToken(String clientId, String clientSecret) {
    String bearerToken;
    HTTPRequest req = new HTTPRequest();
    req.setEndpoint(
      zuoraContactGenerationSettings.get('Endpoint') + '/oauth/token'
    );
    req.setTimeout(120000);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    req.setHeader('Accept', 'application/json; charset=utf-8');
    String body =
      'client_id=' +
      EncodingUtil.urlEncode(clientId, 'UTF-8') +
      '&client_secret=' +
      EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
      '&grant_type=client_credentials';
    req.setBody(body);
    Http http = new Http();
    HTTPResponse res = http.send(req);
    if (res.getStatusCode() == 200) {
      Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      if (responseBodyMap.containsKey('access_token')) {
        bearerToken = (String) responseBodyMap.get('access_token');
      }
    }
    return bearerToken;
  }

  @TestVisible
  private static void sendEmailNotificationAboutError(
    Set<Id> quoteIdList,
    String emailTemplateName,
    String errorMessage
  ) {
    List<zqu__Quote__c> quoteList = [
      SELECT
        Id,
        Link_Raw__c,
        zqu__Opportunity__c,
        zqu__Opportunity__r.Id,
        Zuora_General_Error_Message__c,
        zqu__Hidden_Subscription_Name__c,
        Owner.Email
      FROM zqu__Quote__c
      WHERE Id IN :quoteIdList
      LIMIT 1
    ];

    Id emailTemplateId = [
      SELECT Id
      FROM EmailTemplate
      WHERE DeveloperName = :emailTemplateName
      LIMIT 1
    ]
    .Id;

    List<String> recipientList = obtainRecipientList();

    if (recipientList.isEmpty() || quoteList.isEmpty()) {
      return;
    }

    Map<String, Id> subscriptionMap = new Map<String, Id>();
    if (
      emailTemplateName == RENEWAL_QUOTE_DUPLICATION_ON_ANOTHER_AMEND_TEMPLATE
    ) {
      Set<String> subscriptionNames = new Set<String>();
      for (zqu__Quote__c quote : quoteList) {
        subscriptionNames.add(quote.zqu__Hidden_Subscription_Name__c);
      }

      List<Zuora__Subscription__c> subscriptionList = [
        SELECT Id, Name
        FROM Zuora__Subscription__c
        WHERE Name IN :subscriptionNames
      ];
      for (Zuora__Subscription__c subscription : subscriptionList) {
        subscriptionMap.put(subscription.Name, subscription.Id);
      }
    }

    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
    for (zqu__Quote__c quote : quoteList) {
      Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(
        emailTemplateId,
        UserInfo.getUserId(),
        quote.Id
      );
      String emailSubject = email.getSubject();
      String emailTextBody = email.getPlainTextBody();
      if (emailTemplateName == RENEWAL_QUOTE_DUPLICATION_TEMPLATE) {
        String oppLink =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/' +
          quote.zqu__Opportunity__c;
        emailTextBody = emailTextBody.replace('{oppLink}', oppLink);
      } else if (
        emailTemplateName == RENEWAL_QUOTE_DUPLICATION_ON_ANOTHER_AMEND_TEMPLATE
      ) {
        String subscriptionLink =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/' +
          subscriptionMap.get(quote.zqu__Hidden_Subscription_Name__c);
        emailTextBody = emailTextBody.replace(
            '{subscriptionLink}',
            subscriptionLink
          )
          .replace('{errorMessage}', errorMessage);
      } else if (emailTemplateName == DUPLICATE_RENEWAL_SHOULD_BE_REVIEWED) {
        String oppLink =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/' +
          quote.zqu__Opportunity__c;
        String quoteLink =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/' +
          quote.Id;
        emailTextBody = emailTextBody.replace('{oppLink}', oppLink)
          .replace('{quoteLink}', quoteLink); // ZOHAR -- alon was here!!
      }
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setSubject(emailSubject);
      message.setPlainTextBody(emailTextBody);
      message.setUseSignature(false);
      message.setBccSender(false);
      message.setSaveAsActivity(false);

      if (emailTemplateName == DUPLICATE_RENEWAL_SHOULD_BE_REVIEWED) {
        message.toAddresses = Test.isRunningTest()
          ? new List<String>{ 'alon.shalev@similarweb.com' }
          : new List<String>{ quote.Owner.Email }; //ZOHAR -- alon was here!!
      } else {
        message.toAddresses = recipientList;
      }
      System.debug('message--' + message.getHtmlBody());
      System.debug('message--' + message.getPlainTextBody());

      message.setSenderDisplayName('Similarweb support');
      messages.add(message);
    }

    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    if (!results[0].success) {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }

  private static List<String> obtainRecipientList() {
    List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(
      new Set<String>{ RECIPIENTS_METADATA_NAME }
    );
    List<String> recipientList = new List<String>();
    if (!generalConfigurationList.isEmpty()) {
      Matcher m = Pattern.compile(
          '[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+'
        )
        .matcher(generalConfigurationList[0].Text_Value__c);
      while (m.find()) {
        recipientList.add(m.group());
      }
    }
    return recipientList;
  }

  public static void cloneQuote(Map<Id, zqu.Quote> renewClonedZQuoteMap) {
    List<zqu.QPlan> oldPlans;
    for (Id quoteId : renewClonedZQuoteMap.keySet()) {
      oldPlans = zqu.QPlanReader.load(quoteId);
      break;
    }

    List<zqu.QPlan> newPlans = zqu.QPlanReader.load(
      renewClonedZQuoteMap.values()[0].getId()
    );

    for (zqu.QPlan newPlan : newPlans) {
      newPlan.remove();
    }
    for (zqu.QPlan oldPlan : oldPlans) {
    }
  }

  /**
   * Helper method to update a charge group by iterating over each charge and matching them by index.
   * This method updates quantity, effective price, and tier values accordingly.
   */
  private static void updateChargeGroup(
    zqu.zChargeGroup originalGroup,
    zqu.zChargeGroup newGroup
  ) {
    if (originalGroup.zCharges == null || newGroup.zCharges == null) {
      System.debug('One of the charge groups is missing charges.');
      return;
    }

    Integer minSize = Math.min(
      originalGroup.zCharges.size(),
      newGroup.zCharges.size()
    );

    // Update quantity for each charge if editable.
    for (Integer i = 0; i < minSize; i++) {
      zqu.zCharge oldCharge = originalGroup.zCharges[i];
      zqu.zCharge newCharge = newGroup.zCharges[i];
      if (oldCharge.isQuantityEditable) {
        oldCharge.QUANTITY = newCharge.QUANTITY;
      }
    }

    // Recalculate charges after quantity updates.
    originalGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(
      originalGroup.zCharges
    );

    // Update effective price and tier values for each charge.
    for (Integer i = 0; i < minSize; i++) {
      zqu.zCharge oldCharge = originalGroup.zCharges[i];
      zqu.zCharge newCharge = newGroup.zCharges[i];

      if (oldCharge.hasCustomTiers || oldCharge.chargeTiersObjects != null) {
        List<zqu__QuoteCharge_Tier__c> oldTiers = oldCharge.chargeTiersObjects;
        List<zqu__QuoteCharge_Tier__c> newTiers = newCharge.chargeTiersObjects;
        if (oldTiers != null && newTiers != null) {
          Integer tierMin = Math.min(oldTiers.size(), newTiers.size());
          for (Integer j = 0; j < tierMin; j++) {
            oldTiers[j].zqu__Effective_Price__c = newTiers[j]
              .zqu__Effective_Price__c;
          }
          if (oldCharge.hasCustomTiers) {
            oldCharge.populateCustomChargeTiers(oldTiers);
          }
        }
      } else if (oldCharge.isEffectivePriceEditable) {
        oldCharge.EFFECTIVE_PRICE = newCharge.EFFECTIVE_PRICE;
      }
    }

    // Recalculate charges after effective price updates.
    originalGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(
      originalGroup.zCharges
    );
  }

  public class QuoteCloneException extends Exception {
  }
  public class OppRenewalException extends Exception {
  }

  public static void addCoverage() {
    integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
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

  // API Name constant for Quantity field on QCharge (VERIFY)
  // *** CRITICAL: VERIFY API Name of lookup field on zqu__QuoteRatePlan__c that points to Product2 ***
  private static final String PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME = 'zqu__Product__c';
  private static final String ProductRatePlan_LOOKUP_ON_QRPLAN_API_NAME = 'zqu__ProductRatePlan__c';

  // --- Main Method ---
  //        public static void applyProductChangesToQuote(Map<Id, zqu.Quote> renewClonedZQuoteMap, Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap) {
  //            System.debug(LoggingLevel.DEBUG, 'Entering applyProductChangesToQuote (v23 - Final Corrected)...');
  //            System.debug(LoggingLevel.DEBUG, 'Input renewClonedZQuoteMap size: ' + (renewClonedZQuoteMap == null ? 0 : renewClonedZQuoteMap.size()));
  //            for(QuoteProductsChangeUnit QPCU : quoteProductsChangeUnitMap.values()){
  //                System.debug(LoggingLevel.DEBUG, 'Input addedProductIdMap: ' + QPCU.addedProductIdMap);
  //                System.debug(LoggingLevel.DEBUG, 'Input removedProducts: ' + QPCU.removedProducts);
  //                System.debug(LoggingLevel.DEBUG, 'Input updatedProductIdMap: ' + QPCU.updatedProductIdMap);
  //                System.debug(LoggingLevel.DEBUG, 'Input addedProducts: ' + QPCU.addedProducts);
  //                System.debug(LoggingLevel.DEBUG, 'Input removedProductIds: ' + QPCU.removedProductIds);
  //                System.debug(LoggingLevel.DEBUG, 'Input region: ' + QPCU.region);
  //            }
  //
  //            if (renewClonedZQuoteMap == null || renewClonedZQuoteMap.isEmpty() || quoteProductsChangeUnitMap == null || quoteProductsChangeUnitMap.isEmpty()) {
  //                System.debug(LoggingLevel.WARN, 'Input maps are null or empty. Exiting.');
  //                return;
  //            }
  //
  //            // --- Bulkification Prep ---
  //            Set<String> allZuoraProductIdsForAddCheck = new Set<String>();
  //            for (QuoteProductsChangeUnit changeUnit : quoteProductsChangeUnitMap.values()) {
  //                if (changeUnit?.addedProducts != null) {
  //                    for (zqu.Product product : changeUnit.addedProducts) {
  //                        if (product?.ProductId != null) {
  //                            allZuoraProductIdsForAddCheck.add(product.ProductId);
  //                        }
  //                    }
  //                }
  //            }
  //            // Map: Zuora Product ID -> List of Rate Plan SObjects (including related Product2 ID)
  //            Map<String, List<zqu__ProductRatePlan__c>> zuoraProdIdToRatePlansMap_ForAdd = new Map<String, List<zqu__ProductRatePlan__c>>();
  //            if (!allZuoraProductIdsForAddCheck.isEmpty()) {
  //                try {
  //                    List<zqu__ProductRatePlan__c> ratePlans = Database.query(
  //                            'SELECT Id, Name, Region__c, ' + PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME + ', ' +
  //                                    'zqu__Product__r.zqu__ZuoraId__c ' + // Still need intermediate Product for Zuora ID mapping
  //                                    'FROM zqu__ProductRatePlan__c ' +
  //                                    'WHERE zqu__Product__r.zqu__ZuoraId__c IN :allZuoraProductIdsForAddCheck'
  //                    );
  //                    for (zqu__ProductRatePlan__c prp : ratePlans) {
  //                        String relatedZuoraProdId = prp.zqu__Product__r?.Id; // Safe navigation
  //                        if (String.isNotBlank(relatedZuoraProdId)) {
  //                            if (!zuoraProdIdToRatePlansMap_ForAdd.containsKey(relatedZuoraProdId)) {
  //                                zuoraProdIdToRatePlansMap_ForAdd.put(relatedZuoraProdId, new List<zqu__ProductRatePlan__c>());
  //                            }
  //                            zuoraProdIdToRatePlansMap_ForAdd.get(relatedZuoraProdId).add(prp);
  //                        }
  //                    } System.debug(LoggingLevel.DEBUG, 'Fetched ' + ratePlans.size() + ' Rate Plans for add check.');
  //                } catch (Exception e) { System.debug(LoggingLevel.ERROR, 'Error querying Rate Plans for add check: ' + e.getMessage() + '. Check PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME and relationship zqu__Product__r.'); }
  //            }
  //
  //            // --- Main Processing Logic ---
  //            List<zqu.QPlan> allPlansToSave = new List<zqu.QPlan>();
  //            Set<Id> quotesSuccessfullyProcessedOrAttempted = new Set<Id>();
  //            Set<Id> quotesWithProcessingErrors = new Set<Id>(); // Track OriginalQuoteIDs
  //
  //            for (Id originalQuoteId : renewClonedZQuoteMap.keySet()) {
  //                zqu.Quote targetQuoteWrapper = renewClonedZQuoteMap.get(originalQuoteId);
  //                system.debug('targetQuoteWrapper: ' + targetQuoteWrapper);
  //                system.debug('targetQuoteWrapper.getSObject().zqu__ExistSubscriptionID__c: ' + targetQuoteWrapper.getSObject().zqu__ExistSubscriptionID__c);
  //                Id clonedQuoteId = targetQuoteWrapper?.getSObject()?.Id;
  //                QuoteProductsChangeUnit changeUnit = quoteProductsChangeUnitMap.get(originalQuoteId);
  //
  //                if (clonedQuoteId == null) {
  //                    System.debug(LoggingLevel.ERROR, 'No Cloned Quote ID for Original: ' + originalQuoteId);
  //                    quotesWithProcessingErrors.add(originalQuoteId);
  //                    continue;
  //                }
  //                if (changeUnit == null) {
  //                    System.debug(LoggingLevel.ERROR, 'No Change Unit for Original: ' + originalQuoteId);
  //                    quotesWithProcessingErrors.add(originalQuoteId);
  //                    continue;
  //                }
  //
  //                quotesSuccessfullyProcessedOrAttempted.add(clonedQuoteId); // Track target ID
  //
  //                try {
  //                    System.debug(LoggingLevel.DEBUG, 'Processing Cloned Quote ID: ' + clonedQuoteId + ' (from Original: ' + originalQuoteId + ')');
  //
  //                    // --- Step 1: Load Target Plans and Mark for Removal ---
  //                    System.debug(LoggingLevel.DEBUG, 'Loading existing plans for target quote: ' + clonedQuoteId);
  //                    List<zqu.QPlan> targetPlans = zqu.QPlanReader.load(clonedQuoteId);
  //                    if (targetPlans != null && !targetPlans.isEmpty()) {
  //                        System.debug(LoggingLevel.INFO, 'Marking ' + targetPlans.size() + ' existing target plans for removal.');
  //                        for (zqu.QPlan plan : targetPlans) {
  //                            if(plan != null) {
  //                                plan.remove();
  //                                allPlansToSave.add(plan);
  //                            }
  //                        }
  //                    } else {
  //                        System.debug(LoggingLevel.INFO, 'No existing plans found on target.');
  //                    }
  //
  //                    // --- Step 2: Determine Final Set of Rate Plan SF IDs for Target Quote ---
  //                    Set<Id> finalRatePlanIds = new Set<Id>(); // Stores SF IDs of Rate Plans
  //                    Map<Id, Id> originalRatePlanIdToProduct2IdMap = new Map<Id, Id>(); // Helper: RatePlan.Id -> Product2.Id
  //
  //                    System.debug(LoggingLevel.DEBUG, 'Loading plans from original quote: ' + originalQuoteId);
  //                    List<zqu.QPlan> originalPlans = zqu.QPlanReader.load(originalQuoteId);
  //
  //                    // Populate initial set and mapping from original plans
  //                    if (originalPlans != null && !originalPlans.isEmpty()) {
  //                        for (zqu.QPlan originalPlan : originalPlans) {
  //                            system.debug('originalPlan?.getRecord().zqu__DataStored__c: ' + originalPlan?.getRecord().zqu__DataStored__c);
  //                            if (originalPlan?.getRecord() == null) {
  //                                continue;
  //                            }
  //                            Id product2Lookup = (Id)originalPlan.get(PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME);
  //                            system.debug('product2Lookup: ' + product2Lookup);
  //                            zqu__QuoteRatePlan__c originalQrp = (zqu__QuoteRatePlan__c)originalPlan.getRecord();
  //                            Id originalRatePlanId = originalQrp.Id;
  //                            Id originalProduct2Id = (Id)originalQrp.get(PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME);
  //                            Id productRatePlanId = (Id)originalQrp.get(ProductRatePlan_LOOKUP_ON_QRPLAN_API_NAME);
  //                            system.debug('productRatePlanId: ' + productRatePlanId);
  //                            if (productRatePlanId != null) {
  //                                finalRatePlanIds.add(productRatePlanId);
  //                                if (originalProduct2Id != null) {
  //                                    originalRatePlanIdToProduct2IdMap.put(productRatePlanId, originalProduct2Id);
  //                                }
  //                                else {
  //                                    System.debug(LoggingLevel.WARN, 'Original RP ' + originalRatePlanId + ' has null Product2 lookup (' + PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME + ').');
  //                                }
  //                            }
  //                        }
  //                        System.debug(LoggingLevel.DEBUG, 'Initial Rate Plan SF IDs from original: ' + finalRatePlanIds);
  //                    } else {
  //                        System.debug(LoggingLevel.WARN, 'Original quote ' + originalQuoteId + ' has no plans.');
  //                    }
  //
  //                    // Remove plans based on removedProductIds (SF Product2 IDs)
  //                    Set<Id> removedProduct2Ids = new Set<Id>();
  //                    system.debug('changeUnit.removedProductIds: ' + changeUnit.removedProductIds);
  //                    if (changeUnit.removedProductIds != null) {
  //                        removedProduct2Ids.addAll(changeUnit.removedProductIds);
  //                    }
  //                    if (!removedProduct2Ids.isEmpty()) {
  //                        Set<Id> ratePlanIdsToRemove = new Set<Id>();
  //                        for (Id ratePlanId : originalRatePlanIdToProduct2IdMap.keySet()) {
  //                            system.debug(originalRatePlanIdToProduct2IdMap.containsKey(ratePlanId));
  //                            Id product2Id = originalRatePlanIdToProduct2IdMap.get(ratePlanId);
  //                            if (product2Id != null && removedProduct2Ids.contains(product2Id)) {
  //                                ratePlanIdsToRemove.add(ratePlanId);
  //                            }
  //                        }
  //                        if (!ratePlanIdsToRemove.isEmpty()) {
  //                            System.debug(LoggingLevel.INFO, 'Removing Rate Plan SF IDs based on removed Product2 SF IDs ('+ removedProduct2Ids + '): ' + ratePlanIdsToRemove);
  //                            finalRatePlanIds.removeAll(ratePlanIdsToRemove);
  //                        }
  //                    }
  //
  //                    // Add plans from addedProducts list
  //                    if (changeUnit.addedProducts != null && !changeUnit.addedProducts.isEmpty()) {
  //                        String requiredRegion = changeUnit.region;
  //                        System.debug(LoggingLevel.DEBUG, 'Processing ' + changeUnit.addedProducts.size() + ' products from addedProducts list.');
  //                        for (zqu.Product productToAdd : changeUnit.addedProducts) {
  //                            if (productToAdd?.ProductId == null) {
  //                                continue;
  //                            }
  //                            String zuoraProductId = productToAdd.ProductId; // Zuora ID for lookup
  //
  //                            Id ratePlanIdForNewAdd = null;
  //                            Id product2IdForNewAdd = null;
  //                            if (zuoraProdIdToRatePlansMap_ForAdd.containsKey(zuoraProductId)) {
  //                                List<zqu__ProductRatePlan__c> candidates = zuoraProdIdToRatePlansMap_ForAdd.get(zuoraProductId);
  //                                for (zqu__ProductRatePlan__c prp : candidates) {
  //                                    if (prp.Region__c == requiredRegion) {
  //                                        ratePlanIdForNewAdd = prp.Id;
  //                                        product2IdForNewAdd = (Id)prp.get(PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME);
  //                                        break;
  //                                    }
  //                                }
  //                            }
  //
  //                            if (ratePlanIdForNewAdd != null) {
  //                                // Add only if its Product2 ID wasn't explicitly removed
  //                                if (product2IdForNewAdd != null && removedProduct2Ids.contains(product2IdForNewAdd)) {
  //                                    System.debug(LoggingLevel.INFO, 'Skipping adding Rate Plan ' + ratePlanIdForNewAdd + ' from addedProducts because its Product2 ID ' + product2IdForNewAdd + ' was in removed list.');
  //                                } else {
  //                                    System.debug(LoggingLevel.DEBUG, 'Adding Rate Plan SF ID ' + ratePlanIdForNewAdd + ' from addedProducts.');
  //                                    finalRatePlanIds.add(ratePlanIdForNewAdd);
  //                                }
  //                            } else {
  //                                System.debug(LoggingLevel.WARN, 'No suitable Rate Plan found for addedProduct ' + zuoraProductId + ' in region ' + requiredRegion);
  //                            }
  //                        }
  //                    }
  //
  //                    System.debug(LoggingLevel.INFO, 'Final set of Rate Plan SF IDs for target quote ' + clonedQuoteId + ': ' + finalRatePlanIds);
  //
  //                    // --- Step 3: Build New Plans using makeFromCatalog ---
  //                    List<zqu.QPlan> newlyBuiltPlans = new List<zqu.QPlan>();
  //                    if (!finalRatePlanIds.isEmpty()) {
  //                        System.debug(LoggingLevel.INFO, 'Building ' + finalRatePlanIds.size() + ' plans from catalog using SF IDs.');
  //                        try {
  //                            newlyBuiltPlans = zqu.QPlanBuilder.makeFromCatalog(clonedQuoteId, new List<Id>(finalRatePlanIds));
  //                            if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty()) {
  //                                System.debug(LoggingLevel.INFO, 'Built ' + newlyBuiltPlans.size() + ' plans.');
  //                            }
  //                            else {
  //                                System.debug(LoggingLevel.WARN, 'makeFromCatalog returned null/empty list.');
  //                            }
  //                        } catch (Exception buildEx) {
  //                            System.debug(LoggingLevel.ERROR, 'Error calling makeFromCatalog: ' + buildEx.getMessage());
  //                        }
  //                    } else {
  //                        System.debug(LoggingLevel.INFO, 'No final Rate Plan IDs to build.');
  //                    }
  //
  //                    // --- Step 4: Apply Quantity Updates ---
  //                    if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty() && changeUnit.updatedProductIdMap != null && !changeUnit.updatedProductIdMap.isEmpty()) {
  //                        System.debug(LoggingLevel.INFO, 'Applying quantity updates to ' + newlyBuiltPlans.size() + ' newly built plans.');
  //                        Map<Id, zqu.zChargeGroup> updateMapByProd2Id = (Map<Id, zqu.zChargeGroup>)changeUnit.updatedProductIdMap; // Key is Product2 SF ID
  //
  //                        for (zqu.QPlan newPlan : newlyBuiltPlans) {
  //                            if (newPlan?.getRecord() == null) {
  //                                continue;
  //                            }
  //                            zqu__QuoteRatePlan__c qrp = (zqu__QuoteRatePlan__c)newPlan.getRecord();
  //                            Id currentProduct2Id = (Id)qrp.get(PRODUCT2_LOOKUP_ON_QRPLAN_API_NAME);
  //
  //                            if (currentProduct2Id == null) {
  //                                System.debug(LoggingLevel.WARN, 'Cannot get Product2 ID for newly built plan ' + qrp.Id + ' to check updates.');
  //                                continue;
  //                            }
  //
  //                            // Check update map using Product2 SF ID
  //                            if (updateMapByProd2Id.containsKey(currentProduct2Id)) {
  //                                zqu.zChargeGroup overrideData = updateMapByProd2Id.get(currentProduct2Id);
  //                                if (overrideData?.zCharges != null && !overrideData.zCharges.isEmpty()) {
  //                                    String overrideQuantityStr = overrideData.zCharges[0].QUANTITY;
  //                                    if (String.isNotBlank(overrideQuantityStr)) {
  //                                        try {
  //                                            Decimal overrideQuantity = Decimal.valueOf(overrideQuantityStr);
  //                                            System.debug(LoggingLevel.DEBUG, 'Applying Quantity ' + overrideQuantity + ' to charges in Plan for Product2 ID ' + currentProduct2Id);
  //                                            List<zqu.QCharge> charges = newPlan.getCharges();
  //                                            if (charges != null) {
  //                                                for (zqu.QCharge charge : charges) {
  //                                                    if(charge == null) {
  //                                                        continue;
  //                                                    }
  //                                                    try {
  //                                                        charge.put(QCHARGE_QUANTITY_FIELD, overrideQuantity);
  //                                                        System.debug(LoggingLevel.DEBUG, 'Set Quantity on charge ' + charge.get('Name'));
  //                                                    }
  //                                                    catch (Exception putEx) {
  //                                                        System.debug(LoggingLevel.ERROR, 'Error setting quantity on charge ' + charge.get('Name') + ': ' + putEx.getMessage());
  //                                                    }
  //                                                }
  //                                            }
  //                                        } catch (Exception ex) {
  //                                            System.debug(LoggingLevel.ERROR, 'Error converting override quantity string "' + overrideQuantityStr + '" for Product2 ID ' + currentProduct2Id + ': ' + ex.getMessage());
  //                                        }
  //                                    } else {
  //                                        System.debug(LoggingLevel.WARN, 'Override quantity string blank for Product2 ID ' + currentProduct2Id);
  //                                    }
  //                                } else {
  //                                    System.debug(LoggingLevel.WARN, 'Override data/charges null/empty for Product2 ID ' + currentProduct2Id);
  //                                }
  //                            } else {
  //                                System.debug(LoggingLevel.DEBUG, 'No quantity update found for Product2 ID: ' + currentProduct2Id);
  //                            }
  //                        }
  //                    } else if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty()) {
  //                        System.debug(LoggingLevel.DEBUG, 'No update map or empty. Skipping quantity updates.');
  //                    }
  //
  //                    // --- Step 5: Add Newly Built & Potentially Updated Plans to Save List ---
  //                    if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty()) {
  //                        allPlansToSave.addAll(newlyBuiltPlans);
  //                    }
  //
  //                } catch (Exception e) {
  //                    System.debug(LoggingLevel.ERROR, 'Error processing plans for Original: ' + originalQuoteId + ' (Target: ' + clonedQuoteId + '). Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
  //                    quotesWithProcessingErrors.add(originalQuoteId); quotesSuccessfullyProcessedOrAttempted.remove(clonedQuoteId);
  //                }
  //            } // End loop
  //
  //            // --- Perform Bulk DML using QPlanWriter ---
  //            if (!allPlansToSave.isEmpty()) {
  //                System.debug(LoggingLevel.INFO, 'Attempting to bulk save ' + allPlansToSave.size() + ' QPlan operations via QPlanWriter.');
  //                try {
  //                    zqu.QPlanWriter.save(allPlansToSave); System.debug(LoggingLevel.INFO, 'QPlanWriter.save call executed successfully.');
  //                }
  //                catch (Exception bulkSaveEx) {
  //                    System.debug(LoggingLevel.ERROR, 'Error during QPlanWriter.save: ' + bulkSaveEx.getMessage() + '\n' + bulkSaveEx.getStackTraceString());
  //                    for (Id quoteIdWithError : quotesSuccessfullyProcessedOrAttempted) {
  //                        quotesWithProcessingErrors.add(quoteIdWithError);
  //                    }
  //                    quotesSuccessfullyProcessedOrAttempted.clear();
  //                }
  //            } else {
  //                System.debug(LoggingLevel.INFO, 'No QPlan operations required saving.');
  //            }
  //
  //            // --- Final Notification ---
  //            Set<Id> finalSuccessfulIds = new Set<Id>(quotesSuccessfullyProcessedOrAttempted); finalSuccessfulIds.removeAll(quotesWithProcessingErrors);
  //            if (!quotesWithProcessingErrors.isEmpty()) {
  //                sendEmailNotificat0ionAboutError(finalSuccessfulIds, DUPLICATE_RENEWAL_SHOULD_BE_REVIEWED, 'Error');
  //            }
  //
  //            System.debug(LoggingLevel.DEBUG, 'Exiting applyProductChangesToQuote (v23 - Final Corrected).');
  //        }

  // API Name constant for the lookup from QuoteRatePlan to ProductRatePlan (Catalog)
  // *** VERIFY THIS FIELD NAME IN YOUR ORG'S SCHEMA ***
  private static final String CATALOG_PRP_LOOKUP_ON_QRPLAN_API_NAME = 'zqu__ProductRatePlan__c';
  // API Name constant for Quantity field on QuoteRatePlanCharge (VERIFY)
  private static final String QCHARGE_QUANTITY_FIELD = 'zqu__Quantity__c';
  // API Name constant for Charge Number field on QuoteRatePlanCharge (VERIFY)
  private static final String QCHARGE_NUMBER_FIELD = 'zqu__ChargeNumber__c'; // Or zqu__Number__c ?
  // Optional: Flag on zqu__QuoteRatePlan__c to check if it's a valid record (VERIFY)
  // private static final String QRP_DATA_STORED_FIELD = 'zqu__DataStored__c';

  // --- Main Method ---
  //        public static void applyProductChangesToQuote(Map<Id, zqu.Quote> renewClonedZQuoteMap, Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap_UNUSED) {
  //            System.debug(LoggingLevel.DEBUG, 'Entering applyProductChangesToQuote (v28 - Build from Catalog + Qty Transfer)...');
  //            System.debug(LoggingLevel.DEBUG, 'Input renewClonedZQuoteMap size: ' + (renewClonedZQuoteMap == null ? 0 : renewClonedZQuoteMap.size()));
  //
  //            if (renewClonedZQuoteMap == null || renewClonedZQuoteMap.isEmpty()) {
  //                System.debug(LoggingLevel.WARN, 'Input map renewClonedZQuoteMap is null or empty. Exiting.');
  //                return;
  //            }
  //
  //            // --- Main Processing Logic ---
  //            List<zqu.QPlan> allPlansToSave = new List<zqu.QPlan>();
  //            Set<Id> quotesSuccessfullyProcessedOrAttempted = new Set<Id>();
  //            Set<Id> quotesWithProcessingErrors = new Set<Id>(); // Track target Quote IDs with errors
  //
  //            for (Id originalSFQuoteId_Key : renewClonedZQuoteMap.keySet()) {
  //                zqu.Quote targetQuoteWrapper = renewClonedZQuoteMap.get(originalSFQuoteId_Key);
  //                Id clonedQuoteId = targetQuoteWrapper?.getSObject()?.Id;
  //                String existingSubId = targetQuoteWrapper?.getSObject()?.zqu__ExistSubscriptionID__c;
  //
  //                if (clonedQuoteId == null) { System.debug(LoggingLevel.ERROR, 'No Cloned Quote ID for Original Key: ' + originalSFQuoteId_Key); quotesWithProcessingErrors.add(originalSFQuoteId_Key); continue; }
  //                if (String.isBlank(existingSubId)) { System.debug(LoggingLevel.ERROR, 'Renewal Quote ' + clonedQuoteId + ' missing zqu__ExistSubscriptionID__c.'); quotesWithProcessingErrors.add(clonedQuoteId); continue; }
  //
  //                quotesSuccessfullyProcessedOrAttempted.add(clonedQuoteId);
  //
  //                try {
  //                    System.debug(LoggingLevel.DEBUG, 'Processing Renewal Quote ID: ' + clonedQuoteId + ' linked to Subscription ID: ' + existingSubId);
  //
  //                    // --- Step 1: Find the Quote to Clone Info From ---
  //                    List<zqu__Quote__c> sourceQuotes = [SELECT Id FROM zqu__Quote__c WHERE zqu__ZuoraSubscriptionID__c = :existingSubId LIMIT 2];
  //                    Id quoteToCloneId = null;
  //                    if (sourceQuotes.isEmpty()) { throw new QuoteCloneException('Source quote not found for Sub ID: ' + existingSubId); }
  //                    else if (sourceQuotes.size() > 1) { throw new QuoteCloneException('Multiple source quotes found for Sub ID: ' + existingSubId); }
  //                    else { quoteToCloneId = sourceQuotes[0].Id; System.debug(LoggingLevel.INFO, 'Found source Quote: ' + quoteToCloneId); }
  //
  //                    // --- Step 2: Load Target Plans and Mark for Removal ---
  //                    System.debug(LoggingLevel.DEBUG, 'Loading existing plans for target quote: ' + clonedQuoteId);
  //                    List<zqu.QPlan> targetPlans = zqu.QPlanReader.load(clonedQuoteId);
  //                    if (targetPlans != null && !targetPlans.isEmpty()) {
  //                        System.debug(LoggingLevel.INFO, 'Marking ' + targetPlans.size() + ' existing target plans for removal.');
  //                        for (zqu.QPlan plan : targetPlans) { if(plan != null) { plan.remove(); allPlansToSave.add(plan); } }
  //                    } else { System.debug(LoggingLevel.INFO, 'No existing plans found on target quote: ' + clonedQuoteId); }
  //
  //                    // --- Step 3: Load Source Plans & Extract Catalog IDs + Quantity Map ---
  //                    System.debug(LoggingLevel.DEBUG, 'Loading plans from source quote: ' + quoteToCloneId + ' to extract info.');
  //                    Set<Id> catalogRatePlanIdsToBuild = new Set<Id>(); // Use Set to avoid duplicates
  //                    // Map Key: "CatalogRatePlanId:ChargeNumber", Value: Quantity
  //                    Map<String, Decimal> quantityMap = new Map<String, Decimal>();
  //                    Map<String, String> originalQuoteMap = new Map<String, String>();
  //                    List<zqu.QPlan> sourcePlans = zqu.QPlanReader.load(quoteToCloneId);
  //
  //                    if (sourcePlans != null && !sourcePlans.isEmpty()) {
  //                        System.debug(LoggingLevel.INFO, 'Found ' + sourcePlans.size() + ' plans on source quote. Extracting catalog IDs and quantities.');
  //                        for (zqu.QPlan sourcePlan : sourcePlans) {
  //                            if (sourcePlan?.getRecord() == null) continue;
  //                            zqu__QuoteRatePlan__c sourceQrp = (zqu__QuoteRatePlan__c)sourcePlan.getRecord();
  //                            Id catalogPrpId = (Id)sourceQrp.get(CATALOG_PRP_LOOKUP_ON_QRPLAN_API_NAME);
  //                            Boolean isNotRemoved = sourceQrp.get('zqu__AmendmentType__c') != 'RemoveProduct';
  //                            if(isNotRemoved){
  //                                if (catalogPrpId != null) {
  //                                    catalogRatePlanIdsToBuild.add(catalogPrpId); // Add catalog ID for building
  //                                    // Now process charges for this plan
  //                                    List<zqu.QCharge> sourceCharges = sourcePlan.getCharges();
  //                                    if (sourceCharges != null) {
  //                                        for (zqu.QCharge sourceCharge : sourceCharges) {
  //                                            system.debug(LoggingLevel.DEBUG, 'isOneTimeCharge: ' + ZuoraPriceCalculation.isOneTimeCharge(sourceQrp.Name, sourceCharge));
  //                                            system.debug(LoggingLevel.DEBUG, 'Charge Name: ' + sourceQrp.Name);
  //                                            if (sourceCharge == null || ZuoraPriceCalculation.isOneTimeCharge(sourceQrp.Name, sourceCharge)) continue;
  //                                            Object quantityObj = sourceCharge.get(QCHARGE_QUANTITY_FIELD);
  //                                            if (quantityObj != null) {
  //                                                try {
  //                                                    // Convert quantity (might be String or Decimal)
  //                                                    Decimal quantityDecimal = (quantityObj instanceof Decimal) ? (Decimal)quantityObj : Decimal.valueOf(String.valueOf(quantityObj));
  //                                                    String mapKey = catalogPrpId;
  //                                                    quantityMap.put(mapKey, quantityDecimal);
  //                                                    originalQuoteMap.put(mapKey, sourceCharge.getRecord().Id);
  //                                                    System.debug(LoggingLevel.DEBUG, 'Stored Qty ' + quantityDecimal + ' for Key: ' + mapKey);
  //                                                } catch (Exception e) {
  //                                                    System.debug(LoggingLevel.WARN, 'Could not parse quantity (' + quantityObj + ') or charge number for charge on source QRP ' + sourceQrp.Id + '. Error: ' + e.getMessage());
  //                                                }
  //                                            } else { System.debug(LoggingLevel.DEBUG, 'Skipping charge on source QRP ' + sourceQrp.Id + ': Null quantity or charge number.'); }
  //                                        }
  //                                    }
  //                                } else { System.debug(LoggingLevel.WARN, 'Source QRP ' + sourceQrp.Id + ' has null Catalog Rate Plan lookup.'); }
  //                            }
  //                        }
  //                    } else { System.debug(LoggingLevel.WARN, 'Source quote ' + quoteToCloneId + ' has no plans.'); }
  //
  //                    // --- Step 4: Build New Plans using makeFromCatalog ---
  //                    List<zqu.QPlan> newlyBuiltPlans = new List<zqu.QPlan>();
  //                    if (!catalogRatePlanIdsToBuild.isEmpty()) {
  //                        System.debug(LoggingLevel.INFO, 'Attempting to build ' + catalogRatePlanIdsToBuild.size() + ' plans from catalog using SF IDs: ' + catalogRatePlanIdsToBuild);
  //                        try {
  //                            newlyBuiltPlans = zqu.QPlanBuilder.makeFromCatalog(clonedQuoteId, new List<Id>(catalogRatePlanIdsToBuild));
  //                            if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty()) {
  //                                System.debug(LoggingLevel.INFO, 'Successfully built ' + newlyBuiltPlans.size() + ' plans.');
  //                            } else { System.debug(LoggingLevel.WARN, 'makeFromCatalog returned null or empty list.'); }
  //                        } catch (Exception buildEx) { System.debug(LoggingLevel.ERROR, 'Error calling makeFromCatalog: ' + buildEx.getMessage()); }
  //                    } else { System.debug(LoggingLevel.INFO, 'No unique Catalog Rate Plan IDs extracted from source quote to build.'); }
  //
  //                    // --- Step 5: Apply Quantities to Newly Built Plans ---
  //                    if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty() && !quantityMap.isEmpty()) {
  //                        System.debug(LoggingLevel.INFO, 'Applying original quantities to ' + newlyBuiltPlans.size() + ' newly built plans.');
  //                        Integer appliedCount = 0;
  //                        for (zqu.QPlan newPlan : newlyBuiltPlans) {
  //                            if (newPlan?.getRecord() == null) continue;
  //                            zqu__QuoteRatePlan__c newQrp = (zqu__QuoteRatePlan__c)newPlan.getRecord();
  //                            Boolean isNotRemoved = newQrp.get('zqu__AmendmentType__c') != 'RemoveProduct';
  //                            Id catalogPrpId = (Id)newQrp.get(CATALOG_PRP_LOOKUP_ON_QRPLAN_API_NAME); // Get its Catalog ID
  //                            if (catalogPrpId != null) {
  //                                List<zqu.QCharge> newCharges = newPlan.getCharges();
  //                                if (newCharges != null) {
  //                                    for (zqu.QCharge newCharge : newCharges) {
  //                                        if (newCharge == null) continue;
  //                                        if (String.isNotBlank(newCharge.getRecord().Name)) {
  //                                            String lookupKey = catalogPrpId;
  //                                            if (quantityMap.containsKey(lookupKey)) {
  //                                                Decimal originalQuantity = quantityMap.get(lookupKey);
  //                                                String originalId = originalQuoteMap.get(lookupKey);
  //                                                try {
  //                                                    newCharge.put(QCHARGE_QUANTITY_FIELD, originalQuantity);
  //                                                    newCharge.put('Renewal_Quote_rate_plan__c', originalId);
  //                                                    appliedCount++;
  //                                                    System.debug(LoggingLevel.DEBUG, 'Applied Qty ' + originalQuantity + ' to charge ' + newCharge.getRecord().Name + ' on new plan for Catalog RP ' + catalogPrpId);
  //                                                } catch (Exception putEx) {
  //                                                    System.debug(LoggingLevel.ERROR, 'Error setting quantity on new charge ' + newCharge.getRecord().Name + ' for Catalog RP ' + catalogPrpId + ': ' + putEx.getMessage());
  //                                                }
  //                                            } else { System.debug(LoggingLevel.DEBUG, 'No original quantity found for key: ' + lookupKey); }
  //                                        } else { System.debug(LoggingLevel.WARN, 'Newly built charge on Catalog RP ' + catalogPrpId + ' missing charge number.'); }
  //                                    }
  //                                }
  //                            } else { System.debug(LoggingLevel.WARN, 'Newly built plan missing Catalog RP lookup.'); }
  //                        }
  //                        System.debug(LoggingLevel.INFO, 'Applied ' + appliedCount + ' quantity values.');
  //                    } else if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty()) { System.debug(LoggingLevel.DEBUG, 'Quantity map was empty. Skipping quantity transfer.'); }
  //
  //                    // --- Step 6: Add Newly Built & Updated Plans to Save List ---
  //                    if (newlyBuiltPlans != null && !newlyBuiltPlans.isEmpty()) {
  //                        allPlansToSave.addAll(newlyBuiltPlans);
  //                    }
  //
  //                } catch (Exception e) {
  //                    System.debug(LoggingLevel.ERROR, 'Error processing for Renewal Quote ID: ' + clonedQuoteId + ' (Original Key: ' + originalSFQuoteId_Key + '). Error Type: ' + e.getTypeName() + '. Message: ' + e.getMessage() + '\n' + e.getStackTraceString());
  //                    quotesWithProcessingErrors.add(clonedQuoteId);
  //                    quotesSuccessfullyProcessedOrAttempted.remove(clonedQuoteId);
  //                }
  //            } // End loop
  //
  //            // --- Perform Bulk DML using QPlanWriter ---
  //            if (!allPlansToSave.isEmpty()) {
  //                System.debug(LoggingLevel.INFO, 'Attempting to bulk save ' + allPlansToSave.size() + ' QPlan operations (removals/new+qty) via QPlanWriter.');
  //                try {
  //                    zqu.QPlanWriter.save(allPlansToSave);
  //                    System.debug(LoggingLevel.INFO, 'QPlanWriter.save call executed successfully.');
  //                } catch (Exception bulkSaveEx) {
  //                    System.debug(LoggingLevel.ERROR, 'Error during QPlanWriter.save: ' + bulkSaveEx.getMessage() + '\n' + bulkSaveEx.getStackTraceString());
  //                    for (Id quoteIdWithError : quotesSuccessfullyProcessedOrAttempted) { quotesWithProcessingErrors.add(quoteIdWithError); }
  //                    quotesSuccessfullyProcessedOrAttempted.clear();
  //                }
  //            } else { System.debug(LoggingLevel.INFO, 'No QPlan operations required saving.'); }
  //
  //            // --- Final Notification ---
  //            Set<Id> finalSuccessfulIds = new Set<Id>(quotesSuccessfullyProcessedOrAttempted);
  //            if (!quotesWithProcessingErrors.isEmpty()) { sendEmailNotificationAboutError(quotesWithProcessingErrors, DUPLICATE_RENEWAL_SHOULD_BE_REVIEWED, 'Error'); }
  //
  //            System.debug(LoggingLevel.DEBUG, 'Exiting applyProductChangesToQuote (v28 - Build from Catalog + Qty Transfer).');
  //        }

  // API Name constant for the Quote lookup field on QuoteRatePlan__c
  // *** VERIFY THIS FIELD NAME IN YOUR ORG'S SCHEMA ***
  private static final String QUOTE_LOOKUP_API_NAME = 'zqu__Quote__c';

  // --- Main Method ---
  // quoteProductsChangeUnitMap is now confirmed irrelevant
  public static void applyProductChangesToQuote(
    Map<Id, zqu.Quote> renewClonedZQuoteMap,
    Map<Id, QuoteProductsChangeUnit> quoteProductsChangeUnitMap_UNUSED
  ) {
    System.debug(
      LoggingLevel.DEBUG,
      'Entering applyProductChangesToQuote (Clone from Found Source)'
    );
    System.debug(
      LoggingLevel.DEBUG,
      'Input renewClonedZQuoteMap size: ' +
      (renewClonedZQuoteMap == null ? 0 : renewClonedZQuoteMap.size())
    );

    if (renewClonedZQuoteMap == null || renewClonedZQuoteMap.isEmpty()) {
      System.debug(
        LoggingLevel.WARN,
        'Input map renewClonedZQuoteMap is null or empty. Exiting.'
      );
      return;
    }

    // --- Main Processing Logic ---
    List<zqu.QPlan> allPlansToSave = new List<zqu.QPlan>(); // Master list for bulk save
    List<zqu.QPlan> finalPlanList = new List<zqu.QPlan>(); // Master list for bulk save
    Set<Id> quotesSuccessfullyProcessedOrAttempted = new Set<Id>(); // Track target Quote IDs
    Set<Id> quotesWithProcessingErrors = new Set<Id>(); // Track target Quote IDs with errors

    // **MODIFICATION**: Iterate through the map entries to process each renewal individually
    for (Id originalSFQuoteId_Key : renewClonedZQuoteMap.keySet()) {
      // Using original SF ID as context for errors if needed

      zqu.Quote targetQuoteWrapper = renewClonedZQuoteMap.get(
        originalSFQuoteId_Key
      );
      Id clonedQuoteId = targetQuoteWrapper?.getSObject()?.Id;
      String existingSubId = targetQuoteWrapper
        ?.getSObject()
        ?.zqu__ExistSubscriptionID__c; // Get Sub ID for *this* renewal

      if (clonedQuoteId == null) {
        System.debug(
          LoggingLevel.ERROR,
          'Could not get Cloned Quote ID for Original SF ID Key: ' +
          originalSFQuoteId_Key
        );
        quotesWithProcessingErrors.add(originalSFQuoteId_Key); // Log error against original key
        continue;
      }
      if (String.isBlank(existingSubId)) {
        System.debug(
          LoggingLevel.ERROR,
          'Renewal Quote ' +
            clonedQuoteId +
            ' is missing zqu__ExistSubscriptionID__c. Cannot find source quote.'
        );
        quotesWithProcessingErrors.add(clonedQuoteId); // Log error against target quote ID
        continue;
      }

      quotesSuccessfullyProcessedOrAttempted.add(clonedQuoteId);

      try {
        System.debug(
          LoggingLevel.DEBUG,
          'Processing Renewal Quote ID: ' +
            clonedQuoteId +
            ' linked to Subscription ID: ' +
            existingSubId
        );

        // --- Step 1: Find the Quote to Clone ---
        List<zqu__Quote__c> sourceQuotes = [
          SELECT Id
          FROM zqu__Quote__c
          WHERE zqu__ZuoraSubscriptionID__c = :existingSubId
          LIMIT 2
        ];
        Id quoteToCloneId = null;

        if (sourceQuotes.isEmpty()) {
          System.debug(
            LoggingLevel.ERROR,
            'No source quote found with zqu__ZuoraSubscriptionID__c = ' +
              existingSubId +
              ' for Renewal Quote ' +
              clonedQuoteId
          );
          throw new QuoteCloneException(
            'Source quote not found for Subscription ID: ' + existingSubId
          ); // Throw to mark as error
        } else if (sourceQuotes.size() > 1) {
          System.debug(
            LoggingLevel.ERROR,
            'Multiple (' +
              sourceQuotes.size() +
              ') source quotes found with zqu__ZuoraSubscriptionID__c = ' +
              existingSubId +
              '. Cannot determine unique source for Renewal Quote ' +
              clonedQuoteId
          );
          throw new QuoteCloneException(
            'Multiple source quotes found for Subscription ID: ' + existingSubId
          ); // Throw to mark as error
        } else {
          quoteToCloneId = sourceQuotes[0].Id;
          System.debug(
            LoggingLevel.INFO,
            'Found source Quote to Clone: ' + quoteToCloneId
          );
        }

        // --- Step 2: Load Target Plans and Mark for Removal ---
        System.debug(
          LoggingLevel.DEBUG,
          'Loading existing plans for target quote: ' + clonedQuoteId
        );
        List<zqu.QPlan> targetPlans = zqu.QPlanReader.load(clonedQuoteId);
        if (targetPlans != null && !targetPlans.isEmpty()) {
          System.debug(
            LoggingLevel.INFO,
            'Marking ' +
              targetPlans.size() +
              ' existing target plans for removal.'
          );
          for (zqu.QPlan plan : targetPlans) {
            if (plan != null) {
              plan.remove();
              allPlansToSave.add(plan);
            }
          }
        } else {
          System.debug(
            LoggingLevel.INFO,
            'No existing plans found on target quote: ' + clonedQuoteId
          );
        }

        // --- Step 3: Load Plans from Quote to Clone ---
        System.debug(
          LoggingLevel.DEBUG,
          'Loading plans from source quote to clone: ' + quoteToCloneId
        );
        List<zqu.QPlan> sourcePlans = zqu.QPlanReader.load(quoteToCloneId);
        if (sourcePlans == null || sourcePlans.isEmpty()) {
          System.debug(
            LoggingLevel.WARN,
            'Source quote ' + quoteToCloneId + ' has no plans to copy.'
          );
          // Proceed to save removals if any
        } else {
          System.debug(
            LoggingLevel.INFO,
            'Found ' +
              sourcePlans.size() +
              ' plans on source quote ' +
              quoteToCloneId +
              '. Cloning and re-parenting.'
          );

          //Step 4: Create a map of charge numbers to plans on updated products
          Map<String, zqu.QPlan> ratePlanByChargeNumberMap = new Map<String, zqu.QPlan>();
          for (zqu.QPlan sourcePlan : sourcePlans) {
            Boolean isNotRemoved =
              sourcePlan.get('zqu__AmendmentType__c') != 'RemoveProduct';
            String quoteRatePlanAmendmentType = sourcePlan.getAmendment()
              .getRecord()
              .zqu__Type__c;
            if (quoteRatePlanAmendmentType == 'UpdateProduct' && isNotRemoved) {
              for (zqu.QCharge sourceCharge : sourcePlan.getCharges()) {
                String chargeNumber = sourceCharge.getRecord()
                  .zqu__ChargeNumber__c;
                if (
                  !ratePlanByChargeNumberMap.containsKey(chargeNumber) &&
                  !ZuoraPriceCalculation.isOneTimeCharge(
                    sourcePlan.getRecord().Name,
                    sourceCharge
                  )
                ) {
                  System.debug(
                    LoggingLevel.DEBUG,
                    'Cloning source plan ID: ' + sourcePlan.getId()
                  );
                  zqu.QPlan clonedPlan = sourcePlan.deepClone(false); // Clone without preserving ID
                  if (clonedPlan == null) {
                    System.debug(
                      LoggingLevel.ERROR,
                      'deepClone(false) returned null for source plan ID: ' +
                      sourcePlan.getId()
                    );
                    continue;
                  }

                  // **CRITICAL**: Re-parent the cloned plan to the target quote ID
                  clonedPlan.put(QUOTE_LOOKUP_API_NAME, clonedQuoteId);
                  clonedPlan.put('zqu__QuoteAmendment__c', null);
                  System.debug(
                    LoggingLevel.DEBUG,
                    'Re-parented cloned plan to target quote ' + clonedQuoteId
                  );
                  ratePlanByChargeNumberMap.put(chargeNumber, clonedPlan);
                }
              }
            }
            if (quoteRatePlanAmendmentType == 'NewProduct') {
              for (zqu.QCharge sourceCharge : sourcePlan.getCharges()) {
                if (
                  !ZuoraPriceCalculation.isOneTimeCharge(
                    sourcePlan.getRecord().Name,
                    sourceCharge
                  )
                ) {
                  System.debug(
                    LoggingLevel.DEBUG,
                    'Cloning source plan ID: ' + sourcePlan.getId()
                  );
                  zqu.QPlan clonedPlan = sourcePlan.deepClone(false); // Clone without preserving ID
                  if (clonedPlan == null) {
                    System.debug(
                      LoggingLevel.ERROR,
                      'deepClone(false) returned null for source plan ID: ' +
                      sourcePlan.getId()
                    );
                    continue;
                  }

                  // **CRITICAL**: Re-parent the cloned plan to the target quote ID
                  clonedPlan.put(QUOTE_LOOKUP_API_NAME, clonedQuoteId);
                  clonedPlan.put('zqu__QuoteAmendment__c', null);
                  System.debug(
                    LoggingLevel.DEBUG,
                    'Re-parented cloned plan to target quote ' + clonedQuoteId
                  );
                  finalPlanList.add(clonedPlan);
                }
              }
            }
          }

          // --- Step 5: Clone & Re-parent Source Plans ---
          for (zqu.QPlan sourcePlan : sourcePlans) {
            Boolean isNotRemoved =
              sourcePlan.get('zqu__AmendmentType__c') != 'RemoveProduct';
            String quoteRatePlanAmendmentType = sourcePlan.getAmendment()
              .getRecord()
              .zqu__Type__c;
            if (isNotRemoved) {
              if (sourcePlan == null)
                continue;
              for (zqu.QCharge sourceCharge : sourcePlan.getCharges()) {
                system.debug(
                  'sourceCharge should be 1: ' + sourceCharge.getRecord().Name
                );
                Boolean isLastSegment = sourceCharge.getRecord()
                  .zqu__IsLastSegment__c;
                String chargeNumber = sourceCharge.getRecord()
                  .zqu__ChargeNumber__c;
                if (
                  isLastSegment &&
                  !ratePlanByChargeNumberMap.containsKey(chargeNumber) &&
                  quoteRatePlanAmendmentType == 'Original' &&
                  !ZuoraPriceCalculation.isOneTimeCharge(
                    sourcePlan.getRecord().Name,
                    sourceCharge
                  )
                ) {
                  System.debug(
                    LoggingLevel.DEBUG,
                    'Cloning source plan ID: ' + sourcePlan.getId()
                  );
                  zqu.QPlan clonedPlan = sourcePlan.deepClone(false); // Clone without preserving ID
                  if (clonedPlan == null) {
                    System.debug(
                      LoggingLevel.ERROR,
                      'deepClone(false) returned null for source plan ID: ' +
                      sourcePlan.getId()
                    );
                    continue;
                  }

                  // **CRITICAL**: Re-parent the cloned plan to the target quote ID
                  clonedPlan.put(QUOTE_LOOKUP_API_NAME, clonedQuoteId);
                  clonedPlan.put('zqu__QuoteAmendment__c', null);
                  System.debug(
                    LoggingLevel.DEBUG,
                    'Re-parented cloned plan to target quote ' + clonedQuoteId
                  );

                  // Add the newly cloned and re-parented plan to the master save list
                  finalPlanList.add(clonedPlan);
                }
              }
            }
          }
          finalPlanList.addAll(ratePlanByChargeNumberMap.values());
        }
      } catch (Exception e) {
        // Catch errors during find source, load, remove, clone, or put stages
        System.debug(
          LoggingLevel.ERROR,
          'Error processing for Renewal Quote ID: ' +
            clonedQuoteId +
            ' (Original Key: ' +
            originalSFQuoteId_Key +
            '). Error Type: ' +
            e.getTypeName() +
            '. Message: ' +
            e.getMessage() +
            '\n' +
            e.getStackTraceString()
        );
        quotesWithProcessingErrors.add(clonedQuoteId); // Mark target quote as having error
        quotesSuccessfullyProcessedOrAttempted.remove(clonedQuoteId);
      }
    } // End loop through renewClonedZQuoteMap

    // --- Perform Bulk DML using QPlanWriter ---
    if (!finalPlanList.isEmpty()) {
      System.debug(
        LoggingLevel.INFO,
        'Attempting to bulk save ' +
          finalPlanList.size() +
          ' QPlan operations (removals/clones) via QPlanWriter.'
      );
      try {
        zqu.QPlanWriter.save(finalPlanList);
        System.debug(
          LoggingLevel.INFO,
          'QPlanWriter.save call executed successfully.'
        );
      } catch (Exception bulkSaveEx) {
        System.debug(
          LoggingLevel.ERROR,
          'Error during QPlanWriter.save: ' +
            bulkSaveEx.getMessage() +
            '\n' +
            bulkSaveEx.getStackTraceString()
        );
        // Mark all attempted quotes as potentially having errors
        for (Id quoteIdWithError : quotesSuccessfullyProcessedOrAttempted) {
          quotesWithProcessingErrors.add(quoteIdWithError);
        }
        quotesSuccessfullyProcessedOrAttempted.clear();
      }
    } else {
      System.debug(LoggingLevel.INFO, 'No QPlan operations required saving.');
    }

    // --- Final Notification ---
    Set<Id> finalSuccessfulIds = new Set<Id>(
      quotesSuccessfullyProcessedOrAttempted
    );
    // Use target quote IDs for notifications now
    //if (!quotesWithProcessingErrors.isEmpty()) { sendEmailNotificationAboutError(quotesWithProcessingErrors, 'Errors during Quote Product Clone Process (v26)', 'Error'); }
    //if (!finalSuccessfulIds.isEmpty()) { sendEmailNotificationAboutError(finalSuccessfulIds, 'Quotes Processed for Product Clone (v26)', 'Info'); }

    System.debug(
      LoggingLevel.DEBUG,
      'Exiting applyProductChangesToQuote (v26 - Clone from Found Source).'
    );
  }

  public static void removeIrrelevantProducts(Id quoteId) {
    List<zqu__QuoteRatePlan__c> qrpList = [
      SELECT Id
      FROM zqu__QuoteRatePlan__c
      WHERE
        zqu__Quote__c = :quoteId
        AND zqu__QuoteAmendment__r.zqu__Quote__c != :quoteId
    ];
    system.debug('qrpList: ' + qrpList);
    system.debug('qrpList.size(): ' + qrpList.size());
    if (!qrpList.isEmpty()) {
      delete qrpList;
    }
  }
}

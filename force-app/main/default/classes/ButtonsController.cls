public with sharing class ButtonsController {
  @AuraEnabled
  public static Response quoteInit(Id quoteId) {
    Response response;
    try {
      Map<String, Object> responseMap = new Map<String, Object>();
      Organization org = [SELECT InstanceName FROM Organization LIMIT 1];
      String zuoraVisualforcePageUrl =
        URL.getOrgDomainUrl().toExternalForm().split('\\.')[0] +
        '--zqu.' +
        org.InstanceName +
        '.visual.force.com';
      responseMap.put('zuoraVisualforcePageUrl', zuoraVisualforcePageUrl);
      responseMap.put(
        'isQuoteApprovalEnabled',
        Zuora_Quote_Approval_Settings__c.getOrgDefaults()
          .Enable_Approval_process_for_Quote__c
      );
      responseMap.put('isHitwiseAccount', false);
      responseMap.put('isARenewal7day', false);
      zqu__Quote__c quote = [
        SELECT
          Id,
          zqu__Account__c,
          zqu__Account__r.AccountSource,
          zqu__ZuoraAccountID__c,
          zqu__StartDate__c,
          Trial_Quote__c,
          Hitwise_Link__c,
          zqu__Previewed_Delta_MRR__c,
          zqu__Previewed_SubTotal__c,
          Customer_requests_to_pay_immediately__c,
          Sub_total__c,
          zqu__ZuoraSubscriptionID__c,
          zqu__Previewed_Total__c,
          Renewal_by_client_confirmation__c,
          zqu_Quote_Status__c,
          zqu__SubscriptionType__c,
          document_format__c,
          payment_frequency1__c,
          zqu__PaymentTerm__c,
          Irregular_Frequency__c,
          zqu__PaymentMethod__c,
          Link_to_SW_System__c,
          RecordTypeId,
          zqu__QuoteBusinessType__c,
          Is_from_existing_Billing_Account__c,
          Is_Contract_Signed_Manually__c,
          zqu__Previewed_Delta_TCV__c,
          Q2C_Green_Lane__c,
          Contacts_Product__c,
          Exception_Product__c,
          Is_Quote_Ready__c
        FROM zqu__Quote__c
        WHERE Id = :quoteId
      ];
      if (quote != null) {
        responseMap.put('quoteRecord', quote);
        List<Zuora__CustomerAccount__c> billAcc = [
          SELECT Id, Zuora__Balance__c
          FROM Zuora__CustomerAccount__c
          WHERE Zuora__External_Id__c = :quote.zqu__ZuoraAccountID__c
        ];
        List<Zuora__Subscription__c> zuoraSubscriptionList = [
          SELECT Id, Zuora__TermSettingType__c
          FROM Zuora__Subscription__c
          WHERE Zuora__External_Id__c = :quote.zqu__ZuoraSubscriptionID__c
          LIMIT 1
        ];
        if (billAcc != null && billAcc.size() > 0) {
          Boolean isBalanceZero = !zuoraSubscriptionList.isEmpty() &&
            zuoraSubscriptionList[0].Zuora__TermSettingType__c == 'EVERGREEN'
            ? (billAcc[0].Zuora__Balance__c == 0 &&
              quote.Sub_total__c == 0 &&
              quote.zqu__Previewed_Total__c == 0)
            : (billAcc[0].Zuora__Balance__c == 0 && quote.Sub_total__c == 0);
          responseMap.put('isBalanceZero', isBalanceZero);
        }
        //MQ-929
        // if(quote.zqu__Account__r!=null && quote.zqu__Account__r.AccountSource !=null && quote.zqu__Account__r.AccountSource.containsIgnoreCase('Hitwise')) {
        //     responseMap.put('isHitwiseAccount', true);
        // }

        if (
          quote.zqu__StartDate__c != null &&
          Date.today().daysBetween(quote.zqu__StartDate__c) >= 7 &&
          Date.today() < quote.zqu__StartDate__c
        ) {
          responseMap.put('isARenewal7day', true);
        }

        if (quote.Hitwise_Link__c != null) {
          responseMap.put('Hitwise_Link__c', quote.Hitwise_Link__c);
        }
        responseMap.put('isTrialQuote', quote.Trial_Quote__c); //  changed to a nicer version
        responseMap.put('isGreenLane', quote.Q2C_Green_Lane__c); //  changed to a nicer version
        responseMap.put('isContactsProduct', quote.Contacts_Product__c); //  changed to a nicer version
        responseMap.put('isExceptionalProduct', quote.Exception_Product__c); //  changed to a nicer version
        responseMap.put(
          'isCustomerRequestsToPayImmediately',
          quote.Customer_requests_to_pay_immediately__c
        ); //  changed to a nicer version
        responseMap.put(
          'isRenewalByClientConfirmation',
          quote.Renewal_by_client_confirmation__c
        ); //  changed to a nicer version
        responseMap.put('isQuoteReady', quote.Is_Quote_Ready__c); // alon addition 05.06.24
        System.debug('responseMap---' + responseMap.get('isQuoteReady'));

        if (
          ((quote.zqu__Previewed_Delta_MRR__c > 0.01 ||
          quote.zqu__Previewed_Delta_MRR__c < -0.01) &&
          quote.zqu__Previewed_Delta_MRR__c != null)
        ) {
          responseMap.put('isDeltaMrrOrSubGreaterThanZero', true);
        }
      }

      ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quoteId);
      if (!zqsc.checkIfReadOnly()) {
        String quoteStatus = zqsc.correctStatusIfWrong();
      }

      System.debug('zqsc.getCurrentListStep() ' + zqsc.getCurrentListStep());

      responseMap.put('stepList', zqsc.getCurrentListStep());

      Id profileId = userinfo.getProfileId();
      String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
      .Name;
      System.debug('profileName');
      responseMap.put(
        'isMsaSentToZuoraEnabled',
        profileName.equalsIgnoreCase('System Administrator') ||
          profileName.equalsIgnoreCase('SW Billing') ||
          profileName.equalsIgnoreCase('SW Billing Extended')
      );
      responseMap.put(
        'isLegalFlowEnabled',
        profileName.equalsIgnoreCase('System Administrator') ||
          profileName.equalsIgnoreCase('SW Billing') ||
          profileName.equalsIgnoreCase('SW Legal')
      );
      responseMap.put(
        'isNewAmendProfiles',
        profileName.equalsIgnoreCase('Similarweb Partner Community Profile') ||
          profileName.equalsIgnoreCase('Standard User') ||
          profileName.equalsIgnoreCase('SW Consultants') ||
          profileName.equalsIgnoreCase('SW CSM Internal') ||
          profileName.equalsIgnoreCase('SW Management') ||
          profileName.equalsIgnoreCase('SW Marketing') ||
          profileName.equalsIgnoreCase('SW Read Only (View all Data)') ||
          profileName.equalsIgnoreCase('SW Read Only (View all GTM Data)') ||
          profileName.equalsIgnoreCase('SW Sales External') ||
          profileName.equalsIgnoreCase('SW Sales Internal') ||
          profileName.equalsIgnoreCase('SW SDR') ||
          profileName.equalsIgnoreCase('SW Support') ||
          profileName.equalsIgnoreCase('SW View All') ||
          profileName.equalsIgnoreCase('SW Wolves') ||
          profileName.equalsIgnoreCase('View all Data')
      );
      responseMap.put(
        'isSalesOps',
        profileName.equalsIgnoreCase('SW SalesOps') ||
        profileName.equalsIgnoreCase('SW SalesOps Extended')
      );

      responseMap.put('isASproductExist', checkIfAsExist(quoteId));
      System.debug('responseMap ' + responseMap);
      System.debug('profileName ' + profileName);
      response = new Response(responseMap);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      System.debug(ex.getStackTraceString());
      response = new Response(ex.getMessage());
    }
    return response;
  }

  private static Boolean checkIfAsExist(String quoteId) {
    Boolean isASproductExist = false;
    Set<String> productNameSet = new Set<String>();

    List<zqu__QuoteRatePlanCharge__c> quoteRatePlanList = [
      SELECT id, zqu__ProductName__c, zqu__QuoteRatePlan__r.zqu__Quote__c
      FROM zqu__QuoteRatePlanCharge__c
      WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId
    ];

    for (zqu__QuoteRatePlanCharge__c quoteRatePlan : quoteRatePlanList) {
      productNameSet.add(quoteRatePlan.zqu__ProductName__c);
    }

    if (!productNameSet.isEmpty()) {
      List<Product2> productList = [
        SELECT Id, AS__c
        FROM Product2
        WHERE Name IN :productNameSet
      ];

      for (Product2 product2 : productList) {
        if (product2.AS__c == '1') {
          isASproductExist = true;
          break;
        }
      }
    }

    return isASproductExist;
  }

  @AuraEnabled
  public static AuraResponse assignSDR(String accountId) {
    AuraResponse auraResponse;
    if (!Test.isRunningTest()) {
      auraResponse = AuraButtonControlsHandler.redirectOnAccountReadyBusiness(
        'ManualReassignAcc',
        accountId
      );
    }
    return auraResponse;
  }
  @AuraEnabled
  public static AuraResponse assignSDRLeads(String accountId) {
    AuraResponse auraResponse;
    if (!Test.isRunningTest())
      auraResponse = AuraButtonControlsHandler.redirectOnLeadReadyBusiness(
        'ManualLeadReassignment',
        accountId
      );
    return auraResponse;
  }
  @AuraEnabled
  public static AuraResponse assignCSM(String accountId) {
    AuraResponse auraResponse;
    if (!Test.isRunningTest())
      auraResponse = AuraButtonControlsHandler.redirectOnAccountReadyBusiness(
        'ManualRoundRobinAccountSMBAM',
        accountId
      );
    return auraResponse;
  }
  @AuraEnabled
  public static AuraResponse assignSales(String accountId) {
    AuraResponse auraResponse;
    if (!Test.isRunningTest())
      auraResponse = AuraButtonControlsHandler.redirectOnAccountReadyBusiness(
        'ManualRoundRobinAccountSMB',
        accountId
      );
    return auraResponse;
  }
  @AuraEnabled
  public static AuraResponse finQuote(String QuoteId) {
    AuraResponse auraResponse;
    if (!Test.isRunningTest())
      auraResponse = AuraButtonControlsHandler.finalizeQuote(QuoteId);
    return auraResponse;
  }

  @AuraEnabled
  public static AuraResponse newQuoteServerSide(
    String oppId,
    Boolean forcePositive
  ) {
    AuraResponse auraResponse;
    if (!Test.isRunningTest())
      auraResponse = AuraButtonControlsHandler.newQuote(oppId, forcePositive);
    return auraResponse;
  }

  @AuraEnabled
  public static AuraResponse openModalServerSide(String oppId) {
    AuraResponse auraResponse;
    if (!Test.isRunningTest())
      auraResponse = AuraButtonControlsHandler.openModal(oppId);
    return auraResponse;
  }
}

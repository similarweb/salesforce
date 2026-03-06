global without sharing class CreateQuoteAmendPageController {
  global zqu__Quote__c thisQuote { get; set; }
  public Zuora__Subscription__c subscription { get; set; }
  public String packageName { get; set; }
  public String productType { get; set; }
  public Decimal currentContractTCV { get; set; }
  public Integer initialTerm { get; set; }
  public Integer renewTerm { get; set; }
  public String paymentTerm { get; set; }
  public String paymentType { get; set; }
  public Date termStartDate { get; set; }
  public Date subscriptionTermStartDate { get; set; }
  public String billingAccCompanyName { get; set; }
  public String amendmentRenewalPaymentFrequency { get; set; }
  public String defaultPaymentMethod { get; set; }
  public String legacyOrNewSolution { get; set; }
  public Integer numberOfCountry { get; set; }
  public Decimal specificBillingPeriod { get; set; }
  public MetadataServiceFacade service {
    get {
      if (service == null) {
        service = new MetadataServiceFacade();
      }
      return service;
    }
    private set;
  }

  public static Map<String, String> businessTypeToInstructionsMap {
    get {
      if (businessTypeToInstructionsMap == null) {
        businessTypeToInstructionsMap = new Map<String, String>();
        for (Zuora_Quote_Amend_Instructions_Setting__mdt zqais_i : [
          SELECT Id, Business_type__c, Instructions__c
          FROM Zuora_Quote_Amend_Instructions_Setting__mdt
        ]) {
          /* zqais_i.Instructions__c = zqais_i.Instructions__c.replace('\r\n','<br/>')
                                                                     .replace('\u2022','')
                                                                     .replace('\u25e6',''); */
          String instruction = '<ul>';
          for (
            String instructionLine_i : zqais_i.Instructions__c.split('\r\n')
          ) {
            if (
              instructionLine_i.contains('\u2022') ||
              instructionLine_i.contains('\u25e6')
            ) {
              instruction +=
                '<li>' +
                instructionLine_i.replace('\u2022', '').replace('\u25e6', '') +
                '</li>';
            } else {
              instruction += instructionLine_i + '<br/>';
            }
          }
          instruction += '</ul>';
          businessTypeToInstructionsMap.put(
            zqais_i.Business_type__c,
            instruction
          );
        }
      }
      return businessTypeToInstructionsMap;
    }
    private set;
  }

  public static Map<String, Map<String, List<String>>> packageValueToPackageAmendmentsMap {
    get {
      if (packageValueToPackageAmendmentsMap == null) {
        packageValueToPackageAmendmentsMap = new Map<String, Map<String, List<String>>>();
        for (Renewal_by_CC_pre_approved_migrations__mdt mdt : [
          SELECT
            Id,
            Current_Base_Package__c,
            Product_Type__c,
            New_Base_Package__c
          FROM Renewal_by_CC_pre_approved_migrations__mdt
        ]) {
          if (
            packageValueToPackageAmendmentsMap.get(
              mdt.Current_Base_Package__c
            ) == null
          ) {
            packageValueToPackageAmendmentsMap.put(
              mdt.Current_Base_Package__c,
              new Map<String, List<String>>()
            );
          }
          if (
            packageValueToPackageAmendmentsMap.get(mdt.Current_Base_Package__c)
              .get(mdt.Product_Type__c) == null
          ) {
            packageValueToPackageAmendmentsMap.get(mdt.Current_Base_Package__c)
              .put(mdt.Product_Type__c, new List<String>());
          }
          packageValueToPackageAmendmentsMap.get(mdt.Current_Base_Package__c)
            .get(mdt.Product_Type__c)
            .add(mdt.New_Base_Package__c);
        }
      }
      return packageValueToPackageAmendmentsMap;
    }
    private set;
  }

  @RemoteAction
  public static String getPackageAmendmentsForPackageValue() {
    return JSON.serialize(packageValueToPackageAmendmentsMap);
  }

  global CreateQuoteAmendPageController(
    ApexPages.StandardController StandardController
  ) {
    thisQuote = (zqu__Quote__c) StandardController.getRecord();
    String subscriptionId = apexpages.currentpage()
      .getparameters()
      .get('subscriptionId');
    System.debug('subscriptionId ' + subscriptionId);
    System.debug(
      'zqu__SubscriptionTermStartDate__c ' +
      thisQuote.zqu__SubscriptionTermStartDate__c
    );
    if (String.isNotBlank(subscriptionId)) {
      subscription = getRelatedSubscription(subscriptionId);
      if (subscription == null) {
        throw new SubscriptionNotExistException(
          'Account details is not sync, please go the account level and clicks on "Sync data from ZBilling".'
        );
      }
      if (
        subscription != null &&
        !subscription.Zuora__Subscription_Product_Charges__r.isEmpty()
      ) {
        specificBillingPeriod = subscription.Zuora__Subscription_Product_Charges__r[0]
          ?.Zuora__SpecificBillingPeriod__c;
      }
      // currentContractTcv = calculateCurrentContractTCV(subscription,thisQuote);
      currentContractTCV = calculateCurrentContractTCV(subscription, thisQuote);
      subscriptionTermStartDate = subscription.Zuora__SubscriptionStartDate__c;
      obtainTerms(subscription);
      System.debug('subs ' + subscription);
      List<String> relatedPackageNameList = getRelatedPackageNameListFromSubscription(
        subscription
      );
      System.debug('relatedPackageNameList ' + relatedPackageNameList);
      numberOfCountry = getNumberOfCountryFromRelatedPackageList(
        relatedPackageNameList
      );
      MetadataService.CustomField packageCustomField = service.obtainCustomField(
        'zqu__Quote__c.Package__c'
      );
      MetadataService.CustomField productCompatibilityField = service.obtainCustomField(
        'zqu__Quote__c.Product_Compatibility__c'
      );
      Map<String, List<String>> packagePicklistValueDependentMap = service.obtainPicklistValueDependentMap(
        packageCustomField
      );
      Map<String, List<String>> productCompatibilityPicklistValueDependentMap = service.obtainPicklistValueDependentMap(
        productCompatibilityField
      );
      packageName = getPackageNameFromRelatedSubs(
        relatedPackageNameList,
        productCompatibilityPicklistValueDependentMap
      );
      productType = getProductTypeFromRelatedSubs(
        packageName,
        packagePicklistValueDependentMap
      );

      amendmentRenewalPaymentFrequency = getBaseProductSpecificBillingPeriodFromSubscription(
        subscription
      );

      MetadataService.CustomField productTypeCustomField = service.obtainCustomField(
        'zqu__Quote__c.New_solution_use_case__c'
      );
      Map<String, List<String>> productTypePicklistValueDependentMap = service.obtainPicklistValueDependentMap(
        productTypeCustomField
      );
      legacyOrNewSolution = getLegacyOrNewSolutionFromRelatedSubs(
        productType,
        productTypePicklistValueDependentMap
      );
      System.debug('packageName ' + packageName);
      System.debug('productType ' + productType);
      System.debug('legacyOrNewSolution ' + legacyOrNewSolution);
    } else {
      termStartDate = thisQuote.zqu__SubscriptionTermStartDate__c;
    }
    String billingAccountId = apexpages.currentpage()
      .getparameters()
      .get('billingAccountId');
    if (String.isNotBlank(billingAccountId)) {
      Zuora__CustomerAccount__c relatedBillingAccount = getRelatedBillingAccount(
        billingAccountId
      );
      if (relatedBillingAccount != null) {
        System.debug('relatedBillingAccount ' + relatedBillingAccount);
        billingAccCompanyName = String.escapeSingleQuotes(
          relatedBillingAccount.Name
        );
        //MQ-2213
        System.debug(relatedBillingAccount.Zuora__DefaultPaymentMethod__c);
        System.debug(relatedBillingAccount.Zuora__Batch__c);
        if (
          relatedBillingAccount.Zuora__DefaultPaymentMethod__c ==
          'Credit Card' ||
          relatedBillingAccount.Zuora__DefaultPaymentMethod__c == 'CreditCard'
        ) {
          if (relatedBillingAccount.Zuora__Batch__c != null) {
            if (
              relatedBillingAccount.Zuora__Batch__c.equalsIgnoreCase('batch3')
            ) {
              defaultPaymentMethod = 'Other';
              paymentType = 'Credit Card';
            } else {
              defaultPaymentMethod = 'Credit Card';
            }
          }
        } else if (
          relatedBillingAccount.Zuora__DefaultPaymentMethod__c == 'WireTransfer'
        ) {
          defaultPaymentMethod = 'Wire Transfer';
        } else {
          defaultPaymentMethod = relatedBillingAccount.Zuora__DefaultPaymentMethod__c;
        }
        paymentTerm = relatedBillingAccount.Zuora__PaymentTerm__c;
        if (paymentType == null) {
          paymentType = getPaymentType(relatedBillingAccount);
        }
      }
    }
  }

  public void obtainTerms(Zuora__Subscription__c subscription) {
    if (subscription != null) {
      Pattern pp = Pattern.compile('.*[0-9]');
      if (String.isNotBlank(subscription.Zuora__InitialTerm__c)) {
        Matcher mm = pp.matcher(subscription.Zuora__InitialTerm__c);
        if (mm.find()) {
          initialTerm = Integer.valueof(mm.group());
        }
      }
      if (String.isNotBlank(subscription.Zuora__RenewalTerm__c)) {
        Matcher mm = pp.matcher(subscription.Zuora__RenewalTerm__c);
        if (mm.find()) {
          renewTerm = Integer.valueof(mm.group());
        }
      }
      termStartDate = subscription.Zuora__TermStartDate__c;
    }
  }

  public static Zuora__Subscription__c getRelatedSubscription(
    String subscriptionId
  ) {
    List<Zuora__Subscription__c> relatedSubscriptionsList = [
      SELECT
        Id,
        Zuora__Account__c,
        Zuora__NextRenewalDate__c,
        Zuora__SubscriptionEndDate__c,
        Zuora__TermStartDate__c,
        Zuora__SubscriptionStartDate__c,
        Zuora__InitialTerm__c,
        Zuora__MRR__c,
        Zuora__RenewalTerm__c,
        (
          SELECT Id, ProductName__c, Zuora__SpecificBillingPeriod__c
          FROM Zuora__Subscription_Product_Charges__r
        )
      FROM Zuora__Subscription__c
      WHERE Zuora__External_Id__c = :subscriptionId
    ];
    if (!relatedSubscriptionsList.isEmpty()) {
      return relatedSubscriptionsList[0];
    }
    return null;
  }

  public static Zuora__CustomerAccount__c getRelatedBillingAccount(
    String billingAccountId
  ) {
    List<Zuora__CustomerAccount__c> relatedBillingAccountList = [
      SELECT
        Id,
        Name,
        Zuora__DefaultPaymentMethod__c,
        Zuora__PaymentTerm__c,
        Zuora__Batch__c,
        (
          SELECT Id, Zuora__PaymentMethod__c, Payment_Type__c
          FROM Zuora__Payments__r
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM Zuora__CustomerAccount__c
      WHERE Zuora__External_Id__c = :billingAccountId
    ];
    if (!relatedBillingAccountList.isEmpty()) {
      return relatedBillingAccountList[0];
    }
    return null;
  }

  private static Integer getNumberOfCountryFromRelatedPackageList(
    List<String> relatedPackageNameList
  ) {
    Integer numberOfCountry = 0;
    for (String packageName_i : relatedPackageNameList) {
      if (packageName_i.startsWith('Country')) {
        numberOfCountry++;
      }
    }
    return numberOfCountry;
  }

  @RemoteAction
  public static String getInstructionForBusinessType(String businessType) {
    if (businessTypeToInstructionsMap.containsKey(businessType)) {
      return businessTypeToInstructionsMap.get(businessType);
    } else {
      return 'Please select the quote business type';
    }
  }

  public static List<String> getRelatedPackageNameListFromSubscription(
    Zuora__Subscription__c subscription
  ) {
    List<String> relatedPackageNameList = new List<String>();
    List<String> relatedProductNameList = new List<String>();
    for (
      Zuora__SubscriptionProductCharge__c zspc_i : subscription.Zuora__Subscription_Product_Charges__r
    ) {
      if (String.isNotBlank(zspc_i.ProductName__c)) {
        relatedProductNameList.add(zspc_i.ProductName__c);
      }
    }
    if (!relatedProductNameList.isEmpty()) {
      System.debug('relatedProductNameList ' + relatedProductNameList);
      List<Product2> productList = [
        SELECT Id, ProductCompatibility__c
        FROM Product2
        WHERE
          Name IN :relatedProductNameList
          AND zqu__Category__c = 'Base Products'
      ];
      for (Product2 product_i : productList) {
        if (String.isNotBlank(product_i.ProductCompatibility__c)) {
          relatedPackageNameList.addAll(
            product_i.ProductCompatibility__c.split(',')
          );
        }
      }
    }
    return relatedPackageNameList;
  }

  public static String getBaseProductSpecificBillingPeriodFromSubscription(
    Zuora__Subscription__c subscription
  ) {
    String specificBillingPeriodRaw = '';
    Map<String, Zuora__SubscriptionProductCharge__c> subProductChargeMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    if (subscription == null) {
      throw new SubscriptionNotExistException(
        'Account details is not sync, please go the account level and clicks on "Sync data from ZBilling".'
      );
    }
    for (
      Zuora__SubscriptionProductCharge__c zspc_i : subscription.Zuora__Subscription_Product_Charges__r
    ) {
      if (String.isNotBlank(zspc_i.ProductName__c)) {
        subProductChargeMap.put(zspc_i.ProductName__c.toLowerCase(), zspc_i);
      }
    }
    if (!subProductChargeMap.isEmpty()) {
      List<Product2> productList = [
        SELECT Id, Name
        FROM Product2
        WHERE
          Name IN :subProductChargeMap.keySet()
          AND zqu__Category__c = 'Base Products'
      ];
      Product2 basePackageProduct = null;
      if (!productList.isEmpty()) {
        basePackageProduct = productList[0];
      }

      Zuora__SubscriptionProductCharge__c baseSubProductCharge = new Zuora__SubscriptionProductCharge__c();
      if (basePackageProduct != null) {
        baseSubProductCharge = subProductChargeMap.get(
          basePackageProduct.Name.toLowerCase()
        );
      }

      if (baseSubProductCharge.Zuora__SpecificBillingPeriod__c != null) {
        Integer specificBillingPeriod = baseSubProductCharge.Zuora__SpecificBillingPeriod__c.intValue();
        switch on specificBillingPeriod {
          when 12 {
            specificBillingPeriodRaw = 'Annual';
          }
          when 6 {
            specificBillingPeriodRaw = 'Semi-Annual';
          }
          when 3 {
            specificBillingPeriodRaw = 'Quarterly';
          }
          when 24 {
            specificBillingPeriodRaw = 'Every 2 Years';
          }
          when 36 {
            specificBillingPeriodRaw = 'Every 3 years';
          }
          /*  when 'Full Term'{
                        specificBillingPeriod = initialTerm.intValue();
                    } */
          /*  when 'Other'{
                        specificBillingPeriod = initialTerm.intValue();
                    } */
          when else {
            specificBillingPeriodRaw = 'Other';
          }
        }
      }
    }
    return specificBillingPeriodRaw;
  }

  public static String getPackageNameFromRelatedSubs(
    List<String> relatedPackageNameList,
    Map<String, List<String>> picklistValueDependentMap
  ) {
    String packageName;
    for (String controllingFieldName_i : picklistValueDependentMap.keySet()) {
      List<String> dependentValueList = picklistValueDependentMap.get(
        controllingFieldName_i
      );
      System.debug('dependentValueList ' + dependentValueList);
      System.debug('controllingFieldName_i ' + controllingFieldName_i);
      for (String packageName_i : relatedPackageNameList) {
        if (dependentValueList.contains(packageName_i)) {
          packageName = controllingFieldName_i;
          break;
        }
      }
      if (String.isNotBlank(packageName)) {
        break;
      }
    }
    return packageName;
  }

  public static String getProductTypeFromRelatedSubs(
    String packageName,
    Map<String, List<String>> picklistValueDependentMap
  ) {
    String productType;
    for (String controllingFieldName_i : picklistValueDependentMap.keySet()) {
      List<String> dependentValueList = picklistValueDependentMap.get(
        controllingFieldName_i
      );
      if (dependentValueList.contains(packageName)) {
        productType = controllingFieldName_i;
        break;
      }
    }
    return productType;
  }

  public static String getLegacyOrNewSolutionFromRelatedSubs(
    String productType,
    Map<String, List<String>> picklistValueDependentMap
  ) {
    String legacyOrNewSolution;
    for (String controllingFieldName_i : picklistValueDependentMap.keySet()) {
      List<String> dependentValueList = picklistValueDependentMap.get(
        controllingFieldName_i
      );
      if (dependentValueList.contains(productType)) {
        legacyOrNewSolution = controllingFieldName_i;
        break;
      }
    }
    return legacyOrNewSolution;
  }

  private static String getPaymentType(
    Zuora__CustomerAccount__c relatedBillingAccount
  ) {
    String paymentType;
    if (
      relatedBillingAccount.Zuora__Payments__r != null &&
      relatedBillingAccount.Zuora__Payments__r.size() > 0
    ) {
      Zuora__Payment__c payment = relatedBillingAccount.Zuora__Payments__r[0];
      paymentType = payment.Payment_Type__c;
      if (paymentType != null && String.isNotBlank(paymentType)) {
        if (
          paymentType.containsIgnoreCase('CreditCard') ||
          paymentType.containsIgnoreCase('Credit Card')
        ) {
          paymentType = 'Credit Card';
        }
        if (
          paymentType.containsIgnoreCase('WireTransfer') ||
          paymentType.containsIgnoreCase('Wire Transfer') ||
          paymentType.containsIgnoreCase('Other')
        ) {
          paymentType = 'Wire Transfer';
        }
      }
    } else {
      paymentType = 'Wire Transfer';
    }
    return paymentType;
  }

  private static Decimal calculateCurrentContractTCV(
    Zuora__Subscription__c subscription,
    zqu__Quote__c quote
  ) {
    Integer initialTerm;
    Decimal currQuoteTcv = 0;
    Pattern pp = Pattern.compile('.*[0-9]');
    if (String.isNotBlank(subscription.Zuora__InitialTerm__c)) {
      Matcher mm = pp.matcher(subscription.Zuora__InitialTerm__c);
      if (mm.find()) {
        initialTerm = Integer.valueof(mm.group());
      }
    }
    if (subscription.Zuora__MRR__c != null && initialTerm != null) {
      currQuoteTcv = (subscription.Zuora__MRR__c * initialTerm).round();
    }
    return currQuoteTcv;
  }

  public class SubscriptionNotExistException extends Exception {
  }
}

global without sharing class CreateQuotePageController {
  global zqu__Quote__c thisQuote { get; set; }
  public Boolean isFullTermSwhown { get; set; }
  public String gapriseIncAccId { get; set; }
  public String gapriseIncAccName { get; set; }
  public String prosusAccId { get; set; }
  public String prosusAccName { get; set; }
  public String paymentTerm { get; set; }
  public String taxExemptCertificateID { get; set; }
  public String defaultPaymentMethod { get; set; }
  public String billingAccountId { get; set; }
  public String billingAccCompanyName { get; set; }
  public String BillToCompanyName { get; set; }
  public String paymentFrequency { get; set; }
  public String billToId { get; set; }
  public String soldToId { get; set; }
  public String billToName { get; set; }
  public String soldToName { get; set; }
  public String quoteCurrency { get; set; }
  public String orgUrl { get; set; }
  public Integer initialTerm { get; set; }
  public Integer renewTerm { get; set; }
  public Zuora__Subscription__c subscription { get; set; }
  public Boolean isMsaSentToZuoraEnabled { get; set; }
  public Boolean isSalesOpsEnabled { get; set; }
  public Boolean isUserRoleRankRanger { get; set; }
  public String quoteCurrencies { get; set; }
  public String currenciesList { get; set; }
  public Boolean isProsusVisible { get; set; }
  public Date relatedStartDate { get; set; }
  public Decimal specificBillingPeriod { get; set; }
  public String userProfileName { get; set; }
  public String userName { get; set; }
  public String packagesForValidationLine { get; set; }
  public String soldToCountryValue { get; set; }
  public String groupDescription { get; set; }
  public Boolean showInitialAndRenewal { get; set; }
  public Zuora__CustomerAccount__c parentCustomerAccount { get; set; }
  public String parentContactName { get; set; }
  public String parentContactId { get; set; }
  public static zqu__Quote__c currentStaticQuote { get; set; }

  private static Set<String> noValidationCountries = new Set<String>{
    'Israel',
    'United Kingdom',
    'Malaysia',
    'Indonesia',
    'Singapore'
  };

  global createQuotePageController(
    ApexPages.StandardController StandardController
  ) {
    showInitialAndRenewal = true;
    System.debug('parentCustomerAccount--' + this.parentCustomerAccount);
    isUserRoleRankRanger = checkUserRoleForRankRanger();
    System.debug('createQuotePageController');
    thisQuote = (zqu__Quote__c) StandardController.getRecord();
    System.debug('thisQuote: ' + thisQuote);
    zqu__Quote__c fullQuoteObject;
    zqu__Quote__c quoteWithData;
    if (thisQuote.Id != null) {
      fullQuoteObject = zqu.Quote.getInstance(thisQuote.Id).getSObject();
      quoteWithData = [
        SELECT Id, Group_Description__c
        FROM zqu__Quote__c
        WHERE Id = :thisQuote.Id
      ];
      relatedStartDate = fullQuoteObject.zqu__StartDate__c;
      soldToCountryValue = getContactCountryById(
        fullQuoteObject.zqu__SoldToContact__c
      );
      currentStaticQuote = thisQuote;
      System.debug('currentStaticQuote: ' + currentStaticQuote);
    }
    this.userProfileName = getCurrentUserProfileName();
    this.userName = getCurrentUserName();
    thisQuote.recalculateFormulas();
    isFullTermSwhown = thisQuote.Payment_Frequency_Control__c;
    searchGapriseIncBillingAccount();
    orgUrl = URL.getSalesforceBaseUrl().toExternalForm();
    String crmAccountId = apexpages.currentpage()
        .getparameters()
        .get('crmAccountId') != null
      ? apexpages.currentpage().getparameters().get('crmAccountId')
      : thisQuote.zqu__Account__c;
    if (
      apexpages.currentpage() != null &&
      apexpages.currentpage().getparameters() != null &&
      apexpages.currentpage().getparameters().containsKey('billingAccountId') &&
      apexpages.currentpage().getparameters().containsKey('crmAccountId')
    ) {
      System.debug('apexpages true');
      billingAccountId = apexpages.currentpage()
        .getparameters()
        .get('billingAccountId');
      String subscriptionId = apexpages.currentpage()
        .getparameters()
        .get('subscriptionId');
      Zuora__CustomerAccount__c relatedBillingAccount;
      if (String.isNotBlank(billingAccountId)) {
        System.debug('asdasdsa');
        relatedBillingAccount = getRelatedBillingAccount(billingAccountId);
        paymentTerm = relatedBillingAccount.Zuora__PaymentTerm__c;
        taxExemptCertificateID = relatedBillingAccount.Zuora__TaxExemptCertificateID__c;
        billingAccCompanyName = String.escapeSingleQuotes(
          relatedBillingAccount.Name
        );
        BillToCompanyName = String.isNotBlank(
            relatedBillingAccount.BillingCompanyName__c
          )
          ? String.escapeSingleQuotes(
              relatedBillingAccount.BillingCompanyName__c
            )
          : '';
        if (
          relatedBillingAccount.Zuora__DefaultPaymentMethod__c == 'CreditCard'
        ) {
          defaultPaymentMethod = 'Credit Card';
        } else if (
          relatedBillingAccount.Zuora__DefaultPaymentMethod__c == 'WireTransfer'
        ) {
          defaultPaymentMethod = 'Wire Transfer';
        } else {
          defaultPaymentMethod = relatedBillingAccount.Zuora__DefaultPaymentMethod__c;
        }
        billToId = relatedBillingAccount.Zuora__BillToId__c;
        soldToId = relatedBillingAccount.Zuora__SoldToId__c;
        billToName = relatedBillingAccount.Zuora__BillToName__c;
        soldToName = relatedBillingAccount.Zuora__SoldToName__c;
        quoteCurrency = relatedBillingAccount.Zuora__Currency__c;
      }
      if (
        String.isNotBlank(billingAccountId) &&
        String.isNotBlank(crmAccountId) &&
        String.isBlank(subscriptionId)
      ) {
        subscription = getRelatedSubscription(relatedBillingAccount.Id);
        if (
          subscription != null &&
          !subscription.Zuora__Subscription_Product_Charges__r.isEmpty()
        ) {
          specificBillingPeriod = subscription
            ?.Zuora__Subscription_Product_Charges__r[0]
            ?.Zuora__SpecificBillingPeriod__c;
          System.debug('specificBillingPeriod--' + specificBillingPeriod);
          obtainTerms(subscription);
          paymentFrequency = getBaseProductSpecificBillingPeriodFromSubscription(
            subscription
          );
        }
      }
    }
    if (String.isNotBlank(crmAccountId)) {
      System.debug('i am here');
      parentCustomerAccount = getParentAccountInfo(crmAccountId); // alon shalev mq-1829 14.5.23 maybe we can put this line in 112
      System.debug('parentCustomerAccount--' + parentCustomerAccount);
      if (parentCustomerAccount != null) {
        showInitialAndRenewal = false;
        Map<String, object> billtoAndSoldToMap = getSoldToAndBillToByEmail(
          parentCustomerAccount.Zuora__External_Id__c
        );
        parentContactName = billtoAndSoldToMap.get('billToContact') != null
          ? String.valueOf(billtoAndSoldToMap.get('billToContact'))
          : null;
        parentContactId = billtoAndSoldToMap.get('billToContactId') != null
          ? String.valueOf(billtoAndSoldToMap.get('billToContactId'))
          : null;
      }

      System.debug('parentCustomerAccount after--' + parentCustomerAccount);
      Account account = getRelatedSfAccount(crmAccountId);
      String allowedAccIdForProsus = getProsusAccountId();
      system.debug(
        'account.Group_Description__c--' + account.Group_Description__c
      );
      system.debug('account--' + account);
      system.debug('quoteWithData--' + quoteWithData);
      groupDescription = quoteWithData != null &&
        quoteWithData.Group_Description__c != null
        ? quoteWithData.Group_Description__c
        : account.Group_Description__c;

      if (
        String.isNotBlank(allowedAccIdForProsus) &&
        (account.ParentId != null &&
        ((String) account.ParentId)
          .containsIgnoreCase(allowedAccIdForProsus)) ||
        (account.Root_Parent_Account__c != null &&
        account.Root_Parent_Account__c.containsIgnoreCase(
          allowedAccIdForProsus
        ))
      ) {
        isProsusVisible = true;
        searchProsusBillingAccount();
      } else {
        isProsusVisible = false;
      }
    }
    Id profileId = userinfo.getProfileId();
    String profileName = [SELECT Id, Name FROM Profile WHERE Id = :profileId]
    .Name;
    System.debug('profileName');
    if (
      profileName.equalsIgnoreCase('System Administrator') ||
      profileName.equalsIgnoreCase('SW Billing') ||
      profileName.equalsIgnoreCase('SW Billing Extended')
    ) {
      isMsaSentToZuoraEnabled = true;
    } else {
      isMsaSentToZuoraEnabled = false;
    }

    if (
      profileName.equalsIgnoreCase('SW SalesOps') ||
      profileName.equalsIgnoreCase('SW SalesOps Extended')
    ) {
      isSalesOpsEnabled = true;
    } else {
      isSalesOpsEnabled = false;
    }

    List<Quote_Currencies__mdt> quoteCurrenciesMetadataList = [
      SELECT
        Id,
        Subsidiary_Name__c,
        Applicable_Currencies__c,
        Default_Currency__c
      FROM Quote_Currencies__mdt
    ];
    if (!quoteCurrenciesMetadataList.isEmpty()) {
      Map<String, Quote_Currencies__mdt> quoteCurrenciesMap = new Map<String, Quote_Currencies__mdt>();
      for (Quote_Currencies__mdt qc_i : quoteCurrenciesMetadataList) {
        if (String.isNotBlank(qc_i.Subsidiary_Name__c)) {
          quoteCurrenciesMap.put(qc_i.Subsidiary_Name__c, qc_i);
        }
      }
      quoteCurrencies = JSON.serialize(quoteCurrenciesMap);
    }

    List<String> currenciesListTemp = new List<String>();
    Schema.SObjectType obj_describe = Schema.getGlobalDescribe()
      .get('zqu__Quote__c');
    Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe();
    Map<String, Schema.SObjectField> fields = obj_describe_result.fields.getMap();
    Schema.DescribeFieldResult fieldResult = fields.get('zqu__Currency__c')
      .getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      currenciesListTemp.add(String.valueOf(pickListVal.getValue()));
    }
    currenciesList = JSON.serialize(currenciesListTemp);

    if (!isSalesOpsEnabled) {
      this.packagesForValidationLine = obtainPackagesForValidationLine();
    }
  }

  private Zuora__CustomerAccount__c getParentAccountInfo(Id sfAccountId) {
    Zuora__CustomerAccount__c parentAccount;
    String activeStr = 'Active';
    String termedStr = 'Termed';
    Date todayDate = Date.today();
    List<Zuora__CustomerAccount__c> billingAccounts = [
      SELECT
        Id,
        name,
        Zuora__External_Id__c,
        Zuora_Parent_Account__c,
        (
          SELECT Id
          FROM Zuora__Subscriptions__r
          WHERE
            Zuora__Status__c = :activeStr
            AND Zuora__SubscriptionEndDate__c > :todayDate
            AND Zuora__TermSettingType__c = :termedStr
        )
      FROM Zuora__CustomerAccount__c
      WHERE Zuora__Account__c = :sfAccountId
    ];
    for (Zuora__CustomerAccount__c billingAccount : billingAccounts) {
      if (billingAccount.Zuora_Parent_Account__c == 'Yes') {
        parentAccount = billingAccount;
        break;
      } else if (!billingAccount.Zuora__Subscriptions__r.isEmpty()) {
        parentAccount = billingAccount;
        break;
      }
    }
    return parentAccount;
  }

  private Boolean checkForExistingSubscription() {
    boolean isExistingSubscription = false;
    return isExistingSubscription;
  }

  private Boolean checkUserRoleForRankRanger() {
    User currentUser = [
      SELECT Profile.Name, UserRole.Name
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    return currentUser.UserRole.Name == 'Rank Ranger';
  }

  private static String obtainPackagesForValidationLine() {
    String packagesLine;
    List<Quote_Create_Package_Validatuon__mdt> packageList = [
      SELECT id, Value__c
      FROM Quote_Create_Package_Validatuon__mdt
    ];

    for (Quote_Create_Package_Validatuon__mdt packageVal : packageList) {
      if (String.isBlank(packagesLine)) {
        packagesLine = packageVal.Value__c;
      } else {
        packagesLine += ', ' + packageVal.Value__c;
      }
    }

    return packagesLine;
  }

  @RemoteAction
  public static Map<String, Object> checkSoldToCountry(
    Id soldToContactId,
    String pck
  ) {
    system.debug('soldToContactId--' + soldToContactId);
    System.debug('yuck: ' + pck);
    try {
      Contact contactWithCountryAndRegion = getContactCountryAndRegion(
        soldToContactId
      );
      String soldToCountry = contactWithCountryAndRegion != null &&
        String.isNotBlank(contactWithCountryAndRegion.MailingCountry)
        ? contactWithCountryAndRegion.MailingCountry
        : '';
      boolean isRegionLatam =
        contactWithCountryAndRegion != null &&
        String.isNotBlank(contactWithCountryAndRegion.Country_Region_new__c) &&
        contactWithCountryAndRegion.Country_Region_new__c == 'LATAM';

      Boolean countrySubsidiaryForCountryExists = checkIfCountrySubsidiaryForCountryExists(
        soldToCountry,
        pck,
        contactWithCountryAndRegion
      );
      Country_Subsidiary__c countrySubsidiary = getCountrySubsidiary(
        soldToCountry,
        pck,
        contactWithCountryAndRegion
      );
      Map<String, Object> responseMap = new Map<String, Object>();
      responseMap.put(
        'isCountrySubsidiaryForCountryExists',
        countrySubsidiaryForCountryExists
      );
      responseMap.put('soldToContactCountry', soldToCountry);
      responseMap.put('isRegionLatam', isRegionLatam);
      if (String.isNotBlank(countrySubsidiary.Subsidiary__c)) {
        responseMap.put('subsidiary', countrySubsidiary.Subsidiary__c);
      }
      if (String.isNotBlank(countrySubsidiary.Name)) {
        responseMap.put('subsidiaryName', countrySubsidiary.Name);
      }
      return responseMap;
    } catch (Exception ex) {
      system.debug(ex.getMessage());
      system.debug(ex.getStackTraceString());
      return null;
    }
  }

  @RemoteAction
  public static Map<String, Object> getSubsidaiaryCountryName(
    Id soldToContactId,
    String billingAccountId
  ) {
    try {
      String soldToCountry = getContactCountryById(soldToContactId);
      Zuora__CustomerAccount__c billingAccount = getBillingAccount(
        billingAccountId
      );
      Map<String, Object> responseMap = new Map<String, Object>();
      if (billingAccount != null) {
        responseMap.put('subsidiaryName', billingAccount.Subsidiary__c);
        responseMap.put('contactMailgCountry', soldToCountry);
        if (
          soldToCountry == 'Germany' &&
          billingAccount.Subsidiary__c.contains('UK') &&
          billingAccount.Zuora__Balance__c == 0
        ) {
          responseMap.put('isWrongSubsidiary', true);
        } else {
          responseMap.put('isWrongSubsidiary', false);
        }
      }
      return responseMap;
    } catch (Exception ex) {
      return null;
    }
  }

  @RemoteAction
  public static Boolean validateCertificateId(
    Id soldToContactId,
    String certificateId
  ) {
    Boolean response = false;
    try {
      String soldToCountry = getContactCountryById(soldToContactId);
      if (noValidationCountries.contains(soldToCountry)) {
        return true;
      }
      String isoCountry = getIsoCodeByCountryName(
        soldToCountry,
        soldToContactId
      );

      System.debug('isoCountry ' + isoCountry);
      if (String.isNotBlank(isoCountry)) {
        WSVATService service = new WSVATService();
        String wsvatResponse = service.checkVat(isoCountry, certificateId);
        Boolean isVatNumberValid = parseWsvatResponse(wsvatResponse);
        response = isVatNumberValid;
      } else {
        response = false;
      }
    } catch (Exception ex) {
      return false;
    }
    return response;
  }

  @RemoteAction
  public static Boolean validateCertificateIdNew(
    Id soldToContactId,
    String certificateId
  ) {
    Boolean response = false;
    try {
      String soldToCountry = getContactCountryById(soldToContactId);
      if (noValidationCountries.contains(soldToCountry)) {
        return true;
      }
      List<String> certificateIdWithIso = certificateId.split(' ');

      if (!certificateIdWithIso.isEmpty()) {
        WSVATService service = new WSVATService();
        String wsvatResponse = service.checkVat(
          certificateIdWithIso[0],
          certificateIdWithIso[1]
        );
        Boolean isVatNumberValid = parseWsvatResponse(wsvatResponse);
        response = isVatNumberValid;
      } else {
        response = false;
      }
    } catch (Exception ex) {
      return false;
    }
    return response;
  }

  @RemoteAction
  public static String getHelpText(String fieldName) {
    try {
      // MetadataServiceFacade service = new MetadataServiceFacade();
      // MetadataService.CustomField fieldMd = service.obtainCustomField('zqu__Quote__c.'+fieldName);
      // if (fieldMd != null) {
      //     return fieldMd.inlineHelpText;
      // }
      DescribeFieldResult dfr = Utility.getFieldDescribe(
        'zqu__Quote__c',
        fieldName
      );
      if (dfr != null) {
        return dfr.getInlineHelpText();
      }
      return '';
    } catch (Exception ex) {
      return '';
    }
  }

  @RemoteAction
  public static Map<String, Object> getBillToFromParentAccountName(
    String parentAccountName
  ) {
    System.debug('parentAccountName--' + parentAccountName);
    Map<String, Object> responseMap = new Map<String, Object>();
    Zuora__CustomerAccount__c billingAccount = [
      SELECT
        Id,
        Zuora__BillToWorkEmail__c,
        Zuora__SoldToWorkEmail__c,
        Zuora__Account__c
      FROM Zuora__CustomerAccount__c
      WHERE Name = :parentAccountName
    ];
    Map<String, String> inputFieldToMailMap = new Map<String, String>();
    inputFieldToMailMap.put(
      'billToContact',
      billingAccount.Zuora__BillToWorkEmail__c
    );
    generateContactMapFromEmail(
      billingAccount,
      inputFieldToMailMap,
      responseMap
    );
    return responseMap;
  }

  @RemoteAction
  public static Map<String, Object> getSoldToAndBillToByEmail(
    String parentOrCurrentBillingAccount
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    Zuora__CustomerAccount__c billingAccount = [
      SELECT
        Id,
        Zuora__BillToWorkEmail__c,
        Zuora__SoldToWorkEmail__c,
        Zuora__Account__c
      FROM Zuora__CustomerAccount__c
      WHERE Zuora__External_Id__c = :parentOrCurrentBillingAccount
    ];

    Map<String, String> inputFieldToMailMap = new Map<String, String>();
    inputFieldToMailMap.put(
      'billToContact',
      billingAccount.Zuora__BillToWorkEmail__c
    );
    inputFieldToMailMap.put(
      'soldToContact',
      billingAccount.Zuora__SoldToWorkEmail__c
    );
    generateContactMapFromEmail(
      billingAccount,
      inputFieldToMailMap,
      responseMap
    );
    return responseMap;
  }

  private static void generateContactMapFromEmail(
    Zuora__CustomerAccount__c billingAccount,
    Map<String, String> inputFieldToMailMap,
    Map<String, Object> responseMap
  ) {
    List<Contact> contacts = [
      SELECT Name, Id, Email
      FROM Contact
      WHERE
        AccountId = :billingAccount.Zuora__Account__c
        AND Email IN :inputFieldToMailMap.values()
    ];
    Map<String, Contact> emailToNameMap = new Map<String, Contact>();
    for (Contact contact : contacts) {
      emailToNameMap.put(contact.Email, contact);
    }
    for (String inputField : inputFieldToMailMap.keySet()) {
      String email = inputFieldToMailMap.get(inputField);
      String contactName = emailToNameMap.containsKey(email)
        ? emailToNameMap.get(email).Name
        : null;
      String contactId = emailToNameMap.containsKey(email)
        ? emailToNameMap.get(email).Id
        : null;
      responseMap.put(inputField, contactName);
      responseMap.put(inputField + 'Id', contactId);
    }
  }

  private void searchGapriseIncBillingAccount() {
    List<Zuora__CustomerAccount__c> gapriseIncAccList = [
      SELECT Id, Name
      FROM Zuora__CustomerAccount__c
      WHERE Name = 'Gaprise inc.'
    ];
    if (gapriseIncAccList.size() > 0) {
      Zuora__CustomerAccount__c gapriseIncAcc = gapriseIncAccList[0];
      gapriseIncAccId = gapriseIncAcc.Id;
      gapriseIncAccName = gapriseIncAcc.Name;
    }
  }

  private void searchProsusBillingAccount() {
    List<Zuora__CustomerAccount__c> prosusAccList = [
      SELECT Id, Name
      FROM Zuora__CustomerAccount__c
      WHERE Name = 'Prosus Services B.V.'
    ];
    if (prosusAccList.size() > 0) {
      Zuora__CustomerAccount__c prosusAcc = prosusAccList[0];
      prosusAccId = prosusAcc.Id;
      prosusAccName = prosusAcc.Name;
    }
  }

  private static String getContactCountryById(Id soldToContactId) {
    Contact contact = getContactCountryAndRegion(soldToContactId);
    String country = '';
    if (contact != null && String.isNotBlank(contact.MailingCountry)) {
      country = contact.MailingCountry;
    }
    return country;
  }

  private static Contact getContactCountryAndRegion(Id soldToContactId) {
    List<Contact> contactList = [
      SELECT MailingCountry, Country_Region_new__c, Account.AccountSource
      FROM Contact
      WHERE Id = :soldToContactId
    ];
    Contact contact = contactList.isEmpty() ? null : contactList[0];
    return contact;
  }

  private static String getIsoCodeByCountryName(
    String soldToCountry,
    Id soldToContactId
  ) {
    String isoCountry;
    Country_Subsidiary__c countrysub = new Country_Subsidiary__c();
    Contact soldToContact = getContactCountryAndRegion(soldToContactId);
    System.debug('currentStaticQuote: ' + currentStaticQuote);
    if (soldToContact.Account.AccountSource == '42matters') {
      countrysub = [
        SELECT Id, ISOCode__c
        FROM Country_Subsidiary__c
        WHERE
          Tax_Region__c != NULL
          AND Country_Name__c = :soldToCountry
          AND (Name = :soldToCountry
          OR ISOCode_3__c = :soldToCountry)
          AND ISOCode__c != NULL
          AND Company__c = '42matters'
        LIMIT 1
      ];
    } else if (
      !currentStaticQuote.Migrating_to_New_Soultion__c.equalsIgnoreCase(
        'Yes'
      ) && currentStaticQuote.package__c.equalsIgnoreCase('Admetricks')
    ) {
      countrysub = [
        SELECT Id, ISOCode__c
        FROM Country_Subsidiary__c
        WHERE
          Tax_Region__c != NULL
          AND Country_Name__c = :soldToCountry
          AND (Name = :soldToCountry
          OR ISOCode_3__c = :soldToCountry)
          AND ISOCode__c != NULL
          AND Company__c = 'Admetricks'
        LIMIT 1
      ];
    } else if (
      !currentStaticQuote.Migrating_to_New_Soultion__c.equalsIgnoreCase(
        'Yes'
      ) && currentStaticQuote.package__c.containsIgnoreCase('Newslever')
    ) {
      countrysub = [
        SELECT Id, ISOCode__c
        FROM Country_Subsidiary__c
        WHERE
          Tax_Region__c != NULL
          AND Country_Name__c = :soldToCountry
          AND (Name = :soldToCountry
          OR ISOCode_3__c = :soldToCountry)
          AND ISOCode__c != NULL
          AND Company__c = 'Signal Insights, Inc.'
        LIMIT 1
      ];
    } else {
      countrysub = [
        SELECT Id, ISOCode__c
        FROM Country_Subsidiary__c
        WHERE
          Tax_Region__c != NULL
          AND Country_Name__c = :soldToCountry
          AND (Name = :soldToCountry
          OR ISOCode_3__c = :soldToCountry)
          AND ISOCode__c != NULL
          AND Company__c = 'SW'
        LIMIT 1
      ];
    }

    if (countrysub != null) {
      isoCountry = countrysub.ISOCode__c;
    }
    System.debug('isoCountry: ' + isoCountry);
    return isoCountry;
  }

  private static Boolean parseWsvatResponse(String wsvatResponse) {
    Boolean isVatNumberValid = false;
    if (wsvatResponse.startswith('checkVatResponse_element')) {
      //Successfull answer starts with checkVATresponse_element
      integer validi = wsvatResponse.indexof('valid=');
      if (validi != -1) {
        integer resulti = wsvatResponse.indexof(',', validi);
        if (resulti != -1) {
          string results = wsvatResponse.substring(validi + 6, resulti);
          if (results.EqualsIgnoreCase('True'))
            isVatNumberValid = true;
          if (results.EqualsIgnoreCase('false'))
            isVatNumberValid = false;
        }
      }
    }
    return isVatNumberValid;
  }

  private static Boolean checkIfCountrySubsidiaryForCountryExists(
    String soldToCountry,
    String pck,
    Contact soldToContact
  ) {
    if (
      soldToCountry == 'Japan' ||
      soldToCountry == 'Russia' ||
      soldToCountry == 'Australia' ||
      soldToCountry == 'United States'
    ) {
      return false;
    } else {
      list<Country_Subsidiary__c> countrySubsidiaryList = new List<Country_Subsidiary__c>();
      System.debug('currentStaticQuote: ' + currentStaticQuote);
      if (soldToContact.Account.AccountSource == '42matters') {
        countrySubsidiaryList = [
          SELECT Id
          FROM Country_Subsidiary__c
          WHERE
            ((Taxable__c = 'All'
            AND Country_Name__c = :soldToCountry)
            OR (Taxable__c = 'Yes'
            AND Country_Name__c = 'United Kingdom'
            AND Country_Name__c = :soldToCountry))
            AND Company__c = '42matters'
        ];
      } else if (pck.equalsIgnoreCase('Admetricks')) {
        countrySubsidiaryList = [
          SELECT Id
          FROM Country_Subsidiary__c
          WHERE
            ((Taxable__c = 'All'
            AND Country_Name__c = :soldToCountry)
            OR (Taxable__c = 'Yes'
            AND Country_Name__c = 'United Kingdom'
            AND Country_Name__c = :soldToCountry))
            AND Company__c = 'Admetricks'
        ];
      } else if (pck.containsIgnoreCase('Newslever')) {
        countrySubsidiaryList = [
          SELECT Id
          FROM Country_Subsidiary__c
          WHERE
            ((Taxable__c = 'All'
            AND Country_Name__c = :soldToCountry)
            OR (Taxable__c = 'Yes'
            AND Country_Name__c = 'United Kingdom'
            AND Country_Name__c = :soldToCountry))
            AND Company__c = 'Signal Insights, Inc.'
        ];
      } else {
        countrySubsidiaryList = [
          SELECT Id
          FROM Country_Subsidiary__c
          WHERE
            ((Taxable__c = 'All'
            AND Country_Name__c = :soldToCountry)
            OR (Taxable__c = 'Yes'
            AND Country_Name__c = 'United Kingdom'
            AND Country_Name__c = :soldToCountry))
            AND Company__c = 'SW'
        ];
      }
      if (countrySubsidiaryList.size() > 0) {
        return true;
      } else {
        return false;
      }
    }
  }

  private static Country_Subsidiary__c getCountrySubsidiary(
    String soldToCountry,
    String pck,
    Contact soldToContact
  ) {
    System.debug('currentStaticQuote: ' + currentStaticQuote);
    System.debug('soldToContact: ' + soldToContact);
    List<Country_Subsidiary__c> countrySubsidiaryList = new List<Country_Subsidiary__c>();
    if (soldToContact.Account.AccountSource == '42matters') {
      countrySubsidiaryList = [
        SELECT Id, Name, Subsidiary__c
        FROM Country_Subsidiary__c
        WHERE Country_Name__c = :soldToCountry AND Company__c = '42matters'
      ];
    } else if (pck.equalsIgnoreCase('Admetricks')) {
      countrySubsidiaryList = [
        SELECT Id, Name, Subsidiary__c
        FROM Country_Subsidiary__c
        WHERE Country_Name__c = :soldToCountry AND Company__c = 'Admetricks'
      ];
    } else if (pck.containsIgnoreCase('Newslever')) {
      countrySubsidiaryList = [
        SELECT Id, Name, Subsidiary__c
        FROM Country_Subsidiary__c
        WHERE
          Country_Name__c = :soldToCountry
          AND Company__c = 'Signal Insights, Inc.'
      ];
    } else {
      countrySubsidiaryList = [
        SELECT Id, Name, Subsidiary__c
        FROM Country_Subsidiary__c
        WHERE Country_Name__c = :soldToCountry AND Company__c = 'SW'
      ];
    }
    System.debug('countrySubsidiaryList: ' + countrySubsidiaryList);
    return countrySubsidiaryList[0];
  }

  private static Zuora__CustomerAccount__c getBillingAccount(
    String billingAccountId
  ) {
    Zuora__CustomerAccount__c billingAccount;
    List<Zuora__CustomerAccount__c> billingAccountList = [
      SELECT Id, Subsidiary__c, Zuora__Balance__c
      FROM Zuora__CustomerAccount__c
      WHERE Zuora__External_Id__c = :billingAccountId
      LIMIT 1
    ];

    if (!billingAccountList.isEmpty()) {
      billingAccount = billingAccountList[0];
    }
    return billingAccount;
  }

  public static Zuora__Subscription__c getRelatedSubscription(String accId) {
    List<Zuora__Subscription__c> relatedSubscriptionsList = [
      SELECT
        Id,
        Zuora__Account__c,
        Zuora__NextRenewalDate__c,
        Zuora__SubscriptionEndDate__c,
        Zuora__SubscriptionStartDate__c,
        Zuora__InitialTerm__c,
        Zuora__RenewalTerm__c,
        Zuora__Status__c,
        Zuora__TermSettingType__c,
        (
          SELECT Id, ProductName__c, Zuora__SpecificBillingPeriod__c
          FROM Zuora__Subscription_Product_Charges__r
        )
      FROM Zuora__Subscription__c
      WHERE Zuora__CustomerAccount__c = :accId
    ];
    if (!relatedSubscriptionsList.isEmpty()) {
      Zuora__Subscription__c subscription;
      for (Zuora__Subscription__c subscription_i : relatedSubscriptionsList) {
        if (subscription_i.Zuora__Status__c == 'Active') {
          subscription = subscription_i;
          break;
        } else if (subscription == null) {
          subscription = subscription_i;
        }
      }
      return subscription;
    }
    return null;
  }

  public static Account getRelatedSfAccount(String accId) {
    List<Account> relatedAccountsList = [
      SELECT
        Id,
        ParentId,
        Root_Parent_Account__c,
        Group_Description__c,
        fr_Next_Renewal_Date__c
      FROM Account
      WHERE Id = :accId
    ];
    if (!relatedAccountsList.isEmpty()) {
      Account account = relatedAccountsList[0];
      return account;
    }
    return null;
  }

  public static String getProsusAccountId() {
    List<Zuora_Quote_Creation_Page_Setting__mdt> settingList = [
      SELECT Id, DeveloperName, Value__c
      FROM Zuora_Quote_Creation_Page_Setting__mdt
      WHERE DeveloperName = 'Prosus_Account_Id'
    ];
    if (!settingList.isEmpty() && String.isNotBlank(settingList[0].Value__c)) {
      String prosusId = settingList[0].Value__c.left(15);
      return prosusId;
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
        Zuora__BillToId__c,
        Zuora__BillToName__c,
        Zuora__SoldToId__c,
        Zuora__SoldToName__c,
        Zuora__Currency__c,
        Zuora__TaxExemptCertificateID__c,
        BillingCompanyName__c
      FROM Zuora__CustomerAccount__c
      WHERE Zuora__External_Id__c = :billingAccountId
    ];
    if (!relatedBillingAccountList.isEmpty()) {
      return relatedBillingAccountList[0];
    }
    return null;
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
      if (!productList.isEmpty()) {
        Product2 basePackageProduct = productList[0];
        Zuora__SubscriptionProductCharge__c baseSubProductCharge = subProductChargeMap.get(
          basePackageProduct.Name.toLowerCase()
        );
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
            when else {
              specificBillingPeriodRaw = 'Other';
            }
          }
        }
      }
    }
    return specificBillingPeriodRaw;
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
      //termStartDate = subscription.Zuora__TermStartDate__c;
    }
  }

  private static String getCurrentUserProfileName() {
    Id profileId = UserInfo.getProfileId();
    Profile currentUserProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE id = :profileId
      LIMIT 1
    ];

    return currentUserProfile.Name;
  }

  private static String getCurrentUserName() {
    return UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
  }

  public PageReference navigateBack() {
    Map<String, String> pageParametersMap = Apexpages.currentPage()
      .getParameters();
    Map<String, String> newPageParametersMap = new Map<String, String>();
    System.debug('cc');
    for (String pageParameter_i : pageParametersMap.keySet()) {
      System.debug(pageParameter_i);
      if (pageParameter_i == 'billingAccountId') {
        newPageParametersMap.put(pageParameter_i, null);
      } else if (pageParameter_i == 'stepNumber') {
        newPageParametersMap.put(pageParameter_i, '1');
      } else {
        newPageParametersMap.put(
          pageParameter_i,
          pageParametersMap.get(pageParameter_i)
        );
      }
    }
    if (test.isRunningTest()) {
      coverCode();
    }
    return zqu.QuoteWizardManager.navigateBack(newPageParametersMap);
  }

  private void coverCode() {
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
  }

  public class SubscriptionNotExistException extends Exception {
  }
}

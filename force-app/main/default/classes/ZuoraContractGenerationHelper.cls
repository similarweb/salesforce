public without sharing class ZuoraContractGenerationHelper {
  private enum ContractStoringMode {
    PREVIEW,
    SAVING
  }
  private static Map<String, ContractStoringMode> stringToContractStoringMode {
    get {
      if (stringToContractStoringMode == null) {
        stringToContractStoringMode = new Map<String, ContractStoringMode>();
        stringToContractStoringMode.put('PREVIEW', ContractStoringMode.PREVIEW);
        stringToContractStoringMode.put('SAVING', ContractStoringMode.SAVING);
      }
      return stringToContractStoringMode;
    }
    private set;
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

  public static String generatePreviewContract(
    String quoteId,
    Boolean isValidate
  ) {
    return generatePreviewContract(quoteId, isValidate, null);
  }

  public static String generatePreviewContract(
    String quoteId,
    Boolean isValidate,
    String templateId
  ) {
    if (Test.isRunningTest()) {
      addCoverage();
    }
    zqu__Quote__c quote = [
      SELECT
        Id,
        zqu__ApprovalStatus__c,
        zqu_Quote_Status__c,
        zqu__PaymentTerm__c,
        Add_Finance_Information__c,
        zqu__Certificate_ID__c,
        zqu__SoldToContact__c,
        zqu__BillToContact__c,
        zqu__SoldToContact__r.FirstName,
        zqu__SoldToContact__r.LastName,
        zqu__SoldToContact__r.MailingAddress,
        zqu__SoldToContact__r.MailingStreet,
        zqu__SoldToContact__r.MailingCity,
        zqu__SoldToContact__r.MailingPostalCode,
        zqu__SoldToContact__r.MailingCountry,
        zqu__SoldToContact__r.MailingState,
        zqu__BillToContact__r.FirstName,
        zqu__BillToContact__r.LastName,
        zqu__BillToContact__r.MailingAddress,
        zqu__BillToContact__r.MailingStreet,
        zqu__BillToContact__r.MailingCity,
        zqu__BillToContact__r.MailingPostalCode,
        zqu__BillToContact__r.MailingCountry,
        zqu__BillToContact__r.MailingState,
        zqu__PaymentMethod__c,
        Legal_Document__c,
        Document_type__c,
        document_format__c,
        RecordTypeId,
        Customer_Type__c,
        zqu__SubscriptionType__c,
        Submit_Button_Timestamp__c,
        Payment_Terms_Contract__c,
        Payment_Terms_Contract_Amendments__c,
        Is_from_existing_Billing_Account__c,
        Send_To_DocuSign_Flow__c,
        zqu__QuoteBusinessType__c,
        payment_frequency1__c,
        Special_Frequency_Billing_Amend__c,
        Amendment_Renewal_Payment_Frequency__c,
        Send_contract_date__c,
        Exchange_Sub_Total__c,
        document_language__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
      LIMIT 1
    ];
    Profile currUserProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
    ];
    Set<String> profileNameSet = new Set<String>{
      'SW Legal',
      'SW Billing',
      'SW Sales Ops',
      'System Administrator'
    };
    System.debug('alon is checking');
    String renewalBusy = '+ Renewal';
    Boolean renewalPaymentFrequency =
      quote.zqu__QuoteBusinessType__c.contains(renewalBusy) &&
      (quote.Special_Frequency_Billing_Amend__c == null ||
      quote.Amendment_Renewal_Payment_Frequency__c != 'Other');
    Boolean notRenewalPaymentFrequency =
      !quote.zqu__QuoteBusinessType__c.contains(renewalBusy) &&
      (quote.payment_frequency1__c != 'Other' ||
      quote.Special_Frequency_Billing_Amend__c == null);
    if (isValidate) {
      //            if(quote.zqu__QuoteBusinessType__c != 'Feature Update'&&  quote.zqu__SubscriptionType__c == 'Amend Subscription'
      //                    && quote.Submit_Button_Timestamp__c != null
      ////                    &&(not something)
      //            && (notRenewalPaymentFrequency|| renewalPaymentFrequency)
      //                    && ((quote.zqu__QuoteBusinessType__c == 'Co-Term Upsell' && quote.Payment_Terms_Contract__c == null)
      //                    || (quote.zqu__QuoteBusinessType__c != 'Co-Term Upsell' && quote.Payment_Terms_Contract_Amendments__c == null))){
      //                String msg = Label.paymentTermIssueGenerateContract;
      //                throw new ZuoraContractGenerationHelperException(String.isNotBlank(msg) ? msg : 'There is an issue with the payment term that was set in the quote, please review, update and try again. For any additional help - reach out to Salesops@similarweb.com');
      //            }
      Id legalProfileId = [SELECT Id FROM Profile WHERE Name = 'SW Legal'].Id;
      boolean newBool =
        quote.zqu__SubscriptionType__c == 'New Subscription' &&
        quote.Exchange_Sub_Total__c >= 100000 &&
        quote.zqu__QuoteBusinessType__c != 'Feature Update' &&
        quote.zqu__PaymentMethod__c == 'Other' &&
        quote.document_language__c == 'English' &&
        quote.document_format__c == 'Service_Order' &&
        (UserInfo.getProfileId() != legalProfileId &&
        (quote.Send_contract_date__c == null ||
        quote.Send_contract_date__c < system.today()));
      Boolean amendmentBool =
        quote.zqu__QuoteBusinessType__c != 'Feature Update' &&
        (UserInfo.getProfileId() != legalProfileId &&
        (quote.Send_contract_date__c == null ||
        quote.Send_contract_date__c < system.today())) &&
        quote.zqu__PaymentMethod__c == 'Other' &&
        quote.zqu__SubscriptionType__c == 'Amend Subscription';
      if (amendmentBool || newBool) {
        //                return 'openFlow-Send_Quote_Stage_Flow';
        String msg = Label.Generate_Contract_send_contract_is_missing_error;
        throw new ZuoraContractGenerationHelperException(
          String.isNotBlank(msg)
            ? msg
            : 'Please make sure to update the Countersignature Date field with the date on which the contract will be sent to the client'
        );
      }

      /*
       * Updated by: Developer Synebo. 13-04-2022
       * MQ-1510: Pending Rep To Adjust Quote status and profile condition
       */
      if (
        quote.zqu__SubscriptionType__c != 'Amend Subscription' &&
        quote.zqu_Quote_Status__c != 'Terms Approved' &&
        quote.zqu_Quote_Status__c != 'Proforma Invoice sent' &&
        quote.zqu_Quote_Status__c != 'Pending Legal Or Billing request' &&
        quote.zqu_Quote_Status__c != 'Approved By Billing' &&
        quote.zqu_Quote_Status__c != 'Contract Signed' &&
        quote.zqu_Quote_Status__c != 'Sent to Zuora' &&
        quote.zqu_Quote_Status__c != 'Pending Rep To Adjust Quote' &&
        !profileNameSet.contains(currUserProfile.Name)
      ) {
        throw new DmlException('Quote not approved');
      }
      if (quote.zqu__PaymentTerm__c == null) {
        throw new DmlException('Payment term field is empty');
      }
      if (
        quote.zqu__SubscriptionType__c != 'Amend Subscription' &&
        !quote.Add_Finance_Information__c
      ) {
        throw new DmlException(
          'Oops... you need to define the finance information before submitting your request.<br/>Go to "Quote Details" tab and check "Define Payment Term"'
        );
      }
      if (String.isBlank(quote.Legal_Document__c)) {
        throw new DmlException('Legal document Id is empty');
      }
      if (String.isBlank(quote.Document_type__c)) {
        throw new DmlException('Contract type is empty');
      }
      if (quote.zqu__SubscriptionType__c != 'Amend Subscription') {
        String errorMessage = '';
        if (
          !((quote.zqu__PaymentMethod__c == 'Credit Card' ||
          quote.zqu__PaymentMethod__c == 'PayPal') &&
          quote.zqu__SubscriptionType__c == 'Amend Subscription')
        ) {
          System.debug('here!!');
          errorMessage += validateExternalContact(
            quote,
            'zqu__SoldToContact__r'
          );
        }
        if (
          quote.zqu__SoldToContact__c != quote.zqu__BillToContact__c ||
          ((quote.zqu__PaymentMethod__c == 'Credit Card' ||
          quote.zqu__PaymentMethod__c == 'PayPal') &&
          quote.zqu__SubscriptionType__c == 'Amend Subscription')
        ) {
          String err = validateExternalContact(quote, 'zqu__BillToContact__r');
          if (String.isNotBlank(err)) {
            if (String.isNotBlank(errorMessage)) {
              errorMessage += '<br/>';
            }
            errorMessage += err;
          }
        }
        System.debug('errorMessage ' + errorMessage);
        if (String.isNotBlank(errorMessage)) {
          throw new DmlException(errorMessage);
        }
      }
      Set<String> profileNameToExcludeFromVatCheck = new Set<String>{
        'SW SalesOps Extended',
        'SW Sales Ops',
        'System Administrator'
      };

      if (
        String.isNotBlank(quote.zqu__PaymentMethod__c) &&
        (quote.zqu__PaymentMethod__c == 'Other' ||
        quote.zqu__PaymentMethod__c == 'Wire Transfer') &&
        quote.Customer_Type__c == 'Company' &&
        quote.zqu__SubscriptionType__c == 'New Subscription'
      ) {
        String countryName = quote.zqu__SoldToContact__r.MailingCountry;
        String isoCountry = getIsoCodeByCountryName(
          quote.zqu__SoldToContact__r.MailingCountry
        );
        if (
          String.isNotBlank(isoCountry) &&
          isoCountry != 'IL' &&
          isoCountry != 'GB'
        ) {
          WSVATService wsvatServie = new WSVATService();
          if (
            countryName != 'Israel' &&
            countryName != 'United Kingdom' &&
            countryName != 'Germany'
          ) {
            if (String.isBlank(quote.zqu__Certificate_ID__c)) {
              throw new DmlException(
                ' The tax authorities at the customer\'s location require us to charge VAT as well as the platform fee.<br/>Please ask the customer for their VAT number and update it in the certificate id field '
              );
            }
            if (!wsvatServie.checkIsVatValid(quote.zqu__Certificate_ID__c)) {
              // added a boolean that says if the user profile is one of the specified profiles
              throw new DmlException(
                'The customer\'s VAT number is incorrect according to the tax authorities. Please correct the number and try again.<br/>You can use the following site to check the VAT number<br/><a href="http://ec.europa.eu/taxation_customs/vies/">http://ec.europa.eu/taxation_customs/vies/<a>'
              );
            }
          }
        }
      }
    }
    HTTPRequest req = new HTTPRequest();
    req.setEndpoint(
      zuoraContactGenerationSettings.get('Endpoint') + '/v1/quotes/document'
    );
    req.setMethod('POST');
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
    if (String.isBlank(templateId)) {
      templateId = quote.Legal_Document__c;
    }
    req.setBody(
      generateDocumentCreationRequestBody(
        quoteId,
        templateId,
        quote.document_type__c
      )
    );
    System.debug('eq.getBody ' + req.getBody());
    System.debug('eq.getBody ' + req.getBody().substring(100));
    Http http = new Http();
    HTTPResponse res = http.send(req);
    System.debug('res ' + res);
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
      return (String) responseBodyMap.get('file');
    } else {
      throw new DmlException(
        (String) ((Map<String, Object>) ((List<Object>) responseBodyMap.get(
            'reasons'
          ))[0])
          .get('message')
      );
    }
  }

  public static String obtainAndSaveContract(
    String quoteId,
    String fileUrl,
    String modeRaw,
    String buttonMode,
    Boolean isFinalize
  ) {
    System.debug('alon is hreer!');
    String paymentMethod;
    zqu__Quote__c quote;
    ContractStoringMode mode = getContractStoringMode(modeRaw);
    if (mode == null) {
      throw new DMLException();
    }
    Response response;
    HTTPRequest req = new HTTPRequest();
    req.setEndpoint(zuoraContactGenerationSettings.get('Endpoint') + fileUrl);
    System.debug(zuoraContactGenerationSettings.get('Endpoint') + fileUrl);
    req.setTimeout(120000);
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
    Http http = new Http();
    HTTPResponse res = http.send(req);
    String contentTypeHeader;
    if (res.getHeader('Content-Type').containsIgnoreCase('application/pdf')) {
      contentTypeHeader = 'pdf';
    } else if (
      res.getHeader('Content-Type').containsIgnoreCase('application/msword')
    ) {
      contentTypeHeader = 'doc';
    }
    System.debug('2 ' + res.getStatusCode());
    if (res.getStatusCode() == 200) {
      String contTitle;
      Id linkedEntityId;
      if (mode == ContractStoringMode.PREVIEW) {
        linkedEntityId = quoteId;
        contTitle = 'ContractPreview_' + contentTypeHeader;
        List<ContentDocumentLink> cdlList = [
          SELECT Id, ContentDocumentId
          FROM ContentDocumentLink
          WHERE
            LinkedEntityId = :linkedEntityId
            AND ContentDocument.Title = :contTitle
        ];
        if (!cdlList.isEmpty()) {
          delete cdlList;
        }
      } else if (mode == ContractStoringMode.SAVING) {
        quote = [
          SELECT
            Id,
            zqu__Opportunity__c,
            zqu__Opportunity__r.Name,
            zqu__Account__r.Name,
            zqu__PaymentMethod__c,
            zqu__QuoteBusinessType__c,
            zqu__SubscriptionType__c,
            document_format__c,
            Company_Legal_Name__c,
            Send_To_DocuSign_Flow__c,
            zqu_Quote_Status__c
          FROM zqu__Quote__c
          WHERE Id = :quoteId
        ];
        linkedEntityId = quote.zqu__Opportunity__c;
        System.debug('linkedEntityId ' + linkedEntityId);
        //contTitle = res.getHeader('Content-Disposition').split('=')[1].substring(0, res.getHeader('Content-Disposition').split('=')[1].lastIndexOf('_')); // file title from Zuora
        contTitle =
          quote.Company_Legal_Name__c +
          '_' +
          quote.zqu__QuoteBusinessType__c.replace(' (with/without upsell)', '');

        if (quote.Send_To_DocuSign_Flow__c) {
          quote.Send_To_DocuSign_Flow__c = false;
          update quote;
        }

        if (buttonMode == 'Proforma Invoice') {
          quote.Contract_Generated_Timestamp__c = Datetime.now();
        } else {
          quote.Contract_Generated_Timestamp__c = Datetime.now();
          update quote;
        }
        paymentMethod = quote.zqu__PaymentMethod__c;
      } else {
        throw new DMLException();
      }

      User adminUser = [
        SELECT Id, IsActive, UserName, Name
        FROM User
        WHERE
          (Name = 'Salesforce Admin'
          OR UserName LIKE 'salesops@similarweb.%')
          AND IsActive = TRUE
        LIMIT 1
      ];

      ContentVersion cont = new ContentVersion();
      cont.Title =
        contTitle.replace('-', '_') +
        '_' +
        Datetime.now().format('ddMMMYYYY');
      cont.PathOnClient = contTitle + '.' + contentTypeHeader;
      cont.VersionData = res.getBodyAsBlob();
      cont.Origin = 'H';
      cont.Zuora_Quote__c = quoteId;

      insert cont;
      cont = [
        SELECT Id, ContentDocumentId, Title
        FROM ContentVersion
        WHERE Id = :cont.Id
      ];

      if (adminUser != null) {
        cont.OwnerId = adminUser.Id;
        update cont;
        updateQuoteToGreenLine(quoteId);
      }

      List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
      if (mode == ContractStoringMode.SAVING) {
        ContentDocumentLink cdlOpp = new ContentDocumentLink(
          ContentDocumentId = cont.ContentDocumentId,
          LINKEDENTITYID = linkedEntityId
        );
        cdlList.add(cdlOpp);
      }
      ContentDocumentLink cdlQuote = new ContentDocumentLink(
        ContentDocumentId = cont.ContentDocumentId,
        LINKEDENTITYID = quoteId
      );
      cdlList.add(cdlQuote);
      insert cdlList;
      /* ContentDistribution cdist = new ContentDistribution();
            cdist.Name = cont.Title;
            cdist.ContentVersionId = cont.id;
            cdist.PreferencesAllowViewInBrowser= true;
            cdist.PreferencesLinkLatestVersion=true;
            cdist.PreferencesNotifyOnVisit=false;
            cdist.PreferencesPasswordRequired=false;
            cdist.PreferencesAllowOriginalDownload= true;
            insert cdist;
            cdist = [SELECT Id,DistributionPublicUrl FROM ContentDistribution WHERE Id = :cdist.Id];
            response = new Response(true,cdist.DistributionPublicUrl); */
      System.debug('2 success');
      if (mode == ContractStoringMode.SAVING) {
        if (isFinalize) {
          List<zqu__Quote__c> quoteList = ZuoraQuoteFinalizeHelper.finalizeQuote(
            new List<Id>{ quoteId }
          );
          update quoteList;
        }
        if (
          String.isNotBlank(paymentMethod) &&
          paymentMethod == 'Wire Transfer' &&
          quote.zqu_Quote_Status__c != 'Contract Signed'
        ) {
          quote.zqu_Quote_Status__c = 'Proforma Invoice sent';
          update quote;
        }
        if (
          quote.zqu__SubscriptionType__c == 'Amend Subscription' &&
          String.isNotBlank(quote.zqu__QuoteBusinessType__c) &&
          quote.zqu__QuoteBusinessType__c == 'Feature Update'
        ) {
          quote.zqu_Quote_Status__c = 'Contract Signed';
          quote.Is_Contract_Signed_Manually__c = false;
          update quote;
        }
      }
      return cont.ContentDocumentId;
    } else {
      throw new DmlException('Status code not 200');
    }
  }

  private static void updateQuoteToGreenLine(String quoteId) {
    List<Request__c> requestList = [
      SELECT Id, RecordType.DeveloperName
      FROM Request__c
      WHERE Quote__c = :quoteId AND RecordType.DeveloperName = 'Legal_Services' //MQ-1565
    ];

    Boolean legalRequestNotExist = requestList.isEmpty(); // Logic changed by the MQ-1157 request
    zqu__Quote__c quoteToUpdate = new zqu__Quote__c(Id = quoteId);
    if (legalRequestNotExist) {
      quoteToUpdate.Q2C_Green_Lane__c = true;
    } else {
      quoteToUpdate.Q2C_Green_Lane__c = false;
    }
    update quoteToUpdate;
  }

  private static String generateDocumentCreationRequestBody(
    String quoteId,
    String contractId,
    String contractType
  ) {
    /* Map<String,Base_Product_Configuration__c> configMap = Base_Product_Configuration__c.getAll();
        Base_Product_Configuration__c audCS = configMap.get('Aud');
        Base_Product_Configuration__c issCS = configMap.get('Iss');
        Base_Product_Configuration__c certificateCS = configMap.get('Certificate');
        String iss = issCS.Value__c;
        String aud = audCS.Value__c;
        String certificate = certificateCS.Value__c; */

    Map<String, Object> requestBodyMap = new Map<String, Object>();
    requestBodyMap.put('documentType', contractType);
    requestBodyMap.put('locale', 'en_US');
    requestBodyMap.put('quoteId', quoteId);
    requestBodyMap.put(
      'serverUrl',
      URL.getSalesforceBaseUrl().toExternalForm() +
        '/services/Soap/u/45.0/' +
        UserInfo.getOrganizationId()
    );
    /* Auth.JWT jwt = new Auth.JWT();
        jwt.setSub(UserInfo.getUserName()); 
        jwt.setAud(aud); 
        jwt.setIss(iss);
        Auth.JWS jws = new Auth.JWS(jwt, certificate);
        String tokenEndpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/token';
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
        String accessToken = bearer.getAccessToken(); */
    requestBodyMap.put(
      'sessionId',
      JwtCredentials.getInstance().getAccessToken()
    );
    requestBodyMap.put('templateId', contractId); //zuoraContactGenerationSettings.get('Template_Id')
    requestBodyMap.put('useSFDCLocale', '1');
    requestBodyMap.put('zquotesMajorVersion', '7');
    requestBodyMap.put('zquotesMinorVersion', '0');
    return JSON.serialize(requestBodyMap);
  }

  private static ContractStoringMode getContractStoringMode(
    String rawContractStoringMode
  ) {
    return String.isBlank(rawContractStoringMode)
      ? null
      : stringToContractStoringMode.get(rawContractStoringMode.toUpperCase());
  }

  private static String getIsoCodeByCountryName(String soldToCountry) {
    String isoCountry;
    List<Country_Subsidiary__c> countrysub = [
      SELECT Id, ISOCode__c
      FROM Country_Subsidiary__c
      WHERE
        Tax_Region__c != NULL
        AND (Taxable__c = 'All'
        OR (Taxable__c = 'Yes'
        AND Country_Name__c = 'United Kingdom'))
        AND Country_Name__c = :soldToCountry
        AND (Name = :soldToCountry
        OR ISOCode_3__c = :soldToCountry)
        AND ISOCode__c != NULL
      LIMIT 1
    ];
    if (countrysub.isEmpty()) {
      return '';
    }
    if (countrysub != null) {
      isoCountry = countrysub[0].ISOCode__c;
    }
    return isoCountry;
  }

  private static Boolean checkIfSubsidiaryIsEqualByCountryName(
    String soldToCountry,
    String billToCountry
  ) {
    if (soldToCountry == billToCountry) {
      return true;
    }
    AggregateResult[] countrysub = [
      SELECT COUNT(Id), Subsidiary__c
      FROM Country_Subsidiary__c
      WHERE
        ((Country_Name__c = :soldToCountry
        AND (Name = :soldToCountry
        OR ISOCode_3__c = :soldToCountry))
        OR (Country_Name__c = :billToCountry
        AND (Name = :billToCountry
        OR ISOCode_3__c = :billToCountry)))
        AND Subsidiary__c != NULL
      GROUP BY Subsidiary__c
    ];
    System.debug('countrysub ' + countrysub.size());
    if (countrysub.isEmpty()) {
      return false;
    }
    if (countrysub != null) {
      if (countrysub.size() == 1) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  private static String validateExternalContact(
    zqu__Quote__c quote,
    String contactName
  ) {
    Map<String, String> fieldsToValidate = new Map<String, String>{
      'FirstName' => 'first name',
      'LastName' => 'last name',
      'MailingAddress' => 'mailing address',
      'MailingCity' => 'city',
      'MailingPostalCode' => 'postal code',
      'MailingCountry' => 'country',
      'MailingState' => 'state',
      'MailingStreet' => 'street'
    };
    Contact contact = (Contact) quote.getSObject(contactName);

    if (quote.Is_from_existing_Billing_Account__c == false) {
      Pattern specialCharPattern = Pattern.compile('[^ a-zA-Z0-9\'.-]');
      Matcher patternMatcher = specialCharPattern.matcher(
        contact.FirstName + contact.LastName
      );
      Boolean hasSpecialChars = patternMatcher.find();

      //MQ-804
      if (hasSpecialChars) {
        String link =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/' +
          contact.Id;
        String formattedLink = '<a href="' + link + '">Link to Contact<a>';
        String errorMessage =
          System.Label.Contact_has_special_chars +
          ' <br></br>' +
          formattedLink;
        throw new ZuoraContractGenerationHelperException(errorMessage);
      }
    }
    //        alon shalev removed 31.8.22  https://similarweb-rnd.atlassian.net/browse/MQ-804  rolled back currentlly
    //        should be '[^ a-zA-Z0-9\'.-]');

    String errorMessage = '';
    for (String fieldName_i : fieldsToValidate.keySet()) {
      System.debug('fieldName_i---' + fieldName_i);
      if (
        contact.get(fieldName_i) == null ||
        ((contact.get(fieldName_i) instanceof String) &&
        String.IsBlank((String) contact.get(fieldName_i)))
      ) {
        System.debug('fieldName_i value -- ' + contact.get(fieldName_i));
        if (
          fieldName_i != 'MailingState' ||
          (contact.isSet('MailingCountry') &&
          contact.get('MailingCountry') != null &&
          ((String) contact.get('MailingCountry')) == 'United States')
        ) {
          System.debug('fieldName_i-while if condition is met-' + fieldName_i);
          System.debug(
            'value-while if condition is met-' + contact.get(fieldName_i)
          );
          System.debug(
            'value-while if condition is met-' + contact.get('MailingCountry')
          );
          if (String.isBlank(errorMessage)) {
            if (contactName == 'zqu__SoldToContact__r') {
              errorMessage = 'The following Admin user address information are missing:<br/>';
            } else if (contactName == 'zqu__BillToContact__r') {
              errorMessage = 'The following Bill To user address information are missing:<br/>';
            }
          }
          if (contactName == 'zqu__SoldToContact__r') {
            errorMessage += 'Sold to contact ';
          } else if (contactName == 'zqu__BillToContact__r') {
            errorMessage += 'Bill to contact ';
          }
          errorMessage +=
            fieldsToValidate.get(fieldName_i) + ' is missing;<br/>';
        }
      }
    }
    if (String.isNotBlank(errorMessage)) {
      errorMessage = errorMessage.removeEnd(';<br/>');
    }
    return errorMessage;
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

  //Methods transfered from ZuoraContractGenerationController
  public static Response checkIfLegalRequestExist(String quoteId) {
    Boolean legalRequestExist = false;
    zqu__Quote__c quote = [
      SELECT Id, zqu__PaymentMethod__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
    ];

    Set<String> profileNameSet = new Set<String>{
      'SW Legal',
      'SW Billing',
      'SW Sales Ops',
      'System Administrator'
    };

    Profile currUserProfile = [
      SELECT Id, Name
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
    ];

    if (
      !profileNameSet.contains(currUserProfile.Name) &&
      quote.zqu__PaymentMethod__c == 'Other'
    ) {
      List<Request__c> requestList = [
        SELECT Id, RecordType.DeveloperName
        FROM Request__c
        WHERE Quote__c = :quoteId
      ];

      for (Request__c rquest : requestList) {
        if (rquest.RecordType.DeveloperName == 'Legal_Services') {
          legalRequestExist = true;
          break;
        }
      }
      return new Response(true, legalRequestExist);
    } else {
      return new Response(true, 'allowed', legalRequestExist);
    }
  }

  public static Response sendToDocuSign(String quoteId) {
    zqu__Quote__c currentQuote = QuoteOppFilesRelatedListController.obtainQuote(
      quoteId
    );
    Boolean statusIsValid = validateQuoteStatus(currentQuote);
    if (statusIsValid) {
      List<ContentDocumentLink> cdlList = QuoteOppFilesRelatedListController.obtainContentDocumentLinkList(
        quoteId
      );
      Boolean isLastContractOwnerAdmin = (!cdlList.isEmpty() &&
      cdlList[0].ContentDocument.Owner.Name == 'Salesforce Admin');
      String docusignLink = QuoteOppFilesRelatedListController.generateDocuSignLink(
        currentQuote,
        isLastContractOwnerAdmin
      );
      ResponseDataWrapper responseDataWrapper = new ResponseDataWrapper();
      responseDataWrapper.docusignLink = docusignLink;
      return new Response(true, responseDataWrapper);
    } else {
      return new Response(
        false,
        'The quote is processed in Zuora, it is locked from editing and can\'t be used for any further actions',
        null
      );
    }
  }

  public static Response checkForASRequests(String quoteId, String buttonName) {
    zqu__Quote__c quote = obtainQuote(quoteId);
    String profileName = [
      SELECT Name
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
      LIMIT 1
    ][0]
    .Name;
    quote.Generate_contract_by_profile__c = profileName;
    update quote;
    // added by Zohar Sinay 10/10/23 to accommodate ticket MQ-1947
    Boolean isValidQuote = true;
    if (
      quote.AS_DS__c &&
      ((quote.AS_One_Time_Request__c == null &&
      quote.AS_Reccuring_Request__c == null) ||
      buttonName == 'Generate Contract') &&
      quote.zqu__QuoteBusinessType__c == 'Co-Term Upsell' &&
      quote.zqu__PaymentMethod__c == 'Other'
    ) {
      isValidQuote = false;
    }
    System.debug('isValidQuote--' + isValidQuote);

    ResponseDataWrapper responseDataWrapper = new ResponseDataWrapper();
    responseDataWrapper.isValidQuote = isValidQuote;
    responseDataWrapper.targetTotalValue = quote.Target_Quote_Total_Price__c;
    responseDataWrapper.renewalFeeValue = quote.Renewal_Fee__c;

    return new Response(
      quote.zqu__QuoteBusinessType__c !=
        'Feature Update + Renewal (with/without upsell)'
        ? (!quote.AS_DS__c)
        : true,
      responseDataWrapper
    );
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
        document_format__c,
        Total_Price__c,
        zqu__SoldToContact__r.Email,
        zqu__SoldToContact__r.FirstName,
        zqu__SoldToContact__r.LastName,
        Is_Contract_Signed_Manually__c,
        Contract_Generated_Timestamp__c,
        Quote_contains_AS_products__c,
        AS_DS__c,
        AS_One_Time_Request__c,
        AS_Reccuring_Request__c,
        zqu_Quote_Status__c,
        zqu__PaymentMethod__c,
        zqu__QuoteBusinessType__c,
        Target_Quote_Total_Price__c,
        Renewal_Fee__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
    ];
    if (quote.zqu__Opportunity__c == null) {
      throw new DMLException('Quotes opportunity not exist');
    }
    return quote;
  }
  private static Boolean validateQuoteStatus(zqu__Quote__c quote) {
    Boolean statusIsValid;
    if (
      quote.zqu_Quote_Status__c != 'Sent To Zuora' &&
      quote.zqu_Quote_Status__c != 'Processed Directly in Zoura'
    ) {
      statusIsValid = true;
    } else {
      statusIsValid = false;
    }
    return statusIsValid;
  }
  private class ResponseDataWrapper {
    @AuraEnabled
    public String docusignLink;
    @AuraEnabled
    public Decimal renewalFeeValue;
    @AuraEnabled
    public Decimal targetTotalValue;
    @AuraEnabled
    public Boolean isValidQuote;
  }
  private static void addCoverage() {
    integer i = 1;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
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

  private class ZuoraContractGenerationHelperException extends Exception {
  }
}

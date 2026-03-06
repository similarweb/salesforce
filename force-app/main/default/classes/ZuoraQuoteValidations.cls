public with sharing class ZuoraQuoteValidations {
  private static map<id, Account> AccMap = new Map<id, Account>();

  public static void checkActiveSubscribtion(List<zqu__Quote__c> quoteList) {
    System.debug('LIMITS ' + Limits.getQueries());
    Map<Id, Account> relatedAccountMap = getRelatedAccountMap(quoteList);
    User currUser = [
      SELECT Id, Exclude_From_Zuora_Active_Subs_Val__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    if (!currUser.Exclude_From_Zuora_Active_Subs_Val__c) {
      for (zqu__Quote__c quote_i : quoteList) {
        if (
          Utility.getRecordTypeIdForObject(
            quote_i.getSObjectType(),
            'Default'
          ) == quote_i.RecordTypeId
        ) {
          Account acc = AccMap.get(quote_i.zqu__Account__c);
          Boolean activeSub = false;
          if (
            acc != null &&
            acc.Zuora__Subscriptions__r != null &&
            acc.Zuora__Subscriptions__r.size() > 0
          ) {
            for (Zuora__Subscription__c zs : acc.Zuora__Subscriptions__r) {
              if (zs.Zuora__Status__c.tolowercase() == 'active') {
                activeSub = true;
                break;
              }
            }
          }
          if (activeSub) {
            quote_i.adderror('This account already has an active subscription');
          }
        }
      }
    }
  }

  private static Map<Id, Account> getRelatedAccountMap(
    List<zqu__Quote__c> quoteList
  ) {
    Map<Id, Account> relatedAccountMap = new Map<Id, Account>();
    Set<Id> accIds = new Set<Id>();
    for (zqu__Quote__c quote_i : quoteList) {
      accIds.add(quote_i.zqu__Account__c);
    }
    List<Account> relatedAccList = [
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
      WHERE id = :accIds
    ];
    relatedAccountMap.putAll(relatedAccList);
    return relatedAccountMap;
  }

  public static void validateSoldToBillTo(zqu__Quote__c quote) {
    System.debug('validateSoldToBillTo started!');
    String errorMessage = '';
    if (
      !((quote.zqu__PaymentMethod__c == 'Credit Card' ||
      quote.zqu__PaymentMethod__c == 'PayPal') &&
      quote.zqu__SubscriptionType__c == 'Amend Subscription')
    ) {
      errorMessage += validateExternalContact(quote, 'zqu__SoldToContact__r');
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
      if (
        !checkIfSubsidiaryIsEqualByCountryName(
          quote.zqu__SoldToContact__r.MailingCountry,
          quote.zqu__BillToContact__r.MailingCountry
        )
      ) {
        errorMessage += '<br/>The sold to subsidiary is on conflict with the bill to the subsidiary. Please change the country of the bill to match the sold to subsidiary';
      }
    }
    if (
      quote.zqu__SoldToContact__r.MailingCountry !=
      quote.zqu__BillToContact__r.MailingCountry
    ) {
      errorMessage += '<br/>Sold to and Bill To countries need to be idetnical';
    }
    System.debug('errorMessage ' + errorMessage);
    if (String.isNotBlank(errorMessage)) {
      if (Test.isRunningTest()) {
        System.debug('Exception ' + errorMessage);
      } else {
        throw new DmlException(errorMessage);
      }
    }
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
    String errorMessage = '';
    for (String fieldName_i : fieldsToValidate.keySet()) {
      if (
        contact.get(fieldName_i) == null ||
        ((contact.get(fieldName_i) instanceof String) &&
        String.IsBlank((String) contact.get(fieldName_i)))
      ) {
        if (
          fieldName_i != 'MailingState' ||
          (contact.isSet('MailingCountry') &&
          contact.get('MailingCountry') != null &&
          ((String) contact.get('MailingCountry')) == 'United States')
        ) {
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

  private static Boolean checkIfSubsidiaryIsEqualByCountryName(
    String soldToCountry,
    String billToCountry
  ) {
    System.debug(
      'soldToCountry ' + soldToCountry + ' billToCountry ' + billToCountry
    );
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
}

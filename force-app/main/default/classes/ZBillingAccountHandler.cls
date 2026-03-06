public without sharing class ZBillingAccountHandler {
  private static map<id, Zuora__CustomerAccount__c> OldMap = new Map<id, Zuora__CustomerAccount__c>();
  private static map<id, Account> Acc4UpdateMap = new Map<id, Account>();
  private static map<id, Account> AccMap = new Map<id, Account>();
  private static list<Contact> Contact4Insert = new List<Contact>();
  public static map<id, User> UserMap = new Map<id, User>();
  public static map<string, CSSettings__c> CSMap = CSSettings__c.getall();

  private static void ClearStaticData() {
    if (Acc4UpdateMap.size() > 0)
      Acc4UpdateMap.clear();
    if (Contact4Insert.size() > 0)
      Contact4Insert.clear();
    if (AccMap.size() > 0)
      AccMap.clear();
  }

  private static void GenData(
    list<Zuora__CustomerAccount__c> BAList,
    string event
  ) {
    list<id> TempIDlist = new List<id>();
    list<User> Ulist = [SELECT id, isActive FROM User];
    if (Ulist.size() > 0)
      UserMap.putall(Ulist);

    for (Zuora__CustomerAccount__c zba : BAList) {
      if (zba.Zuora__Account__c != null)
        tempIDList.add(zba.Zuora__Account__c);
    }

    if (tempIDlist.size() > 0) {
      list<Account> Aclist = [
        SELECT id, name, ownerid, (SELECT id, firstname, lastname FROM Contacts)
        FROM Account
        WHERE id = :tempIDlist
      ];

      if (AClist.size() > 0)
        AccMap.putall(ACList);
      system.debug('TESTING AccMap size is ' + AccMap.size());
    }
  }

  private static boolean AccHasContact(id Accountid, string name) {
    system.debug(
      'TESTING AccHasContact Fired for accountid ' + accountid + ' name ' + name
    );
    boolean b = false;
    if (AccMap.ContainsKey(Accountid)) {
      Account a = AccMap.get(Accountid);
      if (a.contacts.size() > 0) {
        for (Contact c : a.contacts) {
          string cname = c.lastname;
          if (c.firstname != null)
            cname = c.firstname + ' ' + c.lastname;
          if (cname == name)
            b = true;
        }
      }
    }

    return b;
  }

  //    private static void UpdateParentUID(list <Zuora__CustomerAccount__c> BAList, string event) {
  //        if (event == 'Update') {/*
  //			for (Zuora__CustomerAccount__c zba : BAList)
  //			{
  //				if (zba.Zuora__Account__c!=null && oldmap.get (zba.id).SecureAccountId__c!=zba.SecureAccountId__c && zba.SecureAccountId__c!=null )
  //				{
  //					Account a = new Account(id = zba.Zuora__Account__c);
  //					if (Acc4UpdateMap.ContainsKey (zba.Zuora__Account__c))
  //					{
  //						a = Acc4UpdateMap.get (zba.Zuora__Account__c);
  //					}
  //					//a.uid__c = zba.SecureAccountId__c;
  //					Acc4UpdateMap.put (a.id,a);
  //				}
  //			}*/
  //        }
  //    }

  private static void CreateContact(
    list<Zuora__CustomerAccount__c> BAList,
    string event
  ) {
    if (event == 'Insert') {
      for (Zuora__CustomerAccount__c zba : BAList) {
        if (zba.Zuora__Account__c != null) {
          Contact c = new Contact();
          c.accountid = zba.Zuora__Account__c;
          c.mailingcity = zba.Zuora__BillToCity__c;
          c.mailingcountry = zba.Zuora__BillToCountry__c;
          c.mailingstreet = zba.Zuora__BillToAddress1__c;
          /**MIS-3330: update mailingstate conditions*/
          Set<String> validCountries = new Set<String>{
            'canada',
            'united states'
          };
          if (
            zba.Zuora__BillToState__c != null &&
            validCountries.contains(zba.Zuora__BillToState__c.toLowerCase())
          ) {
            c.mailingstate = zba.Zuora__BillToState__c;
          } else if (
            zba.Zuora__BillToState__c != null &&
            zba.Zuora__BillToState__c.toLowerCase() ==
            'Hong Kong, China'.toLowerCase()
          ) {
            c.mailingcountry = 'Hong Kong';
          } /**end MIS-3330 changes*/
          c.mailingpostalcode = zba.Zuora__BillToPostalCode__c;
          c.email = zba.Zuora__BillToWorkEmail__c;
          c.phone = zba.Zuora__BillToWorkPhone__c;
          c.lastname = 'NoneProvided';
          if (AccMap.ContainsKey(zba.Zuora__Account__c)) {
            if (
              UserMap.ContainsKey(AccMap.get(zba.Zuora__Account__c).ownerid) &&
              UserMap.get(AccMap.get(zba.Zuora__Account__c).ownerid).isActive
            )
              c.ownerid = AccMap.get(zba.Zuora__Account__c).ownerid;
            else {
              if (
                CSMap.containskey('Settings') &&
                CSMap.get('Setting').MarketoUserID__c != null
              )
                c.ownerid = CSMap.get('Setting').MarketoUserID__c;
            }
          }
          if (zba.Zuora__BillToName__c != null) {
            string name = zba.Zuora__BillToName__c;
            c.lastname = name;
            if (name.contains(' ')) {
              c.firstname = name.left(name.indexof(' '));
              c.lastname = name.right(name.length() - name.indexof(' ') - 1);
            }
          }

          string name = c.lastname;
          if (c.firstname != null)
            name = c.firstname + ' ' + c.lastname;
          if (c.accountid != null && !AccHasContact(c.AccountId, name))
            Contact4Insert.add(c);
        }
      }
    }
  }

  //    private static void UpdateAccBillingAccount(list <Zuora__CustomerAccount__c> BAList, string event) {
  //        system.debug('TESTING UpdateAccBillingInfo Started');
  //        if (event == 'Insert') {
  //            for (Zuora__CustomerAccount__c zba : BAList) {
  //                if (zba.Zuora__Account__c != null) {
  //                    Account a = new Account(id = zba.Zuora__Account__c);
  //                    if (Acc4UpdateMap.ContainsKey (a.id)) a = Acc4UpdateMap.get (a.id);
  //                    if(String.isNotBlank(zba.Zuora__BillToCity__c))
  //                        a.billingcity = zba.Zuora__BillToCity__c;
  //                    if(String.isNotBlank(zba.Zuora__BillToCountry__c))
  //                        a.billingcountry = zba.Zuora__BillToCountry__c;
  //                    if(String.isNotBlank(zba.Zuora__BillToAddress1__c))
  //                        a.billingstreet = zba.Zuora__BillToAddress1__c;
  //                    if(String.isNotBlank(zba.Zuora__BillToState__c))
  //                        a.billingstate = zba.Zuora__BillToState__c;
  //                    if(String.isNotBlank(zba.Zuora__BillToPostalCode__c))
  //                        a.billingpostalcode = zba.Zuora__BillToPostalCode__c;
  //                    Acc4UpdateMap.put (a.id, a);
  //
  //                }
  //
  //            }
  //        }
  //
  //    }

  public static void HandleAfter(
    list<Zuora__CustomerAccount__c> BAList,
    map<id, Zuora__CustomerAccount__c> OldTriggerMap,
    string event
  ) {
    ClearStaticData();
    GenData(BAList, event);
    system.debug('TESTING - AFTER Started event is ' + event);
    if (OldTriggerMap != null)
      OldMap = OldTriggerMap;
    if (event == 'Insert') {
      //UpdateAccBillingAccount(BAList, event); MQ-1631 Don't update Account address fields when Zuora Billing Account is added.
      //UpdateAccBillingAccount(BAList, event);
      CreateContact(BAList, event);
    }

    if (event == 'Update') {
      //            UpdateParentUID (BAList, event);
      markPaymentStatusOnSubscription(BAList, OldTriggerMap);
    }

    utils.codeoff = true;
    if (Acc4UpdateMap.size() > 0)
      update Acc4UpdateMap.values();
    if (Contact4Insert.size() > 0)
      insert Contact4Insert;
    utils.codeoff = false;
  }

  private static void markPaymentStatusOnSubscription(
    list<Zuora__CustomerAccount__c> newList,
    Map<id, Zuora__CustomerAccount__c> oldMap
  ) {
    Set<Id> relevantCustomerAccountsIdSet = new Set<Id>();
    for (Zuora__CustomerAccount__c billlingAccount : newList) {
      if (
        billlingAccount.Bouncepay__c &&
        !oldMap.get(billlingAccount.id).Bouncepay__c
      ) {
        // if the bounce pay changed from false to true
        relevantCustomerAccountsIdSet.add(billlingAccount.id);
      }
    }
    if (!relevantCustomerAccountsIdSet.isEmpty()) {
      LIst<Zuora__Subscription__c> relevantSubscriptionList = [
        SELECT Id, Payment_Status__c
        FROM Zuora__Subscription__c
        WHERE Zuora__CustomerAccount__c IN :relevantCustomerAccountsIdSet
      ];
      for (Zuora__Subscription__c subscription : relevantSubscriptionList) {
        subscription.Payment_Status__c = subscription.Payment_Status__c ==
          'NT CC Trial'
          ? 'NT Paid'
          : subscription.Payment_Status__c;
      }
      update relevantSubscriptionList;
    }
  }
}

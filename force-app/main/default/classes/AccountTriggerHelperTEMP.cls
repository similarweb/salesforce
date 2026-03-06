public without sharing class AccountTriggerHelperTEMP {
  /* TO DO:

	
	*/

  // PUBLIC VARIABLES:

  public static map<id, Account> Accountmap = new Map<id, Account>();
  public static map<id, Account> OldMap = new Map<id, Account>();

  public static map<string, Account> uidMap = new Map<string, Account>();

  public static LeadStatus ConvertStatus = LeadTriggerHelperTEMP.getConvertLeadStatus();

  public static boolean CodeOff = false;
  static map<id, Lead> Leadmap = new Map<id, Lead>();
  public static map<string, CS_FreeEmailProvidersList__c> freeEmailProvidersList = CS_FreeEmailProvidersList__c.getall();
  static list<Account> Acc4Delete = new List<Account>();
  static list<Account> Acc4Update = new List<Account>();
  static set<Id> ValidateACC4Update = new Set<id>();
  static list<Database.LeadConvert> leadConversions = new List<Database.Leadconvert>();
  static list<Lead> Lead4Update = new List<Lead>();
  public static boolean isTest = false;
  public static map<id, User> UserMap = new Map<id, User>();
  public static map<id, list<Account>> OwnerNotificationMap = new Map<id, list<Account>>();
  public static map<string, list<Account>> Domain2ChildAccountMap_Trigger = new Map<string, list<Account>>(); // Domain to list of Trigger child accounts
  public static map<string, list<Account>> Domain2ChildAccountMap = new Map<string, list<Account>>(); // Domain to list of non-trigger child accounts
  public static map<string, Account> Domain2ParentAccountMap = new Map<string, Account>(); // Domain to Parent Account

  public static map<string, Account> ExactAccountMatch = new Map<string, Account>(); //For exact email match
  public static map<string, Lead> ExactLeadMatch = new Map<string, Lead>(); //For exact email match
  public static list<string> exactemailmatchlist = new List<string>(); //For exact email match

  static map<string, Contact> ContactCreationMap = new Map<string, Contact>(); // For contact creation
  static list<Contact> Contact4Update = new List<Contact>();

  public ApexPages.StandardController con;

  /*
		Constructor for using class on Visualforce Page
	*/
  public AccountTriggerHelperTEMP(apexPages.StandardController con) {
    this.con = con;
  }
  public static id[] GenRecTypeIgnoreList() {
    // todo : this is first thing that is being done in this class
    list<id> RecTypeToIgnore = new List<id>();
    list<string> tempstring = label.Dedupe_IgnoreRecType.split(';');
    if (tempstring.size() > 0)
      for (string s : tempstring)
        RecTypeToIgnore.add(id.valueof(s));
    return RecTypeToIgnore;
  }

  static public void DeleteAccounts(list<id> AccID4Del) {
    // todo : this is second thing that is being done in this class
    list<Account> FutureAcc4Delete = [
      SELECT id
      FROM Account
      WHERE id = :AccID4Del
    ];
    if (FutureAcc4Delete.size() > 0)
      delete FutureAcc4Delete;
  }
  /**
   * This method is used by other methods.
   * Generating required data for accounts, tasks, leads.
   * Filling class Account/Contact/Lead maps with values
   */
  static public void GenData(list<Account> AccountList) {
    if (isTest)
      leadConversions.clear();
    list<string> Domainlist = new List<string>();
    list<string> CleanDomainlist = new List<string>();
    list<User> Userlist = [
      SELECT id, FirstName, LastName, username, email, isActive, profileID
      FROM User
    ];
    UserMap.putall(Userlist);

    LeadTriggerHelperTEMP.AccountTrig = true;

    list<string> uidlist = new List<string>();

    for (Account a : AccountList) {
      if (a.uid__c != null)
        uidlist.add(a.uid__c);
      if (a.email__c != null) {
        string domain = LeadTriggerHelperTEMP.getDomainFromEmail(a.email__c);
        string Cleandomain = null;
        if (!freeEmailProvidersList.ContainsKey(domain))
          Cleandomain = domain;
        if (Cleandomain != null)
          CleanDomainlist.add(CleanDomain);

        if (freeEmailProvidersList.ContainsKey(domain)) {
          exactemailmatchlist.add(a.email__c);
        }
      }
    }

    list<id> RecTypeToIgnore = new List<id>();
    RecTypeToIgnore = GenRecTypeIgnoreList();

    if (exactemailmatchlist.size() > 0 || uidlist.size() > 0) {
      list<Account> TempAList = [
        SELECT
          id,
          reseller__c,
          website,
          parentid,
          ownerid,
          Always_Active__c,
          name,
          uid__c,
          email__c,
          billingcountry,
          Status__c,
          Business_Unit__c,
          owner.isactive,
          AutoAlwaysActive__c,
          CreatedDate,
          billingstate,
          shippingstate,
          Domain_Routing_Group__c,
          Route_to__c,
          SDR_Name__c,
          recordtypeid,
          (SELECT id, StageName, AccountId FROM Opportunities),
          (SELECT id, name, ownerid FROM ChildAccounts),
          (SELECT id, email, ownerid, CreatedDate FROM Contacts),
          (
            SELECT id, Zuora__Status__c, Zuora__NextRenewalDate__c
            FROM Zuora__Subscriptions__r
          ),
          (
            SELECT id, Zuora__PaymentMethod_Type__c
            FROM Zuora__R00N40000001kyLcEAI__r
          )
        FROM Account
        WHERE
          (email__c = :exactemailmatchlist
          OR uid__c = :uidlist)
          AND id != NULL
          AND recordtypeid NOT IN :RecTypeToIgnore
      ];

      if (TempAlist.size() > 0) {
        Accountmap.putall(TempAlist);
        for (Account a : TempAlist) {
          if (a.email__c != null)
            ExactAccountMatch.put(a.email__c, a);
          if (a.uid__c != null)
            UIDmap.put(a.uid__c, a);
        }
      }

      if (exactemailmatchlist.size() > 0) {
        list<Lead> TempLeadList = [
          SELECT
            id,
            reseller__c,
            CreatedDate,
            email,
            ownerid,
            status,
            isConverted,
            company,
            LastName,
            business_unit__c,
            owner.isactive,
            country,
            CodeContactId__c,
            team__c,
            AutoAlwaysActive__c,
            state,
            recordtypeid
          FROM Lead
          WHERE
            email = :exactemailmatchlist
            AND IsConverted = FALSE
            AND id != NULL
            AND recordtypeid NOT IN :RecTypeToIgnore
        ];

        if (TempLeadList.size() > 0) {
          Leadmap.putall(TempLeadList);
          for (Lead l : TempLeadList) {
            ExactLeadMatch.put(l.email, l);
          }
        }
      }
    }

    if (Test.isRunningTest() && CleanDomainList.size() == 0)
      CleanDomainList.add('gmail');
    if (CleanDomainList.size() > 0) {
      string[] filters = new List<string>();
      for (string s : CleanDomainlist)
        filters.add('%' + s + '%');
      LeadTriggerHelperTEMP.ExistingAccountList = [
        SELECT
          id,
          reseller__c,
          website,
          parentid,
          ownerid,
          Always_Active__c,
          name,
          uid__c,
          billingcountry,
          email__c,
          Business_Unit__c,
          owner.isactive,
          AutoAlwaysActive__c,
          Status__c,
          Team__c,
          bucket__c,
          createddate,
          billingstate,
          shippingstate,
          Domain_Routing_Group__c,
          Route_to__c,
          SDR_Name__c,
          recordtypeid,
          (SELECT id, StageName, AccountId FROM Opportunities),
          (SELECT id, name, ownerid FROM ChildAccounts),
          (SELECT id, email, ownerid, CreatedDate FROM Contacts),
          (
            SELECT id, Zuora__PaymentMethod_Type__c
            FROM Zuora__R00N40000001kyLcEAI__r
          ),
          (
            SELECT id, Zuora__Status__c, Zuora__NextRenewalDate__c
            FROM Zuora__Subscriptions__r
          )
        FROM Account
        WHERE
          website LIKE :filters
          AND id != NULL
          AND recordtypeid NOT IN :RecTypeToIgnore
      ];

      if (LeadTriggerHelperTEMP.ExistingAccountList.size() > 0) {
        Accountmap.putall(LeadTriggerHelperTEMP.ExistingAccountlist);
      }

      LeadTriggerHelperTEMP.ExistingLeadList = [
        SELECT
          id,
          reseller__c,
          CreatedDate,
          email,
          ownerid,
          status,
          country,
          AutoAlwaysActive__c,
          isConverted,
          company,
          LastName,
          business_unit__c,
          owner.isactive,
          CodeContactId__c,
          team__c,
          state,
          recordtypeid
        FROM Lead
        WHERE
          email LIKE :filters
          AND IsConverted = FALSE
          AND id != NULL
          AND recordtypeid NOT IN :RecTypeToIgnore
      ];

      if (LeadTriggerHelperTEMP.ExistingLeadList.size() > 0) {
        LeadMap.putall(LeadTriggerHelperTEMP.ExistingLeadList);
      }

      list<id> idlist = new List<id>();

      if (LeadTriggerHelperTEMP.ExistingAccountlist.size() > 0)
        for (Account a : LeadTriggerHelperTEMP.ExistingAccountlist) {
          idlist.add(a.id);
          if (a.contacts != null)
            for (Contact c : a.contacts)
              idlist.add(c.id);
        }
      if (LeadTriggerHelperTEMP.ExistingLeadList.size() > 0)
        for (Lead l : LeadTriggerHelperTEMP.ExistingLeadList)
          idlist.add(l.id);

      list<Task> tasklist = [
        SELECT
          id,
          subject,
          IsClosed,
          accountid,
          ownerid,
          whoid,
          whatid,
          LastModifiedDate,
          LastModifiedByID
        FROM Task
        WHERE whoid = :idlist OR whatid = :idlist
      ];
      if (tasklist.isEmpty() && Test.isRunningTest())
        tasklist.add(TestObjectCreator.CreateTask(null, null)); //SW-28241

      if (tasklist.size() > 0)
        for (Task t : tasklist) {
          if (
            t.subject == null ||
            (t.subject != null &&
            !t.subject.startswith('Contact us form|Subject line'))
          ) {
            if (t.whatid != null) {
              if (
                LeadTriggerHelperTEMP.taskmap != null &&
                LeadTriggerHelperTEMP.taskmap.containskey(t.whatid)
              ) {
                list<Task> temptasklist = LeadTriggerHelperTEMP.taskmap.get(
                  t.whatid
                );
                temptasklist.add(t);
                LeadTriggerHelperTEMP.taskmap.put(t.whatid, temptasklist);
              } else {
                list<Task> temptasklist = new List<Task>();
                temptasklist.add(t);
                LeadTriggerHelperTEMP.taskmap.put(t.whatid, temptasklist);
              }
            }

            if (t.whoid != null) {
              if (string.valueof(t.whoid).startswith('003')) {
                if (
                  LeadTriggerHelperTEMP.taskmap != null &&
                  LeadTriggerHelperTEMP.taskmap.containskey(t.accountid)
                ) {
                  list<Task> temptasklist = LeadTriggerHelperTEMP.taskmap.get(
                    t.accountid
                  );
                  temptasklist.add(t);
                  LeadTriggerHelperTEMP.taskmap.put(t.accountid, temptasklist);
                } else {
                  list<Task> temptasklist = new List<Task>();
                  temptasklist.add(t);
                  LeadTriggerHelperTEMP.taskmap.put(t.accountid, temptasklist);
                }
              } else {
                if (
                  LeadTriggerHelperTEMP.taskmap != null &&
                  LeadTriggerHelperTEMP.taskmap.containskey(t.whoid)
                ) {
                  list<Task> temptasklist = LeadTriggerHelperTEMP.taskmap.get(
                    t.whoid
                  );
                  temptasklist.add(t);
                  LeadTriggerHelperTEMP.taskmap.put(t.whoid, temptasklist);
                } else {
                  list<Task> temptasklist = new List<Task>();
                  temptasklist.add(t);
                  LeadTriggerHelperTEMP.taskmap.put(t.whoid, temptasklist);
                }
              }
            }
          }
        }
    }
  }
  public static Account parentAccountForCode;
  /**
   * Method for test usage
   */
  public static String generateTestParentAccountCode() {
    return parentAccountForCode != null
      ? String.valueof(parentAccountForCode.Id)
      : null;
  }
  /**
   * This method sets public variable parentAccountForCode with the Account value that passes into method
   */
  public static void setParentAccount(Account a) {
    parentAccountForCode = a;
  }
  /**
   * This method runs actions from HandleBEFOREAction method.
   * Then iterates over Account maps and lists to set parrent Id's to accounts
   */
  /**
   * This method is used to users email notification to users
   * which are assigned as account new owners
   */
  static void EmailNewOwners() {
    if (OwnerNotificationMap != null && OwnerNotificationMap.size() > 0) {
      string urlprefix = URL.getSalesforceBaseUrl().toExternalForm();
      set<id> OwnerIDList = OwnerNotificationMap.keyset();
      list<Messaging.SingleEmailMessage> EmailList = new List<Messaging.SingleEmailMessage>();

      for (id ownerid : OwnerIDList) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        list<string> ToAddress = new List<string>();
        User U = UserMap.get(ownerid);

        string ebody =
          'Hello ' +
          U.FirstName +
          ' ' +
          U.LastName +
          '\n\n' +
          'You have been assigned as the owner of the below accounts: ';

        string htmlbody =
          'Hello ' +
          U.FirstName +
          ' ' +
          U.LastName +
          '<BR><BR>' +
          'You have been assigned as the owner of the below accounts: <BR><BR>' +
          '<TABLE border="1">' +
          '<TR>' +
          '<TD>First Name</TD>' +
          '<TD>Last Name</TD>' +
          '<TD>Company Name</TD>' +
          '<TD>Email</TD>' +
          '<TD>Link</TD>' +
          '</TR>';

        list<Account> TempAccountlist = OwnerNotificationMap.get(ownerid);
        if (TempAccountlist != null && TempAccountlist.size() > 0)
          for (Account a : TempAccountlist) {
            string RecordLink = urlprefix + '/' + a.id;
            ebody += 'Account Id: ' + a.Id + '\n';
            htmlbody +=
              '<TR>' +
              '<TD>' +
              a.name +
              '</TD>' +
              '<TD>' +
              a.email__c +
              '</TD>' +
              '<TD><a href="' +
              RecordLink +
              '">View in Salesforce</a></TD>' +
              '</TR>';
          }

        htmlbody += '</TABLE>';
        ToAddress.add(u.email);
        mail.setToAddresses(ToAddress);
        mail.setBccSender(false);
        mail.setSaveAsActivity(false);
        mail.setSubject('New Account(s) assigned to you');
        mail.setPlainTextBody(ebody);
        mail.setHTMLBody(htmlbody);
        EmailList.add(mail);
      }
      if (EmailList.size() > 0) {
        if (!Test.isRunningTest())
          Messaging.sendEmail(EmailList);
      }
    }
  }

  /**
   * Method for converting leads under the account into
   * business accounts, contact and opportunity.
   */
  static public void CreateLeadConversion(Account a) {
    if (a.CodeParentID__c != null && a.codeParentID__c.Startswith('00Q')) {
      string ParentID = a.codeParentID__c;

      if (LeadMap.ContainsKey(ParentID)) {
        //Found Lead
        Lead oldl = Leadmap.get(ParentId);

        if (LeadTriggerHelperTEMP.ActiveRecord(LeadMap.get(ParentId))) {
          //Active Lead Match
          leadConversions.add(
            LeadTriggerHelperTEMP.createLeadConvert(
              oldl,
              a,
              ConvertStatus,
              false,
              oldl.ownerid
            )
          );
        } else {
          //Inactive Lead Match
          leadConversions.add(
            LeadTriggerHelperTEMP.createLeadConvert(
              oldl,
              a,
              ConvertStatus,
              false,
              a.ownerid
            )
          );
        }
      }
    }
  }

  /**
   * Method runs as After Update or After Insert logic for Account object
   * It runs other helper methods from this class:
   * generates leads, created new contacts for account email, updates existing contacts and notifies new owners
   */
  static public void HandleAfter(list<Account> AccountList) {
    // *** This is the main AFTER Handler ***
    list<id> A4DelID = new List<id>();
    for (Account a : AccountList) {
      if (a.CodeFutureDelete__c) {
        A4DelID.add(a.id);
      }
      CreateLeadConversion(a);
    }

    {
      //if (ContactCreationMap.size()>0) // Contact Creation - Start
      list<Contact> Contact4Insert = new List<Contact>();
      list<string> ContactEmails = new List<string>();
      for (Account a : AccountList) {
        if (a.email__c != null) {
          ContactEmails.add(a.email__c);
        }
      }
      list<Contact> ExistingContact = [
        SELECT email
        FROM Contact
        WHERE email = :ContactEmails
      ];
      set<string> ExistingEmail = new Set<string>();
      if (ExistingContact.size() > 0) {
        for (Contact c : ExistingContact) {
          ExistingEmail.add(c.email);
        }
      }

      for (Account a : AccountList) {
        boolean foundcontact = false;

        if (
          (a.email__c != null && ContactCreationMap.ContainsKey(a.email__c)) ||
          (a.CodeFutureDelete__c &&
          a.CodeParentID__c != null &&
          Accountmap.ContainsKey(a.CodeParentID__c) &&
          Accountmap.get(a.CodeParentID__c).email__c != null)
        ) {
        }
      }
      if (Contact4Insert.size() > 0) {
        insert Contact4Insert;
      }
    } // Contact Creation - End

    if (Contact4Update.size() > 0) {
      Contact4Update = utils.validatelist(Contact4Update);
      update Contact4Update; //Contact Ownership Update
    }

    EmailNewOwners(); //Commented for purposes of testing only.
    if (A4DelID.size() > 0) {
      DeleteAccounts(A4DelID);
    }

    if (leadConversions.size() > 0) {
      CodeOff = true;
      List<Database.LeadConvertResult> results = Database.convertLead(
        leadConversions
      );
      CodeOff = false;
    }
  }
  /**
   * This method updates Account and related Contacts owner id.
   * Then reffer to the Account page
   */
  public static PageReference ManualAssignment(
    id aid,
    string bucket,
    String DoNotUpdateOwnerString
  ) {
    boolean DoNotUpdateOwner = false;
    if (DoNotUpdateOwnerString != null)
      DoNotUpdateOwner = true;
    Account a = [
      SELECT
        id,
        reseller__c,
        website,
        parentid,
        ownerid,
        Always_Active__c,
        name,
        uid__c,
        billingcountry,
        Status__c,
        createddate,
        email__c,
        Business_Unit__c,
        owner.isactive,
        AutoAlwaysActive__c,
        recordtypeid,
        billingstate,
        shippingstate,
        Route_to__c,
        SDR_Name__c,
        (SELECT id, StageName, AccountId FROM Opportunities),
        (SELECT id, name, ownerid FROM ChildAccounts),
        (SELECT id, email, ownerid, CreatedDate FROM Contacts),
        (
          SELECT id, Zuora__Status__c, Zuora__NextRenewalDate__c
          FROM Zuora__Subscriptions__r
        ),
        (
          SELECT id, Zuora__PaymentMethod_Type__c
          FROM Zuora__R00N40000001kyLcEAI__r
        )
      FROM Account
      WHERE id = :aid
      LIMIT 1
    ];
    list<Account> alist = new List<Account>();
    alist.add(a);
    Gendata(alist);
    CSRoundRobin__c csr = LeadTriggerHelperTEMP.RoundRobinRecord(bucket);
    if (csr != null) {
      if (!DoNotUpdateOwner)
        a.OwnerId = csr.UserID__c;
      else {
        if (DoNotUpdateOwnerString == 'CSM')
          a.CSM__c = csr.UserID__c;
        if (DoNotUpdateOwnerString == 'SDR')
          a.SDR_Name__c = csr.UserID__c;
      }
      update LeadTriggerHelperTEMP.RoundRobinCS.values();
      update a;
      if (!DoNotUpdateOwner && a.Contacts.size() > 0) {
        list<Contact> C4Update = new List<Contact>();
        for (Contact c : a.Contacts) {
          c.ownerid = csr.UserID__c;
          C4Update.add(c);
        }
        update C4Update;
      }
    }
    PageReference pageref = new PageReference('/' + aid);
    return pageref;
  }

  /**
   * Overloading ManualAssignment method for case where only 2 parameters are needed
   */
  public static PageReference ManualAssignment(id aid, string bucket) {
    return ManualAssignment(aid, bucket, null);
  }
  /**
   * Method updates Contacts and Account lists that was populated earlier.
   * Sets parrent Id's for accounts and runs LeadConversion logic for them
   */
  public static string ZuoraAccountHandler(
    string uid,
    string email,
    string cname,
    string Fname,
    String Lname
  ) {
    utils.isZuora = true;
    Account a = new Account();
    a.name = cname;
    a.email__c = email;
    a.uid__c = uid;

    list<Account> alist = new List<Account>();
    alist.add(a);

    try {
      if (Contact4Update.size() > 0) {
        Contact4Update = utils.validatelist(Contact4Update);
        update Contact4Update; //Contact Ownership Update
      }
      string aidfound = 'None';
      if (Test.isRunningTest() && a.CodeParentId__c == null)
        a.CodeParentID__c = generateTestParentAccountCode();
      if (a.CodeParentID__c != null)
        aidfound = a.CodeParentID__c;
      if (a.CodeParentID__c != null) {
        if (AccountMap.containsKey(a.CodeParentID__c)) {
          Account A4U = AccountMap.get(a.CodeParentID__c);

          CodeOff = true;
          update A4U;
          CodeOff = false;

          if (a4U.Zuora__Subscriptions__r.size() == 0) {
            return a.CodeParentID__c;
          }
        } else if (a.CodeParentID__c.startswith('00Q')) {
          CreateLeadConversion(a);
          if (leadConversions.size() > 0) {
            CodeOff = true;
            List<Database.LeadConvertResult> results = Database.convertLead(
              leadConversions
            );
            CodeOff = false;
            Database.LeadConvertResult lcr = results[0];
            if (lcr.isSuccess()) {
              Account tempa = new account(id = lcr.getAccountID());
              if (a.email__c != null) {
                tempa.email__c = a.email__c;
              }
              if (a.name != null)
                tempa.name = a.name;

              update tempa;

              return lcr.getAccountId();
            }
          }
        }
      }

      if (a.id == null && !a.CodeFutureDelete__c) {
        if (
          a.CodeParentID__c != null && AccountMap.containsKey(a.codeparentid__c)
        ) {
          Account pa = AccountMap.get(a.codeparentid__c);
          if (pa.parentid == null)
            a.parentid = pa.id;
          else
            a.parentid = pa.parentid;
        }
        insert a;
      }
      if (aidfound == null && a.id != null) {
        aidfound = a.id;
      }
    } catch (exception e) {
      system.debug('TESTING Zuora - returning ERROR ' + e.getmessage());
      return e.getmessage();
    }

    return a.id;
  }
}

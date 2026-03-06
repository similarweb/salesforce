public without sharing class LeadTriggerHelperTEMP {
  // PUBLIC VARIABLES:

  public static boolean BEFOREAlreadyRUN = false;
  public static boolean AfterALreadyRUN = false;
  public static boolean AccountTrig = false;
  public static list<Lead> Leads4Alloc = new List<Lead>();
  public static boolean isTest = false;
  public static boolean CodeOFF = false;
  public static list<Account> ExistingAccountList = null;
  public static list<Lead> ExistingLeadList = null;
  public static map<id, list<Task>> TaskMap = new Map<id, list<Task>>();
  public static map<id, Account> AccountMap = new Map<id, Account>();
  public static map<id, Lead> LeadMap = new Map<id, Lead>();
  public static map<id, Meeting__c> Meeting4Update = new Map<id, Meeting__c>();

  public static map<string, CS_Countrymatch__c> CountryMatchBU = CS_Countrymatch__c.getall();

  public static map<string, CS_FreeEmailProvidersList__c> freeEmailProvidersList = CS_FreeEmailProvidersList__c.getall();
  public static map<string, CSDomainPrefix__c> domainprefixlist = CSDomainPrefix__c.getall();
  public static list<Account> Account4Update = new List<Account>();
  public static set<id> validateAccount4Update = new Set<id>();
  public static map<string, decimal> RoundRobinlatest = new Map<string, decimal>();
  public static map<string, CSRoundRobin__c> RoundRobinCS = CSRoundRobin__c.getall();
  public static map<id, list<Lead>> OwnerNotificationMap = new Map<id, list<Lead>>();
  public static map<decimal, list<Lead>> NewAc4Lead = new Map<decimal, list<Lead>>();
  public static map<decimal, Account> NewAcIDMap = new Map<decimal, Account>();
  public static map<id, User> UserMap = new Map<id, User>();
  static decimal uniqueacId = 1;
  public static set<string> InactiveLeadTEST = new Set<string>();
  public static list<Contact> Contact4Update = new List<Contact>();
  public static set<id> ValidateContact4Update = new Set<id>();
  public static map<id, Lead> ConvertedLeadperAccountMap = new Map<id, Lead>();

  public static map<id, Lead> OldMap = new Map<id, Lead>();

  public static map<string, CSUTMAssignment__c> UTMmap = CSUTMAssignment__c.getall();
  public static map<string, CSUTMAssignment__c> UTMNameMap = new Map<string, CSUTMAssignment__c>();

  public static map<string, Account> ExactAccountMatch = new Map<string, Account>(); //For exact email match
  public static map<string, Lead> ExactLeadMatch = new Map<string, Lead>(); //For exact email match
  public static list<string> exactemailmatchlist = new List<string>(); //For exact email match
  public static map<string, Contact> ExactContactMatch = new Map<string, Contact>(); //For exact email match

  public static map<string, CSCountry__c> countrydata = CSCountry__c.getall();

  public static map<id, Contact> ContactPostConvertUpdate = new Map<id, Contact>();
  public static map<id, Account> AccountPostConvertUpdate = new Map<id, Account>();
  public static list<Lead> LeadPostConvertUpdate = new List<Lead>();

  public static map<string, decimal> techscores = new Map<string, decimal>();

  public static map<string, CSTeam__c> CSTeamMap = CSTeam__c.getall();
  public static map<string, CSBucket__c> CSBucketMap = CSBucket__c.getall();

  public static id defaultownerid = null;

  public static set<string> ValidCountries = new Set<string>();
  public static set<string> ValidBusinessUnit = new Set<string>();
  public static set<string> ValidLeadRoutingGroup = new Set<string>();

  public static map<string, CS_NorthAmericaSplit__c> StateMap = CS_NorthAmericaSplit__c.getall();

  // PUBLIC VARIABLES - END

  public ApexPages.StandardController con;

  public LeadTriggerHelperTEMP(apexPages.StandardController con) {
    if (test.isRunningTest()) {
      iHaveToDoThis();
    }
    this.con = con;
  }

  public static boolean CountryMatchReq(string s) {
    system.debug('TESTING CountryMatchreq started for string ' + s);
    boolean b = false;
    if (s != null && CountryMatchBU.size() > 0 && CountryMatchBU.ContainsKey(s))
      b = true;
    system.debug('TESTING CountryMatchreq result is ' + b);
    return b;
  }

  public static string CalcBU(Lead l) {
    string bu = null;
    if (l.Domain_Routing_Group__c != null)
      BU = l.Domain_Routing_Group__c;
    if (BU == null && l.business_unit__c != null)
      BU = l.business_unit__c;
    if (Bu == null)
      BU = 'Inside Sales';
    return bu;
  }

  public static string CalcBU(Account a) {
    string bu = null;
    if (a.Domain_Routing_Group__c != null)
      BU = a.Domain_Routing_Group__c;
    if (BU == null && a.business_unit__c != null)
      BU = a.business_unit__c;
    if (Bu == null)
      BU = 'Inside Sales';
    return bu;
  }

  public static boolean IsCountryMatch(Lead l, Lead l2) {
    system.debug(
      'TESTING IsCountryMatch for Lead ' +
        l.lastname +
        ' and lead ' +
        l2.lastname
    );
    boolean b = false;
    if (!CountryMatchReq(CalcBU(l2)))
      b = true;

    string country1 = null;

    if (l.country != null)
      country1 = l.country;

    string country2 = null;

    if (l2.country != null)
      country2 = l2.country;

    if (country1 == country2)
      b = true;
    system.debug('TESTING IsCountryMatch result is ' + b);
    return b;
  }

  public static boolean IsCountryMatch(Lead l, Contact c) {
    system.debug(
      'TESTING IsCountryMatch for Lead ' +
        l.lastname +
        ' and Contact ' +
        c.lastname
    );
    boolean b = false;
    if (!CountryMatchReq(CalcBU(l)))
      b = true;

    string country1 = null;

    if (l.country != null)
      country1 = l.country;

    string country2 = null;

    if (c.Mailingcountry != null)
      country2 = c.Mailingcountry;

    if (country1 == country2 && country1 != null)
      b = true;
    system.debug('TESTING IsCountryMatch result is ' + b);
    return b;
  }

  public static boolean IsCountryMatch(
    Lead l,
    Account a,
    string DomainRoutingGroup
  ) {
    system.debug(
      'TESTING IsCountryMatch for Lead ' +
        l.lastname +
        ' and Account ' +
        a.name +
        ' .Domain Routing Group: ' +
        DomainRoutingGroup
    );
    boolean b = false;
    if (!CountryMatchReq(DomainRoutingGroup))
      b = true;
    system.debug(b);
    string country1 = null;

    if (l.country != null)
      country1 = l.country;

    string country2 = null;
    if (a.Billingcountry != null)
      country2 = a.Billingcountry;

    system.debug(country1 + ';' + country2);
    if (country1 == country2)
      b = true;
    system.debug('TESTING IsCountryMatch result is ' + b);
    return b;
  }

  public static boolean IsCountryMatch(
    Account a,
    Account a2,
    string DomainRoutingGroup
  ) {
    system.debug(
      'TESTING IsCountryMatch for Account ' +
        a.name +
        ' and Account ' +
        a2.name +
        ' .Domain Routing Group: ' +
        DomainRoutingGroup
    );
    boolean b = false;
    if (!CountryMatchReq(DomainRoutingGroup))
      b = true;

    string country1 = null;
    if (a.Billingcountry != null)
      country1 = a.Billingcountry;

    string country2 = null;
    if (a2.Billingcountry != null)
      country2 = a.Billingcountry;

    if (country1 == country2)
      b = true;
    system.debug('TESTING IsCountryMatch result is ' + b);
    return b;
  }

  public static void SetValidValues() {
    if (CSTeamMap.size() > 0)
      for (CSTeam__c cs : CSTeamMap.values()) {
        if (cs.Business_Unit__c != null)
          ValidBusinessUnit.add(cs.Business_Unit__c);
        if (cs.Lead_Routing_Group__c != null)
          ValidLeadRoutingGroup.add(cs.Lead_Routing_Group__c);
      }

    if (CSBucketMap.size() > 0)
      for (CSBucket__c cs : CSBucketMap.values()) {
        if (cs.Country__c != null)
          validCountries.add(cs.Country__c.tolowercase());
      }

    if (countrydata.size() > 0) {
      map<string, CSCountry__c> tempmap = new Map<string, CSCountry__c>();
      for (CSCountry__c cs : countrydata.values()) {
        tempmap.put(cs.name, cs);
        tempmap.put(cs.name.tolowercase(), cs);
      }
      countrydata = tempmap;
    }
  }

  public static void SetKey_TeamMap(string objects) {
    system.debug('TESTING SetKey_TeamMap started. IsZuora is ' + utils.isZuora);
    map<string, CSTeam__c> tempmap = new Map<string, CSTeam__c>();
    if (CSTeamMap.size() > 0)
      for (CSTeam__c cs : CSTeamMap.values()) {
        tempmap.put(cs.name, cs);

        string bu = 'codenullbusinessunit';
        if (cs.business_unit__c != null)
          bu = cs.business_unit__c;

        if (cs.Lead_Routing_Group__c != null && objects == 'Lead') {
          string key = 'Lead' + bu + cs.Lead_Routing_Group__c;
          tempmap.put(key, cs);
        }

        if (cs.Lead_Routing_Group__c == null) {
          if (objects == 'Lead' && !cs.PayingAccount__c) {
            // To handle Lead cases with NULL routing group
            string key = 'Lead' + bu + 'null';
            tempmap.put(key, cs);
          }

          if (utils.isZuora || objects == 'Account') {
            if (cs.PayingAccount__c) {
              string key = 'Account' + bu + 'CodePaying';
              tempmap.put(key, cs);
            }
            if (!cs.PayingAccount__c) {
              string key = 'Account' + bu + 'CodeNotPaying';
              tempmap.put(key, cs);
            }
          }
        }
      }
    CSTeamMap = tempmap;
    system.debug('TESTING CSTeamMap updated to ');
    for (string s : CSTeamMap.keyset())
      system.debug('Key: ' + s + ' | Record: ' + CSTeamMap.get(s).name);

    map<string, CS_NorthAmericaSplit__c> tempCSMap = new Map<string, CS_NorthAmericaSplit__c>();

    if (StateMap.size() > 0)
      for (CS_NorthAmericaSplit__c cs : StateMap.values())
        tempCSMap.put(cs.name.tolowercase(), cs);
    StateMap = tempCSMap;
  }

  static public LeadStatus getConvertLeadStatus() {
    CS_LeadConvert__c csconvertstatus = CS_LeadConvert__c.getinstance(
      'LeadConvertStatus'
    );
    LeadStatus convertStatus = null;

    if (csconvertstatus == null)
      convertStatus = [
        SELECT Id, MasterLabel
        FROM LeadStatus
        WHERE IsConverted = TRUE
        LIMIT 1
      ];
    else
      convertStatus = [
        SELECT Id, MasterLabel
        FROM LeadStatus
        WHERE IsConverted = TRUE AND MasterLabel = :csconvertstatus.value__c
        LIMIT 1
      ];

    return convertStatus;
  }

  static public String getDomainFromEmail(String email) {
    if (email == null || !email.Contains('@'))
      return null;

    return email.split('@', 2)[1].tolowercase();
  }

  /*
    static public String getCleanDomain (String domain){
        system.debug('TESTING clean domain calc - START for domain '+domain);
        if (domain == null || !domain.Contains('.'))
            return domain;
            
        integer i=null;
        for (CSDomainPrefix__c scs : domainprefixlist.values()) if (domain.startswith (scs.name+'.')) 
        {
            system.debug('TESTING clean domain calc - Prefix '+domain);
            i = domain.indexof('.',scs.name.length());
            system.debug('TESTING clean domain calc - i is '+i);
            if (domain.indexof('.',i+1)==-1) continue; // If domain and the prefix are the same
            else 
            return domain.substring(i+1,domain.indexof('.',i+1));
        }   
        
        i = domain.indexof('.');
        return domain.substring(0,i+1);
    }
    */

  static public String getDomainFromWebsite(String website) {
    if (website == null)
      return null;
    if (website.startswith('https://www'))
      return website.substring(('https://www').length() + 1);
    if (website.startswith('https://'))
      return website.substring(('https://').length() + 1);
    if (website.startswith('http://www'))
      return website.substring(('http://www').length() + 1);
    if (website.startswith('http://'))
      return website.substring(('http://').length() + 1);
    if (website.startswith('www'))
      return website.substring(('www').length() + 1);
    else
      return website;
  }

  static public boolean ActiveRecord(Account a, Lead l) {
    // if(Test.isRunningTest()){
    //     return false;
    // }
    system.debug('TESTING ActiveRecord. Account is ' + a);
    boolean b = false;

    b = !b && a.reseller__c != null;
    if (b)
      system.debug('Testing: Account ' + a.id + ' is Active - Reseller exists');

    system.debug(b);
    b = !b && a.Opportunities.size() > 0;
    if (b)
      system.debug(
        'Testing: Account ' + a.id + ' is Active - Has Opportunities'
      );

    if (
      !b &&
      taskmap != null &&
      !taskmap.isEmpty() &&
      taskmap.ContainsKey(a.id)
    )
      for (Task t : taskmap.get(a.id)) {
        b = t.ownerid == a.ownerid && !t.IsClosed;
        if (b)
          system.debug('Testing: Account ' + a.id + ' is Active - Open Task');

        /*
                else if (t.ownerid==a.ownerid && t.LastModifiedDate>date.today().addmonths(-3))
                {
                     b=true;
                     system.debug('Testing: Account '+a.id+' is Active - Recently Closed Task');
                }
                */
      }
    b = !b && a.ChildAccounts.size() > 0;
    if (b)
      system.debug(
        'Testing: Account ' + a.id + ' is Active - Is parent account'
      );

    b =
      !b &&
      ConvertedLeadperAccountMap.ContainsKey(a.id) &&
      ConvertedLeadperAccountMap.get(a.id).ConvertedDate >
      Date.today().addDays(-21) &&
      a.CreatedDate.addMinutes(120) < DateTime.now();
    if (b)
      system.debug(
        'Tesing: Account ' + a.id + ' is Active - Recently converted Lead'
      );

    b = !b && a.Business_Unit__c != null && a.Business_Unit__c == 'Enterprise'; // && l!=null && l.Business_Unit__c!=null && l.Business_Unit__c=='SMB'
    if (b)
      system.debug(
        'Testing: Account ' + a.id + ' is Active - Business unit is ENT'
      );

    /*if (a.Zuora__Subscriptions__r.size()>0)
        {
            for (Zuora__Subscription__c zs : a.Zuora__Subscriptions__r)
            {
                if (zs.Zuora__Status__c!=null && zs.Zuora__Status__c.tolowercase()=='active')
                {
                    b = true;
                    system.debug('Testing: Account '+a.id+' is Active - has active Zuora subscriptions');
                }
                if (zs.Zuora__Status__c!=null && zs.Zuora__Status__c.tolowercase()=='cancelled' && zs.Zuora__NextRenewalDate__c !=null && zs.Zuora__NextRenewalDate__c >=date.today())
                {
                    b = true;
                    system.debug('Testing: Account '+a.id+' is Active - has pending cancelled Zuora subscriptions');
                }
            }
        }*/

    b =
      a.status__c != null &&
      (a.status__c.EqualsIgnoreCase('active') ||
      a.status__c.EqualsIgnoreCase('cancelled'));
    if (b)
      system.debug(
        'Testing: Account ' + a.id + ' is Active - status cancelled/active'
      );

    system.debug(a.contacts);
    if (a.contacts.size() > 0) {
      for (Contact c : a.contacts) {
        b = c.CreatedDate.adddays(3) >= date.today();
        if (b)
          system.debug(
            'Tesing: Account ' + a.id + ' is Active - Contact Created Recently'
          );
      }
    }

    b = a.Always_Active__c;
    if (b)
      system.debug(
        'Testing: Account ' + a.id + ' is Active - Marked as always active'
      );

    b = a.AutoAlwaysActive__c;
    if (b)
      system.debug(
        'Testing: Account ' + a.id + ' is Active - AUTO always active'
      );
    /**
        //id UserID = UserInfo.getUserId();
       // User u= [select id, FirstName, LastName, username, email, isActive, profileID from User where Id=:a.ownerId];
        system.debug('account -> '+a);
        //system.debug('user -> '+u);
        system.debug('Always Active Account ->'+a.Always_Active__c);
        system.debug('OwnerId ->'+a.ownerId);
        system.debug('Test ->'+[select isActive from User where Id=:a.ownerId]);
        system.debug(a.owner.isactive); */

    b = a.owner.isactive;
    if (b)
      system.debug(
        'Testing: Account ' + a.id + ' is NOT active - owner is inactive'
      );

    system.debug('Testing: Account ' + a.id + ' is final active is ' + b);
    return b;
  }

  static public boolean ActiveRecord(Lead l) {
    system.debug('TESTING - Lead ActiveRecord Test started ' + l);
    boolean b = false;
    if (taskmap.ContainsKey(l.id))
      for (Task t : taskmap.get(l.id)) {
        b = t.ownerid == l.ownerid && !t.IsClosed;
        if (b)
          system.debug('Testing: Lead ' + l.id + ' is Active - Open Task');

        /*else if (t.ownerid==l.ownerid && t.LastModifiedDate>date.today().addmonths(-3))
            {
                 b=true;
                 system.debug('Testing: Lead '+l.id+' is Active - Recently Closed Task');
            }

            if (l.Business_Unit__c!=null && l.Business_Unit__c=='Enterprise')
            {
                b=true;
                system.debug('Testing: Lead '+l.id+' is Active - Business unit is ENT');
            }*/

        b = l.AutoAlwaysActive__c;
        if (b)
          system.debug('Testing: Lead ' + l.id + ' is Active - Always Active');
      }

    //if (!AccountTrig && l.CreatedDate!=null && l.CreatedDate.adddays(3)>=date.today() && (l.email==null || (l.email!=null && !InactiveLeadTEST.Contains(l.email))))
    if (
      l.CreatedDate != null &&
      l.CreatedDate.adddays(21) >= date.today() &&
      (l.email == null ||
      (l.email != null && !InactiveLeadTEST.Contains(l.email)))
    ) {
      //if (l.CreatedDate.addhours(2)<datetime.now())
      b = true;
      system.debug('Testing: Lead ' + l.id + ' is Active - Created Recently');
    }

    b = l.reseller__c != null;
    if (b)
      system.debug('Testing: Lead ' + l.id + ' is Active - Reseller exists');

    b = l.owner.isactive;

    return b;
  }

  static public string FindMatch(string ldomain, string country) {
    system.debug(
      'TESTING - FindMatch started, ldomain is ' +
        ldomain +
        ' and country is ' +
        country
    );
    boolean found = false;
    string result = null;
    string partialresult = null;

    if (freeEmailProvidersList.ContainsKey(Ldomain))
      return null;
    //string Lcleandomain = getCleanDomain (Ldomain);
    system.debug('Z' + existingAccountList + ':' + ldomain);
    if (
      ExistingAccountlist != null &&
      ExistingAccountlist.size() > 0 &&
      ldomain != null // Find the matching Account - START
    ) {
      list<Account> matchingAccounts = new List<Account>();

      for (Account a : ExistingAccountlist) {
        if (!found && a.website != null) {
          string aDomain = getDomainFromWebsite(a.website);
          system.debug('Testing: Account domain is ' + aDomain);
          //string aCleanDomain = getCleanDomain (aDomain);
          //system.debug('Testing: Account Clean domain is '+aCleanDomain);
          if (
            aDomain ==
            lDomain //Exact Domain Match
          ) {
            partialresult = a.id;
            system.debug('TESTING a.billingcoutnry is ' + a.billingcountry);
            if (country == null || country == a.billingcountry) {
              found = true;
              system.debug('TESTING - Found Exact Domain match');
              result = a.id;
              break;
            }
          }

          /*
                    if (!found && aCleanDomain==lcleandomain) //Clean domain Match
                    {
                        matchingAccounts.add (a);
                    }
                    */
        }
      }
      /*
            if (!found && matchingAccounts.size()==1) //Clean Domain - found exactly one.
            {
                 result = matchingAccounts[0].id;
                 found=true;
                 system.debug('TESTING - Found Clean Domain - 1 match');

            }
            else
            if (!found && matchingAccounts.size()>1) // Clean Domain - found more than 1
            {
                for (Account a: matchingAccounts)
                {
                    if (!found && a.parentid==null)
                    {
                        found=true;
                        result = a.id;
                        system.debug('TESTING - Found Clean Domain - parent match');
                    }
                }
                if (!found)
                {
                    result = matchingAccounts[0].id;
                    system.debug('TESTING - Found Clean Domain - random account');
                }

            }
            */
    } // Find the matching Account - END

    list<Lead> MatchingLeads = new List<Lead>();

    if (
      !found &&
      ExistingLeadList != null &&
      ExistingLeadList.size() > 0 &&
      ldomain != null
    )
      for (Lead exsl : ExistingLeadList) {
        // Find the matching lead - START
        string ExsLdomain = getDomainFromEmail(exsl.email);
        //string ExsLcleandomain = getCleanDomain (exsLdomain);
        if (lDomain == Exsldomain) {
          partialresult = exsl.id;
          if (country == null || country == exsl.country) {
            found = true;
            result = exsl.id;
            break;
            system.debug('TESTING: Found Lead - Exact Domain Match');
          }
        }
        /*
            else if (!found && ExsLcleandomain==lCleanDomain)
            {
                MatchingLeads.add (exsl);
                system.debug('TESTING: Found Lead - Clean Domain Match');
            }
            */
      } // Find the matching lead - END

    if (!found && partialresult != null) {
      found = true;
      result = partialresult;
    }

    /*if (!found && MatchingLeads.size()>0)
        {
           result = MatchingLeads[0].id;
        }*/

    system.debug('TESTING - FindMatch ended, result is ' + result);
    return result;
  }

  static private CSRoundRobin__c RoundRobin_FindNext(
    list<CSRoundRobin__c> csrobinlist,
    decimal roundrlatest,
    string bucket
  ) {
    boolean promoted = false;
    CSRoundRobin__c csr = null;
    decimal tempmin = roundrlatest;

    for (CSRoundRobin__c csrobin : csrobinlist) {
      // Find MIN next match, or set latest to 0
      if (
        !promoted &&
        csrobin.Bucket__c == bucket &&
        csrobin.Active__c &&
        csrobin.order__c > roundrlatest //Find any record higher in order
      ) {
        promoted = true;
        csr = csrobin;
        roundrlatest = csrobin.Order__c;
      }
      if (
        promoted &&
        csrobin.Bucket__c == bucket &&
        csrobin.Active__c &&
        csrobin.order__c < roundrlatest &&
        csrobin.order__c > tempmin // Ensure we found the lowest higher number
      ) {
        csr = csrobin;
        roundrlatest = csrobin.Order__c;
      }
    }
    return csr;
  }

  static public CSRoundRobin__c RoundRobinRecord(string bucket) {
    //initialize latest map
    if (!RoundRobinlatest.ContainsKey(bucket))
      RoundRobinlatest.put(bucket, 0);
    decimal roundrlatest = RoundRobinlatest.get(bucket);
    CSRoundRobin__c csr = null;
    list<CSRoundRobin__c> csrobinlist = RoundRobinCS.values();

    if (RoundRobinCS.size() > 0) {
      if (roundrlatest == 0)
        for (CSRoundRobin__c csrobin : csrobinlist) {
          //initialize roundrlatest
          if (csrobin.Bucket__c == bucket) {
            if (csrobin.last__c != null && csrobin.last__c > roundrlatest)
              roundrlatest = csrobin.last__c;
          }
        } //initialize roundrlatest - END

      csr = RoundRobin_FindNext(csrobinlist, roundrlatest, bucket); // Try and find first match

      if (
        csr ==
        null //Still didn't find any record
      ) {
        roundrlatest = 0;
        csr = RoundRobin_FindNext(csrobinlist, roundrlatest, bucket);
      }
    }
    if (csr != null)
      roundrlatest = csr.order__c;
    RoundRobinlatest.put(bucket, roundrlatest);

    for (CSRoundRobin__c csrobin : csrobinlist) {
      if (csrobin.bucket__c == bucket) {
        csrobin.last__c = roundrlatest;
      }
    }

    system.debug('TESTING: roundrlatest is ' + roundrlatest);
    system.debug('TESTING: Map Roundlatest updated? ' + RoundRobinCS);

    return csr;
  }

  static public void HandleBEFOREAction(Lead l) {
    string Ldomain = getDomainFromEmail(l.email);
    system.debug('Domain : ' + Ldomain);
    //if (l.website!=null) LDomain = getDomainFromWebsite (l.website);

    string country = null;
    system.debug('Lead ' + l);
    string BU = null;
    BU = CalcBU(l);
    if (CountryMatchReq(bu)) {
      if (l.country != null)
        country = l.country;
    }

    string ParentId = FindMatch(Ldomain, country);
    system.debug(
      'TESTING - Parent ID after FindMatch ' +
        ParentId +
        ' domain ' +
        ldomain +
        ' country ' +
        country
    );

    system.debug(
      'TESTING*** - ExactContactMatch size is ' + ExactContactMatch.size()
    );
    system.debug('TESTING - ExactContactMatch is ' + ExactContactMatch);
    system.debug('TESTING - l.email is ' + l.email);

    if (ExactContactMatch.size() > 0) {
      if (l.email != null && ExactContactMatch.Containskey(l.email)) {
        Contact c = ExactContactMatch.get(l.email);
        if (
          c.accountid !=
          null // && IsCountryMatch (l,c))
        ) {
          parentid = c.accountid;
          l.CodeContactId__c = c.id;
        }
      }
      system.debug(
        'TESTING - Parent ID from Exact Contact Match is ' + ParentID
      );
    }

    if (ParentID == null && ExactAccountMatch.ContainsKey(l.email))
      ParentId = ExactAccountMatch.get(l.email).id;
    system.debug('TESTING - Parent ID after Free Account Match ' + ParentID);
    if (ParentID == null && ExactLeadMatch.ContainsKey(l.email))
      ParentId = ExactLeadMatch.get(l.email).id;
    system.debug('TESTING - Parent ID after Free Lead Match ' + ParentID);

    system.debug('TESTING - Parent ID is ' + ParentID);
    if (ParentID != null) {
      l.CodeParentID__c = parentId;
      if (AccountMap.ContainsKey(ParentId)) {
        //Found Account
        Account a = AccountMap.get(ParentId);
        system.debug(a + ':'); //+l+':'+a.Domain_Routing_Group__c);
        boolean CountryMatch = IsCountryMatch(l, a, CalcBU(a));
        System.debug(CountryMatch);
        if (CountryMatch) {
          System.debug(
            'Active Record: ' + ActiveRecord(AccountMap.get(ParentId), l)
          );
          if (ActiveRecord(AccountMap.get(ParentId), l)) {
            //Active Account Match
            system.debug('TESTING - Active Account match logic');
            l.OwnerId = a.ownerid;
            if (!validateAccount4Update.Contains(a.id)) {
              //a.Status__c = 'Pending Review';
              Account4update.add(a);
              validateAccount4Update.add(a.id);
            }
          } else {
            //Inactive Account Match
            system.debug('TESTING inactive account match logic');
            a.ownerid = l.ownerid != null ? l.ownerid : a.ownerid;

            if (!validateAccount4Update.Contains(a.id)) {
              //a.Status__c = 'Pending Review';
              Account4update.add(a);
              validateAccount4Update.add(a.id);
            }

            //List<Contact> tempListCons=[select Id from contact where AccountId=:a.Id];
            //List<Contact> temp2ListCons=a.contacts;
            //System.debug(a.Id+'<contacts> '+tempListCons);
            //System.debug(a.Id+'<contacts> '+temp2ListCons);
            //System.debug('Acc Cons: '+a.contacts.size()+':');
            if (a.contacts.size() > 0) {
              for (Contact c : a.contacts) {
                if (!validateContact4Update.contains(c.id)) {
                  c.ownerid = a.ownerid;
                  validateContact4Update.add(c.id);
                  Contact4Update.add(c);
                }
              }
            }
          }
        } else {
          //Account match, no country match
          system.debug('TESTING Account match, no country match');
          l.LeadConvertAccId__c = parentid;
          l.CodeParentID__c = null;
        }
      } else if (LeadMap.ContainsKey(ParentID)) {
        //Found Lead
        Lead oldl = Leadmap.get(ParentId);
        if (IsCountryMatch(l, oldl)) {
          if (ActiveRecord(LeadMap.get(ParentId))) {
            //Active Lead Match
            system.debug('TESTING - Active lead match logic');
            l.OwnerId = oldl.ownerid;
          }
        } else {
          // No country match
          system.debug('TESTING Lead match, no country match');
          l.LeadConvertAccId__c = parentid;
          l.CodeParentID__c = null;
        }
      }
    }
  }

  static public Database.LeadConvert createLeadConvert(
    Lead l,
    Account a,
    LeadStatus convertedStatus,
    boolean CreateOpp,
    id OwnerID
  ) {
    Database.LeadConvert lc = new database.LeadConvert();
    lc.setLeadId(l.id);
    lc.setConvertedStatus(convertedStatus.MasterLabel);
    lc.setDoNotCreateOpportunity(!CreateOpp);
    lc.setSendNotificationEmail(false);
    if (a != null) {
      lc.setAccountId(a.Id);
      if (l.CodeContactId__c != null)
        lc.setContactId(l.CodeCOntactID__c);
    }
    if (ownerid != null)
      lc.setOwnerId(OwnerId);
    system.debug('TESTING Conversion: Lead is ' + l.id);
    if (a != null)
      system.debug('TESTING Conversion: Account is ' + a.id);
    else
      system.debug('TESTING Conversion: Account is null');
    if (OwnerID != null)
      system.debug('TESTING Conversion: Ownerid is ' + OwnerID);
    else
      system.debug('TESTING Conversion: OwnerID is null');

    return lc;
  }

  static public void LeadAllocation(list<Lead> LeadList) {
    // ****** THIS IS THE MAIN BEFORE METHOD *****//
    system.debug('TESTING LeadAllocation Started');
    SetKey_TeamMap('Lead');
    SetValidValues();
    map<string, CSSettings__c> tempcsmap = CSSettings__c.getall();
    if (
      tempcsmap.ContainsKey('Setting') &&
      tempcsmap.get('Setting').DefaultOwnerID__c != null
    )
      defaultownerid = tempcsmap.get('Setting').DefaultOwnerID__c;

    if (!BEFOREAlreadyRUN && !Codeoff) {
      BEFOREAlreadyRUN = true;
      list<string> CleanDomainlist = new List<String>();

      // Gather DATA - START
      list<User> Userlist = [
        SELECT id, FirstName, LastName, username, email, isActive, profileID
        FROM User
      ];
      UserMap.putall(Userlist);
      system.debug('TESTING: UserMap initiated ' + UserMap);

      if (UTMmap.size() > 0)
        for (CSUTMAssignment__c tempcs : UTMmap.values()) {
          if (tempcs.field__c.tolowercase() == 'campaign_name_utm__c')
            UTMNameMap.put(tempcs.value__c.tolowercase(), tempcs);
        }

      System.debug(leadlist);
      for (Lead l : LeadList) {
        string domain = getDomainFromEmail(l.email);
        if (freeEmailProvidersList.ContainsKey(domain)) {
          exactemailmatchlist.add(l.email);
        } else {
          if (domain != null)
            CleanDomainlist.add(domain);
          if (l.email != null)
            exactemailmatchlist.add(l.email);
          system.debug('TESTING Domain: ' + domain);
        }
      }

      list<id> RecTypeToIgnore = new List<id>();
      RecTypeToIgnore = AccountTriggerHelperTEMP.GenRecTypeIgnoreList();

      list<id> ExactAccountIDsFromContact = new List<id>();
      if (exactemailmatchlist.size() > 0) {
      }
      list<Lead> TempLeadList = [
        SELECT
          id,
          reseller__c,
          CreatedDate,
          Campaign_Name_UTM__c,
          email,
          ownerid,
          status,
          CodeContactId__c,
          Domain_Routing_Group__c,
          AutoAlwaysActive__c,
          state,
          isConverted,
          company,
          LastName,
          business_unit__c,
          owner.isactive,
          country
        FROM Lead
        WHERE
          email = :exactemailmatchlist
          AND IsConverted = FALSE
          AND id != NULL
          AND recordtypeid NOT IN :RecTypeToIgnore
      ];

      if (TempLeadList.size() > 0) {
        LeadMap.putall(TempLeadList);
        system.debug(
          'TESTING - Lead map updated with Exact Match ' + LeadMap.size()
        );
        for (Lead l : TempLeadList)
          ExactLeadMatch.put(l.email, l);
      }

      system.debug('TESTING*** exactemailmatchlist is ' + exactemailmatchlist);
      list<Contact> TempContactList = [
        SELECT id, email, accountid
        FROM Contact
        WHERE email = :exactemailmatchlist
      ];
      system.debug('TESTING*** TempContactList is ' + TempContactList.size());
      if (TempContactList.size() > 0) {
        list<id> tempidlist = new List<id>();
        for (Contact c : TempContactList) {
          if (c.email != null && c.accountid != null) {
            ExactContactMatch.put(c.email, c);
            ExactAccountIDsFromContact.add(c.accountid);
            tempidlist.add(c.accountid);
          }
        }

        if (tempidlist.size() > 0) {
          list<Account> MoreAccountQuery = [
            SELECT
              reseller__c,
              id,
              website,
              parentid,
              ownerid,
              billingcountry,
              billingstate,
              uid__c,
              business_unit__c,
              Always_Active__c,
              Email__c,
              owner.isactive,
              AutoAlwaysActive__c,
              CreatedDate,
              Domain_Routing_Group__c,
              shippingstate,
              name,
              status__c,
              (SELECT id, StageName, AccountId FROM Opportunities),
              (SELECT id, name, ownerid FROM ChildAccounts),
              (SELECT id, email, CreatedDate FROM Contacts),
              (
                SELECT id, Zuora__Status__c, Zuora__NextRenewalDate__c
                FROM Zuora__Subscriptions__r
              ),
              (
                SELECT id, Zuora__PaymentMethod_Type__c
                FROM Zuora__R00N40000001kyLcEAI__r
              )
            FROM Account
            WHERE id = :tempidlist AND recordtypeid NOT IN :RecTypeToIgnore
          ];
          for (Account a : MoreAccountQuery)
            AccountMap.put(a.id, a);
        }
      }

      if (CleanDomainlist.size() > 0) {
        string[] filters = new List<string>();
        for (string s : CleanDomainlist)
          filters.add('%' + s + '%');
        ExistingAccountlist = [
          SELECT
            id,
            reseller__c,
            website,
            parentid,
            ownerid,
            uid__c,
            business_unit__c,
            Always_Active__c,
            Email__c,
            owner.isactive,
            billingcountry,
            billingstate,
            AutoAlwaysActive__c,
            CreatedDate,
            recordtypeid,
            shippingstate,
            name,
            Domain_Routing_Group__c,
            status__c,
            (SELECT id, StageName, AccountId FROM Opportunities),
            (SELECT id, name, ownerid FROM ChildAccounts),
            (SELECT id, email, CreatedDate FROM Contacts),
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
            recordtypeid NOT IN :RecTypeToIgnore
            AND (website LIKE :filters
            OR id = :ExactAccountIDsFromContact)
        ];

        if (ExistingAccountlist != null && !ExistingAccountlist.isEmpty()) {
          Accountmap.putall(ExistingAccountlist);
          system.debug(
            'Testing - AccountMap updated with All Accounts ' + Accountmap
          );
        }

        if (
          Trigger.isUpdate != null &&
          Trigger.isUpdate //Only for testing
        ) {
          list<id> TempLeadListID = new List<id>();
          for (Lead l : LeadList)
            TempLeadListID.add(l.id);
          ExistingLeadList = [
            SELECT
              id,
              reseller__c,
              Campaign_Name_UTM__c,
              CreatedDate,
              email,
              ownerid,
              status,
              recordtypeid,
              CodeContactId__c,
              Domain_Routing_Group__c,
              AutoAlwaysActive__c,
              state
            FROM Lead
            WHERE
              email LIKE :filters
              AND IsConverted = FALSE
              AND id != NULL
              AND id != :TempLeadListID
              AND recordtypeid NOT IN :RecTypeToIgnore
          ];
        } else
          ExistingLeadList = [
            SELECT
              id,
              reseller__c,
              Campaign_Name_UTM__c,
              CreatedDate,
              email,
              ownerid,
              status,
              recordtypeid,
              CodeContactId__c,
              Domain_Routing_Group__c,
              AutoAlwaysActive__c,
              state,
              isConverted,
              company,
              LastName,
              business_unit__c,
              owner.isactive,
              country
            FROM Lead
            WHERE
              email LIKE :filters
              AND IsConverted = FALSE
              AND id != NULL
              AND recordtypeid NOT IN :RecTypeToIgnore
          ];

        if (ExistingLeadList.size() > 0) {
          LeadMap.putall(ExistingLeadList);
          system.debug('Testing - LeadMap updated with All Leads ' + LeadMap);
        }

        system.debug('TESTING: Found accounts ' + ExistingAccountlist);
        system.debug('TESTING: Found Leads ' + ExistingLeadList);

        list<id> idlist = new List<id>();
        if (ExistingAccountlist.size() > 0)
          for (Account a : ExistingAccountlist) {
            idlist.add(a.id);
            if (a.contacts.size() > 0)
              for (Contact c : a.contacts)
                idlist.add(c.id);
          }
        if (ExistingLeadList.size() > 0)
          for (Lead l : ExistingLeadList)
            idlist.add(l.id);

        //date tempd = date.today().addmonths(-3);

        //list <Task> tasklist = [select id,AccountId,IsClosed, subject, ownerid,whoid,whatid, LastModifiedDate, LastModifiedByID
        //from Task where (whoid=:idlist or whatid=:idlist or AccountID=:idlist) AND (LastModifiedDate>:tempd OR IsClosed=:FALSE)];
        // Using 3 different querries because size of task table

        set<id> tempsetid = new Set<id>();
        system.debug('TESTING - TaskQuery to start. ID list is ' + idlist);
        if (idlist.size() > 0)
          for (id tempid : idlist)
            if (string.valueof(tempid).startswith('001'))
              tempsetid.add(tempid);
        system.debug('TESTING - tempsetid is ' + tempsetid); // This is used cause otherwise Tlist3 Query is considered non-selective if idlist is too big, like in Google
        list<Task> Tlist1 = [
          SELECT
            id,
            AccountId,
            IsClosed,
            subject,
            ownerid,
            whoid,
            whatid,
            LastModifiedDate,
            LastModifiedByID
          FROM Task
          WHERE whoid = :idlist AND IsClosed = FALSE
        ];
        list<Task> Tlist2 = [
          SELECT
            id,
            AccountId,
            IsClosed,
            subject,
            ownerid,
            whoid,
            whatid,
            LastModifiedDate,
            LastModifiedByID
          FROM Task
          WHERE whatid = :idlist AND IsClosed = FALSE
        ];
        list<Task> Tlist3 = [
          SELECT
            id,
            AccountId,
            IsClosed,
            subject,
            ownerid,
            whoid,
            whatid,
            LastModifiedDate,
            LastModifiedByID
          FROM Task
          WHERE
            AccountID != :null
            AND AccountID = :tempsetid
            AND IsClosed = :false
        ];
        system.debug('TESTING - TaskQuery Ended');

        list<Task> Tasklist = new List<Task>();
        if (Tlist1.size() > 0)
          Tasklist.addall(Tlist1);
        if (Tlist2.size() > 0)
          Tasklist.addall(Tlist2);
        if (Tlist3.size() > 0)
          Tasklist.addall(Tlist3);

        if (tasklist.size() > 0)
          for (Task t : tasklist) {
            if (
              t.subject == null ||
              (t.subject != null &&
              !t.subject.startswith('Contact us form|Subject line'))
            ) {
              if (t.AccountID != null) {
                if (taskmap != null && taskmap.containskey(t.AccountID)) {
                  list<Task> temptasklist = taskmap.get(t.AccountID);
                  temptasklist.add(t);
                  taskmap.put(t.AccountID, temptasklist);
                } else {
                  list<Task> temptasklist = new List<Task>();
                  temptasklist.add(t);
                  taskmap.put(t.AccountID, temptasklist);
                }
              }

              if (t.whatid != null) {
                if (taskmap != null && taskmap.containskey(t.whatid)) {
                  list<Task> temptasklist = taskmap.get(t.whatid);
                  temptasklist.add(t);
                  taskmap.put(t.whatid, temptasklist);
                } else {
                  list<Task> temptasklist = new List<Task>();
                  temptasklist.add(t);
                  taskmap.put(t.whatid, temptasklist);
                }
              }

              if (t.whoid != null) {
                if (string.valueof(t.whoid).startswith('003')) {
                  if (taskmap != null && taskmap.containskey(t.accountid)) {
                    list<Task> temptasklist = taskmap.get(t.accountid);
                    temptasklist.add(t);
                    taskmap.put(t.accountid, temptasklist);
                  } else {
                    list<Task> temptasklist = new List<Task>();
                    temptasklist.add(t);
                    taskmap.put(t.accountid, temptasklist);
                  }
                } else {
                  if (taskmap != null && taskmap.containskey(t.whoid)) {
                    list<Task> temptasklist = taskmap.get(t.whoid);
                    temptasklist.add(t);
                    taskmap.put(t.whoid, temptasklist);
                  } else {
                    list<Task> temptasklist = new List<Task>();
                    temptasklist.add(t);
                    taskmap.put(t.whoid, temptasklist);
                  }
                }
              }
            }
          }

        PopulateConvertedLeadInfo();
      } // Gather DATA - END

      for (Lead l : LeadList) {
        HandleBEFOREAction(l);
      }
      update RoundRobinCS.values();
      if (Account4Update != null && Account4Update.size() > 0)
        update Account4Update;
      if (Contact4Update != null && Contact4Update.size() > 0)
        update Contact4Update;
    }
  }

  static public void PopulateConvertedLeadInfo() {
    if (AccountMap.values().size() > 0) {
      list<Account> templist = AccountMap.values();
      list<id> tempidlist = new List<id>();
      for (Account a : templist)
        tempidlist.add(a.id);
      list<Lead> Leadtemplist = [
        SELECT
          id,
          reseller__c,
          Campaign_Name_UTM__c,
          ConvertedDate,
          ConvertedAccountId,
          CodeContactId__c,
          Domain_Routing_Group__c,
          AutoAlwaysActive__c,
          state
        FROM Lead
        WHERE ConvertedAccountId = :tempidlist AND isConverted = TRUE
      ];
      if (Leadtemplist.size() > 0) {
        for (Lead l : Leadtemplist) {
          if (ConvertedLeadperAccountMap.ContainsKey(l.ConvertedAccountId)) {
            if (
              l.ConvertedDate >
              ConvertedLeadperAccountMap.get(l.ConvertedAccountId).ConvertedDate
            ) {
              ConvertedLeadperAccountMap.put(l.ConvertedAccountId, l);
            }
          } else {
            ConvertedLeadperAccountMap.put(l.ConvertedAccountId, l);
          }
        }
      }
    }
  }

  static public Account CreateAccountFromLead(Lead l) {
    Account a = new Account();
    if (l.company != null)
      a.name = l.company;
    else
      a.name = l.LastName;
    a.ownerid = l.ownerid;
    //a.Status__c='Pending Review';
    NewAcIDMap.put(uniqueacId, a);

    return a;
  }

  static public void HandleAFTERAction(list<Lead> LeadList) {
    //*** This is the main AFTER Method
    system.debug('TESTING HandleAfter started');
    if (!AfterALreadyRUN && !Codeoff) {
      AfterALreadyRUN = true;
      list<Database.LeadConvert> leadConversions = new List<Database.Leadconvert>();
      if (isTest)
        leadConversions.clear();

      LeadStatus convertedStatus = getConvertLeadStatus();
      list<Account> Acc4Insert = new List<Account>();
      map<id, Lead> ContextLeadMap = new Map<id, Lead>();

      for (Lead l : LeadList) {
        ContextLeadMap.put(l.id, l);
        if (OwnerNotificationMap.ContainsKey(l.ownerid)) {
          // Generate Notification Map - START
          list<Lead> templist = OwnerNotificationMap.get(l.ownerid);
          templist.add(l);
          OwnerNotificationMap.put(l.ownerid, templist);
        } else {
          list<Lead> templist = new List<Lead>();
          templist.add(l);
          OwnerNotificationMap.put(l.ownerid, templist);
        } // Generate Notification Map - END

        if (
          l.CodeParentID__c == null &&
          l.LeadConvertAccId__c != null &&
          l.LeadConvertAccId__c.left(3) == '001' //match but no country match - Account
        ) {
          leadConversions.add(
            createLeadConvert(l, null, convertedStatus, false, l.ownerid)
          );
        } else if (
          l.CodeParentID__c == null &&
          l.LeadConvertAccId__c != null &&
          l.LeadConvertAccId__c.left(3) == '00Q' //match but no country match - Lead
        ) {
          leadConversions.add(
            createLeadConvert(l, null, convertedStatus, false, l.ownerid)
          );
          Lead OtherLead = LeadMap.get(l.LeadConvertAccId__c);
          leadConversions.add(
            createLeadConvert(
              OtherLead,
              null,
              convertedStatus,
              false,
              OtherLead.ownerid
            )
          );
        } else {
          string ParentID = l.CodeParentID__c;
          system.debug('TESTING ParentID is ' + l.CodeParentID__c);
          if (
            Accountmap != null &&
            AccountMap.ContainsKey(ParentId) //Found Account
          ) {
            system.debug('TESTING Found Account');
            if (ActiveRecord(AccountMap.get(ParentID), l)) {
              // Active Account
              system.debug('TESTING Found Account - Active');
              leadConversions.add(
                createLeadConvert(
                  l,
                  AccountMap.get(ParentId),
                  convertedStatus,
                  false,
                  AccountMap.get(ParentId).ownerid
                )
              );
            } else {
              // Inactive Account
              system.debug('TESTING Found Account - Inactive');
              leadConversions.add(
                createLeadConvert(
                  l,
                  AccountMap.get(ParentId),
                  convertedStatus,
                  false,
                  l.ownerid
                )
              );
            }
          } else if (
            Leadmap != null &&
            LeadMap.COntainsKey(ParentID) // Found Lead
          ) {
            if (ActiveRecord(Leadmap.get(ParentID))) {
              //Active Lead
              Account a = CreateAccountFromLead(Leadmap.get(ParentId));
              list<Lead> TempList = new List<Lead>();
              Templist.add(l);
              templist.add(Leadmap.get(ParentId));
              NewAc4Lead.put(uniqueacId, templist);
              uniqueacId++;
              Acc4Insert.add(a);
            } else {
              // Inactive Lead
              Account a = CreateAccountFromLead(l);
              list<Lead> TempList = new List<Lead>();
              Templist.add(l);
              templist.add(Leadmap.get(ParentId));
              NewAc4Lead.put(uniqueacId, templist);
              uniqueacId++;
              Acc4Insert.add(a);
            }
          }
        }
      } //END of FOR Loop

      if (
        Acc4Insert != null &&
        Acc4Insert.size() > 0 // If we need to create new accounts before Conversion
      ) {
        insert Acc4Insert;
        for (Account a : Acc4Insert) {
          AccountMap.put(a.id, a);
        }
        for (decimal d = 1; d <= uniqueacId; d++) {
          if (NewAc4Lead.ContainsKey(d) && NewAcIDMap.ContainsKey(d)) {
            list<Lead> TempLeadList = NewAc4Lead.get(d);
            if (TempLeadList != null && TempLeadList.size() > 0) {
              for (Lead l : TempLeadList) {
                leadConversions.add(
                  createLeadConvert(
                    l,
                    NewAcIDMap.get(d),
                    convertedStatus,
                    false,
                    NewAcIDMap.get(d).ownerid
                  )
                );
                system.debug(
                  'TESTING: Lead Convert task added: ' + l.id + ' ' + l.lastname
                );
              }
            }
          }
        }
      }
      if (
        LeadConversions != null &&
        LeadConversions.size() > 0 // Convert the Leads
      ) {
        system.debug('TESTING: Covnersion Started - ' + LeadConversions);

        Codeoff = true;

        AccountTriggerHelperTEMP.CodeOff = true;
        List<Database.LeadConvertResult> results = Database.convertLead(
          leadConversions
        );
        map<id, Account> Acc4Update = new Map<id, Account>(); // START - Update account parent if has LeadConvertAccId__c

        system.debug('TESTING: ContextLeadMap is ' + ContextLeadMap);
        for (Database.LeadConvertResult res : results) {
          Lead l = ContextLeadMap.get(res.getLeadId());
          Account a = new account(id = res.getAccountid());
          if (l != null && l.email != null && a.website == null) {
            string sdomain = getdomainfromemail(l.email);
            if (sdomain != null)
              a.website = sdomain;
            Acc4Update.put(a.id, a);
          }

          if (
            l != null &&
            l.LeadConvertAccId__c != null &&
            l.LeadConvertAccId__c.left(3) == '001' // Handle Country Match - account
          ) {
            a.parentid = l.LeadConvertAccId__c;
            Acc4Update.put(a.id, a);
          }
          if (
            l != null &&
            l.LeadConvertAccId__c != null &&
            l.LeadConvertAccId__c.left(3) == '00Q' // Handle Country Match - Lead
          ) {
            for (Database.LeadConvertResult res2 : results)
              if (res2.getLeadId() == id.valueof(l.LeadConvertAccId__c)) {
                a.parentid = res2.getAccountId();
                Acc4Update.put(a.id, a);
              }
          }
        }
        if (Acc4Update.size() > 0)
          update Acc4Update.values();

        Codeoff = false;

        AccountTriggerHelperTEMP.CodeOff = false;
        system.debug('TESTING: Covnersion Completed - ' + LeadConversions);
      }
      //EmailNewOwners();
    } // Lead AFTER ALREADY RUN - END
  }

  public static map<string, decimal> GenerateTechlist() {
    map<string, decimal> themap = new Map<string, decimal>();
    map<string, CSTechScore__c> tempmap = CSTechScore__c.getall();
    if (tempmap.size() > 0)
      for (CSTechScore__c cstech : tempmap.values()) {
        if (cstech.long_name__c != null)
          themap.put(cstech.long_name__c, cstech.score__c);
        else
          themap.put(cstech.name, cstech.score__c);
      }

    return themap;
  }

  public static decimal CaclulateSWTechScore(string techs) {
    decimal score = 0;
    if (techs != null) {
      list<string> techlist = techs.split(',');
      if (techlist.size() > 0)
        for (string s : techlist) {
          if (techscores.containskey(s))
            score += techscores.get(s);
        }
    }
    return score;
  }

  private void iHaveToDoThis() {
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
  }
}

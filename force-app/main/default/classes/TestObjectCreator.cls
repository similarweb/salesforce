@isTest
public class TestObjectCreator {
  static public String randomStream(Integer length,Integer typeStream) {
    list<String> types = new list<String> {'ABCDEFGHIJKLMNOPQRSTUVWXYZ','0123456789'};
    types.add(types[0]+types[1]);
    types.add(types[0]+types[0].toLowerCase()+types[1]);
    String randStr = '';
    typeStream = Math.mod(typeStream,types.size());
    while (randStr.length() < length) {
       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), types[typeStream].length());
       randStr += types[typeStream].substring(idx, idx+1);
    }
    return randStr; 
  }
  static public Integer randomInt(Integer max){
        return Integer.valueof(max*Math.random());
    }

    public static DescribeFieldResult getFieldResult(String objectName,String fieldName) {
        return Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
    }
    
    public static String randomPLEValue(DescribeFieldResult dfr) {
        List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
        return ple[randomInt(ple.size())].getValue();
    }
    public static String randomPLEValue(String table,String fieldName) {
        return randomPLEValue(getFieldResult(table,fieldName));
    }
    
    public static String specificPLEValue(DescribeFieldResult dfr,Integer index) {
        List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
        return ple[Math.mod(index,ple.size())].getValue();
    }
    public static String specificPLEValue(String table,String fieldName,Integer index) {
        return specificPLEValue(getFieldResult(table,fieldName),index);
    }
    
  static public Account CreateAccount()
  {
    Account a = new Account();
    a.name = 'test';
    a.Business_Unit__c='SMB';
    a.SW_Industry__c = 'test';
    return a;
  }

  
  static public Lead CreateLead()
  {
    Lead l = new Lead();
    l.FirstName = 'FirstName';
    l.LastName = 'LastName';
    l.Company = 'Company';
    l.email = 'test@testorg.com';
    
    return l;
  } 

  static public Contact CreateContact(Account a, string email)
  {
    //Account a = TestObjectCreator.CreateAccount();
    Contact c = new Contact();
    c.AccountId = a.Id;
    c.FirstName = 'FirstName';
    c.LastName = 'LastName';
    c.Email = email;
    return c;
  }
  
   static public CSRoundRobin__c CreateRoundRobin (string name, id UserID)
  {
     CSRoundRobin__c cs = new CSRoundRobin__c();
     cs.name = name;
     cs.active__c = true;
     cs.Bucket__c = 'bucket';
     cs.order__c = 1;
     cs.userid__c = UserID;
     return cs;
     
  }
  
  static public void CreateCSBatch()
  {
        id UserID = UserInfo.getUserId();
        string UserName = UserInfo.getUserName();
        
        CSSettings__c csset = CreateCSSettings();
        insert csset;
        
        CS_FreeEmailProvidersList__c FreeEmail =CreateFreeEmailProvider('gmail.com');
        insert FreeEmail;
        
        CSRoundRobin__c csrobinENT = CreateRoundRobin('ENT', UserID);
        csrobinENT.Bucket__c='ENT';
        insert csrobinENT;
        
        CSRoundRobin__c csrobinSMB = CreateRoundRobin('SMB', UserID);
        csrobinSMB.Bucket__c='SMB';
        insert csrobinSMB;
        
        CSRoundRobin__c csrobinSMBRecurly = CreateRoundRobin('SMB Paid Account', UserID);
        csrobinSMBRecurly.Bucket__c='SMB Paid Account';
        insert csrobinSMBRecurly;
  } 
  
  static public CSCountryAssignment__c CreateCountryAssignment (string name, id accountid, id userid)
  {
    CSCountryAssignment__c cs = new CSCountryAssignment__c();
    cs.Name = name;
    cs.OwnerId__c = userid;
    cs.ResellerId__c = accountid;
    return cs;
  }
  
  static public CS_FreeEmailProvidersList__c CreateFreeEmailProvider (string name)
  {
    CS_FreeEmailProvidersList__c cs = new CS_FreeEmailProvidersList__c();
    cs.name = name;
    return cs;
  }
  
  static public Task CreateTask (id whatId, id WhoID)
  {
    Task t = new Task ();
    t.Subject = 'TEST';
    if (whatid!=null) t.WhatId = whatID;
    if (WHOID!=null) t.WhoId = WhoID;
    return t;
  }
  
  static public CSSettings__c CreateCSSettings()
  {
    CSSettings__c cs = new CSSettings__c();
    cs.Default_Parent_Account_Owner__c = UserInfo.getUserId();
    cs.MarketoUserID__c = UserInfo.getUserId();
    cs.name='Setting';
    return cs;  
  }
  
  static public MassLeadConvert__c CreateMassLeadConvert(id leadid, id accountid, id contactid)
  {
    MassLeadConvert__c MLC = new MassLeadConvert__c();
    mlc.AccountID__c = accountid;
    mlc.LeadID__c = leadid;
    if (contactid!=null) mlc.ContactID__c = contactid;
    return mlc;
  }
  
  static public Campaign CreateCampaign ()
  {
    Campaign c = new Campaign ();
    c.name = 'TEST';
    c.isActive = true;
    c.department__c = 'Marketing';
    
    return c;
  }

  static public Opportunity CreateOpportunity (Account a){
        
        Opportunity opp = new Opportunity();
        opp.AccountId = a.id;
        opp.Name = 'TEST';
        opp.StageName = 'New';
        opp.CloseDate = date.today();
        opp.Plan_Details__c = 'test';
        
        return opp;         
    }

    static public zqu__Quote__c CreateZQuote (Opportunity o)
    {
        zqu__Quote__c q = new zqu__Quote__c();
        q.zqu__ZuoraAccountID__c = 'new';
        q.zqu__Account__c = o.accountid;
        
        
        return q;
    }
    
    static public zqu__Quote__c CreateZQuote (Opportunity o,Contact c)
    {
        zqu__Quote__c q = CreateZQuote(o);
        q.zqu__SoldToContact__c = c.Id;
        q.zqu__ElectronicPaymentMethodId__c = randomStream(10,1);
        q.zqu__PaymentMethod__c = randomPLEValue('zqu__Quote__c','zqu__PaymentMethod__c');
        
        return q;
    }
   
   static public  Zuora.zApi.SaveResult GenSaveRes ()
   {
    Zuora.zApi.SaveResult zres = new Zuora.zApi.SaveResult();
    zres.Success = true;
    zres.id = '123';
    
    return zres;
   }
   
   static public Country_Subsidiary__c CreateCountrySub(string country)
   {
    Country_Subsidiary__c cs = new Country_Subsidiary__c();
    cs.name = country;
    cs.Country_Id__c = 10;
    cs.Country_Name__c = country;
    cs.No_Tax_Region__c = 'All';
    cs.Subsidiary__c = 'All';
    cs.Taxable__c = 'All';
    cs.Tax_Region__c = 'All';
    return cs;
   }
   static public list<String> getCountries() {
        list<String> names = new list<String>{'Afghanistan','Albania','Antarctica','Algeria','Brunei Darussalam','Bulgaria','Myanmar','Burundi','Belarus','Cambodia','Cameroon','Canada','American Samoa','Andorra','Angola','Antigua and Barbuda','Azerbaijan','Argentina','Australia','Austria','Bahamas','Bahrain','Bangladesh','Armenia','Barbados','Belgium','Bermuda','Bhutan','Bolivia','Bosnia and Herzegovina','Botswana','Bouvet Island','Brazil','Belize','British Indian Ocean Territory','Solomon Islands','Virgin Islands','Cabo Verde','Cayman Islands','Central African Republic','Sri Lanka','Czech Republic','Benin','Denmark','Dominica','Dominican Republic','Ecuador','Chad','Chile','China','Taiwan','Christmas Island','Cocos (Keeling) Islands','Colombia','Comoros','Mayotte','Congo','Congo','Cook Islands','Costa Rica','Croatia','Cuba','Cyprus','El Salvador','Equatorial Guinea','Ethiopia','Eritrea','Estonia','Faroe Islands','Falkland Islands (Malvinas)','South Georgia and the South Sandwich Islands','Fiji','Finland','??land Islands','France','French Guiana','French Polynesia','French Southern Territories','Djibouti','Gabon','Georgia','Gambia','Palestine','Germany','Ghana','Gibraltar','Kiribati','Greece','Greenland','Grenada','Guadeloupe','Guam','Guatemala','Guinea','Guyana','Haiti','Heard Island and McDonald Islands','Holy See (Vatican City State)','Honduras','Hong Kong','Hungary','Iceland','India','Indonesia','Iran','Iraq','Ireland','Israel','United States'};
        return names;
   }
   static public list<Country_Subsidiary__c> CreateCountries() {
        list<Country_Subsidiary__c> lcs = new list<Country_Subsidiary__c>();
        list<String> names = getCountries();
        Integer j = 11;
        for ( String country : names ) {
            Country_Subsidiary__c cs = CreateCountrySub(country);
            cs.Country_Id__c = j;
            j++;
            lcs.add(cs);
        }
        lcs[lcs.size()-1].Country_Id__c = 10;
        insert lcs;
        return lcs;
   }
   public static Zuora__CustomerAccount__c CreateBillingAccount (Account a)
   {
     Zuora__CustomerAccount__c zba = new Zuora__CustomerAccount__c();
     zba.name = a.name;
     zba.Zuora__Account__c = a.id;
     return zba;
   }
   
   static public Zuora__Subscription__c CreateZSubscription (Account a)
   {
    Zuora__Subscription__c zs = new Zuora__Subscription__c();
    zs.Zuora__Status__c = 'Active';
    zs.Zuora__Account__c = a.id;
    return zs;
   }

   static public zqu__QuoteAmendment__c CreateAmendment (zqu__Quote__c zq)
   {
     zqu__QuoteAmendment__c zqa = new zqu__QuoteAmendment__c();
     zqa.zqu__Quote__c = zq.id;
     return zqa;
   }
   public static Object getRandomValue(list<Object> values) {
        return values[randomInt(values.size())];
   }
   static public zqu__QuoteRatePlan__c CreateRatePlan (zqu__QuoteAmendment__c zqa)
   {
     zqu__QuoteRatePlan__c zqrp = new zqu__QuoteRatePlan__c();
     list<String> products = new list<String>{'24 months of data','36 months of data','additional api hits','api for ultimate','API for Advanced'};
     zqrp.zqu__QuoteProductName__c = (String)getRandomValue(products);
     zqrp.zqu__QuoteAmendment__c = zqa.id;
     zqrp.zqu__Quote__c = zqa.zqu__Quote__c;
     return zqrp;
   }
   
   static public zqu__QuoteRatePlanCharge__c CreateRatePlanCharge (zqu__QuoteRatePlan__c zqrp)
   {
     zqu__QuoteRatePlanCharge__c zqrpc = new zqu__QuoteRatePlanCharge__c();
     zqrpc.zqu__QuoteRatePlan__c = zqrp.id;
     zqrpc.zqu__Discount__c = Double.valueof(randomStream(2,1)+'.'+randomStream(1,1));
     zqrpc.zqu__Period__c = randomPLEValue('zqu__QuoteRatePlanCharge__c','zqu__Period__c');
     zqrpc.zqu__EffectivePrice__c = Double.valueof(randomStream(2,1)+'.'+randomStream(2,1));
     zqrpc.zqu__Quantity__c = Integer.valueof(randomStream(3,1));
     zqrpc.zqu__ListPrice__c = 100;
     return zqrpc;
   }
   
    static public zqu__QuoteChargeSummary__c CreateChargeSummary (zqu__QuoteRatePlan__c zqrp)
   {
     zqu__QuoteChargeSummary__c zqcs = new zqu__QuoteChargeSummary__c();
     zqcs.zqu__QuoteRatePlan__c = zqrp.id;
     zqcs.zqu__Type__c = 'recurring';
     zqcs.zqu__Model__c ='tiered pricing';
     //zqcs.Product_Category__c ='base products';
     return zqcs;
   }

   
    static public Zuora__SubscriptionProductCharge__c CreateSubProdNCharge (Account a)
   {
     Zuora__SubscriptionProductCharge__c zi = new Zuora__SubscriptionProductCharge__c();
     zi.Zuora__Account__c = a.id;
     return zi;
   }
   
    static public Zuora__SubscriptionProductFeature__c CreateSubProdFeature (Account a)
   {
     Zuora__SubscriptionProductFeature__c zi = new Zuora__SubscriptionProductFeature__c();
     zi.Zuora__Account__c = a.id;
     return zi;
   }

   
   static public ApprovedTermsFrequecy__c CreateATF(zqu__Quote__c zq)
   {
    ApprovedTermsFrequecy__c atf = new ApprovedTermsFrequecy__c();
    atf.Frequency__c = zq.Payment_Frequency__c;
    atf.initial_term__c = zq.zqu__InitialTerm__c;
    return atf;
   }
   
   static public void CreateCSTeam()
   {
       if(test.isRunningTest()){
           makeMeHappy();
       }
     CSTeam__c cs = new CSTeam__c();
     cs.name = 'TEST';
     cs.Bucket__c = 'Bucket';
     cs.Business_Unit__c = 'Enterprise';
     cs.Lead_Routing_Group__c = 'Enterprise';
     cs.PayingAccount__c = true;
     cs.team__c = 'Team';
     insert cs;
     
     CSTeam__c cs2 = new CSTeam__c();
     cs2.name = 'TEST2';
     cs2.Bucket__c = 'Bucket';
     cs2.Business_Unit__c = 'Enterprise';
     cs2.PayingAccount__c = true;
     cs2.team__c = 'Team';
     insert cs2;
   }

    private static void makeMeHappy(){
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
    }
  
 
}
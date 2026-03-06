@isTest
private class ZQuoteHandler_Test {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;

    InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
    ismTest.SW_Industry__c = 'AdTech and AdNetwork';
    ismTest.Department__c = 'BI / Analytics';
    ismTest.Inferred_Solution__c = 'Research';
    ismTest.Name = 'test';
    insert ismTest;

    InferralSolutionMapContact__c ismCTest = new InferralSolutionMapContact__c();
    ismCTest.SW_Industry__c = 'AdTech and AdNetwork';
    ismTest.Department__c = 'BI / Analytics';
    ismCTest.Inferred_Solution__c = 'Research';
    ismCTest.Name = 'test';
    insert ismCTest;

    Inferral_Solution_Valid_Criteria_List__c islvcl = new Inferral_Solution_Valid_Criteria_List__c();
    islvcl.Name = 'department__c';
    islvcl.Is_Valid__c = true;
    insert islvcl;

    Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
    islvcl2.Name = 'sw_industry__c';
    islvcl2.Is_Valid__c = true;
    insert islvcl2;

    InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
    islcvcl.Name = 'department__c';
    islcvcl.Is_Valid__c = true;
    insert islcvcl;

    InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
    islcvcl2.Name = 'sw_industry__c';
    islcvcl2.Is_Valid__c = true;
    insert islcvcl2;

    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["account","test"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;
  }

  @istest
  static void TestZuoraQuote() {
    /*RecTypeMap.get(zq.recordtypeid).developername.EqualsIgnoreCase ('Amendment') ||
     RecTypeMap.get(zq.recordtypeid).developername.EqualsIgnoreCase ('Renewal')*/
    CSSettings__c cs = TestObjectCreator.CreateCSSettings();
    insert cs;
    Integer copies = 1;
    list<Account> la = new List<Account>();
    List<String> countries = TestObjectCreator.getCountries();
    for (Integer i = 0; i < copies; i++) {
      Account a = TestObjectCreator.CreateAccount();
      a.billingcountry = countries[countries.size() - 2];
      //a.BillingCountryCode = 'US';
      la.add(a);
    }
    insert la;
    list<Contact> lc = new List<Contact>();
    for (Integer i = 0; i < copies; i++) {
      Contact c = TestObjectCreator.CreateContact(
        la[i],
        'test' + TestObjectCreator.randomStream(9, 2) + '@testing.com'
      );
      c.MailingCountry = countries[countries.size() - 2];
      //c.MailingCountryCode = 'US';
      lc.add(c);
    }
    insert lc;
    list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
    list<Opportunity> lopp = new List<Opportunity>();
    for (Integer i = 0; i < copies; i++) {
      Opportunity o = TestObjectCreator.CreateOpportunity(la[i]);
      o.SBD_Type__c = null;
      lopp.add(o);
    }
    insert lopp;
    list<zqu__Quote__c> zqlist = new List<zqu__Quote__c>();
    for (Integer i = 0; i < copies; i++) {
      zqlist.add(TestObjectCreator.CreateZQuote(lopp[i], lc[i]));
      zqlist[i].zqu__PaymentMethod__c = 'Other';
      zqlist[i].Payment_Frequency__c = 4;
    }
    insert zqlist;

    list<zqu__QuoteChargeDetail__c> zqcdlist = new List<zqu__QuoteChargeDetail__c>();
    for (Integer i = 0; i < copies; i++) {
      zqcdlist.add(new zqu__QuoteChargeDetail__c(zqu__Quote__c = zqlist[i].id));
    }
    insert zqcdlist;
    ZquoteHandler.GetData(zqlist, 'insert');
    list<zqu__QuoteAmendment__c> zqammendments = new List<zqu__QuoteAmendment__c>();
    for (Integer i = 0; i < copies; i++) {
      zqammendments.add(TestObjectCreator.CreateAmendment(zqlist[i]));
    }
    insert zqammendments;
    List<sObject> toInsert = new List<sObject>();
    Product2 prod = new Product2(Name = 'testProd', InternalCode__c = '132');
    toInsert.add(prod);
    Product2 prod2 = new Product2(Name = 'testProd2', InternalCode__c = '123');
    toInsert.add(prod2);
    Product_Restriction__c prodRest = new Product_Restriction__c(
      ItemCode1__c = '132',
      ItemCode2__c = '123',
      ItemMatch__c = 'Yes'
    );
    toInsert.add(prodRest);
    insert toInsert;
    zqu__ProductRatePlan__c prodrp = new zqu__ProductRatePlan__c(
      zqu__Product__c = prod.id
    );
    insert prodrp;
    zqu__ProductRatePlanCharge__c prodrpc = new zqu__ProductRatePlanCharge__c(
      zqu__ProductRatePlan__c = prodrp.id
    );
    insert prodrpc;
    list<zqu__QuoteRatePlan__c> zqplans = new List<zqu__QuoteRatePlan__c>();
    for (Integer i = 0; i < copies; i++) {
      zqplans.add(TestObjectCreator.CreateRatePlan(zqammendments[i]));
      zqplans[i].zqu__ProductRatePlan__c = prodrp.id;
    }
    insert zqplans;
    list<zqu__QuoteRatePlanCharge__c> zqrpclist = new List<zqu__QuoteRatePlanCharge__c>();
    for (Integer i = 0; i < copies / 2; i++) {
      zqrpclist.add(
        new zqu__QuoteRatePlanCharge__c(zqu__QuoteRatePlan__c = zqplans[i].id)
      );
      zqrpclist[i].zqu__ProductRatePlanCharge__c = prodrpc.id;
    }
    insert zqrpclist;
    list<zqu__QuoteChargeSummary__c> zqsumms = new List<zqu__QuoteChargeSummary__c>();

    for (Integer i = 0; i < copies; i++) {
      zqsumms.add(TestObjectCreator.CreateChargeSummary(zqplans[i]));
    }
    insert zqsumms;
    list<Zuora__Subscription__c> zsc = new List<Zuora__Subscription__c>();
    for (Integer i = 0; i < copies; i++) {
      zsc.add(TestObjectCreator.CreateZSubscription(la[i]));
    }
    insert zsc;
    list<Zuora__SubscriptionProductCharge__c> zi = new List<Zuora__SubscriptionProductCharge__c>();

    for (Integer i = 0; i < copies; i++) {
      zi.add(TestObjectCreator.CreateSubProdNCharge(la[i]));
      zi[i].Zuora__Subscription__c = zsc[i].Id;
    }
    insert zi;
    test.starttest();
    ZquoteHandler.GetData(zqlist, 'insert');
    ZQuoteHandler.GenSubPrdnChrgMap(
      new List<Id>((new Map<Id, Account>(la)).keyset())
    );
    //zqlist.add (TestObjectCreator.CreateZQuote (o,c));
    upsert zqlist;

    ZQuoteHandler handler = new ZQuoteHandler(
      new ApexPages.StandardController(zqlist[0])
    );
    ZQuoteHandler.UpdateAccBatch(zQlist, 'Button');
    //ZQuoteHandler.PopulateCountrySubData (q);
    ZQuoteHandler.testForErrors(zqlist[0].id);
    ZQuoteHandler.BuildQuoteChargeMap(new List<Id>{ zqlist[0].id });
    zqu__QuoteRatePlan__c zqqrp_test = [
      SELECT ID
      FROM zqu__QuoteRatePlan__c
      WHERE zqu__Quote__c = :zqlist[0].Id
      LIMIT 1
    ];
    zqu__QuoteRatePlanCharge__c zqrpc = new zqu__QuoteRatePlanCharge__c(
      zqu__Total__c = 1,
      zqu__ListTotal__c = 1,
      zqu__QuoteRatePlan__c = zqqrp_test.Id,
      zqu__ProductName__c = 'Digital Suite - Advisory Services'
    );
    insert zqrpc;
    ZQuoteHandler.Quote2QuoteRatePlanChargeMap.put(
      zqlist[0].Id,
      new List<zqu__QuoteRatePlanCharge__c>{ zqrpc }
    );
    ZQuoteHandler.HandleBefore(
      zqlist,
      new Map<Id, zqu__Quote__c>(zqlist),
      'Insert'
    );
    ZQuoteHandler.HandleBefore(
      zqlist,
      new Map<Id, zqu__Quote__c>(zqlist),
      'Update'
    );
    ZQuoteHandler.HandleBefore(
      zqlist,
      new Map<Id, zqu__Quote__c>(zqlist),
      'Button'
    );
    ZQuoteHandler.ValidateQuotes4ZBilling(zqlist, 'Button');
    Integer k = 0;
    for (zqu__Quote__c zq : zqlist) {
      ZQuoteHandler.SetInvoiceAndCommunicationProfile(zq, lcsc[k++]);
    }
    ZQuoteHandler.GetQuoteTemplateId(zqlist[0]);
    Test.stopTest();
  }

  @istest
  static void ValidateQRPC4Update_Test() {
    //ValidateQRPC4Update (map <id,zqu__QuoteRatePlanCharge__c> TheMap)
    CSSettings__c cs = TestObjectCreator.CreateCSSettings();
    List<String> countries = TestObjectCreator.getCountries();
    insert cs;
    Account a = TestObjectCreator.CreateAccount();
    a.billingcountry = countries[countries.size() - 2];
    //a.billingcountryCode = 'US';
    insert a;
    Contact c = TestObjectCreator.CreateContact(a, 'test@testing.com');
    c.MailingCountry = countries[countries.size() - 2];
    insert c;

    Opportunity o = TestObjectCreator.CreateOpportunity(a);
    o.SBD_Type__c = null;
    insert o;

    zqu__Quote__c q = TestObjectCreator.CreateZQuote(o);
    q.zqu__TermStartDate__c = System.today();
    insert q;

    zqu__QuoteAmendment__c zamend = TestObjectCreator.CreateAmendment(q);
    insert zamend;

    zqu__QuoteRatePlan__c zqrp = TestObjectCreator.CreateRatePlan(zamend);
    insert zqrp;

    ApprovedTermsFrequecy__c atf = TestObjectCreator.CreateATF(q);
    insert atf;

    test.starttest();
    zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge(
      zqrp
    );
    insert qrpc;

    map<id, zqu__QuoteRatePlanCharge__c> TheMap = new Map<id, zqu__QuoteRatePlanCharge__c>();
    TheMap.put(qrpc.id, qrpc);
    ZQuoteHandler.ValidateQRPC4Update(TheMap);

    // GetQuoteTemplateId_Test
    ZQuoteHandler.GetQuoteTemplateId(q);
    Test.stopTest();
  }

  @istest
  static void GenProductRestrictionMap_Test() {
    Test.startTest();
    ZQuoteHandler.GenProductRestrictionMap();
    Test.stopTest();
  }

  //ValidateQuotes4ZBilling(list <zqu__Quote__c> Qlist, string event)
  @istest
  static void ValidateQuotes4ZBillingp_Test() {
    List<String> countries = TestObjectCreator.getCountries();
    Account a = TestObjectCreator.CreateAccount();
    a.billingcountry = countries[countries.size() - 2];
    //a.billingcountryCode = 'US';
    a.Name = 'test my specalname';
    insert a;
    Contact c = TestObjectCreator.CreateContact(a, 'test@testing.com');
    c.MailingCountry = countries[countries.size() - 2];
    insert c;

    Opportunity o = TestObjectCreator.CreateOpportunity(a);
    o.SBD_Type__c = null;
    insert o;

    zqu__Quote__c q = TestDataFactory.createZQuote(o, c);
    q.zqu__TermStartDate__c = System.today();
    insert q;

    zqu__ZProduct__c prod = new zqu__ZProduct__c(
      Name = 'testProd',
      InternalCode__c = 'DigSuAdSer'
    );
    insert prod;

    zqu__ProductRatePlan__c prodrp = new zqu__ProductRatePlan__c(
      zqu__ZProduct__c = prod.id
    );
    insert prodrp;

    zqu__ProductRatePlanCharge__c prodrpc = new zqu__ProductRatePlanCharge__c(
      zqu__ProductRatePlan__c = prodrp.id
    );
    insert prodrpc;

    zqu__QuoteAmendment__c zamend = TestObjectCreator.CreateAmendment(q);
    insert zamend;

    zqu__QuoteRatePlan__c zqrp = TestObjectCreator.CreateRatePlan(zamend);
    zqrp.zqu__ProductRatePlan__c = prodrp.id;
    insert zqrp;

    zqu__QuoteRatePlanCharge__c zqrpc = new zqu__QuoteRatePlanCharge__c(
      zqu__QuoteRatePlan__c = zqrp.id
    );
    zqrpc.zqu__ProductRatePlanCharge__c = prodrpc.id;
    insert zqrpc;

    zqu__QuoteChargeSummary__c zqcs = TestObjectCreator.CreateChargeSummary(
      zqrp
    );
    zqcs.zqu__QuoteRatePlanCharge__c = zqrpc.Id;
    insert zqcs;

    ApprovedTermsFrequecy__c atf = TestObjectCreator.CreateATF(q);
    insert atf;

    Test.startTest();
    zqu__QuoteRatePlanCharge__c qrpc = TestObjectCreator.CreateRatePlanCharge(
      zqrp
    );
    insert qrpc;
    ZquoteHandler.GetData(new List<zqu__Quote__c>{ q }, 'insert');
    ZQuoteHandler.GetQuoteTemplateId(q);
    list<zqu__Quote__c> zqlist = new List<zqu__Quote__c>{ q };
    ZQuoteHandler.HandleBefore(
      zqlist,
      new Map<Id, zqu__Quote__c>(zqlist),
      'Insert'
    );
    ZQuoteHandler.BuildQuoteChargeMap(new List<Id>{ q.id });
    ZQuoteHandler.ValidateQuotes4ZBilling(
      new List<zqu__Quote__c>{ q },
      'Button'
    );
    Test.stopTest();
  }
}

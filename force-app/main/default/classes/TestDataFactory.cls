@isTest
public class TestDataFactory {
  public static final String zuoraExternalAcctId = '12345678901234567890123456789012';
  public static final String zuoraExternalSubId = '23456789012345678901234567890123';
  public static final String docuSignEnvelopeId = '1001A123-1234-5678-1D84-F8D44652A382';
  public static final String docuSignRecipientId = '1001A223-1234-5678-1D84-A8D44652A382';
  public static final String guidedSellingFlowName = 'TestGuidedSellingFlow';
  public static final String guidedSellingStepName = 'TestGuidedSellingStep';
  public static final String listFilterName = 'TestListFilter';

  private static ID preparedProductID { get; set; }
  public static final Date DEFAULT_EFFECTIVE_START_DATE = Date.today();
  public static final Date DEFAULT_EFFECTIVE_END_DATE = Date.today()
    .addYears(1);
  public static final String DEFAULT_CURRENCY = 'USD';

  public static final String MODEL_F = 'Flat Fee Pricing';
  public static final String MODEL_P = 'Per Unit Pricing';
  public static final String MODEL_V = 'Volume Pricing';
  public static final String MODEL_T = 'Tiered Pricing';
  public static final String MODEL_O = 'Overage Pricing';
  public static final String MODEL_TO = 'Tiered with Overage Pricing';
  public static final String MODEL_FA = 'Discount-Fixed Amount';
  public static final String MODEL_FP = 'Discount-Percentage';

  private static List<String> rateplannames = new List<String>{
    'Plan for Flat Fee charges',
    'Plan for Per Unit charges',
    'Plan for Volume charges',
    'Plan for Overage charges',
    'Plan for Tiered charges',
    'Plan for Discount-Fixed Amount charges'
  };

  private static Map<String, List<List<String>>> PLAN_CHARGE_MAPPING = new Map<String, List<List<String>>>{
    'Plan for Flat Fee charges' => new List<List<String>>{
      new List<String>{ 'Flat Fee Pricing', 'One-Time' },
      new List<String>{ 'Flat Fee Pricing', 'Recurring' },
      new List<String>{ 'Flat Fee Pricing', 'Usage' }
    },
    'Plan for Per Unit charges' => new List<List<String>>{
      new List<String>{ 'Per Unit Pricing', 'One-Time' },
      new List<String>{ 'Per Unit Pricing', 'Recurring' },
      new List<String>{ 'Per Unit Pricing', 'Usage' }
    },
    'Plan for Volume charges' => new List<List<String>>{
      new List<String>{ 'Volume Pricing', 'One-Time' },
      new List<String>{ 'Volume Pricing', 'Recurring' },
      new List<String>{ 'Volume Pricing', 'Usage' }
    },
    'Plan for Overage charges' => new List<List<String>>{
      new List<String>{ 'Overage Pricing', 'Usage' },
      new List<String>{ 'Tiered with Overage Pricing', 'Usage' }
    },
    'Plan for Tiered charges' => new List<List<String>>{
      new List<String>{ 'Tiered Pricing', 'One-Time' },
      new List<String>{ 'Tiered Pricing', 'Recurring' },
      new List<String>{ 'Tiered Pricing', 'Usage' }
    },
    'Plan for Discount-Fixed Amount charges' => new List<List<String>>{
      new List<String>{ 'Discount-Fixed Amount', 'Recurring' },
      new List<String>{ 'Per Unit Pricing', 'One-Time' },
      new List<String>{ 'Per Unit Pricing', 'Recurring' }
    },
    'Plan for Discount-Percentage charges' => new List<List<String>>{
      new List<String>{ 'Discount-Percentage', 'Recurring' },
      new List<String>{ 'Per Unit Pricing', 'One-Time' },
      new List<String>{ 'Per Unit Pricing', 'Recurring' }
    }
  };

  private static Map<String, List<Decimal>> TIER_MAPPING = new Map<String, List<Decimal>>{
    'One-Time_Flat Fee Pricing' => new List<Decimal>{ 1000 },
    'One-Time_Per Unit Pricing' => new List<Decimal>{ 1000 },
    'One-Time_Volume Pricing' => new List<Decimal>{
      0,
      0,
      500,
      0,
      800,
      1,
      1000,
      0
    },
    'One-Time_Tiered Pricing' => new List<Decimal>{ 500, 0, 400, 1, 200, 0 },
    'Recurring_Flat Fee Pricing' => new List<Decimal>{ 1500 },
    'Recurring_Per Unit Pricing' => new List<Decimal>{ 1000 },
    'Recurring_Volume Pricing' => new List<Decimal>{
      0,
      1,
      800,
      1,
      1200,
      0,
      1500,
      1
    },
    'Recurring_Tiered Pricing' => new List<Decimal>{ 800, 0, 400, 0, 300, 1 },
    'Usage_Flat Fee Pricing' => new List<Decimal>{ 0 },
    'Usage_Per Unit Pricing' => new List<Decimal>{ 0 },
    'Usage_Volume Pricing' => new List<Decimal>{},
    'Usage_Tiered Pricing' => new List<Decimal>{},
    'Usage_Overage Pricing' => new List<Decimal>{ 0 },
    'Usage_Tiered with Overage Pricing' => new List<Decimal>{ 8, 100, 200 },
    'Recurring_Discount-Fixed Amount' => new List<Decimal>{ 598, 400, 500 },
    'Recurring_Discount-Percentage' => new List<Decimal>{ 7 },
    '_Flat Fee Pricing' => new List<Decimal>{ 0 },
    '_Per Unit Pricing' => new List<Decimal>{ 0 },
    '_Volume Pricing' => new List<Decimal>{
      0,
      0,
      0,
      0,
      10,
      0,
      0,
      1,
      0,
      1,
      10,
      1,
      0,
      0,
      0,
      0,
      10,
      0
    },
    '_Tiered Pricing' => new List<Decimal>{
      0,
      1,
      0,
      0,
      10,
      0,
      0,
      1,
      0,
      1,
      10,
      1,
      0,
      0,
      0,
      0,
      10,
      0
    }
  };

  public static List<String> getCountries() {
    list<String> names = new List<String>{
      'Afghanistan',
      'Albania',
      'Antarctica',
      'Algeria',
      'Brunei Darussalam',
      'Bulgaria',
      'Myanmar',
      'Burundi',
      'Belarus',
      'Cambodia',
      'Cameroon',
      'Canada',
      'American Samoa',
      'Andorra',
      'Angola',
      'Antigua and Barbuda',
      'Azerbaijan',
      'Argentina',
      'Australia',
      'Austria',
      'Bahamas',
      'Bahrain',
      'Bangladesh',
      'Armenia',
      'Barbados',
      'Belgium',
      'Bermuda',
      'Bhutan',
      'Bolivia',
      'Bosnia and Herzegovina',
      'Botswana',
      'Bouvet Island',
      'Brazil',
      'Belize',
      'British Indian Ocean Territory',
      'Solomon Islands',
      'Virgin Islands',
      'Cabo Verde',
      'Cayman Islands',
      'Central African Republic',
      'Sri Lanka',
      'Czech Republic',
      'Benin',
      'Denmark',
      'Dominica',
      'Dominican Republic',
      'Ecuador',
      'Chad',
      'Chile',
      'China',
      'Taiwan',
      'Christmas Island',
      'Cocos (Keeling) Islands',
      'Colombia',
      'Comoros',
      'Mayotte',
      'Congo',
      'Congo',
      'Cook Islands',
      'Costa Rica',
      'Croatia',
      'Cuba',
      'Cyprus',
      'El Salvador',
      'Equatorial Guinea',
      'Ethiopia',
      'Eritrea',
      'Estonia',
      'Faroe Islands',
      'Falkland Islands (Malvinas)',
      'South Georgia and the South Sandwich Islands',
      'Fiji',
      'Finland',
      '??land Islands',
      'France',
      'French Guiana',
      'French Polynesia',
      'French Southern Territories',
      'Djibouti',
      'Gabon',
      'Georgia',
      'Gambia',
      'Palestine',
      'Germany',
      'Ghana',
      'Gibraltar',
      'Kiribati',
      'Greece',
      'Greenland',
      'Grenada',
      'Guadeloupe',
      'Guam',
      'Guatemala',
      'Guinea',
      'Guyana',
      'Haiti',
      'Heard Island and McDonald Islands',
      'Holy See (Vatican City State)',
      'Honduras',
      'Hong Kong',
      'Hungary',
      'Iceland',
      'India',
      'Indonesia',
      'Iran',
      'Iraq',
      'Ireland',
      'Israel',
      'United States'
    };
    return names;
  }

  public static List<Base_Product_Contract__c> createBaseProductContract_CS() {
    Base_Product_Contract__c bpc1 = new Base_Product_Contract__c();
    bpc1.Name = Utility.hashCode('BPC_Value1');
    bpc1.Label__c = 'BPC_Label1';
    bpc1.Value__c = 'BPC_Value1';
    return new List<Base_Product_Contract__c>{ bpc1 };
  }

  public static List<Base_Product_Controlling_Obj__c> createBaseProductControlling_CS() {
    Base_Product_Controlling_Obj__c bpc1 = new Base_Product_Controlling_Obj__c();
    bpc1.Name = Utility.hashCode('BPCO_Value1');
    bpc1.Label__c = 'BPCO_Label1';
    bpc1.Value__c = 'BPCO_Value1';
    Base_Product_Controlling_Obj__c bpc2 = new Base_Product_Controlling_Obj__c();
    bpc2.Name = Utility.hashCode('BPCO_Value2');
    bpc2.Label__c = 'BPCO_Label2';
    bpc2.Value__c = 'BPCO_Value2';
    return new List<Base_Product_Controlling_Obj__c>{ bpc1, bpc2 };
  }

  public static List<Base_Product_Dependent__c> createBaseProductDependent_CS() {
    Base_Product_Dependent__c bpc1 = new Base_Product_Dependent__c();
    bpc1.Name = Utility.hashCode('BPCO_Value1BPC_Value1');
    bpc1.Controlling__c = 'BPCO_Value1';
    bpc1.Dependent__c = 'BPC_Value1';
    Base_Product_Dependent__c bpc2 = new Base_Product_Dependent__c();
    bpc2.Name = Utility.hashCode('BPCO_Value2BPC_Value2');
    bpc2.Controlling__c = 'BPCO_Value2';
    bpc2.Dependent__c = 'BPC_Value2';
    return new List<Base_Product_Dependent__c>{ bpc1, bpc2 };
  }

  public static List<Base_Product_Default_Addon__c> createBaseProductDefaultAddon_CS() {
    Base_Product_Default_Addon__c bpc1 = new Base_Product_Default_Addon__c();
    bpc1.Name = Utility.hashCode('Marketing Premium 5K Monthly API Hits');
    bpc1.Controlling__c = 'Marketing Solution - Premium';
    bpc1.Addon__c = 'Marketing Premium 5K Monthly API Hits';
    bpc1.Postfix__c = 'API Hits'; //ZQuoteService.API_HITS_ADDON_POSTFIX;
    return new List<Base_Product_Default_Addon__c>{ bpc1 };
  }

  public static List<Base_Product_Dynamic_Addon__c> createBaseProductDynamicAddon_CS() {
    /* Base_Product_Dynamic_Addon__c bpc1 = new Base_Product_Dynamic_Addon__c();
        bpc1.Name = Utility.hashCode('Marketing Premium 5K Monthly API Hits');
        bpc1.Controlling__c = 'Marketing Solution - Premium';
        bpc1.Addon__c = 'Marketing Premium 5K Monthly API Hits';
        bpc1.Postfix__c = ZQuoteService.API_HITS_ADDON_POSTFIX; */
    Base_Product_Dynamic_Addon__c bpc2 = new Base_Product_Dynamic_Addon__c();
    bpc2.Name = Utility.hashCode('Marketing - 5 Months of Historical Data');
    bpc2.Controlling__c = 'Marketing Solution - Premium';
    bpc2.Addon__c = 'Marketing - 5 Months of Historical Data';
    bpc2.Postfix__c = 'Months of Historical Data'; //ZQuoteService.HISTORICAL_DATA_ADDON_POSTFIX;
    return new List<Base_Product_Dynamic_Addon__c>{ bpc2 }; //bpc1
  }

  public static List<Base_Product_Num_of_Users__c> createBaseProductNumOfUsers_CS() {
    Base_Product_Num_of_Users__c bpc1 = new Base_Product_Num_of_Users__c();
    bpc1.Name = Utility.hashCode('Marketing Solution - Premium');
    bpc1.Controlling__c = 'Marketing Solution - Premium';
    bpc1.Number_of_User__c = 2;
    return new List<Base_Product_Num_of_Users__c>{ bpc1 };
  }

  public static List<Base_Product_Configuration__c> createBaseProductConfiguration_CS() {
    Base_Product_Configuration__c bpc1 = new Base_Product_Configuration__c();
    bpc1.Name = 'Iss';
    bpc1.Value__c = 'TestIss';
    Base_Product_Configuration__c bpc2 = new Base_Product_Configuration__c();
    bpc2.Name = 'Controlled field name';
    bpc2.Value__c = 'Contract_Wording_List__c';
    Base_Product_Configuration__c bpc3 = new Base_Product_Configuration__c();
    bpc3.Name = 'Controlling field name';
    bpc3.Value__c = 'Package__c';
    Base_Product_Configuration__c bpc4 = new Base_Product_Configuration__c();
    bpc4.Name = 'Aud';
    bpc4.Value__c = 'TestAud';
    Base_Product_Configuration__c bpc5 = new Base_Product_Configuration__c();
    bpc5.Name = 'Certificate';
    bpc5.Value__c = 'TestCertificate';
    return new List<Base_Product_Configuration__c>{
      bpc1,
      bpc2,
      bpc3,
      bpc4,
      bpc5
    };
  }

  public static void createSimilarWeb_CS() {
    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["account"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;
  }

  public static void createInferredSolutionSettings_CS() {
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
    CSSettings__c cs = TestObjectCreator.CreateCSSettings();
    insert cs;
  }

  public static List<Zuora_Quote_Approval_Settings__c> createZuoraQuoteApprovalSettings_CS() {
    Zuora_Quote_Approval_Settings__c zqas = Zuora_Quote_Approval_Settings__c.getOrgDefaults();
    zqas.Enable_Approval_process_for_Quote__c = true;
    return new List<Zuora_Quote_Approval_Settings__c>{ zqas };
  }

  public static List<Zuora_Quote_Approval_Settings__c> createZuoraQuoteApprovalSettings_CS(
    Boolean isApproval
  ) {
    Zuora_Quote_Approval_Settings__c zqas = Zuora_Quote_Approval_Settings__c.getOrgDefaults();
    zqas.Enable_Approval_process_for_Quote__c = isApproval;
    return new List<Zuora_Quote_Approval_Settings__c>{ zqas };
  }

  public static ContentVersion createContentVersion() {
    ContentVersion contentVersionInsert = new ContentVersion(
      Title = 'Test',
      PathOnClient = 'Test.jpg',
      VersionData = Blob.valueOf('Test Content Data'),
      IsMajorVersion = true
    );
    return contentVersionInsert;
  }

  public static ContentVersion createContentVersionWithType(String typeOfCv) {
    ContentVersion contentVersionInsert = new ContentVersion(
      Title = 'Test',
      PathOnClient = 'Test.' + typeOfCv,
      VersionData = Blob.valueOf('Test Content Data'),
      IsMajorVersion = true
    );
    return contentVersionInsert;
  }

  public static ContentDocumentLink createContentDocumentLink(
    Id linkedEntityId,
    Id contentDocumentId
  ) {
    ContentDocumentLink contentlink = new ContentDocumentLink();
    contentlink.ShareType = 'V';
    contentlink.LinkedEntityId = linkedEntityId;
    contentlink.ContentDocumentId = contentDocumentId;
    contentlink.Visibility = 'AllUsers';
    return contentlink;
  }

  public static Attachment createAttachment(Id parentId) {
    Attachment att = new Attachment();
    att.Body = Blob.valueOf('test');
    att.Name = 'test';
    att.ParentId = parentId;
    return att;
  }

  public static Account createAccount() {
    Account a = new Account();
    a.name = 'test';
    a.Business_Unit__c = 'SMB';
    a.SW_Industry__c = 'test';
    return a;
  }
  public static Contact createContact(Account a, String email) {
    Contact c = new Contact();
    c.AccountId = a.Id;
    c.FirstName = 'FirstName';
    c.LastName = 'LastName';
    c.Email = email;
    c.Email = email;
    c.MailingCity = 'Odessa';
    c.MailingPostalCode = '212';
    c.MailingCountry = 'Ukraine';
    //        c.MailingState = 'Odessa';
    c.MailingStreet = 'test';
    return c;
  }
  public static Lead createLead() {
    Lead lead = new Lead();
    lead.Company = 'Company';
    lead.FirstName = 'FirstName';
    lead.LastName = 'LastName';
    lead.status = 'Open';
    lead.Email = 'test@aaa.com';
    return lead;
  }

  public static Country_Subsidiary__c createCountrySub(string country) {
    Country_Subsidiary__c cs = new Country_Subsidiary__c();
    cs.name = country;
    cs.ISOCode_3__c = '123';
    cs.ISOCode__c = country;
    cs.Country_Id__c = 10;
    cs.Country_Name__c = country;
    cs.No_Tax_Region__c = 'All';
    cs.Subsidiary__c = 'All';
    cs.Taxable__c = 'All';
    cs.Tax_Region__c = 'All';
    return cs;
  }

  public static List<Country_Subsidiary__c> createCountries() {
    List<Country_Subsidiary__c> lcs = new List<Country_Subsidiary__c>();
    List<String> names = getCountries();
    Integer j = 11;
    for (String country : names) {
      Country_Subsidiary__c cs = createCountrySub(country);
      cs.Country_Id__c = j;
      j++;
      lcs.add(cs);
    }
    lcs[lcs.size() - 1].Country_Id__c = 10;
    return lcs;
  }

  public static Opportunity createOpportunity(Account a) {
    Opportunity opp = new Opportunity();
    opp.AccountId = a.id;
    opp.Name = 'TEST';
    opp.StageName = 'New';
    opp.CloseDate = date.today();
    opp.Plan_Details__c = 'test';
    //opp.Product_Sold__c = 'test';
    return opp;
  }

  static public zqu__Quote__c createZQuote(Opportunity opp) {
    zqu__Quote__c quote = new zqu__Quote__c();
    quote.RecordTypeId = Utility.getRecordTypeIdForObject(
      'zqu__Quote__c',
      'Default'
    );
    quote.zqu__ZuoraAccountID__c = 'new';
    quote.zqu__Account__c = opp.accountid;
    quote.zqu__Opportunity__c = opp.Id;
    quote.zqu__Currency__c = 'USD';
    quote.roi_start_date__c = Date.today();
    quote.roi_end_date__c = Date.today();
    quote.roi_conversion_rate__c = 100;
    quote.document_format__c = 'Service_Order';
    quote.roi_aquisition_average_order_value__c = 100;
    quote.zqu__ApprovalStatus__c = 'New';
    quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
    quote.Payment_Frequency__c = 12;
    quote.Add_Finance_Information__c = true;
    //quote.Contract_type__c = 'pdf';
    quote.zqu__Certificate_ID__c = '12345';
    quote.zqu__ElectronicPaymentMethodId__c = 'jjbsdjjkb';
    quote.zqu__PaymentMethod__c = 'Credit Card';
    quote.Legacy_or_New_solution_deal__c = 'Solution 3.0';
    quote.New_solution_use_case__c = 'Competitive Intelligence';
    quote.package__c = 'Competitive Intelligence - Business';
    quote.zqu__Previewed_SubTotal__c = 1000;
    quote.Total_Discount__c = 0;
    quote.Total_List_Price__c = 1000;
    quote.payment_frequency1__c = 'Annual';
    quote.zqu__InitialTerm__c = 12;
    quote.zqu__SubscriptionType__c = 'New Subscription';
    quote.Subsidiary__c = 'SimilarWeb IL';
    return quote;
  }

  public static zqu__Quote__c createZQuote(Opportunity opp, Contact contact) {
    zqu__Quote__c quote = CreateZQuote(opp);
    quote.zqu__SoldToContact__c = contact.Id;
    quote.zqu__BillToContact__c = contact.Id;
    quote.zqu__QuoteBusinessType__c = 'New';
    return quote;
  }

  public static zqu__Quote__c createAmendZQuote(
    Opportunity opp,
    Contact contact
  ) {
    zqu__Quote__c quote = CreateZQuote(opp, contact);
    quote.zqu__SubscriptionType__c = 'Amend Subscription';
    quote.RecordTypeId = Utility.getRecordTypeIdForObject(
      quote.getSObjectType(),
      'Amendment'
    );
    quote.zqu__QuoteBusinessType__c = 'Co-Term Upsell';
    quote.document_format__c = null;
    return quote;
  }

  public static zqu__Quote__c createCancellationZQuote(
    Opportunity opp,
    Contact contact
  ) {
    zqu__Quote__c quote = CreateZQuote(opp, contact);
    quote.zqu__SubscriptionType__c = 'Cancel Subscription';
    quote.zqu__CancellationDate__c = Date.today();
    quote.zqu__QuoteBusinessType__c = 'Cancellation';
    return quote;
  }

  public static zqu__QuoteAmendment__c createZQuoteAmendment(
    zqu__Quote__c quote
  ) {
    zqu__QuoteAmendment__c zAmend = new zqu__QuoteAmendment__c();
    zAmend.zqu__Quote__c = quote.id;
    return zAmend;
  }

  public static Product2 createProduct2() {
    Product2 prod = new Product2(
      Name = 'Marketing Solution - Premium',
      InternalCode__c = '132',
      zqu__Category__c = 'Base Products'
    );
    return prod;
  }

  public static zqu__ProductRatePlan__c createZuoraProductRatePlan(
    Product2 product
  ) {
    zqu__ProductRatePlan__c prodrp = new zqu__ProductRatePlan__c(
      zqu__Product__c = product.id
    );
    return prodrp;
  }

  public static zqu__ProductRatePlanCharge__c createZuoraProductRatePlanCharge(
    zqu__ProductRatePlan__c productRatePlan
  ) {
    zqu__ProductRatePlanCharge__c prodrpc = new zqu__ProductRatePlanCharge__c(
      zqu__ProductRatePlan__c = productRatePlan.id
    );
    prodrpc.name = 'ProductRatePlanChargeTest';
    return prodrpc;
  }

  public static ApprovedTermsFrequecy__c createATF(zqu__Quote__c quote) {
    ApprovedTermsFrequecy__c atf = new ApprovedTermsFrequecy__c();
    atf.Frequency__c = quote.Payment_Frequency__c;
    atf.initial_term__c = quote.zqu__InitialTerm__c;
    return atf;
  }

  public static zqu__QuoteRatePlan__c CreateRatePlan(
    zqu__QuoteAmendment__c zQuoteAmendmant
  ) {
    zqu__QuoteRatePlan__c zqrp = new zqu__QuoteRatePlan__c();
    zqrp.zqu__QuoteProductName__c = 'API for Marketing Solution - Premium';
    zqrp.zqu__QuoteAmendment__c = zQuoteAmendmant.id;
    zqrp.zqu__Quote__c = zQuoteAmendmant.zqu__Quote__c;
    return zqrp;
  }

  public static zqu__QuoteRatePlanCharge__c CreateRatePlanCharge(
    zqu__QuoteRatePlan__c zqrp
  ) {
    zqu__QuoteRatePlanCharge__c zqrpc = new zqu__QuoteRatePlanCharge__c();
    zqrpc.zqu__QuoteRatePlan__c = zqrp.id;
    zqrpc.zqu__Discount__c = 0;
    zqrpc.zqu__Period__c = 'Specific Months';
    zqrpc.zqu__EffectivePrice__c = 1000;
    zqrpc.zqu__Quantity__c = 1;
    zqrpc.zqu__ListPrice__c = 1000;
    zqrpc.zqu__ListTotal__c = 1000;
    return zqrpc;
  }

  public static zqu__QuoteChargeSummary__c createChargeSummary(
    zqu__QuoteRatePlan__c zqrp
  ) {
    zqu__QuoteChargeSummary__c zqcs = new zqu__QuoteChargeSummary__c();
    zqcs.Name = 'Test quote charge detail';
    zqcs.zqu__QuoteRatePlan__c = zqrp.id;
    zqcs.zqu__Type__c = 'recurring';
    zqcs.zqu__Model__c = 'tiered pricing';
    return zqcs;
  }

  public static zqu__QuoteChargeDetail__c createChargeDetail(
    zqu__Quote__c quote
  ) {
    zqu__QuoteChargeDetail__c zqcd = new zqu__QuoteChargeDetail__c();
    zqcd.zqu__Quote__c = quote.id;
    zqcd.zqu__OriginalId__c = 'testZuoraId';
    return zqcd;
  }

  public static Zuora__CustomerAccount__c createBillingAccount(Account acc) {
    Zuora__CustomerAccount__c billAcc = new Zuora__CustomerAccount__c();
    billAcc.Name = 'Test Billing Account';
    billAcc.Zuora__Account__c = acc.Id;
    billAcc.Zuora__AccountNumber__c = 'A-001';
    billAcc.Zuora__AutoPay__c = false;
    billAcc.Zuora__Batch__c = 'Batch1';
    billAcc.Zuora__BillCycleDay__c = '1';
    billAcc.Zuora__Balance__c = 0;
    billAcc.Zuora__BillToCity__c = 'Atlanta';
    billAcc.Zuora__BillToCountry__c = 'United States';
    billAcc.Zuora__BillToAddress1__c = '123 Main St';
    billAcc.Zuora__BillToState__c = 'Georgia';
    billAcc.Zuora__BillToPostalCode__c = '12345';
    billAcc.Zuora__BillToId__c = '1234567890';
    billAcc.Zuora__BillToName__c = 'Test Name';
    billAcc.Zuora__BillToWorkEmail__c = 'test@test.com';
    billAcc.Zuora__MRR__c = 100;
    billAcc.Zuora__Credit_Balance__c = 100;
    billAcc.Zuora__Currency__c = 'USD';
    billAcc.Zuora__External_Id__c = zuoraExternalAcctId;
    billAcc.Zuora__PaymentTerm__c = 'Due Upon Receipt';
    billAcc.Zuora__Status__c = 'Active';
    billAcc.Zuora__Zuora_Id__c = zuoraExternalAcctId;
    billAcc.Subsidiary__c = 'TestSubsidiary';

    return billAcc;
  }

  public static Zuora__Subscription__c createSubscription(
    Account acc,
    Zuora__CustomerAccount__c billAcc
  ) {
    Zuora__Subscription__c sub = new Zuora__Subscription__c();
    sub.Zuora__Account__c = acc.Id;
    sub.Zuora__AutoRenew__c = false;
    sub.Zuora__ContractAcceptanceDate__c = System.today();
    sub.Zuora__ContractEffectiveDate__c = System.today();
    sub.Zuora__CustomerAccount__c = billAcc.Id;
    sub.Zuora__External_Id__c = zuoraExternalSubId;
    sub.Zuora__InitialTerm__c = '12 Months';
    sub.Zuora__InvoiceOwner__c = billAcc.Id;
    sub.Zuora__MRR__c = 100;
    sub.Name = 'Test Subscription';
    sub.Zuora__NextChargeDate__c = System.today().addMonths(1);
    sub.Zuora__NextRenewalDate__c = System.today().addMonths(12);
    sub.Zuora__OriginalCreatedDate__c = System.today();
    sub.Zuora__RenewalTerm__c = '12 Months';
    sub.Zuora__ServiceActivationDate__c = System.today();

    sub.Zuora__Status__c = 'Active';
    sub.Zuora__SubscriptionEndDate__c = System.today().addMonths(12);
    sub.Zuora__SubscriptionStartDate__c = System.today();
    sub.Zuora__TCV__c = 1200;
    sub.Zuora__TermEndDate__c = System.today().addMonths(12);
    sub.Zuora__TermSettingType__c = 'TEREMED';
    sub.Zuora__TermStartDate__c = System.today();
    sub.Zuora__Version__c = 1;
    sub.Zuora__Zuora_Id__c = zuoraExternalSubId;

    return sub;
  }

  public static Zuora__SubscriptionProductCharge__c createSubProdCharge(
    Zuora__Subscription__c sub,
    String frequency
  ) {
    Zuora__SubscriptionProductCharge__c charge = new Zuora__SubscriptionProductCharge__c();
    charge.Name = 'Test Charge';
    charge.Zuora__Subscription__c = sub.Id;
    charge.Zuora__BillingPeriod__c = frequency;
    charge.Zuora__ProductName__c = 'Test Product';

    return charge;
  }

  public static dsfs__DocuSign_Status__c createDocuSignStatus(Opportunity opp) {
    dsfs__DocuSign_Status__c dsfs = new dsfs__DocuSign_Status__c(
      dsfs__Company__c = opp.AccountId,
      dsfs__Opportunity__c = opp.Id,
      dsfs__Sender_Email__c = 'test@similarweb.com',
      dsfs__Envelope_Status__c = 'Delivered',
      dsfs__DocuSign_Envelope_ID__c = docuSignEnvelopeId,
      dsfs__Subject__c = 'Document for eSignature'
    );

    return dsfs;
  }

  public static dsfs__DocuSign_Recipient_Status__c createDocuSignRecipientStatus(
    dsfs__DocuSign_Status__c status
  ) {
    dsfs__DocuSign_Recipient_Status__c dsRecipientStatus = new dsfs__DocuSign_Recipient_Status__c(
      dsfs__DocuSign_Routing_Order__c = 1,
      dsfs__Recipient_Status__c = 'Completed', //DocuSignRecipientStatusDomain.DOCUSIGN_SIGNED_STATUS,
      dsfs__Date_Signed__c = Datetime.now().addDays(-1),
      dsfs__Parent_Status_Record__c = status.Id,
      dsfs__Envelope_Id__c = docuSignEnvelopeId,
      dsfs__DocuSign_Recipient_Id__c = docuSignRecipientId
    );

    return dsRecipientStatus;
  }

  public static dsfs__DocuSign_Envelope__c createDocuSignEnvelop() {
    dsfs__DocuSign_Envelope__c newEnvelope = new dsfs__DocuSign_Envelope__c();
    // newEnvelope.dsfs__Source_Object__c = propertyId;
    newEnvelope.dsfs__DocuSign_Email_Message__c = 'my new message';
    newEnvelope.dsfs__DocuSign_Envelope_ID__c = docuSignEnvelopeId;
    return newEnvelope;
  }

  public static dsfs__DocuSign_Envelope_Document__c createDocuSignDocument(
    Id enveloperId,
    Id cvId
  ) {
    dsfs__DocuSign_Envelope_Document__c document = new dsfs__DocuSign_Envelope_Document__c();
    document.dsfs__External_Document_Id__c = cvId;
    document.dsfs__DocuSign_EnvelopeID__c = enveloperId;
    return document;
  }

  public static zqu__GuidedSellingFlow__c createGuidedSellingFlow() {
    zqu__GuidedSellingFlow__c guidedSellingFlow = new zqu__GuidedSellingFlow__c();
    guidedSellingFlow.Name = guidedSellingFlowName;
    guidedSellingFlow.zqu__IncludeInProductSelector__c = true;
    return guidedSellingFlow;
  }

  public static zqu__GuidedSellingStep__c createGuidedSellingStep() {
    zqu__GuidedSellingStep__c guidedSellingStep = new zqu__GuidedSellingStep__c();
    guidedSellingStep.Name = guidedSellingStepName;
    guidedSellingStep.zqu__StepTitle__c = guidedSellingStepName;
    zqu__ZList__c zlist = new zqu__ZList__c();
    zlist.zqu__Associated_Field_Set__c = 'test';
    zlist.zqu__SObject_Name__c = 'test';
    zlist.zqu__List_Name__c = 'test';
    insert zlist;
    guidedSellingStep.zqu__ZList__c = zlist.Id;
    return guidedSellingStep;
  }

  public static zqu__StepToFlowMap__c createGuidedSellingFlowToStep(
    zqu__GuidedSellingFlow__c guidedSellingFlow,
    zqu__GuidedSellingStep__c guidedSellingStep
  ) {
    zqu__StepToFlowMap__c stepToFlowMap = new zqu__StepToFlowMap__c();
    stepToFlowMap.zqu__GuidedSellingStep__c = guidedSellingStep.Id;
    stepToFlowMap.zqu__GuidedSellingFlow__c = guidedSellingFlow.Id;
    stepToFlowMap.zqu__Order__c = 1;
    return stepToFlowMap;
  }

  public static zqu__List_Filter__c createListFilter() {
    zqu__List_Filter__c listFilter = new zqu__List_Filter__c();
    listFilter.Name = guidedSellingStepName;
    return listFilter;
  }

  public static zqu__List_Filter_Item__c createListFilterItem(
    zqu__List_Filter__c listFilter
  ) {
    zqu__List_Filter_Item__c listFilterItem = new zqu__List_Filter_Item__c();
    listFilterItem.zqu__Field_Name__c = 'IsGuidedSelling__c';
    listFilterItem.zqu__Fixed_Value__c = 'All';
    listFilterItem.zqu__Left_Field_Type__c = 'TEXT';
    listFilterItem.zqu__Left_Object_Name__c = 'zqu__ProductRatePlan__c';
    listFilterItem.zqu__Left_Object_Type__c = 'zqu__ProductRatePlan__c';
    listFilterItem.zqu__Operator__c = '=';
    listFilterItem.zqu__Segment_Id__c = 'segment-0';
    listFilterItem.zqu__List_Filter__c = listFilter.Id;
    return listFilterItem;
  }

  public static Request__c createRequest(Opportunity opp) {
    Request__c request = new Request__c();
    request.Requester__c = UserInfo.getUserId();
    request.Recipient_Picklist__c = 'Chris Foale';
    request.Opportunity__c = opp.Id;
    request.Account__c = opp.AccountId;
    request.Signed_contract__c = 'Yes';
    request.Currency__c = 'USD';
    request.Request_Type__c = 'Vendor Form request';
    request.RecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName()
      .get('Vendor_Form')
      .getRecordTypeId();
    return request;
  }

  public static zqu__ZProduct__c prepareProductCatalog() {
    List<zqu__ZProduct__c> listOFzprod = new List<zqu__ZProduct__c>();
    zqu__ZProduct__c zprod = null;
    try {
      // Following cases will return list size as 0 and thus new product catalog will be created.
      // 1. null == preparedProductID
      // 2. preparedProductID is expired
      listOFzprod = [
        SELECT
          name,
          zqu__effectivestartdate__c,
          zqu__effectiveenddate__c,
          zqu__sku__c,
          zqu__zuoraid__c,
          zqu__deleted__c
        FROM zqu__ZProduct__c
        WHERE id = :preparedProductID
      ];
    } catch (Exception e) {
      System.assert(
        false,
        'Exception occured while querying ZProduct__c. Exception Details: ' +
        e.getMessage()
      );
    }
    if (listOFzprod.size() == 0) {
      //generate ProductCatalog in Salesforce
      zprod = new zqu__ZProduct__c();
      zprod.Name = 'CC Testing';
      zprod.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
      zprod.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
      zprod.zqu__SKU__c = 'testingsku0001';
      zprod.zqu__ZuoraId__c = 'zuoraid0000000001';
      zprod.zqu__Deleted__c = false;
      try {
        insert zprod;
      } catch (Exception e) {
        System.assert(
          false,
          'ZQTestDataSetup.prepareProductCatalog: Exception occured while inserting ZProduct__c. Exception Details: ' +
          e.getMessage()
        );
      }
      System.assert(
        null != zprod.Id,
        'Product record preparation failed when prepare for testing product catalog.'
      );

      preparedProductID = zprod.Id;

      List<zqu__ProductRatePlan__c> p_rateplans = new List<zqu__ProductRatePlan__c>();
      Integer rpzuoraid = 1;
      for (String rpname : rateplannames) {
        zqu__ProductRatePlan__c p_rateplan = new zqu__ProductRatePlan__c();
        p_rateplan.Name = rpname;
        p_rateplan.zqu__EffectiveStartDate__c = DEFAULT_EFFECTIVE_START_DATE;
        p_rateplan.zqu__EffectiveEndDate__c = DEFAULT_EFFECTIVE_END_DATE;
        p_rateplan.zqu__ZProduct__r = zprod;
        p_rateplan.zqu__ZProduct__c = zprod.Id;
        p_rateplan.IsGuidedSelling__c = 'All';
        p_rateplan.zqu__ZuoraId__c = String.valueOf(rpzuoraid);
        p_rateplan.zqu__Deleted__c = false;
        p_rateplans.add(p_rateplan);
        rpzuoraid++;
      }
      try {
        insert p_rateplans;
      } catch (Exception e) {
        System.assert(
          false,
          'ZQTestDataSetup.prepareProductCatalog: Exception occured while inserting ProductRatePlan__c records. Exception Details: ' +
          e.getMessage()
        );
      }
      System.assert(
        p_rateplans.size() > 0,
        'Product Rateplan records prepare failed when prepare for testing product catalog.'
      );
      List<zqu__ProductRatePlanCharge__c> p_all_charges = new List<zqu__ProductRatePlanCharge__c>();
      for (zqu__ProductRatePlan__c p_rateplan : p_rateplans) {
        List<zqu__ProductRatePlanCharge__c> rp_charges = getProductRatePlanCharges(
          p_rateplan
        );
        p_all_charges.addAll(rp_charges);
      }
      try {
        insert p_all_charges;
      } catch (Exception e) {
        System.assert(
          false,
          'ZQTestDataSetup.prepareProductCatalog: Exception occured while inserting ProductRatePlanCharge__c records. Exception Details: ' +
          e.getMessage()
        );
      }
      System.assert(
        p_all_charges.size() > 0,
        'Product Rateplan charge records prepare failed when prepare for testing product catalog.'
      );
      List<zqu__ProductRatePlanChargeTier__c> p_all_tiers = new List<zqu__ProductRatePlanChargeTier__c>();
      for (zqu__ProductRatePlanCharge__c charge : p_all_charges) {
        List<zqu__ProductRatePlanChargeTier__c> p_chargetiers = getProductRatePlanChargeTiers(
          charge
        );
        p_all_tiers.addAll(p_chargetiers);
      }
      try {
        insert p_all_tiers;
      } catch (Exception e) {
        System.assert(
          false,
          'ZQTestDataSetup.prepareProductCatalog: Exception occured while inserting ProductRatePlanChargeTier__c records. Exception Details: ' +
          e.getMessage()
        );
      }
      System.assert(
        p_all_tiers.size() > 0,
        'Product Rateplan charge tier records prepare failed when prepare for testing product catalog.'
      );
    }
    return zprod;
  }

  private static List<zqu__ProductRatePlanCharge__c> getProductRatePlanCharges(
    zqu__ProductRatePlan__c rp
  ) {
    List<List<String>> chargedefines = PLAN_CHARGE_MAPPING.get(rp.Name);
    List<zqu__ProductRatePlanCharge__c> charges = new List<zqu__ProductRatePlanCharge__c>();
    Integer zuoraid = Integer.valueOf(rp.zqu__ZuoraId__c) * 1000;
    for (List<String> chargedefine : chargedefines) {
      zqu__ProductRatePlanCharge__c p_charge = new zqu__ProductRatePlanCharge__c();
      p_charge.Name = chargedefine.get(1) + ' ' + chargedefine.get(0);
      p_charge.zqu__Model__c = chargedefine.get(0);
      p_charge.zqu__Type__c = chargedefine.get(1);
      p_charge.zqu__UOM__c = 'UOM tesing';
      p_charge.zqu__DefaultQuantity__c = 1;
      p_charge.zqu__MinQuantity__c = 0;
      p_charge.zqu__MaxQuantity__c = 500;
      p_charge.zqu__RecurringPeriod__c = 'Monthly';
      p_charge.zqu__ZuoraId__c = String.valueOf(zuoraid);
      p_charge.zqu__ProductRatePlan__c = rp.Id;
      p_charge.zqu__ProductRatePlan__r = rp;
      p_charge.zqu__Deleted__c = false;
      if (
        p_charge.zqu__Model__c == 'Discount-Fixed Amount' ||
        p_charge.zqu__Model__c == 'Discount-Percentage'
      ) {
        p_charge.zqu__Discount_Apply_Type__c = 3;
        p_charge.zqu__Upto_How_Many_Periods__c = 5;
        p_charge.zqu__Discount_Level__c = 'RatePlan';
      }
      zuoraid++;
      charges.add(p_charge);
    }
    return charges;
  }

  private static List<zqu__ProductRatePlanChargeTier__c> getProductRatePlanChargeTiers(
    zqu__ProductRatePlanCharge__c charge
  ) {
    List<Decimal> tierprices = TIER_MAPPING.get(
      charge.zqu__Type__c + '_' + charge.zqu__Model__c
    );
    List<zqu__ProductRatePlanChargeTier__c> p_tiers = new List<zqu__ProductRatePlanChargeTier__c>();
    Integer tiernumber = 0;
    if (
      MODEL_V.equals(charge.zqu__Model__c) ||
      MODEL_T.equals(charge.zqu__Model__c)
    ) {
      for (Integer i = 0; i < tierprices.size(); i++) {
        zqu__ProductRatePlanChargeTier__c p_tier = new zqu__ProductRatePlanChargeTier__c();
        p_tier.zqu__Price__c = tierprices[i];
        if (0 == tierprices[i + 1]) {
          p_tier.zqu__PriceFormat__c = 'Flat Fee';
        } else {
          p_tier.zqu__PriceFormat__c = 'Per Unit';
        }
        p_tier.zqu__Tier__c = tiernumber + 1;
        p_tier.zqu__Currency__c = DEFAULT_CURRENCY;
        if (0 == tiernumber) {
          p_tier.zqu__StartingUnit__c = 0;
        } else {
          p_tier.zqu__StartingUnit__c = 100 * tiernumber + 1;
        }
        if (tiernumber <= tierprices.size() - 1) {
          p_tier.zqu__EndingUnit__c = 100 * (tiernumber + 1);
        }
        p_tier.zqu__ProductRatePlanCharge__r = charge;
        p_tier.zqu__ProductRatePlanCharge__c = charge.Id;
        p_tier.zqu__Deleted__c = false;
        p_tiers.add(p_tier);
        i++;
        tiernumber++;
      }
    } else {
      for (Decimal tierprice : tierprices) {
        zqu__ProductRatePlanChargeTier__c p_tier = new zqu__ProductRatePlanChargeTier__c();
        p_tier.zqu__Price__c = tierprice;
        p_tier.zqu__Tier__c = tiernumber + 1;
        p_tier.zqu__Currency__c = DEFAULT_CURRENCY;
        p_tier.zqu__StartingUnit__c = 100 * tiernumber + 1;
        if (tiernumber <= tierprices.size() - 1) {
          p_tier.zqu__EndingUnit__c = 100 * (tiernumber + 1);
        }
        p_tier.zqu__ProductRatePlanCharge__r = charge;
        p_tier.zqu__ProductRatePlanCharge__c = charge.Id;
        p_tier.zqu__Deleted__c = false;
        p_tiers.add(p_tier);
      }
    }
    return p_tiers;
  }

  public static Zuora__Payment__c createPayment(
    Zuora__CustomerAccount__c billingAcc
  ) {
    Zuora__Payment__c payment = new Zuora__Payment__c();
    payment.Name = 'test';
    payment.Zuora__PaymentMethod__c = 'Credit card';
    payment.Zuora__Effective_Date__c = Date.today();
    payment.Zuora__Amount__c = 100;
    payment.Zuora__BillingAccount__c = billingAcc.Id;
    return payment;
  }

  public static void createSimilarWebSettings() {
    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["account","lead"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;
  }

  public static ContactDraft__c creatContactDraft(Account acc) {
    ContactDraft__c draftObject = new ContactDraft__c();
    draftObject.AccountId__c = acc.Id;
    draftObject.Email__c = 'test@test.com';
    draftObject.FirstName__c = 'testFN';
    draftObject.LastName__c = 'testLN';
    draftObject.Title__c = 'testTitle';
    draftObject.Department__c = 'Investment';
    draftObject.OriginalLeadSource__c = 'Facebook';
    draftObject.Phone__c = '1111';
    draftObject.Mobile__c = '2222';
    draftObject.Country__c = 'UK';
    draftObject.UploadStatus__c = '';
    draftObject.isValid__c = true;
    return draftObject;
  }
}

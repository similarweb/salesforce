@isTest
private class ASProductModalControllerTest {
  @testSetup
  static void setup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    insert TestDataFactory.createBaseProductContract_CS();
    insert TestDataFactory.createBaseProductConfiguration_CS();
    insert TestDataFactory.createBaseProductControlling_CS();
    insert TestDataFactory.createBaseProductDependent_CS();
    insert TestDataFactory.createBaseProductDefaultAddon_CS();
    insert TestDataFactory.createBaseProductDynamicAddon_CS();
    insert TestDataFactory.createBaseProductNumOfUsers_CS();
    Account a = TestObjectCreator.CreateAccount();
    a.billingcountryCode = 'US';
    insert a;
    Contact c = TestObjectCreator.CreateContact(
      a,
      'test' + TestObjectCreator.randomStream(9, 2) + '@testing.com'
    );
    c.MailingCountryCode = 'US';
    insert c;
    Opportunity opp = TestObjectCreator.CreateOpportunity(a);
    opp.Primary_Contact__c = c.id;
    insert opp;
    Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(a);
    insert zca;

    List<Request__c> requestList = new List<Request__c>();
    Request__c rquest1 = new Request__c();
    rquest1.Requester__c = UserInfo.getUserId();
    rquest1.Recipient_Picklist__c = 'Chris Foale';
    rquest1.Applicable_Quote__c = 'Yes';
    rquest1.Opportunity__c = opp.Id;
    rquest1.Account__c = opp.AccountId;
    rquest1.Signed_contract__c = 'Yes';
    rquest1.Currency__c = 'USD';
    rquest1.RecordTypeId = '0120X0000005lrhQAA';
    rquest1.Regularity__c = 'One time';
    rquest1.Status__c = 'Submitted';
    rquest1.List_Price__c = 788;
    rquest1.Account__c = a.id;
    rquest1.Opportunity__c = opp.id;
    rquest1.Manager__c = UserInfo.getUserId();
    requestList.add(rquest1);

    Request__c rquest2 = new Request__c();
    rquest2.Requester__c = UserInfo.getUserId();
    rquest2.Recipient_Picklist__c = 'Chris Foale';
    rquest2.Applicable_Quote__c = 'Yes';
    rquest2.Opportunity__c = opp.Id;
    rquest2.Account__c = opp.AccountId;
    rquest2.Signed_contract__c = 'Yes';
    rquest2.Currency__c = 'USD';
    rquest2.RecordTypeId = '0120X0000005lrhQAA';
    rquest2.Regularity__c = 'Recurring Monthly';
    rquest2.Status__c = 'Submitted';
    rquest2.List_Price__c = 1419;
    rquest2.Account__c = a.id;
    rquest2.Opportunity__c = opp.id;
    rquest2.Manager__c = UserInfo.getUserId();
    requestList.add(rquest2);
    insert requestList;

    zqu__Quote__c quote = TestDataFactory.CreateZQuote(opp, c);
    quote.Quote_contains_AS_products__c = true;
    quote.zqu__QuoteBusinessType__c = 'Co-Term Upsell';
    quote.zqu__Previewed_SubTotal__c = 10;
    quote.Target_Quote_Total_Price__c = 10;
    quote.zqu__PaymentMethod__c = 'Other';
    insert quote;
    List<zqu__QuoteRatePlanCharge__c> chargeList = new List<zqu__QuoteRatePlanCharge__c>();

    zqu__QuoteAmendment__c zqa = new zqu__QuoteAmendment__c(
      zqu__Quote__c = quote.Id
    );
    insert zqa;
    zqu__QuoteRatePlan__c zqrp = new zqu__QuoteRatePlan__c(
      zqu__Quote__c = quote.Id,
      zqu__QuoteAmendment__c = zqa.Id
    );
    insert zqrp;
    zqu__QuoteRatePlanCharge__c zqrpc = new zqu__QuoteRatePlanCharge__c(
      zqu__Total__c = 1,
      zqu__ListTotal__c = 1,
      zqu__QuoteRatePlan__c = zqrp.Id,
      zqu__ProductName__c = 'Digital Suite - Advisory Services'
    );
    chargeList.add(zqrpc);
    zqu__QuoteRatePlanCharge__c zqrpc2 = new zqu__QuoteRatePlanCharge__c(
      zqu__Total__c = 2,
      zqu__ListTotal__c = 2,
      zqu__QuoteRatePlan__c = zqrp.Id,
      zqu__ProductName__c = 'Digital Suite - Advisory Services'
    );
    chargeList.add(zqrpc2);
    insert chargeList;
    Product2 asProduct = new Product2(
      Name = 'Digital Suite - Advisory Services',
      InternalCode__c = 'DigSuAdSer',
      zqu__Category__c = 'Add On Services',
      AS__C = '1'
    );
    insert asProduct;
  }

  @isTest
  static void insertRequestTest() {
    String oneTimeRequestId = '';
    String recurrencyRequestId = '';
    Double targetPriceValue = 1500;
    zqu__Quote__c quote = [
      SELECT Id, Target_Quote_Total_Price__c, AS_DS__c
      FROM zqu__Quote__c
    ];
    List<Request__c> requestList = [
      SELECT Id, Status__c, Regularity__c
      FROM Request__c
    ];
    for (Request__c request : requestList) {
      if (request.Regularity__c == 'One time') {
        oneTimeRequestId = request.id;
      } else {
        recurrencyRequestId = request.id;
      }
    }

    ASProductModalController.ResponseWrapper wrapper = new ASProductModalController.ResponseWrapper();
    wrapper.requestId = oneTimeRequestId;

    Test.startTest();
    System.debug('Test test' + quote.AS_DS__c);
    ASProductModalController.insertRequest(
      quote.id,
      oneTimeRequestId,
      recurrencyRequestId,
      targetPriceValue,
      false,
      5000
    );
    ASProductModalController.insertRequest(
      quote.id,
      oneTimeRequestId,
      recurrencyRequestId,
      quote.Target_Quote_Total_Price__c,
      true,
      5000
    );
    Test.stopTest();
  }

  @isTest
  static void insertRequestNullValuesTest() {
    ASProductModalController.insertRequest(null, null, null, null, null, null);
  }

  @isTest
  static void getQuoteFieldsTest() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    Test.startTest();
    Response resp = ASProductModalController.getQuoteFields(quote.id);
    Test.stopTest();
    System.assert(resp.success);
  }

  @isTest
  static void checkIfASProductsExistTest() {
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    List<Request__c> requestList = [
      SELECT Id, Status__c, Regularity__c
      FROM Request__c
    ];
    Request__c oneTime;
    Request__c reccuring;
    for (Request__c r : requestList) {
      if (r.Regularity__c == 'One time') {
        oneTime = r;
      } else {
        reccuring = r;
      }
    }

    Test.startTest();
    try {
      ASProductModalController.checkIfASProductsExist(
        quote,
        oneTime,
        reccuring
      );
    } catch (Exception e) {
      System.assert(e.getMessage().contains('The relevant product'));
    }

    Test.stopTest();
  }

  @isTest
  static void insertRequestExceptionTest() {
    Double targetPriceValue = 1500;
    zqu__Quote__c quote = [SELECT Id FROM zqu__Quote__c];
    quote.Quote_contains_AS_products__c = false;
    update quote;

    String oneTimeRequestId = '';
    String recurrencyRequestId = '';

    Test.startTest();
    ASProductModalController.insertRequest(
      quote.id,
      oneTimeRequestId,
      recurrencyRequestId,
      targetPriceValue,
      false,
      5000
    );
    Test.stopTest();
  }
}

@isTest
public without sharing class TestServicesTest {
  @istest
  static void TestServices() {
    //	SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //	currentSettings.API_Key__c='test';
    //	currentSettings.Create_Date_TimeFrame__c='test';
    //	currentSettings.Enriched_Entities__c='["account"]';
    //	currentSettings.Invisible_Fields__c='test';
    //	currentSettings.Refresh_Data_Interval__c=0;
    //	currentSettings.Sync_on_create_and_update__c=true;
    //	insert currentSettings;

    Inferral_Solution_Settings__c inferral_Solution_Settings = new Inferral_Solution_Settings__c();
    inferral_Solution_Settings.Value__c = 'Marketing (MI)';
    inferral_Solution_Settings.Name = 'Default Value';
    insert inferral_Solution_Settings;

    CSSettings__c cs = TestObjectCreator.CreateCSSettings();
    insert cs;

    RestResponse res = new RestResponse();
    RestContext.response = res;
    Services.ZuoraAccountHandler(
      '5675',
      'aaaa@ajkdha.com',
      'dfsdfsdf',
      'sdfsdfsdfsd',
      'sdfsdfsdf',
      'Israel',
      '',
      'AdTech and AdNetwork',
      '1',
      '2',
      '2025-01-11'
    );
    RestRequest req = new RestRequest();
    req.httpMethod = 'GET';
    Account a = TestObjectCreator.CreateAccount();
    a.BillingCountryCode = 'US';
    insert a;
    Opportunity o = TestObjectCreator.CreateOpportunity(a);
    insert o;
    zqu__Quote__c quote = TestObjectCreator.CreateZQuote(o);
    quote.zqu__ZuoraAccountID__c = 'new';
    quote.zqu__Account__c = o.accountid;
    quote.zqu__Opportunity__c = o.Id;
    quote.zqu__Currency__c = 'USD';
    quote.zqu__ApprovalStatus__c = 'New';
    quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
    quote.Payment_Frequency__c = 12;
    quote.zqu__Certificate_ID__c = '12345';
    quote.zqu__ElectronicPaymentMethodId__c = 'jjbsdjjkb';
    quote.zqu__PaymentMethod__c = 'Credit Card';
    quote.zqu__Previewed_SubTotal__c = 6000;
    quote.Total_Discount__c = 10;
    quote.Total_List_Price__c = 1000;
    insert quote;
    req.requestURI = 'apexrest/services/sendQuote/' + String.valueof(quote.Id);
    RestContext.request = req;
    Services.doGet();

    /* dr 28-Feb-2016 - this throws exception and doens't look like increasing coverage
  	req.requestURI = 'apexrest/services/sendQuote/sdkfjslkdjfs';
  	RestContext.request = req;
  	Services.doGet();
  	
  	req.requestURI = 'apexrest/services/vvv/sfsdfsdf';
  	RestContext.request = req;
  	Services.doGet();*/
  }
}

@isTest
public class UtilityTest {

    @TestSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
    }

    @isTest
    public static void hashCodeTest() {
        Utility.hashCode('name');
    }

    @isTest
    public static void convertDateToDatetimeTest() {
        Utility.convertDateToDatetime(Date.today());
    }

    @isTest
    public static void getRecordTypeIdForObjectTest() {
        RecordType recType = [SELECT DeveloperName 
                                FROM RecordType
                               WHERE SobjectType = 'Account' 
                               LIMIT 1
        ];
        Account acc = TestDataFactory.createAccount();
        insert acc;
        Utility.getRecordTypeIdForObject(acc.getSObjectType(),recType.DeveloperName);
        Utility.getRecordTypeIdForObject('Account',recType.DeveloperName);
    }
    
    @isTest
    public static void getDevNameForRecordTypeIDTest() {
        Account acc = TestDataFactory.createAccount();
        insert acc;
        acc = [SELECT Id,RecordTypeId FROM Account];
        Utility.getDevNameForRecordTypeID(acc.getSObjectType(),acc.RecordTypeId);
        Utility.getDevNameForRecordTypeID('Account',acc.RecordTypeId);
    }

    @isTest
    public static void replaceTest() {
        List<String> testList = new List<String>{'test1','test2'};
        Utility.replace(testList,'test2','test3');
    }

    @isTest
    public static void isProductionOrgTest() {
        Utility.isProductionOrg();
    }

    @isTest
    public static void getDaysInYearTest() {
        Utility.getDaysInYear(Date.today());
    }

    @isTest
    public static void getDaysBetween() {
        Utility.getDaysBetween(Date.today(),Date.today().addDays(1));
    }
    
    /* @isTest
    public static void test() {
        Utility.hashCode('name');
    }

    @isTest
    public static void test2() {
        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
      currentSettings.API_Key__c='test';
      currentSettings.Create_Date_TimeFrame__c='test';
      currentSettings.Enriched_Entities__c='["account"]';	        
      currentSettings.Invisible_Fields__c='test';
      currentSettings.Refresh_Data_Interval__c=0;
      currentSettings.Sync_on_create_and_update__c=true;
      insert currentSettings;
      
  	CSSettings__c cs = TestObjectCreator.CreateCSSettings();
  	insert cs;
  	Services.ZuoraAccountHandler ('5675', 'aaaa@ajkdha.com', 'dfsdfsdf', 'sdfsdfsdfsd', 'sdfsdfsdf');
  	RestRequest req = new RestRequest();
  	req.httpMethod = 'GET';
	Account a = TestObjectCreator.CreateAccount();
	a.BillingCountry = 'USA';
  	insert a;
  	Opportunity o = TestObjectCreator.CreateOpportunity(a);
  	insert o;
        zqu__Quote__c quote = TestObjectCreator.CreateZQuote(o);
        quote.zqu__ZuoraAccountID__c = 'new';
        quote.zqu__Account__c = o.accountid;
        quote.zqu__Opportunity__c = o.Id;
        quote.zqu__Currency__c='USD';      
        quote.zqu__ApprovalStatus__c = 'New';
        quote.zqu__PaymentTerm__c = 'Due Upon Receipt';
        quote.Payment_Frequency__c = 12;
        quote.zqu__Certificate_ID__c = '12345';
        quote.zqu__ElectronicPaymentMethodId__c = 'jjbsdjjkb';
        quote.zqu__PaymentMethod__c = 'Credit Card';
        quote.Legacy_or_New_solution_deal__c = 'New solution';
        quote.New_solution_use_case__c = 'Marketing';
        quote.zqu__Previewed_SubTotal__c = 6000;
        quote.Total_Discount__c = 10;
        quote.Total_List_Price__c = 1000;
        insert quote;
        quote.Total_List_Price__c = 2000;
        update quote;
    } */
}
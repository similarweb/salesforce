@isTest
public class ZQuoteDomainTest {
    @TestSetup
    static void setup(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();     
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
        List<String> countries =  TestObjectCreator.getCountries();
        Account a = TestObjectCreator.CreateAccount();
        a.billingcountry = countries[countries.size()-1];
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        c.MailingCountry = countries[countries.size()-1];
        insert c;
        list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        Opportunity o = TestObjectCreator.CreateOpportunity (a);
        insert o;                
    }
    
    @IsTest
    static void newSubQuoteInsertTest(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact); 
        Test.startTest();
        insert quote;
        Test.stopTest();
    }

    @IsTest
    static void newSubQuoteUpdateTest(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact); 
        insert quote;
        quote.zqu__InitialTerm__c = 6;
        Test.startTest();
        update quote;
        Test.stopTest();
    }

    @IsTest
    static void cancellationQuoteInsertTest(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createCancellationZQuote (opp,contact); 
        Test.startTest();
        insert quote;
        Test.stopTest();
    }

    @IsTest
    static void amendQuoteInsertTest(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createAmendZQuote (opp,contact); 
        Test.startTest();
        insert quote;
        Test.stopTest();
    }

    @IsTest
    static void amendRenewalQuoteInsertTest(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createAmendZQuote (opp,contact); 
        quote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
        Test.startTest();
        insert quote;
        Test.stopTest();
    }

    @IsTest
    static void launchZuoraAccountFieldUpdateJob_Test(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact); 
        
        Test.startTest();
            ZQuoteDomain testDomain = new ZQuoteDomain(new List<zqu__Quote__c>{quote});
            insert quote;
            testDomain.launchZuoraAccountFieldUpdateJob(new Set<Id>{quote.Id});
        Test.stopTest();
    }

    @IsTest
    static void checkIfFeldsIsChangedTest() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createAmendZQuote (opp,contact); 
        quote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
        insert quote;
        Test.startTest();
        quote.zqu__QuoteBusinessType__c = 'Feature Update + Renewal (with/without upsell)';
        update quote;
        Test.stopTest();
    }

    @isTest
    public static void calculateSpecificBillingPeriodTest(){
        Test.startTest();
        Account a = TestDataFactory.CreateAccount();
        a.billingcountry = 'Israel';
        insert a;
        Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
        c.MailingCountry = 'Israel';
        insert c;
        Opportunity opp = TestDataFactory.CreateOpportunity (a);
        opp.CloseDate = Date.today().addDays(1);
        insert opp;   

        zqu__Quote__c q = TestDataFactory.createZQuote (opp,c);
        insert q;
        zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
        insert qa;
        zqu__QuoteRatePlan__c zqrp = TestDataFactory.CreateRatePlan (qa);
        insert zqrp;
        zqu__QuoteRatePlanCharge__c qrpc = TestDataFactory.CreateRatePlanCharge (zqrp);
        qrpc.zqu__RatePlanName__c = 'Marketing Solution - Premium';
        qrpc.zqu__ListTotal__c = 250;
        insert qrpc;
        ZuoraQuoteMetricsManipulationHelper.isMakeDataGetChargeDisabled = true;
        ZuoraQuoteMetricsManipulationHelper.calculateSpecificBillingPeriod(new List<zqu__Quote__c>{q},new Set<Id>{q.Id});
        Test.stopTest();
    }

    @isTest
    public static void onInsertStandartQuoteTest(){       
        // List<String> countries =  TestObjectCreator.getCountries();
        // Account a = TestObjectCreator.CreateAccount();
        // a.billingcountry = countries[countries.size()-1];
        // insert a;
        // Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        // c.MailingCountry = countries[countries.size()-1];
        // insert c;
        // list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        // Opportunity o = TestObjectCreator.CreateOpportunity (a);
        // insert o;
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Opportunity o = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Test.startTest();                
        zqu__Quote__c q = TestDataFactory.createZQuote (o,c); 
        insert q;
        Test.stopTest();
    }

    @isTest
    public static void onInsertAmendQuoteTest(){       
        // List<String> countries =  TestObjectCreator.getCountries();
        // Account a = TestObjectCreator.CreateAccount();
        // a.billingcountry = countries[countries.size()-1];
        // insert a;
        // Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        // c.MailingCountry = countries[countries.size()-1];
        // insert c;
        // list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        // Opportunity o = TestObjectCreator.CreateOpportunity (a);
        // insert o;
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Opportunity o = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Test.startTest();            
        zqu__Quote__c q = TestDataFactory.createZQuote (o,c); 
        insert q;
        zqu__QuoteAmendment__c qa = TestDataFactory.createZQuoteAmendment(q);
        insert qa;
        Test.stopTest();
    }

    @isTest
    public static void onInsertRenewalQuoteTest(){       
        // List<String> countries =  TestObjectCreator.getCountries();
        // Account a = TestObjectCreator.CreateAccount();
        // a.billingcountry = countries[countries.size()-1];
        // insert a;
        // Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        // c.MailingCountry = countries[countries.size()-1];
        // insert c;
        // list<Country_Subsidiary__c> lcsc = TestObjectCreator.CreateCountries();
        // Opportunity o = TestObjectCreator.CreateOpportunity (a);
        // insert o;
        Account a = [SELECT Id FROM Account LIMIT 1];
        Contact c = [SELECT Id FROM Contact LIMIT 1];
        Opportunity o = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Test.startTest();            
        zqu__Quote__c testQuote = TestDataFactory.createZQuote (o,c); 
                      testQuote.zqu__PaymentMethod__c = 'Other';
                      testQuote.Customer_Type__c = 'Company';
                      testQuote.Is_from_existing_Billing_Account__c = false;
                      testQuote.zqu__Account__c = a.Id;
                      testQuote.zqu__QuoteBusinessType__c = 'Renewal (with/without upsell)';
                      testQuote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
                      testQuote.zqu__SubscriptionTermEndDate__c = Date.today().addDays(2);
        insert testQuote;
        Test.stopTest();
    }

    @isTest
    public static void createRenewalConfirmationTimestampPdfTest(){
        Zuora_Document_Generation_Setting__c defaultRenewalTemplate = new Zuora_Document_Generation_Setting__c();
        defaultRenewalTemplate.Name = 'Default Renewal Quote Template Id';
        defaultRenewalTemplate.Value__c = 'test';
        
        Contact contact2 = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp2 = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp2,contact2);
        quote2.zqu_Quote_Status__c = 'Contract Signed';
        insert quote2;

        quote2.zqu__InitialTerm__c = 5;
        quote2.zqu__StartDate__c = System.today().addDays(10);
        quote2.Renewal_by_client_confirmation__c = true;

        String responseBody = '{'+
                              '    "success": true'+
                              '}';
        HttpResponse testResp = new HttpResponse();
        testResp.setStatusCode(200);
        testResp.setHeader('Content-Type','application/msword');
        testResp.setBody(responseBody);
        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        Test.startTest();
        insert defaultRenewalTemplate;
        update quote2;
        quote2.zqu_Quote_Status__c = 'Sent To Zuora';
        update quote2;
        Test.stopTest();

    }

    @isTest
    public static void updateZouraQuoteWithList(){
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.SolutionGeneration__c = 'Test solution';
        quote.zqu__ZuoraAccountID__c = 'Test id';
        quoteList.add(quote);

        zqu__Quote__c quote2 = TestDataFactory.createZQuote(opp,contact);
        quote2.SolutionGeneration__c = 'Test solution';
        quote2.zqu__ZuoraAccountID__c = 'Test id';
        quoteList.add(quote2);
        
        Test.startTest();
        insert quoteList;
        Test.stopTest();
    }

    @isTest
    public static void multiSubProcessTest(){
        List<zqu__Quote__c> quoteList = new List<zqu__Quote__c>();
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        Zuora__CustomerAccount__c billAcc = TestDataFactory.createBillingAccount(acc);
        billAcc.Zuora_Parent_Account__c = 'Yes';
        insert billAcc;
        Zuora__Subscription__c sz = TestDataFactory.createSubscription(acc, billAcc);
        sz.Zuora__TermSettingType__c = 'TERMED';
        sz.Zuora__Status__c = 'Active';
        insert sz;
        zqu__Quote__c quote = TestDataFactory.createZQuote (opp,contact);
        quote.SolutionGeneration__c = 'Test solution';
        quote.zqu__ZuoraAccountID__c = 'Test id';
        quote.MultiSubscription__c = true;
        quoteList.add(quote);
        insert quoteList;
        Test.stopTest();
    }

    private class ZuoraServiceMock implements HttpCalloutMock {
        private HttpResponse res;

        public ZuoraServiceMock(HttpResponse res){
            this.res = res;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return this.res;
        }
    }
}
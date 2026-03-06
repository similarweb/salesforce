/**
 * Created by Alon.Shalev on 9/11/2024.
 */
@IsTest
public class UpdateFutureOraOppsBatchTest {

    @TestSetup
    static void setupData() {
        Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
        iss.Name='Default Value';
        iss.Value__c='Sales';
        insert iss;
        InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
        ismTest.SW_Industry__c = 'AdTech and AdNetwork';
        ismTest.Department__c = 'BI / Analytics';
        ismTest.Inferred_Solution__c = 'Research';
        ismTest.Name = 'test';
        insert ismTest;
        // Create a mock Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Zuora__CustomerAccount__c zca = TestObjectCreator.CreateBillingAccount (acc);
        zca.Zuora__AccountNumber__c = '123';
        zca.Zuora__DefaultPaymentMethod__c = 'WireTransfer';
        zca.Zuora__BillToWorkEmail__c = 'test@test.com';
        zca.Zuora__Currency__c = 'USD';
        insert zca;

        // Create mock Zuora__Subscription__c records
        Zuora__Subscription__c sz = TestDataFactory.createSubscription(acc, zca);
        sz.Zuora__TermSettingType__c = 'TERMED';
        sz.Zuora__Status__c = 'Active';
        insert sz;

        // Create a mock Opportunity
        Opportunity opp = new Opportunity(
                AccountId = acc.Id,
                StageName = 'Prospecting',
                CloseDate = Date.today().addMonths(1),
                Type = 'Upsell',
                Cycle__c = 'Annually'
        );
        insert opp;
        Contact contact = TestObjectCreator.CreateContact(acc, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        contact.MailingCountryCode = 'US';
        insert contact;

        // Create mock zqu__Quote__c records
        zqu__Quote__c quote2 = TestDataFactory.createZQuote (opp,contact);
        quote2.zqu_Quote_Status__c = 'Contract Signed';
        insert quote2;


    }

    @IsTest
    static void testExecuteBatch() {
        // Run the batch class and validate its behavior

        Test.startTest();
        String responseBody = '{'+
                '    "success": true'+
                '}';
        HttpResponse testResp = new HttpResponse();
        testResp.setStatusCode(200);
        testResp.setHeader('Content-Type','application/msword');
        testResp.setBody(responseBody);
        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        zqu__Quote__c quote2 = [SELECT Id,zqu__Account__c,Future_CTU_Flag__c,zqu__StartDate__c,zqu_Quote_Status__c,zqu__QuoteBusinessType__c FROm zqu__Quote__c ];
        quote2.zqu_Quote_Status__c = 'Sent to Zuora';
        quote2.Future_CTU_Flag__c = true;
        quote2.zqu__StartDate__c = Date.today();
        quote2.zqu__QuoteBusinessType__c = 'Co-Term Upsell + Renewal';
        update quote2;
        // Execute the batch with a small scope size
        UpdateFutureOraOppsBatch batch = new UpdateFutureOraOppsBatch();
        Database.executeBatch(batch, 1);  // Adjust the batch size if needed

        Test.stopTest();
        //assert

        // Verify that the batch processed the quotes and updated Future_CTU_Flag__c
        List<zqu__Quote__c> quotes = [SELECT Id, Future_CTU_Flag__c FROM zqu__Quote__c WHERE Future_CTU_Flag__c = false];
        System.assertEquals(1, quotes.size(), 'The Future_CTU_Flag__c should be updated to false for processed quotes.');

        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Type = 'Renewal'];
        System.assertEquals(1, opps.size(), 'There should be at least one Opportunity created/updated.');
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
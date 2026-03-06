@isTest
public class QuoteTotalFieldsCalcBatchTest {
    
    @testSetup
    public static void setup(){
        TestDataFactory.createInferredSolutionSettings_CS();
        Account a = TestObjectCreator.CreateAccount();
        a.billingcountryCode = 'US';
        insert a;
        Contact c = TestObjectCreator.CreateContact(a, 'test'+TestObjectCreator.randomStream(9,2)+'@testing.com');
        c.MailingCountryCode = 'US';
        insert c;
        Opportunity opp = TestObjectCreator.CreateOpportunity(a);
        opp.Primary_Contact__c = c.id;
        insert opp;
        Zuora__CustomerAccount__c zca = TestDataFactory.createBillingAccount(a);
        insert zca;
        zqu__Quote__c quote = TestDataFactory.CreateZQuote(opp, c);
        insert quote;
        zqu__QuoteAmendment__c zqa = new zqu__QuoteAmendment__c(zqu__Quote__c = quote.Id);
        insert zqa;
        zqu__QuoteRatePlan__c zqrp = new zqu__QuoteRatePlan__c(zqu__Quote__c = quote.Id,zqu__QuoteAmendment__c = zqa.Id);
        insert zqrp;
        zqu__QuoteRatePlanCharge__c zqrpc = new zqu__QuoteRatePlanCharge__c(zqu__Total__c=1,zqu__ListTotal__c=1,zqu__QuoteRatePlan__c=zqrp.Id); 
        insert zqrpc;
    }
    
    @isTest
    public static void testBatch(){
        Test.startTest();
        Database.executeBatch(new QuoteTotalFieldsCalcBatch());
        Test.stopTest();
    }
    
}
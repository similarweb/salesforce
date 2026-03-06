@isTest
public class ZuoraQuoteMetricQueueableTest {
    @TestSetup
    static void setup(){

        List<String> countries =  TestDataFactory.getCountries();
        Account acc = TestDataFactory.createAccount();
        acc.billingcountry = countries[countries.size()-1];
        insert acc;

        Opportunity opp = TestDataFactory.CreateOpportunity (acc);
        insert opp;  

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
        rquest1.Account__c = acc.id;
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
        rquest2.Account__c = acc.id;
        rquest2.Opportunity__c = opp.id;
        rquest2.Manager__c = UserInfo.getUserId();
        requestList.add(rquest2);
        insert requestList;

        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test Quote';
        quote.zqu__StartDate__c = System.today();
        quote.zqu__ValidUntil__c = System.today();
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        quote.zqu__InitialTerm__c = 12;
        quote.zqu__RenewalTerm__c = 12;
        quote.zqu__Account__c = (acc != null) ? acc.Id : null;
        quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
        quote.zqu__BillToContact__c = null;
        quote.zqu__SoldToContact__c = null;
        quote.zqu__Currency__c = 'USD';
        quote.zqu__ZuoraAccountID__c = acc.id;
        quote.zqu__Status__c = 'New';
        quote.zqu__SubscriptionType__c = 'Amend Subscription';
        quote.zqu__Hidden_Subscription_Name__c = 'Test Zuora Subscription';
        quote.Target_Quote_Total_Price__c = 3030;
        quote.zqu__InitialTerm__c = 250;
        insert quote;
    }

    @isTest
    public static void executeUpdateChargesTets(){
        zqu__Quote__c quote = [SELECT id, Target_Quote_Total_Price__c, zqu__InitialTerm__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
        List<Request__c> requestList = [SELECT Id, Regularity__c, List_Price__c FROM Request__c];
        String oneTimeRequestId = '';
        String recurringRequestId = '';
        Map<String, Decimal> requestMap = new Map<String, Decimal>();
        for(Request__c rq : requestList){
            if(rq.Regularity__c == 'One time'){
                oneTimeRequestId = rq.id;
                requestMap.put(rq.Regularity__c , rq.List_Price__c);
            } else if(rq.Regularity__c == 'Recurring Monthly'){
                recurringRequestId = rq.id;
                requestMap.put(rq.Regularity__c , rq.List_Price__c);
            }
        }
        String actionName = 'updateChargesIfMetricsChanged';
        System.enqueueJob(new ZuoraQuoteMetricManipulationQueueable(quote.id, quote.Target_Quote_Total_Price__c, quote.zqu__InitialTerm__c, oneTimeRequestId, recurringRequestId, requestMap, actionName));
        Test.stopTest();
    }
    
    @isTest
    public static void executeRecalculateSubtotalTest(){
        zqu__Quote__c quote = [SELECT id, Target_Quote_Total_Price__c, zqu__InitialTerm__c FROM zqu__Quote__c LIMIT 1];
        Test.startTest();
            System.enqueueJob(new ZuoraQuoteMetricManipulationQueueable(quote.id, 'recalculateSubtotal'));
        Test.stopTest();
    }

    @isTest
    public static void executeRecalculateNewSubTest(){
        zqu__Quote__c quote = [SELECT id, Target_Quote_Total_Price__c, zqu__InitialTerm__c FROM zqu__Quote__c LIMIT 1];
        quote.zqu__SubscriptionType__c = 'New Subscription';
        update quote;
        Test.startTest();
            System.enqueueJob(new ZuoraQuoteMetricManipulationQueueable(quote.id, 'recalculateSubtotal'));
        Test.stopTest();
    }
}
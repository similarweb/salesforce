@isTest  
public class FillSimilarWebForecastBatchTest {

    @isTest
    static void test(){
        Test.startTest();
        Account acc = new Account( Name = 'Account_for_user', Business_unit__c='Inside Sales'); //account whose opps will be visible
        Account acc2 = new Account( Name = 'Account_for_user_2', Business_unit__c='Inside Sales'); 
        insert new List<Account>{acc, acc2};        
        List<Opportunity> opps = new List<opportunity>{
                new Opportunity(AccountId=acc.Id, Name = 'Acc1_Opportunity_1', Type='New Sell', Cycle__c='Annually', CloseDate = DAte.today(), Cycle_Price__c=123, StageName='Prospect',Similarweb_Forecasting_status__c=null), 
                new Opportunity(AccountId=acc2.Id, Name = 'Acc2_Opportunity_1', Type='New Sell', Cycle__c='Annually', CloseDate = DAte.today(), Cycle_Price__c=123, StageName='Prospect',Similarweb_Forecasting_status__c=null)
            }; 
        insert opps;        
        Database.executeBatch(new FillSimilarWebForecastBatch());
        Test.stopTest();
    }
}
@isTest
public class ClosedOpportunityRelevantTaskBatchTest {
  /*  static testmethod void test() {
        Account a = new Account(Name = 'ABC');
        insert a;
        List<Opportunity> opportunityToInsert = new List<Opportunity>();
        for(Integer i=0; i<100; i++) {
            Opportunity opp = new Opportunity(Name = 'testABC' + i, AccountId = a.Id, CloseDate = date.today(), StageName = 'Prospecting', Relevant_Task_Creation_Date__c = date.today());
            opportunityToInsert.add(opp);
        }
        insert opportunityToInsert;
        Test.startTest();

            ClosedOpportunityRelevantTaskBatch obj = new ClosedOpportunityRelevantTaskBatch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }*/
    static testmethod void test2() {
        Account a = new Account(Name = 'ABC');
        insert a;
        List<Opportunity> opportunityToInsert = new List<Opportunity>();
        for(Integer i=0; i<100; i++) {
            Opportunity opp = new Opportunity(Name = 'testABC' + i, AccountId = a.Id, CloseDate = date.today(), StageName = 'Prospecting', Relevant_Task_Creation_Date__c = date.today());
            opportunityToInsert.add(opp);
        }
        insert opportunityToInsert;
        Test.startTest();
        ClosedOpportunityRelevantTaskBatch shedule = new ClosedOpportunityRelevantTaskBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, shedule);
        
        Test.stopTest();
    }

}
@isTest
public class BatchBIDataPopulateRelatedRecordsTest {
    
    @testSetup
    static void setup(){        
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();      
        Account acc = TestDataFactory.createAccount();
        acc.Base_Product__c ='1';
        insert acc;
        Contact cnt = TestDataFactory.createContact(acc, 'test@aaa.com');
        cnt.Pro_User_Type__c = '1';
        insert cnt;
        Lead ld = TestDataFactory.createLead();
        ld.Pro_User_Type__c = '1';
        insert ld;
    }
    
    @isTest static void testsBatchBIDataPopulateRecords(){
        
        List<BI_Data__c> bids = [SELECT Id, Base_Product__c FROM BI_Data__c];
		System.debug('!bids'+ bids.size());
        Test.startTest();
        BatchBIDataPopulateRelatedRecords biBatch = new BatchBIDataPopulateRelatedRecords(true);
        database.executeBatch(biBatch, 20);
        string sch = '0 0 22 * * ?';
      	system.schedule ('BiDataFixBatch', sch, new BatchBiDataScheduler());
        Test.stopTest();
        Account acc = [SELECT ID, Base_Product__c FROM Account LIMIT 1];
        
        System.assertEquals(acc.Base_Product__c, bids[0].Base_Product__c );
        
    }    
}
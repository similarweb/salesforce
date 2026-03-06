@isTest
public class NewRequestOverrideButtonControllerTest {

    @isTest
    private static void testObtainRequestRecordTypes(){
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        Account testAcc = new Account(Name='test name');
        testAcc.BillingCountryCode = 'Us';
        insert testAcc;
        Opportunity testOpp = new Opportunity(AccountId=testAcc.Id, Name='test', StageName='Prospect', CloseDate=System.today(), Type='New Sale');
        insert testOpp;
        
        String result = NewRequestOverrideButtonController.obtainRequestRecordTypes(testOpp.Id);
        Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(result);
        
        System.assertEquals('New Sale', responseMap.get('oppType'));
        
    }
}
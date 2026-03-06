@isTest
public class InferredSolutionControllerTest {
    
    @testSetup
    public static void setup(){
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
        
        InferralSolutionMapContact__c ismCTest = new InferralSolutionMapContact__c();
        ismCTest.SW_Industry__c = 'AdTech and AdNetwork';
        ismTest.Department__c = 'BI / Analytics';
        ismCTest.Inferred_Solution__c = 'Research';        
        ismCTest.Name = 'test';
        insert ismCTest;
        
        Inferral_Solution_Valid_Criteria_List__c islvcl = new Inferral_Solution_Valid_Criteria_List__c();
        islvcl.Name='department__c';  
        islvcl.Is_Valid__c=true;
        insert islvcl;
        
        Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
        islvcl2.Name='sw_industry__c';  
        islvcl2.Is_Valid__c=true;
        insert islvcl2;
        
        InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
        islcvcl.Name='department__c';  
        islcvcl.Is_Valid__c=true;
        insert islcvcl;
        
        InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
        islcvcl2.Name='sw_industry__c';  
        islcvcl2.Is_Valid__c=true;
        insert islcvcl2;
    }
    
    @isTest
    public static void obtainInferredSolutionLeadDataTest(){
        Test.startTest();
        String testtest = InferredSolutionController.obtainInferredSolutionData('Lead');
        Test.stopTest();        
    }
    
    @isTest
    public static void obtainInferredSolutionContactDataTest(){
        Test.startTest();
        String testtest = InferredSolutionController.obtainInferredSolutionData('Contact');
        Test.stopTest();        
    }
    
    
    @isTest
    public static void saveInferredSolutionLeadDataTest(){
        List<InferralSolutionMap__c> ifsList = new List<InferralSolutionMap__c>();
        InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
        ismTest.SW_Industry__c = 'Agency';
        ismTest.Department__c = 'BI / Analytics';
        ismTest.Inferred_Solution__c = 'Research';
        ismTest.Name = 'test2';
        ifsList.add(ismTest);
        Test.startTest();
        InferredSolutionController.saveInferredSolutionData(JSON.serialize(ifsList),'Lead');
        Test.stopTest();                
    }
    
    @isTest
    public static void saveInferredSolutionLeadDataNegativTest(){
        List<InferralSolutionMap__c> ifsList = new List<InferralSolutionMap__c>();
        InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
        ismTest.SW_Industry__c = 'Agency';
        ismTest.Department__c = 'BI / Analytics';
        ismTest.Inferred_Solution__c = 'Research';
        ismTest.Name = 'test2';
        ifsList.add(ismTest);
        Test.startTest();
        InferredSolutionController.saveInferredSolutionData('dddzzz','Lead');
        Test.stopTest();                
    }
    
    @isTest
    public static void saveInferredSolutionContactDataTest(){
        List<InferralSolutionMapContact__c> ifsList = new List<InferralSolutionMapContact__c>();
        InferralSolutionMapContact__c ismTest = new InferralSolutionMapContact__c();
        ismTest.SW_Industry__c = 'Agency';
        ismTest.Department__c = 'BI / Analytics';
        ismTest.Inferred_Solution__c = 'Research';
        ismTest.Name = 'test2';
        ifsList.add(ismTest);
        Test.startTest();
        InferredSolutionController.saveInferredSolutionData(JSON.serialize(ifsList),'Contact');
        Test.stopTest();                
    }
    
    @isTest
    public static void removeLeadInferredSolutionRecordTest(){
        Test.startTest();
        String testtest = InferredSolutionController.removeInferredSolutionRecord('test','Lead');
        Test.stopTest();        
    }    
    @isTest
    public static void removeContactInferredSolutionRecordTest(){
        Test.startTest();
        String testtest = InferredSolutionController.removeInferredSolutionRecord('test','Contact');
        Test.stopTest();        
    }
    @isTest
    public static void createInferredSolutionLeadColumnTest(){
        Test.setMock(HttpCalloutMock.class, new InferredSolutionApiMock());
        Test.startTest();
        String testtest = InferredSolutionController.createInferredSolutionColumn('Status','Lead');
        InferredSolutionController.removeInferredSolutionColumn('Department__c','Lead');
        Test.stopTest();        
    }
    
    @isTest
    public static void createInferredSolutionLeadColumnWithColumnTest(){
        Test.setMock(HttpCalloutMock.class, new InferredSolutionApiMock());
        Inferral_Solution_Valid_Criteria_List__c cs = new Inferral_Solution_Valid_Criteria_List__c();
        cs.Name = 'department__c';
        cs.Is_Valid__c = false;
        insert cs;
        Test.startTest();
        String testtest = InferredSolutionController.createInferredSolutionColumn('Department__c','Lead');
        InferredSolutionController.removeInferredSolutionColumn('Department__c','Lead');
        Test.stopTest();        
    }
    
    @isTest
    public static void createInferredSolutionContactColumnTest(){
        Test.setMock(HttpCalloutMock.class, new InferredSolutionApiMock());
        Test.startTest();
        String testtest = InferredSolutionController.createInferredSolutionColumn('Status__c','Contact');
        InferredSolutionController.removeInferredSolutionColumn('Department__c','Contact');
        Test.stopTest();        
    }
    
    @isTest
    public static void saveDefaultTest(){
        Test.startTest();
        String testtest = InferredSolutionController.saveDefault('Investors');
        Test.stopTest();        
    }   
    
    @isTest
    public static void runLogicTest(){
        Test.startTest();
        InferredSolutionController.checkBatchCondition('Lead','CreatedDate > YESTERDAY');
        InferredSolutionController.checkBatchCondition('Contact','CreatedDate > YESTERDAY');
        InferredSolutionController.runLogic('Lead','CreatedDate > YESTERDAY');
        InferredSolutionController.runLogic('Contact','CreatedDate > YESTERDAY');
        Test.stopTest();        
    }
    
    @isTest
    public static void checkIfBatchRunningTest(){
        Test.startTest();
        InferredSolutionController.checkIfBatchRunning('Lead');
        InferredSolutionController.checkIfBatchRunning('Contact');
        Test.stopTest();        
    }
    
    @isTest
    public static void recalculateIndexTest(){
        Test.startTest();
        InferredSolutionController.recalculateIndex('Lead');
        InferredSolutionController.recalculateIndex('Contact');
        Test.stopTest();        
    }
}
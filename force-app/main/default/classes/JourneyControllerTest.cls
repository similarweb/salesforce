@isTest
public class JourneyControllerTest {
    
    @testSetup
    static void testSetup() {
        Journey_Path_Setting__c polygraph = new Journey_Path_Setting__c();
        polygraph.Name='polygraph';
        polygraph.Journey_Name__c='Standard';
        polygraph.Step_Name__c='Polygraph';
        polygraph.Step_Order__c=4;
        polygraph.Active__c=true;
        insert polygraph;
        /*Journey_Path_Setting__c website = new Journey_Path_Setting__c();
        website.Name='website';
        website.Journey_Name__c='Standard';
        website.Step_Name__c='Website';
        website.Step_Order__c=1;
        website.Active__c=true;
        insert website;
        Journey_Path_Setting__c sc = new Journey_Path_Setting__c();
        sc.Name='Salesforce Created';
        sc.Journey_Name__c='Standard';
        sc.Step_Name__c='Salesforce Created';
        sc.Step_Order__c=3;
        sc.Active__c=true;
        insert sc;
        Journey_Path_Setting__c pardot = new Journey_Path_Setting__c();
        pardot.Name='pardot';
        pardot.Journey_Name__c='Standard';
        pardot.Step_Name__c='pardot';
        pardot.Step_Order__c=2;
        pardot.Active__c=true;
        insert pardot;*/
        Journey_Path_Setting__c clearbit = new Journey_Path_Setting__c();
        clearbit.Name='clearbit';
        clearbit.Journey_Name__c='Standard';
        clearbit.Step_Name__c='Clearbit';
        clearbit.Step_Order__c=5;
        clearbit.Active__c=true;
        insert clearbit;
        /*Journey_Path_Setting__c datafox = new Journey_Path_Setting__c();
        datafox.Name='datafox';
        datafox.Journey_Name__c='Standard';
        datafox.Step_Name__c='Datafox';
        datafox.Step_Order__c=6;
        datafox.Active__c=true;
        insert datafox;*/
        
        Journey_Path_Setting__c fits = new Journey_Path_Setting__c();
        fits.Name='fits';
        fits.Journey_Name__c='Standard';
        fits.Step_Name__c='Fit Score';
        fits.Step_Order__c=8;
        fits.Active__c=true;
        insert fits;
        Journey_Path_Setting__c br = new Journey_Path_Setting__c();
        br.Name='br';
        br.Journey_Name__c='Standard';
        br.Step_Name__c='Behavioral Rate';
        br.Step_Order__c=9;
        br.Active__c=true;
        insert br;
        Journey_Path_Setting__c bu = new Journey_Path_Setting__c();
        bu.Name='bu';
        bu.Journey_Name__c='Standard';
        bu.Step_Name__c='Business Unit';
        bu.Step_Order__c=10;
        bu.Active__c=true;
        insert bu;
        Journey_Path_Setting__c mql = new Journey_Path_Setting__c();
        mql.Name='MQL';
        mql.Journey_Name__c='Standard';
        mql.Step_Name__c='MQL';
        mql.Step_Order__c=11;
        mql.Active__c=true;
        insert mql;
        Journey_Path_Setting__c routing = new Journey_Path_Setting__c();
        routing.Name='Routing';
        routing.Journey_Name__c='Standard';
        routing.Step_Name__c='Routing';
        routing.Step_Order__c=12;
        routing.Active__c=true;
        insert routing;
        Journey_Path_Setting__c cj = new Journey_Path_Setting__c();
        cj.Name='Completed Journey';
        cj.Journey_Name__c='Standard';
        cj.Step_Name__c='Completed Journey';
        cj.Step_Order__c=13;
        cj.Active__c=true;
        insert cj;
        
        Journey_Step_Setting__c jsp1 = new Journey_Step_Setting__c();
        jsp1.Name='Behavioral Rate';
        jsp1.TimeStampName__c='First_Behavioral_Rate_Timestamp__c';
        insert jsp1;
        
        Journey_Step_Setting__c jsp2 = new Journey_Step_Setting__c();
        jsp2.Name='Business Unit';
        jsp2.TimeStampName__c='Business_unit_timestamp__c';
        insert jsp2;
        
        Journey_Step_Setting__c jsp3 = new Journey_Step_Setting__c();
        jsp3.Name='Completed Journey';
        jsp3.TimeStampName__c='Journey_Completed_Timestamp__c';
        insert jsp3;
        
        Journey_Step_Setting__c jsp0 = new Journey_Step_Setting__c();
        jsp0.Name='Clearbit';
        jsp0.TimeStampName__c='Clearbit_Timestamp__c';
        insert jsp0;
        
        // Journey_Step_Setting__c jsp4 = new Journey_Step_Setting__c();
        // jsp4.Name='Datafox';
        // jsp4.TimeStampName__c='dfox__Last_Synced_Date__c';
        // insert jsp4;
        
        Journey_Step_Setting__c jsp5 = new Journey_Step_Setting__c();
        jsp5.Name='Fit Score';
        jsp5.TimeStampName__c='SW_Fit_Score_Timestamp__c';
        insert jsp5;
        
        Journey_Step_Setting__c jsp6 = new Journey_Step_Setting__c();
        jsp6.Name='MQL';
        jsp6.TimeStampName__c='First_MQL_Calc__c';
        insert jsp6;
        
        Journey_Step_Setting__c jsp7 = new Journey_Step_Setting__c();
        jsp7.Name='Polygraph';
        jsp7.TimeStampName__c='Polygraph_Update_Timestamp__c';
        insert jsp7;
        
        Journey_Step_Setting__c jsp8 = new Journey_Step_Setting__c();
        jsp8.Name='Routing';
        jsp8.TimeStampName__c='LeanData__Reporting_Timestamp__c';
        insert jsp8;
        
        TestDataFactory.createSimilarWebSettings();
        TestDataFactory.createInferredSolutionSettings_CS();
        
        Lead lead = new Lead(); 
        lead.Sent_to_Polygraph__c = Datetime.now().addMinutes(-40);
        lead.Polygraph_Update_Timestamp__c = Datetime.now().addMinutes(-30);
        lead.Clearbit_Timestamp__c=Datetime.now().addMinutes(-30);
        lead.SW_Fit_Score_Timestamp__c=DateTime.now().addMinutes(-15);
        lead.First_Behavioral_Rate_Timestamp__c=DateTime.now().addMinutes(-10);
        lead.Business_unit_timestamp__c=DateTime.now().addMinutes(-9);
        lead.First_MQL_Calc__c=DateTime.now().addMinutes(-8);
        lead.LeanData__Reporting_Timestamp__c=DateTime.now().addMinutes(-7);
        //lead.LeanData__Routing_Status__c = 'not processed';
        lead.LastName='Testing1';
        lead.Company='Test 16.10.18';
        lead.Orchestration_Journey__c='Standard';
        lead.Email = 'testLead@gmail.com1';
        insert lead;
        
        Lead lead2 = new Lead();
        lead2.Sent_to_Polygraph__c = DateTime.now().addHours(-2);
        lead2.Polygraph_Update_Timestamp__c =  DateTime.now().addHours(-1).addMinutes(-50);
        lead2.Clearbit_Timestamp__c=Datetime.now().addMinutes(-30);
        lead2.SW_Fit_Score_Timestamp__c=DateTime.now().addMinutes(-30);
        lead2.First_Behavioral_Rate_Timestamp__c=DateTime.now().addMinutes(-25);
        lead2.Business_unit_timestamp__c=DateTime.now().addMinutes(-20);
        lead2.First_MQL_Calc__c=DateTime.now().addMinutes(-15);
        lead2.LeanData__Reporting_Timestamp__c=DateTime.now().addMinutes(-10);
        lead2.LeanData__Routing_Status__c = 'routed';
        lead2.LastName='Testing2';
        lead2.Company='Test 16.10.18';
        lead2.Orchestration_Journey__c='Standard';
        lead2.Email = 'testLead@gmail.com2';
        insert lead2;
        
        Lead lead3 = new Lead();
        lead3.Sent_to_Polygraph__c = DateTime.now().addHours(-2);
        lead3.Polygraph_Update_Timestamp__c =  DateTime.now().addHours(-1).addMinutes(-50);
        lead3.Clearbit_Timestamp__c=Datetime.now().addMinutes(-30);        
        lead3.SW_Fit_Score_Timestamp__c=DateTime.now().addMinutes(-30);
        lead3.First_Behavioral_Rate_Timestamp__c=DateTime.now().addMinutes(-25);
        lead3.Business_unit_timestamp__c=DateTime.now().addMinutes(-20);
        lead3.First_MQL_Calc__c=DateTime.now().addMinutes(-15);
        lead3.LeanData__Reporting_Timestamp__c=DateTime.now().addMinutes(-10);
        lead3.LeanData__Routing_Status__c = 'not processed';
        lead3.LastName='Testing3';
        lead3.Company='Test 16.10.18';
        lead3.Orchestration_Journey__c='Standard';
        lead3.Email = 'testLead@gmail.com3';
        insert lead3;
        
        Lead lead4 = new Lead();
        lead4.Sent_to_Polygraph__c = DateTime.now().addHours(-2);
        lead4.Polygraph_Update_Timestamp__c =  DateTime.now().addHours(-1).addMinutes(-50);
        lead4.Clearbit_Timestamp__c=Datetime.now().addMinutes(-30);       
        lead4.SW_Fit_Score_Timestamp__c=DateTime.now().addMinutes(-30);
        lead4.First_Behavioral_Rate_Timestamp__c=DateTime.now().addMinutes(-25);
        lead4.Business_unit_timestamp__c=DateTime.now().addMinutes(-20);
        lead4.First_MQL_Calc__c=DateTime.now().addMinutes(-15);
        lead4.LeanData__Reporting_Timestamp__c=DateTime.now().addMinutes(-10);
        lead4.Journey_Completed_Timestamp__c=DateTime.now().addMinutes(-5);
        lead4.LastName='Testing4';
        lead4.Company='Test 16.10.18';
        lead4.Orchestration_Journey__c='Standard';
        lead4.LeanData__Routing_Action__c ='aaa';
        lead4.LeanData__Routing_Status__c='routed';
        lead4.Email = 'testLead@gmail.com4';
        insert lead4;
    }
    
	@isTest
    public static void obtainJorneySettingListTest(){
        String settingSet = JourneyController.obtainJorneySettingList();
        //System.assertEquals('["Standard","Fast Track","LDR"]', settingSet);
    }
    
    @isTest
    public static void obtainLeadListTest(){
        String leadList = JourneyController.obtainLeadList('Standard','Completed Journey',false);
        Map<String,Object> leadMap = (Map<String,Object>) JSON.deserializeUntyped(leadList);
        //System.assertEquals(leadMap.get('success'), true);
		Map<String,Object> data = (Map<String,Object>) leadMap.get('data');       
        //System.assertEquals(data.get('step'), 'Completed Journey');
        //System.assertEquals(data.get('journeyName'), 'Standard');
        //System.debug('leads ' +data.get('leads'));
        //System.assertEquals(data.get('queue'), 3);        
    }
    
    @isTest
    public static void obtainPathAtributesTest(){
        String pathAttributes = JourneyController.obtainPathAtributes('Standard');
        Map<String,Object> pathAttributesMap = (Map<String,Object>) JSON.deserializeUntyped(pathAttributes);
        //System.assertEquals(pathAttributesMap.get('success'), true);
        Map<String,Object> data = (Map<String,Object>) pathAttributesMap.get('data');
        List<Object> steps = (List<Object>) data.get('steps'); 
        //System.assertEquals(steps.size(),13);
    }
    
    @isTest
    public static void obtainLeadListByParamTest(){
        String pathAttributes = JourneyController.obtainLeadListByParam('Testing1','Name');
        Map<String,Object> pathAttributesMap = (Map<String,Object>) JSON.deserializeUntyped(pathAttributes);
        //System.assertEquals(pathAttributesMap.get('success'), true);
        pathAttributes = JourneyController.obtainLeadListByParam('Testing2','Name');
        pathAttributesMap = (Map<String,Object>) JSON.deserializeUntyped(pathAttributes);
        //System.assertEquals(pathAttributesMap.get('success'), true);
        pathAttributes = JourneyController.obtainLeadListByParam('Testing3','Name');
        pathAttributesMap = (Map<String,Object>) JSON.deserializeUntyped(pathAttributes);
        //System.assertEquals(pathAttributesMap.get('success'), true);
    }
    
    @isTest
    public static void obtainJourneyPathSettingsTest(){
        String result = JourneyController.obtainJourneyPathSettings('Standard');
        Map<String,Object> pathAttributesMap = (Map<String,Object>) JSON.deserializeUntyped(result);
        //System.assertEquals(pathAttributesMap.get('success'), true);
        List<Object> data = (List<Object>) pathAttributesMap.get('data');
        //System.assertEquals(data.size(),13);   
    }
    
    @isTest
    public static void updateJourneyPathSettingsTest(){
        Journey_Path_Setting__c test = new Journey_Path_Setting__c();
        test.Name='test';
        test.Journey_Name__c='Standard test';
        test.Step_Name__c='t-t-t-test';
        test.Step_Order__c=4;
        test.Active__c=true;
        insert test;
        test.Active__c=false;
        List<Journey_Path_Setting__c> testSettings = new  List<Journey_Path_Setting__c>();
        testSettings.add(test);
        JourneyController.updateJourneyPathSettings(testSettings);
        Journey_Path_Setting__c actual =  [SELECT Id,Active__c FROM Journey_Path_Setting__c WHERE Name='test' LIMIT 1];
        //System.assertEquals(false, actual.Active__c);
    }
}
@isTest
global class OppClosedLostFlowControllerTest {
    
    @testSetup
    global static void testSetup(){
        OppClosedLostReasonSettings__c setting1 = new OppClosedLostReasonSettings__c();
        setting1.Name = '1';
        setting1.Description__c = 'No relationship with decision making authority';
        setting1.Group_Name__c = 'Relationship';
        insert setting1;
        
        OppClosedLostReasonSettings__c setting2 = new OppClosedLostReasonSettings__c();
        setting2.Name = '2';
        setting2.Description__c = 'We started the renewal process too late';
        setting2.Group_Name__c = 'Relationship';
        insert setting2;
        
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
        
//        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
//        currentSettings.API_Key__c='test';
//        currentSettings.Create_Date_TimeFrame__c='test';
//        currentSettings.Enriched_Entities__c='[]';
//        currentSettings.Invisible_Fields__c='test';
//        currentSettings.Refresh_Data_Interval__c=0;
//        currentSettings.Sync_on_create_and_update__c=true;
//        insert currentSettings;
    }
    
    @isTest
    global static void getOpportunityDetailsTest() {
        Account acc = new Account(Name='acc');
        insert acc;
        Contact contact = new Contact(LastName='contactovich',AccountId = acc.Id,Department__c= 'eCommerce',Email='test@gmail.com');
        insert contact;
        Opportunity opp = new Opportunity(Name='opp',StageName = 'Prospect',CloseDate=Date.today().addDays(1), AccountId = acc.Id,Use_Cases__c='Marketing: SEO / Content',Closed_Lost_Reason__c='Privacy',
                                         Closed_Lost_Reason_More_details__c='test',Opp_will_be_relevant__c='Not relevant');
        insert opp;        
        Test.startTest();
        Response response = OppClosedLostFlowController.getOpportunityDetails(opp.Id);
        OppClosedLostFlowController.getOpportunityDetails('Id');
        Test.stopTest();
        System.assertEquals(true, response.success);
        //System.assertEquals('{"solutionFit":["eCommerce"],"opportunity":{"attributes":{"type":"Opportunity","url":"/services/data/v43.0/sobjects/Opportunity/'+ opp.id +'"},"Id":"'+ opp.id +'","AccountId":"'+ acc.id +'","Account":{"attributes":{"type":"Account","url":"/services/data/v43.0/sobjects/Account/'+ acc.id +'"},"Id":"'+ acc.id +'","Name":"acc"}}}', Json.serialize(response.content));
    }	
    
    @isTest
    global static void getPicklistFieldsDetailsTest() {        
        Account acc = new Account(Name='acc');
        insert acc;
        Contact contact = new Contact(LastName='contactovich',AccountId = acc.Id,Department__c= 'eCommerce',Email='test@gmail.com');
        List<Map<String,List<String>>> testList = new List<Map<String,List<String>>>();
        testList.add(new Map<String,List<String>>{'Contact' => new List<String>{'Department__c'}});
        testList.add(new Map<String,List<String>>{'Opportunity' => new List<String>{'Closed_Lost_Reason__c'}});
        Test.startTest();
        Response response = OppClosedLostFlowController.getPicklistFieldsDetails(JSON.serialize(testList));
        OppClosedLostFlowController.getPicklistFieldsDetails('contactJson');
        Test.stopTest();
        //System.assertEquals(true, response.success);
        //System.assertEquals('{"Opportunity":{"Closed_Lost_Reason__c":[{"reasonName":"No relationship with decision making authority","ordinalNumb":1,"groupName":"Relationship"},{"reasonName":"We started the renewal process too late","ordinalNumb":2,"groupName":"Relationship"}]},"Contact":{"Department__c":[{"value":"eCommerce","label":"eCommerce"},{"value":"Other","label":"Other"},{"value":"Account Management / Customer Success","label":"Account Management / Customer Success"},{"value":"BI / Analytics","label":"BI / Analytics"},{"value":"Corporate Development / Mergers and Acquisitions","label":"Corporate Development / Mergers and Acquisitions"},{"value":"Investment","label":"Investment"},{"value":"Management (C-Level)","label":"Management (C-Level)"},{"value":"Marketing: Affiliate / Media Buying","label":"Marketing: Affiliate / Media Buying"},{"value":"Marketing: Management / General","label":"Marketing: Management / General"},{"value":"Marketing: PPC / Display","label":"Marketing: PPC / Display"},{"value":"Marketing: PR / Comms / Social Media","label":"Marketing: PR / Comms / Social Media"},{"value":"Marketing: SEO / Content","label":"Marketing: SEO / Content"},{"value":"Product Management","label":"Product Management"},{"value":"Sales / Business Development","label":"Sales / Business Development"},{"value":"Sales Operations","label":"Sales Operations"},{"value":"Strategy / Market Research","label":"Strategy / Market Research"}]}}',JSON.serialize(response.content));
    }	
    
    @isTest
    global static void submitOpportunityTest() {
        Account acc = new Account(Name='acc');
        insert acc;
        Opportunity opp = new Opportunity(Name='opp',StageName = 'Prospect',CloseDate=Date.today().addDays(1),AccountId = acc.Id,Use_Cases__c='Marketing: SEO / Content',Closed_Lost_Reason__c='Privacy',
                                         Closed_Lost_Reason_More_details__c='test',Opp_will_be_relevant__c='Not relevant');
        insert opp;  
        Test.startTest();
        Response response = OppClosedLostFlowController.submitOpportunity(Json.serialize(opp));
        OppClosedLostFlowController.submitOpportunity('opp');
        Test.stopTest();
        System.assertEquals(true, response.success);
        Integer d = Date.today().addDays(1).day();
        Integer mo = Date.today().addDays(1).month();
        Integer yr = Date.today().addDays(1).year();     
        DateTime dt = DateTime.newInstance(yr, mo, d);
        //System.assertEquals('{"attributes":{"type":"Opportunity","url":"/services/data/v43.0/sobjects/Opportunity/'+ opp.id +'"},"Closed_Lost_Reason__c":null,"AccountId":"'+ acc.id +'","StageName":"Closed Lost","Closed_Lost_Reason_2__c":"Test","Id":"'+ opp.id +'","CloseDate":"'+ dt.format('yyyy-MM-dd') + '","Name":"opp"}',JSON.serialize(response.content));
    }	    
    
    
    @isTest
    global static void closeOpportunityTest() {        
        Test.startTest();
        OppClosedLostFlowController.closeOpportunity('opport');
        Test.stopTest();
    }	
}
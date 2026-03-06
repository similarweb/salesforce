@isTest
public class InferredSolutionHandlerTest {
    
     @testSetup
    static void setup(){
        User u = [SELECT Id FROM User WHERE Id !=:UserInfo.getUserId() LIMIT 1];
        
        Pardot_Data_Manipulation_Setting__c pdms1 = new Pardot_Data_Manipulation_Setting__c();
		pdms1.Name = 'JUNK_LEAD_OWNER_ID';
		pdms1.Value__c = u.Id;
		insert pdms1;
        
        Pardot_Data_Manipulation_Setting__c pdms11 = new Pardot_Data_Manipulation_Setting__c();
		pdms11.Name = 'LDR_LEAD_OWNER_ID';
		pdms11.Value__c = u.Id;
		insert pdms11;
        
         Pardot_Data_Manipulation_Setting__c pdms111 = new Pardot_Data_Manipulation_Setting__c();
		pdms111.Name = 'FRENEMY_LEAD_OWNER_ID';
		pdms111.Value__c = u.Id;
		insert pdms111;
        
        Pardot_Data_Manipulation_Setting__c pdms2 = new Pardot_Data_Manipulation_Setting__c();
		pdms2.Name = 'FRENEMY_FLOW_MINUTES';
		pdms2.Value__c = '2';
		insert pdms2;
        
        Polygraph_Interaction_Setting__c pis = new Polygraph_Interaction_Setting__c();
		pis.Name = 'Token_Password';
		pis.Value__c = '00000000000000000000000000000000';
		insert pis;
        
        Polygraph_Interaction_Setting__c pis2 = new Polygraph_Interaction_Setting__c();
		pis2.Name = 'UserKey';
		pis2.Value__c = 'test';
		insert pis2;
        
        Polygraph_Interaction_Setting__c pis3 = new Polygraph_Interaction_Setting__c();
		pis3.Name = 'Endpoint';
		pis3.Value__c = 'https://polygraph-test.similarweb.io/api/test';
		insert pis3;
        
        List<LDR_Criteria_Settings__c> lcsList = new List<LDR_Criteria_Settings__c>();
        List<String> cr = new List<String>{'Company_LDR_Compare__c=False','Country_LDR_Compare__c=FALSE','Email domain type = Private','Is null (Company)','Is null (Country)','Is null (Email)','Is null (Employee Min)','Is null (FirstName)','Is null (Industry)','Is null (Phone)','Is null (Title)','Is null (Website)',
'LeadSource != NULL','LeadSource not contains Outbound','LeadSource!= Deal Registration','Not(Country=Japan)'};
        for(String str : cr){
            LDR_Criteria_Settings__c lcs = new LDR_Criteria_Settings__c();
            lcs.Name=str;
            lcs.Enabled__c=true;
            lcsList.add(lcs) ;
        }       
        insert lcsList;
        
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
        
        TestDataFactory.createSimilarWeb_CS();
    }
    
    @isTest
    public static void leadTest(){
        Test.startTest();            
        Lead testLead = new Lead(LastName='Test',Company='Test',SW_Industry__c='AdTech and AdNetwork',Department__c	='eCommerce', Email='test@email.com');
        insert testLead;
        testLead.SW_Industry__c = 'Education';
        update testLead;
        
        Account acc = new Account(Name = 'Test', Business_Unit__c = 'Inside Sales',SW_Industry__c='AdTech and AdNetwork');
        insert acc;     
        
        Contact cnt = new Contact(LastName='Contact', FirstName = 'Test', Email = 'test@11mail.com', AccountId = acc.Id,Department__c	='eCommerce');        
        insert cnt;
        cnt.Department__c='BI / Analytics';
        update cnt;
        Test.stopTest();
    }
    
    /*@isTest
    public static void contactTest(){
        
        Test.startTest();
        Account acc = new Account(Name = 'Test', Business_Unit__c = 'Inside Sales',SW_Industry__c='AdTech and AdNetwork');
        insert acc;     
        
        Contact cnt = new Contact(LastName='Contact', FirstName = 'Test', Email = 'test@11mail.com', AccountId = acc.Id,Department__c	='eCommerce');        
        insert cnt;
        cnt.Department__c='BI / Analytics';
        update cnt;
        Test.stopTest();
    }*/

}
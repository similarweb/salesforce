/*
 * @Update 2020-11-27
 * 
 * @Author: ZedXagE 
 * @Date: 2019-02-28 14:12:30 
 * @Last Modified by:   ZedXagE 
 * @Last Modified time: 2019-02-28 14:12:30 
 */

@isTest
public class ZCampaignAutomationTest {
	@testSetup
	static void setup(){
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

	static testMethod void tes() {
		Test.setMock(HttpCalloutMock.class, new NewBiApiMockImp());
		RecordType accountRecordType = [SELECT Id FROM RecordType WHERE Name = 'Default'][0];

		Account acc = new Account(RecordType = accountRecordType, Name = 'Test', Business_Unit__c = 'Inside Sales');
		insert acc;

		Contact cnt = new Contact
				(
						LastName='Contact',
						FirstName = 'Test',
						Email = 'test@11mail.com',
						AccountId = acc.Id
				);

		insert cnt;

		Lead lead1 = new Lead(
				LastName='Test 1',
				Company='Test comp',
				LeadSource='MIR',
				Employees_Min__c=300,
				Country_Code__c='IR',
				Email='test@gmail.com',
				New_Behavioral_Rate__c=1,
				SW_Fit_Score__c='A',
				Business_Unit__c='A',
				OwnerID=FunelMonitorHandler.JOURNEY_OLD_OWNER_ID
		);

		insert lead1;

		insert new Website_SF_Associated_Campaign__c(Name='1test',Website__c='testlddict1', Campaign__c='testld1');
		Lead ld = [select id from Lead where isConverted=false limit 1];
		Contact con = [select id from Contact limit 1];
		List <ZCampaignAutomation.objcheck> objs = new List <ZCampaignAutomation.objcheck>();
		//create Webinar Recorded
		objs.add(new ZCampaignAutomation.objcheck('Lead', ld.id, 'Webinar Recorded', 'testld1'));
		objs.add(new ZCampaignAutomation.objcheck('Contact', con.id, 'Webinar Recorded', 'testcon1'));
		//create Report
		objs.add(new ZCampaignAutomation.objcheck('Lead', ld.id, 'Report', 'testld2'));
		objs.add(new ZCampaignAutomation.objcheck('Contact', con.id, 'Report', 'testcon2'));
		//create Zoom Registered
		objs.add(new ZCampaignAutomation.objcheck('Lead', ld.id, 'Zoom Registered', 'testld3'));
		objs.add(new ZCampaignAutomation.objcheck('Contact', con.id, 'Zoom Registered', 'testcon3'));
		ZCampaignAutomation.Handler(objs);
		objs.clear();
		//update Webinar Recorded
		objs.add(new ZCampaignAutomation.objcheck('Lead', ld.id, 'Webinar Recorded', 'testlddict1'));
		objs.add(new ZCampaignAutomation.objcheck('Contact', con.id, 'Webinar Recorded', 'testcon1'));
		//update Report
		objs.add(new ZCampaignAutomation.objcheck('Lead', ld.id, 'Report', 'testld2'));
		objs.add(new ZCampaignAutomation.objcheck('Contact', con.id, 'Report', 'testcon2'));
		//update Zoom Attended
		objs.add(new ZCampaignAutomation.objcheck('Lead', ld.id, 'Zoom Attended', 'testld3'));
		objs.add(new ZCampaignAutomation.objcheck('Contact', con.id, 'Zoom Attended', 'testld3'));
		ZCampaignAutomation.Handler(objs);
		Campaign camp = [select id,Status from Campaign where name='testld3' limit 1];
		camp.Status = 'Completed';
		update camp;
	}
}
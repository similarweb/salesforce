public with sharing class LeadGroudonHandler implements GroudonQueueable.GroudonHandler {
	private List<Lead> leadList;
	private Boolean isBulk = false;

	public LeadGroudonHandler(List<Lead> leadList){
		this.leadList = leadList;
	}

	public LeadGroudonHandler(List<Lead> leadList,Boolean isBulk){
		this.leadList = leadList;
		this.isBulk = isBulk;
	}

	public void process() {
		List<Log_Event__e> eventList = new List<Log_Event__e>();
		boolean needToUpdateLeads = false;
		API_Configuration__mdt apiConfiguration = GeneralUtil.getAPIConfig('Groudon_Integration');

		GroudonIntegrationService groudonService = new GroudonIntegrationService(
				new LeadGroudonRequestGenerator(),
				new LeadGroudonResponseGenerator(),
				apiConfiguration);

		try{
			if(this.isBulk){
				GroudonIntegrationService.GroudonResponse response = groudonService.callGroudonBulk(this.leadList);
				for(Lead leadItem : this.leadList){
					fillLog(leadItem, response, eventList);
				}
			}else{
				for(Lead leadItem : this.leadList){
					GroudonIntegrationService.GroudonResponse response = groudonService.callGroudon(leadItem);
					fillLog(leadItem,response,eventList);
				}
			}
		}catch(Exception ex){
			Log_Event__e log = new Log_Event__e();
			log.Email__c = this.isBulk ? 'mass update' : this.leadList.isEmpty() ? 'no leads' : this.leadList[0].Email;
			log.Apex_class__c = 'GroudonIntegrationService';
			log.Apex_Method__c = 'callGroudon';
			log.Record_Ids__c = this.isBulk ? 'mass update' : this.leadList.isEmpty() ? 'no leads' : this.leadList[0].id;
			log.Log_Type__c = 'Error';
			log.Http_Body__c = 'no payload available';
			log.Detailed_Error_Message__c = ex.getMessage() + ' ' + ex.getStackTraceString();
			log.SF_Type__c = 'Lead';
			eventList.add(log);

		}
		needToUpdateLeads = true;
		List<Lead> leadAfterLambdaCallout = [SELECT Id, Groudon_Timestamp__c FROM Lead WHERE Id IN : this.leadList];
		for (Lead leadItem : leadAfterLambdaCallout) {
			leadItem.Force_Enrichment__c = false;
			leadItem.Groudon_Call_Status__c = 'Enrichment_Ended';
			leadItem.Groudon_Timestamp__c = Datetime.now();
		}
		if (!eventList.isEmpty()) {
			Eventbus.publish(eventList);
		}
		if(needToUpdateLeads){
			update leadAfterLambdaCallout;
		}
	}

	private void fillLog(Lead leadItem, GroudonIntegrationService.GroudonResponse response, List<Log_Event__e> eventList) {
		Log_Event__e log = new Log_Event__e();
		log.Email__c = leadItem.email;
		log.Apex_Method__c = this.isBulk ?  'callGroudonBulk' : 'callGroudonSingle';
		log.Apex_class__c = 'GroudonIntegrationService';
		log.Record_Ids__c = leadItem.id;
		log.Log_Type__c = response.isSuccess ? 'Info' : 'Error';
		log.Http_Body__c = response.leadIdToBodyMap.get(leadItem.Id);
		log.Sub_Type__c = 'callGroudon';
		log.SF_Type__c = 'Lead';
		eventList.add(log);
	}

	public class LeadGroudonRequestGenerator implements GroudonQueueable.GroudonRequestGenerator {
		public GroudonIntegrationService.GroudonRequest generate(SObject record) {
			Lead leadItem = (Lead) record;

			GroudonIntegrationService.GroudonRequest requestBody = new GroudonIntegrationService.GroudonRequest();

			requestBody.first_name = leadItem.FirstName;
			requestBody.last_name = leadItem.LastName;
			requestBody.domain = leadItem.Domain__c;
			requestBody.Country_Code = leadItem.CountryCode;
			requestBody.Department_C = leadItem.Department__c;
			requestBody.Department_Other_Description = leadItem.Department_Other_Description__c;
			requestBody.email = leadItem.Email;
			requestBody.linkedin_profile = leadItem.Linkedin_Profile__c;
			requestBody.Seniority = leadItem.Seniority__c;
			requestBody.industry = leadItem.SW_Industry__c;
			requestBody.job_title = leadItem.Title;
			requestBody.Industry_Other_Description = leadItem.Industry_Other_Description__c;
			requestBody.Title_Other_Description = leadItem.Title_Other_Description__c;
			requestBody.Pre_mapped_industry = leadItem.Pre_mapped_industry__c;
			requestBody.Pre_Mapped_Title = leadItem.Pre_Mapped_Title__c;
			requestBody.website = leadItem.Website;
			requestBody.Business_Unit = leadItem.Business_Unit__c;
			requestBody.Clean_Domain = leadItem.Clean_Domain__c;
			requestBody.country = leadItem.country;
			requestBody.Email_address_domain_type = leadItem.Email_address_domain_type__c;
			requestBody.Employees_Min = leadItem.Employees_Min__c;
			requestBody.Lugia_Fit_Score = leadItem.Lugia_Fit_Score__c;
			requestBody.LinkedIn = leadItem.LinkedIn__c;
			requestBody.Lugia_Linkedin_Profile = leadItem.Lugia_Linkedin_Profile__c;
			requestBody.MIR_Status = leadItem.MIR_Status__c;
			requestBody.Quiz_Data_Incomplete = leadItem.Quiz_Data_Incomplete__c;
			requestBody.ROE_Division = leadItem.ROE_Division__c;
			requestBody.SI_Enrichment_Visits = leadItem.SI_Enrichment_Visits__c;
			requestBody.Strategic_Pod = leadItem.Strategic_Pod__c;
			requestBody.title = leadItem.title;
			requestBody.Use_of_Similarweb = leadItem.Use_of_Similarweb__c;
			requestBody.first_name = leadItem.FirstName;
			requestBody.last_name = leadItem.LastName;
			requestBody.Company = leadItem.Company;
			requestBody.SW_Fit_Score_Reason = leadItem.SW_Fit_Score_Reason__c;
			requestBody.Fit_Score_Test = leadItem.Fit_Score_Test__c;
			requestBody.Lugia_Fit_Score_Reasoning = leadItem.Lugia_Fit_Score_Reasoning__c;
			requestBody.Lugia_Employees_Count = leadItem.Lugia_Employees_Count__c;
			requestBody.sf_id = leadItem.Id;
			requestBody.timestamp = Datetime.now();
			requestBody.clientIp = leadItem.clientIp__c;
			requestBody.sf_type = 'Lead';
			requestBody.Registration_Type = leadItem.Registration_Type__c;
			requestBody.LeadSource = leadItem.LeadSource;

			return requestBody;
		}
	}

	public class LeadGroudonResponseGenerator implements GroudonQueueable.GroudonResponseGenerator {
		public GroudonIntegrationService.GroudonResponse generate(List<GroudonIntegrationService.GroudonRequest> requestBodies) {
			GroudonIntegrationService.GroudonResponse groudonResponse = new GroudonIntegrationService.GroudonResponse();

			for (GroudonIntegrationService.GroudonRequest r : requestBodies) {
				groudonResponse.leadIdToBodyMap.put(r.sf_id ,JSON.serializePretty(r,true));
			}

			return groudonResponse;
		}
	}
}
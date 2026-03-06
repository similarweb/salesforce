public with sharing class ContactGroudonHandler implements GroudonQueueable.GroudonHandler {
	public List<Contact> contacts;

	public ContactGroudonHandler(Contact c) {
		this.contacts = new List<Contact>{c};
	}

	public ContactGroudonHandler(List<Contact> contacts){
		this.contacts = contacts;
	}

	public void process() {
		List<Log_Event__e> eventList = new List<Log_Event__e>();
		API_Configuration__mdt apiConfiguration = GeneralUtil.getAPIConfig('Groudon_Integration');

		GroudonIntegrationService groudonService = new GroudonIntegrationService(
				new ContactGroudonRequestGenerator(),
				new ContactGroudonResponseGenerator(),
				apiConfiguration);

		try{
			GroudonIntegrationService.GroudonResponse response = this.contacts.size() > 1 ?
																 groudonService.callGroudonBulk(this.contacts) :
																 groudonService.callGroudon(this.contacts.get(0));

			for(Contact c : this.contacts){
				fillLog(c, response, eventList);
			}
		}catch(Exception ex){
			Log_Event__e log = new Log_Event__e();
			log.Email__c = this.contacts.size() > 1 ? 'mass update' : this.contacts.isEmpty() ? 'no leads' : this.contacts[0].Email;
			log.Apex_class__c = 'GroudonIntegrationService';
			log.Apex_Method__c = 'callGroudon';
			log.Record_Ids__c = this.contacts.size() > 1 ? 'mass update' : this.contacts.isEmpty() ? 'no leads' : this.contacts[0].id;
			log.Log_Type__c = 'Error';
			log.Http_Body__c = 'no payload available';
			log.Detailed_Error_Message__c = ex.getMessage() + ' ' + ex.getStackTraceString();
			log.SF_Type__c = 'Contact';
			eventList.add(log);

		}
		List<Contact> contactsAfterLambdaCallout = [SELECT Id FROM Contact WHERE Id IN: this.contacts];
		for (Contact c : contactsAfterLambdaCallout) {
			c.Force_Enrichment__c = false;
			c.Groudon_Timestamp__c = Datetime.now();
			c.Groudon_Call_Status__c = 'Enrichment_Ended';
		}

		if (!eventList.isEmpty()) {
			Eventbus.publish(eventList);
		}

		update contactsAfterLambdaCallout;
	}

	private void fillLog(Contact c, GroudonIntegrationService.GroudonResponse response, List<Log_Event__e> eventList) {
		Log_Event__e log = new Log_Event__e();
		log.Email__c = c.email;
		log.Apex_Method__c = this.contacts.size() > 0 ?  'callGroudonBulk' : 'callGroudonSingle';
		log.Apex_class__c = 'GroudonIntegrationService';
		log.Record_Ids__c = c.id;
		log.Log_Type__c = response.isSuccess ? 'Info' : 'Error';
		log.Http_Body__c = response.leadIdToBodyMap.get(c.Id);
		log.Sub_Type__c = 'callGroudon';
		log.SF_Type__c = 'Contact';
		eventList.add(log);
	}

	public class ContactGroudonRequestGenerator implements GroudonQueueable.GroudonRequestGenerator {
		public GroudonIntegrationService.GroudonRequest generate(SObject record) {
			Contact contactItem = (Contact) record;

			GroudonIntegrationService.GroudonRequest requestBody = new GroudonIntegrationService.GroudonRequest();

			requestBody.first_name = contactItem.FirstName;
			requestBody.last_name = contactItem.LastName;
			requestBody.domain = contactItem.Website__c;
			requestBody.Country_Code = contactItem.MailingCountryCode;
			requestBody.Department_C = contactItem.Department__c;
			requestBody.Department_Other_Description = contactItem.Department_Other_Description__c;
			requestBody.email = contactItem.Email;
			requestBody.linkedin_profile = contactItem.Linkedin_Profile__c;
			requestBody.Seniority = contactItem.Seniority__c;
			requestBody.industry = contactItem.SW_Industry__c;
			requestBody.job_title = contactItem.Title;
			requestBody.Industry_Other_Description = contactItem.Industry_Other_Description__c;
			requestBody.Title_Other_Description = contactItem.Title_Other_Description__c;
			requestBody.Pre_mapped_industry = contactItem.Pre_mapped_industry__c;
			requestBody.Pre_Mapped_Title = contactItem.Pre_Mapped_Title__c;
			requestBody.website = contactItem.Website__c;
			requestBody.Business_Unit = contactItem.Business_Unit__c;
			requestBody.Clean_Domain = contactItem.Clean_Domain__c;
			requestBody.country = contactItem.MailingCountry;
			requestBody.Email_address_domain_type = contactItem.Email_address_domain_type__c;
			requestBody.Employees_Min = contactItem.Employees_Min__c;
			requestBody.Lugia_Fit_Score = contactItem.Lugia_Fit_Score__c;
			requestBody.LinkedIn = contactItem.LinkedIn_Profile__c;
			requestBody.Lugia_Linkedin_Profile = contactItem.Lugia_Linkedin_Profile__c;
			requestBody.MIR_Status = contactItem.MIR_Status__c;
			requestBody.Quiz_Data_Incomplete = contactItem.Quiz_Data_Incomplete__c;
			requestBody.ROE_Division = contactItem.ROE_Division__c;
			requestBody.SI_Enrichment_Visits = contactItem.SI_Enrichment_Visits__c;
			requestBody.Strategic_Pod = contactItem.Strategic_Pod__c;
			requestBody.title = contactItem.title;
			requestBody.Use_of_Similarweb = contactItem.Use_of_Similarweb__c;
			requestBody.first_name = contactItem.FirstName;
			requestBody.last_name = contactItem.LastName;
			requestBody.Company = contactItem.Account_name__c;
			requestBody.SW_Fit_Score_Reason = contactItem.SW_Fit_Score_Reason__c;
			requestBody.Fit_Score_Test = contactItem.Fit_Score_Test__c;
			requestBody.Lugia_Fit_Score_Reasoning = contactItem.Lugia_Fit_Score_Reasoning__c;
			requestBody.Lugia_Employees_Count = contactItem.Lugia_Employees_Count__c;
			requestBody.sf_id = contactItem.Id;
			requestBody.timestamp = Datetime.now();
			// requestBody.clientIp = contactItem.clientIp__c;
			requestBody.sf_type = 'Contact';
			requestBody.Registration_Type = contactItem.Registration_Type__c;
			requestBody.LeadSource = contactItem.LeadSource;

			return requestBody;
		}
	}

	public class ContactGroudonResponseGenerator implements GroudonQueueable.GroudonResponseGenerator {
		public GroudonIntegrationService.GroudonResponse generate(List<GroudonIntegrationService.GroudonRequest> requestBodies) {
			GroudonIntegrationService.GroudonResponse groudonResponse = new GroudonIntegrationService.GroudonResponse();

			for (GroudonIntegrationService.GroudonRequest r : requestBodies) {
				groudonResponse.contactIdToBodyMap.put(r.sf_id ,JSON.serializePretty(r,true));
			}

			return groudonResponse;
		}
	}
}
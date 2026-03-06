public with sharing class RecordIFrameController {
	@AuraEnabled(cacheable = false)
	public static String getData(String recordId) {
		String iframeUrl = '';

		if (recordId.startsWith('001')) {
			iframeUrl += 'https://eevee.int.similarweb.io/agent/salesforce-contract-?salesforce_url=' +
					     System.Url.getOrgDomainUrl().toExternalForm() +
						 '/lightning/r/Account/' + recordId + '/view';
		} else {
			Lead l = [SELECT Id, Website, LinkedIn_Profile__c, CountryCode, Title FROM Lead WHERE Id =: recordId];
			if (l.Website == 'no_website' || String.isBlank(l.Website)) {
				l.Website = 'N/A';
			}
			if (String.isBlank(l.LinkedIn_Profile__c)) {
				l.LinkedIn_Profile__c = 'N/A';
			}
			if (String.isBlank(l.CountryCode)) {
				l.CountryCode = 'N/A';
			}
			if (l.LinkedIn_Profile__c == 'N/A' && String.isNotBlank(l.Title)) {
				l.LinkedIn_Profile__c = l.Title;
			}
			iframeUrl += 'https://eevee.int.similarweb.io/agent/draft---30-second-pe?company_domain=' + l.Website + '&linkedin_url=' + l.LinkedIn_Profile__c + '&country=' + l.CountryCode;
		}

		return iframeUrl;
	}
}
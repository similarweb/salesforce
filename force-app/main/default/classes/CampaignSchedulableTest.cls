@IsTest
public class CampaignSchedulableTest {
	@IsTest
	static void testSchedulableAndBatchable() {
		TestDataFactory.createInferredSolutionSettings_CS();

		List<Campaign> campaigns = new List<Campaign>();
		for (Integer i = 0; i < 2; i++) {
			campaigns.add(new Campaign(Name = 'Test Campaign ' + i, Update_Campaign_Members__c = true));
		}
		insert campaigns;

		Lead l = TestObjectCreator.CreateLead();
		l.country = 'Israel';
		insert l;
		Contact c = new Contact(LastName = 'Test Contact', Email='test@gmail.com');
		insert c;

		List<CampaignMember> members = new List<CampaignMember>();
		for (Campaign camp : campaigns) {
			members.add(new CampaignMember(CampaignId = camp.Id, LeadId = l.Id));
			members.add(new CampaignMember(CampaignId = camp.Id, ContactId = c.Id));
		}
		insert members;

		Test.startTest();
		new CampaignSchedulable().execute(null);
		Test.stopTest();

		List<Campaign> updatedCampaigns = [SELECT Id, Update_Campaign_Members__c FROM Campaign WHERE Id IN :campaigns];
		for (Campaign camp : updatedCampaigns) {
			System.assertEquals(false, camp.Update_Campaign_Members__c, 'Campaign flag should be reset');
		}

		List<CampaignMember> updatedMembers = [SELECT Id, Campaign_Description__c FROM CampaignMember WHERE Id IN :members];
		for (CampaignMember m : updatedMembers) {
			System.assert(m.Campaign_Description__c == null || m.Campaign_Description__c == '',
					'Campaign_Description__c should be set or empty');
		}

		Lead updatedLead = [SELECT Id, Campaign_Description__c FROM Lead WHERE Id = :l.Id];
		Contact updatedContact = [SELECT Id, Campaign_Description__c FROM Contact WHERE Id = :c.Id];
		System.assert(updatedLead.Campaign_Description__c == null || updatedLead.Campaign_Description__c == '',
				'Lead Campaign_Description__c should be set or empty');
		System.assert(updatedContact.Campaign_Description__c == null ||
						updatedContact.Campaign_Description__c == '',
				'Contact Campaign_Description__c should be set or empty');

	}
}
public class CampaignSchedulable implements Schedulable {
	public void execute(SchedulableContext param1) {
		Map<String, Campaign> campaigns = new Map<String, Campaign>([
				SELECT Id, Update_Campaign_Members__c
				FROM Campaign
				WHERE Update_Campaign_Members__c = true
		]);

		Database.executeBatch(new CampaignBatchable(campaigns.keyset()), 500);
	}
}
public with sharing class NoTouchProcessRetry implements Database.Batchable<NoTouch_API_log__c>, Database.Stateful {
	private Integer numberOfDays;
	private Set<Id> accountIds;

	public NoTouchProcessRetry(Integer numberOfDays) {
		this.numberOfDays = numberOfDays;
	}

	public void manualRetry(Integer numberOfDays, Integer sizeLimit) {
//		Database.executeBatch(new NoTouchProcessRetry(7), 3);
		List<NoTouch_API_log__c> scope = [
				SELECT Id, Request_Paramets__c, hasException__c
				FROM NoTouch_API_log__c
				WHERE hasException__c = true AND CreatedDate >=: Date.today().addDays(-numberOfDays)
				LIMIT :sizeLimit
		];

		processLogs(scope);
	}

	public void manualRetryBatch(Integer numberOfDays) {
		Database.executeBatch(new NoTouchProcessRetry(numberOfDays), 3);
	}


	public Iterable<NoTouch_API_log__c> start(Database.BatchableContext param1) {
		return [
				SELECT Id, Request_Paramets__c, hasException__c
				FROM NoTouch_API_log__c
				WHERE hasException__c = true AND CreatedDate >=: Date.today().addDays(-numberOfDays)
		];
	}

	public void execute(Database.BatchableContext param1, List<NoTouch_API_log__c> scope) {
		this.processLogs(scope);
	}

	public void finish(Database.BatchableContext param1) {
		system.enqueueJob(new UpdateMarketingPersonaQueueable(this.accountIds));
	}

	private void processLogs(List<NoTouch_API_log__c> scope) {
		for (NoTouch_API_log__c log : scope) {
			if (String.isBlank(log.Request_Paramets__c)) {
				continue;
			}

			NoTouchProcess noTouchProcess = new NoTouchProcess();

			try {
				Map<String, String> input = (Map<String, String>) JSON.deserialize(log.Request_Paramets__c, Map<String, String>.class);

				String accountId = noTouchProcess.handleNoTouch(
						input.get('uid'),
						input.get('email'),
						input.get('cname'),
						input.get('Fname'),
						input.get('Lname'),
						input.get('uid'),
						input.get('websiteDomain'),
						input.get('industry'),
						input.get('minEmployees'),
						input.get('maxEmployees'),
						input.get('NT_Subscription_FirstCharge_Date'),
						0
				);

				if (Services.validateSfAccountId(accountId)) {
					log.hasException__c = false;
					String jsonResponse = '{"response": {"status": "Success", "message": "", "accountId": "' + accountId + '", "retry": true, "logId": "' + log.Id + '" }}';
					noTouchProcess.recordLog(true, jsonResponse, accountId);
					this.accountIds.add(accountId);
				}
			} catch (Exception e) {

			}
		}

		Database.update(scope, false);
	}
}
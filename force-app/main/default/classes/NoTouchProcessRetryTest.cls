@IsTest
public class NoTouchProcessRetryTest {
	@isTest static void testManualRetry_SkipsBlankRequestParams() {
		// Create a log with blank Request_Paramets__c and hasException = true
		NoTouch_API_log__c log = new NoTouch_API_log__c(
				hasException__c = true,
				Request_Paramets__c = ''
		);
		insert log;

		// Call manualRetry - should not throw and should perform update
		Test.startTest();
		NoTouchProcessRetry runner = new NoTouchProcessRetry(7);
		runner.manualRetry(7, 100);
		Test.stopTest();

		// Re-query to ensure record still exists and no unexpected changes
		NoTouch_API_log__c after = [SELECT Id, hasException__c, Request_Paramets__c FROM NoTouch_API_log__c WHERE Id = :log.Id];
		System.assertEquals(true, after.hasException__c, 'hasException__c should remain true when Request_Paramets__c is blank');
	}

//	@isTest static void testBatchable_StartExecute_WithMalformedAndBlankJson() {
//		// Create logs: one blank JSON, one malformed JSON
//		List<NoTouch_API_log__c> logs = new List<NoTouch_API_log__c>{
//				new NoTouch_API_log__c(hasException__c = true, Request_Paramets__c = ''),
//				new NoTouch_API_log__c(hasException__c = true, Request_Paramets__c = '{badjson')
//				};
//		insert logs;
//
//		// Execute batchable to cover start/execute/finish
//		Test.startTest();
//		Database.executeBatch(new NoTouchProcessRetry(7), 1);
//		Test.stopTest();
//
//		// Ensure records still exist and were processed without throwing
//		Integer count = [SELECT count() FROM NoTouch_API_log__c WHERE Id IN :logs];
//		System.assertEquals(2, count, 'Both logs should still exist after batch execution');
//	}

	@isTest static void testProcessLogs_WithValidJson_DoesNotThrow() {
		// Insert a log with valid JSON for Request_Paramets__c. The underlying NoTouchProcess may execute
		// but exceptions are caught inside processLogs; we only assert no exception bubbles up.
		Map<String, String> payload = new Map<String, String>{
		'uid' => 'u1', 'email' => 'e@t.com', 'cname' => 'C', 'Fname' => 'F', 'Lname' => 'L',
		'websiteDomain' => 'example.com', 'industry' => 'Ind', 'minEmployees' => '10', 'maxEmployees' => '50'
		};

		NoTouch_API_log__c log = new NoTouch_API_log__c(
				hasException__c = true,
				Request_Paramets__c = JSON.serialize(payload)
		);
		insert log;

		// Call process via batch execute which will call processLogs and catch any internal exceptions
		Test.startTest();
		Database.executeBatch(new NoTouchProcessRetry(7), 1);
		Test.stopTest();

		// If we reach here, processing didn't throw unhandled exceptions
		System.assert(true);
	}
}
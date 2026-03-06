@isTest
public with sharing class SwitchContextServiceTest {
  @isTest
  static void refreshScheduledRunTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'ZuoraRefreshRenewalQuoteBatch';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void submitScheduledRunTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'QuoteRenewalSubmitBatch';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void scheduledRunErrorTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = null;
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void closedOpportunityRelevantTaskBatchTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'ClosedOpportunityRelevantTaskBatch';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void batchBIDataPopulateRelatedRecordsTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'BatchBIDataPopulateRelatedRecords';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void taskCounterBatchTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'TaskCounterBatch';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void zuoraSubscriptionHandlerBatchTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'ZuoraSubscriptionHandlerBatch';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void businessUnitUpdateBatchTest() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'BusinessUnitUpdateBatch';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }

  @isTest
  static void netsuiteExchangeRatesScheduler() {
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    String jobName = 'NetsuiteExchangeRatesScheduler';
    req.requestURI = 'callout:Zuora_Integration/services/apexrest/switch/context/';
    req.httpMethod = 'POST';
    req.params.put('jobName', jobName);

    RestContext.request = req;
    RestContext.response = res;

    Test.startTest();
    SwitchContextService.scheduledJobRun();
    Test.stopTest();
  }
}

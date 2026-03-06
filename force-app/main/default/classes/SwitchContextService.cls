/**
 * REST Endpoint that uses named credential to schedule job
 * in the context of user authorized in named credentials
 */
@RestResource(urlMapping='/switch/context/*')
global with sharing class SwitchContextService {
  /**
   * Sending POST request to the endpoint for sheduling jobs according to ones was scheduled on the prod
   * Shedule job depending on the name as passed request param
   * Request params: String jobName - name of the job that needs to be scheduled
   * @return Void
   */
  @HttpPost
  global static void scheduledJobRun() {
    RestRequest req = RestContext.request;
    RestResponse res = RestContext.response;
    res.addHeader('Content-Type', 'application/json');

    try {
      String job = req.params.get('jobName');
      if (job == null && String.isBlank(job)) {
        throw new SwitchContextServiceException('Job name is empty');
      }

      switch on job {
        when 'ZuoraRefreshRenewalQuoteBatch' {
          if (!Test.isRunningTest()) {
            ZuoraRefreshRenewalQuoteBatch.scheduleRenewelBatch();
          }
        }
        when 'QuoteRenewalSubmitBatch' {
          if (!Test.isRunningTest()) {
            QuoteRenewalSubmitBatch.scheduleRenewelBatch();
          }
        }
        when 'ClosedOpportunityRelevantTaskBatch' {
          if (!Test.isRunningTest()) {
            System.schedule(
              'ClosedOpportunityRelevantTaskBatch',
              '0 0 16 * * ?',
              new ClosedOpportunityRelevantTaskBatch()
            );
          }
        }
        when 'BatchBIDataPopulateRelatedRecords' {
          if (!Test.isRunningTest()) {
            System.schedule(
              'BatchBIDataPopulateRelatedRecords',
              '0 0 16 * * ?',
              new BatchBiDataScheduler()
            );
          }
        }
        when 'TaskCounterBatch' {
          if (!Test.isRunningTest()) {
            System.schedule(
              'TaskCounterBatch',
              '0 0 16 * * ?',
              new TaskCounterBatch(System.now(), 0)
            );
          }
        }
        when 'ZuoraSubscriptionHandlerBatch' {
          if (!Test.isRunningTest()) {
            System.schedule(
              'ZuoraSubscriptionHandlerBatch',
              '0 0 16 * * ?',
              new ZuoraSubscriptionHandlerBatch(false)
            );
          }
        }
        when 'BusinessUnitUpdateBatch' {
          if (!Test.isRunningTest()) {
            System.schedule(
              'BusinessUnitUpdateBatch',
              '0 0 16 * * ?',
              new BusinessUnitUpdateBatch()
            );
          }
        }
        when 'NetsuiteExchangeRatesScheduler' {
          if (!Test.isRunningTest()) {
            NetsuiteExchangeRatesScheduler.scheduleDaily();
          }
        }
      }

      res.statusCode = 200;
      res.responseBody = Blob.valueOf(JSON.serialize(true));
    } catch (Exception e) {
      res.statusCode = 400;
      res.responseBody = Blob.valueOf('{"error":"' + e.getMessage() + '"}');
    }
  }

  /**
   * Custom Exception inner class
   * Used to throw exception during code running
   */
  global class SwitchContextServiceException extends Exception {
  }
}

@isTest
public class NetsuiteExchangeRatesSchedulerTest {
  @isTest
  static void retreiveExchangeRatesFromNetsuiteEndpointTest() {
    MockUtil.NetsuiteExchangeRatesServiceHttpMock mockServiceInstance = new MockUtil.NetsuiteExchangeRatesServiceHttpMock();
    Test.setMock(HttpCalloutMock.class, mockServiceInstance);
    Test.startTest();
    NetsuiteExchangeRatesScheduler.scheduleDaily();
    Test.stopTest();
    Integer numOfRunningNetsuiteJobs = [
      SELECT COUNT()
      FROM CronTrigger
      WHERE
        CronJobDetail.JobType = '7'
        AND CronJobDetail.name = 'NetsuiteExchangeRatesSchedulerTest'
    ];
    System.assertEquals(
      1,
      numOfRunningNetsuiteJobs,
      'Netsuite scheduled job not ran'
    );
  }
}

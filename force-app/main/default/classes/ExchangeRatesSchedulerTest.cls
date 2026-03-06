/**
 * Made by Dmitry Trufanov from Synebo
 *
 * =============== changes =============
 * Itzik Winograd, 2022-06-09: Schedule the class manually with "test" in the name
 **/
@isTest
public class ExchangeRatesSchedulerTest {
  @testSetup
  public static void setup() {
    BOI_Currency_Settings__c boi = new BOI_Currency_Settings__c();
    boi.Name = 'test';
    boi.Currency_Code__c = '01';
    insert boi;
  }

  @isTest
  public static void test() {
    Test.setMock(HttpCalloutMock.class, new ExchangeRatesSchedulerMockImp());
    Test.startTest();
    //ExchangeRatesScheduler.scheduleDaily();
    System.schedule(
      'ExchangeRatesSchedulerTest',
      '0 0 01 * * ?',
      new ExchangeRatesScheduler()
    );
    Test.stopTest();
  }
}

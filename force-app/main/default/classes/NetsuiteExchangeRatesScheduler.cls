public with sharing class NetsuiteExchangeRatesScheduler implements Schedulable{
    public static void scheduleDaily() {
        String schedulerJobName = 'NetsuiteExchangeRatesScheduler';
        if (Test.isRunningTest()) {
            schedulerJobName+='Test';
        }
        System.schedule(schedulerJobName,'0 0 15 * * ?', new NetsuiteExchangeRatesScheduler());
    }
    
    public void execute(SchedulableContext SC) {  
        futureExecuteAction();
    }

    @future(callout=true)
    private static void futureExecuteAction(){
        NetsuiteExchangeRatesService.retreiveExchangeRatesFromNetsuiteEndpoint();
    }
}
public class QuoteRenewalSubmitBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts{

    private Datetime specificDate;

    public QuoteRenewalSubmitBatch(){}

    public QuoteRenewalSubmitBatch(Datetime specDate){
        this.specificDate = specDate;
    }

    public static void executeBatch(){
        Database.executeBatch(new QuoteRenewalSubmitBatch(),1);
    }

    public static void scheduleRenewelBatch(){
        new QuoteRenewalSubmitBatch().execute(null);
    }

    public static void scheduleRenewelBatch(Datetime specDate){
        new QuoteRenewalSubmitBatch(specDate).execute(null);
    }

    public Database.QueryLocator start (Database.BatchableContext BC){

        String query = 'SELECT Id FROM zqu__Quote__c WHERE zqu__QuoteBusinessType__c = \'Renewal (with/without upsell)\' AND zqu_Quote_Status__c = \'Quote Pending Renewal Date\' AND (zqu__StartDate__c = NEXT_N_DAYS:7 OR zqu__StartDate__c = LAST_N_DAYS:8)';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<zqu__Quote__c> scope){
        Set<Id> quoteIds = new Set<Id>();
        for(zqu__Quote__c quote : scope){
            quoteIds.add(quote.Id);
        }
        ZuoraSubmitQuoteService.submitQuote(scope[0].Id);
    }

    public void execute(SchedulableContext SC) {
        /* Itzik Winograd 2022-01-26: Removed inside rescheduling. All daily scheduling are done via UI.
        if(SC != null){
            System.abortJob(Sc.getTriggerId());
        }
        String schedulerName = 'QuoteRenewalSubmitBatch';
        if (Test.isRunningTest()) {
            schedulerName = 'QuoteRenewalSubmitBatchTest';
        }
        if(specificDate == null){
            Database.executeBatch(new QuoteRenewalSubmitBatch(),1);
            System.schedule(schedulerName, Utility.getCronFromDateTime(System.now().addDays(1)), new QuoteRenewalSubmitBatch());
        } else {
            System.schedule(schedulerName, Utility.getCronFromDateTime(specificDate), new QuoteRenewalSubmitBatch());
        }*/
        Database.executeBatch(new QuoteRenewalSubmitBatch(),1);
    }

    public void finish(Database.BatchableContext BC){
    }
}
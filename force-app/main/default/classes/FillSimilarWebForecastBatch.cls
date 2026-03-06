public class FillSimilarWebForecastBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start (Database.BatchableContext BC){
        String query = 'SELECT Id,Similarweb_Forecasting_status__c,ForecastCategoryName FROM Opportunity WHERE Similarweb_Forecasting_status__c=null';
        if(Test.isRunningTest())
            query = 'SELECT Id,Similarweb_Forecasting_status__c,ForecastCategoryName FROM Opportunity';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){     
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        for (SObject sobj_i : scope) { 
            Opportunity opp = (Opportunity)sobj_i;
            opp.Similarweb_Forecasting_status__c = opp.ForecastCategoryName;
            oppToUpdateList.add(opp);
        }
        update oppToUpdateList;
    }
    
    public void finish(Database.BatchableContext BC){
    }
}
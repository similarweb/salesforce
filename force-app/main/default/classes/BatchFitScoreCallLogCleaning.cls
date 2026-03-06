global class BatchFitScoreCallLogCleaning implements 
    Database.Batchable<sObject>, Database.Stateful {    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime obsoleteDate = DateTime.now().addDays(-3);
        return Database.getQueryLocator(
            'SELECT ID ' +
            'FROM Fit_Score_Call_Log__c ' + 
            'Where CreatedDate <: obsoleteDate'
        );
    }
    global void execute(Database.BatchableContext bc, List<Fit_Score_Call_Log__c> scope){
       delete scope;
    }    
    global void finish(Database.BatchableContext bc){
       
    }    
}
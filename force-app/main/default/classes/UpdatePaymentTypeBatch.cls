global with sharing class UpdatePaymentTypeBatch implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id, Payment_Type__c, zqu__ZuoraAccountID__c'
                                        + ' FROM zqu__Quote__c WHERE (Payment_Type__c = \'\') '
                                        + 'AND (NOT Name LIKE \'%test%\') '
                                        + 'AND (NOT zqu_Quote_Status__c = \'Cancelled\') '
                                        + 'AND zqu__PaymentMethod__c = \'Other\' '
                                        + 'AND CreatedDate >= 2020-06-01T00:00:00Z');
    }
    global void execute(Database.BatchableContext bc, List<zqu__Quote__c> quotes){
        UpdatePaymentTypeBatchHelper.updatePaymentTypeField(quotes);
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}
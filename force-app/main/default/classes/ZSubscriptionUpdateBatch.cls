public class ZSubscriptionUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    @TestVisible
    private static final Integer DEFAULT_BATCH_SIZE = 10;

    @TestVisible
    private Set<Id> proceededAccounts;
    @TestVisible
    private ZSubscriptionService subService;

    public ZSubscriptionUpdateBatch() {
        this.proceededAccounts = new Set<Id>();
        this.subService = new ZSubscriptionService();
    }

    public void execute(SchedulableContext sc){
        Database.executeBatch(new ZSubscriptionUpdateBatch(), DEFAULT_BATCH_SIZE);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT '+
                            'Id, ' +
                            'Zuora__Account__c, ' +
                            'Zuora__NextRenewalDate__c, ' +
                            'CreatedDate ' +
                        'FROM Zuora__Subscription__c ' +
                        'WHERE Zuora__Account__c != null ' +
                        'AND Zuora__NextRenewalDate__c != null';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Zuora__Subscription__c> records){
        Set<Id> accountIds = new Set<Id>();
        for(Zuora__Subscription__c sub : records){
            Id accountId = sub.Zuora__Account__c;
            if(accountId != null){
                accountIds.add(accountId);
            }
        }
        accountIds.removeAll(this.proceededAccounts);
        this.proceededAccounts.addAll(new List<Id>(accountIds));

        if(accountIds.isEmpty()){
            return;
        }
 
        List<Account> updatedAccounts = this.subService.updateRelatedAccounts(accountIds);
        if(!updatedAccounts.isEmpty()){
            update updatedAccounts;
        }
    }

    public void finish(Database.BatchableContext bc){

    }
}
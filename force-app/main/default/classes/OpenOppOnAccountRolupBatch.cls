/**
 * Created by Alon.Shalev on 8/12/2023.
 */

public with sharing class OpenOppOnAccountRolupBatch implements Database.Batchable<sObject>, Schedulable{



    private final Integer BATCH_SCOPE_SIZE;

    public OpenOppOnAccountRolupBatch(){
        this.BATCH_SCOPE_SIZE = 50;
    }

    public OpenOppOnAccountRolupBatch(Integer batchScopeSize){
        this.BATCH_SCOPE_SIZE = batchScopeSize;
    }

    public void execute(SchedulableContext sc) {
        OpenOppOnAccountRolupBatch batch = new OpenOppOnAccountRolupBatch();
        Database.executeBatch(batch, this.BATCH_SCOPE_SIZE);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,NumberOfOpenOpps__c,' +
                '(SELECT Id FROM Opportunities WHERE IsClosed = false) ' +
                'FROM Account ';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> records) {
        System.debug('records--'+records);
        List<Account> accountUpdateList = new List<Account>();
        for(Account acc : records){
            Decimal currentCount = acc.Opportunities.isEmpty() ? 0 : Decimal.valueOf(acc.Opportunities.size());
            if(acc.NumberOfOpenOpps__c != currentCount){
                acc.NumberOfOpenOpps__c = currentCount;
                accountUpdateList.add(acc);
            }
        }
        Database.update (accountUpdateList,false);
    }

    public void finish(Database.BatchableContext bc) {
    }

}
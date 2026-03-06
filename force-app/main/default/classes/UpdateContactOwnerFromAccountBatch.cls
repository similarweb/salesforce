/**
 * Created by Alon.Shalev on 7/18/2024.
 */

public with sharing class UpdateContactOwnerFromAccountBatch implements Database.Batchable<sObject>{

    Private Map<Id, Account> accountMap = new Map<Id, Account>();
    private List<Log_Event__e> logEvents = new List<Log_Event__e>();
    private String teamMembers;

    public UpdateContactOwnerFromAccountBatch(Map<Id, Account> accountMap, String teamMembers){
        this.accountMap = accountMap;
        this.teamMembers = teamMembers;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
                SELECT Id, AccountId,Name, OwnerId, Previous_Owner_Id__c, Account_owner_reassigned__c
                FROM Contact
                WHERE AccountId IN :this.accountMap.keySet()
        ]);

    }


    public void execute(Database.BatchableContext BC, List<Contact> scope){
        System.debug('scope--'+scope);
        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact cnt : scope) {
            System.debug(cnt.Id);
            System.debug(cnt.Name);
            if (cnt.OwnerId != this.accountMap.get(cnt.AccountId).OwnerId) {
                cnt.Previous_Owner_Id__c = cnt.OwnerId;
                cnt.OwnerId = this.accountMap.get(cnt.AccountId).OwnerId;
                cnt.Account_owner_reassigned__c = true;
                contactsToUpdate.add(cnt);
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            Integer index = 0;
            List<Database.SaveResult> saveResults = Database.update(contactsToUpdate, false);
            for (Database.SaveResult sr : saveResults) {
                if (!sr.isSuccess()) {
                    logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{
                            contactsToUpdate[index].Id
                    }, 'UpdateContactOwnerFromAccountBatch',
                            'execute', 'Cant update this Contact', sr.getErrors().toString(), 'Error'));
                }
                index++;
            }
        }
    }

    public void publishLogs(){
        if (!logEvents.isEmpty()) {
            EventBus.publish(logEvents);
        }
    }

    public void finish(Database.BatchableContext BC){
        publishLogs();
        if(String.isNotBlank(this.teamMembers)){
            System.enqueueJob(new KeepAccountTeamQueueable (this.teamMembers));
        }
    }
}
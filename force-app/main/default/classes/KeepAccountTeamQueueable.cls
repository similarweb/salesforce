/**
    * @author Itzik Winograd
    * @date 06/06/2021
    * @description Queueable class to upsert the old account members to the recrod with changed object.
    * @param String accountTeamMembers - String representation of the accountTeamMembers
    */
public without sharing class KeepAccountTeamQueueable implements Queueable{
    private String accountTeamMembers;

    public KeepAccountTeamQueueable(String accountTeamMembers){
        this.accountTeamMembers = accountTeamMembers;
    }

    public void execute(QueueableContext context) { 
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        List<AccountTeamMember> newlistAcc = (List<AccountTeamMember>) JSON.deserialize(accountTeamMembers,List<AccountTeamMember>.class);
        for(AccountTeamMember objAccTeamMember : newlistAcc){
            objAccTeamMember.Id= null;
        }
        system.debug('### Account records to insert: '+(JSON.serialize(newlistAcc)));
        List<Database.UpsertResult> resultsList = Database.upsert(newlistAcc, false);
        for (Integer i = 0; i < resultsList.size(); i++) {
            Database.UpsertResult result = resultsList[i];
            if (!result.isSuccess()) {
                logEvents.add(LogEventUtils.createLogEventRecord(new List<String>{newlistAcc[i].Id}, 'KeepAccountTeamQueueable', 'execute', 
                JSON.serialize(newlistAcc[i]),result.getErrors().toString(), 'Error'));
            }
        }
        if(logEvents.size() > 0){
            EventBus.publish(logEvents);
        }
    }
}
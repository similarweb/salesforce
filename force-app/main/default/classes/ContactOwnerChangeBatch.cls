/****************************************************************************************************************
Name                		: ContactOwnerChangeBatch
Description         		:
Related components 		: 

Created/Modified by               Created/Modified Date           Requested by           Related Task/Issue             
-----------------------------------------------------------------------------------------------------------------
1. Dmitry Trufanov                     07.02.2019               Dmitry Trufanov				   - 
2. Dmitry Trufanov                     03.12.2019               Dmitry Trufanov				   - 
****************************************************************************************************************/
public class ContactOwnerChangeBatch implements Database.Batchable<sObject>, Schedulable{
    
    private enum BatchMode {QueryByIdMap,QueryByReassignField}
    private BatchMode mode;
    private Map<Id, Id> oldOwnerMap;

    public ContactOwnerChangeBatch(Map<Id, Id> oldOwnerMap){
        this.oldOwnerMap = oldOwnerMap;
        this.mode = BatchMode.QueryByIdMap;
    }

    public ContactOwnerChangeBatch(){
        this.mode = BatchMode.QueryByReassignField;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('ContactOwnerChangeBatch inside');        
        String query = 'SELECT Id, OwnerId,Previous_Owner_Id__c, Account_owner_reassigned__c,Owner_reassigned__c, (Select ID, OwnerID, Subject, Previous_Owner__c from Tasks ' + 
                       'WHERE Status IN (\'Waiting on someone else\',\'In Progress\',\'Not Started\')) '+ 
                       'from Contact'; 
        if (mode == BatchMode.QueryByIdMap) {
            Set<Id> contactIds = oldOwnerMap.keyset();
            query+=' WHERE Id IN :contactIds';
        } else if (mode == BatchMode.QueryByReassignField) {
            query+=' WHERE Account_owner_reassigned__c = true OR Owner_reassigned__c = true';
        } else {
            throw new BatchModeIsNotDefinedException('Batch mode is not defined');
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope){
        
        List<Task> toUpdate = new List<Task>();
        System.debug('here');        
        System.debug('scope ' + scope);
        for(Contact cnt : scope){
            if (cnt.Tasks.size()>0){
                for (Task task_i : cnt.Tasks){
                    //System.debug ('cnt task ' + t + ', subj matches ' + t.Subject.toLowerCase().contains('contact us') + ', t prev owner ' + t.Previous_Owner__c);
                    if (cnt.OwnerId == task_i.OwnerId) {    //contact owned this task, task is active, owner automatically reassigned
                        System.debug('111');
                        if (!(!String.isEmpty(task_i.Subject) && task_i.Subject.toLowerCase().contains('contact us'))){   //task owner should be set back to previous as it doesn't match one of criteria
                            System.debug('1');
                            task_i.OwnerID = String.isEmpty(task_i.Previous_Owner__c) ? cnt.Previous_Owner_Id__c  : task_i.Previous_Owner__c;
                            
                        }
                    } else {                        //task wasn't owned by new owner, owne has to be changed manually 
                        System.debug('2222');
                        if (!String.isEmpty(task_i.Subject) && task_i.Subject.toLowerCase().contains('contact us')){
                            task_i.OwnerId = cnt.OwnerId;
                            System.debug('2');
                        }
                    }
                    task_i.Changed_from_Parent__c = Datetime.now() + '';
                    toUpdate.add(task_i);
                }
            }
            cnt.Account_owner_reassigned__c = false;
            cnt.Owner_reassigned__c = false;
        }
        update scope;
        
        System.debug('toUpdate ' + toUpdate);
        if (!toUpdate.isEmpty())
            update toUpdate;
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
    public void execute(SchedulableContext SC) {
        System.debug('ContactOwnerChangeBatchScheduler inside');
        System.abortJob(Sc.getTriggerId());
        if (mode == BatchMode.QueryByIdMap) {                    
            Database.executeBatch(new ContactOwnerChangeBatch(oldOwnerMap),50);
        } else if (mode == BatchMode.QueryByReassignField) {
            Database.executeBatch(new ContactOwnerChangeBatch(),50);
            System.schedule('ContactOwnerChangeBatch', getCronFromDateTime(System.now().addHours(4)), new ContactOwnerChangeBatch());
        } else {
            throw new BatchModeIsNotDefinedException('Batch mode is not defined');
        }        
    }

    public static String getCronFromDateTime(Datetime executeTime){
		return executeTime.second() + ' ' + executeTime.minute() + ' ' + executeTime.hour() + ' ' + executeTime.day() + ' ' + executeTime.month() + ' ? ' + executeTime.year();
	}
    
    private class BatchModeIsNotDefinedException extends Exception {}
}
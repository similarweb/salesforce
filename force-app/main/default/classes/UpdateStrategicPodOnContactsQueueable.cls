/**
 * Created by Alon.Shalev on 2/21/2024.
 */

public with sharing class UpdateStrategicPodOnContactsQueueable implements Queueable{

    private static final Integer maximumNumberOfContacts = 5;
    private Map<Id,Contact> allContactMap;

    public UpdateStrategicPodOnContactsQueueable(Set<Id> accountIdSet){
        this.allContactMap = new map<Id,Contact>([SELECT id,Account.Strategic_Pod__c FROM Contact WHERE AccountId IN : accountIdSet]);
    }

    public UpdateStrategicPodOnContactsQueueable(Map<Id,Contact> allContactMap){
        this.allContactMap = allContactMap;
    }

    public void execute(QueueableContext context) {
        Integer counter = 0;

        List<Contact> contactToUpdateList = new List<Contact>();
        for(Id contactId : allContactMap.keySet()){
            Contact contItem = allContactMap.get(contactId);
            if(counter < maximumNumberOfContacts){
                contItem.put('Strategic_Pod__c',contItem.Account.Strategic_Pod__c);
                contactToUpdateList.add(contItem);
                counter++;
                allContactMap.remove(contactId);
            }

        }
        if(!contactToUpdateList.isEmpty()){
            update contactToUpdateList;
        }

        if(!allContactMap.isEmpty()){
            System.debug(allContactMap.size());
            System.debug('lets see--'+allContactMap.size());
            if(!Test.isRunningTest()){
                system.enqueueJob(new UpdateStrategicPodOnContactsQueueable(allContactMap)); // will run the job with te reminders
            }
        }
    }

}
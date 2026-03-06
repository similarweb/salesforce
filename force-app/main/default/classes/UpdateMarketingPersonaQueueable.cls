/**
 * Created by Alon.Shalev on 2/12/2024.
 */

public with sharing class UpdateMarketingPersonaQueueable implements Queueable{

    private static final Integer maximumNumberOfContacts = 5;
    private Map<Id,Contact> allContactMap;
    private Set<Id> accountIdSet;
    private Boolean fromNoTouchRetry = false;

    public UpdateMarketingPersonaQueueable(Set<Id> accountIdSet){
        this.allContactMap = new map<Id,Contact>([SELECT id,Department__c,Account.SW_Industry__c,Marketing_Persona__c,Current_Registration_Type__c FROM Contact WHERE AccountId IN : accountIdSet]);
    }
    public UpdateMarketingPersonaQueueable(Map<Id,Contact> allContactMap){
        this.allContactMap = allContactMap;
    }

    public UpdateMarketingPersonaQueueable(Set<Id> accountIdSet, Boolean fromNoTouchRetry){
        this.allContactMap = new map<Id,Contact>([SELECT id,Department__c,Account.SW_Industry__c,Marketing_Persona__c,Current_Registration_Type__c FROM Contact WHERE AccountId IN : accountIdSet]);
        this.accountIdSet = accountIdSet;
        this.fromNoTouchRetry = fromNoTouchRetry;
    }

    public void execute(QueueableContext context) {
        Integer counter = 0;
        List<Marketing_Persona__mdt> settings = [SELECT Department__c,Marketing_Persona_with_Industry__c,Marketing_Persona_without_Industry__c,Account_SW_Industries__c FROM Marketing_Persona__mdt];
        Map<String,Marketing_Persona__mdt> settingMap = new Map<String,Marketing_Persona__mdt>();
        for(Marketing_Persona__mdt setting  : settings){
            settingMap.put(setting.Department__c, setting);
        }
        List<Contact> contactToUpdateList = new List<Contact>();

        for(Id contactId : allContactMap.keySet()){
            Contact contItem = allContactMap.get(contactId);
            if(String.isNotBlank(contItem.Current_Registration_Type__c) && contItem.Current_Registration_Type__c.contains('Shopper')){
                counter++;
                contItem.put('Marketing_Persona__c','Shopper');
            } else if (String.isNotBlank(contItem.Current_Registration_Type__c) && contItem.Current_Registration_Type__c.contains('app-solution')) {
                counter++;
                contItem.put('Marketing_Persona__c','Apps');
            }
            Marketing_Persona__mdt setting =  settingMap.get(allContactMap.get(contactId).Department__c);
            List<String> swIndustriesFromMetaData = setting != null ?  setting.Account_SW_Industries__c.split(',') : new List<String>();
            Object newValue =  setting != null ? (
                                    swIndustriesFromMetaData.contains(contItem.Account.SW_Industry__c) ?
                                        setting.Marketing_Persona_with_Industry__c :
                                        getValueFromRegistrationType(contItem,true,setting.Marketing_Persona_without_Industry__c)) :
                                    getValueFromRegistrationType(contItem,false,null);

            if(counter < maximumNumberOfContacts){
                contItem.put('Marketing_Persona__c',newValue);
                contactToUpdateList.add(contItem);
                counter++;
                allContactMap.remove(contactId);
            }

        }

        if(!contactToUpdateList.isEmpty()){
            update contactToUpdateList;
        }

        if(!allContactMap.isEmpty()){
            if(!Test.isRunningTest()){
                system.enqueueJob(new UpdateMarketingPersonaQueueable(allContactMap)); // will run the job with te reminders
            }
        }

        if (this.fromNoTouchRetry) {
            system.enqueueJob(new UpdatestrategicPodOnContactsQueueable(this.accountIdSet));
        }
    }

    private String getValueFromRegistrationType(Contact contact , boolean withSettingExist,String defaultValue){
        String newPersonaValue = defaultValue != null ? defaultValue : 'No Persona';
        if(contact.Current_Registration_Type__c != null){
            if(contact.Current_Registration_Type__c.containsIgnoreCase('Sales') ||
               contact.Current_Registration_Type__c.containsIgnoreCase('sales-solution') ||
               contact.Current_Registration_Type__c.containsIgnoreCase('Digital Marketing') ||
               contact.Current_Registration_Type__c.containsIgnoreCase('web-solution')) {
                if(!withSettingExist || (contact.Department__c == null || contact.Department__c == 'Other')){
                    newPersonaValue = contact.Current_Registration_Type__c.containsIgnoreCase('Sales') ||
                                      contact.Current_Registration_Type__c.containsIgnoreCase('sales-solution') ?
                                        'Sales' : 'Marketing - General';
                }
            }
        }
        return newPersonaValue;
    }
}
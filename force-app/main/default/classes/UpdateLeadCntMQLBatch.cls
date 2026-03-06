global class UpdateLeadCntMQLBatch implements Database.Batchable<sObject>, Schedulable{

    String query;
    
    global UpdateLeadCntMQLBatch(){
		        
    }
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new UpdateLeadCntMQLBatch());
    }
    
    global Database.QueryLocator start (Database.BatchableContext BC){
        query = 'select id, ContactId, Contact.MQL__c, LeadId, Lead.MQL__c, Rating__c, Contact.Status__c, Contact.Name, Lead.Name, Lead.Status, CompanyOrAccount, ' + 
            	'Contact.HasOptedOutOfEmail, Contact.Account.Name, Lead.HasOptedOutOfEmail, Lead.Company from CampaignMember '+ 
            	'where (Rating__c = 4 or Rating__c = 5) and ((Contact.MQL__c = false and Contact.Status__c !=  \'Unqualified\' and Contact.HasOptedOutOfEmail = false )' +
            	' or ( Lead.MQL__c = false and Lead.Status != \'Unqualified\' and Lead.HasOptedOutOfEmail = false))  and CompanyOrAccount != \'SimilarWeb\'';
        System.debug('start');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope){
        System.debug('scopr ' + scope);
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Lead> leadsToUpdate = new List<Lead>();
        for (CampaignMember member : scope) {
            if (member.Contact != null && !member.Contact.MQL__c && member.Contact.Status__c != 'Unqualified') {
                contactsToUpdate.add(new Contact(Id = member.ContactId, MQL__c  = true, Member_Of_5_Campaign__c = true));
            } 
            if (member.Lead != null && !member.Lead.MQL__c && member.Lead.Status != 'Unqualified') {
                leadsToUpdate.add(new Lead(Id = member.LeadId, MQL__c  = true));
            }
        }
            System.debug('leadsToUpdate ' + leadsToUpdate );
            System.debug('contactsToUpdate ' + contactsToUpdate );
        if (!contactsToUpdate.isEmpty() )
            update contactsToUpdate;
        if (!leadsToUpdate.isEmpty() )
            update leadsToUpdate;
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}
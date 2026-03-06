public class Report2BatchBillTo implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){        
        String query = 'SELECT Id , Zuora__BillToWorkEmail__c , Zuora__BillToName__c , Zuora__BillToAddress1__c , Zuora__BillToAddress2__c , Zuora__BillToWorkPhone__c , Zuora__BillToCity__c , Zuora__BillToPostalCode__c , Zuora__BillToCountry__c,Zuora__BillToState__c,Zuora__Status__c FROM Zuora__CustomerAccount__c WHERE Zuora__BillToWorkEmail__c!=null'; 
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<Zuora__CustomerAccount__c> billingAccountList){
        List<Map<String,Object>> report2 = new List<Map<String,Object>>();
        Set<String> mails = new Set<String>();
        Map<String, List<Contact>> emailContactMap = new Map<String, List<Contact>>();
        
        for (Zuora__CustomerAccount__c zca_i : billingAccountList) {
            if(String.isNotBlank(zca_i.Zuora__BillToWorkEmail__c)){
                mails.add(zca_i.Zuora__BillToWorkEmail__c);
            }
        }
        List<Contact> contactList = new List<Contact>();
        contactList = [SELECT Id 
                       , Email
                       , Name
                       , FirstName
                       , LastName
                       , Phone
                       , MailingStreet
                       , MailingCity
                       , MailingPostalCode
                       , MailingCountry
                       , MailingState
                       FROM Contact
                       WHERE Email IN :mails];
        
        for (Contact cnt_i : contactList) {
            List<Contact> cntList = new List<Contact>();
            if (emailContactMap.containsKey(cnt_i.Email)) {
                cntList = emailContactMap.get(cnt_i.Email);
            }
            cntList.add(cnt_i);
            emailContactMap.put(cnt_i.Email,cntList);
        }
        for (Zuora__CustomerAccount__c zca_i : billingAccountList) {        
            if(emailContactMap.containsKey(zca_i.Zuora__BillToWorkEmail__c)){
                List<Contact> billToCntList = emailContactMap.get(zca_i.Zuora__BillToWorkEmail__c);
                for(Contact cnt_i : billToCntList){
                    Map<String,Object> billingAccIbjectMap = new Map<String,Object>();
                    if(zca_i.Zuora__BillToState__c != cnt_i.MailingState
                       || zca_i.Zuora__BillToWorkPhone__c != cnt_i.Phone
                       || zca_i.Zuora__BillToPostalCode__c != cnt_i.MailingPostalCode
                       || zca_i.Zuora__BillToCity__c != cnt_i.MailingCity
                       || zca_i.Zuora__BillToAddress1__c != cnt_i.MailingStreet
                       || zca_i.Zuora__BillToCountry__c != cnt_i.MailingCountry
                       || zca_i.Zuora__BillToName__c != cnt_i.Name)
                    {
                        billingAccIbjectMap.put('Billing Account Id',zca_i.Id);
                        billingAccIbjectMap.put('Billing Account Email',zca_i.Zuora__BillToWorkEmail__c);
                        billingAccIbjectMap.put('Contact Id',cnt_i.Id);
						billingAccIbjectMap.put('Contact Email',cnt_i.Email);
                        if(zca_i.Zuora__BillToName__c != cnt_i.Name){
                            billingAccIbjectMap.put('Billing Account',zca_i.Zuora__BillToName__c);
                            // billingAccIbjectMap.put('Contact Name',cnt_i.Name);
                            billingAccIbjectMap.put('Contact First Name',cnt_i.FirstName);
                            billingAccIbjectMap.put('Contact Last Name',cnt_i.LastName);
                        }
                        if(zca_i.Zuora__BillToWorkPhone__c != cnt_i.Phone){
                            billingAccIbjectMap.put('Billing Account Phone',zca_i.Zuora__BillToWorkPhone__c);
                            billingAccIbjectMap.put('Contact Phone',cnt_i.Phone);
                        }
                        if(zca_i.Zuora__BillToPostalCode__c != cnt_i.MailingPostalCode){
                            billingAccIbjectMap.put('Billing Account PostalCode',zca_i.Zuora__BillToPostalCode__c);
                            billingAccIbjectMap.put('Contact MailingPostalCode',cnt_i.MailingPostalCode);
                        }
                        if(zca_i.Zuora__BillToCity__c != cnt_i.MailingCity){
                            billingAccIbjectMap.put('Billing Account City',zca_i.Zuora__BillToCity__c);
                            billingAccIbjectMap.put('Contact MailingCity',cnt_i.MailingCity);
                        }
                        if(zca_i.Zuora__BillToAddress1__c != cnt_i.MailingStreet){
                            billingAccIbjectMap.put('Billing Account Street',zca_i.Zuora__BillToAddress1__c);
                        	billingAccIbjectMap.put('Contact MailingStreet',cnt_i.MailingStreet);
                        }
                        if(zca_i.Zuora__BillToCountry__c != cnt_i.MailingCountry){
                            billingAccIbjectMap.put('Billing Account Country',zca_i.Zuora__BillToCountry__c);
                        	billingAccIbjectMap.put('Contact MailingCountry',cnt_i.MailingCountry);
                        }
                        if(zca_i.Zuora__BillToState__c != cnt_i.MailingState){
                            billingAccIbjectMap.put('Billing Account State',zca_i.Zuora__BillToState__c);
                        	billingAccIbjectMap.put('Contact MailingState',cnt_i.MailingState);
                        }
                        billingAccIbjectMap.put('Zuora status',zca_i.Zuora__Status__c);
                        report2.add(billingAccIbjectMap);
                    }
                }   
            }            
        } 
        System.debug(JSON.serializePretty(report2)); 
    }
    
    public void finish(Database.BatchableContext BC){
    }
}
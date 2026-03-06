/**
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* @author Itzik Winograd
* @date 19/08/2021
* @description: Calculate the MQL in a different class. set values to the MQL Dates fields.
*               Removed 'static' from afterUpdate method.
* --------------------------------------------------------------------------------------
*/
public with sharing class BIDataPopulateRelatedRecordsHandler {

    public  void afterUpdate(Map<Id,BI_Data__c> newBid, Map<Id,BI_Data__c> oldBid) {
        Set<Id> bidLeads = new Set<Id>();
        Set<Id> bidLeadsProUserProduct = new Set<Id>();
        Map<Id,BI_Data__c> bidLeadsBehave = new Map<Id,BI_Data__c>();
        Set<Id> bidContacts = new Set<Id>();
        Set<Id> bidContactsProUserProduct = new Set<Id>();
        Map<Id,BI_Data__c> bidContactsBehave = new Map<Id,BI_Data__c>();
        Set<Id> bidAccounts = new Set<Id>();
        List<Lead> leads = new List<Lead>();
        List<Contact> contacts = new List<Contact>();
        List<Account> accounts = new List<Account>();

        for(Id key : newBid.keySet()){
            BI_Data__c newOne = newBid.get(key);
            BI_Data__c oldOne = oldBid.get(key);

            if(newOne.Related_Record_18_ID__c.substring(0,3) == '00Q' && 
                (newOne.Pro_User_Type__c != oldOne.Pro_User_Type__c || newOne.Base_Product__c != oldOne.Base_Product__c || newOne.SW_Behavioral_Rate__c != oldOne.SW_Behavioral_Rate__c)){
                    bidLeads.add(newOne.Id);
                    if (newOne.Pro_User_Type__c != oldOne.Pro_User_Type__c || newOne.Base_Product__c != oldOne.Base_Product__c) {
                        bidLeadsProUserProduct.add(newOne.Id);
                    }
                    if (newOne.SW_Behavioral_Rate__c != oldOne.SW_Behavioral_Rate__c) {
                        bidLeadsBehave.put(newOne.Id,newOne);
                    }
            } else if(newOne.Related_Record_18_ID__c.substring(0,3) == '003' &&
                (newOne.Pro_User_Type__c != oldOne.Pro_User_Type__c || newOne.Base_Product__c != oldOne.Base_Product__c || newOne.SW_Behavioral_Rate__c != oldOne.SW_Behavioral_Rate__c)){
                    bidContacts.add(newOne.Id);
                    if (newOne.Pro_User_Type__c != oldOne.Pro_User_Type__c || newOne.Base_Product__c != oldOne.Base_Product__c) {
                        bidContactsProUserProduct.add(newOne.Id);    
                    }
                    if (newOne.SW_Behavioral_Rate__c != oldOne.SW_Behavioral_Rate__c) {
                        bidContactsBehave.put(newOne.Id,newOne);
                    }
            } else if(newOne.Related_Record_18_ID__c.substring(0,3) == '001' &&
                (newOne.ARR__c != oldOne.ARR__c || newOne.Base_Product__c != oldOne.Base_Product__c)){
                    bidAccounts.add(newOne.Id);
            }
        }
        //leads = [ SELECT Id, Base_Product__c, Pro_User_Type__c,BI_Data__c,SW_Fit_Score__c, First_MQL_Date__c, MQL__c, MQL_date__c FROM Lead WHERE BI_Data__c IN :bidLeads];
        String fieldsToQuery = 'SELECT Id, Base_Product__c, Pro_User_Type__c,BI_Data__c,SW_Fit_Score__c, MQL__c, First_MQL_Date__c, MQL_date__c FROM ';
        if(!bidLeads.isEmpty()){
            leads = Database.query(fieldsToQuery + ' Lead WHERE BI_Data__c IN :bidLeads');
        }
        if(!bidContacts.isEmpty()){
            contacts = Database.query(fieldsToQuery + ' Contact WHERE BI_Data__c IN :bidContacts');
        }
        if(!bidAccounts.isEmpty()){
            accounts = [SELECT Id, ARR__c, Base_Product__c,BI_Data__c FROM Account WHERE BI_Data__c IN :bidAccounts];
        }

        if(!leads.isEmpty()){
            for(Lead ld: leads){
                if (bidLeadsProUserProduct.contains(ld.BI_Data__c)) {
                    ld.Base_Product__c = newBid.get(ld.BI_Data__c).Base_Product__c;
                    ld.Pro_User_Type__c = newBid.get(ld.BI_Data__c).Pro_User_Type__c;
                }
                if (bidLeadsBehave.containsKey(ld.BI_Data__c)) {
                    BI_Data__c biData = newBid.get(ld.BI_Data__c);
                    ld = (Lead)setMQLValues (ld, biData);
                }
            }
            update leads;
        }

        
        if(!contacts.isEmpty()){
            for(Contact cnt: contacts){
                if (bidContactsProUserProduct.contains(cnt.BI_Data__c)) {
                    cnt.Base_Product__c = newBid.get(cnt.BI_Data__c).Base_Product__c;
                    cnt.Pro_User_Type__c = newBid.get(cnt.BI_Data__c).Pro_User_Type__c;
                }
                if (bidContactsBehave.containsKey(cnt.BI_Data__c)) {
                    BI_Data__c biData = newBid.get(cnt.BI_Data__c);
                    cnt = (Contact)setMQLValues (cnt, biData);
                }
            }
            update contacts;
        }
        
        if(!accounts.isEmpty()){

            for(Account acc: accounts){
                acc.ARR__c = newBid.get(acc.BI_Data__c).ARR__c;
                acc.Base_Product__c = newBid.get(acc.BI_Data__c).Base_Product__c;
            }
            update accounts;
        }
    }

    /**
    * @author Itzik Winograd
    * @date 19/08/2021
    * @description send the records to mql+mql dates and debug the calculation.
    * @param SObject sobj to update the mql on, 
    * @param BI_Data__c biData the related biData record of the sobj.  
    * @return Void.
    */
    public SObject setMQLValues(SObject sobj, BI_Data__c biData){
        Boolean currentMqlValue = (Boolean)sobj.get('MQL__c');
        // 2021/07: The calculation moved to the MQLCalculation class
        Boolean newMQLValue = MQLCalculationHandler.calculateMQL(biData.SW_Behavioral_Rate__c, (String)sobj.get('SW_Fit_Score__c')); 
        sobj.put('MQL__c', newMQLValue);
        if(GeneralUtil.getGeneralConfig('Create_MQL_Logs').Text_Value__c == 'true' ? true : false){
            Eventbus.publish(MQLCalculationHandler.createMQLLogRecord(sobj,'MQL = ' + newMQLValue+'. \nReason: BI_Data__c record updated.', (String)sobj.get('SW_Fit_Score__c'),biData.SW_Behavioral_Rate__c));
        }
        // 2021/08: Set values to MQL dates
        sobj = MQLCalculationHandler.assignMQLDates(sobj, currentMqlValue);
        System.debug('### Calculation MQL from BI_Data trigger. BH: ' + biData.SW_Behavioral_Rate__c +
                        ' , FS: ' + sobj.get('SW_Fit_Score__c') +
                        ' , MQL: ' + sobj.get('MQL__c'));
        return sobj;
    }
}

/* Leads old MQL assignment
if ((biData.SW_Behavioral_Rate__c == 1 
        && (ld.SW_Fit_Score__c == 'A' || ld.SW_Fit_Score__c == 'B' || ld.SW_Fit_Score__c == 'C')
    )
    ||
    (biData.SW_Behavioral_Rate__c == 2 
        && (ld.SW_Fit_Score__c == 'A' || ld.SW_Fit_Score__c == 'B' || ld.SW_Fit_Score__c == 'C')
    )
    ||
    (biData.SW_Behavioral_Rate__c == 3 
        && (ld.SW_Fit_Score__c == 'A')
    )
) {
    ld.MQL__c = true;
} else {
    ld.MQL__c = false;
}*/

 /* Contact old MQL assignment:
if ((biData.SW_Behavioral_Rate__c == 1 
        && (cnt.SW_Fit_Score__c == 'A' || cnt.SW_Fit_Score__c == 'B' || cnt.SW_Fit_Score__c == 'C')
    )
    ||
    (biData.SW_Behavioral_Rate__c == 2 
        && (cnt.SW_Fit_Score__c == 'A' || cnt.SW_Fit_Score__c == 'B' || cnt.SW_Fit_Score__c == 'C')
    )
    ||
    (biData.SW_Behavioral_Rate__c == 3 
        && (cnt.SW_Fit_Score__c == 'A')
    )
) {
    cnt.MQL__c = true;
} else {
    cnt.MQL__c = false;
}*/
/* OLD MQL assignment
BI_Data__c biData = newBid.get(cnt.BI_Data__c);
                    // 2021/07: The calculation moved to the MQLCalculation class
                    cnt.MQL__c = MQLCalculationHandler.calculateMQL(biData.SW_Behavioral_Rate__c, cnt.SW_Fit_Score__c);
                    // 2021/08: Set values to MQL dates
                    cnt = (Contact)MQLCalculationHandler.assignMQLDates(cnt);
                    System.debug('### Calculation MQL from BI_Data trigger. BH: ' + biData.SW_Behavioral_Rate__c +
                                    ' , FS: ' + cnt.SW_Fit_Score__c +
                                    ' , MQL: ' + cnt.MQL__c);
*/
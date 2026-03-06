/**
* @author Itzik Winograd
* @date 03/03/2021
* @description Integration class to ShareASale
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 27/05/2021
* description - Addition to Phase 1:
*               make sure that Order_Number__c is null for creating the call,
*               and verify on update that old Affiliate_ID__c is 'organic'.
*               Also, filter out the converted contacts on trigger.isInsert.
*               Countries(07/2021): Add filter only for some of the countries in the custom metadata
*/
public with sharing class ShareASaleIntegration {
    

    /**
    * @author Itzik Winograd
    * @date 03/03/2021
    * @description Main method. filter the inserted sobjects and then perform a call to shareasale.
    * @param none 
    * @return none
    */
    public void handle(List<SObject> sobjectsList, Map<Id,SObject> oldMap){
       List<SObject> filteredRecords = filterRecords(sobjectsList, oldMap);
        if(!filteredRecords.isEmpty()){
            System.enqueueJob(new ShareASaleQuauableCalls(filteredRecords, 'new')); //this class will always send 'new' transaction to shareasale
        }
    }

    /**
    * @author Itzik Winograd
    * @date 03/03/2021
    * @description filter the records. Records with Affiliate_ID__c and without Order_Number__c and not 'organic' will be processed.
    * @date 27/05/2021 - added filtering out the converted contacts on insert.
    * @date 31/06/2021 - added filtering only approved countries in metadata
    * @param List<SObject> sobjectsList - trigger.new context
    * @param Map<Id,SObject> oldMap - trigger.old context
    * @return List<SObject> filteredRecords
    */
    public List<SObject> filterRecords(List<SObject> sobjectsList, Map<Id,SObject> oldMap){
        String countryFieldName = getCountryFieldName((Id)sobjectsList[0].get('id'));
        Set<String> approvedCountries = getApprovedCountriesSet();
        Map<String,SObject> idToSObjectMap = new Map<String,SObject>();
        for(SObject sobj : sobjectsList){
            if(rewardAffiliate(sobj, oldMap!=null ? oldMap.get((String)sobj.get('Id')) : null) && approvedCountries.contains((String)sobj.get(countryFieldName))){
                String sobjectId = (String)sobj.get('Id');
                idToSObjectMap.put(sobjectId,sobj);
            }
        }
        return idToSObjectMap.values();
    } 

    /**
    * @author Itzik Winograd
    * @date 30/05/2021
    * @description: Check if this sobject is rellevnat for 'new transaction':
    *               if order number == null, affiliate Id is not null and not organic,
    *               and (it's an insert or its an update and old affiliate Id was null) 
    * @param SObject sobj - value from trigger.new
    * @param SObject oldSObject  - value from trigger.old
    * @return Boolean 
    */
    private Boolean rewardAffiliate (SObject sobj, SObject oldSObject){
        return 
            sobj.get('Order_Number__c') == null && 
            sobj.get('Affiliate_ID__c') != null &&  
            ((String)sobj.get('Affiliate_ID__c')).toLowerCase() != 'organic' && 
            (oldSObject==null || ((String)oldSObject.get('Affiliate_ID__c')) == null);
    }

    /**
    * @author Itzik Winograd
    * @date 30/06/2021
    * @description: Get a list of approved counrties for ShareASale transactions from the Country_Picklist_Values__mdt.
    * @return Set<String> with approved countries
    */
    private Set<String> getApprovedCountriesSet(){
        Set<String> approvedCountriesSet = new Set<String>();
        try{
            for(Country_Picklist_Values__mdt countryName : [SELECT CountryName__c, Affiliate_Country__c 
                                                              FROM Country_Picklist_Values__mdt
                                                             WHERE Affiliate_Country__c = true]){
                approvedCountriesSet.add(countryName.CountryName__c);
            }
            if(approvedCountriesSet.isEmpty()){
                throw new ShareASaleIntegrationException('Couldn\'t find any approved countries!');
            }
        }
        catch (exception ex)
        {
            throw new ShareASaleIntegrationException('Error fetching list of approved countries!');
        }
        return approvedCountriesSet;
    }

    /**
    * @author Itzik Winograd
    * @date 30/06/2021
    * @description: get the right country field name according to the object type.
    * @param Id example of an Id from the list of sobjects
    * @return String api name of the field to get the country from
    */
    private string getCountryFieldName(Id id){
        String countryFieldName;
        switch on GeneralUtil.getObjectNameFromId(id){
            when  'lead'{
                countryFieldName = 'Country';
            } when 'contact' {
                countryFieldName = 'MailingCountry';
            } when else {
                throw new ShareASaleIntegrationException('Couldn\'t set country field name; Invalid object sent the ShareASaleIntegrationException class.');
            }
        }
        return countryFieldName;
    }

    private class ShareASaleIntegrationException extends Exception {}
}
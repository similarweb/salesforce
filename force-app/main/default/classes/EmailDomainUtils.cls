/**
* @author Itzik Winograd
* @date 24/12/2020
* @description General EmailDomain__c functions that can help us throughout the code base
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------                     
*/

public with sharing class EmailDomainUtils { 
    /**
    * @author Itzik Winograd
    * @date 24/12/2020
    * @description Create a list of EmailDomain__c records 
    * @param Integer numOfDomains - Number of EmailDomain__c records to create.  
    * @return List<EmailDomain__c> - list of EmailDomain__c with Name = TestDomain_<i> (i is increasing numOfDomains), null if none requested
    */
    public static List<EmailDomain__c>  getEmailDomains(Integer numOfDomains){
        List<EmailDomain__c> lst_EmailDomains = new List<EmailDomain__c>();
        Id devRecordTypeId = Schema.SObjectType.EmailDomain__c.getRecordTypeInfosByDeveloperName().get('Free').getRecordTypeId();
        if (numOfDomains > 0){
            for (Integer i = 0; i < numOfDomains; i++){
                lst_EmailDomains.add(New EmailDomain__c(
                    Name = 'TestDomain_'+i+'.com',
                    RecordTypeId = devRecordTypeId
                ));
            }
            return lst_EmailDomains;
        }
        return null;
    }
}
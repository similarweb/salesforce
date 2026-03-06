/**
* @author Itzik Winograd
* @date 21/06/2021
* @description: When leads converted to accounts or contacts,
                collects the relevant account ids, mark them with "Pass_Values_to_Related_Records__c"
                and enqueue "DistributeAccValuesToConsBatch" job.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
public with sharing class PassValuesToConvertedLeads {
   
    /** 
    * @author Itzik Winograd
    * @date 21/06/2021
    * @description Check for converted leads. If lead is converted to account or contact - mark it with "Pass_Values_to_Related_Records__c"
    *              Run distribute account values to contacts afterwatds.
    * @param List<Lead> newLeadsList
    * @param Map<Id, Lead> oldLeadsMap
    * @return Void.
    */
    public void handle(List<Lead> newLeadsList, Map<Id, Lead> oldLeadsMap){
        Set<Account> accountsSet = new Set<Account>();
        for(Lead ld : newLeadsList){
            if(ld.IsConverted == true && oldLeadsMap.get(ld.Id).IsConverted == false){
                if(ld.ConvertedAccountId != null){
                    accountsSet.add(new Account(
                        id = ld.ConvertedAccountId,
                        Pass_Values_to_Related_Records__c = true
                    ));
                }
                if(ld.ConvertedContactId != null){
                    //do nothing here, since it will be taken care of in ContactGetValuesFromAccount
                }
                    
            }
        }
        if (!accountsSet.isEmpty()){
            System.enqueueJob(new QueueableDMLUtils(new List<Account>(accountsSet),'update', false, 'ExecuteDistibuteAccountValuesToCons'));
        }
    }
}
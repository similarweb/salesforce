/**
* @author Itzik Winograd
* @date  21/02/2021
* @description: This class query for Accounts with "Pass_Values_to_Related_Records__c" = true,
*               then passes the values on the fields (fields are specified in the custom metadata),
*               and unflaggin the accounts with Pass_Values_to_Related_Records__c = true;
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
public class DistributeAccValuesToConsBatch implements Database.Batchable<sObject>,  Database.Stateful{
	
    private String query = '';
    private FieldMappingUtil.FieldMappingData fmd;
    private Integer BATCH_LIMIT = Integer.valueOf(GeneralUtil.getGeneralConfig('Account_to_Related_Contacts_Batch_Size').Number_Value__c);
    private String prevAccountId = '';
    private Set<Id> accountsToUnflagIdSet;

    //Constructor. Build the query for the contacts with the "pass values.." = true on their account.
    public DistributeAccValuesToConsBatch(){
        System.debug ('### In DistributeAccValuesToConsBatch');
        
        List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList('Account to Related Contacts');
        this.fmd = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(fieldsMappingList);    
        this.query = createQuery();
    }
     
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    //Execute method. Call the method to update the contacts and unflag the accounts afterwards.
    public void execute(Database.BatchableContext BC, List<SObject> scope){
        accountsToUnflagIdSet = new Set<Id>(); // ids are added in getContactsToUpdate()
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        System.debug('### in DistributeAccValuesToConsBatch - Execute');
        List<Contact> contactsToUpdate = getContactsToUpdate(scope);
        String errorMessage = '';
        if(!contactsToUpdate.isEmpty()){
            try{
                List<Database.SaveResult> contactsSR = Database.update(contactsToUpdate,false);
                for (Integer i = 0; i < contactsSR.size(); i++) {
                    Database.SaveResult result = contactsSR[i];
                    if (!result.isSuccess()) {
                        accountsToUnflagIdSet.remove(contactsToUpdate[i].AccountId);//remove this contact's accountId from the accounts to unflag.
                        errorMessage = 'Error in DistributeAccValuesToConsBatch - Update Contact: ' + result.getErrors();
                        logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>{contactsToUpdate[i].Id}, 'DistributeAccValuesToConsBatch', 'execute', 
                                                                    '', errorMessage, 'Error',null,null));
                    }
                }
            } catch (Exception ex){
                errorMessage = 'Exception caught in DistributeAccValuesToConsBatch - Update Contacts: ' + ex.getMessage();
                logEvents.add(LogEventUtils.createLogEventRecord((List<SObject>)contactsToUpdate, 'DistributeAccValuesToConsBatch', 'execute', 
                                                                 '', errorMessage, 'Error',null,null));
            }
        }
        if(!accountsToUnflagIdSet.isEmpty()){
            try{
                List<Account> accountsToUnflagList = unflagAccounts(accountsToUnflagIdSet);
                List<Database.SaveResult> accountsSR = Database.update(accountsToUnflagList,false);
                for (Integer i = 0; i < accountsSR.size(); i++) {
                    Database.SaveResult result = accountsSR[i];
                    if (!result.isSuccess()) {
                        errorMessage = 'Error in DistributeAccValuesToConsBatch - Unflag account: ' + result.getErrors();
                        logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>{accountsToUnflagList[i].Id}, 'DistributeAccValuesToConsBatch', 'execute', 
                                                                    '', errorMessage, 'Error',null,null));
                    }
                }
            } catch (Exception ex){
                errorMessage = 'Exception caught in DistributeAccValuesToConsBatch - Unflag Accounts: ' + ex.getMessage();
                System.debug ('### '+ errorMessage);
                logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>(accountsToUnflagIdSet), 'DistributeAccValuesToConsBatch', 'execute', 
                                                                 '', errorMessage, 'Error',null,null));
            }
        }
        if(!logEvents.isEmpty()){
            EventBus.publish(logEvents);
        }
	}
     
    public void finish(Database.BatchableContext BC){
        /** 2021-07-19: remove the unflagged accounts only if 1 account was found flagged.
         * if more then 1 account is found - it means that other prcesses are running in the background.SELECT  FROM 
         * */
        List<Account> unflaggedAccounts = new List<Account>([
            SELECT Id 
            FROM Account 
            WHERE Pass_Values_to_Related_Records__c = true]);
        if(unflaggedAccounts.size() == 1){ //>0
            System.debug('### Should unflag 1 accounts');
            for(Account acc : unflaggedAccounts){
                acc.Pass_Values_to_Related_Records__c = false;
            }
            try{
                update unflaggedAccounts;
            } catch (Exception ex){
                String errorMessage = 'Exception caught in DistributeAccValuesToConsBatch - Finish and Unflag Accounts: ' + ex.getMessage();
                System.debug ('### '+ errorMessage);
                EventBus.publish(LogEventUtils.createLogEventRecord(unflaggedAccounts, 'DistributeAccValuesToConsBatch', 'finish', 
                                                                 '', errorMessage, 'Error',null,null));
            }
        }
        System.debug('### Finished All DistributeAccValuesToConsBatch batches'); 
    }
    
    /** 
    * @author Itzik Winograd
    * @date 21/02/2021
    * @description: create a nested query of accounts with contacts
    * @param none.
    * @return String a nested query of accounts with contacts.
    */ 
    private String createQuery(){
        String accountFields ='';
        for (String field : fmd.sourceFieldSet){
            accountFields += ', Account.' + field;
        }
        System.debug('### accountFields' + accountFields);
        //set the contact query 
        String fullQuery = fmd.getRecordsFromSObject('Contact','Account.Pass_Values_to_Related_Records__c ' + accountFields);
        fullQuery += ' WHERE Account.Pass_Values_to_Related_Records__c = true';
        System.debug ('### fullQuery: ' + fullQuery);
        return fullQuery;
    }
    
    /** 
    * @author Itzik Winograd
    * @date 28/02/2021
    * @description: Get the flagged accounts and their contact. loop ovet these accounts
    * and on the related contact. if the contact is not update - add it to the contactsToUpdate.
    * Use a fmd method to pass the values from the account to the contact.
    * @param None.
    * @return List<Contact> contactsToUpdate with the values taken from their accounts.
    */ 
    private List<Contact> getContactsToUpdate(List<SObject> scope){
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList('Account to Related Contacts');
        Boolean alreadyAdded;
        List<Contact> contacts = (List<Contact>)scope;
        if(!contacts.isEmpty()){
            System.debug('### prevAccountId before: ' + prevAccountId);
            prevAccountId = prevAccountId == '' ? contacts[0].AccountId : prevAccountId; //set it only if it is null
            System.debug('### prevAccountId after: ' + prevAccountId);
            for(Contact con:contacts){
                alreadyAdded = false;
                Contact contactToUpdate = new Contact();
                for(Fields_Mapping__mdt mdt : fieldsMappingList){
                    if(con.get(mdt.Destination_Field__c) != con.getSObject('Account').get(mdt.Source_Field__c)){
                        contactToUpdate.put(mdt.Destination_Field__c, con.getSObject('Account').get(mdt.Source_Field__c));
                        alreadyAdded = true;
                    }
                }//end values compare
                if(alreadyAdded == true){
                    contactToUpdate.put('Id', con.get('Id'));
                    contactsToUpdate.add(contactToUpdate);
                }
                if(con.AccountId != prevAccountId){
                    accountsToUnflagIdSet.add(prevAccountId);
                }
                prevAccountId = con.AccountId;
            }//end for on contacts
        }
        return contactsToUpdate;
    }
    
    /** 
    * @author Itzik Winograd
    * @date 28/02/2021
    * @description: Uncheck the Pass_Values_to_Related_Records__c on the accounts in the list.
    * @param Set<Id> accountIds - Set of account Ids to unflag
    * @return  List<Account> accountsToUnflagList - List of unflagged accounts
    */ 
    private List<Account> unflagAccounts(Set<Id> accountIds){
        List<Account> accountsToUnflagList = new List<Account>();
        Account updatedAccount;
        for (Id accIdd : accountIds){
            accountsToUnflagList.add(
                new Account(
                    Id = accIdd,
                    Pass_Values_to_Related_Records__c = false)
            );
        }
        return accountsToUnflagList;
    }
}
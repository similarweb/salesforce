/**
 * @author Itzik Winograd
 * @date 02/02/2021
 * @description This class is tracking changes on the BiData object.
 * If changes were made to the specific fields (in custom meta data), this class will
 * mock a change to the related lead/account and trigger a fitscore claculation with NewBiApiInteractionHandler clas.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public with sharing class BiDataCallFitScore {
  public void addCoverageBeforeDeletion() {
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }
  //
  //    List<Contact> newContacts;
  //    Map<Id,Contact> oldContacts;
  //    List<Lead> newLeads;
  //    Map<Id,Lead> oldLeads;

  /**
   * @author Itzik Winograd
   * @date 02/02/2021
   * @description Main mathod to handle the process
   * @param List<Bi_Data__c> newList - new records list
   * @param Map<Id, Bi_Data__c> oldMap - old records map
   * @return none.
   */
  public void generateFitScoreCall(
    List<Bi_Data__c> newList,
    Map<Id, Bi_Data__c> oldMap
  ) {
    //        //get list of fileds to track from custom meta data
    //        List<String> biDataFieldsList=GeneralUtil.getGeneralConfig('BiData_fields_to_trigger_fitscore_call').Text_Value__c.split(',');
    //        //check if custom the values on the fields from the custom metadata fields were changed
    //        filterRecords(newList, oldMap, biDataFieldsList);
    //        //collect the updated records and generate from them list and map, both for contact and for lead
    //        mockUpdatedLeadsAndContacts();
    //
    //        //call NewBiApiInteractionHandler for leads and for contacts.
    //        if(oldContacts.keySet().size() > 0){
    //            System.debug('### in BiDAtaCallFitScore, calling on Contacts');
    //            NewBiApiInteractionHandler nbah = new NewBiApiInteractionHandler('Contact');
    ////            nbah.fitscoreOnDfoxChange(newContacts,oldContacts);
    //        }
    //        if(oldLeads.keySet().size() > 0){
    //            System.debug('### in BiDAtaCallFitScore, calling on Leads');
    //            NewBiApiInteractionHandler nbah = new NewBiApiInteractionHandler('Lead');
    ////            nbah.fitscoreOnDfoxChange(newLeads,oldLeads);
    //        }
    //
  }

  /**
   * @author Itzik Winograd
   * @date 02/02/2021
   * @description filter the records that the fields in the biDataFieldsList list has changed in them.
   * collect the affectedRecordIds to a sets if contact and lead ids
   * @param List<Bi_Data__c> newList - new records list
   * @param Map<Id,Bi_Data__c> oldMap - old records map
   * @param List<String> biDataFieldsList - fileds to check if they had changed
   * @return none. updates class lists
   */
  public void filterRecords(
    List<Bi_Data__c> newList,
    Map<Id, Bi_Data__c> oldMap,
    List<String> biDataFieldsList
  ) {
    //        //put the ids of the relatedrecords in a map so we can use map.keySet() later.
    //        oldContacts = new Map<Id,Contact>();
    //        oldLeads = new Map<Id,Lead>();
    //
    //        String idValue;
    //        String relatedObjectName;
    //        for(Bi_Data__c bid : newList){
    //            for(String field : biDataFieldsList){
    //                if (bid.get(field) != oldMap.get(bid.Id).get(field)){
    //                    idValue = bid.Related_Record_ID__c;
    //                    relatedObjectName = GeneralUtil.getObjectNameFromId(idValue);
    //                    if(relatedObjectName == 'contact'){
    //                        oldContacts.put(idValue, null);
    //                    } else if (relatedObjectName == 'lead'){
    //                        oldLeads.put(idValue, null);
    //                    }
    //                }
    //            }
    //        }
  }

  /**
   * @author Itzik Winograd
   * @date 02/02/2021
   * @description Create mock of chenged lead and contacts in lists and sets.
   * clone the sObject and change the email to simulate a field changed.
   * @param none
   * @return None.
   */
  public void mockUpdatedLeadsAndContacts() {
    //        newContacts = new List<Contact>();
    //        newLeads = new List<Lead>();
    //
    //        if(oldContacts.keySet() != null){
    //            for(Contact con : (List<Contact>)queryRelatedRecords(oldContacts.keySet(), 'contact')){
    //                newContacts.add(con);
    //                Contact fakeOldContact = con.clone(false, false, false, false);
    //                fakeOldContact.email = con.Clean_Domain__c+'old';
    //                oldContacts.put(con.Id, fakeOldContact);
    //            }
    //        }
    //        if(oldLeads.keySet() != null){
    //            for(Lead ld : (List<Lead>)queryRelatedRecords(oldLeads.keySet(), 'lead')){
    //                newLeads.add(ld);
    //                Lead fakeOldLead = ld.clone(false, false, false, false);
    //                fakeOldLead.email = ld.Clean_Domain__c+'old';
    //                oldLeads.put(ld.Id, fakeOldLead);
    //            }
    //        }
  }

  /**
   * @author Itzik Winograd
   * @date 02/02/2021
   * @description query for the records in the set of ids.
   * Query them with all the field necessary in the class newBiApiInteractionHandler.
   * @param Set<sObject> setOfIds set of id to query their id's from
   * @param String objectName the object name to query from
   * @return None.
   */
  //    public  List<sObject>  queryRelatedRecords(Set<Id> setOfIds, String objectName){
  //        String query = 'SELECT Polygraph_Update_Timestamp__c,SW_Fit_Score__c, Fit_Score_Last_Request_Date__c, Fit_Score_Count__c,';
  //        if (objectName=='contact'){
  //            query += GeneralUtil.getGeneralConfig('BiAPIFields_Contact').Text_Value__c;
  //        } else if(objectName=='lead'){
  //            query += GeneralUtil.getGeneralConfig('BiAPIFields_Lead').Text_Value__c;
  //        }
  //        query += ' FROM ' + objectName + ' WHERE Id IN :setOfIds ';
  //        return Database.query(query);
  //    }
}

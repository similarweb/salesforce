/**
 * @author Itzik Winograd
 * @date 21/02/2020
 * @description on contact creation, get values from the account to the new created contact.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public with sharing class ContactGetValuesFromAccount {
  private FieldMappingUtil.FieldMappingData fmd;

  /**
   * @author Itzik Winograd
   * @date 16/02/2021
   * @description: Main method.
   * @param List<Contact> newList - new list of contacts
   * @param Map<Id,Contact> oldMap - map of trigger.old contacts
   * @return none.
   */
  public void handle(List<SObject> newList, Map<Id, SObject> oldMap) {
    String customMetaDataName = '';
    if (oldMap == null) {
      //its an insert
      customMetaDataName = 'New Contact - Values from Account';
    } else {
      //its an update
      customMetaDataName = 'Account to Related Contacts';
      newList = filterChangedOwner(
        (List<Contact>) newList,
        (Map<Id, Contact>) oldMap
      );
    }
    List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
      customMetaDataName
    );
    FieldMappingUtil.FieldMappingData fmd = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(
      fieldsMappingList
    );
    Map<Id, Account> accounts = getFieldsFromCMD(newList, fmd);
    setValuesToContact(newList, accounts, fmd);
  }

  /**
   * @author Itzik Winograd
   * @date 21/02/2021
   * @description: Get the custom metadata fields, then create a query with all the source fields. Update the
   * @param List<Contact> newList - new list of contacts
   * @param FieldMappingUtil.FieldMappingData fmd - fieldMapping data, holding what account fields should pass to what fields on contacts
   * @return Map<Id,Account> of accounts to get the values from
   */
  private Map<Id, Account> getFieldsFromCMD(
    List<Contact> newList,
    FieldMappingUtil.FieldMappingData fmd
  ) {
    String fieldsToQuery = '';
    for (String source : fmd.sourceFieldSet) {
      fieldsToQuery += ', ' + source;
    }
    String query = 'SELECT Id ' + fieldsToQuery + ' FROM Account';
    return getAccounts(newList, query);
  }

  /**
   * @author Itzik Winograd
   * @date 21/02/2021
   * @description: Create a set of id from the contacts, then query accounts to create an account map;
   * update the class accounts map.
   * @param List<Contact> newList - list of new/updated contacts
   * @param String query - a query with the CMD values from the fields on the account object.
   * @return Map<Id,Account> of accounts to get the values from
   */
  private Map<Id, Account> getAccounts(List<Contact> newList, String query) {
    Set<Id> accountIds = new Set<Id>();
    for (Contact con : newList) {
      //Create set of account Id's to get values from
      if (con.AccountId != null) {
        accountIds.add(con.AccountId);
      }
    }
    query += ' WHERE Id IN :accountIds';
    System.debug('### full query: ' + query);
    return new Map<Id, Account>((List<Account>) Database.query(query));
  }

  /**
   * @author Itzik Winograd
   * @date 21/02/2021
   * @description: Assign the values from the Account to contact using the populateValuesFromSObject method.
   * Get the rellevant account by the AccountId on the contact.
   * update the class accounts map.
   * @param List<Contact> newList - new list of contacts
   * @param Map<Id,Account> accounts -  to get the values from and pass these values to the contacts.
   * @param FieldMappingUtil.FieldMappingData fmd - fieldMapping data, holding what account fields should pass to what fields on contacts
   * @return None.
   */
  private void setValuesToContact(
    List<Contact> newList,
    Map<Id, Account> accounts,
    FieldMappingUtil.FieldMappingData fmd
  ) {
    for (Contact con : newList) {
      fmd.populateValuesFromSObject((SObject) accounts.get(con.AccountId)); //assign values to the contact from the matching account
      Object obj;
      for (String destinationField : fmd.fieldMappingDataUnitMap.keySet()) {
        //loop over all the destination-field values
        obj = fmd.fieldMappingDataUnitMap.get(destinationField).getValue();
        con.put(destinationField, obj); //put in the prototypeChild a value from the parent
        System.debug(
          '### destinationField: ' + destinationField + ', value: ' + obj
        );
      }
    }
  }

  /**
   * @author Itzik Winograd
   * @date 16/06/2021
   * @description: check if the accountId is changed on these records. return only changed records.
   * @param List<Contact> newList - new list of contacts
   * @param Map<Id,Contact> oldMap - map of trigger.old contacts
   * @return List<Contact> filterd contacts.
   */
  public List<Contact> filterChangedOwner(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    List<Contact> filteredContacts = new List<Contact>();
    for (Contact con : newList) {
      if (con.AccountId != oldMap.get(con.Id).get('AccountId')) {
        filteredContacts.add(con);
      }
    }
    return filteredContacts;
  }
}

@isTest
public class DistributeAccountValuesToContactTest {
  /**
   * @author Itzik Winograd
   * @date 15/03/2021
   * @description: Test setup. create account and related contacts
   *               Important! The value on the custom metadata General Configuration - Account_to_Related_Contacts_Batch_Size	should be 10!
   */
  @testSetup
  public static void distributeAccountValuesToContactMakeData() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );

    Integer BATCH_LIMIT = Integer.valueOf(
      GeneralUtil.getGeneralConfig('Account_to_Related_Contacts_Batch_Size')
        .Number_Value__c
    );
    Integer N = BATCH_LIMIT;
    //Insert account
    List<Account> accountList = AccountUtils.getAccounts(N);
    insert accountList;
    //insert contact
    List<Contact> allContacts = new List<Contact>();
    for (Account acc : accountList) {
      List<Contact> cons = ContactUtils.getContactsForAccount(1, acc);
      allContacts.addAll(cons);
    }
    Test.startTest();
    System.debug('@@@ allContacts.size(): ' + allContacts);
    insert allContacts;
    Test.stopTest();
  }
  /**
   * @Author Itzik Winograd
   * @Date 15/03/2021
   * @Description: Update the fields in the custom meta data on accounts.
   * @Expected: The maching fields on this Account's contact will be updated with the same values.
   */
  @isTest
  public static void distributeAccountValuesToContactTest() {
    List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
      'Account to Related Contacts'
    );
    //get Accounts
    Map<Id, Account> accountsMap = new Map<Id, Account>(
      [
        SELECT Id
        FROM Account
      ]
    );
    //update Account
    for (Id accId : accountsMap.keySet()) {
      setValuesFromCMD(accountsMap.get(accId), 1);
    }
    Test.startTest();
    update accountsMap.values();
    Test.stopTest();
    //verify related contact was updated
    Map<String, String> destinationVsSource = new Map<String, String>();
    String source = '';
    String destination = '';
    for (Fields_Mapping__mdt fmp : fieldsMappingList) {
      destination = fmp.Destination_Field__c;
      source = fmp.Source_Field__c;
      destinationVsSource.put(destination, source);
    }
    String fullQuery =
      'SELECT Id ' +
      getContactsFieldsToQuery() +
      ' FROM Contact LIMIT 16';
    System.debug('### test fullQuery: ' + fullQuery);
    List<Contact> contactList = Database.query(fullQuery);
    for (Contact con : contactList) {
      for (String dest : destinationVsSource.keySet()) {
        System.assertEquals(
          con.getSObject('Account').get(destinationVsSource.get(dest)),
          con.get(dest),
          'Error: ' + con.get(dest) + ' do not match!'
        );
      }
    }

    //Verify that no accounts are left with "Pass_Values_to_Related_Records__c" true
    Integer accountsWithTruePass = Database.countQuery(
      'SELECT COUNT() FROM Account WHERE Pass_Values_to_Related_Records__c = true'
    );
    System.assertEquals(
      0,
      accountsWithTruePass,
      'Error: Not all accounts were unflagged!'
    );
  }

  /**
   * date: 13/06/2021
   * description: set values from the custom metadata to the SObject
   * @param SObject sobj - the sobject to put values in
   * @param Integer num - a number to add to the text in the fields
   */

  public static void setValuesFromCMD(SObject sobj, Integer num) {
    List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
      'Account to Related Contacts'
    );
    FieldMappingUtil.FieldMappingData fmd = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(
      fieldsMappingList
    );
    Set<String> accFieldsList = fmd.sourceFieldSet;
    for (String fieldName : accFieldsList) {
      Schema.DisplayType fielddataType = Schema.getGlobalDescribe()
        .get('Account')
        .getDescribe()
        .fields
        .getMap()
        .get(fieldName)
        .getDescribe()
        .getType();
      if (fielddataType == Schema.DisplayType.TextArea) {
        sobj.put(fieldName, 'SomeValue' + num);
      } else if (fielddataType == Schema.DisplayType.String) {
        sobj.put(fieldName, 'SomeValue' + num);
      } else if (fielddataType == Schema.DisplayType.Integer) {
        sobj.put(fieldName, num);
      } else if (fielddataType == Schema.DisplayType.Double) {
        sobj.put(fieldName, num);
      } else if (fielddataType == Schema.DisplayType.DateTime) {
        sobj.put(fieldName, Datetime.now());
      }
    }
  }
  /**
   * @Author Itzik Winograd
   * @Date 16/06/2021
   * @Description: Merge 2 accounts and verify that the contact got the values from the masteAcct
   * @Expected: The maching fields on this Account's contact will be updated with the same values.
   */
  @isTest
  public static void distributeAccountValuesTestMerge() {
    List<Account> accounts = new List<Account>(
      [
        SELECT Id, Name, Base_Product__c
        FROM Account
        LIMIT 2
      ]
    );
    System.debug('@@@ accounts : ' + accounts);
    String masterAcctId = accounts[0].Id;
    Account masterAcct = accounts[0];
    String mergeAcctId = accounts[1].Id;
    Account mergeAcct = accounts[1];
    //insert 2 contacts to the mergeAcct
    List<Contact> cons = ContactUtils.getContactsForAccount(2, mergeAcct);
    insert cons;
    //put 3 in mergeAcct so it will cascate to the contacts
    setValuesFromCMD(mergeAcct, 3);
    //put 5 in the masterAcct. We will expect this value after merge.
    setValuesFromCMD(masterAcct, 55);
    update accounts;

    Test.startTest();
    String fullQuery =
      'SELECT Id ' +
      getContactsFieldsToQuery() +
      ' FROM Contact WHERE AccountId = :mergeAcctId';
    System.debug(
      '@@@ Contacts of mergeAcct - before merge: ' + Database.query(fullQuery)
    );
    merge masterAcct mergeAcct;
    Test.stopTest();
    fullQuery =
      'SELECT Id ' +
      getContactsFieldsToQuery() +
      ' FROM Contact WHERE AccountId = :masterAcctId';
    String afterResults = '' + Database.query(fullQuery);
    System.debug('@@@ Contact of masterAcct - after merge: ' + afterResults);
    System.assert(
      afterResults.contains('55'),
      '@@@ Error: contacts does not contain the master values.'
    );
  }

  //Create a query from the custom meta data fields
  public static String getContactsFieldsToQuery() {
    String query = '';
    String source = '';
    String destination = '';
    List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
      'Account to Related Contacts'
    );
    for (Fields_Mapping__mdt fmp : fieldsMappingList) {
      destination = fmp.Destination_Field__c;
      source = fmp.Source_Field__c;
      query += ', ' + destination + ', ' + 'Account.' + source + ' ';
    }
    return query;
  }
}

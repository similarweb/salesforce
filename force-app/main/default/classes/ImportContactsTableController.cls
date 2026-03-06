public with sharing class ImportContactsTableController {
  private static final List<String> APEX_JOB_STATUSES = new List<String>{
    'Holding',
    'Queued',
    'Preparing',
    'Processing'
  };
  private static final List<String> NEEDED_CONTACT_FIELDS = new List<String>{
    'AccountId',
    'Email',
    'FirstName',
    'LastName',
    'Title',
    'Department__c',
    'Original_Lead_Source__c',
    'Phone',
    'MobilePhone',
    'MailingCountry',
    'ContactId',
    'otherPhone',
    'LinkedIn_Profile__c'
  };

  @AuraEnabled(cacheable=true)
  public static Response getPicklistsValues() {
    Response response;
    try {
      Map<String, Object> resulPicklistsOptions = new Map<String, Object>();
      resulPicklistsOptions.put(
        'DepartmentOptions',
        getStandartObjectPicklistValues(
          getSObjectFieldDescribe('Contact', 'Department__c')
        )
      );
      resulPicklistsOptions.put(
        'LeadSourceOptions',
        getStandartObjectPicklistValues(
          getSObjectFieldDescribe('Contact', 'Original_Lead_Source__c')
        )
      );

      List<PicklistWrapper> countryPicklistOptions = new List<PicklistWrapper>();
      countryPicklistOptions.add(new PicklistWrapper('', ''));

      //            List<Country_Picklist_Values__mdt> countryList = [SELECT Id, CountryName__c FROM Country_Picklist_Values__mdt ORDER BY CountryName__c];
      Schema.DescribeFieldResult fieldResult = User.Countrycode.getDescribe();
      List<Schema.PicklistEntry> countryPicklistEntries = fieldResult.getPicklistValues();
      List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(
        User.StateCode.getDescribe().getPicklistValues()
      );
      Map<String, CountryWrapper> countryToStatePicklistMap = new Map<String, CountryWrapper>();
      countryToStatePicklistMap.put('', new CountryWrapper('', ''));
      List<String> controllingValues = new List<String>();

      for (Schema.PicklistEntry ple : countryPicklistEntries) {
        String label = ple.getLabel();
        CountryWrapper countryWrapper = new CountryWrapper(label, label);
        countryToStatePicklistMap.put(label, countryWrapper);
        //countryPicklistOptions.add(countryWrapper);
        controllingValues.add(label);
      }

      for (PicklistEntryWrapper plew : depEntries) {
        String label = plew.label;
        String validForBits = base64ToBits(plew.validFor);
        for (Integer i = 0; i < validForBits.length(); i++) {
          // For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
          String bit = validForBits.mid(i, 1);
          if (bit == '1') {
            countryToStatePicklistMap.get(controllingValues.get(i))
              .stateList.add(new PicklistWrapper(label, label));
          }
        }
      }

      for (Schema.PicklistEntry pickListVal : countryPicklistEntries) {
        countryPicklistOptions.add(
          new PicklistWrapper(pickListVal.getLabel(), pickListVal.getLabel())
        );
      }

      resulPicklistsOptions.put(
        'CountryPicklistOptions',
        countryPicklistOptions
      );
      resulPicklistsOptions.put(
        'CountryToStatePicklistMap',
        countryToStatePicklistMap
      );

      response = new Response(resulPicklistsOptions);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  private static List<PicklistEntryWrapper> wrapPicklistEntries(
    List<Schema.PicklistEntry> PLEs
  ) {
    return (List<PicklistEntryWrapper>) JSON.deserialize(
      JSON.serialize(PLEs),
      List<PicklistEntryWrapper>.class
    );
  }

  private static String base64ToBits(String validFor) {
    String base64Chars =
      '' +
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
      'abcdefghijklmnopqrstuvwxyz' +
      '0123456789+/';
    if (String.isEmpty(validFor))
      return '';

    String validForBits = '';

    for (Integer i = 0; i < validFor.length(); i++) {
      String thisChar = validFor.mid(i, 1);
      Integer val = base64Chars.indexOf(thisChar);
      String bits = decimalToBinary(val).leftPad(6, '0');
      validForBits += bits;
    }

    return validForBits;
  }

  public static String decimalToBinary(Integer val) {
    String bits = '';
    while (val > 0) {
      Integer remainder = Math.mod(val, 2);
      val = Integer.valueOf(Math.floor(val / 2));
      bits = String.valueOf(remainder) + bits;
    }
    return bits;
  }

  @AuraEnabled
  public static Response getDraftRecords() {
    Response response;
    try {
      List<ContactDraft__c> draftRecords = [
        SELECT
          Id,
          AccountId__c,
          Email__c,
          FirstName__c,
          LastName__c,
          Title__c,
          Department__c,
          OriginalLeadSource__c,
          Phone__c,
          Mobile__c,
          Country__c,
          City__c,
          State__c,
          ContactId__c,
          UploadStatus__c,
          isValid__c,
          Other_Phone__c,
          LinkedIn_Profile__c
        FROM ContactDraft__c
        WHERE CreatedById = :UserInfo.getUserId()
      ];

      List<TableItemWrapper> tableItemsList = buildTableItemsList(draftRecords);
      for (TableItemWrapper tbi : tableItemsList) {
        System.debug(tbi);
      }
      response = new Response(tableItemsList);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response getContactFieldsCharLimits() {
    Response response;
    try {
      Map<String, Integer> mapFieldToCharAmount = getFieldsCharLimits();

      response = new Response(mapFieldToCharAmount);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response checkIfSandbox() {
    Response response;
    try {
      Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1]
      .IsSandbox;

      response = new Response(isSandbox);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response saveDraft(String draftObjectJSON) {
    Response response;
    try {
      TableItemWrapper draftObjectToImport = (TableItemWrapper) JSON.deserialize(
        draftObjectJSON,
        TableItemWrapper.class
      );
      ContactDraft__c draftObject = buildDraft(draftObjectToImport, null);

      upsert draftObject;

      response = new Response(new TableItemWrapper(draftObject));
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response importContacts(String contactsToImportJSON) {
    system.debug('alon started');
    Response response;
    try {
      List<AsyncApexJob> activeApexJobs = [
        SELECT Id, CreatedBy.Name
        FROM AsyncApexJob
        WHERE
          JobType = 'BatchApex'
          AND ApexClass.Name = 'ContactsImportBatch'
          AND CreatedById = :UserInfo.getUserId()
          AND Status IN :APEX_JOB_STATUSES
      ];
      if (activeApexJobs.isEmpty()) {
        Boolean dupEmail = false;
        Set<String> emails = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        List<Contact> enteredContacts = new List<Contact>();
        List<Contact> contactToUpsert = new List<Contact>();
        List<TableItemWrapper> returnTabItem = new List<TableItemWrapper>();
        Map<String, String> emailToDraftId = new Map<String, String>();
        Map<String, TableItemWrapper> emailToDraft = new Map<String, TableItemWrapper>();
        List<TableItemWrapper> wrappedContacts = (List<TableItemWrapper>) JSON.deserialize(
          contactsToImportJSON,
          List<TableItemWrapper>.class
        );
        System.debug(wrappedContacts);
        for (TableItemWrapper wc_i : wrappedContacts) {
          accountIds.add(wc_i.AccountId);
        }
        Map<ID, Account> idToAccMap = new Map<ID, Account>(
          [SELECT Id, OwnerId, Name FROM Account WHERE Id IN :accountIds]
        );

        for (TableItemWrapper wc_i : wrappedContacts) {
          if (String.isNotBlank(wc_i.AccountId)) {
            if (!emails.contains(wc_i.Email)) {
              emails.add(wc_i.Email);
              Contact newCont = buildContact(wc_i);
              Account acc = idToAccMap.get(wc_i.AccountId);
              System.debug(acc);
              if (acc != null) {
                newCont.OwnerId = acc.OwnerId;
              }
              enteredContacts.add(newCont);
              // enteredContacts.add(buildContact(wc_i));
              emailToDraftId.put(wc_i.Email, wc_i.draftId);
              emailToDraft.put(wc_i.Email, wc_i);
            } else {
              dupEmail = true;
              wc_i.UploadStatus = 'Such email is already entered!';
              returnTabItem.add(wc_i);
            }
          }
        }

        // if(!dupEmail){
        Map<String, Contact> emailToExistContact = new Map<String, Contact>();
        List<Contact> existingContacts = [
          SELECT Id, FirstName, LastName, Email, AccountId, Account.OwnerId
          FROM Contact
          WHERE Email IN :emails
        ];
        if (!existingContacts.isEmpty()) {
          for (Contact contact_i : existingContacts) {
            emailToExistContact.put(contact_i.Email, contact_i);
          }
        }

        if (!emailToExistContact.isEmpty()) {
          for (Contact contact_i : enteredContacts) {
            if (
              emailToExistContact.containsKey(contact_i.Email) &&
              String.isBlank(contact_i.Id)
            ) {
              Contact existingContact = emailToExistContact.get(
                contact_i.Email
              );
              if (contact_i.AccountId != existingContact.AccountId) {
                TableItemWrapper tiw = emailToDraft.get(contact_i.Email);
                tiw.UploadStatus = 'Contact with such email exists on another account!';
                tiw.isValid = false;
                returnTabItem.add(tiw);
              } else {
                Contact exCont = new Contact();
                exCont.Id = existingContact.Id;
                exCont.Email = contact_i.Email;
                exCont.Department__c = contact_i.Department__c;
                exCont.Phone = contact_i.Phone;
                exCont.MobilePhone = contact_i.MobilePhone;
                exCont.AccountId = contact_i.AccountId;
                exCont.FirstName = existingContact.FirstName;
                exCont.LastName = existingContact.LastName;
                contactToUpsert.add(exCont);
              }
            } else {
              contactToUpsert.add(contact_i);
            }
          }
        } else {
          contactToUpsert.addAll(enteredContacts);
        }
        System.debug(contactToUpsert);

        if (!contactToUpsert.isEmpty()) {
          ContactsImportBatch importBatch = new ContactsImportBatch(
            contactToUpsert,
            emailToDraftId
          );
          Id batchId = Database.executeBatch(importBatch, 50);
        }

        response = new Response(buildTableItemsListAfterImport(returnTabItem));
        // } else{
        // response = new Response(true, 'Some of the emails are duplicated!',buildTableItemsListAfterImport(wrappedContacts));
        // }
      } else {
        response = new Response(
          true,
          'Contact import is already in progress! Please, expect email once it is done',
          buildTableItemsListAfterImport(
            (List<TableItemWrapper>) JSON.deserialize(
              contactsToImportJSON,
              List<TableItemWrapper>.class
            )
          )
        );
      }
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response csvImport(String jsonCsv) {
    Response response;
    try {
      Integer step = 0;
      Integer columnIndex = 0;
      Map<Integer, String> columIndexToName = new Map<Integer, String>();
      List<List<String>> parsedCsvFileRows = CSVReader.read(jsonCsv);
      for (List<String> row_i : parsedCsvFileRows) {
        System.debug(row_i);
        if (step == 0) {
          for (Integer i = 0; i < row_i.size(); i++) {
            System.debug(row_i[i]);
            System.debug(row_i[i].normalizeSpace());
            if (checkIfColumnIsNeeded(row_i[i].normalizeSpace())) {
              // columIndexToName.put(columnIndex,row_i[i]);
              columIndexToName.put(i, row_i[i]);
              columnIndex++;
            }
            System.debug(i);
          }
          step++;
        }
        for (String a : row_i) {
          System.debug(a);
        }
      }
      step = 0;
      List<TableItemWrapper> tableItemsList = new List<TableItemWrapper>();
      System.debug(parsedCsvFileRows);
      System.debug(columIndexToName);
      for (List<String> row_i : parsedCsvFileRows) {
        if (step == 0) {
          step++;
        } else {
          tableItemsList.add(new TableItemWrapper(row_i, columIndexToName));
        }
      }
      List<ContactDraft__c> newDrafts = new List<ContactDraft__c>();
      System.debug(tableItemsList);
      Map<String, Integer> mapFieldToCharAmount = getFieldsCharLimits();
      for (TableItemWrapper tabItem_i : tableItemsList) {
        newDrafts.add(buildDraft(tabItem_i, mapFieldToCharAmount));
      }
      if (!newDrafts.isEmpty()) {
        insert newDrafts;
      }

      List<TableItemWrapper> newTabItems = new List<TableItemWrapper>();
      System.debug(newDrafts);
      for (ContactDraft__c cd_i : newDrafts) {
        newTabItems.add(new TableItemWrapper(cd_i));
      }
      // response = new Response(true,'New drafts are saved!');
      System.debug(newTabItems);
      response = new Response(newTabItems);
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response deleteDrafts(String contactsToImportJSON) {
    Response response;
    try {
      List<TableItemWrapper> wrappedContacts = (List<TableItemWrapper>) JSON.deserialize(
        contactsToImportJSON,
        List<TableItemWrapper>.class
      );

      List<ContactDraft__c> draftsToDelete = new List<ContactDraft__c>();

      for (TableItemWrapper tiw_i : wrappedContacts) {
        if (String.isNotBlank(tiw_i.draftId)) {
          ContactDraft__c draftTodel = new ContactDraft__c(Id = tiw_i.draftId);
          draftsToDelete.add(draftTodel);
        }
      }

      if (!draftsToDelete.isEmpty()) {
        delete draftsToDelete;
      }

      response = new Response(buildTableItemsList(new List<ContactDraft__c>()));
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @AuraEnabled
  public static Response deleteOneDraft(String draftObjectJSON) {
    Response response;
    try {
      TableItemWrapper draftObjectToImport = (TableItemWrapper) JSON.deserialize(
        draftObjectJSON,
        TableItemWrapper.class
      );
      ContactDraft__c draftObject = buildDraft(draftObjectToImport, null);
      System.debug(draftObject);

      if (String.isNotBlank(draftObject.Id)) {
        delete draftObject;
      }

      response = new Response(new TableItemWrapper());
    } catch (Exception ex) {
      response = new Response(ex.getMessage());
    }
    return response;
  }

  @testVisible
  private static ContactDraft__c buildDraft(
    TableItemWrapper enteredTabItem,
    Map<String, Integer> fieldsCharLimits
  ) {
    Boolean isMapEmpty = fieldsCharLimits == null;
    ContactDraft__c draftObject = new ContactDraft__c();
    draftObject.AccountId__c = (!isMapEmpty &&
      fieldsCharLimits.get('Account') < enteredTabItem.AccountId.length())
      ? ''
      : enteredTabItem.AccountId;
    draftObject.Email__c = (!isMapEmpty &&
      fieldsCharLimits.get('Email') < enteredTabItem.Email.length())
      ? cutFieldValue(enteredTabItem.Email, fieldsCharLimits.get('Email'))
      : enteredTabItem.Email;
    draftObject.FirstName__c = (!isMapEmpty &&
      fieldsCharLimits.get('FirstName') < enteredTabItem.FirstName.length())
      ? cutFieldValue(
          enteredTabItem.FirstName,
          fieldsCharLimits.get('FirstName')
        )
      : enteredTabItem.FirstName;
    draftObject.LastName__c = (!isMapEmpty &&
      fieldsCharLimits.get('LastName') < enteredTabItem.LastName.length())
      ? cutFieldValue(enteredTabItem.LastName, fieldsCharLimits.get('LastName'))
      : enteredTabItem.LastName;
    draftObject.Title__c = (!isMapEmpty &&
      fieldsCharLimits.get('Title') < enteredTabItem.Title.length())
      ? cutFieldValue(enteredTabItem.Title, fieldsCharLimits.get('Title'))
      : enteredTabItem.Title;
    draftObject.Department__c = enteredTabItem.Department;
    draftObject.City__c = enteredTabItem.City;
    draftObject.State__c = enteredTabItem.State;
    draftObject.OriginalLeadSource__c = enteredTabItem.OriginalLeadSource;
    draftObject.Phone__c = (!isMapEmpty &&
      fieldsCharLimits.get('Phone') < enteredTabItem.Phone.length())
      ? cutFieldValue(enteredTabItem.Phone, fieldsCharLimits.get('Phone'))
      : enteredTabItem.Phone;
    draftObject.Mobile__c = (!isMapEmpty &&
      fieldsCharLimits.get('Mobile') < enteredTabItem.Mobile.length())
      ? cutFieldValue(enteredTabItem.Mobile, fieldsCharLimits.get('Mobile'))
      : enteredTabItem.Mobile;
    draftObject.Country__c = enteredTabItem.Country;
    draftObject.ContactId__c = (!isMapEmpty &&
      fieldsCharLimits.get('Contact') < enteredTabItem.ContactId.length())
      ? ''
      : enteredTabItem.ContactId;
    draftObject.UploadStatus__c = enteredTabItem.UploadStatus;
    draftObject.Other_Phone__c = (!isMapEmpty &&
      fieldsCharLimits.get('OtherPhone') < enteredTabItem.otherPhone.length())
      ? cutFieldValue(
          enteredTabItem.otherPhone,
          fieldsCharLimits.get('OtherPhone')
        )
      : enteredTabItem.otherPhone;
    draftObject.LinkedIn_Profile__c = (!isMapEmpty &&
      fieldsCharLimits.get('LinkedInProfile') <
      enteredTabItem.linkedInProfile.length())
      ? cutFieldValue(
          enteredTabItem.linkedInProfile,
          fieldsCharLimits.get('LinkedInProfile')
        )
      : enteredTabItem.linkedInProfile;
    draftObject.isValid__c = enteredTabItem.isValid;
    if (
      enteredTabItem.draftId != null &&
      String.isNotBlank(enteredTabItem.draftId)
    ) {
      draftObject.Id = enteredTabItem.draftId;
    }

    return draftObject;
  }

  @testVisible
  private static Contact buildContact(TableItemWrapper enteredTabItem) {
    Contact newContact = new Contact();
    newContact.AccountId = enteredTabItem.AccountId;
    newContact.Email = enteredTabItem.Email;
    newContact.FirstName = enteredTabItem.FirstName;
    newContact.LastName = enteredTabItem.LastName;
    newContact.Title = enteredTabItem.Title;
    newContact.Department__c = enteredTabItem.Department;
    newContact.Original_Lead_Source__c = enteredTabItem.OriginalLeadSource;
    newContact.LeadSource = enteredTabItem.OriginalLeadSource;
    newContact.Phone = enteredTabItem.Phone;
    newContact.MobilePhone = enteredTabItem.Mobile;
    newContact.MailingCountry = enteredTabItem.Country;
    newContact.MailingState = enteredTabItem.State;
    newContact.MailingCity = enteredTabItem.City;
    newContact.LinkedIn_Profile__c = enteredTabItem.linkedInProfile;
    newContact.OtherPhone = enteredTabItem.otherPhone;
    if (String.isNotBlank(enteredTabItem.ContactId)) {
      newContact.Id = enteredTabItem.ContactId;
    }
    return newContact;
  }

  @testVisible
  private static String cutFieldValue(String fieldValue, Integer maxLength) {
    return fieldValue.left(maxLength);
  }

  @testVisible
  private static List<TableItemWrapper> buildTableItemsList(
    List<ContactDraft__c> draftRecords
  ) {
    List<TableItemWrapper> tableItemsList = new List<TableItemWrapper>();
    for (integer i = 0; i < 50; i++) {
      tableItemsList.add(new TableItemWrapper());
    }
    if (!draftRecords.isEmpty()) {
      for (integer i = 0; i < draftRecords.size(); i++) {
        if (i < tableItemsList.size()) {
          tableItemsList[i] = new TableItemWrapper(draftRecords[i]);
        } else {
          tableItemsList.add(new TableItemWrapper(draftRecords[i]));
        }
      }
    }

    return tableItemsList;
  }

  @testVisible
  private static List<TableItemWrapper> buildTableItemsListAfterImport(
    List<TableItemWrapper> tabItems
  ) {
    if (!tabItems.isEmpty()) {
      if (tabItems.size() < 50) {
        while (tabItems.size() < 50) {
          tabItems.add(new TableItemWrapper());
        }
      }
    } else {
      for (integer i = 0; i < 50; i++) {
        tabItems.add(new TableItemWrapper());
      }
    }
    return tabItems;
  }

  @testVisible
  private static List<PicklistWrapper> getStandartObjectPicklistValues(
    Schema.DescribeFieldResult fieldResult
  ) {
    List<PicklistWrapper> valueList = new List<PicklistWrapper>();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry pickListVal : ple) {
      valueList.add(
        new PicklistWrapper(pickListVal.getLabel(), pickListVal.getValue())
      );
    }

    return valueList;
  }

  @testVisible
  private static Schema.DescribeFieldResult getSObjectFieldDescribe(
    String objectApiName,
    String fieldApiName
  ) {
    Schema.SObjectType obj_describe = Schema.getGlobalDescribe()
      .get(objectApiName);
    Schema.DescribeSObjectResult obj_describe_result = obj_describe.getDescribe();
    Map<String, Schema.SObjectField> fields = obj_describe_result.fields.getMap();
    Schema.DescribeFieldResult fieldResult = fields.get(fieldApiName)
      .getDescribe();
    return fieldResult;
  }

  @testVisible
  private static Boolean checkIfColumnIsNeeded(String fieldName) {
    Boolean isColumValid = false;
    System.debug(fieldName);
    for (String fieldName_i : NEEDED_CONTACT_FIELDS) {
      if (fieldName.equalsIgnoreCase(fieldName_i)) {
        isColumValid = true;
      }
    }
    return isColumValid;
  }

  @testVisible
  private static Map<String, Integer> getFieldsCharLimits() {
    Map<String, Integer> mapFieldToCharAmount = new Map<String, Integer>();
    mapFieldToCharAmount.put(
      'Title',
      getSObjectFieldDescribe('Contact', 'Title').getLength()
    );
    mapFieldToCharAmount.put(
      'Phone',
      getSObjectFieldDescribe('Contact', 'Phone').getLength()
    );
    mapFieldToCharAmount.put(
      'Mobile',
      getSObjectFieldDescribe('Contact', 'MobilePhone').getLength()
    );
    mapFieldToCharAmount.put(
      'FirstName',
      getSObjectFieldDescribe('Contact', 'FirstName').getLength()
    );
    mapFieldToCharAmount.put(
      'LastName',
      getSObjectFieldDescribe('Contact', 'LastName').getLength()
    );
    mapFieldToCharAmount.put(
      'Account',
      getSObjectFieldDescribe('Contact', 'AccountId').getLength()
    );
    mapFieldToCharAmount.put(
      'Email',
      getSObjectFieldDescribe('Contact', 'Email').getLength()
    );
    mapFieldToCharAmount.put(
      'Contact',
      getSObjectFieldDescribe('Contact', 'Id').getLength()
    );
    mapFieldToCharAmount.put(
      'OtherPhone',
      getSObjectFieldDescribe('Contact', 'OtherPhone').getLength()
    );
    mapFieldToCharAmount.put(
      'LinkedInProfile',
      getSObjectFieldDescribe('Contact', 'LinkedIn_Profile__c').getLength()
    );

    return mapFieldToCharAmount;
  }

  public class TableItemWrapper {
    @AuraEnabled
    public String AccountId;
    @AuraEnabled
    public String Email;
    @AuraEnabled
    public String FirstName;
    @AuraEnabled
    public String LastName;
    @AuraEnabled
    public String Title;
    @AuraEnabled
    public String Department;
    @AuraEnabled
    public String OriginalLeadSource;
    @AuraEnabled
    public String Phone;
    @AuraEnabled
    public String Mobile;
    @AuraEnabled
    public String Country;
    @AuraEnabled
    public String State;
    @AuraEnabled
    public String City;
    @AuraEnabled
    public String ContactId;
    @AuraEnabled
    public String UploadStatus;
    @AuraEnabled
    public Boolean isValid;
    @AuraEnabled
    public String draftId;
    @AuraEnabled
    public String otherPhone;
    @AuraEnabled
    public String linkedInProfile;

    public TableItemWrapper() {
      this.AccountId = '';
      this.Email = '';
      this.FirstName = '';
      this.LastName = '';
      this.Title = '';
      this.Department = '';
      this.OriginalLeadSource = '';
      this.Phone = '';
      this.Mobile = '';
      this.Country = '';
      this.City = '';
      this.State = '';
      this.ContactId = '';
      this.UploadStatus = '';
      this.isValid = false;
      this.draftId = '';
      this.otherPhone = '';
      this.linkedInProfile = '';
    }

    public TableItemWrapper(ContactDraft__c draftRecord) {
      // this.AccountId = draftRecord.Account__c;
      this.AccountId = draftRecord.AccountId__c == null
        ? ''
        : draftRecord.AccountId__c;
      this.Email = draftRecord.Email__c == null ? '' : draftRecord.Email__c;
      this.FirstName = draftRecord.FirstName__c == null
        ? ''
        : draftRecord.FirstName__c;
      this.LastName = draftRecord.LastName__c == null
        ? ''
        : draftRecord.LastName__c;
      this.Title = draftRecord.Title__c == null ? '' : draftRecord.Title__c;
      this.Department = draftRecord.Department__c == null
        ? ''
        : draftRecord.Department__c;
      this.OriginalLeadSource = draftRecord.OriginalLeadSource__c == null
        ? ''
        : draftRecord.OriginalLeadSource__c;
      this.Phone = draftRecord.Phone__c == null ? '' : draftRecord.Phone__c;
      this.Mobile = draftRecord.Mobile__c == null ? '' : draftRecord.Mobile__c;
      this.Country = draftRecord.Country__c == null
        ? ''
        : draftRecord.Country__c;
      this.City = draftRecord.City__c == null ? '' : draftRecord.City__c;
      this.State = draftRecord.State__c == null ? '' : draftRecord.State__c;
      // this.ContactId = draftRecord.Contact__c;
      this.ContactId = draftRecord.ContactId__c == null
        ? ''
        : draftRecord.ContactId__c;
      this.UploadStatus = draftRecord.UploadStatus__c == null
        ? ''
        : draftRecord.UploadStatus__c;
      this.isValid = draftRecord.isValid__c;
      this.draftId = draftRecord.Id;
      this.otherPhone = draftRecord.Other_Phone__c == null
        ? ''
        : draftRecord.Other_Phone__c;
      this.linkedInProfile = draftRecord.LinkedIn_Profile__c == null
        ? ''
        : draftRecord.LinkedIn_Profile__c;
    }

    public TableItemWrapper(
      List<String> columns,
      Map<Integer, String> columIndexToName
    ) {
      this();
      System.debug(columns);
      System.debug(columIndexToName);
      for (integer i = 0; i < columns.size(); i++) {
        System.debug(columIndexToName.get(i));
        System.debug(columIndexToName.get(i));
        if (columIndexToName.containsKey(i)) {
          String columnName = columIndexToName.get(i).normalizeSpace();
          System.debug(columnName);
          if (columnName.equalsIgnoreCase('AccountId')) {
            this.AccountId = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('Email')) {
            this.Email = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('FirstName')) {
            this.FirstName = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('LastName')) {
            this.LastName = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('Title')) {
            this.Title = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('Department__c')) {
            this.Department = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('Original_Lead_Source__c')) {
            this.OriginalLeadSource = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('Phone')) {
            this.Phone = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('MobilePhone')) {
            this.Mobile = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('MailingCountry')) {
            this.Country = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('ContactId')) {
            this.ContactId = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('otherPhone')) {
            this.otherPhone = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          } else if (columnName.equalsIgnoreCase('LinkedIn_Profile__c')) {
            this.linkedInProfile = String.isBlank(columns[i])
              ? ''
              : columns[i].normalizeSpace();
          }
        }
      }
      this.UploadStatus = '';
      this.isValid = false;
      this.draftId = '';
      System.debug(this);
    }
  }

  public class PicklistWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public Boolean isSelected;

    public PicklistWrapper(String value, String label) {
      this.value = value;
      this.label = label;
      this.isSelected = false;
    }
  }

  public class CountryWrapper {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public Boolean isSelected;
    @AuraEnabled
    public List<PicklistWrapper> stateList;

    public CountryWrapper(String value, String label) {
      this.value = value;
      this.label = label;
      this.isSelected = false;
      this.stateList = new List<ImportContactsTableController.PicklistWrapper>{
        new ImportContactsTableController.PicklistWrapper('', '')
      };
    }
  }

  public class PicklistEntryWrapper {
    public String active { get; set; }
    public String defaultValue { get; set; }
    public String label { get; set; }
    public String value { get; set; }
    public String validFor { get; set; }
  }
}

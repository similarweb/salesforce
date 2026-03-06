public with sharing class VoicenterLightningApexController {
  public class VoicenterCdrInsertResult {
    public object InsertResult { get; set; }
    public VoicenterCDR CDR { get; set; }
    public String Error { get; set; }
    public String WorkerID { get; set; }
    public String CustomerID { get; set; }
    public String ExistingTaskOID { get; set; }
  }

  public class FindObjectResponse {
    public String ID { get; set; }
    public String Name { get; set; }
    public String OrganizationName { get; set; }
    public String ObjectType { get; set; }
    public String Phone { get; set; }
    public object Raw { get; set; }
  }

  public class VoicenterCDR {
    public string CallID { get; set; }
    public string CallerExtension { get; set; }
    public string CallerNumber { get; set; }
    public Long DateEpoch { get; set; }
    public string DialStatus { get; set; }
    public integer Duration { get; set; }
    public integer ID { get; set; }
    public string RecordURL { get; set; }
    public string TargetExtension { get; set; }
    public string TargetNumber { get; set; }
    public integer UrlID { get; set; }
  }

  @AuraEnabled
  public static Task GetTaskDB(String paramID) {
    return [
      SELECT Id
      FROM Task
      WHERE Id = :paramID
    ];
  }

  @AuraEnabled
  public static String FindObjectByPhone(String phoneNumber) {
    List<List<sObject>> results = [
      FIND :phoneNumber
      IN PHONE FIELDS
      RETURNING
        Contact(Id, Phone, Name, Department),
        Account(Id, Phone, Name),
        Lead(Id, Phone, Company, Name)
    ];

    FindObjectResponse resp = new FindObjectResponse();
    resp.Raw = results;
    resp.Phone = phoneNumber;
    if (ValidateNumber(phoneNumber)) {
      if (results[0].size() > 0) {
        Contact cny = (Contact) results[0][0];
        resp.ID = cny.Id;
        resp.Name = cny.Name;
        resp.OrganizationName = cny.Department;
        resp.ObjectType = 'Contact';
      } else if (results[1].size() > 0) {
        Account accnt = (Account) results[1][0];
        resp.ID = accnt.Id;
        resp.Name = accnt.Name;
        resp.OrganizationName = accnt.Name;
        resp.ObjectType = 'Account';
      } else if (results[2].size() > 0) {
        Lead lny = (Lead) results[2][0];
        resp.ID = lny.Id;
        resp.Name = lny.Name;
        resp.OrganizationName = lny.Company;
        resp.ObjectType = 'Lead';
      }
    }

    /*
sObject[] records = ((List<sObject>)results[0]);
if (!records.isEmpty()) {
for (Integer i = 0; i < records.size(); i++) {
sObject record = records[i];   
if (record.getSObjectType() == Contact.getSObjectType()) {
// contacts.add((Contact) record);
//return ((String)((Contact) record).Id);
Contact cny = (Contact) record;
resp.ID = cny.Id;
resp.Name = cny.Name;
resp.OrganizationName = cny.Department;
resp.ObjectType = 'Contact';
}
else if (record.getSObjectType() == Lead.getSObjectType()){
//leads.add((Lead) record);
//return ((String)((Lead) record).Id);
Lead lny = (Lead) record;
resp.ID = lny.Id;
resp.Name = lny.Name;
resp.OrganizationName = lny.Company;
resp.ObjectType = 'Lead';
} 
else if (record.getSObjectType() == Account.getSObjectType()){
Account accnt = (Account)record;
resp.ID = accnt.Id;
resp.Name = accnt.Name;
resp.OrganizationName = accnt.Name;
resp.ObjectType = 'Account';
}
}
}*/
    String srt = JSON.serialize(resp);
    return srt;
    //return resp.ID;
    //return String.valueOf(results[0].size());
  }

  @AuraEnabled
  public static Boolean ValidateNumber(String phoneNumber) {
    phoneNumber = phoneNumber.deleteWhitespace();
    Boolean validPhoneNumber = false;
    if (phoneNumber.length() > 6) {
      if (phoneNumber.isNumeric() == true) {
        validPhoneNumber = true;
      } else {
        if (
          phoneNumber.equalsIgnoreCase('private') ||
          phoneNumber.equalsIgnoreCase('anonymous') ||
          phoneNumber.equalsIgnoreCase('restricted') ||
          phoneNumber.equalsIgnoreCase('unknown')
        ) {
          validPhoneNumber = true;
        }
      }
    }
    return validPhoneNumber;
  }

  @AuraEnabled
  public static String CreateTaskFromClick2Call(
    String ivrUniqueID,
    String customerID
  ) {
    // Check if task with given Ivr unique id already exists:
    VoicenterCdrInsertResult res = new VoicenterCdrInsertResult();
    res.Error = 'OK';
    res.WorkerID = '';
    res.CustomerID = '';
    res.ExistingTaskOID = '';

    ivrUniqueID = ivrUniqueID.trim();

    if (ivrUniqueID == '') {
      res.Error = 'Empty ivr id';
      return (String) JSON.serialize(res);
    }

    /*List<List<sObject>> results = [FIND :ivrUniqueID
IN ALL FIELDS
RETURNING 
Task(Id)];

if(results[0].size() > 0) {
res.Error = 'Already exists';
Task task = (Task)results[0][0];
res.ExistingTaskOID = task.Id;
return res;
}*/

    try {
      Task t = new Task(
        OwnerId = UserInfo.getUserId(),
        Subject = 'Call',
        Status = 'Open',
        Priority = 'Normal',
        ivruniqueid__c = ivrUniqueID
      );

      if (customerID.startsWith('001')) {
        t.WhatId = customerID;
      } else {
        t.WhoId = customerID;
      }

      upsert t;
      res.InsertResult = t;
    } catch (DmlException e) {
      res.InsertResult = e.getMessage();
      res.Error = 'Dml Error';
      String em = e.getMessage();
      //   System.debug('The following exception has occurred: ' + em );
      //return em;
    } catch (Exception e) {
      res.InsertResult = e.getMessage();
      res.Error = 'Error';
      //  System.debug('Query Issue: ' + e);  //return e.getMessage();
    }
    String srt = JSON.serialize(res);
    return srt;
  }

  @AuraEnabled
  public static String FindIDByPhone(String phoneNumber) {
    List<List<sObject>> results = [
      FIND :phoneNumber
      IN PHONE FIELDS
      RETURNING
        Contact(Id, Phone, FirstName, LastName),
        Lead(Id, Phone, FirstName, LastName),
        Account(Id, Phone, Name)
    ];
    sObject[] records = ((List<sObject>) results[0]);

    //return 'in FindIdByPhone';

    if (!records.isEmpty()) {
      for (Integer i = 0; i < records.size(); i++) {
        sObject record = records[i];

        if (record.getSObjectType() == Contact.sObjectType) {
          // contacts.add((Contact) record);

          return ((String) ((Contact) record).Id);
        } else if (record.getSObjectType() == Lead.sObjectType) {
          //leads.add((Lead) record);
          return ((String) ((Lead) record).Id);
        } else if (record.getSObjectType() == Account.sObjectType) {
          //leads.add((Lead) record);
          return ((String) ((Lead) record).Id);
        }
      }
    }
    return null;
  }
}

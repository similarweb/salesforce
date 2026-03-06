public class ContactTriggerHandler {
  public static Boolean TriggerFirstRun = true;
  private List<Log_Event__e> logEventsList = new List<Log_Event__e>();

  public void run() {
    InferredSolutionHandler ish = new InferredSolutionHandler('Contact');
    //BiApiInteractionHandler baih = new BiApiInteractionHandler('Contact');
    NewBiApiInteractionHandler newbaih = new NewBiApiInteractionHandler(
      'Contact'
    );
    //CampaignAutomationHandlerNew cahn = new CampaignAutomationHandlerNew('Contact');//MIS-2723: Remove the creation of Salesloft's outbound campaigns
    //ContactGetValuesFromAccount cva = new ContactGetValuesFromAccount();//2022-05-22: Itzik Winograd, 2022-05-22, Commented Out. MIS-2257
    MQLCalculationHandler mqlCalc = new MQLCalculationHandler();

    if (Trigger.isBefore && Trigger.isUpdate) {
      GroudonProtectionUtil.protectGroudonEnrichmentFields(
        Trigger.new,
        Trigger.oldMap
      );
      zuoraBillToSoldToManagement(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      leadGenIdPreventionManagement(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      updateDomainFields(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      setPreviousOwner(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      ish.setInferredSolution(Trigger.new, Trigger.oldMap);
      //baih.fitscoreOnDfoxChange(Trigger.new, Trigger.oldMap);
      //            newbaih.fitscoreOnDfoxChange(Trigger.new,Trigger.oldMap);
      //            changeTasksOwner((List<Contact>)Trigger.new, (Map<Id, Contact>)Trigger.oldMap);
      //cva.handle(Trigger.new, Trigger.oldMap);//2022-05-22: Itzik Winograd, 2022-05-22, Commented Out. MIS-2257
      //Added 2021/07/13 by Itzik Winograd: MQL calculation
      mqlCalc.handle(Trigger.new, Trigger.oldMap);
      setSlaTimeStamp(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
    }
    if (Trigger.isBefore && Trigger.isInsert) {
      updateDomainFields(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      changeOwnerIdForLeanDataLeadConversion(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      ish.setInferredSolution(Trigger.new, Trigger.oldMap);
      //Added 21/02/2021 by Itzik Winograd
      //cva.handle(Trigger.new, null);//2022-05-22: Itzik Winograd, 2022-05-22, Commented Out. MIS-2257
      //Added 2021/07/13 by Itzik Winograd: MQL calculation
      mqlCalc.handle(Trigger.new, Trigger.oldMap);
      newbaih.updateFitScoreLastRequest(Trigger.new);
      updateStrategicPodFromAccount(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
      //CampaignAutomationHandler.automateLeadCampaignContact((Map<Id, Contact>)Trigger.newMap);
      //cahn.automateCompaign((List<Contact>)Trigger.new, null); //MIS-2723: Remove the creation of Salesloft's outbound campaigns
      //createCampaignOrMember((Map<Id,Contact>)Trigger.newMap, null);///MIS-4279
      countQualifiedContacts((List<Contact>) Trigger.new, null);
      //Added 07/03/2021 by Itzik Winograd
      //Itzik Winograd, 2022-02-02 Remove all ShareASale triggers
      //ShareASaleIntegration sasi = new ShareASaleIntegration();
      //ShareASaleIntegration sasi = new ShareASaleIntegration();
      //sasi.handle((List <SObject>)Trigger.new, null);
      //Added 21/07/2021 by Itzik Winograd
      TransferEmailSubscriptionRecords cesr = new TransferEmailSubscriptionRecords();
      cesr.handle((List<SObject>) Trigger.new, null);
      //            newbaih.fitscoreOnDfoxChange(Trigger.new,Trigger.oldMap);
      updateMarketingPersona(Trigger.new);
      verifyGroudon(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
      //CampaignAutomationHandler.automateLeadCampaignContact((Map<Id, Contact>)Trigger.newMap,(Map<Id, Contact>)Trigger.oldMap);
      //cahn.automateCompaign((List<Contact>)Trigger.new, (Map<Id,SObject>)Trigger.oldMap); //MIS-2723: Remove the creation of Salesloft's outbound campaigns
      //createCampaignOrMember((Map<Id,Contact>)Trigger.newMap, (Map<Id,Contact>)Trigger.oldMap);//MIS-4279 removed
      countQualifiedContacts(
        (List<Contact>) Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      updateMarketingPersonaOnUpdate(
        Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      modifyCountDownWhenMirStatusChange(
        Trigger.new,
        (Map<Id, Contact>) Trigger.oldMap
      );
      verifyGroudon(Trigger.old, Trigger.new);

      //Itzik Winograd, 2021-05-25: ShareASale Phase2
      //Itzik Winograd, 2022-02-02: Remove all ShareASale triggers
      //ShareASaleIntegration sasi = new ShareASaleIntegration();
      //sasi.handle((List <SObject>)Trigger.new, Trigger.oldMap);
    }
  }

  public void setSlaTimeStamp(List<Contact> newList, Map<Id, Contact> oldMap) {
    System.debug('setSlaTimeStamp----');
    List<Contact> relevantContactList = new List<Contact>();
    Set<Id> userIdSet = new Set<Id>();
    for (Contact contact : newList) {
      filter(contact, oldMap, relevantContactList, userIdSet);
    }
    System.debug(' how many relevant ?  ' + relevantContactList.size());
    if (!relevantContactList.isEmpty()) {
      Map<Id, User> userMap = geContactWithOwnerInfoMap(userIdSet);

      for (Contact contactToUpdate : relevantContactList) {
        User leadOwner = userMap.get(contactToUpdate.OwnerId);
        contactToUpdate.SLA_Start_Timestamp__c = calculateSla(
          leadOwner.TimeZoneSidKey,
          contactToUpdate
        );
      }
    }
  }

  private Datetime calculateSla(String userTimeZone, Contact contactToUpdate) {
    Datetime currentDateTime = getLatestDateTime(contactToUpdate);
    Datetime calculatedSlaDateTime = SlaCalculationProcess.getCalculatedSlaDateTime(
      currentDateTime,
      userTimeZone
    );
    return calculatedSlaDateTime;
  }

  private Datetime getLatestDateTime(Contact contactToUpdate) {
    if (contactToUpdate.First_MQL_Date__c == null) {
      return contactToUpdate.Last_Owner_Assigned_Date__c;
    } else if (contactToUpdate.Last_Owner_Assigned_Date__c == null) {
      return contactToUpdate.First_MQL_Date__c;
    } else {
      return contactToUpdate.First_MQL_Date__c >
        contactToUpdate.Last_Owner_Assigned_Date__c
        ? contactToUpdate.First_MQL_Date__c
        : contactToUpdate.Last_Owner_Assigned_Date__c;
    }
  }

  private Map<Id, User> geContactWithOwnerInfoMap(Set<Id> userIdSet) {
    Map<Id, User> userMap = new Map<Id, User>(
      [SELECT Id, TimeZoneSidKey FROM User WHERE Id IN :userIdSet]
    );
    return userMap;
  }

  private void filter(
    Contact contact,
    Map<Id, Contact> oldMap,
    List<Contact> relevantContactList,
    Set<Id> userIdSet
  ) {
    if (
      contact.First_MQL_Date__c != oldMap.get(contact.Id).First_MQL_Date__c ||
      contact.Last_Owner_Assigned_Date__c !=
      oldMap.get(contact.id).Last_Owner_Assigned_Date__c
    ) {
      if (contact.First_MQL_Date__c != null) {
        relevantContactList.add(contact);
        userIdSet.add(contact.OwnerId);
      }
    }
  }

  public static void setPreviousOwner(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    if (TriggerFirstRun) {
      TriggerFirstRun = false;
      for (Contact cnt : newList) {
        if (cnt.OwnerId != oldMap.get(cnt.Id).OwnerId)
          cnt.Previous_Owner_Id__c = oldMap.get(cnt.Id).OwnerId;
        System.debug('newOwnerId ' + cnt.OwnerId);
        System.debug(
          'oldMap.get(cnt.Id).OwnerId ' + oldMap.get(cnt.Id).OwnerId
        );
      }
      System.debug('setPreviousOwner() newList ' + newList);
    }
  }

  public static void updateDomainFields(
    List<Contact> newList,
    Map<Id, Contact> oldContactMap
  ) {
    List<Contact> contactsToUpd = new List<Contact>();
    List<String> emailDomains = new List<String>();
    if (Trigger.isInsert) {
      for (Contact cont_i : newList) {
        if (String.isNotBlank(cont_i.Email_Domain__c)) {
          contactsToUpd.add(cont_i);
          emailDomains.add(cont_i.Email_Domain__c);
        }
      }
    } else {
      for (Contact cont_i : newList) {
        Contact contOld_i = oldContactMap.get(cont_i.Id);
        if (
          (contOld_i.Email != cont_i.Email ||
          contOld_i.LinkedIn_Profile__c != cont_i.LinkedIn_Profile__c ||
          contOld_i.Master_Website__c != cont_i.Master_Website__c) &&
          String.isNotBlank(cont_i.Email_Domain__c)
        ) {
          contactsToUpd.add(cont_i);
          emailDomains.add(cont_i.Email_Domain__c);
        }
      }
    }
    Map<String, String> existedDomainsToRT = new Map<String, String>();
    for (EmailDomain__c ed_i : [
      SELECT Name, RecordType.DeveloperName
      FROM EmailDomain__c
      WHERE Name IN :emailDomains
    ]) {
      existedDomainsToRT.put(
        ed_i.Name.toLowerCase(),
        ed_i.RecordType.DeveloperName
      );
    }

    for (Contact cont_i : contactsToUpd) {
      String recordTypeName = existedDomainsToRT.get(cont_i.Email_Domain__c);
      if (recordTypeName != null) {
        if (recordTypeName == 'Junk_Emails') {
          cont_i.Email_address_domain_type__c = 'Junk';
          cont_i.Email_address_domain_type_details__c = String.isBlank(
              cont_i.Email_address_domain_type_details__c
            ) || cont_i.Email_address_domain_type_details__c == 'Private'
            ? cont_i.Email_address_domain_type__c
            : cont_i.Email_address_domain_type_details__c;
          cont_i.HasOptedOutOfEmail = true;
          cont_i.Email_Domain_Type_Timestamp__c = System.now();
        } else if (recordTypeName == 'Free') {
          cont_i.Email_address_domain_type__c = 'Private';
          cont_i.Email_address_domain_type_details__c = String.isBlank(
              cont_i.Email_address_domain_type_details__c
            ) || cont_i.Email_address_domain_type_details__c == 'Private'
            ? cont_i.Email_address_domain_type__c
            : cont_i.Email_address_domain_type_details__c;
          cont_i.Email_Domain_Type_Timestamp__c = System.now();
        } else {
          cont_i.Email_address_domain_type__c = 'Company';
          cont_i.Email_address_domain_type_details__c = String.isBlank(
              cont_i.Email_address_domain_type_details__c
            ) || cont_i.Email_address_domain_type_details__c == 'Private'
            ? cont_i.Email_address_domain_type__c
            : cont_i.Email_address_domain_type_details__c;
          cont_i.Email_Domain_Type_Timestamp__c = System.now();
        }
      } else {
        cont_i.Email_address_domain_type__c = 'Company';
        cont_i.Email_address_domain_type_details__c = String.isBlank(
            cont_i.Email_address_domain_type_details__c
          ) || cont_i.Email_address_domain_type_details__c == 'Private'
          ? cont_i.Email_address_domain_type__c
          : cont_i.Email_address_domain_type_details__c;
        cont_i.Email_Domain_Type_Timestamp__c = System.now();
      }

      if (
        cont_i.Email_address_domain_type__c == 'Private' &&
        String.isNotBlank(cont_i.LinkedIn_Profile__c) &&
        !cont_i.LinkedIn_Profile__c.contains('didnotfind.com')
      ) {
        cont_i.Email_address_domain_type__c = 'Company - Secondary';
      }
    }
  }

  /**
   * @author Zohar Sinay
   * @date 30/01/2022
   * @description: check if the Bill to or Sold To is changed on these records. unchange them and store the values on the relevant fields.
   * @param List<Contact> newList - new list of contacts
   * @param Map<Id,Contact> oldMap - map of trigger.old contacts
   */
  public void zuoraBillToSoldToManagement(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    Schema.FieldSet fs2 = Schema.SObjectType.Contact.fieldSets.zuora_billto_soldto_validation;
    List<User> currUserDivision = [
      SELECT Id, FirstName, Division
      FROM User
      WHERE Id = :userInfo.getUserId()
    ];
    for (Contact con : newList) {
      if (
        con.AccountId != null &&
        ((con.Bill_To__c == true) || (con.Sold_To__c == true)) &&
        (currUserDivision[0].Division == 'Integration' &&
        currUserDivision[0].FirstName != 'Zuora')
      ) {
        con.Zuora_BillTo_SoldTo_Validation_Details__c =
          '' +
          'ChangedByUser: ' +
          userInfo.getFirstName() +
          ' ' +
          UserInfo.getLastName() +
          ' ' +
          userInfo.getUserId() +
          ' ' +
          '\n';
        con.Zuora_BillTo_SoldTo_Validation_Date__c = Datetime.now();
        for (Schema.FieldSetMember f : fs2.getFields()) {
          con.Zuora_BillTo_SoldTo_Validation_Details__c +=
            f.getFieldPath() +
            ': ' +
            con.get(f.getFieldPath()) +
            '\n';
          con.put(f.getFieldPath(), oldMap.get(con.Id).get(f.getFieldPath()));
        }
      }
    }
  }

  /**
   * @author Zohar Sinay
   * @date 17/02/2022
   * @description: Check new contact created with flag of converted lead with accountId present
   * @param List<Contact> newList - new list of contacts
   * @param Map<Id,Contact> oldMap - map of trigger.old contacts
   */
  public void changeOwnerIdForLeanDataLeadConversion(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    List<Id> AccountIdList = new List<Id>();
    Map<Id, List<Contact>> contactListByAccountId = new Map<Id, List<Contact>>();
    for (Contact con : newList) {
      if (
        con.Is_Converted_By_Lean_Data__c == true &&
        !String.isBlank(con.AccountId)
      ) {
        AccountIdList.add(con.AccountId);
        if (contactListByAccountId.containsKey(con.AccountId)) {
          contactListByAccountId.get(con.AccountId).add(con);
        } else {
          contactListByAccountId.put(con.AccountId, new List<Contact>{ con });
        }
      }
    }
    for (Account acc : [
      SELECT Id, OwnerId
      FROM Account
      WHERE Id IN :AccountIdList
    ]) {
      for (Contact con : contactListByAccountId.get(acc.Id)) {
        con.OwnerId = acc.OwnerId;
      }
    }
  }

  /**
   * @author Zohar Sinay
   * @date 27/03/2022
   * @description: Prevent lead gen id field and all others from updating and storing the timestamp of the change.
   * @param List<Contact> newList - new list of contacts
   * @param Map<Id,Contact> oldMap - map of trigger.old contacts
   */
  public void leadGenIdPreventionManagement(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    Schema.FieldSet fs2 = Schema.SObjectType.Contact.fieldSets.LeadCapture_field_set_Contact;
    for (Contact con : newList) {
      for (Schema.FieldSetMember f : fs2.getFields()) {
        if (
          con.get(f.getFieldPath()) !=
          oldMap.get(con.Id).get(f.getFieldPath()) &&
          oldMap.get(con.Id).get(f.getFieldPath()) != null
        ) {
          con.put(f.getFieldPath(), oldMap.get(con.Id).get(f.getFieldPath()));
        }
      }
    }
  }

  public static void countQualifiedContacts(
    List<Contact> newList,
    Map<Id, Contact> oldContactMap
  ) {
    System.debug('countQualifiedContacts--');
    Set<Id> accountIdSet = new Set<Id>();
    List<Account> accountsToUpdateList = new List<Account>();
    for (contact con : newList) {
      if (con.AccountId != null) {
        if (
          (oldContactMap == null &&
          con.Status__c != 'Unqualified') ||
          (oldContactMap != null &&
          oldContactMap.get(con.Id).Status__c == 'Unqualified' &&
          con.Status__c != 'Unqualified') ||
          (oldContactMap != null &&
          oldContactMap.get(con.Id).Status__c != 'Unqualified' &&
          con.Status__c == 'Unqualified')
        ) {
          accountIdSet.add(con.AccountId);
        }
      }
    }
    List<Contact> contactForCheckList = [
      SELECT Id, AccountId
      FROM Contact
      WHERE AccountId IN :accountIdSet
    ];
    System.debug('contactForCheckList--' + contactForCheckList.size());
    for (Contact contact : contactForCheckList) {
      System.debug('account id = ' + contact.AccountId);
    }

    if (!accountIdSet.isEmpty()) {
      List<AggregateResult> aggrList = [
        SELECT Count(Id), AccountId
        FROM Contact
        WHERE AccountId IN :accountIdSet AND Status__c != 'Unqualified'
        GROUP BY AccountId
      ];
      for (AggregateResult aggr : aggrList) {
        System.debug((String) aggr.get('AccountId'));
        accountsToUpdateList.add(
          new Account(
            Id = (Id) aggr.get('AccountId'),
            Number_of_Contacts__c = (Decimal) aggr.get('expr0')
          )
        );
      }
      if (aggrList.isEmpty()) {
        for (Id accId : accountIdSet) {
          accountsToUpdateList.add(
            new Account(Id = accId, Number_of_Contacts__c = 0)
          );
        }
      }
    }

    if (!accountsToUpdateList.isEmpty()) {
      update accountsToUpdateList;
    }
  }

  public void modifyCountDownWhenMirStatusChange(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    System.debug('modifyCountDownWhenMirStatusChange');
    List<MirStatusChangeEvent__e> eventsList = new List<MirStatusChangeEvent__e>();
    for (Contact contactItem : newList) {
      System.debug('contactItem.MIR_Status__c--' + contactItem.MIR_Status__c);
      System.debug(
        'oldMap.get(contactItem.Id).MIR_Status__c--' +
        oldMap.get(contactItem.Id).MIR_Status__c
      );
      if (
        contactItem.MIR_Status__c != oldMap.get(contactItem.Id).MIR_Status__c
      ) {
        MirStatusChangeEvent__e event = new MirStatusChangeEvent__e();
        event.Record_Id__c = contactItem.Id;
        event.MIR_Status_Value__c = contactItem.MIR_Status__c;
        eventsList.add(event);
      }
    }
    System.debug('eventsList--' + eventsList);
    if (!eventsList.isEmpty()) {
      EventBus.publish(eventsList);
      System.debug('Published ' + eventsList.size() + ' events.');
    }
  }

  public void updateMarketingPersonaOnUpdate(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    System.debug('updateMarketingPersonaOnUpdate--');
    List<Contact> changeContactList = new List<Contact>();
    for (Contact conItem : newList) {
      if (
        conItem.Department__c != oldMap.get(conItem.Id).Department__c ||
        (conItem.Current_Registration_Type__c !=
        oldMap.get(conItem.Id).Current_Registration_Type__c)
      ) {
        changeContactList.add(conItem);
      }
    }

    System.debug('changeContactList--' + changeContactList);

    if (!changeContactList.isEmpty()) {
      updateMarketingPersona(changeContactList);
    }
  }

  public void updateMarketingPersona(List<Contact> newList) {
    System.debug('updateMarketingPersona--');
    List<Marketing_Persona__mdt> settings = [
      SELECT
        Department__c,
        Marketing_Persona_with_Industry__c,
        Marketing_Persona_without_Industry__c,
        Account_SW_Industries__c
      FROM Marketing_Persona__mdt
    ];
    Map<String, Marketing_Persona__mdt> settingMap = new Map<String, Marketing_Persona__mdt>();
    for (Marketing_Persona__mdt setting : settings) {
      settingMap.put(setting.Department__c, setting);
    }
    List<Contact> contactWithAccountList = [
      SELECT Department__c, Account.SW_Industry__c, Current_Registration_Type__c
      FROM Contact
      WHERE Id IN :newList
    ];
    for (Contact contact : contactWithAccountList) {
      if (contact.Current_Registration_Type__c == 'Shopper Intelligence') {
        contact.put('Marketing_Persona__c', 'Shopper');
      } else {
        Marketing_Persona__mdt setting = settingMap.get(contact.Department__c);
        System.debug('setting--' + setting);
        List<String> swIndustriesFromMetaData = setting != null
          ? setting.Account_SW_Industries__c.split(',')
          : new List<String>();
        Object newValue = setting != null
          ? swIndustriesFromMetaData.contains(contact.Account.SW_Industry__c)
              ? setting.Marketing_Persona_with_Industry__c
              : getValueFromRegistrationType(
                  contact,
                  true,
                  setting.Marketing_Persona_without_Industry__c
                )
          : getValueFromRegistrationType(contact, false, null);
        contact.put('Marketing_Persona__c', newValue);
      }
    }
    System.debug('contactWithAccountList--' + contactWithAccountList);
    update contactWithAccountList;
  }

  private String getValueFromRegistrationType(
    Contact contact,
    boolean withSettingExist,
    String defaultValue
  ) {
    System.debug('withSettingExist--' + withSettingExist);
    System.debug('contact Department__c-- ' + contact.Department__c);
    String newPersonaValue = defaultValue != null ? defaultValue : 'No Persona';
    if (contact.Current_Registration_Type__c != null) {
      if (
        contact.Current_Registration_Type__c.containsIgnoreCase('Sales') ||
        contact.Current_Registration_Type__c.containsIgnoreCase(
          'Digital Marketing'
        )
      ) {
        if (
          !withSettingExist ||
          (contact.Department__c == null ||
          contact.Department__c == 'Other')
        ) {
          newPersonaValue = contact.Current_Registration_Type__c.containsIgnoreCase(
              'Sales'
            )
            ? 'Sales'
            : 'Marketing - General';
        }
      }
    }

    return newPersonaValue;
  }

  public void updateStrategicPodFromAccount(List<Contact> newList) {
    Set<Id> accountIdSet = new Set<Id>();
    Map<Id, String> accountIdToStrategicPodMap = new Map<Id, String>();

    for (Contact contItem : newList) {
      accountIdSet.add(contItem.AccountId);
    }
    List<Account> parentAccountList = [
      SELECT Id, Strategic_Pod__c
      FROM Account
      WHERE Id IN :accountIdSet
    ];
    for (Account acc : parentAccountList) {
      accountIdToStrategicPodMap.put(acc.Id, acc.Strategic_Pod__c);
    }

    for (Contact contItem : newList) {
      contItem.Strategic_Pod__c = accountIdToStrategicPodMap.get(
        contItem.AccountId
      );
    }
  }

  public void resetWebsiteVerifiedOnWebsiteUpdate(
    List<Contact> newList,
    Map<Id, Contact> oldMap
  ) {
    System.debug('resetWebsiteVerifiedOnWebsiteUpdate--');
    for (Contact contactItem : newList) {
      if (contactItem.Website__c != oldMap.get(contactItem.Id).Website__c) {
        System.debug(' i am here to reset the website!!');
        System.debug(contactItem.Website_Verified__c + ' this is before');
        contactItem.Website_Verified__c = null;
      }
    }
  }

  private void verifyGroudon(List<Contact> newContacts) {
    List<String> leadIds = new List<String>();

    for (Contact c : newContacts) {
      if (
        String.isNotBlank(c.Converted_Lead_ID__c) &&
        String.isNotBlank(c.Website__c) &&
        c.Website__c.toLowerCase() != 'no_website'
      ) {
        leadIds.add(c.Converted_Lead_ID__c);
      }
    }

    if (leadIds.isEmpty()) {
      return;
    }

    List<Lead> leads = [SELECT Id, CreatedDate FROM Lead WHERE Id IN :leadIds];
    Map<String, Lead> leadIdToLead = new Map<String, Lead>();

    for (Lead l : leads) {
      String id15 = String.valueOf(l.Id).substring(0, 15);
      leadIdToLead.put(id15, l);
    }

    List<Contact> relevantContactList = new List<Contact>(),
      fakeContacts = new List<Contact>();
    Set<String> domainsToCheck = new Set<String>();

    // First pass: collect domains that need to be checked
    for (Contact c : newContacts) {
      String leadId15 = null;
      if (c.Converted_Lead_ID__c != null) {
        leadId15 = String.valueOf(c.Converted_Lead_ID__c).substring(0, 15);
      }

      if (
        ((c.enrichment_success__c == false &&
        leadId15 != null &&
        leadIdToLead.containsKey(leadId15) &&
        leadIdToLead.get(leadId15).CreatedDate.date() == Date.today()) ||
        c.Groudon_Call_Status__c == 'NTS (Need To Send)') &&
        c.Email_address_domain_type__c == 'Private' &&
        String.isNotBlank(c.Website_Domain__c)
      ) {
        domainsToCheck.add(c.Website_Domain__c);
      }
    }

    Set<String> fakeDomains = domainsToCheck.isEmpty()
      ? new Set<String>()
      : LeadTriggerHandler.getFakeDomains(domainsToCheck);

    // Second pass: process contacts based on fake domains check
    for (Contact c : newContacts) {
      String leadId15 = c.Converted_Lead_ID__c != null
        ? String.valueOf(c.Converted_Lead_ID__c).substring(0, 15)
        : null;

      if (
        (c.enrichment_success__c == false &&
        leadId15 != null &&
        leadIdToLead.containsKey(leadId15) &&
        leadIdToLead.get(leadId15).CreatedDate.date() == Date.today()) ||
        c.Groudon_Call_Status__c == 'NTS (Need To Send)'
      ) {
        if (c.Email_address_domain_type__c == 'Private') {
          if (fakeDomains.contains(c.Website_Domain__c)) {
            fakeContacts.add(new Contact(Id = c.Id, Email = c.Email));
          } else {
            relevantContactList.add(c);
          }
        } else {
          relevantContactList.add(c);
        }
      }
    }

    if (!relevantContactList.isEmpty()) {
      sendToGroudon(relevantContactList);
    }

    if (!fakeContacts.isEmpty()) {
      for (Contact c : fakeContacts) {
        c.Fake_Data_Reason__c = 'Black list Website';
        c.Fake_Data__c = true;

        Log_Event__e log = new Log_Event__e();
        log.Email__c = c.Email;
        log.Apex_class__c = 'ContactTriggerHandler';
        log.Apex_Method__c = fakeContacts.size() > 1
          ? 'Blocked callGroudonBulk'
          : 'Blocked callGroudonSingle';
        log.Record_Ids__c = c.id;
        log.Log_Type__c = 'Info';
        log.SF_Type__c = 'Contact';
        logEventsList.add(log);
      }

      update fakeContacts;
      Eventbus.publish(logEventsList);
    }
  }

  private void verifyGroudon(
    List<Contact> oldContacts,
    List<Contact> newContacts
  ) {
    List<Contact> relevantContactList = new List<Contact>(),
      fakeContacts = new List<Contact>();
    Set<String> domainsToCheck = new Set<String>();

    // First pass: collect domains that need to be checked
    for (Integer i = 0; i < newContacts.size(); i++) {
      Contact oldC = oldContacts.get(i), newC = newContacts.get(i);

      if (
        ((oldC.Force_Enrichment__c != newC.Force_Enrichment__c &&
        newC.Force_Enrichment__c) ||
        newC.Groudon_Call_Status__c == 'NTS (Need To Send)') &&
        String.isNotBlank(newC.Website__c) &&
        newC.Website__c.toLowerCase() != 'no_website' &&
        newC.Email_address_domain_type__c == 'Private' &&
        String.isNotBlank(newC.Website_Domain__c)
      ) {
        domainsToCheck.add(newC.Website_Domain__c);
      }
    }

    Set<String> fakeDomains = domainsToCheck.isEmpty()
      ? new Set<String>()
      : LeadTriggerHandler.getFakeDomains(domainsToCheck);

    // Second pass: process contacts based on fake domains check
    for (Integer i = 0; i < newContacts.size(); i++) {
      Contact oldC = oldContacts.get(i), newC = newContacts.get(i);

      if (
        ((oldC.Force_Enrichment__c != newC.Force_Enrichment__c &&
        newC.Force_Enrichment__c) ||
        newC.Groudon_Call_Status__c == 'NTS (Need To Send)') &&
        String.isNotBlank(newC.Website__c) &&
        newC.Website__c.toLowerCase() != 'no_website'
      ) {
        if (newC.Email_address_domain_type__c == 'Private') {
          if (fakeDomains.contains(newC.Website_Domain__c)) {
            fakeContacts.add(new Contact(Id = newC.Id, Email = newC.Email));
          } else {
            relevantContactList.add(newC);
          }
        } else {
          relevantContactList.add(newC);
        }
      }
    }

    if (!relevantContactList.isEmpty()) {
      sendToGroudon(relevantContactList);
    }

    if (!fakeContacts.isEmpty()) {
      for (Contact c : fakeContacts) {
        c.Fake_Data_Reason__c = 'Black list Website';
        c.Fake_Data__c = true;

        Log_Event__e log = new Log_Event__e();
        log.Email__c = c.Email;
        log.Apex_class__c = 'ContactTriggerHandler';
        log.Apex_Method__c = fakeContacts.size() > 1
          ? 'Blocked callGroudonBulk'
          : 'Blocked callGroudonSingle';
        log.Record_Ids__c = c.id;
        log.Log_Type__c = 'Info';
        log.SF_Type__c = 'Contact';
        logEventsList.add(log);
      }

      update fakeContacts;
      Eventbus.publish(logEventsList);
    }
  }

  private void sendToGroudon(List<Contact> relevantContactList) {
    Feature_Flag_Setting__mdt groudonSetting = Feature_Flag_Setting__mdt.getInstance(
      'Groudon_Process'
    );
    Boolean featureFlag = groudonSetting != null && groudonSetting.Is_Active__c;
    Feature_Flag_Setting__mdt groudonSettingBulk = Feature_Flag_Setting__mdt.getInstance(
      'Groudon_Process_bulk'
    );
    Boolean featureFlagBulk =
      groudonSettingBulk != null && groudonSettingBulk.Is_Active__c;
    if (featureFlagBulk) {
      if (relevantContactList.size() > 1) {
        system.enqueueJob(
          new GroudonQueueable(new ContactGroudonHandler(relevantContactList))
        );
      } else {
        system.enqueueJob(
          new GroudonQueueable(
            new ContactGroudonHandler(relevantContactList.get(0))
          )
        );
      }
    } else if (featureFlag) {
      for (Contact c : relevantContactList) {
        system.enqueueJob(new GroudonQueueable(new ContactGroudonHandler(c)));
      }
    }
  }
}

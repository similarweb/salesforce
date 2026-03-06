public class LeadTriggerHandler {
  private List<Log_Event__e> logEventsList = new List<Log_Event__e>();

  public void beforeInsert(List<Lead> newLeads) {
    setPolygraphTimeStamps(newLeads);
    markGroudon(newLeads);
  }

  public void afterUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
    reassignTaskOwner(newMap.values(), oldMap);
    modifyCountDownWhenMirStatusChange(newMap.values(), oldMap);
    sendToGroudon(newMap.values());
    markForceEnrichment(oldMap.values(), newMap.values());
    // createCampaignOrMember(newMap,oldMap); MIS-4279
  }

  public void afterInsert(Map<Id, Lead> newMap) {
    sendToGroudon(newMap.values());
  }

  /**
   * --- change---
   * @author Elnur Alibaev
   * @date 15/08/2025
   * @description Updated lead's send to groudon conditions with email and fake website check
   */
  private void sendToGroudon(List<Lead> newList) {
    List<Lead> relevantLeadList = new List<Lead>();
    List<Lead> fakeLeads = new List<Lead>();
    Set<String> domainsToCheck = new Set<String>();

    for (Lead leadItem : newList) {
      if (String.isNotBlank(leadItem.Website_Domain__c)) {
        domainsToCheck.add(leadItem.Website_Domain__c);
      }
    }

    Set<String> fakeDomains = domainsToCheck.isEmpty()
      ? new Set<String>()
      : getFakeDomains(domainsToCheck);

    for (Lead leadItem : newList) {
      if (leadItem.Groudon_Call_Status__c == 'NTS (Need To Send)') {
        if (
          String.isBlank(leadItem.Website_Domain__c) ||
          leadItem.Website_Domain__c == 'no_website'
        ) {
          continue;
        }

        if (leadItem.Email_address_domain_type__c == 'Private') {
          if (fakeDomains.contains(leadItem.Website_Domain__c)) {
            fakeLeads.add(new Lead(Id = leadItem.Id, Email = leadItem.Email));
          } else {
            relevantLeadList.add(leadItem);
          }
        } else {
          relevantLeadList.add(leadItem);
        }
      }
    }

    if (!relevantLeadList.isEmpty()) {
      Feature_Flag_Setting__mdt groudonSetting = Feature_Flag_Setting__mdt.getInstance(
        'Groudon_Process'
      );
      Boolean featureFlag =
        groudonSetting != null && groudonSetting.Is_Active__c;
      Feature_Flag_Setting__mdt groudonSettingBulk = Feature_Flag_Setting__mdt.getInstance(
        'Groudon_Process_bulk'
      );
      Boolean featureFlagBulk =
        groudonSettingBulk != null && groudonSettingBulk.Is_Active__c;
      if (featureFlagBulk) {
        if (relevantLeadList.size() > 1) {
          //                    system.enqueueJob(new GroudonQueueable(relevantLeadList,true)); // more then 1
          system.enqueueJob(
            new GroudonQueueable(new LeadGroudonHandler(relevantLeadList, true))
          ); // more then 1
        } else {
          //                    system.enqueueJob(new GroudonQueueable(relevantLeadList)); // 1 exactly
          system.enqueueJob(
            new GroudonQueueable(new LeadGroudonHandler(relevantLeadList))
          ); // 1 exactly
        }
      } else if (featureFlag) {
        for (Lead leadItem : relevantLeadList) {
          //                    system.enqueueJob(new GroudonQueueable(new List<Lead>{leadItem}));
          system.enqueueJob(
            new GroudonQueueable(
              new LeadGroudonHandler(new List<Lead>{ leadItem })
            )
          );
        }
      }
    }

    if (!fakeLeads.isEmpty()) {
      for (Lead l : fakeLeads) {
        l.Fake_Data_Reason__c = 'Black list Website';
        l.Fake_Data__c = true;

        Log_Event__e log = new Log_Event__e();
        log.Email__c = l.Email;
        log.Apex_class__c = 'LeadTriggerHandler';
        log.Apex_Method__c = fakeLeads.size() > 1
          ? 'Blocked callGroudonBulk'
          : 'Blocked callGroudonSingle';
        log.Record_Ids__c = l.id;
        log.Log_Type__c = 'Info';
        log.SF_Type__c = 'Lead';
        logEventsList.add(log);
      }
      try {
        update fakeLeads;
      } catch (Exception e) {
        insert new Trace_Log__c(
          Context__c = 'MIS-8352',
          Log__c = 'Exception 3: ' + e.getMessage()
        );
        throw e;
      }
      Eventbus.publish(logEventsList);
    }
  }

  public void markGroudonOnBeforeUpdate(
    Map<Id, Lead> newMap,
    Map<Id, Lead> oldMap
  ) {
    List<Lead> leadCompanyChangeList = new List<Lead>();
    for (Id leadId : newMap.keySet()) {
      String groudonCallStatus = newMap.get(leadId).Groudon_Call_Status__c;
      System.debug('groudonCallStatus--' + groudonCallStatus);
      //            boolean enrichmentSucceededBool = newMap.get(leadId).enrichment_success__c;
      //            boolean enrichmentSendBool = newMap.get(leadId).call_made_from_groudon__c;
      Boolean websiteChangeBool =
        newMap.get(leadId).Website != oldMap.get(leadId).Website;
      Boolean titleChangeBool =
        newMap.get(leadId).Title != oldMap.get(leadId).Title &&
        String.isNotBlank(newMap.get(leadId).Title) &&
        newMap.get(leadId).Title != 'NA';
      Boolean departmentChangeBool =
        newMap.get(leadId).Department__c != oldMap.get(leadId).Department__c &&
        String.isNotBlank(newMap.get(leadId).Department__c) &&
        newMap.get(leadId).Department__c != 'NA';
      Boolean seniorityChangeBool =
        newMap.get(leadId).Seniority__c != oldMap.get(leadId).Seniority__c &&
        String.isNotBlank(newMap.get(leadId).Seniority__c) &&
        newMap.get(leadId).Seniority__c != 'NA';
      Boolean employeeChangeBool =
        newMap.get(leadId).Employees_Min__c !=
        oldMap.get(leadId).Employees_Min__c;
      Boolean phoneChangeBool =
        newMap.get(leadId).Phone != oldMap.get(leadId).Phone &&
        String.isNotBlank(newMap.get(leadId).Phone) &
        newMap.get(leadId).Phone != 'NA';
      Boolean industryChangeBool =
        newMap.get(leadId).SW_Industry__c !=
        oldMap.get(leadId).SW_Industry__c &&
        String.isNotBlank(newMap.get(leadId).SW_Industry__c) &
        newMap.get(leadId).SW_Industry__c != 'NA';
      boolean forceEnrichBool =
        newMap.get(leadId).Force_Enrichment__c == true &&
        oldMap.get(leadId).Force_Enrichment__c == false;
      boolean quizCompleteBool = false;
      if (
        newMap.get(leadId).Is_Groudon_Quiz_Complete__c == false &&
        ((oldMap.get(leadId).Quiz_Data_Incomplete__c != 'False' &&
        newMap.get(leadId).Quiz_Data_Incomplete__c == 'False') ||
        (oldMap.get(leadId).Current_Registration_Type__c != null &&
        newMap.get(leadId).Current_Registration_Type__c != null &&
        oldMap.get(leadId)
          .Current_Registration_Type__c
          ?.equalsIgnoreCase('registration-transit') &&
        !newMap.get(leadId)
          .Current_Registration_Type__c
          ?.equalsIgnoreCase('registration-transit')))
      ) {
        quizCompleteBool = true;
        newMap.get(leadId).Is_Groudon_Quiz_Complete__c = true;
        newMap.get(leadId).Force_Enrichment__c = true;
      }
      if (
        !forceEnrichBool &&
        (quizCompleteBool ||
        websiteChangeBool ||
        titleChangeBool ||
        departmentChangeBool ||
        seniorityChangeBool ||
        employeeChangeBool ||
        phoneChangeBool ||
        industryChangeBool)
      ) {
        leadCompanyChangeList.add(newMap.get(leadId));
      }
      if (forceEnrichBool) {
        leadCompanyChangeList.add(newMap.get(leadId));
      }
      groudonCallStatus = groudonCallStatus == 'NTS (Need To Send)'
        ? 'Ignore'
        : groudonCallStatus;
      System.debug('groudonCallStatus---after change -- ' + groudonCallStatus);
      newMap.get(leadId).Groudon_Call_Status__c = groudonCallStatus;
    }
    System.debug('leadCompanyChangeList----' + leadCompanyChangeList);
    if (!leadCompanyChangeList.isEmpty()) {
      markGroudon(leadCompanyChangeList);
    }
  }

  private void markGroudon(List<Lead> newList) {
    Integer numberOfDaysFromCreationOfLeads = 90; // thats the default value it can be override from General_Key_Value_pair__mdt
    Feature_Flag_Setting__mdt groudonSetting = Feature_Flag_Setting__mdt.getInstance(
      'Groudon_Process'
    );
    Boolean featureFlag = groudonSetting != null && groudonSetting.Is_Active__c;
    Feature_Flag_Setting__mdt groudonSettingBulk = Feature_Flag_Setting__mdt.getInstance(
      'Groudon_Process_bulk'
    );
    Boolean featureFlagBulk =
      groudonSettingBulk != null && groudonSettingBulk.Is_Active__c;
    if (!featureFlag && !featureFlagBulk && !Test.isRunningTest()) {
      return;
    }
    Set<String> websiteAllowedSet = new Set<String>();
    List<General_Key_Value_pair__mdt> keyValuePairs = [
      SELECT Id, Value__c, Key__c
      FROM General_Key_Value_pair__mdt
      WHERE ProcessName__c = 'GroudonProcess' AND IsActive__c = TRUE
    ];
    for (General_Key_Value_pair__mdt keyValuePair : keyValuePairs) {
      if (keyValuePair.Key__c == 'website') {
        websiteAllowedSet.add(keyValuePair.Value__c);
      }
      if (keyValuePair.Key__c == 'numberOfDaysFromCreation') {
        numberOfDaysFromCreationOfLeads = Integer.valueOf(
          keyValuePair.Value__c
        );
      }
    }
    Date creationDateToCompareWith = Date.today()
      .addDays(numberOfDaysFromCreationOfLeads * -1);

    for (lead leadItem : newList) {
      String groudonCallStatus = leadItem.Groudon_Call_Status__c;

      boolean websiteBool =
        String.isNotBlank(leadItem.Website) &&
        !websiteAllowedSet.contains(leadItem.Website) &&
        !leadItem.IsConverted;
      Boolean titleBool =
        String.isNotBlank(leadItem.Title) && leadItem.Title != 'NA';
      Boolean industryBool =
        String.isNotBlank(leadItem.SW_Industry__c) &&
        leadItem.SW_Industry__c != 'NA';
      Boolean departmentBool =
        String.isNotBlank(leadItem.Department__c) &&
        leadItem.Department__c != 'NA';
      Boolean seniorityBool =
        String.isNotBlank(leadItem.Seniority__c) &&
        leadItem.Seniority__c != 'NA';
      Boolean phoneBool =
        String.isNotBlank(leadItem.Phone) && leadItem.Phone != 'NA';
      Boolean employeeBool = leadItem.Employees_Min__c != null;
      boolean allOtherFieldsBool =
        titleBool ||
        industryBool ||
        departmentBool ||
        seniorityBool ||
        phoneBool ||
        employeeBool;
      boolean creationDateBool =
        leadItem.CreatedDate == null ||
        leadItem.CreatedDate >= creationDateToCompareWith;

      if (websiteBool && allOtherFieldsBool && creationDateBool) {
        groudonCallStatus = String.isBlank(groudonCallStatus) ||
          groudonCallStatus == 'None'
          ? 'NTS (Need To Send)'
          : groudonCallStatus == 'NTS (Need To Send)'
              ? 'Ignore'
              : groudonCallStatus;
      }
      if (leadItem.Force_Enrichment__c) {
        groudonCallStatus = 'NTS (Need To Send)';
        leadItem.Force_Enrichment__c = false;
      }

      leadItem.Groudon_Call_Status__c = groudonCallStatus; // thats the end of the before triggers : values can be :None,NTS (Need To Send),Ignore,Enrichment_Ended
    }
  }

  public void modifyCountDownWhenMirStatusChange(
    List<Lead> newList,
    Map<Id, Lead> oldMap
  ) {
    System.debug(' started modifyCountDownWhenMirStatusChange');
    List<MirStatusChangeEvent__e> eventsList = new List<MirStatusChangeEvent__e>();
    for (Lead leadItem : newList) {
      System.debug('leadItem.MIR_Status__--' + leadItem.MIR_Status__c);
      if (leadItem.MIR_Status__c != oldMap.get(leadItem.Id).MIR_Status__c) {
        MirStatusChangeEvent__e event = new MirStatusChangeEvent__e();
        event.Record_Id__c = leadItem.Id;
        event.MIR_Status_Value__c = leadItem.MIR_Status__c;
        eventsList.add(event);
      }
    }
    System.debug('eventsList--' + eventsList);
    if (!eventsList.isEmpty()) {
      EventBus.publish(eventsList);
      System.debug('Published ' + eventsList.size() + ' events.');
    }
  }

  public void setSlaTimeStamp(List<Lead> newList, Map<Id, Lead> oldMap) {
    System.debug('setSlaTimeStamp----');
    List<Lead> relevantLeadList = new List<Lead>();
    Set<Id> userIdSet = new Set<Id>();
    for (Lead lead : newList) {
      filter(lead, oldMap, relevantLeadList, userIdSet);
    }
    System.debug(' how many relevant ?  ' + relevantLeadList.size());
    if (!relevantLeadList.isEmpty()) {
      Map<Id, User> userMap = getLeadWithOwnerInfoMap(userIdSet);

      for (Lead leadToUpdate : relevantLeadList) {
        User leadOwner = userMap.get(leadToUpdate.OwnerId);
        leadToUpdate.SLA_Start_Timestamp__c = calculateSla(
          leadOwner.TimeZoneSidKey,
          leadToUpdate
        );
      }
    }
  }

  private void filter(
    Lead lead,
    Map<Id, Lead> oldMap,
    List<Lead> relevantLeadList,
    Set<Id> userIdSet
  ) {
    if (
      lead.First_MQL_Date__c != oldMap.get(lead.Id).First_MQL_Date__c ||
      lead.Last_Owner_Assigned_Date__c !=
      oldMap.get(lead.id).Last_Owner_Assigned_Date__c
    ) {
      if (
        lead.First_MQL_Date__c != null &&
        String.valueOf(lead.OwnerId).startsWith('005')
      ) {
        relevantLeadList.add(lead);
        userIdSet.add(lead.OwnerId);
      }
    }
  }

  private Map<Id, User> getLeadWithOwnerInfoMap(Set<Id> userIdSet) {
    Map<Id, User> userMap = new Map<Id, User>(
      [SELECT Id, TimeZoneSidKey FROM User WHERE Id IN :userIdSet]
    );
    return userMap;
  }

  private Datetime calculateSla(String userTimeZone, Lead leadToUpdate) {
    Datetime currentDateTime = getLatestDateTime(leadToUpdate);
    Datetime calculatedSlaDateTime = SlaCalculationProcess.getCalculatedSlaDateTime(
      currentDateTime,
      userTimeZone
    );
    return calculatedSlaDateTime;
  }

  private Datetime getLatestDateTime(Lead leadToUpdate) {
    if (leadToUpdate.First_MQL_Date__c == null) {
      return leadToUpdate.Last_Owner_Assigned_Date__c;
    } else if (leadToUpdate.Last_Owner_Assigned_Date__c == null) {
      return leadToUpdate.First_MQL_Date__c;
    } else {
      return leadToUpdate.First_MQL_Date__c >
        leadToUpdate.Last_Owner_Assigned_Date__c
        ? leadToUpdate.First_MQL_Date__c
        : leadToUpdate.Last_Owner_Assigned_Date__c;
    }
  }

  public void reassignTaskOwner(List<Lead> newList, Map<Id, Lead> oldMap) {
    Map<Id, Id> leadToNewOwnerMap = new Map<Id, Id>();
    Map<Id, Id> leadToOldOwnerMap = new Map<Id, Id>();

    System.debug('reassignTaskOwner () ');
    for (Lead lead_i : newList) {
      if (lead_i.OwnerId != oldMap.get(lead_i.Id).OwnerId) {
        leadToNewOwnerMap.put(lead_i.Id, lead_i.OwnerId);
        leadToOldOwnerMap.put(lead_i.Id, oldMap.get(lead_i.Id).OwnerId);
      }
    }

    if (!leadToNewOwnerMap.isEmpty()) {
      List<String> neededStatuses = new List<String>{
        'Not Started',
        'In Progress',
        'Waiting on someone else'
      };
      List<Task> leadTasks = new List<Task>();
      System.debug('newList ' + newList + ', oldMap ' + oldMap);

      Map<Id, List<Task>> tasks = new Map<Id, List<Task>>();

      List<Task> relTasks;
      try {
        relTasks = [
          SELECT Id, Subject, OwnerId, Previous_Owner__c, WhoId, Status
          FROM Task
          WHERE WhoId IN :leadToNewOwnerMap.keySet()
          ORDER BY OwnerId
        ];
      } catch (Exception e) {
        insert new Trace_Log__c(
          Context__c = 'MIS-8352',
          Log__c = 'Exception 1: ' + e.getMessage()
        );
        throw e;
      }

      for (Task task_i : relTasks) {
        if (!tasks.containsKey(task_i.WhoId))
          tasks.put(task_i.WhoId, new List<Task>());
        tasks.get(task_i.WhoId).add(task_i);
      }
      System.debug('tasks ' + tasks);
      System.debug('leadToNewOwnerMap ' + leadToNewOwnerMap);

      Map<Id, Task> tasksToQuery = new Map<Id, Task>();

      for (Id leadId : tasks.keySet()) {
        for (Task leadTask : tasks.get(leadId)) {
          System.debug(
            'leadTask ' +
              leadTask +
              ' ==> \nlead new owner ' +
              leadToNewOwnerMap.get(leadId) +
              ' lead old owner ' +
              leadToOldOwnerMap.get(leadId)
          );
          if (leadTask.OwnerId == leadToNewOwnerMap.get(leadId)) {
            //task has the same owner as lead and isn't completed
            System.debug(
              'leadtask.Previous_Owner__c ' +
                leadtask.Previous_Owner__c +
                ' ' +
                leadToOldOwnerMap.get(leadId)
            );
            if (
              !(!String.isEmpty(leadTask.Subject) &&
              leadTask.Subject.toLowerCase().contains('contact us')) &&
              neededStatuses.contains(leadTask.Status) &&
              leadTask.Previous_Owner__c != leadToNewOwnerMap.get(leadId)
            ) {
              System.debug(
                'cond 1 , prev owner becomes ' +
                  leadTask.OwnerId +
                  ', new owner ' +
                  leadToOldOwnerMap.get(leadTask.WhoId)
              );
              leadTask.Previous_Owner__c = leadToOldOwnerMap.get(
                leadTask.WhoId
              );
              leadTask.OwnerId = leadToOldOwnerMap.get(leadTask.WhoId);
              //leadTask.OwnerId = String.isEmpty(leadTask.Previous_Owner__c) ? leadToOldOwnerMap.get(leadTask.WhoId) : leadTask.Previous_Owner__c;
              //leadTasks.add(leadTask);
            }
          } else {
            //
            if (
              !String.isEmpty(leadTask.Subject) &&
              leadTask.Subject.toLowerCase().contains('contact us') &&
              neededStatuses.contains(leadTask.Status)
            ) {
              System.debug('cond 2 ');
              leadTask.OwnerId = leadToNewOwnerMap.get(leadId);
              //leadTasks.add(leadTask);
            }
          }
          leadTask.Changed_from_Parent__c = DateTime.now() + '';
          leadTasks.add(leadTask);
        }
      }
      System.debug('leadTasks ' + leadTasks);
      try {
        update leadTasks;
      } catch (Exception e) {
        insert new Trace_Log__c(
          Context__c = 'MIS-8352',
          Log__c = 'Exception 2: ' + e.getMessage()
        );
        throw e;
      }
    }
  }
  public void setEmployeeMinTimestamp(
    List<Lead> newList,
    Map<Id, Lead> oldLeadMap
  ) {
    for (Lead lead_i : newList) {
      Lead oldLead = oldLeadMap.get(lead_i.Id);
      if (lead_i.Employees_Min__c != oldLead.Employees_Min__c) {
        lead_i.Employee_Min_Update_Timestamp__c = DateTime.now();
      }
    }
  }

  //    public void updateDomainFields(List<Lead> newList, Map<Id, Lead> oldLeadMap){
  //        List<Lead> toUpd = new List<Lead>();
  //        List <String> emailDomains = new List<String>();
  //
  //        if(Trigger.isInsert){
  //            for (Lead lead_i : newList){
  //                if(lead_i.Email_DomainClean__c != null){
  //                    toUpd.add(lead_i);
  //                    emailDomains.add(lead_i.Email_DomainClean__c);
  //                }
  //            }
  //        }
  //        else {
  //            for (Lead lead_i : newList){
  //                Lead leadOld_i = oldLeadMap.get(lead_i.Id);
  //                if(leadOld_i!=null && leadOld_i.Email != lead_i.Email && String.isNotBlank(lead_i.Email_DomainClean__c)){
  //                    toUpd.add(lead_i);
  //                    emailDomains.add(lead_i.Email_DomainClean__c);
  //                }
  //            }
  //        }
  //
  //        Map <String, String> existedDomainsToRT = new Map<String, String>();
  //        for(EmailDomain__c ed_i : [SELECT Name, RecordType.DeveloperName FROM EmailDomain__c WHERE Name IN: emailDomains]){
  //            existedDomainsToRT.put(ed_i.Name.toLowerCase(), ed_i.RecordType.DeveloperName);
  //        }
  //        for (Lead lead_i : toUpd){
  //            String recordTypeName = existedDomainsToRT.get(lead_i.Email_DomainClean__c);
  //            if(recordTypeName != null){
  //                if(recordTypeName == 'Junk_Emails'){
  //                    lead_i.Email_address_domain_type__c = 'Junk';
  //                    lead_i.HasOptedOutOfEmail = true;
  //                    lead_i.Email_Domain_Type_Timestamp__c = System.now();
  //                }
  //                else if(recordTypeName == 'Free'){
  //                    lead_i.Email_address_domain_type__c = 'Private';
  //                    lead_i.Email_Domain_Type_Timestamp__c = System.now();
  //                }
  //                else {
  //                    lead_i.Email_address_domain_type__c = 'Company';
  //                    lead_i.Email_Domain_Type_Timestamp__c = System.now();
  //                }
  //            }
  //            else {
  //                lead_i.Email_address_domain_type__c = 'Company';
  //                lead_i.Email_Domain_Type_Timestamp__c = System.now();
  //            }
  //        }
  //    }

  /**
   * ==CHANGE==
   * @author Itzik Winograd
   * @date 2022-09-11
   * @description: MIS-2694: Change from Polygraph_Company_Employees_Range__c to sw_connector__swId__r.sw_connector__Employee_Range__c
   * -----------
   * @author Itzik Winograd
   * @date 2022-10-18
   * @description MIS-3057: Complete Registration - make the owner change only if the current owner on the lead is a Group
   * -----------
   * @author Itzik Winograd
   * @date 2022-10-26
   * @description MIS-3088: Update the Enrichment_timestamp__c on enrichment from sw_connector__Employee_Range__c
   * -----------
   * @author Itzik Winograd
   * @date 2022-11-13
   * @description MIS-2370: get the values of the sw_connector__Employee_Range__c directly from the connector
   *
   * * -----------
   * @author Alon Shalev
   * @date 2023-02-19
   * @description MIS-3509: Override Emp Min/Max data with SI Enrich data - reactivate old process
   */

  //    public void updateEmployeeMinAndMax(Map<Id,Lead> newMap){
  //        Map<Id,Id> connectorIdByLeadId = new Map<Id,Id>();
  //        for (Id lead_Id : newMap.keySet()) {
  //            connectorIdByLeadId.put(lead_Id,newMap.get(lead_Id).sw_connector__swId__c);
  //        }
  //        Map<Id,sw_connector__SimilarWeb_Website_Data__c> connectorData = new Map<Id,sw_connector__SimilarWeb_Website_Data__c>([
  //                SELECT Id, sw_connector__Employee_Range__c
  //                FROM sw_connector__SimilarWeb_Website_Data__c
  //                WHERE Id IN: connectorIdByLeadId.values()
  //        ]);
  //        /*
  //        Map<Id,Lead> enrichedLeadMap = new Map<Id,Lead>([
  //                SELECT Id, Employees_Min__c, Employees_Max__c, sw_connector__swId__r.sw_connector__Employee_Range__c
  //                FROM Lead
  //                WHERE Id IN :newMap.keySet()]
  //        );*/
  //        for (Id lead_Id : newMap.keySet()) {
  //            String rangeFromEnrichment = connectorData.get(connectorIdByLeadId.get(lead_Id))?.sw_connector__Employee_Range__c;
  ////            String rangeFromEnrichment = enrichedLeadMap.get(lead_Id)?.sw_connector__swId__r?.sw_connector__Employee_Range__c;
  //            if(rangeFromEnrichment != null && newMap.get(lead_Id).Website != 'no_website') {
  //                Map<String, Integer> currentSWMinMaxMap = extractEmployeesMinMax(rangeFromEnrichment);
  //                if(newMap.get(lead_Id).Employees_Min__c == null || newMap.get(lead_Id).Employees_Min__c == 1 ){// && currentSWMinMaxMap.get('min') >= 10)  changed by alon shalev 16.02.23
  //                    System.debug('### updateEmployeeMinAndMax: updating the min max to: ' + currentSWMinMaxMap);
  //                    newMap.get(lead_Id).Employees_Min__c = currentSWMinMaxMap.get('min');
  //                    newMap.get(lead_Id).Employees_Max__c = currentSWMinMaxMap.get('max');
  //                    newMap.get(lead_Id).put('Enrichment_timestamp__c', Datetime.now());
  //                    /**Complete registration check; MIS-3124: removed to after save flow
  //                    if(newMap.get(lead_Id).OwnerId.getSObjectType().getDescribe().getName() == 'Group' && newMap.get(lead_Id).Company != null && newMap.get(lead_Id).Website != null &&
  //                            newMap.get(lead_Id).CountryCode != null && newMap.get(lead_Id).SW_Industry__c != null){
  //                        String ownerId = GeneralUtil.getGeneralConfig('sf_admin_user').Text_Value__c;
  //                        newMap.get(lead_Id).OwnerId = ownerId != null ? ownerId : '005b0000002iwIAAAY';
  //                    }*/
  //                }
  //            }
  //        }
  //    }

  //    /**
  //    * @author Itzik Winograd
  //    * @date 2022-09-11
  //    * @description: MIS-2694: Extract the Employees Min and Max values from a String with a range
  //    * @param String employeesMinMax a range, like 200 - 500
  // 	* @return Map<Sting,Integer> with 'min' and 'max' kes
  //    */
  //    public Map<String, Integer> extractEmployeesMinMax(String employeesMinMax){
  //        System.debug('### employeesMinMax: values from the connector:' + employeesMinMax);
  //        Map<String, Integer> minMaxMap = new Map<String, Integer>{'min'=> null, 'max' => null};
  //        switch on employeesMinMax  {
  //            when '0 - 10', '1 - 10' {
  //                minMaxMap.put('min', 1);
  //                minMaxMap.put('max', 10);
  //            }
  //            when '10 - 50' , '11 - 50'{
  //                minMaxMap.put('min', 11);
  //                minMaxMap.put('max', 50);
  //            }
  //            when '50 - 200', '51 - 200' {
  //                minMaxMap.put('min', 51);
  //                minMaxMap.put('max', 200);
  //            }
  //            when '200 - 500' {
  //                minMaxMap.put('min', 201);
  //                minMaxMap.put('max', 500);
  //            }
  //            when '500 - 1,000', '500- 1,000', '501 - 1,000' {
  //                minMaxMap.put('min', 501);
  //                minMaxMap.put('max', 1000);
  //            }
  //            when '1,000 - 5,000' {
  //                minMaxMap.put('min', 1001);
  //                minMaxMap.put('max', 5000);
  //            }
  //            when '5,000 - 10,000', '> 10,000'  {
  //                minMaxMap.put('min', 5001);
  //                minMaxMap.put('max', 10000);
  //            }
  //            when else {
  //                minMaxMap.put('min', null);
  //                minMaxMap.put('max', null);
  //            }
  //        }
  //        return minMaxMap;
  //    }

  public void marketingCloudAdjustment(
    List<Lead> newList,
    Map<Id, Lead> oldLeadMap
  ) {
    Map<String, List<Lead>> leadToInspectListBySolution = new Map<String, List<Lead>>();
    Map<String, SFMC_Processed_by_Distribution__c> solutionMapMDT = new Map<String, SFMC_Processed_by_Distribution__c>();
    for (SFMC_Processed_by_Distribution__c dist : [
      SELECT Id, Initial_Date__c, Processed_by_SFMC__c, Solution__c, Counter__c
      FROM SFMC_Processed_by_Distribution__c
    ]) {
      solutionMapMDT.put(dist.Solution__c, dist);
    }

    leadToInspectListBySolution = setupLeadsMapData(
      leadToInspectListBySolution,
      solutionMapMDT
    );
    for (Lead lid : newList) {
      if (
        solutionMapMDT.containsKey(lid.Inferred_Solution__c) &&
        !lid.Is_Distribution_Handled__c
      ) {
        if (
          !String.isBlank(lid.Inferred_Solution__c) &&
          (date.today() >
          solutionMapMDT.get(lid.Inferred_Solution__c).Initial_Date__c)
        ) {
          if (
            (oldLeadMap == null) ||
            (oldLeadMap.get(lid.Id).Inferred_Solution__c !=
            lid.Inferred_Solution__c)
          ) {
            if (solutionMapMDT.containsKey(lid.Inferred_Solution__c)) {
              lid.Is_Distribution_Handled__c = true;
              //leadToInspectListBySolution.get(lid.Inferred_Solution__c).add(lid);
            }
          }
        }
      }
    }
  }

  private Map<String, List<Lead>> setupLeadsMapData(
    Map<String, List<Lead>> leadToInspectListBySolution,
    Map<String, SFMC_Processed_by_Distribution__c> solutionMapMDT
  ) {
    for (String solution : solutionMapMDT.keySet()) {
      leadToInspectListBySolution.put(solution, new List<Lead>());
    }
    return leadToInspectListBySolution;
  }

  /**
   * @author Zohar Sinay
   * @date 27/03/2022
   * @description: Prevent lead gen id field and all others from updating and storing the timestamp of the change.
   * @param List<Contact> newList - new list of contacts
   * @param Map<Id,Contact> oldMap - map of trigger.old contacts
   */
  public void leadGenIdPreventionManagement(
    List<Lead> newList,
    Map<Id, Lead> oldMap
  ) {
    Schema.FieldSet fs2 = Schema.SObjectType.Lead.fieldSets.LeadCapture_field_set_Lead;
    for (Lead lid : newList) {
      for (Schema.FieldSetMember f : fs2.getFields()) {
        if (
          lid.get(f.getFieldPath()) !=
          oldMap.get(lid.Id).get(f.getFieldPath()) &&
          oldMap.get(lid.Id).get(f.getFieldPath()) != null
        ) {
          lid.put(f.getFieldPath(), oldMap.get(lid.Id).get(f.getFieldPath()));
        }
      }
    }
  }

  /**
   * @param newList
   * @param oldLeadMap
   * added by Zohar Sinay 09.10.22 this method only filters the update for the updateDomainFields process
   */

  public void updateDomainFieldsOnUpdate(
    List<Lead> newList,
    Map<Id, Lead> oldLeadMap
  ) {
    List<Lead> leadToUpdateList = new List<Lead>();
    for (Lead newLead : newList) {
      Lead oldLead = oldLeadMap.get(newLead.Id);
      if (
        newLead.Email != oldLead.Email ||
        newLead.Secondary_email__c != oldLead.Secondary_email__c ||
        newLead.LinkedIn_Profile__c != oldLead.LinkedIn_Profile__c ||
        newLead.Website != oldLead.Website
      ) {
        leadToUpdateList.add(newLead);
      }
    }
    System.debug('leadToUpdateList: ' + leadToUpdateList);
    if (!leadToUpdateList.isEmpty()) {
      updateDomainFields(leadToUpdateList);
    }
  }

  /**
   * @param newList - lead list to check against
   * changed by Zohar Sinay : 09.10.22
   * calculate the Email_address_domain_type__c according to the recordtype of the email address domain
   * ======change========
   * @author Itzik Winograd
   * @date 07/11/2022
   * @description MIS-3124: check the recalculate business unit instead of calling the whole batch
   */
  public void updateDomainFields(List<Lead> newList) {
    List<Lead> toUpd = new List<Lead>();
    Set<String> emailDomainSet = new Set<String>();
    for (Lead lead_i : newList) {
      String primaryDomain = lead_i.Email?.substringAfter('@').trim();
      String secondaryDomain = lead_i.Secondary_email__c
        ?.substringAfter('@')
        .trim();
      if (primaryDomain != null || secondaryDomain != null) {
        toUpd.add(lead_i);
        emailDomainSet.addAll(
          new Set<String>{ primaryDomain, secondaryDomain }
        );
      }
    }
    Map<String, String> existedDomainsToRT = new Map<String, String>();
    for (EmailDomain__c ed_i : [
      SELECT Name, RecordType.DeveloperName
      FROM EmailDomain__c
      WHERE Name IN :emailDomainSet
    ]) {
      existedDomainsToRT.put(
        ed_i.Name.toLowerCase(),
        ed_i.RecordType.DeveloperName
      );
    }

    //List<Id> recalculateBULeadIdList = new List<Id>();

    for (Lead lead_i : toUpd) {
      calculateDomain(
        existedDomainsToRT,
        lead_i,
        lead_i.Email?.substringAfter('@').trim(),
        false
      );

      if (
        lead_i.Email_address_domain_type__c == 'Private' &&
        String.isNotBlank(lead_i.LinkedIn_Profile__c) &&
        !lead_i.LinkedIn_Profile__c.contains('didnotfind.com')
      ) {
        lead_i.Email_address_domain_type__c = 'Company - Secondary';
      } else if (
        lead_i.Email_address_domain_type__c != 'Company' &&
        !String.isBlank(lead_i.Secondary_email__c) &&
        (lead_i.Secondary_email__c
          ?.substringAfter('@')
          ?.trim()
          .equalsIgnoreCase(lead_i.Master_Website__c?.trim()))
      ) {
        calculateDomain(
          existedDomainsToRT,
          lead_i,
          lead_i.Secondary_email__c?.substringAfter('@').trim(),
          true
        );
        //recalculateBULeadIdList.add(lead_i.Id);
        lead_i.put('Recalculate_Business_Unit__c', true);
      }
    } /*
        if(!recalculateBULeadIdList.isEmpty()){
            recalculateBU(recalculateBULeadIdList);
        }*/
  }

  //    @future
  /**
   * @param recalculateBULeadIDList - A list of the leads to recalculate the Business unit for
   * created by Zohar Sinay 24.10.22
   * Description: Method is used to reactivate the BU calculation in case the secondary email gets a lead to be a company - secondary
   */
  //    static void recalculateBU (List<Id> recalculateBULeadIDList){
  //        List<Lead> recalculateBULeadList = [SELECT Id,OwnerId,CreatedById,Country, Business_Unit__c, Employees_Min__c, Clean_Domain__c,Polygraph_Company_Name__c,Orchestration_Journey__c, Email_address_domain_type__c  FROM Lead WHERE Id IN: recalculateBULeadIDList];
  //        String ldrOwnerSetting = String.valueOf(Pardot_Data_Manipulation_Setting__c.getInstance('LDR_LEAD_OWNER_ID').Value__c);
  //        BusinessUnitUpdateHelper buuh = new BusinessUnitUpdateHelper();
  //        buuh.updateBusinessUnit(recalculateBULeadList, 'Clean_Domain__c', 'Country', ldrOwnerSetting, false);
  //    }

  /**
   * @param existedDomainsToRT - record type map of the email address domain record types
   * @param lead_i - lead for which we update the email_address_domain_type
   * @param domainName - domain name for which we choose the record type
   * @param isSecondary - Indicates whether the calculation is based secondary email
   * created by Zohar Sinay 18.10.22
   * Description: Method is used to calculate the email domain for a specific lead
   */
  private void calculateDomain(
    Map<String, String> existedDomainsToRT,
    Lead lead_i,
    String domainName,
    Boolean isSecondary
  ) {
    System.debug('existedDomainsToRT: ' + existedDomainsToRT);
    System.debug('domainName: ' + domainName);
    String recordTypeName = existedDomainsToRT.get(domainName);
    System.debug('recordTypeName: ' + recordTypeName);
    Map<String, String> recordTypeNameToDomainTypeMap = new Map<String, String>{
      'Junk_Emails' => 'Junk',
      'Free' => 'Private'
    };
    lead_i.Email_Domain_Type_Timestamp__c = System.now();

    if (isSecondary) {
      if (recordTypeNameToDomainTypeMap.containsKey(recordTypeName)) {
        lead_i.Email_address_domain_type__c = recordTypeNameToDomainTypeMap.get(
          recordTypeName
        );
        lead_i.Email_address_domain_type_details__c = String.isBlank(
            lead_i.Email_address_domain_type_details__c
          ) || lead_i.Email_address_domain_type_details__c == 'Private'
          ? lead_i.Email_address_domain_type__c
          : lead_i.Email_address_domain_type_details__c;
      } else {
        lead_i.Email_address_domain_type__c = 'Company - Secondary';
        lead_i.Email_address_domain_type_details__c = String.isBlank(
            lead_i.Email_address_domain_type_details__c
          ) || lead_i.Email_address_domain_type_details__c == 'Private'
          ? lead_i.Email_address_domain_type__c
          : lead_i.Email_address_domain_type_details__c;
        lead_i.Website = lead_i.Master_Website__c;
      }
    } else {
      lead_i.Email_address_domain_type__c = recordTypeNameToDomainTypeMap.containsKey(
          recordTypeName
        )
        ? recordTypeNameToDomainTypeMap.get(recordTypeName)
        : 'Company';
      lead_i.Email_address_domain_type_details__c = String.isBlank(
          lead_i.Email_address_domain_type_details__c
        ) || lead_i.Email_address_domain_type_details__c == 'Private'
        ? lead_i.Email_address_domain_type__c
        : lead_i.Email_address_domain_type_details__c;
    }
  }

  /**
   * @param newList
   * created by Zohar Sinay 18.10.22
   * Description: Method sets the Master website whenever the lead receives a first value that is not no_website on the Website, and stores it there for good.
   */
  public void fillMasterDomain(List<Lead> newList) {
    for (Lead lid : newList) {
      if (
        String.isBlank(lid.Master_Website__c) &&
        (String.isNotBlank(lid.Website) &&
        (!lid.Website.equalsIgnoreCase('no_website')))
      ) {
        System.debug('lid.Website_Domain__c: ' + lid.Website_Domain__c);
        lid.Master_Website__c = lid.Website_Domain__c;
      }
    }
  }

  /**
   * @author Itzik Winograd
   * @description MIS-3230: Dont call polygraph. just update the timestamps fields.
   * @date 2022-11-08
   * */
  public void setPolygraphTimeStamps(List<Lead> newLeads) {
    for (Lead lead : newLeads) {
      lead.put('Sent_to_Polygraph__c', System.now());
      if (lead.get('Polygraph_Update_Timestamp__c') == null) {
        lead.put('Polygraph_Update_Timestamp__c', System.now());
      }
    }
  }

  public void recalculateBusinessUnit(
    List<Lead> newList,
    Map<Id, Lead> oldMap
  ) {
    System.debug('nullifyStratPodOfPrivateLead');
    for (Lead leadItem : newList) {
      if (
        leadItem.Website != oldMap.get(leadItem.Id).Website ||
        leadItem.Business_Unit__c != oldMap.get(leadItem.Id).Business_Unit__c ||
        leadItem.LinkedIn_Profile__c !=
        oldMap.get(leadItem.Id).LinkedIn_Profile__c
      ) {
        leadItem.Recalculate_Business_Unit__c = true;
      }
    }
  }
  public void resetWebsiteVerifiedOnWebsiteUpdate(
    List<Lead> newList,
    Map<Id, Lead> oldMap
  ) {
    System.debug('resetWebsiteVerifiedOnWebsiteUpdate--');
    for (Lead leadItem : newList) {
      if (leadItem.Website != oldMap.get(leadItem.Id).Website) {
        System.debug(' i am here to reset the website!!');
        System.debug(leadItem.Website_Verified__c + ' this is before');
        leadItem.Website_Verified__c = null;
      }
    }
  }

  public static Set<String> getFakeDomains(Set<String> domainsToCheck) {
    if (domainsToCheck == null || domainsToCheck.isEmpty()) {
      return new Set<String>();
    }

    List<Fake_Domain__mdt> fakeDomainMDTs = [
      SELECT Id, Domain__c
      FROM Fake_Domain__mdt
      WHERE Domain__c IN :domainsToCheck
    ];
    Set<String> fakeDomains = new Set<String>();

    for (Fake_Domain__mdt fd : fakeDomainMDTs) {
      fakeDomains.add(fd.Domain__c);
    }

    return fakeDomains;
  }

  private void markForceEnrichment(List<Lead> oldLeads, List<Lead> newLeads) {
    List<Lead> forceEnrichmentLeads = new List<Lead>();

    for (Integer i = 0; i < newLeads.size(); i++) {
      Lead oldLead = oldLeads.get(i), newLead = newLeads.get(i);

      if (
        (newLead.Groudon_Timestamp__c == null ||
        newLead.Groudon_Timestamp__c < Datetime.now().addDays(-30)) &&
        newLead.CreatedDate > Datetime.now().addYears(-2) &&
        newLead.CreatedDate < Datetime.now().addDays(-60) &&
        oldLead.LastActivityDate__c != newLead.LastActivityDate__c
      ) {
        forceEnrichmentLeads.add(
          new Lead(Id = newLead.Id, Force_Enrichment__c = true)
        );
      }
    }

    if (forceEnrichmentLeads.size() > 0) {
      try {
        update forceEnrichmentLeads;
      } catch (Exception e) {
        insert new Trace_Log__c(
          Context__c = 'MIS-8352',
          Log__c = 'Exception 4: ' + e.getMessage()
        );
        throw e;
      }
    }
  }
}

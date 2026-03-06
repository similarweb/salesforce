/*
 * Made by Dmitry Trufanov from Synebo
 */
public class PardotDataManipulationHandler {
  public void frenemiesFlow() {
    try {
      Pardot_Data_Manipulation_Setting__c minutesSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
        'FRENEMY_FLOW_MINUTES'
      );
      if (minutesSetting != null) {
        Set<String> domainSet = new Set<String>();
        List<Lead> leadToPerformList = new List<Lead>();
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
          //check if Polygraph reply was recieved
          if (
            lead_i.Polygraph_Update_Timestamp__c != null &&
            oldLead_i.Polygraph_Update_Timestamp__c == null
          ) {
            domainSet.add(lead_i.Email_DomainClean__c);
            leadToPerformList.add(lead_i);
          }
        }
        Set<String> existFrenemySet = new Set<String>();
        for (Frenemy__c frenemy_i : [
          SELECT Id, Name
          FROM Frenemy__c
          WHERE Name IN :domainSet
        ]) {
          existFrenemySet.add(frenemy_i.Name.toLowerCase());
        }
        Set<Id> frenemyLeadSet = new Set<Id>();
        for (Lead lead_i : leadToPerformList) {
          //check if Email_DomainClean__c math in Frenemy__c.Name
          if (
            (String.isNotBlank(lead_i.Email_DomainClean__c) &&
            existFrenemySet.contains(
              lead_i.Email_DomainClean__c.toLowerCase()
            )) && lead_i.Unverified_Reason__c != 'Unauthorized Country'
          ) {
            frenemyLeadSet.add(lead_i.Id);
          }
        }
        //run scheduler that that will make changes
        if (!frenemyLeadSet.isEmpty()) {
          Integer minutes = Integer.valueOf(minutesSetting.Value__c);
          Datetime workTime = System.now().addMinutes(minutes);
          String cronExpression = getCronFromDateTime(workTime);
          System.schedule(
            'Frenemy_Flow_' + System.now().getTime(),
            cronExpression,
            new FrenemyDataPopulationSchedule(frenemyLeadSet)
          );
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
  }

  private String getCronFromDateTime(Datetime executeTime) {
    return executeTime.second() +
      ' ' +
      executeTime.minute() +
      ' ' +
      executeTime.hour() +
      ' ' +
      executeTime.day() +
      ' ' +
      executeTime.month() +
      ' ? ' +
      executeTime.year();
  }

  public void unsubscribeFlow() {
    try {
      if (Trigger.isInsert) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          if (
            lead_i.HasOptedOutOfEmail &&
            lead_i.Unverified_Reason__c != 'Unauthorized Country'
          ) {
            lead_i.Pardot_List_Assignment__c = 'Recycle Bin';
          }
        }
      } else if (Trigger.isUpdate) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
          if (
            lead_i.HasOptedOutOfEmail &&
            !oldLead_i.HasOptedOutOfEmail &&
            lead_i.Unverified_Reason__c != 'Unauthorized Country'
          ) {
            lead_i.Pardot_List_Assignment__c = 'Recycle Bin';
          }
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
  }

  public void leadSourceDealRegistrationFlow() {
    try {
      List<RecordType> panelAcquisitionRTList = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Lead' AND DeveloperName = 'Wolves'
        LIMIT 1
      ];
      RecordType panelAcquisitionRT = new RecordType();
      if (!panelAcquisitionRTList.isEmpty()) {
        panelAcquisitionRT = panelAcquisitionRTList[0];
      }
      if (Trigger.isInsert) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          if (lead_i.Unverified_Reason__c != 'Unauthorized Country') {
            if (panelAcquisitionRT.Id == lead_i.RecordTypeId) {
              leadSourceDealRegistrationDataPopulation(lead_i, false);
            } else if (
              lead_i.LeadSource == 'Deal Registration' ||
              lead_i.Original_Lead_Source__c == 'Deal Registration'
            ) {
              leadSourceDealRegistrationDataPopulation(lead_i, true);
            }
          }
        }
      } else if (Trigger.isUpdate) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
          if (lead_i.Unverified_Reason__c != 'Unauthorized Country') {
            if (
              panelAcquisitionRT.Id == lead_i.RecordTypeId &&
              lead_i.RecordTypeId != oldLead_i.RecordTypeId
            ) {
              leadSourceDealRegistrationDataPopulation(lead_i, false);
            } else if (
              (lead_i.LeadSource == 'Deal Registration' &&
              lead_i.LeadSource != oldLead_i.LeadSource) ||
              (lead_i.Original_Lead_Source__c == 'Deal Registration' &&
              lead_i.Original_Lead_Source__c !=
              oldLead_i.Original_Lead_Source__c)
            ) {
              leadSourceDealRegistrationDataPopulation(lead_i, true);
            }
          }
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
  }

  private void leadSourceDealRegistrationDataPopulation(
    Lead lead_i,
    Boolean isReasonDeal
  ) {
    lead_i.Pardot_List_Assignment__c = 'Recycle Bin';
    lead_i.Orchestration_Journey_Status__c = 'Excluded';
    lead_i.Journey_Completed_Timestamp__c = System.now();
    lead_i.Unverified_Reason__c = isReasonDeal
      ? 'Deal Registration'
      : 'Panel Acquisition';
  }

  public void outboundLeadsFlow() {
    try {
      if (Trigger.isInsert) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          if (
            (lead_i.LeadSource != null &&
            lead_i.LeadSource.containsIgnoreCase('Outbound')) ||
            (lead_i.Original_Lead_Source__c != null &&
            lead_i.Original_Lead_Source__c.containsIgnoreCase('Outbound')) &&
            lead_i.Unverified_Reason__c != 'Unauthorized Country'
          ) {
            outboundLeadsDataPopulation(lead_i);
          }
        }
      } else if (Trigger.isUpdate) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
          if (
            (lead_i.LeadSource != null &&
            lead_i.LeadSource.containsIgnoreCase('Outbound') &&
            lead_i.LeadSource != oldLead_i.LeadSource) ||
            (lead_i.Original_Lead_Source__c != null &&
            lead_i.Original_Lead_Source__c.containsIgnoreCase('Outbound') &&
            lead_i.Original_Lead_Source__c !=
            oldLead_i.Original_Lead_Source__c) &&
            lead_i.Unverified_Reason__c != 'Unauthorized Country'
          ) {
            outboundLeadsDataPopulation(lead_i);
          }
        }
      }
    } catch (Exception e) {
    }
  }

  private void outboundLeadsDataPopulation(Lead lead_i) {
    lead_i.Pardot_List_Assignment__c = 'Recycle Bin';
    lead_i.Orchestration_Journey_Status__c = 'Excluded';
    lead_i.Journey_Completed_Timestamp__c = System.now();
    lead_i.Unverified_Reason__c = 'Outbound';
  }

  public void similarWebEmployeesFlow() {
    try {
      Pardot_Data_Manipulation_Setting__c ownerSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
        'JUNK_LEAD_OWNER_ID'
      );
      if (Trigger.isInsert) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          if (
            String.isNotBlank(lead_i.Email_DomainClean__c) &&
            lead_i.Email_DomainClean__c.containsIgnoreCase('similarweb') &&
            lead_i.Unverified_Reason__c != 'Unauthorized Country'
          ) {
            similarWebEmployeesDataPopulation(lead_i, ownerSetting);
          }
        }
      } else if (Trigger.isUpdate) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
          if (
            lead_i.Email != oldLead_i.Email &&
            lead_i.Email_DomainClean__c.containsIgnoreCase('similarweb') &&
            lead_i.Unverified_Reason__c != 'Unauthorized Country'
          ) {
            similarWebEmployeesDataPopulation(lead_i, ownerSetting);
          }
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
  }

  private void similarWebEmployeesDataPopulation(
    Lead lead_i,
    Pardot_Data_Manipulation_Setting__c ownerSetting
  ) {
    if (ownerSetting != null && String.isNotBlank(ownerSetting.Value__c)) {
      lead_i.OwnerId = ownerSetting.Value__c;
    }
    lead_i.Unverified_Reason__c = 'Employee';
    lead_i.Orchestration_Journey_Status__c = 'Excluded';
    lead_i.Journey_Completed_Timestamp__c = System.now();
    lead_i.Pardot_List_Assignment__c = 'Recycle Bin';
  }

  public void checkIfCountryAuthorized() {
    try {
      Pardot_Data_Manipulation_Setting__c ownerSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
        'JUNK_LEAD_OWNER_ID'
      );
      if (Trigger.isInsert) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          if (
            lead_i.Country == 'Iran' ||
            lead_i.Country == 'Syria' ||
            lead_i.Country == 'Lebanon'
          ) {
            lead_i.Unverified_Reason__c = 'Unauthorized Country';
            lead_i.Exclude_from_Funnel_Journey__c = true;
            if (
              ownerSetting != null && String.isNotBlank(ownerSetting.Value__c)
            ) {
              lead_i.OwnerId = ownerSetting.Value__c;
            }
          }
        }
      } else if (Trigger.isUpdate) {
        for (Lead lead_i : (List<Lead>) Trigger.new) {
          Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
          if (
            oldLead_i.Country != lead_i.Country &&
            (lead_i.Country == 'Iran' ||
            lead_i.Country == 'Syria' ||
            lead_i.Country == 'Lebanon')
          ) {
            lead_i.Unverified_Reason__c = 'Unauthorized Country';
            lead_i.Exclude_from_Funnel_Journey__c = true;
            if (
              ownerSetting != null && String.isNotBlank(ownerSetting.Value__c)
            ) {
              lead_i.OwnerId = ownerSetting.Value__c;
            }
          }
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
  }

  /*
    public void blackListFlow(){
        System.debug('1');
        try{
            Pardot_Data_Manipulation_Setting__c ownerSetting = Pardot_Data_Manipulation_Setting__c.getInstance('JUNK_LEAD_OWNER_ID');
            if(Trigger.isInsert){
                for(Lead lead_i : (List<Lead>)Trigger.new){
                    if(lead_i.Email_address_domain_type__c == 'Junk'){
                        blackListDataPopulation(lead_i,ownerSetting);
                    }
                }
            }else if(Trigger.isUpdate){
                for(Lead lead_i : (List<Lead>)Trigger.new){
                    Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
                    if(lead_i.Email_address_domain_type__c != oldLead_i.Email_address_domain_type__c && lead_i.Email_address_domain_type__c == 'Junk'){
                        System.debug('qqq');
                        blackListDataPopulation(lead_i,ownerSetting);
                    }
                }
            }
        } catch(Exception e){
            System.debug(e);
        }
    }
    
    private void blackListDataPopulation(Lead lead_i,Pardot_Data_Manipulation_Setting__c ownerSetting){
        if(ownerSetting != null && String.isNotBlank(ownerSetting.Value__c)){
            lead_i.OwnerId = ownerSetting.Value__c;
        }
        lead_i.Unverified_Reason__c = 'Junk';
        lead_i.Orchestration_Journey_Status__c = 'Excluded';
        lead_i.Journey_Completed_Timestamp__c = System.now();
    }

    public void setLdrLeadOwner(){
Pardot_Data_Manipulation_Setting__c ldrOwnerSetting = Pardot_Data_Manipulation_Setting__c.getInstance('LDR_LEAD_OWNER_ID');
if(Trigger.isInsert){
for(Lead lead_i : (List<Lead>)Trigger.new){
// set owner to LDR if Orchestration_Journey__c=='LDR' and current owner not the Frenemy owner
if(lead_i.Orchestration_Journey__c=='LDR' &&  lead_i.Unverified_Reason__c !='Frenemies'){
lead_i.OwnerId=ldrOwnerSetting.Value__c;
}
}
} else if(Trigger.isUpdate){            
for(Lead lead_i : (List<Lead>)Trigger.new){
Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
// set owner to LDR if Orchestration_Journey__c=='LDR' and current owner not the Frenemy owner
if( lead_i.Orchestration_Journey__c=='LDR' && lead_i.Unverified_Reason__c !='Frenemies') 
{
lead_i.OwnerId=ldrOwnerSetting.Value__c;
}
}
}
}*/
  public void verifyCheck() {
    Pardot_Data_Manipulation_Setting__c unverifiedOwnerSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
      'UNVERIFIED_LEAD_OWNER_ID'
    );
    for (Lead lead_i : (List<Lead>) Trigger.new) {
      Lead oldLead_i = (Lead) Trigger.oldMap.get(lead_i.Id);
      if (
        lead_i.verified__c == 'Unverified' &&
        lead_i.verified__c != oldLead_i.verified__c &&
        lead_i.Unverified_Reason__c != 'Unauthorized Country'
      ) {
        lead_i.OwnerId = unverifiedOwnerSetting.Value__c;
      }
    }
  }
  public void journeyDecisionFlow() {
    try {
      Pardot_Data_Manipulation_Setting__c ldrOwnerSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
        'LDR_LEAD_OWNER_ID'
      );
      Pardot_Data_Manipulation_Setting__c frenemyOwnerSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
        'FRENEMY_LEAD_OWNER_ID'
      );
      Pardot_Data_Manipulation_Setting__c junkOwnerSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
        'JUNK_LEAD_OWNER_ID'
      );
      Pardot_Data_Manipulation_Setting__c unverifiedOwnerSetting = Pardot_Data_Manipulation_Setting__c.getInstance(
        'UNVERIFIED_LEAD_OWNER_ID'
      );
      List<String> baseLeadLdrOwnerIdList = Pardot_Data_Manipulation_Setting__c.getInstance(
          'BASIC_LDR_LEAD_OWNER_ID_LIST'
        )
        .Value__c.split(';');
      for (Lead lead_i : (List<Lead>) Trigger.new) {
        // execute if Orchestration_Journey__c==null and Polygraph reply was received
        //2021-09-02 - Itzik: Added lead_i.Business_Unit__c!=null
        if (
          lead_i.Orchestration_Journey__c == null &&
          lead_i.Business_Unit__c != null &&
          lead_i.Polygraph_Update_Timestamp__c != null &&
          lead_i.Unverified_Reason__c != 'Unauthorized Country'
        ) {
          Map<String, Boolean> ldrCriteriaMap = generateLdrCriteriaMap(lead_i);
          Boolean isLdr = false;
          for (String ownerId_i : baseLeadLdrOwnerIdList) {
            ownerId_i = ownerId_i.trim();
            if (((String) lead_i.OwnerId).startsWithIgnoreCase(ownerId_i)) {
              isLdr = true;
              break;
            }
          }
          // if(isLdr){
          //     isLdr = new BooleanComparison(ldrCriteriaMap.get('fourthCriteria'))
          //         .booleanAND(ldrCriteriaMap.get('fifthCriteria'))
          //         .booleanAND(
          //             new BooleanComparison(ldrCriteriaMap.get('firstCriteria'))
          //             .booleanOR(
          //                 new BooleanComparison(ldrCriteriaMap.get('secondCriteria'))
          //                 .booleanAND(ldrCriteriaMap.get('thirdCriteria'))
          //                 .booleanAND(
          //                     new BooleanComparison(
          //                         new BooleanComparison(ldrCriteriaMap.get('sixthCriteria'))
          //                         .booleanAND(ldrCriteriaMap.get('seventhCriteria'))
          //                         .getResult()
          //                     ).booleanOR(
          //                         new BooleanComparison(ldrCriteriaMap.get('eighthCriteria'))
          //                         .booleanAND(ldrCriteriaMap.get('ninthCriteria'))
          //                         .getResult()
          //                     )
          //                     .getResult()
          //                 )
          //                 .getResult()
          //             )
          //             .getResult()
          //         )
          //         .getResult();
          // }

          if (isLdr) {
            isLdr = new BooleanComparison(ldrCriteriaMap.get('fourthCriteria'))
              .booleanAND(
                new BooleanComparison(ldrCriteriaMap.get('firstCriteria'))
                  .booleanOR(
                    new BooleanComparison(ldrCriteriaMap.get('thirdCriteria'))
                      .booleanAND(ldrCriteriaMap.get('tenthCriteria'))
                      .getResult()
                  )
                  .getResult()
              )
              .getResult();
          }

          System.debug('isLDR - ' + isLdr);
          if (lead_i.Last_Contact_Us_Form_Subject__c != null) {
            lead_i.Orchestration_Journey__c = 'Fast Track';
          }
          //                    else if(isLdr)
          //                    {
          //                        if(new BooleanComparison(ldrCriteriaMap.get('secondCriteria'))
          //                           .booleanAND(ldrCriteriaMap.get('thirdCriteria'))
          //                           .booleanAND(ldrCriteriaMap.get('fourthCriteria'))
          //                           .booleanAND(ldrCriteriaMap.get('fifthCriteria')).getResult())
          //                        {
          //                            lead_i.LDR_Journey_Reason__c='Multiple reasons';
          //                        } else if( new BooleanComparison(ldrCriteriaMap.get('secondCriteria'))
          //                                  .booleanAND(ldrCriteriaMap.get('thirdCriteria'))
          //                                  .booleanAND(ldrCriteriaMap.get('firstCriteria'))
          //                                  .booleanAND(ldrCriteriaMap.get('fifthCriteria')).getResult())
          //                        {
          //                            lead_i.LDR_Journey_Reason__c='Multiple reasons';
          //                        } else if(new BooleanComparison(ldrCriteriaMap.get('firstCriteria'))
          //                                  .booleanAND(ldrCriteriaMap.get('fifthCriteria')).getResult() )
          //                        {
          //                            lead_i.LDR_Journey_Reason__c='Mandatory field is empty';
          //                        }else if(new BooleanComparison(ldrCriteriaMap.get('secondCriteria'))
          //                                 .booleanAND(ldrCriteriaMap.get('thirdCriteria'))
          //                                 .booleanAND(ldrCriteriaMap.get('fifthCriteria')).getResult())
          //                        {
          //                            lead_i.LDR_Journey_Reason__c='Company not equal to Polygraph';
          //                        }else if( new BooleanComparison(ldrCriteriaMap.get('fourthCriteria'))
          //                                 .booleanAND(ldrCriteriaMap.get('fifthCriteria')).getResult())
          //                        {
          //                            lead_i.LDR_Journey_Reason__c='Country is not equal to Polygraph';
          //                        } else {
          //                            lead_i.LDR_Journey_Reason__c='Others';
          //                        }
          //
          //
          //                        lead_i.Orchestration_Journey__c='LDR';
          //                        lead_i.OwnerId=ldrOwnerSetting.Value__c;
          //                        if(lead_i.Unverified_Reason__c == 'Frenemies' && lead_i.Exclude_from_Funnel_Journey__c == true){
          //                            lead_i.LDR_Journey_Reason__c='Frenemies';
          //                            lead_i.OwnerId=frenemyOwnerSetting.Value__c;
          //                        }/*else if(lead_i.Unverified_Reason__c == 'Junk' && lead_i.Exclude_from_Funnel_Journey__c == true){
          //                            lead_i.LDR_Journey_Reason__c='Junk';
          //                            lead_i.OwnerId=junkOwnerSetting.Value__c;
          //                        }*/else if(lead_i.Unverified_Reason__c == 'Employees' && lead_i.Exclude_from_Funnel_Journey__c == true){
          //                            lead_i.LDR_Journey_Reason__c='Employees';
          //                            lead_i.OwnerId=ldrOwnerSetting.Value__c;
          //                        }
          //
          //
          //                        if(new BooleanComparison(ldrCriteriaMap.get('firstCriteria'))
          //                           .booleanAND(ldrCriteriaMap.get('fifthCriteria')).getResult())
          //                        {
          //                            lead_i.LDR_Journey_Reason__c='Missing Fields';
          //                        } else if(new BooleanComparison(ldrCriteriaMap.get('secondCriteria')).getResult())
          //                        {
          //                            lead_i.LDR_Journey_Reason__c='Comparison';
          //                        }
          //                    }
          else {
            lead_i.Orchestration_Journey__c = 'Standard';
          }
        }
      }
    } catch (Exception e) {
      System.debug(e);
    }
  }

  private Map<String, Boolean> generateLdrCriteriaMap(Lead lead_i) {
    LDRsettingMapWrapper ldrSettingWrapper = new LDRsettingMapWrapper(lead_i);

    Map<String, Boolean> ldrConditionsMap = new Map<String, Boolean>();
    Boolean firstCriteria;
    Boolean secondCriteria;
    Boolean thirdCriteria;
    Boolean fourthCriteria;
    Boolean fifthCriteria;
    Boolean sixthCriteria;
    Boolean seventhCriteria;
    Boolean eighthCriteria;
    Boolean ninthCriteria;
    Boolean tenthCriteria;

    firstCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Is null (FirstName)')
      )
      .booleanOR(ldrSettingWrapper.get('Is null (Company)'))
      .booleanOR(ldrSettingWrapper.get('Is null (Website)'))
      .booleanOR(ldrSettingWrapper.get('Is null (Employee Min)'))
      .booleanOR(ldrSettingWrapper.get('Is null (Employee Max)'))
      .booleanOR(ldrSettingWrapper.get('Is null (SW Industry)'))
      .booleanOR(ldrSettingWrapper.get('Is null (Country)'))
      .booleanOR(ldrSettingWrapper.get('Is null (Email)'))
      .getResult();
    secondCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Company_LDR_Compare__c=False')
      )
      .getResult();
    thirdCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Email domain type = Private')
      )
      .getResult();
    fourthCriteria = new BooleanComparison(
        ldrSettingWrapper.get('LeadSource != NULL')
      )
      .booleanAND(ldrSettingWrapper.get('LeadSource not contains Outbound'))
      .booleanAND(ldrSettingWrapper.get('LeadSource!= Deal Registration'))
      .getResult();
    fifthCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Not(Country=Japan)')
      )
      .booleanAND(ldrSettingWrapper.get('Not(Country=Vietnam)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Viet Nam)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=China)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Taiwan)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Hong Kong)'))
      .getResult();
    sixthCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Country=United States')
      )
      .booleanOR(ldrSettingWrapper.get('Country=France'))
      .booleanOR(ldrSettingWrapper.get('Country=Germany'))
      .booleanOR(ldrSettingWrapper.get('Country=United Kingdom'))
      .booleanOR(ldrSettingWrapper.get('Country=Switzerland'))
      .booleanOR(ldrSettingWrapper.get('Country=Belgium'))
      .booleanOR(ldrSettingWrapper.get('Country=Austria'))
      .booleanOR(ldrSettingWrapper.get('Country=Canada'))
      .booleanOR(ldrSettingWrapper.get('Country=Netherlands'))
      .booleanOR(ldrSettingWrapper.get('Country=Luxembourg'))
      .booleanOR(ldrSettingWrapper.get('Country=Denmark'))
      .booleanOR(ldrSettingWrapper.get('Country=Finland'))
      .booleanOR(ldrSettingWrapper.get('Country=Iceland'))
      .booleanOR(ldrSettingWrapper.get('Country=Norway'))
      .booleanOR(ldrSettingWrapper.get('Country=Sweden'))
      .getResult();
    seventhCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Employee min > 50')
      )
      .getResult();
    eighthCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Not(Country=United States)')
      )
      .booleanAND(ldrSettingWrapper.get('Not(Country=France)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Germany)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=United Kingdom)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Switzerland)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Belgium)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Canada)'))
      .booleanAND(ldrSettingWrapper.get('Not(Country=Austria)'))
      .getResult();
    ninthCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Employee min > 1000')
      )
      .getResult();
    tenthCriteria = new BooleanComparison(
        ldrSettingWrapper.get('Business_unit__c = Strategic')
      )
      .getResult();

    ldrConditionsMap.put('firstCriteria', firstCriteria);
    ldrConditionsMap.put('secondCriteria', secondCriteria);
    ldrConditionsMap.put('thirdCriteria', thirdCriteria);
    ldrConditionsMap.put('fourthCriteria', fourthCriteria);
    ldrConditionsMap.put('fifthCriteria', fifthCriteria);
    ldrConditionsMap.put('sixthCriteria', sixthCriteria);
    ldrConditionsMap.put('seventhCriteria', seventhCriteria);
    ldrConditionsMap.put('eighthCriteria', eighthCriteria);
    ldrConditionsMap.put('ninthCriteria', ninthCriteria);
    ldrConditionsMap.put('tenthCriteria', tenthCriteria);
    return ldrConditionsMap;
  }

  // private Map<String,Boolean> generateLdrCriteriaMapNew(Lead lead_i){
  //     LDRsettingMapWrapper ldrSettingWrapper = new LDRsettingMapWrapper(lead_i);

  //     Map<String,Boolean> ldrConditionsMap = new Map<String,Boolean>();
  //     Boolean firstCriteria;
  //     Boolean secondCriteria;
  //     Boolean thirdCriteria;
  //     Boolean fourthCriteria;

  //     firstCriteria = new BooleanComparison(ldrSettingWrapper.get('Is null (FirstName)'))
  //         								.booleanOR(ldrSettingWrapper.get('Is null (Company)'))
  //                                         .booleanOR(ldrSettingWrapper.get('Is null (Website)'))
  //                                         .booleanOR(ldrSettingWrapper.get('Is null (Employee Min)'))
  //                                         .booleanOR(ldrSettingWrapper.get('Is null (Employee Max)'))
  //                                         .booleanOR(ldrSettingWrapper.get('Is null (SW Industry)'))
  //                                         .booleanOR(ldrSettingWrapper.get('Is null (Country)'))
  //                                         .booleanOR(ldrSettingWrapper.get('Is null (Email)'))
  //         								.getResult();
  //     secondCriteria = new BooleanComparison(ldrSettingWrapper.get('Email domain type = Private'))
  //                                         .getResult();
  //     thirdCriteria = new BooleanComparison(ldrSettingWrapper.get('Business_unit__c = Strategic'))
  //         								.getResult();
  //     fourthCriteria = new BooleanComparison(ldrSettingWrapper.get('LeadSource != NULL'))
  //         								.booleanAND(ldrSettingWrapper.get('LeadSource not contains Outbound'))
  //                                         .booleanAND(ldrSettingWrapper.get('LeadSource!= Deal Registration'))
  //         								.getResult();

  //     ldrConditionsMap.put('firstCriteria',firstCriteria);
  //     ldrConditionsMap.put('secondCriteria',secondCriteria);
  //     ldrConditionsMap.put('thirdCriteria',thirdCriteria);
  //     ldrConditionsMap.put('fourthCriteria',fourthCriteria);

  //     return ldrConditionsMap;
  // }

  private class BooleanComparison {
    private Boolean result;

    public BooleanComparison(Boolean result) {
      this.result = result;
    }

    public Boolean getResult() {
      return result;
    }

    public BooleanComparison booleanAND(Boolean compared) {
      if (result == null && compared == null) {
        return this;
      } else if (result == null) {
        result = compared;
      } else if (compared != null) {
        result = result && compared;
      }
      return this;
    }

    public BooleanComparison booleanOR(Boolean compared) {
      if (result == null && compared == null) {
        return this;
      } else if (result == null) {
        result = compared;
      } else if (compared != null) {
        result = result || compared;
      }
      return this;
    }
  }

  private class LDRsettingMapWrapper {
    Map<String, LDR_Criteria_Settings__c> ldrCriteriaSettingMap;
    Lead lead_i;

    public LDRsettingMapWrapper(Lead lead_i) {
      ldrCriteriaSettingMap = LDR_Criteria_Settings__c.getAll();
      this.lead_i = lead_i;
    }

    public Boolean get(String key) {
      if (
        ldrCriteriaSettingMap.containsKey(key) &&
        ldrCriteriaSettingMap.get(key).Enabled__c
      ) {
        switch on key {
          when 'Is null (FirstName)' {
            return String.isBlank(lead_i.FirstName);
          }
          when 'Is null (Company)' {
            return String.isBlank(lead_i.Company);
          }
          when 'Is null (Website)' {
            return String.isBlank(lead_i.Website);
          }
          when 'Is null (Employee Min)' {
            return (lead_i.Employees_Min__c == null) ||
              lead_i.Employees_Max__c == 0;
          }
          when 'Is null (SW Industry)' {
            return String.isBlank(lead_i.SW_Industry__c);
          }
          when 'Is null (Country)' {
            return String.isBlank(lead_i.Country);
          }
          when 'Is null (Email)' {
            return String.isBlank(lead_i.Email);
          }
          when 'Is null (Employee Max)' {
            return (lead_i.Employees_Max__c == null) ||
              lead_i.Employees_Max__c == 0;
          }
          when 'Business_unit__c = Strategic' {
            return (lead_i.Business_unit__c == 'Strategic');
          }
          when 'Company_LDR_Compare__c=False' {
            return !lead_i.Company_LDR_Compare__c;
          }
          when 'Email domain type = Private' {
            return lead_i.Email_address_domain_type__c == 'Private';
          }
          when 'LeadSource != NULL' {
            return lead_i.LeadSource != null;
          }
          when 'LeadSource not contains Outbound' {
            return lead_i.LeadSource != null &&
              !lead_i.LeadSource.contains('Outbound');
          }
          when 'LeadSource!= Deal Registration' {
            return lead_i.LeadSource != 'Deal Registration';
          }
          when 'Not(Country=Japan)' {
            return lead_i.Country != 'Japan';
          }
          when 'Not(Country=Vietnam)' {
            return lead_i.Country != 'Vietnam';
          }
          when 'Not(Country=Viet Nam)' {
            return lead_i.Country != 'Viet Nam';
          }
          when 'Not(Country=China)' {
            return lead_i.Country != 'China';
          }
          when 'Not(Country=Taiwan)' {
            return lead_i.Country != 'Taiwan';
          }
          when 'Not(Country=Hong Kong)' {
            return lead_i.Country != 'Hong Kong';
          }
          when 'Country=United States' {
            return lead_i.Country == 'United States';
          }
          when 'Country=France' {
            return lead_i.Country == 'France';
          }
          when 'Country=Germany' {
            return lead_i.Country == 'Germany';
          }
          when 'Country=United Kingdom' {
            return lead_i.Country == 'United Kingdom';
          }
          when 'Country=Switzerland' {
            return lead_i.Country == 'Switzerland';
          }
          when 'Country=Belgium' {
            return lead_i.Country == 'Belgium';
          }
          when 'Country=Canada' {
            return lead_i.Country == 'Canada';
          }
          when 'Country=Austria' {
            return lead_i.Country == 'Austria';
          }
          when 'Country=Netherlands' {
            return lead_i.Country == 'Netherlands';
          }
          when 'Country=Luxembourg' {
            return lead_i.Country == 'Luxembourg';
          }
          when 'Country=Norway' {
            return lead_i.Country == 'Norway';
          }
          when 'Country=Sweden' {
            return lead_i.Country == 'Sweden';
          }
          when 'Country=Denmark' {
            return lead_i.Country == 'Denmark';
          }
          when 'Country=Finland' {
            return lead_i.Country == 'Finland';
          }
          when 'Country=Iceland' {
            return lead_i.Country == 'Iceland';
          }
          when 'Employee min > 50' {
            return lead_i.Employees_Min__c != null &&
              lead_i.Employees_Min__c > 50;
          }
          when 'Not(Country=United States)' {
            return lead_i.Country != 'United States';
          }
          when 'Not(Country=France)' {
            return lead_i.Country != 'France';
          }
          when 'Not(Country=Germany)' {
            return lead_i.Country != 'Germany';
          }
          when 'Not(Country=United Kingdom)' {
            return lead_i.Country != 'United Kingdom';
          }
          when 'Not(Country=Switzerland)' {
            return lead_i.Country != 'Switzerland';
          }
          when 'Not(Country=Belgium)' {
            return lead_i.Country != 'Belgium';
          }
          when 'Not(Country=Canada)' {
            return lead_i.Country != 'Canada';
          }
          when 'Not(Country=Austria)' {
            return lead_i.Country != 'Austria';
          }
          when 'Employee min > 1000' {
            return lead_i.Employees_Min__c != null &&
              lead_i.Employees_Min__c > 1000;
          }
        }
      }
      return null;
    }
  }
}

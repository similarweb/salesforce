/**
* @author Gad Sharon asdasddddd
* @date 26/11/2020
* @description Helper class for the business unit update process. 
*               This process runs on both leads and accounts.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd 
* date        - 18/01/2021
* description - In determineFieldValues(..), change the strategic region calculation to 
*               be using general-configuration custom meta data.
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd 
* date        - 25/05/2021
* description - Make sure the LDR check is performed only if the Owners are admins.
                Added set<id> to the determineFieldValues paramters list.
*               Based on MIS-690.
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd 
* date        - 16/06/2021
* description - Calculate business_unit even if the website--domain field is empty.
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd 
* date        - 15/12/2021
* description - Calculate business unit enterprise or inside sales according to different 
*               Employees_Min__c values defined in custom metadata
* --------------------------------------------------------------------------------------* --------------------------------------------------------------------------------------
* author      - Zohar Sinay
* date        - 28/08/2022
* description - Prevent private leads from becoming strategic, as they're most likely not strategic
*
* --------------------------------------------------------------------------------------*/

public without sharing class BusinessUnitUpdateHelper {
  /**
   * @author Gad Sharon
   * @date 26/11/2020
   * @description Update the business unit field according to the info in the record.
   * @param List <SObject> lst_records- The list of records we should determine their business unit.
   * @param String domainField - The field the logic should take into concideration in setting the business unit.
   * @param String countryField - The Country field the logic should take into concideration in setting the business unit.
   * @param String ldrOwnerSetting - In case we need to set an LDR owner, this object will contain relevant data, null otherwise.
   * @param Boolean accountRecords - In case this logic runs on accounts true, false otherwise.
   * @return Void.
   */

  public void updateBusinessUnit(
    List<SObject> lst_records,
    String domainField,
    String countryField,
    String ldrOwnerSetting,
    Boolean accountRecords
  ) {
    List<SObject> lst_recordsToUpdate = new List<SObject>();
    String recordType;
    Set<String> set_validOwnerId = new Set<String>();
    if (ldrOwnerSetting != null) {
      for (
        BU_LDR_valid_owner__c buOwnerSetting_i : BU_LDR_valid_owner__c.getAll()
          .values()
      ) {
        set_validOwnerId.add(buOwnerSetting_i.OwnerId__c);
      }
    }
    Map<String, List<SObject>> map_domainToRecords = mapRecordsToDomains(
      lst_records,
      domainField
    );
    Map<String, EmailDomain__c> map_domainToEmailDomains = mapEmailDomainsToDomains(
      map_domainToRecords.keySet()
    );
    Map<String, String> domainToStrategicRegion = GeneralUtil.getKeyValuePairsMap(
      'Email Domain to Strategic Region'
    );

    for (String domain : map_domainToRecords.keySet()) {
      for (SObject record : map_domainToRecords.get(domain)) {
        EmailDomain__c emailDomain = map_domainToEmailDomains.containsKey(
            domain
          )
          ? map_domainToEmailDomains.get(domain)
          : null;
        recordType = emailDomain != null
          ? emailDomain.RecordType.DeveloperName
          : null;
        Boolean allowedToUpdateStrategicPod =
          record.getSObjectType() != Lead.sObjectType ||
          record.get('Email_address_domain_type__c') == 'Company' ||
          (record.get('Email_address_domain_type__c') ==
          'Company - Secondary' &&
          String.isNotBlank(
            String.valueOf(record.get('LinkedIn_Profile__c'))
          ) &&
          !String.valueOf(record.get('LinkedIn_Profile__c'))
            .contains('didnnotfind.com'));

        if (
          accountRecords &&
          recordType != null &&
          recordType.toLowerCase() != 'free'
        ) {
          Object strategicPod;

          if (record.getSObjectType() == Lead.sObjectType) {
            strategicPod = allowedToUpdateStrategicPod &&
              emailDomain.Strategic_Pod__c != null
              ? emailDomain.Strategic_Pod__c
              : record.get('Strategic_Pod__c');
          } else {
            strategicPod = emailDomain.Strategic_Pod__c != null
              ? emailDomain.Strategic_Pod__c
              : record.get('Strategic_Pod__c');
          }

          record.put('Strategic_Pod__c', strategicPod);
          record.put(
            'Strategic_Region__c',
            strategicPod != null
              ? domainToStrategicRegion.get(recordType)
              : null
          );
          record.put(
            'Parent_Company_Domain__c',
            emailDomain.Parent_Company_Domain__c != null
              ? emailDomain.Parent_Company_Domain__c
              : record.get('Parent_Company_Domain__c')
          ); // MIS-2871 alon shalev added in  22.5.23
        }
        if (accountRecords && recordType == null && !Test.isRunningTest()) {
          // recordtype == null means there is no email domain realted to this website
          // record.put('Parent_Company_Domain__c',null);
        }

        if (!accountRecords) {
          record.put(
            'Strategic_Pod__c',
            allowedToUpdateStrategicPod && emailDomain != null
              ? emailDomain.Strategic_Pod__c
              : null
          ); // MIS-4670
          record.put(
            'Strategic_Region__c',
            record.get('Strategic_Pod__c') != null
              ? domainToStrategicRegion.get(recordType)
              : null
          );
        }

        determineFieldValues(record, recordType, countryField, emailDomain);

        lst_recordsToUpdate.add(record);
      }
    }

    //Update the records only if they are not part of a before trigger run.
    if (!accountRecords) {
      List<Lead> recordsToUpdateAfterRemoval = new List<Lead>();
      for (SObject recordToUpdate : lst_recordsToUpdate) {
        recordsToUpdateAfterRemoval.add(
          removeCountryFromUpdate(recordToUpdate)
        );
        //                String countryFromLeadCapture = (String)recordToUpdate.get('CountryCodeFromLeadCapture__c');
        //                String currentCountryCode  = (String)recordToUpdate.get('CountryCode');
        //                if(String.isNotBlank(countryFromLeadCapture) && currentCountryCode != countryFromLeadCapture){
        //                    recordToUpdate.put('CountryCode',recordToUpdate.get('CountryCodeFromLeadCapture__c'));
        //                }
      }
      //            Map<Id,Lead> currentLeadsState = new Map<Id,Lead>([SELECT CountryCode FROM Lead WHERE Id IN : lst_recordsToUpdate]);
      //            for(SObject record : lst_recordsToUpdate){
      //                record.put('CountryCode',currentLeadsState.get(record.Id).CountryCode);
      //            }

      System.debug(
        'Records to Update: ' +
        JSON.serializePretty(recordsToUpdateAfterRemoval)
      );
      update recordsToUpdateAfterRemoval;
    }
  }

  private Lead removeCountryFromUpdate(SObject recordToUpdate) {
    String leadString = Json.serialize(recordToUpdate);
    Map<String, Object> leadMap = (Map<String, Object>) Json.deserializeUntyped(
      leadString
    );
    leadMap.remove('CountryCode');
    leadMap.remove('Country');
    String afterRemoval = JSON.serialize(leadMap);

    return (Lead) JSON.deserialize(afterRemoval, Lead.class);
  }

  /**
   * @author Itzik Winograd
   * @date 25/05/2021
   * @description Get the Ids of all the admin-owners to determine if LDR check is needed.
   * @param List<SObject> lst_records - sobject list.
   * @return Set<Id> userIds
   */
  //    private Set<Id> getSystemAdminOwners(List<SObject> lst_records){
  //        Set<Id> ownersIds = new Set<Id>();
  //        for (SObject sobj:lst_records){
  //            ownersIds.add((Id)sobj.get('OwnerId'));
  //        }
  //        List<SObject> results = Database.query(
  //                'SELECT Id, Profile.Name '+
  //                        'FROM User '+
  //                        'WHERE Id IN:ownersIds ' +
  //                        'AND (Profile.Name = \'System Administrator\' '+
  //                        'OR Profile.Name = \'Integration User No DF\' )'); //Changed on 27/06 to support the 'System Admin' user
  //        Set<Id> systemAdminSet = (new Map<Id,SObject>(results)).keySet();
  //        return systemAdminSet;
  //    }

  /**
   * @author Gad Sharon
   * @date 26/11/2020
   * @description Create a map of domains to the records that have this domain.
   * @param List<SObject> - The list of records we work on and need to create the map for.
   * @param String - The field in the object that contains the domain we should work on.
   * @return Map<String, List<SObject>> - Map of domains to the records that have this domain.
   */

  public Map<String, List<SObject>> mapRecordsToDomains(
    List<SObject> lst_records,
    String domainField
  ) {
    Map<String, List<SObject>> map_domainToRecords = new Map<String, List<SObject>>();
    String domain;

    for (SObject sobj : lst_records) {
      domain = (String) sobj.get(domainField);
      domain = String.isNotBlank(domain) ? domain.toLowerCase() : domain;
      if (!map_domainToRecords.containsKey(domain))
        map_domainToRecords.put(domain, new List<SObject>());
      map_domainToRecords.get(domain).add(sobj);
    }
    return map_domainToRecords;
  }

  /**
   * @author Gad Sharon
   * @date 26/11/2020
   * @description Create a map of domains to their email domains records.
   * @param Set<String> - The domain names we need to find their email domains records.
   * @return Map<String, EmailDomain__c> - A map of domains to their email domains records.
   */

  public Map<String, EmailDomain__c> mapEmailDomainsToDomains(
    Set<String> set_domainNames
  ) {
    Map<String, EmailDomain__c> map_domainToEmailDomains = new Map<String, EmailDomain__c>();
    List<EmailDomain__c> emailDomains = [
      SELECT
        id,
        Name,
        RecordType.DeveloperName,
        Parent_Company_Domain__c,
        Strategic_Pod__c,
        Exclude_NAL_tagging_from_Private_email__c
      FROM EmailDomain__c
      WHERE Name IN :set_domainNames
    ];

    //Create Map for Name of EmailDomain__c to the record
    for (EmailDomain__c emailDom : emailDomains) {
      map_domainToEmailDomains.put(emailDom.Name.toLowerCase(), emailDom);
    }

    return map_domainToEmailDomains;
  }

  /**
   * @author Gad Sharon
   * @date 26/11/2020
   * @description Determine the values we need to set in the fields.
   * @param SObject record- The record we need to set its fields.
   * @param String recordType - The record type of the domain.
   * @param String ldrOwnerSetting- In case we need to set an LDR owner, this object will contain relevant data, null otherwise.
   * @param set set_validOwnerId - Set of valid owner ids.
   * @param Boolean accountRecords- In case this logic runs on accounts true, false otherwise.
   * @param Set<Id> systemAdminSet- set of owners user ids that are admins
   * @param String countryField - The Country field the logic should take into concideration in setting the business unit.
   * @return SObject - The record we set its fields with the updated fields.
   * =================================================================================================
   * @autor Itzik Winograd
   * @date 15/12/2021
   * @description: Sepereate the business unit calcualtion for us and non-us countries, with different emp min values;
   *               Add countryField to the parms list.
   */

  private SObject determineFieldValues(
    SObject record,
    String recordType,
    String countryField,
    EmailDomain__c emailDomain
  ) {
    String businessUnit;
    String strategicRegion;
    //2021-01-17: use custom meta data to determine the Strategic Region value.
    if (recordType != null && recordType.toLowerCase() != 'free') {
      if (recordType.toLowerCase() == 'enterprise') {
        businessUnit = 'Enterprise';
        if (
          GeneralUtil.hasSObjectField(record, 'Email_address_domain_type__c')
        ) {
          if (
            String.valueOf(record.get('Email_address_domain_type__c'))
              .equalsIgnoreCase('Private') ||
            (record.getSObjectType() == Lead.getSObjectType() &&
            record.get('Email_address_domain_type__c') ==
            'Company - Secondary' &&
            (String.isBlank(
              String.valueOf(record.get('LinkedIn_Profile__c'))
            ) ||
            String.valueOf(record.get('LinkedIn_Profile__c'))
              .contains('didnnotfind.com')))
          ) {
            if (emailDomain.Exclude_NAL_tagging_from_Private_email__c) {
              record.put('Strategic_Pod__c', null);
              record.put('Strategic_Region__c', null);
            }
          }
        }
      } else {
        businessUnit = 'Strategic';
        for (
          General_Key_Value_pair__mdt cmdt : GeneralUtil.getKeyValuePairs(
            'Email Domain to Strategic Region'
          )
        ) {
          if (recordType == cmdt.Key__c) {
            strategicRegion = cmdt.Value__c;
          }
        }
      }
    } else {
      strategicRegion = null;
      //Get the min employees number from "General Configuration" Custom meta data type
      //2021-12-15: Check for Enterprise countries in the custom metadata to determine the right minimum employees value
      businessUnit = BusinessUnitCalculationByEmployeeMin(
        record,
        countryField,
        businessUnit
      );
    }

    return setFields(businessUnit, strategicRegion, record, countryField);
  }

  /**
   * ===== changes ====
   * @author Itzik Winograd
   * @date 20/12/22
   * @description MIS-3198: add the Industry_Cluster__c to the calculations
   * */
  private String BusinessUnitCalculationByEmployeeMin(
    SObject record,
    String countryField,
    String businessUnit
  ) {
    List<String> countriesList = GeneralUtil.getGeneralConfig(
        'US_Canada_Countries'
      )
      .Text_Value__c.split(';');
    Integer minEmployees;
    if (countriesList.contains((String) record.get(countryField))) {
      //country is US/CA
      minEmployees = Integer.valueOf(
        GeneralUtil.getGeneralConfig('Business_Unit_Employees_Min_US_CA')
          .Number_Value__c
      );
    } else {
      minEmployees = Integer.valueOf(
        GeneralUtil.getGeneralConfig('Business_Unit_Employees_Min_ROW')
          .Number_Value__c
      );
    }
    //MIS-3198:Industry_Cluster__c
    if (
      GeneralUtil.getObjectNameFromSObject(record) == 'account' &&
      (String) record.get('Industry_Cluster__c') == 'Investors'
    ) {
      if (record.get('SW_Industry__c') != 'Hedge Funds and Asset Management') {
        businessUnit = (Decimal) record.get('Employees_Min__c') <= 50
          ? 'Inside Sales'
          : 'Enterprise';
      } else /** meaning: if(record.get('SW_Industry__c') == 'Hedge Funds and Asset Management') */ {
        if (
          new Set<String>{ '$250M - $500M', 'Under $250M', null }
            .contains((String) record.get('AUM__c'))
        ) {
          businessUnit = 'Inside Sales';
        } else {
          businessUnit = 'Enterprise';
        }
      } //end of MIS-3198 changes
    } else if (
      record.get('Employees_Min__c') != null &&
      (Decimal) record.get('Employees_Min__c') > minEmployees
    ) {
      businessUnit = 'Enterprise';
    } else {
      businessUnit = 'Inside Sales';
    }
    return businessUnit;
  }

  /**
   * Set the business unit and strategic region.
   *
   * @param businessUnit
   * @param strategicRegion
   * @param record
   * @return SObject - The record we set its fields with the updated fields.
   * @author Gad Sharon
   * @date 26/11/2020
   * ====================== cahnges ===================
   * @author Itzik Winograd
   * @date 07/11/2022
   * @description MIS-3124: uncheck the Recalculate_Business_Unit__c field
   */

  private SObject setFields(
    String businessUnit,
    String strategicRegion,
    SObject record,
    String countryField
  ) {
    record.put('Business_Unit__c', businessUnit);
    record.put(
      'Strategic_Region__c',
      record.get('Strategic_Pod__c') != null ? strategicRegion : null
    );

    if (businessUnit == 'Inside Sales') {
      record.put('Strategic_Pod__c', null);
      record.put('Strategic_Region__c', null);
    }
    if (GeneralUtil.hasSObjectField(record, 'Email_address_domain_type__c')) {
      if (
        (String.valueOf(record.get('Email_address_domain_type__c'))
          .equalsIgnoreCase('Private') ||
        (record.getSObjectType() == Lead.getSObjectType() &&
        record.get('Email_address_domain_type__c') == 'Company - Secondary' &&
        (String.isBlank(String.valueOf(record.get('LinkedIn_Profile__c'))) ||
        String.valueOf(record.get('LinkedIn_Profile__c'))
          .contains('didnnotfind.com')))) && businessUnit == 'Strategic'
      ) {
        record.put('Website', 'no_website');
        record.put('Employees_Min__c', 11);
        record.put('Employees_Max__c', 50);
        businessUnit = BusinessUnitCalculationByEmployeeMin(
          record,
          countryField,
          businessUnit
        );
        record.put('Business_Unit__c', businessUnit);
        record.put('Strategic_Region__c', null);
      }
    }
    if (
      GeneralUtil.getObjectNameFromSObject(record) == 'lead' &&
      record.get('Recalculate_Business_Unit__c') == true
    ) {
      record.put('Recalculate_Business_Unit__c', false);
    }
    return record;
  }

  //    private SObject ldrCheck(Sobject sobj, String ldrOwnerSetting, Set<String> set_validOwnerId)
  //    {
  //        if((GeneralUtil.hasSObjectField(sobj, 'Email_address_domain_type__c') &&
  //                String.valueOf(sobj.get('Email_address_domain_type__c')) != null && !String.valueOf(sobj.get('Email_address_domain_type__c'))?.equalsIgnoreCase('Private')&&
  //                GeneralUtil.hasSObjectField(sobj, 'Business_Unit__c') &&
  //                String.valueOf(sobj.get('Business_Unit__c')) != null && String.valueOf(sobj.get('Business_Unit__c'))?.equalsIgnoreCase('Strategic')) &&
  //                ((sobj.get('Polygraph_Company_Name__c') == null || sobj.get('Polygraph_Company_Name__c') != 'Company') &&
  //                        set_validOwnerId.contains((String)sobj.get('CreatedById')))){
  //            sobj.put('Orchestration_Journey__c', 'LDR');
  //            sobj.put('LDR_Journey_Reason__c', 'LDR in BU Calculation');
  //            sobj.put('OwnerId', ldrOwnerSetting);
  //        }
  //        return sobj;
  //    }
}

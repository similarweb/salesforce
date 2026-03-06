/**
 * Created by Alon.Shalev on 11/28/2023.
 */

public with sharing class CreateCampaignFromEmailResultBatch implements Database.Batchable<sObject>, Schedulable {
  private Map<String, String> campaignFieldToValueMap = new Map<String, String>();

  public CreateCampaignFromEmailResultBatch() {
    List<General_Key_Value_pair__mdt> keyValuePairsSettings = [
      SELECT Key__c, Value__c
      FROM General_Key_Value_pair__mdt
      WHERE ProcessName__c = 'CreateCampaignFromEmailResultBatch'
    ];
    for (General_Key_Value_pair__mdt setting : keyValuePairsSettings) {
      this.campaignFieldToValueMap.put(setting.Key__c, setting.Value__c);
    }
  }

  public void execute(SchedulableContext SC) {
    CreateCampaignFromEmailResultBatch batch = new CreateCampaignFromEmailResultBatch();
    Integer runningBatchSize = 100;
    Database.executeBatch(batch, runningBatchSize);
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query =
      'SELECT Id,Name,et4ae5__DateSent__c,et4ae5__Lead__c,et4ae5__Contact__c ' +
      'FROM et4ae5__IndividualEmailResult__c ' +
      'WHERE (et4ae5__Opened__c = true OR et4ae5__Clicked__c = true) ' +
      'AND LastModifiedDate >= YESTERDAY';
    return Database.getQueryLocator(query);
  }

  public void execute(
    Database.BatchableContext BC,
    List<et4ae5__IndividualEmailResult__c> scope
  ) {
    // data collections
    Map<String, et4ae5__IndividualEmailResult__c> emailResultsNameMap = new Map<String, et4ae5__IndividualEmailResult__c>();
    List<Campaign> campaignToInsertList = new List<Campaign>();
    List<CampaignMember> campaignMemberToInsertList = new List<CampaignMember>();
    Set<String> leadIdFromEmailResultSet = new Set<String>();
    Set<String> contactIdFromEmailResultSet = new Set<String>();
    for (et4ae5__IndividualEmailResult__c emailResult : scope) {
      if (emailResult.Name.contains(' --')) {
        String prefixName = emailResult.Name.substringBefore(' --');
        emailResultsNameMap.put(prefixName, emailResult);
        if (emailResult.et4ae5__Lead__c != null) {
          leadIdFromEmailResultSet.add(emailResult.et4ae5__Lead__c);
        }
        if (emailResult.et4ae5__Contact__c != null) {
          contactIdFromEmailResultSet.add(emailResult.et4ae5__Contact__c);
        }
      }
    }

    // part 1 campaign creation

    List<Campaign> existingCampaignList = [
      SELECT Id, Name
      FROM Campaign
      WHERE Name IN :emailResultsNameMap.keySet()
    ];

    Set<String> existingCampaignNameSet = new Set<String>();
    for (Campaign existing : existingCampaignList) {
      existingCampaignNameSet.add(existing.Name);
    }

    for (String prefixName : emailResultsNameMap.keySet()) {
      if (!existingCampaignNameSet.contains(prefixName)) {
        campaignToInsertList.add(
          createCampaign(prefixName, emailResultsNameMap.get(prefixName))
        );
      }
    }
    if (!campaignToInsertList.isEmpty()) {
      insert campaignToInsertList;
    }

    //part 2 campaign Member creation
    List<Campaign> afterInsertCampaignList = [
      SELECT Id, Name
      FROM Campaign
      WHERE Name IN :emailResultsNameMap.keySet()
    ];

    Map<String, Campaign> nameToCampaignMap = new Map<String, Campaign>();

    for (Campaign campaign : afterInsertCampaignList) {
      nameToCampaignMap.put(campaign.Name, campaign);
    }
    Set<String> keySetOfExistingCampaignMemberSet = getKeySetOfExistingCampaignMemberSet(
      leadIdFromEmailResultSet,
      contactIdFromEmailResultSet,
      afterInsertCampaignList
    );
    for (et4ae5__IndividualEmailResult__c emailResult : scope) {
      if (emailResult.Name.contains(' --')) {
        String prefixName = emailResult.Name.substringBefore(' --');
        if (
          needToCreateCampaignMember(
            emailResult,
            nameToCampaignMap.get(prefixName),
            keySetOfExistingCampaignMemberSet
          )
        ) {
          String newlyCreatedKey = nameToCampaignMap.get(prefixName).Id + ':';
          newlyCreatedKey += emailResult.et4ae5__Contact__c != null
            ? emailResult.et4ae5__Contact__c
            : emailResult.et4ae5__Lead__c;
          keySetOfExistingCampaignMemberSet.add(newlyCreatedKey);
          campaignMemberToInsertList.add(
            createCampaignMember(emailResult, nameToCampaignMap.get(prefixName))
          );
        }
      }
    }
    if (!campaignMemberToInsertList.isEmpty()) {
      Database.SaveResult[] saveResults = Database.insert(
        campaignMemberToInsertList,
        false
      );

      for (Database.SaveResult result : saveResults) {
        if (!result.isSuccess()) {
          for (Database.Error err : result.getErrors()) {
            // Check if the error is due to a duplicate value
            if (
              !(err.getStatusCode() == StatusCode.DUPLICATE_VALUE &&
              err.getMessage().contains('Already a campaign'))
            ) {
              // Handle other errors - by throwing an exception
              throw new CreateCampaignException(
                'Insert failed due to a non-duplicate error'
              );
            }
          }
        }
      }
    }
  }

  private Set<String> getKeySetOfExistingCampaignMemberSet(
    Set<String> leadIdFromEmailResultSet,
    Set<String> contactIdFromEmailResultSet,
    List<Campaign> afterInsertCampaignList
  ) {
    List<CampaignMember> existingCampaignMembersList = [
      SELECT Id, ContactId, LeadId, CampaignId
      FROM CampaignMember
      WHERE
        (LeadId IN :leadIdFromEmailResultSet
        OR ContactId IN :contactIdFromEmailResultSet)
        AND CampaignId IN :afterInsertCampaignList
    ];

    Set<String> keySetOfExistingCampaignMemberSet = new Set<String>();
    for (CampaignMember existingCampaignMember : existingCampaignMembersList) {
      keySetOfExistingCampaignMemberSet.add(
        createKeySetFromCampaignMember(existingCampaignMember)
      );
    }
    return keySetOfExistingCampaignMemberSet;
  }
  private boolean needToCreateCampaignMember(
    et4ae5__IndividualEmailResult__c emailResult,
    Campaign campaign,
    Set<String> keySetOfExistingCampaignMemberSet
  ) {
    String newlyCreatedKey = campaign.Id + ':';
    newlyCreatedKey += emailResult.et4ae5__Contact__c != null
      ? emailResult.et4ae5__Contact__c
      : emailResult.et4ae5__Lead__c;
    return !keySetOfExistingCampaignMemberSet.contains(newlyCreatedKey);
  }

  private String createKeySetFromCampaignMember(
    CampaignMember existingCampaignMember
  ) {
    // the key will be Campaign +":"+ contactId OR leadId
    String key = existingCampaignMember.CampaignId;
    if (existingCampaignMember.ContactId != null) {
      key += ':' + existingCampaignMember.ContactId;
    }
    if (existingCampaignMember.LeadId != null) {
      key += ':' + existingCampaignMember.LeadId;
    }
    return key;
  }

  private CampaignMember createCampaignMember(
    et4ae5__IndividualEmailResult__c emailResult,
    Campaign campaign
  ) {
    System.debug('campaign--' + campaign);
    CampaignMember newCampaignMember = new CampaignMember();
    newCampaignMember.CampaignId = campaign.Id;
    newCampaignMember.LeadId = emailResult.et4ae5__Lead__c;
    newCampaignMember.ContactId = emailResult.et4ae5__Contact__c;
    newCampaignMember.Status = 'Opened';
    return newCampaignMember;
  }

  private Campaign createCampaign(
    String prefixName,
    et4ae5__IndividualEmailResult__c emailResult
  ) {
    Campaign campaign = new Campaign();
    campaign.Name = prefixName;
    campaign.SFMC_Journey_Name__c = prefixName;
    campaign.Region__c = this.campaignFieldToValueMap.containsKey('Region__c')
      ? this.campaignFieldToValueMap.get('Region__c')
      : null;
    campaign.BudgetedCost = this.campaignFieldToValueMap.containsKey(
        'BudgetedCost'
      )
      ? Decimal.valueOf(this.campaignFieldToValueMap.get('BudgetedCost'))
      : null;
    campaign.Department__c = this.campaignFieldToValueMap.containsKey(
        'Department__c'
      )
      ? this.campaignFieldToValueMap.get('Department__c')
      : null;
    campaign.StartDate = Date.valueOf(emailResult.et4ae5__DateSent__c);
    campaign.EndDate = Date.valueOf(emailResult.et4ae5__DateSent__c);
    campaign.Type = 'Email';
    campaign.Channel__c = 'Email SFMC';
    campaign.Asset_Type2__c = populateAssetType(prefixName);
    campaign.IsActive = true;
    campaign.A_B_Test__c = checkPattern(emailResult.Name);
    return campaign;
  }

  private Boolean checkPattern(String inputText) {
    // Define the regex pattern
    String patternString = '- [A-Za-z] --';

    // Compile the pattern
    Pattern pattern = Pattern.compile(patternString);

    // Create a matcher for the input text
    Matcher matcher = pattern.matcher(inputText);
    return matcher.find();
  }

  private String populateAssetType(String prefixName) {
    String assetType;
    if (prefixName.startsWith('OE - NWL')) {
      assetType = 'Email - Newsletter';
    } else if (prefixName.startsWith('OE')) {
      assetType = 'Email - One-off';
    } else if (prefixName.startsWith('AE')) {
      assetType = 'Email - Automated Cadence';
    } else if (prefixName.startsWith('TE')) {
      assetType = 'Email - Triggered';
    }
    return assetType;
  }

  public void finish(Database.BatchableContext BC) {
  }

  public class CreateCampaignException extends Exception {
  }
}

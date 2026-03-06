/**
 * Created by Alon.Shalev on 3/27/2024.
 */

public with sharing class TerritoryHandler {
  public TerritoryHandler() {
  }

  public void nalTerritoryValidation(List<Territory__c> newList) {
    for (Territory__c terItem : newList) {
      if (String.isNotBlank(terItem.Strategic_Pod__c)) {
        if (!terItem.Strategic_Pod__c.startsWith('NAL')) {
          if (String.isNotBlank(terItem.Sub_Division__c)) {
            List<String> subDivisionList = terItem.Sub_Division__c.split(';');
            if (subDivisionList.size() > 1) {
              terItem.addError(
                'U cant  have more then 1 subdivision if the strategic pod doesnt starts with NAL'
              );
            }
          }
        }
      }
    }
  }
  public void nalTerritoryValidationOnUpdate(
    List<Territory__c> newList,
    Map<Id, Territory__c> oldMap
  ) {
    List<Territory__c> relevantTerritoriesList = new List<Territory__c>();
    for (Territory__c terItem : newList) {
      if (
        terItem.Sub_Division__c != oldMap.get(terItem.Id).Sub_Division__c ||
        terItem.Strategic_Pod__c != oldMap.get(terItem.Id).Strategic_Pod__c
      ) {
        relevantTerritoriesList.add(terItem);
      }
    }
    if (!relevantTerritoriesList.isEmpty()) {
      nalTerritoryValidation(relevantTerritoriesList);
    }
  }

  public void validationOfTerritoryMemberDuplication(
    List<Territory__c> newList,
    Map<Id, Territory__c> oldMap
  ) {
    List<Territory__c> relevantList = new List<Territory__c>();
    for (Territory__c territory : newList) {
      if (territory.OwnerId != oldMap.get(territory.Id).OwnerId) {
        relevantList.add(territory);
      }
    }
    if (!relevantList.isEmpty()) {
      List<Territory_Member__c> territoryMembers = [
        SELECT Id, Name__c
        FROM Territory_Member__c
        WHERE Territory__c IN :relevantList
      ];
      Set<Id> userIdFromMembers = new Set<Id>();
      for (Territory_Member__c territoryMember : territoryMembers) {
        userIdFromMembers.add(territoryMember.Name__c);
      }
      for (Territory__c territory : relevantList) {
        if (userIdFromMembers.contains(territory.OwnerId)) {
          territory.addError('The user is already assigned to this territory.');
        }
      }
    }
  }
}

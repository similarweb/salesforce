/**
 * Created by alon.shalev on 5/11/2025.
 */

public with sharing class TerritoryMemberHandler {
  public void duplicationValidation(List<Territory_Member__c> newList) {
    System.debug('duplicationValidation started');
    Set<Id> territoryIdSet = new Set<Id>();
    for (Territory_Member__c territoryMember : newList) {
      territoryIdSet.add(territoryMember.Territory__c);
    }
    Map<Id, Set<Id>> territoryToUserMap = new Map<Id, Set<Id>>();
    List<Territory__c> territoryWithExistingMembersList = [
      SELECT Id, Ownerid, (SELECT Name__c FROM Territory_Members__r)
      FROM Territory__c
      WHERE Id IN :territoryIdSet
    ];
    System.debug(
      'territoryWithExistingMembersList--' + territoryWithExistingMembersList
    );
    if (!territoryWithExistingMembersList.isEmpty()) {
      for (Territory__c territory : territoryWithExistingMembersList) {
        if (!territoryToUserMap.containsKey(territory.Id)) {
          territoryToUserMap.put(territory.Id, new Set<Id>());
        }
        territoryToUserMap.get(territory.Id).add(territory.OwnerId);
        for (
          Territory_Member__c territoryMember : territory.Territory_Members__r
        ) {
          territoryToUserMap.get(territory.Id).add(territoryMember.Name__c);
        }
      }
    }

    for (Territory_Member__c territoryMember : newList) {
      Set<Id> userOfThisTerritorySet = territoryToUserMap.get(
        territoryMember.Territory__c
      );
      if (userOfThisTerritorySet != null) {
        if (userOfThisTerritorySet.contains(territoryMember.Name__c)) {
          territoryMember.addError(
            'The user is already assigned to this territory.'
          );
        }
      }
    }
  }

  public void handleBeforeDelete(List<Territory_Member__c> members) {
    List<String> memberIds = new List<String>();

    for (Territory_Member__c m : members) {
      memberIds.add(m.Id);
    }

    List<Territory_Member__c> territoryMembers = [
        SELECT Id, Name__c, Territory_Member_Role__c, Territory__r.OwnerId
        FROM Territory_Member__c
        WHERE Id IN :memberIds
      ],
      excludedFromTerritoryChangeMembers = new List<Territory_Member__c>();

    for (Territory_Member__c m : territoryMembers) {
      if (
        m.Territory_Member_Role__c == 'Sales Manager' &&
        m.Territory__r.OwnerId != m.Name__c
      ) {
        excludedFromTerritoryChangeMembers.add(m);
      }
    }

    excludeFromTerritoryChange(excludedFromTerritoryChangeMembers);
  }

  private void excludeFromTerritoryChange(List<Territory_Member__c> members) {
    List<String> territoryAndOwner = new List<String>();

    for (Territory_Member__c m : members) {
      territoryAndOwner.add(
        '(Territory__c = \'' +
          m.Territory__c +
          '\' AND OwnerId = \'' +
          m.Territory__r.OwnerId +
          '\')'
      );
    }

    if (territoryAndOwner.size() > 0) {
      String query =
        'SELECT Id, Exclude_From_Territory_Owner_Change__c ' +
        'FROM Account ' +
        'WHERE Exclude_From_Territory_Owner_Change__c = true AND (' +
        String.join(territoryAndOwner, ' OR ') +
        ')';

      Database.executeBatch(new TerritoryMemberAccountBatchable(query), 250);
    }
  }
}

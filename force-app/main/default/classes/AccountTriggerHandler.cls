/******************************************************************************* 
Name : AccountTriggerHandler
Description : Handler class for Account triggers
Created/Modified by Created/Modified Date Requested by Related Task/Issue 
---------------------------------------------------------------------------------------- 
1.Nevo Haarari           04/03/2018         ARIEL LOPEZ             [SW-28689] 
2.Nevo Haarari           11/04/2018         Omer/Doreen          	[SW-29066]
************************************************************************************/
public class AccountTriggerHandler {
  public void machParent(
    List<Account> accNewList,
    Map<Id, Account> accOldMap,
    Map<Id, Account> accNewMap
  ) {
    map<Id, String> accIdToDomain = new Map<Id, String>();
    List<Account> releventAccLst = new List<Account>();
    for (Account acc : accNewList) {
      System.debug('inside handler AccountTriggerHandler');
      //Insert
      System.debug('acc---' + acc.Domain__c);
      System.debug('acc---' + acc.AccountDomain__c);
      if (Trigger.isInsert) {
        if (
          acc.Sys_Hierarchy_Required__c == 'Yes' &&
          acc.Domain__c != null &&
          acc.Domain__c != ''
        ) {
          //&& acc.Email_address_domain_type_SFDC__c == 'Company'
          accIdToDomain.put(acc.id, acc.Domain__c.toLowerCase());
          releventAccLst.add(acc);
          acc.Sys_Hierarchy_Required__c = 'No';
          System.debug('acc.id==' + acc.id);
        }
      }

      //update
      if (Trigger.isUpdate) {
        if (
          acc.Sys_Hierarchy_Required__c == 'Yes' &&
          acc.Domain__c != null &&
          acc.Domain__c != ''
        ) {
          //&& acc.Email_address_domain_type_SFDC__c == 'Company'
          if (
            accOldMap != null &&
            accOldMap.get(acc.Id).Sys_Hierarchy_Required__c != 'Yes'
          ) {
            //call flow
            // call_machParent_Flow(acc.id);

            accIdToDomain.put(acc.id, acc.Domain__c.toLowerCase());
            releventAccLst.add(acc);
            System.debug('acc.id==' + acc.id);
            acc.Sys_Hierarchy_Required__c = 'No';
          }
        }
      }
    }
  }

  //MIS-4768

  public void updateMarketingPersona(
    Map<Id, Account> newMap,
    Map<Id, Account> oldMap
  ) {
    System.debug('alon start updateMarketingPersona--');
    Set<Id> changedAccountIdSet = new Set<Id>();
    for (Id accountId : newMap.keySet()) {
      if (
        newMap.get(accountId).SW_Industry__c !=
        oldMap.get(accountId).SW_Industry__c
      ) {
        changedAccountIdSet.add(accountId);
      }
    }
    System.debug('changedAccountIdSet---' + changedAccountIdSet);
    if (!changedAccountIdSet.isEmpty()) {
      system.enqueueJob(
        new UpdateMarketingPersonaQueueable(changedAccountIdSet)
      );
    }
  }

  public void updateStrategicPodOnContacts(
    Map<Id, Account> newMap,
    Map<Id, Account> oldMap
  ) {
    Set<Id> changedAccountIdSet = new Set<Id>();
    for (Id accountId : newMap.keySet()) {
      if (
        newMap.get(accountId).Strategic_Pod__c !=
        oldMap.get(accountId).Strategic_Pod__c
      ) {
        changedAccountIdSet.add(accountId);
      }
    }
    System.debug('changedAccountIdSet---' + changedAccountIdSet);
    if (!changedAccountIdSet.isEmpty()) {
      system.enqueueJob(
        new UpdatestrategicPodOnContactsQueueable(changedAccountIdSet)
      );
    }
  }

  public void handleClosedOppOwnerRevert(
    Map<Id, Account> newMap,
    Map<Id, Account> oldMap
  ) {
    System.debug('handleClosedOppOwnerRevert -- START');
    Set<String> allowedProfiles = new Set<String>{
      'System Administrator',
      'SW SalesOps',
      'SW SalesOps Extended'
    };
    String currentUserProfileName = [
      SELECT Name
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
    ]
    .Name;
    System.debug(
      'handleClosedOppOwnerRevert -- currentUserProfileName: ' +
      currentUserProfileName
    );

    if (allowedProfiles.contains(currentUserProfileName)) {
      System.debug(
        'handleClosedOppOwnerRevert -- User profile is allowed, exiting'
      );
      return;
    }

    // Collect accounts where owner has changed
    Set<Id> ownerChangedAccountIds = new Set<Id>();
    for (Id accountId : newMap.keySet()) {
      if (newMap.get(accountId).OwnerId != oldMap.get(accountId).OwnerId) {
        ownerChangedAccountIds.add(accountId);
        System.debug(
          'handleClosedOppOwnerRevert -- Account owner changed: ' +
            accountId +
            ' | Old Owner: ' +
            oldMap.get(accountId).OwnerId +
            ' | New Owner: ' +
            newMap.get(accountId).OwnerId
        );
      }
    }

    System.debug(
      'handleClosedOppOwnerRevert -- ownerChangedAccountIds: ' +
      ownerChangedAccountIds
    );

    if (ownerChangedAccountIds.isEmpty()) {
      System.debug(
        'handleClosedOppOwnerRevert -- No account owner changes detected, exiting'
      );
      return;
    }

    // Query closed opportunities under these accounts
    Set<Id> closedOppIds = new Set<Id>();
    for (Opportunity opp : [
      SELECT Id
      FROM Opportunity
      WHERE AccountId IN :ownerChangedAccountIds AND IsClosed = TRUE
    ]) {
      closedOppIds.add(opp.Id);
    }

    System.debug(
      'handleClosedOppOwnerRevert -- closedOppIds found: ' + closedOppIds
    );

    if (!closedOppIds.isEmpty()) {
      System.debug(
        'handleClosedOppOwnerRevert -- Enqueuing RevertClosedOppOwnerQueueable with ' +
          closedOppIds.size() +
          ' opportunities'
      );
      System.enqueueJob(new RevertClosedOppOwnerQueueable(closedOppIds));
    } else {
      System.debug(
        'handleClosedOppOwnerRevert -- No closed opportunities found, not enqueuing'
      );
    }
    System.debug('handleClosedOppOwnerRevert -- END');
  }
}

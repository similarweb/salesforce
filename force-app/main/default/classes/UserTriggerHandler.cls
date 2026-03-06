public class UserTriggerHandler {
  public static void manageCommunityUserSharing(
    List<User> newUsers,
    Map<Id, User> oldMap
  ) {
    Boolean isUpdate = Trigger.isUpdate;
    Set<String> profileIds = getCommunityUserProfileId();
    Map<String, List<String>> accountToUserMap = new Map<String, List<String>>();
    Map<String, List<Id>> oldUserAccountsMap = new Map<String, List<Id>>();
    //System.debug('profileId ' + profileId);

    for (User u : newUsers) {
      System.debug('user  ' + u);
      if (
        u.IsPortalEnabled &&
        profileIds.contains(((String) u.ProfileId).substring(0, 15)) &&
        !String.isEmpty(u.AccountId)
      ) {
        if (!accountToUserMap.containsKey(u.AccountId)) {
          accountToUserMap.put(u.AccountId, new List<String>());
        }
        accountToUserMap.get(u.AccountId).add(u.Id);
      }
    }
    System.debug('accountToUserMap ' + accountToUserMap);

    List<Id> toDelete = new List<Id>();
    /*if (!oldUserAccountsMap.isEmpty()) {
            Map<Id, Set<Id>> opportunityUsersMap = new Map<Id, Set<ID>>();
            Set<Id> opportunityIds = new Set<Id>();
            
            for (Opportunity opp : [SELECT Id, AccountID from Opportunity where AccountId in :oldUserAccountsMap.keySet()]) {
                if (oldUserAccountsMap.containsKey(opp.AccountId)){
                    if (!opportunityUsersMap.containsKey(opp.Id))
                        opportunityUsersMap.put(opp.Id, new Set<Id>());
                    opportunityUsersMap.get(opp.Id).addAll(oldUserAccountsMap.get(opp.AccountId));
                }
            }
            if (!opportunityUsersMap.isEmpty()) {
                for (OpportunityShare sh : [SELECT Id, OpportunityId, UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN :opportunityUsersMap.keySet()]) {
                    if (opportunityUsersMap.containsKey(sh.OpportunityId) && opportunityUsersMap.get(sh.OpportunityId).contains(sh.UserOrGroupId))
                        toDelete.add(sh.Id);
                }
            }
        }*/

    List<OpportunityShare> newSharings = new List<OpportunityShare>();
    for (Opportunity opp : [
      SELECT Id, AccountID
      FROM Opportunity
      WHERE AccountID IN :accountToUserMap.keyset()
    ]) {
      if (accountToUserMap.containsKey(opp.AccountID)) {
        for (String userID : accountToUserMap.get(opp.AccountId)) {
          newSharings.add(
            new OpportunityShare(
              OpportunityId = opp.Id,
              UserOrGroupId = userID,
              OpportunityAccessLevel = 'Read'
            )
          );
        }
      }
    }
    System.debug('newSharings ' + newSharings);
    manageNewUserSharings(toDelete, JSON.serialize(newSharings));
  }

  public static Set<String> getCommunityUserProfileId() {
    String validationMessage = 'Please set correct Community User Profile Name in Community_User_Profile_Name Custom Label';
    if (String.isEmpty(Label.Community_User_Profile_Name))
      throw new CommunityUserException(validationMessage);

    Set<String> result = new Set<String>();
    List<String> names = Label.Community_User_Profile_Name.split(',');
    List<Profile> profiles = [SELECT id FROM profile WHERE Name = :names];
    if (!profiles.isEmpty()) {
      for (Profile p : profiles) {
        result.add(((String) p.Id).substring(0, 15));
      }
      return result;
    } else
      throw new CommunityUserException(validationMessage);
  }

  @future
  public static void manageNewUserSharings(
    List<Id> todeleteIds,
    String jsonNewOppSharings
  ) {
    List<OpportunityShare> toDelete = new List<OpportunityShare>();
    for (Id sharingId : toDeleteIds) {
      toDelete.add(new OpportunityShare(Id = sharingId));
    }
    delete toDelete;
    System.debug('todeleteIds ' + todeleteIds + ',\n' + toDelete);

    List<OpportunityShare> newSharings = (List<OpportunityShare>) JSON.deserialize(
      jsonNewOppSharings,
      List<OpportunityShare>.class
    );
    System.debug(
      'jsonNewOppSharings ' + jsonNewOppSharings + ',\n' + newSharings
    );
    insert newSharings;
  }

  public class CommunityUserException extends Exception {
  }
}

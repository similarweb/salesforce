/**
 * @author Itzik Winograd
 * @date 06/06/2021
 * @description Keep the account team on ownership changes.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public without sharing class KeepAccountTeamMembers {
  /**
   * @author Itzik Winograd
   * @date 06/06/2021
   * @description filter the accounts for owner changes. execute an executable
   * @param List<Account> accounts - the Trigger.new accounts
   * @param Map<Id,Account> oldMap - the Trigger.old map of accounts
   * @return None
   */
  public List<Account> handle(List<Account> accounts, Map<Id, Account> oldMap) {
    List<Account> filteredAccounts = filterAccounts(accounts, oldMap);
    if (!filteredAccounts.isEmpty()) {
      System.debug(
        '### KeepAccountTeamMembers - filteredAccounts: ' + filteredAccounts
      );
      List<AccountTeamMember> accountTeamMembers = [
        SELECT
          Id,
          AccountAccessLevel,
          AccountId,
          CaseAccessLevel,
          UserId,
          ContactAccessLevel,
          OpportunityAccessLevel,
          TeamMemberRole,
          Member_of_Territory__c
        FROM AccountTeamMember
        WHERE AccountId IN :filteredAccounts
      ];
      if (!accountTeamMembers.isEmpty()) {
        String teamMembersJson = JSON.serialize(accountTeamMembers);
        System.debug(
          '### KeepAccountTeamMembers - AccountTeamMember records: ' +
          teamMembersJson
        );
        System.enqueueJob(new KeepAccountTeamQueueable(teamMembersJson));
      }
    }
    return filteredAccounts;
  }

  /**
   * @author Itzik Winograd
   * @date 06/06/2021
   * @description filter only accounts with changed owner
   * @param List<Account> accounts - the Trigger.new accounts
   * @param Map<Id,Account> oldMap - the Trigger.old map of accounts
   * @return List<Account> filtered accounts, only accounts with changed owner
   */
  public List<Account> filterAccounts(
    List<Account> accounts,
    Map<Id, Account> oldMap
  ) {
    List<Account> filteredAccounts = new List<Account>();
    for (Account account : accounts) {
      if (account.OwnerId != oldMap.get(account.Id).OwnerId) {
        filteredAccounts.add(account);
      }
    }
    return filteredAccounts;
  }
}

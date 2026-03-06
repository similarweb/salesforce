/**
 * Created by Alon.Shalev on 8/4/2024.
 */

public with sharing class UpdateContactOwnerFromAccountQueueable implements Queueable {
  private Map<Id, Account> accountMap = new Map<Id, Account>();
  private boolean executeLogic;

  public UpdateContactOwnerFromAccountQueueable(
    Map<Id, Account> accountMap,
    boolean executeLogic
  ) {
    this.accountMap = accountMap;
    this.executeLogic = executeLogic;
  }
  public void execute(QueueableContext context) {
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
      WHERE AccountId IN :this.accountMap.values()
    ];
    // Perform any initial processing here

    // Initiate the batch job
    String teamMembers = JSON.serialize(accountTeamMembers);
    if (this.executeLogic) {
      Database.executeBatch(
        new UpdateContactOwnerFromAccountBatch(this.accountMap, teamMembers),
        5
      );
    } else {
      System.enqueueJob(new KeepAccountTeamQueueable(teamMembers));
    }
  }
}

public class AccountMeetingRollupBatch implements Database.Batchable<sObject>, Schedulable {
  private final Integer BATCH_SCOPE_SIZE;

  public AccountMeetingRollupBatch() {
    this.BATCH_SCOPE_SIZE = 50;
  }

  public AccountMeetingRollupBatch(Integer batchScopeSize) {
    this.BATCH_SCOPE_SIZE = batchScopeSize;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      'SELECT Id, Number_Of_Open_Meetings__c, ' +
        '(SELECT Id, Account__c, Status__c FROM Meetings__r) ' +
        'FROM Account'
    );
  }

  public void execute(Database.BatchableContext bc, List<Account> records) {
    List<Account> accountsToUpdate = new List<Account>();
    for (Account acc_i : records) {
      Integer numOfOpenMeetings = 0;
      if (acc_i.Meetings__r != null) {
        for (Meeting__c meet_i : acc_i.Meetings__r) {
          Boolean isActive =
            meet_i.Status__c == 'Pending' ||
            meet_i.Status__c == 'In Progress' ||
            meet_i.Status__c == 'Rescheduling';
          if (isActive) {
            numOfOpenMeetings++;
          }
        }
      }
      if (acc_i.Number_Of_Open_Meetings__c != numOfOpenMeetings) {
        acc_i.Number_Of_Open_Meetings__c = numOfOpenMeetings;
        accountsToUpdate.add(acc_i);
      }
    }
    Database.update(accountsToUpdate, false);
  }

  public void finish(Database.BatchableContext bc) {
  }

  public void execute(SchedulableContext sc) {
    AccountMeetingRollupBatch batch = new AccountMeetingRollupBatch();
    Database.executeBatch(batch, this.BATCH_SCOPE_SIZE);
  }
}

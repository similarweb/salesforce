/**
 * Queueable class to revert owner changes on closed opportunities
 * when the change was triggered by an Account owner change.
 * Only reverts if the owner was changed on the same day.
 */
public without sharing class RevertClosedOppOwnerQueueable implements Queueable {
  private Set<Id> closedOppIds;

  // Static variable for test mocking of history records
  @TestVisible
  private static Map<Id, List<HistoryWrapper>> mockHistoryData;

  public RevertClosedOppOwnerQueueable(Set<Id> closedOppIds) {
    this.closedOppIds = closedOppIds;
  }

  /**
   * Wrapper class to represent history record data (allows mocking in tests)
   */
  public class HistoryWrapper {
    public Id opportunityId;
    public String oldValue;
    public String newValue;
    public Datetime createdDate;

    public HistoryWrapper(
      Id oppId,
      String oldVal,
      String newVal,
      Datetime createdDt
    ) {
      this.opportunityId = oppId;
      this.oldValue = oldVal;
      this.newValue = newVal;
      this.createdDate = createdDt;
    }
  }

  /**
   * Gets history records - returns mock data in test context if available
   */
  private List<HistoryWrapper> getHistoryRecords(Set<Id> oppIds) {
    // If mock data is available (test context), use it
    if (Test.isRunningTest() && mockHistoryData != null) {
      List<HistoryWrapper> result = new List<HistoryWrapper>();
      for (Id oppId : oppIds) {
        if (mockHistoryData.containsKey(oppId)) {
          result.addAll(mockHistoryData.get(oppId));
        }
      }
      System.debug(
        'RevertClosedOppOwnerQueueable -- Using mock history data: ' +
          result.size() +
          ' records'
      );
      return result;
    }

    // Normal execution - query actual history
    List<OpportunityFieldHistory> historyRecords = [
      SELECT OpportunityId, OldValue, NewValue, CreatedDate, Field
      FROM OpportunityFieldHistory
      WHERE OpportunityId IN :oppIds AND Field = 'Owner'
      ORDER BY CreatedDate DESC
    ];

    List<HistoryWrapper> wrappers = new List<HistoryWrapper>();
    for (OpportunityFieldHistory hist : historyRecords) {
      wrappers.add(
        new HistoryWrapper(
          hist.OpportunityId,
          hist.OldValue != null ? String.valueOf(hist.OldValue) : null,
          hist.NewValue != null ? String.valueOf(hist.NewValue) : null,
          hist.CreatedDate
        )
      );
    }
    return wrappers;
  }

  public void execute(QueueableContext context) {
    System.debug('RevertClosedOppOwnerQueueable -- START');
    System.debug(
      'RevertClosedOppOwnerQueueable -- closedOppIds: ' + closedOppIds
    );

    if (closedOppIds == null || closedOppIds.isEmpty()) {
      System.debug(
        'RevertClosedOppOwnerQueueable -- No opportunity IDs provided, exiting'
      );
      return;
    }

    Date today = Date.today();
    System.debug('RevertClosedOppOwnerQueueable -- today: ' + today);
    List<Opportunity> oppsToUpdate = new List<Opportunity>();

    // Get history records (uses mock data in test context if available)
    List<HistoryWrapper> historyRecords = getHistoryRecords(closedOppIds);

    System.debug(
      'RevertClosedOppOwnerQueueable -- historyRecords found: ' +
      historyRecords.size()
    );
    for (HistoryWrapper hist : historyRecords) {
      System.debug(
        'RevertClosedOppOwnerQueueable -- History record: OppId=' +
          hist.opportunityId +
          ' | OldValue=' +
          hist.oldValue +
          ' | NewValue=' +
          hist.newValue +
          ' | CreatedDate=' +
          hist.createdDate
      );
    }

    // Get the latest history record per Opportunity - only include records where OldValue is a User ID (not a name)
    Map<Id, HistoryWrapper> latestHistoryMap = new Map<Id, HistoryWrapper>();
    for (HistoryWrapper hist : historyRecords) {
      // Check if OldValue is a User ID (starts with '005')
      String oldValueStr = hist.oldValue != null ? hist.oldValue : '';
      if (
        oldValueStr.startsWith('005') &&
        !latestHistoryMap.containsKey(hist.opportunityId)
      ) {
        // First match for this Opp = most recent (due to DESC order in query)
        latestHistoryMap.put(hist.opportunityId, hist);
        System.debug(
          'RevertClosedOppOwnerQueueable -- Stored latest history record for OppId=' +
            hist.opportunityId +
            ' with OldValue: ' +
            oldValueStr
        );
      } else if (!oldValueStr.startsWith('005')) {
        System.debug(
          'RevertClosedOppOwnerQueueable -- Skipping history record with name OldValue: ' +
          oldValueStr
        );
      }
    }

    System.debug(
      'RevertClosedOppOwnerQueueable -- latestHistoryMap keys: ' +
      latestHistoryMap.keySet()
    );

    // Check each opportunity for owner changes made today
    for (Id oppId : latestHistoryMap.keySet()) {
      HistoryWrapper latestChange = latestHistoryMap.get(oppId);
      System.debug(
        'RevertClosedOppOwnerQueueable -- Checking OppId=' +
          oppId +
          ' | latestChange.createdDate.date()=' +
          latestChange.createdDate.date() +
          ' | today=' +
          today +
          ' | OldValue=' +
          latestChange.oldValue
      );
      // Check if the change was made today
      if (
        latestChange.createdDate.date() == today &&
        latestChange.oldValue != null
      ) {
        System.debug(
          'RevertClosedOppOwnerQueueable -- Will revert OppId=' +
            oppId +
            ' to OwnerId=' +
            latestChange.oldValue
        );
        oppsToUpdate.add(
          new Opportunity(
            Id = oppId,
            OwnerId = (Id) latestChange.oldValue,
            Bypass_Owner_Change_Validation__c = true
          )
        );
      } else {
        System.debug(
          'RevertClosedOppOwnerQueueable -- Skipping OppId=' +
            oppId +
            ' (not changed today or no old value)'
        );
      }
    }

    System.debug(
      'RevertClosedOppOwnerQueueable -- oppsToUpdate: ' + oppsToUpdate
    );

    if (!oppsToUpdate.isEmpty()) {
      System.debug(
        'RevertClosedOppOwnerQueueable -- Updating ' +
          oppsToUpdate.size() +
          ' opportunities with bypass enabled'
      );
      update oppsToUpdate;
      System.debug('RevertClosedOppOwnerQueueable -- Owner update completed');

      // Deactivate the bypass after owner has been reverted
      List<Opportunity> oppsToDeactivateBypass = new List<Opportunity>();
      for (Opportunity opp : oppsToUpdate) {
        oppsToDeactivateBypass.add(
          new Opportunity(
            Id = opp.Id,
            Bypass_Owner_Change_Validation__c = false
          )
        );
      }
      System.debug(
        'RevertClosedOppOwnerQueueable -- Deactivating bypass on ' +
          oppsToDeactivateBypass.size() +
          ' opportunities'
      );
      update oppsToDeactivateBypass;
      System.debug('RevertClosedOppOwnerQueueable -- Bypass deactivated');
    } else {
      System.debug(
        'RevertClosedOppOwnerQueueable -- No opportunities to update'
      );
    }
    System.debug('RevertClosedOppOwnerQueueable -- END');
  }
}

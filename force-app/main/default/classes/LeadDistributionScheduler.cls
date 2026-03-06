/**
 * Created by zohar.sinay on 28/11/2021.
 */

public with sharing class LeadDistributionScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Integer BATCH_LIMIT = Integer.valueOf(
      GeneralUtil.getGeneralConfig('Lead_Distribution_Batch_Size')
        .Number_Value__c
    );

    Id batchInstanceId = Database.executeBatch(
      new LeadDistributionBatch(),
      BATCH_LIMIT
    );
  }
}

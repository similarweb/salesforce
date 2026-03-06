/**
 * @author Itzik Winograd
 * @date 10/08/2021
 * @description Schedulable class for shareasale retires.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public class ShareASaleRetriesScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Integer BATCH_LIMIT = Integer.valueOf(
      GeneralUtil.getGeneralConfig('ShareASale_Transaction_Batch_Size')
        .Number_Value__c
    );

    ShareASaleRetriesBatch leadRetriesBatch = new ShareASaleRetriesBatch(
      'lead'
    );
    Database.executebatch(leadRetriesBatch, BATCH_LIMIT);

    ShareASaleRetriesBatch contactRetriesBatch = new ShareASaleRetriesBatch(
      'Contact'
    );
    Database.executebatch(contactRetriesBatch, BATCH_LIMIT);
  }
}

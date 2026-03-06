/**
 * @author Zohar Sinay
 * @date 5/04/2022
 * @description Schedulable class for LeadCaptureRetryBatch.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public class LeadCaptureRetryBatchScheduler implements Schedulable {
  private Integer numberOfDays = 7;

  public LeadCaptureRetryBatchScheduler(Integer numOfDays) {
    this.numberOfDays = numOfDays;
  }
  /**
   * @param sc Schedule context for the scheduler
   * @description executing the LeadCaptureRetryBatch according to the general config
   */
  public void execute(SchedulableContext sc) {
    Integer BATCH_LIMIT = Integer.valueOf(
      GeneralUtil.getGeneralConfig('Lead_Capture_Retry').Number_Value__c
    );

    Id batchInstanceId = Database.executeBatch(
      new LeadCaptureRetryBatch(numberOfDays),
      BATCH_LIMIT
    );
  }
}

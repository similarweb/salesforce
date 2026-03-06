/**
 * Created by zohar.sinay on 27/07/2022.
 */
/**
 * @author Zohar Sinay
 * @date 27/07/2022
 * @description Schedulable class for data partners batch
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */

public with sharing class DataPartnerManagementBatchScheduler implements Schedulable {
  public void execute(SchedulableContext sc) {
    Integer BATCH_LIMIT = Integer.valueOf(
      GeneralUtil.getGeneralConfig('DataPartnerManagementBatchSize')
        .Number_Value__c
    );

    DataPartnerManagementBatch DPMBatch = new DataPartnerManagementBatch();
    Database.executebatch(DPMBatch, BATCH_LIMIT);
  }
}

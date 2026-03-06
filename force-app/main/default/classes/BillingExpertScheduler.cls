/**
* @author Itzik Winograd
* @date 27/07/2022
* @description Schedulable class for BillingExpertBatch
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      -
* date        -
* description -
* --------------------------------------------------------------------------------------
*/
public class BillingExpertScheduler implements Schedulable {
    public void execute(SchedulableContext sc){
        Integer BATCH_LIMIT = Integer.valueOf(GeneralUtil.getGeneralConfig('BillingExpertBatchSize').Number_Value__c);
        Database.executeBatch(new BillingExpertBatch(), BATCH_LIMIT);
    }
}
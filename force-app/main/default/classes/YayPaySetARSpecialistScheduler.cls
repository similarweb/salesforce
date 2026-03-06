/**
 * @author Itzik Winograd
 * @date 29/09/2022
 * @description Scheduler for YayPay YayPaySetARSpecialistBatch
 */
public with sharing class YayPaySetARSpecialistScheduler implements Schedulable{

    /**
     * @author Itzik Winograd
     * @date 29/09/2022
     * @description Scheduler execute Method
     * */
    public void execute(SchedulableContext sc) {
        Integer BATCH_LIMIT = Integer.valueOf(GeneralUtil.getGeneralConfig('BillingExpertBatchSize').Number_Value__c);
        Database.executeBatch(new YayPaySetARSpecialistBatch(), BATCH_LIMIT);
    }
}
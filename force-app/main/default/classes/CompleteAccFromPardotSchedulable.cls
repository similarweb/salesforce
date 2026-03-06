/**
* @author Itzik Winograd
* @date 27/04/2020
* @description Schedulable class for CompleteAccFromPardotBatch. Manually scheduled.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/
global class CompleteAccFromPardotSchedulable implements Schedulable{  
    global void execute (SchedulableContext SC){
        CompleteAccFromPardotBatch pardotBatch = new CompleteAccFromPardotBatch();
        Integer BATCH_SIZE = Integer.valueOf(GeneralUtil.getGeneralConfig('Complete_Account_From_Pardot_Batch_Size').Number_Value__c);
        database.executeBatch(pardotBatch, BATCH_SIZE);         
    }
}
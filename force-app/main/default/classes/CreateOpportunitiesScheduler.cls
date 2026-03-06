/**
* @author Itzik Winograd
* @date 10/10/2021
* @description Schedulable class for CreateOpportunitiesBatch.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
public class CreateOpportunitiesScheduler implements Schedulable {
    public void execute(SchedulableContext sc){
        Integer BATCH_LIMIT = Integer.valueOf(GeneralUtil.getGeneralConfig('Opportunites_Creation_Batch_Size').Number_Value__c);

        Id batchInstanceId = Database.executeBatch(new CreateOpportunitiesBatch('CreateOpps_Renewal'), BATCH_LIMIT); 
    }
}
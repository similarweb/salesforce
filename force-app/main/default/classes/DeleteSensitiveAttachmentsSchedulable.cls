/**
* @author Itzik Winograd
* @date 29/08/2021
* @description Schedulable class for Deletion of sensitive attachments
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 03/03/2022
* description - Take the BATCH_LIMIT form the 'DeleteSensitiveAttachmentsBatchSize' GeneralConfig
* --------------------------------------------------------------------------------------
*/
public class DeleteSensitiveAttachmentsSchedulable implements Schedulable {
    public void execute(SchedulableContext sc){
        Integer BATCH_LIMIT = Integer.valueOf(GeneralUtil.getGeneralConfig('DeleteSensitiveAttachmentsBatchSize').Number_Value__c);

        DeleteSensitiveAttachmentsBatch contactRetriesBatch = new DeleteSensitiveAttachmentsBatch();
        Database.executebatch(contactRetriesBatch, BATCH_LIMIT);
    }
}
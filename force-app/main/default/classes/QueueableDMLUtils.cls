/**
* @author Itzik Winograd
* @date 17/06/2021
* @description Queueable class for DML operations. 
*              Can Execute further logic by running the AdditionalLogicForAfterDML class.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------
*/
public class QueueableDMLUtils implements Queueable{
    private List<SObject> sobjectsList;
    private List<Log_Event__e> logEventList = new List<Log_Event__e>();
    private String operation;
    private Boolean allOrNothing; //set to true if null received
    private String additionalProcessClassName;

    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Constructor.
    * @param List<SObject> sobjectsList - list to perform the DML on
    * @param String operation - DML operation type: Insert, Update, Delete, Upsert
    * @param Boolean allOrNothing - for the DML operation
    * @param String additionalProcessClassName - class name that implements the 'AdditionalLogicForAfterDML' interface,
    *               with additional logic to run after the DML Operation.
    */
    public QueueableDMLUtils(List<SObject> sobjectsList, String operation, Boolean allOrNothing, String additionalProcessClassName) {
        this.sobjectsList = sobjectsList;
        this.operation = operation;
        this.allOrNothing = allOrNothing != null ? allOrNothing : true;
        this.additionalProcessClassName = additionalProcessClassName;
    }

    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Queueable Execute Method
    */
    public void execute(QueueableContext context){
        Set<Id> successfulIdSet = new Set<Id>();
        Set<Id> failursIdSet = new Set<Id>();

        if (operation == 'update'){
            updateMethod(successfulIdSet, failursIdSet);
        } else if(operation == 'insert'){
            insertMethod(successfulIdSet, failursIdSet);
        } else if(operation == 'upsert'){
            upsertMethod(successfulIdSet, failursIdSet);
        } else if(operation == 'delete'){
            deleteMethod(successfulIdSet, failursIdSet);
        }
        if(additionalProcessClassName != null){
            executeAdditionalLogic(successfulIdSet, failursIdSet);
        }
        if(!logEventList.isEmpty()){
            Eventbus.publish(logEventList);
        }
    }
    
    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Make an Upsert DML operation . Handle logs.
    * @param Set<Id> successfulIdsSet - set of Ids with successful records ids
    * @param Set<Id> failursIdsSet  - set of Ids with failur records ids
    * @return Void.
    */
    public void upsertMethod(Set<Id> successfulIdsSet, Set<Id> failursIdsSet){
        List<Database.UpsertResult> SObjectSR = Database.upsert(sobjectsList,allOrNothing);
        for (Integer i = 0; i < SObjectSR.size(); i++) {
            Database.UpsertResult result = SObjectSR[i];
            if (!result.isSuccess()) {
                handleDMLErrorLogs(sobjectsList[i],result.getErrors().toString());
                failursIdsSet.add(sobjectsList[i].Id);
            } else { //success
                successfulIdsSet.add(sobjectsList[i].Id);
            }
        }
    }

    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Make an Update DML operation . Handle logs.
    * @param Set<Id> successfulIdsSet - set of Ids with successful records ids
    * @param Set<Id> failursIdsSet  - set of Ids with failur records ids
    * @return Void.
    */
    public void updateMethod(Set<Id> successfulIdsSet, Set<Id> failursIdsSet){
        List<Database.SaveResult> SObjectSR = Database.update(sobjectsList,allOrNothing);
        for (Integer i = 0; i < SObjectSR.size(); i++) {
            Database.SaveResult result = SObjectSR[i];
            if (!result.isSuccess()) {
                handleDMLErrorLogs(sobjectsList[i],result.getErrors().toString());
                failursIdsSet.add(sobjectsList[i].Id);
            } else { //success
                successfulIdsSet.add(sobjectsList[i].Id);
            }
        }
    }

    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Make an inser DML operation . Handle logs.
    * @param Set<Id> successfulIdsSet - set of Ids with successful records ids
    * @param Set<Id> failursIdsSet  - set of Ids with failur records ids
    * @return Void.
    */
    public void insertMethod(Set<Id> successfulIdsSet, Set<Id> failursIdsSet){
        List<Database.SaveResult> SObjectSR = Database.insert(sobjectsList,allOrNothing);
        for (Integer i = 0; i < SObjectSR.size(); i++) {
            Database.SaveResult result = SObjectSR[i];
            if (!result.isSuccess()) {
                handleDMLErrorLogs(sobjectsList[i],result.getErrors().toString());
                failursIdsSet.add(sobjectsList[i].Id);
            } else { //success
                successfulIdsSet.add(sobjectsList[i].Id);
            }
        }
    }

    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Make an Delete DML operation . Handle logs.
    * @param Set<Id> successfulIdsSet - set of Ids with successful records ids
    * @param Set<Id> failursIdsSet  - set of Ids with failur records ids
    * @return Void.
    */
    public void deleteMethod(Set<Id> successfulIdsSet, Set<Id> failursIdsSet){
        List<Database.DeleteResult> SObjectSR = Database.delete(sobjectsList,allOrNothing);
        for (Integer i = 0; i < SObjectSR.size(); i++) {
            Database.DeleteResult result = SObjectSR[i];
            if (!result.isSuccess()) {
                handleDMLErrorLogs(sobjectsList[i],result.getErrors().toString());
                failursIdsSet.add(sobjectsList[i].Id);
            } else { //success
                successfulIdsSet.add(sobjectsList[i].Id);
            }
        }
    }

    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Log handler. Create a log record for a given SObject, with the appropriate operation and Errors.
    * @param None.  
    * @return Void.
    */
    public void handleDMLErrorLogs(SObject sobj, String errors){
        String errorMessage = 'Error in QueueableDMLUtils - ' + operation +', ' + allOrNothing + ': ' + errors;
        System.debug('### errorMessage: ' + errorMessage);
        logEventList.add(LogEventUtils.createLogEventRecord(new List<Id>{sobj.Id}, 'QueueableDMLUtils', operation, 
                    JSON.serialize(sobj), errorMessage, 'Error',null,null));
    }

    /**
    * @author Itzik Winograd
    * @date 17/06/2021
    * @description Execute additional logic. The additinoal logic must implement the interface AdditionalLogicForAfterDML.
    *              If there was an error executing the additional logic - create a log and throw an exception.
    * @param Set<Id> successfulIdsSet - set of Ids with successful records ids
    * @param Set<Id> failursIdsSet  - set of Ids with failur records ids
    * @return Void.
    */
    public void executeAdditionalLogic(Set<Id> successfulIdsSet, Set<Id> failursIdsSet){
        try{
            Type t = Type.forName(additionalProcessClassName);
	        AdditionalLogicForAfterDML processHandler = (AdditionalLogicForAfterDML)t.newInstance();
            processHandler.handle(successfulIdsSet, failursIdsSet);
        }
        catch(Exception ex){
            logEventList.add(LogEventUtils.createLogEventRecord(new List<Id>(successfulIdsSet ), 'QueueableDMLUtils', 'executeAdditionalLogic', 
            '', 'Error executing additional logic: ' + additionalProcessClassName + ' -  ' + ex.getMessage(), 'Error',null,null));
        }
    }   
    
    private class QueueableDMLUtilsException extends Exception{}

}
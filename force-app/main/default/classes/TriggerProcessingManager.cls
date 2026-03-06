/**
* @author Gad Sharon
* @date 25/09/18
* @description This class is used to determine which class we need to run on every trigger.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* @author      -
* @date        -
* @description -
* --------------------------------------------------------------------------------------
*/

public class TriggerProcessingManager {

    public static string objApiName, eventTime, eventType;
    public static map <String, map<String, map<String, list<Trigger_Configuration__mdt>>>> configuration = new map <String, map<String, map<String, list<Trigger_Configuration__mdt>>>>();
    public static map <string, integer> mapNumOfIterationsByProcess = new map <string, integer>();

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Determine the context of the trigger, get all relevant processes and run them.
    * @param string - The object API name of the triggered object.
    * @return None.
    */

    public static void handle(string objectApiName)
    {
        //Determine trigger context
        determineContext(objectApiName);

        //Get the processes defined for this object, in this event time and in this event type (e.g. all processes for Lead-before-insert)
        list<Trigger_Configuration__mdt> processes = getProcesses(objApiName, eventTime, eventType);

        if(!processes.isEmpty())
        {
            //According to the context - determine the processes we neeed to run and execute them
            executeProcesses(processes);
        }
    }

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Determine the object the trigger runs on,
                    the event time (before/after)
                    and the event type (insert/update/delete/undelete).
    * @param string - The object API name of the triggered object.
    * @return None.
    */

    public static void determineContext(string objectApiName)
    {
        objApiName = objectApiName;

        //Determine the event time
        eventTime = determineEventTime();

        //Determine the event type
        eventType = determineEventType();
    }

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Determine the event time (before/after) the trigger runs on.
    * @param None.
    * @return string - The event time the trigger runs on.
    */

    public static string determineEventTime()
    {
        return GeneralUtil.determineEventTime();
    }

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Determine the event type (insert/update/delete/undelete) the trigger runs on.
    * @param None.
    * @return string - The event type the trigger runs on.
    */

    public static string determineEventType() {
        return GeneralUtil.determineEventType();
    }

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Get all relevant processes we need to run on this object.
    * @param String objectApiName - The object API name.
             String funcEventTime - The event time of the trigger.
             String funcEventType - The event type of the trigger.
    * @return List <Trigger_Configuration__mdt> - List of the processes we need to run on this object.
    */

    public static List <Trigger_Configuration__mdt> getProcesses(String objectApiName, String funcEventTime, String funcEventType)
    {
        list<Trigger_Configuration__mdt> processes = new list <Trigger_Configuration__mdt>();

        if(!configuration.containsKey(objectApiName))
            addObjectToConfiguration(objectApiName);

        if(configuration.get(objectApiName).get(funcEventTime) != null &&
                configuration.get(objectApiName).get(funcEventTime).get(funcEventType) != null)
        {
            processes = configuration.get(objectApiName).get(funcEventTime).get(funcEventType);
        }
        return processes;
    }

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Add an object to map of processes per type, time and object.
    * @param string - The object API name.
    * @return None.
    */

    private static void addObjectToConfiguration(String objectApiName)
    {
        List <Trigger_Configuration__mdt> triggerConfigurationList = [Select Implementing_Class__c, Object_API_Name__c, Order_of_Execution__c,
                                                                    Event_Time__c, Event_Type__c
                                                                    From Trigger_Configuration__mdt
                                                                    Where Object_API_Name__c = :objectApiName
                                                                    AND Active__c = true
                                                                    order by Order_of_Execution__c];

        if(triggerConfigurationList.isEmpty())
        {
            configuration.put(objectApiName,new map<string,map<string,list<Trigger_Configuration__mdt>>>());
            return;
        }

        for(Trigger_Configuration__mdt config :triggerConfigurationList)
        {
            if(!configuration.containsKey(objectApiName))//if havent encountered this object type yet
                configuration.put(objectApiName,new map<string,map<string,list<Trigger_Configuration__mdt>>>());

            if(!configuration.get(objectApiName).containsKey(config.Event_Time__c.toLowerCase()))//if havent encountered this event time
                configuration.get(objectApiName).put(config.Event_Time__c.toLowerCase(),new map<string,list<Trigger_Configuration__mdt>>());

            if(!configuration.get(objectApiName).get(config.Event_Time__c.toLowerCase()).containsKey(config.Event_Type__c.toLowerCase()))//if havent encountered this event type
                configuration.get(objectApiName).get(config.Event_Time__c.toLowerCase()).put(config.Event_Type__c.toLowerCase(), new List<Trigger_Configuration__mdt>());

            configuration.get(objectApiName).get(config.Event_Time__c.toLowerCase()).get(config.Event_Type__c.toLowerCase()).add(config);
        }
    }

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Checks the context of the trigger and returns the relevant records we need to work on.
    * @param None.
    * @return list<sObject> - trigger.old if the context is delte, trigger.new otherwise.
    */

    public static list<sObject> getContextTriggerList()
    {
        return trigger.isDelete ? trigger.old:trigger.new;
    }

    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Go through all the processes we need to run and run them with the relevant records.
    * @param List<Trigger_Configuration__mdt> - The list of processes we need to run.
             map<String, list<sObject>> - Records from trigger.new mapped to their record type.
             map<String, map<Id, sObject>> - Records from trigger.oldMap mapped to their record type.
    * @return None.
    */
    @TestVisible
    private static void executeProcesses(List<Trigger_Configuration__mdt> processes)
    {
        boolean runProcess;

        for(Trigger_Configuration__mdt prc : processes)
        {
            runProcess = true;
            list<sObject> triggerNew = new list<sObject>();
            map<Id, sObject> triggerOldMap = new map<Id, sObject>();

            triggerNew.addAll(getContextTriggerList());
            if(trigger.OldMap != null){
                triggerOldMap.putAll(trigger.OldMap);
            }

            //If it's update and we have records we are about to send to the process.
            if(!triggerOldMap.isEmpty())
            {
                runProcess = preventMultipleRuns(prc.Implementing_Class__c);
            }

            if(!triggerNew.isEmpty() && runProcess)
            {
                executeProcess(prc.Implementing_Class__c, triggerNew, triggerOldMap);
            }
        }
    }

    /**
    * @author Gad Sharon
    * @date 08/10/18
    * @description Check if we already ran the code in the class twice (the 2nd run is to allow processing after updates originated from workflows/process builder).
                    if we already ran the code twice, we return false and we'll know not to run the process.
    * @param string - The class name of the business process we need to run.
    * @return boolean - True if we should run the process, false otherwise.
    */
    @TestVisible
    private static boolean preventMultipleRuns(string classToRun)
    {
        boolean runProcess = true;

        //We didn't processed the records for this process yet.
        if(!mapNumOfIterationsByProcess.containsKey(classToRun))
        {
            mapNumOfIterationsByProcess.put(classToRun, 1);
            return runProcess;
        }

        mapNumOfIterationsByProcess.put(classToRun, mapNumOfIterationsByProcess.get(classToRun) + 1);

        if(mapNumOfIterationsByProcess.get(classToRun) > 2)
        {
            runProcess = false;
        }

        return runProcess;
    }


    /**
    * @author Gad Sharon
    * @date 25/09/18
    * @description Excecute a business process with the relevant records it should run on.
    * @param string - The class name of the business process we need to run.
             list<sObject> - The records the business process should run on.
             map<Id, sObject> - The old stage of the records the business process should run on.
    * @return None.
    */
    @TestVisible
    private static void executeProcess(string classToRun, list<sObject> triggerNew, map<Id, sObject> triggerOldMap)
    {
        Type t = Type.forName(classToRun);
        IProcessHandler processHandler = (IProcessHandler)t.newInstance();
        try
        {
            processHandler.handle(triggerNew, triggerOldMap);
        }
        catch(Exception ex)
        {
//            ApexDebugLog.logException(ex, JSON.serialize(triggerNew), classToRun, eventTime + '-' + eventType);

            //At this point we want to rollback the transaction and throw an exception, so external systems can perform retry.
            throw new TriggerInfraException('**Exception Message: ' + ex.getMessage() + '. Exception stack: ' + ex.getStackTraceString() + '**');

        }
    }




    private class TriggerInfraException extends Exception{}

}
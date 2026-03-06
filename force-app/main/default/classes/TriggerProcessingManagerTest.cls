/**
 * @author Itzik Winograd
 * @date 06/10/2022
 * @description Test class for TriggerProcessingManager.
 *              This class will use unit tests (and not business-logic tests), since this is a service.
 */
@isTest
public with sharing class TriggerProcessingManagerTest {
    private static FINAL String PROCESS_NAME = 'TestTrigger';

    @IsTest
    public static void testHandle(){
        TriggerProcessingManager.handle(PROCESS_NAME);
    }

    @IsTest
    public static void testDetermineContext(){
        TriggerProcessingManager.determineContext(PROCESS_NAME);
    }

    @IsTest
    public static void testGetProcessesAndExecute(){
        list<Trigger_Configuration__mdt> processes = TriggerProcessingManager.getProcesses(PROCESS_NAME, 'before', 'insert');
        TriggerProcessingManager.executeProcess(processes[0].Implementing_Class__c, null, null);
        TriggerProcessingManager.preventMultipleRuns(processes[0].Implementing_Class__c);
    }

}
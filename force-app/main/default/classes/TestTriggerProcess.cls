/**
 * @author Itzik Winograd
 * @date 02/10/2022
 * @description test for the TriggerProcessingManager
 */
public without sharing class TestTriggerProcess implements IProcessHandler {

    /**
     * @author Itzik Winograd
     * @date 02/10/2022
     * @description Main handler - doing nothing
     * @param List<Sobject>Trigger.new
     * @param Map<Id,SObject>
     */
    public void handle(List<SObject> sObjects, Map<Id, SObject> sObjectsByIds) {

    }
}
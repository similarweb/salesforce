public interface IProcessHandler {
    
    void handle(list<sObject> triggerNew, map<Id, sObject> triggerOldMap);

}
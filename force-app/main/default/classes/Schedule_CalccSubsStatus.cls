Global with sharing class Schedule_CalccSubsStatus implements Schedulable{
    
    public static String CRON_EXP = '0 0 0 3 9 ? 2022'; //Used for test class only

    global void execute(SchedulableContext scMain) {
        
        system.debug('TESTING Schedule Schedule_RunLeadAssign - START ');
        
        Batch_CalculateAccSubStatus myclass = new Batch_CalculateAccSubStatus();
        id idBatch = Database.executeBatch(myclass, 200);
        
    }   
    
}
public with sharing class vfTestBatch_CalculateAccSubStatus {
    
    static public string errors {get;set;}
    static public boolean isTest= false;
    
        
    public static void RunSubBatch()
    {
        try
        {
            Batch_CalculateAccSubStatus myclass = new Batch_CalculateAccSubStatus();
            if (isTest) utils.istest = true;
            id idBatch = Database.executeBatch(myclass, 90);
            errors = 'Success';
        }
        catch (exception e)
        {
            errors = e.getmessage();
            system.debug('TESTING - error is '+errors);
        }
        
    }
    

}
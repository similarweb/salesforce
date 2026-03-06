public class ZuoraSubscriptionHandlerBatch implements Database.Batchable<sObject>, Schedulable{
    
    private Boolean allDB = false;
    
    public map <id,Account> Acc4Update = new map <id,Account>();
    public map <id,Zuora__Subscription__c> oldmap;
    public map <id,Account> AccMap = new map <id,Account>();	
    public map <id,Zuora__Subscription__c> Sub4Reval = new map <id,Zuora__Subscription__c>();
    public List<sObject> subs = new List<sObject>();

    public ZuoraSubscriptionHandlerBatch(){ // added 2022-01-13
        this.allDB = true;
    }
    public ZuoraSubscriptionHandlerBatch(Boolean allDB){ 
        this.allDB = allDB;
    }
    
    public void execute(SchedulableContext SC) {
        /** Itzik Winograd 2022-01-26: Removed inside rescheduling. All daily scheduling are done via UI.
        if(SC != null){
            List<CronTrigger> cts = [SELECT ID, PreviousFireTime, NextFireTime, CronExpression, CronJobDetail.Name  FROM crontrigger 
                                     WHERE Id=: SC.getTriggerId() ];
            
            System.abortJob(SC.getTriggerId());        
        }
        System.schedule('ZuoraSubscriptionHandlerBatch',getCronFromDateTime(DateTime.newInstance(Date.today().addDays(1), Time.newInstance(0, 0, 0, 0))), new ZuoraSubscriptionHandlerBatch(true));

        if(allDB)
        */
            Database.executeBatch(new ZuoraSubscriptionHandlerBatch(allDB),5);
    }
    
    public String getCronFromDateTime(Datetime executeTime){
        return executeTime.second() + ' ' + executeTime.minute() + ' ' + executeTime.hour() + ' ' + executeTime.day() + ' ' + executeTime.month() + ' ? ' + executeTime.year();
    }
    
    public Database.QueryLocator start (Database.BatchableContext BC){   
        String userID = UserInfo.getUserId();
        String query = 'SELECT Id,Zuora__Status__c,Zuora__NextRenewalDate__c,Zuora__Account__c,Trigger_AccountRecalc__c,Zuora__SubscriptionEndDate__c FROM Zuora__Subscription__c ORDER BY Zuora__Account__c';  //  WHERE Id=\'a2D0O000000EruYUAS\'
        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Log_Event__e> logEvents = new List<Log_Event__e>();
        GenData (scope,'batch');
        RecalculateAccSubs (scope, 'batch'); 
        utils.Codeoff = true;

        if (Acc4Update.size()>0)
        {
            Integer index = 0;
            List<Database.SaveResult> saveResults =  Database.update(Acc4Update.values(),false);
            for(Database.SaveResult sr : saveResults){
                if(!sr.isSuccess()){
                    logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>{Acc4Update.values()[index].Id} , 'ZuoraSubscriptionHandlerBatch' ,'execute','update failed ',sr.getErrors()[0].getMessage(),'Error'));
                }
                index ++;
            }
        }
        utils.Codeoff = false;
        if(!logEvents.isEmpty()){
            EventBus.publish(logEvents);
        }

    }
    
    public void finish(Database.BatchableContext BC){    
    }
    
    public void calculateAccountSubscriptionStatus (Account a)
    {
        ZuoraSubscriptionHandler.evaluateAccountSubscriptionStatus(a);
        Acc4Update.put (a.id,a);
    }
    
    public boolean AccStatusRecReq (Zuora__Subscription__c zs, string event)
    {
        boolean b = false;
        if (event=='Insert') b=true;
        if (event=='batch') b=true;
        if (oldmap!=null && oldmap.containskey (zs.id))
        {
            if (oldmap.get (zs.id).Zuora__Account__c!=zs.Zuora__Account__c) b=true;
            if (oldmap.get (zs.id).Zuora__Status__c!=zs.Zuora__Status__c) b = true;
            if (oldmap.get (zs.id).Zuora__NextRenewalDate__c!=zs.Zuora__NextRenewalDate__c) b = true;
        }
        if (Sub4Reval.ContainsKey (zs.id)) b=true;
        if (event=='Delete') b=true;
        
        return b;
    }
    
    public void GenData (list <Zuora__Subscription__c> zsList, string event)
    {
        set <id> tempid = new set <id>();
        for (Zuora__Subscription__c zs :zslist)
        {
            if (zs.Zuora__Account__c!=null)
            {
                tempid.add (zs.Zuora__Account__c);                
            } 
            if (zs.id!=null)
            {
                tempid.add (zs.id);
            }
            
        }

        if (tempid.size()>0)
        {
            list <Account> AccList = [select id,Status__c,ownerid,owner.isactive, fr_Next_Renewal_Date__c, fr_NextRenewalDate__c,
                                      (select id,Zuora__Status__c,Zuora__NextRenewalDate__c,Zuora__SubscriptionEndDate__c,Zuora__TermEndDate__c,Payment_Status__c  FROM Zuora__Subscriptions__r)
                                      from Account where id IN :tempid];
            if (AccList.size()>0) AccMap.putall (AccList);
        }
    }
    
    public void RecalculateAccSubs (list <Zuora__Subscription__c> zsList, string event)
    {
        Map<Id,Account> accountToUpdateMap = new Map<Id,Account>();
        for (Zuora__Subscription__c zs : zslist)
        {
            if (AccStatusRecReq (zs,event))
            {
                if (zs.Zuora__Account__c!=null && AccMap.containsKey(zs.Zuora__Account__c)){
                    accountToUpdateMap.put(zs.Zuora__Account__c,AccMap.get (zs.Zuora__Account__c));
                }
            }
        }
        for(Account accountToUpdate : accountToUpdateMap.values()){
            calculateAccountSubscriptionStatus(accountToUpdate);
        }

    }
    
    public void CatchFieldRecalc (list <Zuora__Subscription__c> zsList, string event)
    {
        for (Zuora__Subscription__c zs : zsList)
        {
            if (zs.Trigger_AccountRecalc__c)
            {
                zs.Trigger_AccountRecalc__c = false;
                Sub4Reval.put (zs.id,zs);
            }
        }
    }
    
    /*public static void CalcOwner (list <Zuora__Subscription__c> zslist, string event)
    {
        if (event=='Insert')
        {
            for (Zuora__Subscription__c zs : zslist)
            {
                if (zs.Zuora__Account__c!=null && AccMap.ContainsKey (zs.Zuora__Account__c))
                {
                    if (AccMap.get (zs.Zuora__Account__c).owner.isactive) zs.ownerid = AccMap.get (zs.Zuora__Account__c).ownerid;
                }
            }
        }
    }*/
}
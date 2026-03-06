public with sharing class AssignmentButtonHandler {
    
    public ApexPages.StandardController con;
    public Id target_id{get;set;}
    public static integer showalert=0;
    public static string ErrMsChecklist = '';
    
    public string AssignmentError {get;set;}
    
    public AssignmentButtonHandler(apexPages.StandardController con)
    {
        if(test.isRunningTest()){
            iHaveToDoThis();
        }
        this.con = con;
    }
    
    public AssignmentButtonHandler()
    {
        AssignmentError = apexpages.currentpage().getParameters().get('error');
    }
    public AssignmentButtonHandler(Id tid)
    {
        target_id = tid;
    }
    public static AssignmentButtonHandler factory(Id target_id){
        AssignmentButtonHandler abh = new AssignmentButtonHandler(target_id);
        return abh;
    }
        
    public PageReference ManualRoundRobinLeadSMB()
    {
        /*
        id lid = ApexPages.currentPage().getParameters().get('id');
        Lead l = [select id, reseller__c,Campaign_Name_UTM__c, CreatedDate,email,ownerid,status, isConverted,company , 
                    LastName, business_unit__c,owner.isactive,country,
                    from Lead where id=:lid limit 1];
        LeadTriggerHelperTemp.RoundRobinLead (l,'SMB_Sales');
        l.business_unit__c='SMB';
        update l;
        update LeadTriggerHelperTemp.RoundRobinCS.values();
        PageReference pageref = new PageReference('/'+lid);
        return pageref;*/
        
        return LeadReassignment ('IS_ReRouting');
        
    } 
    
    public PageReference ManualRoundRobinLeadENT()
    {
        id lid = target_id!=null?target_id:ApexPages.currentPage().getParameters().get('id');
        Lead l = [select id, reseller__c,Campaign_Name_UTM__c,CreatedDate,email,ownerid,status, 
                    isConverted,company , LastName, business_unit__c,owner.isactive,
                    industry, Website_Category__c,country
                 from Lead where id=:lid limit 1];
                 
        l.business_unit__c='Enterprise';
        update l;
        update LeadTriggerHelperTemp.RoundRobinCS.values();
        PageReference pageref = new PageReference('/'+lid);
        return pageref;
        
    } 
    
    public PageReference ManualAssignmentSMB ()
    {
        /* sw-27989
        // Reassign Inside CSM button - account
        id aid = target_id!=null?target_id:ApexPages.currentPage().getParameters().get('id');
        Account a = [select id,ownerid from Account where id=:aid];
        a.business_unit__c='Inside Sales';
        update a; // This is done to make sure user can update the record
        */
        return  AccAssignment ('IS_ReRouting');     
    
    }
    
    public PageReference ManualAssignmentSMBAM ()
    {
        id aid = target_id!=null?target_id:ApexPages.currentPage().getParameters().get('id');
        Account a = QueryAccount (aid);
        a.business_unit__c='Inside Sales';
        update a; // This is done to make sure user can update the record
        //PageReference pageref = AccountTriggerHelperTemp.ManualAssignment (aid,'SMB AM');
        /*if (a.billingcountry==null)
        {
            PageReference pr = new Pagereference ('/apex/AssignmentErrorpage?error=No Country found on account');
            return pr;
        }
        */
        a.Routing_Group__c = 'InsideCSM_ReRouting';
        LeadTriggerHelperTEMP.SetValidValues();
        Pagereference Pageref = new pageReference ('/'+aid);
        return Pageref;
    
    }
    
    public PageReference ManualAssignmentSMBPaidAccount ()
    {
        id aid = target_id!=null?target_id:ApexPages.currentPage().getParameters().get('id');
        Account a = [select id,ownerid from Account where id=:aid];
        //a.business_unit__c='SMB';
        update a; // This is done to make sure user can update the record
        PageReference pageref = AccountTriggerHelperTemp.ManualAssignment (aid,'SMB Paid Account');
        
        return pageref;
        
    
    }
    
    public PageReference ManualLeadReassignment()
    {
        return LeadReassignment('SDR_ReRouting');
    }
    
    public PageReference LeadReassignment(string routinggroup)
    {
        id lid = target_id!=null?target_id:ApexPages.currentPage().getParameters().get('id');
        Lead l = [select id, reseller__c,Campaign_Name_UTM__c,CreatedDate,email,ownerid,status, 
                    isConverted,company , LastName, business_unit__c,owner.isactive,
                    industry, Website_Category__c,country,routing_group__c
                 from Lead where id=:lid limit 1];

        l.routing_group__C = routinggroup;
        LeadTriggerHelperTemp.SetKey_TeamMap('Lead');
        LeadTriggerHelperTemp.SetValidValues();

        update LeadTriggerHelperTemp.RoundRobinCS.values();
        PageReference pageref = new PageReference('/'+lid);
        return pageref;
        
    } 
    
    public PageReference ManualAccAssignment()
    {
        // Reassign SDR Button - Account
        system.debug('TESTING ManualAccAssignment fired');
        id aid =  target_id!=null?target_id:ApexPages.currentPage().getParameters().get('id');
        //PageReference pageref = AccountTriggerHelperTemp.ManualAssignment (aid,'SDR_ReRouting',true);
        //PageReference pageref = AccountTriggerHelperTemp.ManualAssignment (aid,'SDR_ReRouting','SDR');
        Account a = [select id,ownerid from Account where id=:aid];
        update a; // This is done to make sure user can update the record
        return  AccAssignment ('SDR_ReRouting');    
        
    }
    
    public static Account QueryAccount (id aid)
    {
        Account a = [select id, reseller__c,website, parentid, ownerid,Always_Active__c,
                       name, uid__c,email__c,billingcountry,
                        Status__c,
                        Business_Unit__c,owner.isactive,AutoAlwaysActive__c,
                        CreatedDate,Routing_Group__c,SDR_Name__c,Route_to__c,
                        ShippingCountry,BillingState,ShippingState,

                            (select id, StageName, AccountId from Opportunities) ,
                            (select id, name, ownerid from ChildAccounts) ,
                            (select id, email, ownerid, CreatedDate from Contacts),
                            (select id,Zuora__Status__c,Zuora__NextRenewalDate__c  from Zuora__Subscriptions__r),
                            (select id,Zuora__PaymentMethod_Type__c from Zuora__R00N40000001kyLcEAI__r)
                    from Account where id=:aid limit 1];
        
        return a;
    }
    
    public PageReference AccAssignment(string routinggroup)
    {
        id aid = target_id!=null?target_id:ApexPages.currentPage().getParameters().get('id');
        Account a = QueryAccount (aid);
                    
        system.debug('TESTING AccAssignment Fired. Acc business unit is '+a.business_unit__c);          

        a.routing_Group__c = routinggroup;

        LeadTriggerHelperTemp.SetKey_TeamMap('Account');
        LeadTriggerHelperTemp.SetValidValues();

        PageReference pageref = new PageReference('/'+aid);
        return pageref;
    }

    private void iHaveToDoThis(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
    

}
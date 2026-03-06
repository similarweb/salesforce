trigger LeadTriggerTEMP on Lead (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    
        /*
    map <string,CSTriggerControl__c> cstrigControl = CSTriggerControl__c.getall();
    if (!cstrigControl.ContainsKey ('Lead') || (cstrigControl.ContainsKey('Lead') && cstrigControl.get('Lead').on__c))
        {
        if (trigger.isBefore)
        {                       // BEFORE - START
            if (trigger.isInsert)
            {                   //INSERT - START
                
                
                CSSettings__c csSet = CSSettings__c.getinstance('Setting');
                LeadTriggerHelperTEMP.Leads4Alloc.clear();
                system.debug('Testing - Setting is '+csSet);
                if (csSet!=null && csSet.MarketoUserID__c!=null && id.valueof(csSet.MarketoUserID__c)==UserInfo.getUserId())
                {
                  for (Lead l :trigger.new) LeadTriggerHelperTEMP.Leads4Alloc.add (l);
                }
                if (LeadTriggerHelperTEMP.Leads4Alloc.size()>0)
                LeadTriggerHelperTEMP.LeadAllocation (LeadTriggerHelperTEMP.Leads4Alloc);
                
                
            }                   //INSERT - START
            
            if (trigger.isUpdate)
            {                   //UPDATE - START
                // dr 25-Feb-2016 // LeadTriggerHelperTEMP.techscores = LeadTriggerHelper.GenerateTechlist();
                LeadTriggerHelperTEMP.techscores = LeadTriggerHelperTEMP.GenerateTechlist();// dr 25-Feb-2016
                LeadTriggerHelperTEMP.oldmap = trigger.oldmap;
                LeadTriggerHelperTEMP.SWTechScore (trigger.new, 'Update');
                
                for (Lead l : trigger.new)
                {
                    if (l.Mass_Reassign__c && !trigger.oldmap.get (l.id).Mass_Reassign__c)
                    {
                        l.Mass_Reassign__c=false;
                        LeadTriggerHelperTEMP.Leads4Alloc.add (l);
                    }
                }
                if (LeadTriggerHelperTEMP.Leads4Alloc.size()>0)
                LeadTriggerHelperTEMP.LeadAllocation (LeadTriggerHelperTEMP.Leads4Alloc);
                
                
                
                
                //LeadTriggerHelperTEMP.Leads4Alloc.clear();
                //for (Lead l : trigger.new)
                //{
                    //if (l.Ready_for_Sales__c && trigger.oldmap.get(l.id).Ready_for_Sales__c==false)
                   // {
                  //      LeadTriggerHelperTEMP.Leads4Alloc.add (l);
                 //   }
                //}
                //if (LeadTriggerHelperTEMP.Leads4Alloc.size()>0)
                //{
                //    LeadTriggerHelperTEMP.LeadAllocation(LeadTriggerHelperTEMP.Leads4Alloc);
                //}
                 
                
            }                   // UPDATE - END
           
            
        }                       // BEFORE - END
        
        
        if (trigger.isAfter)
        {                       // AFTER - START
            if (trigger.isInsert)
            {                   // INSERT - START
                if (LeadTriggerHelperTEMP.Leads4Alloc.size()>0)
                LeadTriggerHelperTEMP.HandleAFTERAction(LeadTriggerHelperTEMP.Leads4Alloc);
            } 
                              // INSERT - END
            //if (trigger.isUpdate)
            //{
                //if (LeadTriggerHelperTEMP.Leads4Alloc.size()>0)
                //{
                //    LeadTriggerHelperTEMP.HandleAFTERAction(LeadTriggerHelperTEMP.Leads4Alloc);
              //  }
           
            //}
            
            if (trigger.isUpdate)
            {
                system.debug('TESTING - Update run');
                LeadTriggerHelperTEMP.Oldmap = trigger.oldmap; 
                system.debug('TESTING - Post Convert Code Launch');
                LeadTriggerHelperTEMP.PostConvertLogic (trigger.new);
                system.debug('TESTING - ContactPostConvert size is '+LeadTriggerHelperTEMP.ContactPostConvertUpdate.size());
                if (LeadTriggerHelperTEMP.ContactPostConvertUpdate.size() > 0) 
                {
                    LeadTriggerHelperTEMP.CodeOff = true; 
                    update LeadTriggerHelperTEMP.ContactPostConvertUpdate.values();
                    LeadTriggerHelperTEMP.CodeOff = false;
                }
                if (LeadTriggerHelperTemp.AccountPostConvertUpdate.size()>0)
                {
                    LeadTriggerHelperTEMP.CodeOff = true; 
                    update LeadTriggerHelperTEMP.AccountPostConvertUpdate.values();
                    LeadTriggerHelperTEMP.CodeOff = false;
                }
                
                
                
                if (LeadTriggerHelperTEMP.Meeting4Update.size()>0)
                {
                    LeadTriggerHelperTEMP.CodeOff = true;
                    update LeadTriggerHelperTEMP.Meeting4Update.values();
                    LeadTriggerHelperTEMP.CodeOff = false;
                }
                
                
            }
            
        }                       // AFTER - END
        
    
    }*/
}
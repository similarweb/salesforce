trigger AccountTriggerTEMP on Account(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  //
  //  map <string,CSTriggerControl__c> cstrigControl = CSTriggerControl__c.getall();
  //
  //
  //
  //    if (!cstrigControl.ContainsKey ('Account') || (cstrigControl.ContainsKey('Account') && cstrigControl.get('Account').on__c))
  //        {
  //        if (trigger.isBefore) // BEFORE - START
  //        {
  //            list <Account> RecurlyAccounts = new list <Account>();
  //
  //            if (trigger.isInsert)
  //            {                       // INSERT - START
  //
  //                for (Account a : trigger.new)
  //                {
  //                    if (a.recurly__Account_Code__c!=null)
  //                    {
  //                        //string domain = LeadTriggerHelperTEMP.getDomainFromEmail(a.recurly__Account_Code__c);
  //                        //if (!AccountTriggerHelperTEMP.freeEmailProvidersList.ContainsKey(domain))
  //                        RecurlyAccounts.add (a);
  //                    }
  //                }
  //
  //            }                       // INSERT - END
  //
  //            if (trigger.isUpdate)
  //            {
  //
  //                LeadTriggerHelperTEMP.techscores = LeadTriggerHelperTEMP.GenerateTechlist();
  //                AccountTriggerHelperTEMP.oldmap = trigger.oldmap;
  //                //AccountTriggerHelperTEMP.SWTechScore (trigger.new, 'Update'); //Itzik, 2021-11-22: removed for similartech__STTechnologies__c removal
  //                /*
  //                if (!AccountTriggerHelperTEMP.CodeOff) for (Account a: trigger.new) // *** TESTING ONLY - REMOVE THIS!!
  //                {
  //                    if (a.recurly__Account_Code__c!=null)
  //                    {
  //                        RecurlyAccounts.add (a);
  //                    }
  //
  //                }                           // *** TESTING ONLY - REMOVE THIS!!
  //                */
  //            }
  //
  //            if (RecurlyAccounts.size()>0)
  //            {
  //                AccountTriggerHelperTEMP.RecurlyAccountAllocation(RecurlyAccounts);
  //            }
  //
  //
  //        }                   // BEFORE - END
  //
  //        if (trigger.isAfter)
  //        {                   // AFTER - START
  //
  //            list <Account> RecurlyAccounts = new list <Account>();
  //
  //            if (Trigger.isInsert)   // INSERT - START
  //            {
  //                for (Account a : trigger.new)
  //                {
  //                    if (a.CodeFutureDelete__c || a.CodeParentID__c!=null || a.recurly__Account_Code__c!=null)
  //                    {
  //                        RecurlyAccounts.add (a);
  //                    }
  //                }
  //
  //            }                       // INSERT - END
  //            if (trigger.isupdate)   // UPDATE - START
  //            {
  //
  //                 if (!AccountTriggerHelperTEMP.CodeOff)
  //                 {
  //                    AccountTriggerHelperTEMP.OldMap = trigger.oldmap;
  //                    /*
  //                    AccountTriggerHelperTEMP.RecalcSubOwner(trigger.new);
  //                    AccountTriggerHelperTEMP.RecalcInvoiceOwner(trigger.new);
  //                    */
  //                    /*
  //                    for (Account a: trigger.new) // *** TESTING ONLY - REMOVE THIS!!
  //                    {
  //                        if (a.recurly__Account_Code__c!=null || a.CodeFutureDelete__c || a.CodeParentID__c!=null)
  //                        {
  //                            RecurlyAccounts.add (a);
  //                        }
  //
  //                    }
  //                    */
  //
  //                 }
  //
  //                list <id> AccID = new list <id>();
  //                list <Account> AcSubscriberUpdate = new list <Account>();
  //
  //                /*
  //                for (Account a : trigger.new) //Update contact Recurly Checkbox
  //                {
  //                    if (a.recurly__Subscriber__c != trigger.oldmap.get(a.id).recurly__Subscriber__c)
  //                    {
  //                        AccID.add (a.id);
  //                        acSubscriberUpdate.add (a);
  //                    }
  //
  //                }
  //                if (accID.size()>0)
  //                {
  //                    list <Contact> AccContacts = [select id,accountid,recurly_subscriber__c,email from Contact where AccountId=:accID];
  //                    list <Contact> Con4Update = new list <Contact>();
  //                    if (AccContacts.size()>0)
  //                    {
  //                        for (Account a: acSubscriberUpdate)
  //                        {
  //                            for (Contact c : AccContacts )
  //                            {
  //                                if (c.email!=null && a.recurly__Account_Code__c!=null && c.AccountId==a.id && c.email==a.recurly__Account_Code__c)
  //                                {
  //                                    c.recurly_subscriber__c = a.recurly__Subscriber__c;
  //                                    Con4Update.add (c);
  //                                }
  //                            }
  //                        }
  //                        if (Con4Update.size()>0) update Con4Update;
  //                    }
  //                }
  //                */
  //
  //            }                       // UPDATE - END
  //
  //            system.debug('TESTING AFTER - Recurly Accounts is '+RecurlyAccounts);
  //            if (RecurlyAccounts.size()>0) AccountTriggerHelperTEMP.HandleAfter(RecurlyAccounts);
  //
  //            /*
  //            if (trigger.isDelete)
  //            {
  //                // Handle Merge
  //
  //                for (Account a : trigger.old) if (a.masterrecordid!=null) AccountTriggerHelperTEMP.isMerge = true;
  //
  //                if (AccountTriggerHelperTEMP.isMerge)
  //                {
  //                    AccountTriggerHelperTEMP.RecalcSubOwner(trigger.old);
  //                    AccountTriggerHelperTEMP.RecalcInvoiceOwner(trigger.old);
  //
  //                }
  //
  //
  //            }*/
  //
  //
  //        }                   // AFTER - END
  //
  //
  //    }
}

/************************************************************************************** 
Name                		: MoodleLogTrigger
Description         		:
Related components 		: 

Created/Modified by   Created/Modified Date     Requested by          Related Task/Issue             
----------------------------------------------------------------------------------------
1. Nevo                     27.03.2018               Nevo					[SW-28689]
****************************************************************************************/
trigger Account_Trigger on Account(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  /**

  AccountTriggerHandler Handler = new AccountTriggerHandler();
  
  //turn off trigger 
  Boolean machParent = false;
  try{
	  Map<String, Trigger_Turn_Off__c > Trigger_Turn_Off = Trigger_Turn_Off__c.getAll();
	  if(Trigger_Turn_Off != null && !Trigger_Turn_Off.isEmpty() && Trigger_Turn_Off.containsKey('machParent') && Trigger_Turn_Off.get('machParent').Trigger_Name__c == 'Account_Trigger' && !Test.isRunningTest()){
		machParent = true;
	  }
  }catch(Exception e){system.debug('Error Cause='+ e.getCause() + ' Trace= ' + e.getStackTraceString() + ' Line NUmber= ' +e.getLineNumber() + ' Type is= ' + e.getTypeName() + ' Msg is= ' + e.getMessage() );}
// ------------------------------------------------------------------------
    //  ---------------------------- BEFORE EVENTS -----------------------------
    // ------------------------------------------------------------------------
  
	if (Trigger.isBefore && Trigger.isInsert) // Before Insert
    {        
	         System.debug('machParent=='+machParent);
			//mach Parent Account by Callig Flow SW-28689
			   if(!machParent)
				 Handler.machParent(trigger.new, trigger.oldMap, trigger.newMap);
    }
    else if (Trigger.isBefore && Trigger.isUpdate) // Before Update
    {
		//mach Parent Account by Callig Flow SW-28689
			   if(!machParent)
				Handler.machParent(trigger.new, trigger.oldMap, trigger.newMap);
    }  /*
    else if (Trigger.isBefore && Trigger.isDelete) // Before Delete
    {
    }*/
  // ------------------------------------------------------------------------
  //  ---------------------------- AFTER EVENTS -----------------------------
  // ------------------------------------------------------------------------
  /**
   else if (Trigger.isAfter && Trigger.isInsert) // After Insert
   {
   }
   else if (Trigger.isAfter && Trigger.isUpdate) // After Update
   {
       Handler.updateRelCnt(trigger.new, trigger.oldMap);
   }
  /* else if (Trigger.isAfter && Trigger.isDelete) // After Delete
   {
   }
   else if (Trigger.isAfter && Trigger.isUnDelete) // After UnDelete
   {
   }*/
}

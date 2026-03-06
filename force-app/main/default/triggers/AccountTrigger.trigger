trigger AccountTrigger on Account(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  Boolean machParent = false;
  Map<String, Trigger_Turn_Off__c> Trigger_Turn_Off = Trigger_Turn_Off__c.getAll();
  if (
    Trigger_Turn_Off != null &&
    !Trigger_Turn_Off.isEmpty() &&
    Trigger_Turn_Off.containsKey('machParent') &&
    Trigger_Turn_Off.get('machParent').Trigger_Name__c == 'Account_Trigger' &&
    !Test.isRunningTest()
  ) {
    machParent = true;
  } //MIS-4690

  TR_Acc_BusinessUnitCalc businessUnitCalc = new TR_Acc_BusinessUnitCalc();
  AccountTriggerHandler handler = new AccountTriggerHandler();
  if (Trigger.isBefore && Trigger.isUpdate) {
    //TR_Acc_BusinessUnitCalc businessUnitCalc = new TR_Acc_BusinessUnitCalc();
    businessUnitCalc.handle(Trigger.new, Trigger.oldMap);
    //Added 2021-06-06 by Itzik Winograd. Keep account Team on account Owner Chnage
    //        KeepAccountTeamMembers katm = new KeepAccountTeamMembers();
    //        katm.handle(Trigger.new, Trigger.oldMap);
    AccountTriggerHandlerLght.setISO3(
      Trigger.new,
      (Map<Id, Account>) Trigger.oldMap
    );
    if (!machParent) {
      handler.machParent(Trigger.new, Trigger.oldMap, Trigger.newMap); // MIS-4690
    }
  }

  if (Trigger.isAfter && Trigger.isUpdate) {
    //        ClcAccountTriggerHandler.processAccountCLC((List<Account>)Trigger.new, (Map<Id, Account>)Trigger.oldMap);
    //        AccountTriggerHandlerLght.changeContactOwnerAndKeepAccountTeamMember((Map<Id, Account>)Trigger.newMap, (Map<Id, Account>)Trigger.oldMap);

    if (!System.isBatch()) {
      handler.updateMarketingPersona(Trigger.newMap, Trigger.oldMap); //MIS-4768
      handler.updateStrategicPodOnContacts(Trigger.newMap, Trigger.oldMap);
      handler.handleClosedOppOwnerRevert(Trigger.newMap, Trigger.oldMap);
    }
  }

  if (Trigger.isBefore && Trigger.isInsert) {
    //Added 2021-01-18: Calculate the business unit on account creation
    businessUnitCalc.handle(Trigger.new, null);
    AccountTriggerHandlerLght.setISO3(
      Trigger.new,
      (Map<Id, Account>) Trigger.oldMap
    );
    if (!machParent) {
      handler.machParent(Trigger.new, Trigger.oldMap, Trigger.newMap);
    } //MIS-4690
    //        List<Account> recurlyAccountList = new List<Account>();
    //        for (Account a : trigger.new)
    //        {
    //            if (a.recurly__Account_Code__c!=null)
    //            {
    //                recurlyAccountList.add (a);
    //            }
    //        }
    //
    //        if(!recurlyAccountList.isEmpty()){
    //            AccountTriggerHelperTEMP.RecurlyAccountAllocation(recurlyAccountList);
    //        }//MIS-4690
  }

}

trigger TaskTrigger on Task(
  after delete,
  after insert,
  after undelete,
  after update,
  before delete,
  before insert,
  before update
) {
  if (Trigger.isBefore && Trigger.isInsert) {
    List<Id> userIds = new List<Id>();
    Map<Id, List<Task>> userToTask = new Map<Id, List<Task>>();
    for (sObject sObj_i : Trigger.new) {
      Task task = (Task) sObj_i;
      if (String.isNotBlank(task.OwnerId)) {
        if (userToTask.containsKey(task.OwnerId)) {
          List<Task> tasks = userToTask.get(task.OwnerId);
          tasks.add(task);
          userToTask.put(task.OwnerId, tasks);
        } else {
          List<Task> tasks = new List<Task>();
          tasks.add(task);
          userToTask.put(task.OwnerId, tasks);
        }
        userIds.add(task.OwnerId);
      }
    }
    for (User user : [
      SELECT Manager.Email
      FROM User
      WHERE Id IN :userToTask.keySet()
    ]) {
      if (userToTask.containsKey(user.Id)) {
        for (Task task : userToTask.get(user.Id)) {
          task.Manager_Email__c = user.Manager.Email;
        }
      }
    }
  }

  /* map <string,CSTriggerControl__c> cstrigControl = CSTriggerControl__c.getall();
    if (!cstrigControl.ContainsKey ('Task') || (cstrigControl.ContainsKey('Task') && cstrigControl.get('Task').on__c))
    {
        if (trigger.IsAfter)
        {                       // AFTER - START
            if (trigger.isInsert)
            {                       // INSERT - START
                System.debug('task insert');
                TaskTriggerHandler.HandleAFTER (trigger.new, null);
                System.debug('CPU TIME ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime());
            }                       // INSERT - END
            
            if (trigger.isUpdate)
            {                       // Update - START
                System.debug('task update');
                TaskTriggerHandler.HandleAFTER (trigger.new, trigger.oldmap);
                System.debug('CPU TIME ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime());
            }                       // Update - END
            
            if (trigger.IsDelete)
            {                       // Delete - START
                TaskTriggerHandler.HandleAFTER (trigger.old, null);
            }                       // Delete - END
            
            if (trigger.IsUndelete)
            {                       // Undelete - START
                TaskTriggerHandler.HandleAFTER (trigger.new, null);
            }                       // Undelete - END
            
            
            
            
        }                       // AFTER - END
    }
*/

}

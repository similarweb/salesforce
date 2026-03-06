public class TaskTriggerHandler {
	
	public static map <id,Task> oldmap = new map <id,Task>();
	
	public static map <id,Task> taskmap = new map <id,Task>();
	public static map <id,Contact> ContactMap = new map <id,Contact>();
	
	public static map <id, Task[]> ContactTaskMap = new map <id,Task[]>();
	
	public static void BuildData (list <Task> TaskList)
	{
		list <id> ContactIDs = new list <id>();
		
		for (Task t : taskList)
		{
            System.debug('task ' + t);
			taskmap.put (t.id,t);
			if (t.whoid!=null && string.valueof(t.whoid).startswith('003')) ContactIDs.add (t.whoid);
			if (oldmap!=null && oldmap.get(t.id).whoid!=null && t.whoid!=null &&
			t.whoid!=oldmap.get(t.id).whoid && string.valueof(oldmap.get(t.id).whoid).startswith('003')
			)
			ContactIDs.add (oldmap.get(t.id).whoid);	
		}
		
		if (ContactIDs.size()>0)
		{
			list <Task> newTaskList = [select id,IsClosed,OwnerId,WhoId from Task where WhoId=:ContactIDs];
			for (id cid : ContactIDs)
			{
				list <Task> templist = new list <Task>();
				if (newTaskList.size()>0)for (Task t : newTaskList)
				{
					if (t.whoid!=null && t.whoid==cid) templist.add (t);
				}
				ContactTaskMap.put (cid,templist);
			}
		}
	}
	
	public static void UpdateContactTaskStatus ()
	{
		if (ContactTaskMap.size()>0)
		{
			list <Contact> Contact4Update = new list <Contact>();
			for (id cid : ContactTaskMap.keySet())
			{
				Contact c = new Contact (id=cid);
				c.Closed_Tasks_Counter__c = 0;
				c.Open_Tasks_Counter__c = 0;
				list <Task> templist = ContactTaskMap.get (cid);
				if (templist.size()>0) for (Task t : templist)
				{
					if (t.IsClosed) c.Closed_Tasks_Counter__c +=1;
					else c.Open_Tasks_Counter__c  +=1;
				}
				Contact4Update.add (c);
			}
			update Contact4Update;  
		}
	}
	
	public static void HandleAFTER (list <Task> TaskList, map <id,Task> oldtriggermap) // **** THIS IS THE MAIN AFTER METHOD ***
	{
        oldmap = oldtriggermap;
        System.debug('task here 1');
        System.debug('CcPU TIME ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime());
		BuildData(TaskList);
        System.debug('task here 2');
        System.debug('CcPU TIME ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime());
		UpdateContactTaskStatus();
		System.debug('task here 3');
        System.debug('CcPU TIME ' + Limits.getCpuTime() + ' of ' + Limits.getLimitCpuTime());
		
	}

}
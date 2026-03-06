public without sharing class SubscriptionProductNChargeHandler {
	
	public static map <id,Zuora__SubscriptionProductCharge__c> oldmap = new map <id,Zuora__SubscriptionProductCharge__c>();
	public static map <id,Account> AccMap = new map <id,Account>();
	
	public static void GenData (list <Zuora__SubscriptionProductCharge__c> zslist, string event)
	{
		list <id> tempidlist = new list <id>();
		if (zslist.size()>0) for (Zuora__SubscriptionProductCharge__c zi : zslist)
		{
			if (zi.Zuora__Account__c!=null) tempidlist.add (zi.Zuora__Account__c);
		}
		if (tempidlist.size()>0)
		{
			list <Account> tempalist= [select id, ownerid,owner.isactive from Account where id=:tempidlist];
			AccMap.putall (tempalist);
		}
	}
	
	public static void CalcOwner (list <Zuora__SubscriptionProductCharge__c> zslist, string event)
	{
		if (event=='Insert') for (Zuora__SubscriptionProductCharge__c zi : zslist)
		{
			if (zi.Zuora__Account__c!=null && AccMap.ContainsKey (zi.Zuora__Account__c) && AccMap.get (zi.Zuora__Account__c).owner.isactive)
			{
				zi.ownerid = accmap.get (zi.Zuora__Account__c).ownerid;
			} 
		}
	}
	
	public static void HandleBEFORE (list <Zuora__SubscriptionProductCharge__c> zslist, map <id,Zuora__SubscriptionProductCharge__c> OldTriggerMap, string event)
	{
		if (OldTriggerMap!=null) oldmap = oldtriggermap;
		GenData (zslist,event);
		CalcOwner (zslist,event);
	}


}
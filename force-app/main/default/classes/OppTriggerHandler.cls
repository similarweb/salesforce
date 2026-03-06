public class OppTriggerHandler {
	
	public static map <id, Opportunity> OppMap = new map <id,Opportunity>();
	public static map <id, Opportunity> OldMap = new map <id,Opportunity>();
	
	public static map <id, Account> AccountMap = new map <id,Account>();
	
	public static map <id, CampaignMember> Camp4Acc = new map <id,CampaignMember>(); // map account id to campaign Member
	
	static public boolean CodeOff = false;
	
	
	public static void GenData (list <Opportunity> OppList)
	{
		list <id> AccIDList = new list <Id>();
		for (Opportunity o : OppList) if (o.accountid!=null) AccIDList.add (o.accountid);
		
		if (AccIDList.size()>0)
		{
			list <Account> TempAcList = new list <Account>();
			TempAcList = [select id,
						  (select id, accountid
						  from Contacts)
						 from Account where id=:AccIDList
						 ];
						 
			 if (TempAcList.size()>0)
			 {
			 	list <id> tempCId = new list <id>();
			 	for (Account a : tempAcList)
			 	{
			 		AccountMap.put (a.id,a);
				 	if (a.Contacts.size()>0) for (Contact c : a.Contacts) tempCId.add (c.id);
				 	
				 	if (tempCid.size()>0)
				 	{
				 		list <CampaignMember> CMList = [select id,campaignId,contactid,contact.Accountid ,
				 										createddate
				 										from CampaignMember where contactid=:tempCid 
			 											order by createddate desc];
				 										
				 		if (CMList.size()>0) for (CampaignMember cm : CMList)
				 		{
				 			if (cm.contactid!=null && cm.contact.accountid!=null &&
				 				Camp4Acc.ContainsKey (cm.contact.Accountid))
				 			{
				 				CampaignMember ncm = Camp4Acc.get (cm.contact.accountid);
				 				if (cm.createddate>ncm.createddate)
				 				{
				 					Camp4Acc.put (cm.contact.accountid,cm);	
				 				}
				 			}
				 		}
				 	}
			 	}
			 }
		}
	}
	
	public static void SetPrimaryCampaign (Opportunity o)
	{
		if (o.accountid!=null && Camp4Acc.ContainsKey(o.accountid) ) o.campaignId = Camp4Acc.get(o.accountid).campaignid;
	}
	
	//******************** THIS IS THE MAIN BEFORE METHOD ********************
	public static void HandleBefore (list <Opportunity> OppList, map <id,Opportunity> OldTriggerMap, string event)
	{
		GenData(OppList);
		if (event=='Insert')
		{
			for (Opportunity o : OppList)
			{
				SetPrimaryCampaign (o);
			}
		}
	}

}
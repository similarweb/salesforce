public class ExtendMemberStatusesTriggerHandler {
    public static void ExtendMemberStatuses(List<Campaign> insertedCampaigns){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = CampaignMember.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.isActive()){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } 
        
        Set<Id> campIds = (new Map<Id,Campaign>(insertedCampaigns)).keySet();
        List<CampaignMemberStatus> existedStatuses = [SELECT Label from CampaignMemberStatus WHERE CampaignId=:campIds]; 
        List<String> labelValues = new List<String>();
        for(CampaignMemberStatus campMembStatus: existedStatuses){
        	labelValues.add(campMembStatus.Label);
        }
        List<CampaignMemberStatus> memberStatuses = new List<CampaignMemberStatus>();
        
        
        for(Campaign camp : insertedCampaigns){
            for(String plVal: pickListValuesList){
                if(!labelValues.contains(plVal)){
                    if(plVal=='Attended'||plVal=='Watched on Demand'||plVal=='Responded'){
                        memberStatuses.add(new CampaignMemberStatus(CampaignId=camp.Id, Label=plVal,HasResponded=true));
                    } else {
                    	memberStatuses.add(new CampaignMemberStatus(CampaignId=camp.Id, Label=plVal));
                    }
            	}
            }
        }
        if (!Test.isRunningTest()) {
            upsert memberStatuses;
        }
    }
}
/*
 * @Author: ZedXagE 
 * @Date: 2019-02-28 16:19:37 
 * @Last Modified by:   ZedXagE 
 * @Last Modified time: 2019-02-28 16:19:37 
 */

trigger ZCampaignClosed on Campaign (before insert,before update,after update) {
    if(Trigger.isAfter&&Trigger.isUpdate){
        Set <String> campClosed = new Set <String>();
        for(Campaign camp:Trigger.New)
            if(camp.Status=='Completed'&&Trigger.OldMap.get(camp.id).Status!='Completed'&&camp.Type=='Webinar')
                campClosed.add(camp.id);
        List <CampaignMember> mems4up = [select id,Status from CampaignMember where CampaignId in: campClosed and Status='Registered'];
        for(CampaignMember mem:mems4up) mem.Status = 'No Show';
        update mems4up;
    }
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            for(Campaign camp:Trigger.New)
                camp.Clean_Name__c = ZCampaignAutomation.getCleanName(camp.Name);
        }
        else{
            for(Campaign camp:Trigger.New)
                if(camp.Name!=Trigger.Oldmap.get(camp.id).Name||camp.Clean_Name__c==null)
                    camp.Clean_Name__c = ZCampaignAutomation.getCleanName(camp.Name);
        }
    }
}
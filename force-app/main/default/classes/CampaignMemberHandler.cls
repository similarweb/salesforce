/**
 * Created by Alon.Shalev on 11/19/2023.
 */

public with sharing class CampaignMemberHandler {

    public void createHistoryRecords(List<CampaignMember> newList , Map<Id,CampaignMember> oldMap){
        List<Campaign_Member_History_Tracking__c> campaignMemberHistoryTrackingList = new List<Campaign_Member_History_Tracking__c>();
        String eventType = oldMap == null ? 'Created' : 'Updated';
        List<Schema.SObjectField> campaignMemberFields = CampaignMember.SObjectType.getDescribe().fields.getMap().values();
        for(CampaignMember campaignMember : newList){
            for (Schema.SObjectField field : campaignMemberFields) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if(fieldDescribe.isCustom()){
                    String fieldName = fieldDescribe.getName();
                    if(oldMap == null){
                        if(campaignMember.get(fieldName) != null){
                            campaignMemberHistoryTrackingList.add(createHistory(campaignMember.get(fieldName),null,fieldName,eventType,campaignMember));
                        }
                    }else if(campaignMember.get(fieldName) != oldMap.get(campaignMember.Id).get(fieldName)){
                        campaignMemberHistoryTrackingList.add(createHistory(campaignMember.get(fieldName),oldMap.get(campaignMember.Id).get(fieldName),fieldName,eventType,campaignMember));

                    }

                }

            }
        }
        insert campaignMemberHistoryTrackingList;
    }
    private Campaign_Member_History_Tracking__c createHistory(Object changedValue , Object originalVale , String fieldName , String eventType , CampaignMember campaignMember){
        System.debug('changedValue--'+changedValue);

        Campaign_Member_History_Tracking__c trackingItem = new Campaign_Member_History_Tracking__c();
        trackingItem.Changed_value__c = cutStringToLength(String.valueOf(changedValue), 255);
        trackingItem.Original_Value__c = cutStringToLength(String.valueOf(originalVale), 255);
        trackingItem.Changed_Field__c = cutStringToLength(fieldName, 50);
        trackingItem.Event_Type__c = eventType;
        trackingItem.Campaign_Member_Id__c = campaignMember.Id;
        trackingItem.Email__c = campaignMember.Email;
        trackingItem.Campaign__c = campaignMember.CampaignId;

        return trackingItem;
    }

	private String cutStringToLength(String str, Integer length) {
		if (str != null && str.length() > length) {
			str = str.substring(0, length);
		}

		return str;
	}
}
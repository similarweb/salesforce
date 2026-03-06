/**
 * Created by Alon.Shalev on 10/20/2024.
 */

public with sharing class MqlScoreCtrl {
  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getRecordData(
    String recordId,
    String sObjectType
  ) {
    String query = 'SELECT Id, mql_status__c, First_MQL_Date__c, First_Owner_Assigned_Timestamp__c';
    query += ' FROM  ' + sObjectType;
    query += ' WHERE Id = : recordId';
    SObject objRecord = Database.query(query);

    Map<String, Object> result = new Map<String, Object>();
    result.put('mql_status', objRecord.get('mql_status__c'));
    result.put('firstMQLDate', objRecord.get('First_MQL_Date__c'));
    result.put(
      'firstOwnerTimestamp',
      objRecord.get('First_Owner_Assigned_Timestamp__c')
    );
    return result;
  }

  @AuraEnabled(cacheable=true)
  public static Map<String, Object> getMQLScoreTableInfoFromApex(
    String recordId,
    String sObjectType
  ) {
    System.debug('started getMQLScoreTableInfoFromApex');
    Map<String, Object> resultObj = new Map<String, Object>();
    try {
      String query =
        'SELECT BI_Data__r.Mrkt_Industries_Searched__c,' +
        'BI_Data__r.intent_num_of_package_page_visits__c,' +
        'BI_Data__r.Intent_Num_of_Keyword_Lists__c,' +
        'BI_Data__r.Intent_Minisite_Section_Visits__c,' +
        'BI_Data__r.Intent_Trial_Section_and_Sub__c,' +
        'BI_Data__r.Intent_Log_Ins__c,' +
        'BI_Data__r.intent_num_of_pro_actions__c,' +
        'BI_Data__r.Intent_Pricing_Visits_Dates__c,' +
        'BI_Data__r.Mrkt_Pro_Hook_Clicked__c,' +
        'BI_Data__r.Mrkt_Pro_Hook_Clicked_Dates__c,' +
        'BI_Data__r.intent_num_of_handraises__c,' +
        'BI_Data__r.Mrkt_Premium_Features_Dates__c,' +
        'BI_Data__r.intent_num_of_minisites_visits__c,' +
        'BI_Data__r.intent_num_of_dashboards__c,' +
        'BI_Data__r.intent_num_of_png_downloads__c,' +
        'BI_Data__r.intent_num_of_pdf_downloads__c,' +
        'BI_Data__r.intent_num_of_invite_users__c,' +
        'BI_Data__r.Mrkt_Last_3_Compare_Websites__c,' +
        'BI_Data__r.Intent_Num_of_SI_Advanced_Searches__c,' +
        'BI_Data__r.Intent_Num_of_SI_Company_Overview_Signal__c,' +
        'BI_Data__r.Intent_Num_of_SI_Sales_Signal__c,' +
        'BI_Data__r.Intent_Num_of_SI_Saved_Searches__c,' +
        'BI_Data__r.Mrkt_Last_3_Keyword_List__c';
      query += ' FROM  ' + sObjectType;
      query += ' WHERE Id = : recordId';
      SObject objRecord = Database.query(query);
      BI_Data__c biData = (BI_Data__c) objRecord.getSObject('Bi_Data__r');
      String queryForCampMember = 'SELECT Id,CreatedDate,Status,Campaign_Name__c,Campaign.Asset_Type2__c,Campaign.Type ';
      queryForCampMember += 'FROM CampaignMember ';
      queryForCampMember += sObjectType == 'Contact'
        ? 'WHERE ContactId = :recordId '
        : 'WHERE LeadId = : recordId ';
      List<CampaignMember> campaignMemberList = Database.query(
        queryForCampMember
      );

      resultObj.put('biData', biData);
      resultObj.put(
        'campaignMembers',
        campaignMemberList.isEmpty()
          ? new List<CampaignMember>()
          : filterCampaignMembers(campaignMemberList)
      );
      resultObj.put('isSuccess', true);
    } catch (Exception ex) {
      resultObj.put('isSuccess', false);
      resultObj.put('exception', ex.getMessage());
    }
    return resultObj;
  }

  private static List<CampaignMember> filterCampaignMembers(
    List<CampaignMember> originalCampaignMemberList
  ) {
    List<CampaignMember> campaignMembersAfterFilter = new List<CampaignMember>();
    Set<String> typeWithNoRestrictionsSet = new Set<String>{
      'Content',
      'Webinar'
    };
    Set<String> statusOfEmailCampaignAllowed = new Set<String>{
      'Responded',
      'Clicked'
    };
    for (CampaignMember campaignMember : originalCampaignMemberList) {
      if (typeWithNoRestrictionsSet.contains(campaignMember.Campaign.Type)) {
        campaignMembersAfterFilter.add(campaignMember);
      } else if (
        campaignMember.Campaign.Type == 'Email' &&
        statusOfEmailCampaignAllowed.contains(campaignMember.Status)
      ) {
        campaignMembersAfterFilter.add(campaignMember);
      } else if (
        campaignMember.Campaign.Type == 'Event' &&
        campaignMember.Campaign.Asset_Type2__c != 'Event - Owned'
      ) {
        campaignMembersAfterFilter.add(campaignMember);
      }
    }
    return campaignMembersAfterFilter;
  }
}

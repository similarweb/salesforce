public with sharing class CampaignBatchable implements Database.Batchable<SObject> {
  private Set<String> campaignIds;
  private List<Log_Event__e> logEventsList = new List<Log_Event__e>();

  public CampaignBatchable(Set<String> campaignIds) {
    this.campaignIds = campaignIds;
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(
      [
        SELECT
          Id,
          Description,
          LeadId,
          ContactId,
          Campaign.Description,
          Campaign.Solution__c,
          Campaign.Type,
          Lead.Status,
          Lead.IsConverted,
          CampaignId,
          Campaign_Description__c
        FROM CampaignMember
        WHERE CampaignId IN :this.campaignIds
      ]
    );
  }

  public void execute(Database.BatchableContext bc, List<SObject> scope) {
    List<CampaignMember> members = (List<CampaignMember>) scope;
    List<Lead> updatedLeads = new List<Lead>();
    List<Contact> updatedContacts = new List<Contact>();
    Set<String> scopeCampaignIds = new Set<String>();

    for (CampaignMember m : members) {
      String description = m.Campaign.Description,
        solution = m.Campaign.Solution__c,
        type = m.Campaign.Type;
      scopeCampaignIds.add(m.CampaignId);
      m.Campaign_Description__c = description;

      if (m.LeadId != null && !m.Lead.IsConverted) {
        updatedLeads.add(
          new Lead(
            Id = m.LeadId,
            Campaign_Description__c = description,
            Campaign_Solution__c = solution,
            Campaign_Type__c = type
          )
        );
      }
      if (m.ContactId != null) {
        updatedContacts.add(
          new Contact(
            Id = m.ContactId,
            Campaign_Description__c = description,
            Campaign_Solution__c = solution,
            Campaign_Type__c = type
          )
        );
      }
    }

    List<Campaign> campaignsToUpdate = new List<Campaign>();
    for (String cId : scopeCampaignIds) {
      campaignsToUpdate.add(
        new Campaign(Id = cId, Update_Campaign_Members__c = false)
      );
    }

    try {
      update members;
      update campaignsToUpdate;
      if (!updatedLeads.isEmpty()) {
        update updatedLeads;
      }
      if (!updatedContacts.isEmpty()) {
        update updatedContacts;
      }
    } catch (Exception e) {
      logEventsList.add(
        LogEventUtils.createLogEventRecord(
          members,
          'CampaignBatchable',
          'execute',
          JSON.serialize(members),
          e.getMessage(),
          'Error',
          null,
          null
        )
      );
    }

    if (!logEventsList.isEmpty()) {
      Eventbus.publish(logEventsList);
    }
  }

  public void finish(Database.BatchableContext bc) {
  }
}

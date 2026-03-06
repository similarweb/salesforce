public with sharing class affectlayerEngagementTriggerHandler {
  static Map<Id, Opportunity> oppByIdMap = new Map<Id, Opportunity>();
  public affectlayerEngagementTriggerHandler() {
  }

  public static void handleAfterInsert(
    List<affectlayer__Engagement__c> newEngagements
  ) {
    List<affectlayer__Engagement__c> qualifiedEngagements = getQualifiedEngagements(
      newEngagements
    );

    if (!qualifiedEngagements.isEmpty()) {
      publishChorusDataEvent(qualifiedEngagements);
    }
  }

  private static List<affectlayer__Engagement__c> getQualifiedEngagements(
    List<affectlayer__Engagement__c> engagements
  ) {
    List<affectlayer__Engagement__c> basicFiltered = new List<affectlayer__Engagement__c>();
    Set<Id> opportunityIds = new Set<Id>();

    for (affectlayer__Engagement__c engagement : engagements) {
      Boolean validDisposition =
        engagement.affectlayer__Disposition__c == 'Show' ||
        engagement.affectlayer__Disposition__c == 'Connected';
      Boolean hasOpportunity = engagement.affectlayer__Opportunity__c != null;

      if (validDisposition && hasOpportunity) {
        basicFiltered.add(engagement);
        opportunityIds.add(engagement.affectlayer__Opportunity__c);
      }
    }

    if (basicFiltered.isEmpty()) {
      return new List<affectlayer__Engagement__c>();
    }

    return filterByOpportunityType(basicFiltered, opportunityIds);
  }

  private static List<affectlayer__Engagement__c> filterByOpportunityType(
    List<affectlayer__Engagement__c> engagements,
    Set<Id> opportunityIds
  ) {
    for (Opportunity opp : [
      SELECT
        Id,
        Type,
        Champion_AI__c,
        Decision_Criteria_Competition_AI__c,
        Decision_Process_AI__c,
        Economic_Buyer_AI__c,
        Identify_Pain_AI__c,
        Metrics_AI__c,
        Paper_Process_AI__c,
        AI_Json_Payload__c,
        Probability,
        CloseDate,
        CreatedDate
      FROM Opportunity
      WHERE Id IN :opportunityIds
      ORDER BY CreatedDate DESC
    ]) {
      oppByIdMap.put(opp.Id, opp);
    }

    List<affectlayer__Engagement__c> qualified = new List<affectlayer__Engagement__c>();
    for (affectlayer__Engagement__c engagement : engagements) {
      Opportunity opp = oppByIdMap.get(engagement.affectlayer__Opportunity__c);
      if (
        opp != null &&
        (opp.Type == 'New Sale' ||
        opp.Type == 'Upsell') &&
        (opp.Probability == 10 ||
        opp.Probability == 25 ||
        opp.Probability == 50 ||
        opp.Probability == 60 ||
        opp.Probability == 80) &&
        opp.CloseDate > Date.today()
      ) {
        // Add opportunity data to engagement for event publishing
        //engagement.affectlayer__Opportunity__r = opp;
        // engagement.affectlayer__Opportunity__r.Champion_AI__c = opp.Champion_AI__c;
        // engagement.affectlayer__Opportunity__r.Decision_Criteria_Competition_AI__c = opp.Decision_Criteria_Competition_AI__c;
        // engagement.affectlayer__Opportunity__r.Decision_Process_AI__c = opp.Decision_Process_AI__c;
        // engagement.affectlayer__Opportunity__r.Economic_Buyer_AI__c = opp.Economic_Buyer_AI__c;
        // engagement.affectlayer__Opportunity__r.Identify_Pain_AI__c = opp.Identify_Pain_AI__c;
        // engagement.affectlayer__Opportunity__r.Metrics_AI__c = opp.Metrics_AI__c;
        // engagement.affectlayer__Opportunity__r.Paper_Process_AI__c = opp.Paper_Process_AI__c;
        // engagement.affectlayer__Opportunity__r.AI_Json_Payload__c = opp.AI_Json_Payload__c;
        qualified.add(engagement);
      }
    }
    system.debug(oppByIdMap);
    return qualified;
  }

  private static void publishChorusDataEvent(
    List<affectlayer__Engagement__c> engagements
  ) {
    List<Chorus_Data_Event__e> events = new List<Chorus_Data_Event__e>();

    for (affectlayer__Engagement__c engagement : engagements) {
      Chorus_Data_Event__e event = new Chorus_Data_Event__e();
      event.Engagement_Id__c = engagement.Id;
      event.Chorus_Id__c = engagement.affectlayer__ChorusId__c;
      event.Account_Id__c = engagement.affectlayer__Account__c;
      if (engagement.affectlayer__Opportunity__c != null) {
        event.Opportunity_Id__c = engagement.affectlayer__Opportunity__c;
        event.Champion_AI__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.Champion_AI__c;
        event.Decision_Criteria_Competition_AI__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.Decision_Criteria_Competition_AI__c;
        event.Decision_Process_AI__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.Decision_Process_AI__c;
        event.Economic_Buyer_AI__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.Economic_Buyer_AI__c;
        event.Identify_Pain_AI__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.Identify_Pain_AI__c;
        event.Metrics_AI__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.Metrics_AI__c;
        event.Paper_Process_AI__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.Paper_Process_AI__c;
        event.AI_JSON_Payload__c = oppByIdMap.get(
            engagement.affectlayer__Opportunity__c
          )
          ?.AI_Json_Payload__c;
      }
      events.add(event);
    }
    system.debug('events: ' + events);
    List<Database.SaveResult> results = EventBus.publish(events);

    for (Integer i = 0; i < results.size(); i++) {
      if (!results[i].isSuccess()) {
        System.debug(
          'Failed to publish event for engagement: ' + engagements[i].Id
        );
        for (Database.Error error : results[i].getErrors()) {
          System.debug('Error: ' + error.getMessage());
        }
      }
    }
  }
}

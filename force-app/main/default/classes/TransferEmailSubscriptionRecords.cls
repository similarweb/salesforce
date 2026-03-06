/**
 * @author Itzik Winograd
 * @date 21/07/2021
 * @description On Lead convert, Move the Email_Subscription__c records to the created contact.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */

public class TransferEmailSubscriptionRecords {
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();

  /**
   * @author Itzik Winograd
   * @date 21/07/2021
   * @description: description.
   * @param List<SObject> newList
   * @param Map<Id,SObject> oldMap
   * @return void.
   */
  public void handle(List<SObject> newList, Map<Id, SObject> oldMap) {
    List<Email_Subscription__c> emailSubscriptionsToUpdate = filterAndGetEmailSubscription(
      newList
    );
    if (!emailSubscriptionsToUpdate.isEmpty()) {
      List<Database.SaveResult> resultsList = Database.update(
        emailSubscriptionsToUpdate,
        false
      );
      for (Integer i = 0; i < resultsList.size(); i++) {
        Database.SaveResult result = resultsList[i];
        if (!result.isSuccess()) {
          logEvents.add(
            LogEventUtils.createLogEventRecord(
              new List<String>{ emailSubscriptionsToUpdate[i].Id },
              'ConvertEmailSubscriptionRecords',
              'handle',
              JSON.serialize(emailSubscriptionsToUpdate[i]),
              result.getErrors().toString(),
              'Error'
            )
          );
        }
      }
    }
    if (!logEvents.isEmpty()) {
      EventBus.publish(logEvents);
    }
  }

  /**
   * @author Itzik Winograd
   * @date 21/07/2021
   * @description: filter converted leads, get the converted leads Ids and returns lis of updated Email_Subscription__c
   * @param List<SObject> newList
   * @return List<Email_Subscription__c>
   */
  public List<Email_Subscription__c> filterAndGetEmailSubscription(
    List<SObject> newList
  ) {
    Map<Id, SObject> leadIdsToContactsMap = getParentsIdsList(newList);
    List<Email_Subscription__c> emailSubscriptionsToUpdate = getEmailSubscriptionMap(
      leadIdsToContactsMap
    );
    System.debug(
      '### emailSubscriptionsToUpdate: ' + emailSubscriptionsToUpdate
    );
    return emailSubscriptionsToUpdate;
  }

  /**
   * @author Itzik Winograd
   * @date 21/07/2021
   * @description: returns a Map <LeadId, SObject> of the Lead Ids from converted contacts.
   * @param List<SObject> newList
   * @return Map<Id,SObject> Ids of leads
   */
  public Map<Id, SObject> getParentsIdsList(List<SObject> newList) {
    Map<Id, SObject> leadIdsToContactsMap = new Map<Id, SObject>();
    for (SObject sobj : newList) {
      if (sobj.get('Converted_Lead_ID__c') != null) {
        leadIdsToContactsMap.put((Id) sobj.get('Converted_Lead_ID__c'), sobj);
      }
    }
    return leadIdsToContactsMap;
  }

  /**
   * @author Itzik Winograd
   * @date 21/07/2021
   * @description: get a map of leadId,Contact and queries the Email_Subscription__c for the lead's related records.
   * if found, it will create an update Email_Subscription__c list to return, null otherwise.
   * @param Map<Id,SObject> Map of LeadId
   * @return List<Email_Subscription__c>
   */
  public List<Email_Subscription__c> getEmailSubscriptionMap(
    Map<Id, SObject> leadIdsToContactsMap
  ) {
    List<Email_Subscription__c> emailSubscriptionsList = new List<Email_Subscription__c>();
    Email_Subscription__c updatedEMSub;
    for (Email_Subscription__c emsn : [
      SELECT Id, Contact__c, Lead__c
      FROM Email_Subscription__c
      WHERE Lead__c IN :leadIdsToContactsMap.keySet()
    ]) {
      updatedEMSub = new Email_Subscription__c(
        Id = emsn.Id,
        Contact__c = (Id) leadIdsToContactsMap.get(emsn.Lead__c).get('Id')
      );
      emailSubscriptionsList.add(updatedEMSub);
    }
    return emailSubscriptionsList;
  }
}

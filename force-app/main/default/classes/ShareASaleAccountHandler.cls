/**
 * @author Itzik Winograd
 * @date 01/06/2021
 * @description Handler class for filtering and publishing ShareASale account-related calls.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public with sharing class ShareASaleAccountHandler {
  private List<Log_Event__e> logs = new List<Log_Event__e>();
  /**
   * @author Itzik Winograd
   * @date 01/06/2021
   * @description Filter the relevant accounts, then find the contacts
   * and send a reference call to shareasale with their values.
   * @param List<sObject> triggerNew
   * @param Map<Id, sObject> triggerOldMap
   * @return Void.
   */
  public void handle(List<sObject> triggerNew, Map<Id, sObject> triggerOldMap) {
    System.debug('### in ShareASaleAccountHandler');
    List<Id> accountIds = filter(triggerNew, triggerOldMap);
    Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();
    for (Contact con : [
      SELECT
        Id,
        Affiliate_Id__c,
        Order_Number__c,
        ShareASale_Retries_Counter__c,
        CreatedDate,
        AccountId
      FROM Contact
      WHERE
        AccountId IN :accountIds
        AND Affiliate_Id__c != NULL
        AND Affiliate_Id__c != 'organic'
        AND Order_Number__c != NULL
        AND (Pro_User_Type__c = 'Admin'
        OR Pro_User_Type__c = 'User')
    ]) {
      if (accountIdToContact.containsKey(con.AccountId)) {
        logs.add(
          LogEventUtils.createLogEventRecord(
            new List<String>{ con.Id },
            'ShareASaleAccountHandler',
            'setShareASaleReferenceCall',
            '',
            'More than one matching contact was found for Account Id: ' +
            con.AccountId,
            'error'
          )
        );
      }
      accountIdToContact.put(con.AccountId, con);
    }
    if (accountIdToContact.values().size() > 0) {
      System.debug(
        '### ShareASaleAccountHandler accountIdToContact: ' +
        accountIdToContact.values()
      );
      System.enqueueJob(
        new ShareASaleQuauableCalls(accountIdToContact.values(), 'reference')
      ); //this class will always send 'new' transaction to shareasale
    }
    if (logs.size() > 0) {
      Eventbus.publish(logs);
    }
  }

  /**
   * @author Itzik Winograd
   * @date 01/06/2021
   * @description Filter No_Touch_Account__c==true and No_Touch_Status__c changed to 'After Trial, Success'
   * @param List<sObject> triggerNew
   * @param Map<Id, sObject> triggerOldMap
   * @return List<Id> list of filtered account Ids
   */

  public static List<Id> filter(
    List<sObject> triggerNew,
    Map<Id, sObject> triggerOldMap
  ) {
    List<Id> accountIds = new List<Id>();
    for (SObject acc : triggerNew) {
      if (
        acc.get('No_Touch_Account__c') == true &&
        acc.get('No_Touch_Status__c') == 'After Trial, Success' &&
        triggerOldMap.get((String) acc.get('Id')).get('No_Touch_Status__c') ==
        'Trial'
      ) {
        accountIds.add(acc.Id);
      }
    }
    System.debug('### ShareASaleAccountHandler accountIds: ' + accountIds);
    return accountIds;
  }
}

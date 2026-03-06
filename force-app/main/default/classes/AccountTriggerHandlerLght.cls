/****************************************************************************************************************
Name                		: AccountTriggerHandlerLght
Description         		:
Related components 		:

Created/Modified by               Created/Modified Date           Requested by           Related Task/Issue
-----------------------------------------------------------------------------------------------------------------
1. Dmitry Trufanov                     07.02.2019               Dmitry Trufanov				   -
****************************************************************************************************************/
public class AccountTriggerHandlerLght {
  public static Boolean TriggerFirstRun = true;
  private static List<Log_Event__e> logEvents = new List<Log_Event__e>();

  public static void changeContactOwnerAndKeepAccountTeamMember(
    Map<Id, Account> newMap,
    Map<Id, Account> oldMap
  ) {
    if (TriggerFirstRun) {
      Map<Id, Account> accountMap = new Map<Id, Account>();

      for (Account acc : newMap.values()) {
        if (acc.OwnerId != oldMap.get(acc.Id).OwnerId) {
          accountMap.put(acc.Id, acc);
        }
      }

      if (!accountMap.isEmpty()) {
        System.enqueueJob(
          new UpdateContactOwnerFromAccountQueueable(
            accountMap,
            System.isBatch() || System.isQueueable() || Test.isRunningTest()
          )
        );
      }
    }
    //publishLogs();//Generates too many unnecessary logs
  }

  /**
   * @author Zohar Sinay
   * @date 26/08/2022
   * @description Sets the ISO3 field on Account with the ISO3 code from the relevant MDT record
   * @return
   */
  public static void setISO3(
    List<Account> newTrigger,
    Map<Id, Account> oldMap
  ) {
    Map<String, Country_Picklist_Values__mdt> countryPicklistValues = Country_Picklist_Values__mdt.getAll();

    for (Account acc : newTrigger) {
      if (oldMap == null && (acc.BillingCountryCode != null)) {
        checkAndAssignISO3(countryPicklistValues, acc);
      } else if (
        (oldMap != null &&
        (acc.BillingCountryCode != null) &&
        (oldMap.get(acc.Id).BillingCountryCode != acc.BillingCountryCode)) ||
        (acc.Country_Code_ISO3__c == null &&
        acc.BillingCountryCode != null)
      ) {
        checkAndAssignISO3(countryPicklistValues, acc);
      }
    }
  }

  /**
   * @author Zohar Sinay
   * @date 26/08/2022
   * @description Assigns the ISO3 code if exists in the MDT
   * @return
   */
  private static void checkAndAssignISO3(
    Map<String, Country_Picklist_Values__mdt> countryPicklistValues,
    Account acc
  ) {
    if (countryPicklistValues.containsKey(acc.BillingCountryCode)) {
      acc.Country_Code_ISO3__c = countryPicklistValues.get(
            acc.BillingCountryCode
          )
          .ISO_Code_3__c != null
        ? countryPicklistValues.get(acc.BillingCountryCode).ISO_Code_3__c
        : '';
    }
  }
}

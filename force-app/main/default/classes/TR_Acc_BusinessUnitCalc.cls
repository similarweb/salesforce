/**
 * @author Gad Sharon
 * @date 25/11/2020
 * @description Calculate the account business unit according to changed data on the account.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 18/01/2021
 * description - Changed "Handle" method to support insert, when "map_oldAccs" is null
 * --------------------------------------------------------------------------------------
 */

public with sharing class TR_Acc_BusinessUnitCalc {
  /**
   * @author Gad Sharon
   * @date 25/11/2020
   * @description Handle the functionlity of the class.
   * @param None.
   * @return Void.
   */

  public void handle(List<SObject> lst_newAccs, Map<Id, SObject> map_oldAccs) {
    System.debug('lola i am here!!!!---' + map_oldAccs);
    System.debug('isInsert---' + Trigger.isInsert);
    System.debug('isUpdate---' + Trigger.isUpdate);
    List<Account> lst_accs;
    if (map_oldAccs != null) {
      //on update - filter the records
      lst_accs = filter((List<Account>) lst_newAccs, map_oldAccs);
    } else {
      //on insert - pass all records for calculation
      lst_accs = lst_newAccs;
    }
    //Continue only if we have relevant accounts.
    if (!lst_accs.isEmpty()) {
      System.debug('going into business unit update');
      BusinessUnitUpdateHelper buuh = new BusinessUnitUpdateHelper();
      buuh.updateBusinessUnit(
        lst_accs,
        'Website_Domain__c',
        'BillingCountry',
        null,
        true
      );
      handleAfterBusinessUnitFinished(lst_accs);
    }
  }

  private void handleAfterBusinessUnitFinished(List<Account> newList) {
    for (Account acc : newList) {
      System.debug('acc.Business_Unit__c--' + acc.Business_Unit__c);
      System.debug(
        'acc.NT_BU_override_one_time__c--' + acc.NT_BU_override_one_time__c
      );
      System.debug('acc.Strategic_Pod__c--' + acc.Strategic_Pod__c);
      System.debug('acc.Strategic_Pod__c--' + acc.Strategic_Region__c);
      if (acc.NT_BU_override_one_time__c) {
        acc.NT_BU_override_one_time__c = false;
        if (acc.Business_Unit__c == 'Inside Sales') {
          //                    System.debug(' i am in inside sales');
          //                    acc.Website = acc.NT_master_website__c;
          //                    acc.Employees_Max__c = acc.EmployeesMax_registration__c;
          //                    acc.Employees_Min__c = acc.EmployeesMin_registration__c;
          acc.Name = 'Private Account - ' + acc.Website;
          //                    System.debug('acc.empl---'+acc.Employees_Max__c);
          //                    System.debug('acc.empl---'+acc.Employees_Min__c);
        } else {
          acc.Name = acc.NT_CC_Holder_Name__c;
          acc.Website = 'no_website';
          acc.Employees_Max__c = 10;
          acc.Employees_Min__c = 1;
          acc.Business_Unit__c = 'Inside Sales';
          acc.Strategic_Region__c = ''; // added in 1.1.25
          acc.Strategic_Pod__c = '';
          acc.Parent_Company_Domain__c = '';
        }
      }
    }
  }

  /**
   * @author Gad Sharon
   * @date 25/11/2020
   * @description Check if we have relevant records and if so, return them.
   * @param List<Account> lst_newAccs - The list of accounts to check.
   * @param Map<Id, SObject> map_oldAccs - The previous state of the accounts.
   * @return List <Account> - The list of accounts that we need to work on.
   * =================================================================================================
   * author: Itzik Winograd
   * date: 29/12/2021
   * description: Check the fields that were changed according to a custom metadata named Account_Business_Unit_Calc_Criteria
   */

  private List<Account> filter(
    List<Account> lst_newAccs,
    Map<Id, SObject> map_oldAccs
  ) {
    Set<Account> lst_relevantAccs = new Set<Account>();
    Account oldAcc;
    String rawAccountFieldNames = GeneralUtil.getGeneralConfig(
        'Account_Business_Unit_Calc_Criteria'
      )
      .Text_Value__c;
    if (rawAccountFieldNames != null) {
      List<String> accountFieldNamesList = rawAccountFieldNames.split(';');
      //Check if one of the relevant fields changed.
      for (Account curAcc : lst_newAccs) {
        oldAcc = (Account) map_oldAccs.get(curAcc.id);
        for (String fieldName : accountFieldNamesList) {
          if (curAcc.get(fieldName) != oldAcc.get(fieldName)) {
            lst_relevantAccs.add(curAcc);
          }
        }
      }
    }
    System.debug('lst_relevantAccs--' + lst_relevantAccs.size());
    System.debug('lst_relevantAccs--' + lst_relevantAccs);
    return new List<Account>(lst_relevantAccs);
  }
}

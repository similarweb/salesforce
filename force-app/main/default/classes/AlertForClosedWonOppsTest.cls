/**
 * @author Itzik Winograd
 * @date 15/02/2021
 * @description Test class for the AlertForClosedWonOPpps class
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */

/**
 * @author Itzik Winograd
 * @date 15/02/2021
 * @description Create 5 alerts and publish them
 * @return none.
 */
@isTest
public inherited sharing class AlertForClosedWonOppsTest {
  public static Integer NUMBER_OF_OPPS = 2;
  @isTest
  public static void alertForClosedWonOppsInsertTest() {
    Integer N = NUMBER_OF_OPPS;
    List<Opportunity> opps = new List<Opportunity>();
    Opportunity opp;
    for (Integer i = 0; i < N; i++) {
      opp = createOpp(i);
      opp.StageName = 'Closed Won';
      opps.add(opp);
    }
    Test.startTest();
    List<Database.SaveResult> sr_lst = Database.insert(opps);
    Test.stopTest();
    // Verify that the publish was successful
    for (Integer i = 0; i < sr_lst.size(); i++) {
      System.assertEquals(
        true,
        sr_lst[i].isSuccess(),
        'Error in ' + opps[i].Name + ': ' + sr_lst[i].getErrors()
      );
    }
  }

  @isTest
  public static void alertForClosedWonOppsUpdateTest() {
    Integer N = NUMBER_OF_OPPS;
    List<Opportunity> opps = new List<Opportunity>();
    Account acc = AccountUtils.getAccounts(1)[0];
    insert acc;
    Opportunity opp;
    for (Integer i = 0; i < N; i++) {
      opp = createOpp(i);
      opp.StageName = 'Proposal';
      opp.AccountId = acc.Id;
      opps.add(opp);
    }
    Database.insert(opps);
    for (Opportunity oppToUpdate : opps) {
      oppToUpdate.stageName = 'Closed Won';
      oppToUpdate.SYS_CloseFlow__c = !oppToUpdate.SYS_CloseFlow__c;
    }
    Test.startTest();
    List<Database.SaveResult> sr_lst = Database.update(opps);
    Test.stopTest();
    // Verify that the publish was successful
    for (Integer i = 0; i < sr_lst.size(); i++) {
      System.assertEquals(
        true,
        sr_lst[i].isSuccess(),
        'Error in ' + opps[i].Name + ': ' + sr_lst[i].getErrors()
      );
    }
  }

  /**
   * --- change---
   * @author Elnur Alibaev
   * @date 01/08/2025
   * @description Removed Product_Sold__c from opp initiation
   */
  public static Opportunity createOpp(Integer i) {
    return new Opportunity(
      Name = 'test' + i,
      CloseDate = Date.today(),
      Cycle__c = 'Annually',
      OwnerId = userInfo.getUserId(),
      Arr__c = 499,
      Cycle_Price__c = 500,
      Competition__c = 'none',
      Type = 'upsell'
    );
  }
}

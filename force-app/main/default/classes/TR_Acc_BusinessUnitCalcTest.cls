/*
 * @author Itzik Winograd
 * @date 23/12/2020
 * @description Test class for TR_Acc_BusinessUnitCalc Class
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */

@isTest
global with sharing class TR_Acc_BusinessUnitCalcTest {
  /**
   * @author Itzik Winograd
   * @date 23/12/2020
   * @description - Create Test Accounts and an Email Domain
   */
  @TestSetup
  public static void makeData() {
    //Set a mock for initail Account inserting
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    //        SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
    //        currentSettings.API_Key__c='test';
    //        currentSettings.Create_Date_TimeFrame__c='test';
    //        currentSettings.Enriched_Entities__c='["account"]';
    //        currentSettings.Invisible_Fields__c='test';
    //        currentSettings.Refresh_Data_Interval__c=0;
    //        currentSettings.Sync_on_create_and_update__c=true;
    //        insert currentSettings;

    //Create accounts
    List<Account> accountList = AccountUtils.getAccounts(10);
    System.debug(accountList.size());
    insert accountList;

    EmailDomain__c emc = EmailDomainUtils.getEmailDomains(1)[0];
    insert emc;
  }

  /**
   * @author Itzik Winograd
   * @date 23/12/2020
   * @Description - This class will update the Employee and the Website on the created Accounts.
   * @Desired - The accounts Business Unit will be changed accordingly. for none-related fields we expect no chages to he Business Unit.
   */
  @isTest
  public static void testBusinessUnit() {
    //Set a mock for account updates
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    //System.debug('In doTest');
    Integer minEmployees = Integer.valueOf(
      GeneralUtil.getGeneralConfig('Business_Unit_Employees_Min_US_CA')
        .Number_Value__c
    );
    // Create 3 account lists for each desired business unit assertions
    List<Account> lst_insideSales = new List<Account>();
    List<Account> lst_enterprise = new List<Account>();
    List<Account> lst_strategic = new List<Account>();

    //Change the Website / employee_min fields on account
    List<Account> accountList = TR_Acc_BusinessUnitCalcTest.getAccountsFromDB();
    //System.debug('==> accountList found: ' + accountList.size());
    for (Integer i = 0; i < accountList.size(); i++) {
      //System.debug('===> on '+i+', BusinessUnit is: ' +accountList[i].Business_Unit__c );
      if (i < 4) {
        accountList[i].Website = 'https://www.testNEW' + i + '.com';
      } else if (i < 8) {
        accountList[i].Employees_Min__c = i * minEmployees;
      } else {
        accountList[i].Website = 'https://www.TestDomain_0.com';
      }
    }

    Test.startTest();
    update accountList;
    Test.stopTest();

    //Loop over the found accounts and count them agains the right BU
    for (Account acc : TR_Acc_BusinessUnitCalcTest.getAccountsFromDB()) {
      System.debug('===> BusinessUnit is: ' + acc.Business_Unit__c);
      System.debug('===> Website_Domain__c is: ' + acc.Website_Domain__c);
      switch on acc.Business_Unit__c {
        when 'Inside Sales' {
          lst_insideSales.add(acc);
        }
        when 'Enterprise' {
          lst_enterprise.add(acc);
        }
        when 'Strategic' {
          lst_strategic.add(acc);
        }
      }
    }

    //Assert equal for InsideSales, Enterprise and Strategic
    //        System.assertEquals(6, lst_insideSales.size(),'Error in Business Unit "insideSales"');
    //        System.assertEquals(4, lst_enterprise.size(), 'Error in Business Unit "enterprise"');
    //        System.assertEquals(2, lst_strategic.size(), 'Error in Business Unit "strategic"');

    //Change Other fields on account and make sure the BU is not changed
    accountList = TR_Acc_BusinessUnitCalcTest.getAccountsFromDB();
    List<String> acc_beforeChange = new List<String>();
    for (Integer i = 0; i < accountList.size(); i++) {
      acc_beforeChange.add(accountList[i].Business_unit__c);
      if (i < 4) {
        accountList[i].Name = 'SomeName';
      } else if (i < 8) {
        accountList[i].Email__c = 'some.other@email.com';
      } else {
        accountList[i].Employees_Max__c = 5000;
      }
    }
    update accountList;
    //get the updates and make sure nothing had changed
    accountList = TR_Acc_BusinessUnitCalcTest.getAccountsFromDB();
    for (Integer i = 0; i < accountList.size(); i++) {
      System.assertEquals(
        acc_beforeChange[i],
        accountList[i].Business_unit__c,
        'Business Unit mismatch on account ' + accountList[i]
      );
    }
  }

  /**
   * @author Itzik Winograd
   * @date 24/12/2020
   * @description - Get all inserted accounts
   */
  public static List<Account> getAccountsFromDB() {
    return [
      SELECT Id, Website, Employees_Min__c, Business_unit__c, Website_Domain__c
      FROM Account
    ];
  }

  /**
   * @author Itzik Winograd
   * @date 24/12/2020
   * @description - Mock an HTTPS response for the account-insertion-fitScore-call
   */
  global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"response":{"lead_enrichment_country_values":{"countries":{"world":{"start_date":"2019-12","end_date":"2020-11"}}}}}'
      );
      res.setStatusCode(200);
      return res;
    }
  }
}

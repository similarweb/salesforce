/**
 * @author Itzik Winograd
 * @date 09/01/2022
 * @description Test Class for AddInvalidToEmailFields
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 2022-05-19
 * description - add  acc.SW_Industry__c = 'Agency' since error occured when tested.
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 2022-07-20
 * description - Changed the test accordingly to work with the Bacth version.
 * --------------------------------------------------------------------------------------
 */
@isTest
public class AddInvalidToEmailFieldsTest {
  private static final string OPPORTUNITY_FIELDS_LIST = 'Sandbox_Refresh_Opportunity_Fields';
  private static final string REQUEST_FIELDS_LIST = 'Sandbox_Refresh_Request_Fields';
  private static List<String> requestEmailFieldsToUpdateList = GeneralUtil.getGeneralConfig(
      REQUEST_FIELDS_LIST
    )
    .Text_Value__c.split(';');
  private static List<String> oppEmailFieldsToUpdateList = GeneralUtil.getGeneralConfig(
      OPPORTUNITY_FIELDS_LIST
    )
    .Text_Value__c.split(';');

  /**
   * @author Itzik Winograd
   * @date 09/01/2022
   * @description Create accounts, opps and requests for the upcoming test.
   * 			   Put values in all relevant email fields
   * --- change---
   * @author Elnur Alibaev
   * @date 01/08/2025
   * @description Removed Product_Sold__c assignment from opp
   */
  @testSetup
  public static void makeTestData() {
    //Create accounts
    Integer numOfRecords = 1;
    List<Account> accountsList = AccountUtils.getAccounts(numOfRecords);
    for (Account acc : accountsList) {
      acc.SW_Industry__c = 'Agency';
    }
    insert accountsList;
    System.debug('@@@ accountsList: ' + accountsList);
    //Create Opps
    List<Opportunity> oppsList = new List<Opportunity>();
    for (Integer i = 0; i < numOfRecords; i++) {
      Opportunity opp = TestDataFactory.createOpportunity(accountsList[i]);
      for (String emailField : oppEmailFieldsToUpdateList) {
        opp.put(emailField, 'test' + i + '@test.com');
      }
      oppsList.add(opp);
    }
    insert oppsList;
    System.debug('@@@ oppsList: ' + oppsList);
    //create Request__c
    List<Request__c> requestsList = new List<Request__c>();
    for (Integer i = 0; i < numOfRecords; i++) {
      Request__c req = TestDataFactory.createRequest(oppsList[i]);
      for (String emailField : requestEmailFieldsToUpdateList) {
        req.put(emailField, 'test' + i + '@test.com');
      }
      requestsList.add(req);
    }
    insert requestsList;
    System.debug('@@@ requestsList: ' + requestsList);
  }

  /**
   * @author Itzik Winograd
   * @date 09/01/2022
   * @description Run the process.
   * @expected - No email field will be found without "invalid"
   */
  @isTest
  public static void checkForEmailWitoutInvalid() {
    Test.startTest();
    //AddInvalidToEmailFields addInvlaid = new AddInvalidToEmailFields();
    //addInvlaid.handle();
    Database.executeBatch(
      new AddInvalidToEmailFields('Sandbox_Refresh_Opportunity_Fields'),
      200
    );
    Database.executeBatch(
      new AddInvalidToEmailFields('Sandbox_Refresh_Request_Fields'),
      200
    );
    Database.executeBatch(
      new AddInvalidToEmailFields('Sandbox_Refresh_Meeting_Fields'),
      200
    );
    Test.stopTest();
    //check opps
    List<SObject> oppsList = Database.query(
      CustomQueriesUtils.getCustomQuery(OPPORTUNITY_FIELDS_LIST)
    );
    for (SObject opp : oppsList) {
      for (String emailField : oppEmailFieldsToUpdateList) {
        if (opp.get(emailField) != null) {
          System.assert(
            ((String) opp.get(emailField)).contains('invalid'),
            'No invalid found in Opportunity field ' + emailField
          );
        }
      }
    }
    //check requests
    List<SObject> requestsList = Database.query(
      CustomQueriesUtils.getCustomQuery(REQUEST_FIELDS_LIST)
    );
    for (SObject req : requestsList) {
      for (String emailField : requestEmailFieldsToUpdateList) {
        if (req.get(emailField) != null) {
          System.assert(
            ((String) req.get(emailField)).contains('invalid'),
            'No invalid found in Request__c field ' + emailField
          );
        }
      }
    }
  }
}

/**
 * @author Itzik Winograd
 * @date 10/03/2021
 * @description Test class for ShareASale logging solution
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public class ShareASaleIntegrationTest {
  /**
   * @author Itzik Winograd
   * @date 11/04/2021
   * @Description Create test prerequisites
   * @param none
   * @return none
   */
  @testSetup
  public static void shareASaleTestSetup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );
  }

  /**
   * @author Itzik Winograd
   * @date 11/04/2021
   * @Description Create 15 contacts. Query for Apex_Event_Log__c  records.
   * @Expecte only BATCH_LIMIT log records will be created.
   * Also, assert '178' is part of the called enpoint.
   */
  @isTest
  public static void shareASaleContactsTest() {
    Account acc = AccountUtils.getAccounts(1)[0];
    insert acc;
    //insert some contacts
    List<Contact> cons = ContactUtils.getContacts(15);
    for (Contact con : cons) {
      con.Affiliate_Id__c = '178';
      con.AccountId = acc.Id;
      con.MailingCountry = 'Austria';
    }
    cons[14].Order_Number__c = 'someOrderNumber'; //this will use for phase 2 "reference" call
    cons[14].Pro_User_Type__c = 'User';
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );
    insert cons;
    Test.stopTest();

    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>(
      [
        SELECT
          Id,
          Log_Type__c,
          Apex_Class__c,
          Detailed_Information__c,
          Detailed_Error_Message__c,
          Apex_Method__c,
          Http_Endpoint__c
        FROM Apex_Event_Log__c
        WHERE
          Apex_Class__c = 'ShareASaleQuauableCalls'
          AND Apex_Method__c = 'execute'
        //AND Http_Endpoint__c != null
        ORDER BY Apex_Class__c ASC
      ]
    );
    for (Apex_Event_Log__c lg : logs) {
      System.debug('@@@ log: ' + lg);
    }
    Integer BATCH_LIMIT = Integer.valueOf(
      GeneralUtil.getGeneralConfig('ShareASale_Transaction_Batch_Size')
        .Number_Value__c
    );
    System.assertEquals(
      BATCH_LIMIT,
      logs.size(),
      'shareASaleContactsTest Mismatch on the number of logs created'
    );
    System.assert(logs[0].Http_Endpoint__c.contains('178'));
  }

  /**
   * @author Itzik Winograd
   * @date 11/04/2021
   * @Description Test Lead Conversion. Create a lead and convert it.
   * @Expected: Make sure there is only one log record - for the lead and none was created for the contact
   * @param none
   * @return none
   */
  @isTest
  public static void shareASaleLeadConversionTest() {
    Lead myLead = new Lead(
      LastName = 'lastName',
      email = 'testLead@testLead.com',
      Company = 'testComp',
      Country = 'Austria',
      Affiliate_Id__c = '4444'
    );
    Test.setMock(HttpCalloutMock.class, new ShareASaleMock());
    Test.startTest();
    insert myLead;

    //convert lead
    Database.LeadConvert lc = new database.LeadConvert();
    lc.setLeadId(myLead.id);
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    lc.setConvertedStatus(convertStatus.MasterLabel);
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    Test.stopTest();

    System.assert(lcr.isSuccess());
    System.debug(
      '@@@ found contact: ' +
      [
        SELECT Id, Name, Affiliate_Id__c
        FROM Contact
        WHERE email = 'testLead@testLead.com'
      ]
    );
    Lead insertedLead = [
      SELECT Id, Affiliate_Id__c, ShareASale_New_Transaction_Response__c
      FROM Lead
      WHERE Affiliate_Id__c = '4444'
    ][0];
    System.debug('@@@ insertedLead: ' + insertedLead);
    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>(
      [
        SELECT
          Id,
          Log_Type__c,
          Apex_Class__c,
          Detailed_Information__c,
          Detailed_Error_Message__c,
          Apex_Method__c,
          Http_Endpoint__c
        FROM Apex_Event_Log__c
        WHERE Apex_Method__c = 'execute'
        //AND Http_Endpoint__c LIKE '%4444%'
        ORDER BY CreatedDate DESC
      ]
    );
    System.debug('@@@ found logs: ' + logs);
    System.assertEquals(
      1,
      logs.size(),
      '@@@ shareASaleLeadConversionTest mismatch in log amount'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 11/04/2021
   * @Description Test Lead Conversion with error. Create a lead but with ShareASaleMockError
   * @Expected: make sure that the only existing log is of type 'error'.
   * Also expect that the field 'ShareASale_New_Transaction_Response__c' will hold the error recevied.
   * @param none
   * @return none
   */
  @isTest
  public static void shareASaleTestErrorLog() {
    Lead myLead = new Lead(
      LastName = 'lastName',
      email = 'testLead@testLead.com',
      Company = 'testComp',
      Country = 'Austria',
      Affiliate_Id__c = '5555'
    );
    Test.setMock(HttpCalloutMock.class, new ShareASaleMockError());
    Test.startTest();
    insert myLead;
    Test.stopTest();
    Apex_Event_Log__c logRecord = [
      SELECT Id, Apex_Class__c, Apex_Method__c, Http_Endpoint__c, Log_Type__c
      FROM Apex_Event_Log__c
      WHERE Apex_Class__c = 'ShareASaleQuauableCalls'
      //AND Http_Endpoint__c LIKE '%5555%'
      ORDER BY CreatedDate DESC
    ][0];
    System.assertEquals(
      'Error',
      logRecord.Log_Type__c,
      '@@@ shareASaleTestErrorLog mismatch in log type'
    );
    Lead insertedLead = [
      SELECT Id, ShareASale_New_Transaction_Response__c
      FROM Lead
      WHERE Affiliate_Id__c = '5555'
    ][0];
    System.assertEquals(
      'Transaction Failed',
      insertedLead.ShareASale_New_Transaction_Response__c,
      '@@@ shareASaleTestErrorLog mismatch error message'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 02/06/2021
   * @Description test account updated to "after trial successful"
   * and verify that only one shareasale phase-2 record was created.
   */
  @isTest
  public static void shareASaleReferenceTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );
    Account acc = AccountUtils.getAccounts(1)[0];
    acc.No_Touch_Status__c = 'Trial';
    acc.No_Touch_Account__c = true;
    insert acc;
    Contact con = ContactUtils.getContacts(1)[0];
    con.Affiliate_Id__c = '178';
    con.AccountId = acc.Id;
    con.Order_Number__c = 'someOrderNumber'; //this will use for phase 2 "reference" call
    con.Pro_User_Type__c = 'User';
    con.MailingCountry = 'Austria';
    Test.startTest();
    insert con;
    acc.No_Touch_Status__c = 'After Trial, Success';
    update acc;
    Test.stopTest();
    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>(
      [
        SELECT Id, HTTP_Endpoint__c
        FROM Apex_Event_Log__c
        //WHERE HTTP_Endpoint__c LIKE '%reference%'
      ]
    );
    System.assertEquals(
      1,
      logs.size(),
      '@@@ Extra reference logs were found: ' + logs
    );
  }

  /**
   * @author Itzik Winograd
   * @date 30/06/2021
   * @Description Test wrong country name, one that is not in the list.
   * @Expected : no log record will be found
   */
  @isTest
  public static void shareASaleTestWrongCountry() {
    List<Contact> cons = ContactUtils.getContacts(3);
    for (Contact con : cons) {
      con.Affiliate_Id__c = '178';
      con.MailingCountry = 'Neverland';
    }
    Test.startTest();
    insert cons;
    Test.stopTest();
    List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>(
      [
        SELECT Id, HTTP_Endpoint__c
        FROM Apex_Event_Log__c
        //WHERE HTTP_Endpoint__c like '%shareasale%'
      ]
    );
    System.assertEquals(
      0,
      logs.size(),
      '@@@ Extra reference logs were found: ' + logs
    );
  }

  /**
   * @author Itzik Winograd
   * @date 10/03/2021
   * @Description Mocks shareASale response, one with error and one without
   */
  public class ShareASaleMock implements System.HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('ContentType', 'application/json');
      res.setBody('Transaction Created');
      res.setStatusCode(200);
      return res;
    }
  }
  public class ShareASaleMockError implements System.HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('ContentType', 'application/json');
      res.setBody('Transaction Failed');
      res.setStatusCode(200);
      return res;
    }
  }
}

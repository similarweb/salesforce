/**
* @author Itzik Winograd
* @date 21/06/2021
* @description: Test class for the PassValuesToConvertedLeadsTest

*/
@isTest
public class PassValuesToConvertedLeadsTest {
  private static final Integer EMP_MIN = 33;
  /**
   * @author Itzik Winograd
   * @date 21/06/2021
   * @description Create lead, account and contacts.
   */
  @testSetup
  public static void testLeadConvertPassValuesToAccount() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );

    Lead myLead = new Lead(
      LastName = 'lastName',
      email = 'testLead@testLead.com',
      Company = 'testComp'
    );
    insert myLead;

    Account acc = AccountUtils.getAccounts(1)[0];
    acc.Employees_Min__c = EMP_MIN;
    insert acc;
    Contact con = ContactUtils.getContactsForAccount(1, acc)[0];
    insert con;
    //Contact conWithoutAccount = ContactUtils.getContacts(1)[0];
    //insert conWithoutAccount;
  }

  /**
   * @author Itzik Winograd
   * @date 21/06/2021
   * @description Convert lead to an existing account
   * @Expected:  The new Cotact - the converted lead - received the value in the Employees_Min__c from the Account.
   */
  @isTest
  public static void testConvertToAccount() {
    Lead myLead = [
      SELECT Id
      FROM LEAD
      LIMIT 1
    ];
    Account acc = [
      SELECT Id
      FROM Account
      LIMIT 1
    ];
    Test.startTest();
    //convert lead
    Database.LeadConvert lc = new database.LeadConvert();
    lc.setLeadId(myLead.id);
    lc.setAccountId(acc.Id);
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    lc.setConvertedStatus(convertStatus.MasterLabel);
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    Test.stopTest();

    for (Contact conI : [
      SELECT Id, Employees_Min__c
      FROM Contact
      WHERE AccountId = :acc.Id
    ]) {
      System.assertEquals(
        EMP_MIN,
        conI.Employees_Min__c,
        '@@@ Error: employees_min_c mismatch!'
      );
    }
  }

  /**
   * @author Itzik Winograd
   * @date 21/06/2021
   * @description Convert lead to an existing contact
   * @Expected:  The new Cotact - the converted lead - received the value in the Employees_Min__c from the Account.
   */
  @isTest
  public static void testConvertToContact() {
    Lead myLead = [
      SELECT Id
      FROM Lead
      LIMIT 1
    ];
    Account acc = [
      SELECT Id, Employees_Min__c
      FROM Account
      LIMIT 1
    ];
    Contact con = [
      SELECT Id, AccountId
      FROM Contact
      WHERE AccountId = :acc.Id
      LIMIT 1
    ];
    con.Employees_Min__c = EMP_MIN * 2;
    update con;
    Test.startTest();
    //convert lead
    Database.LeadConvert lc = new database.LeadConvert();
    lc.setLeadId(myLead.id);
    lc.setContactId(con.Id);
    lc.setAccountId(con.AccountId);
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel
      FROM LeadStatus
      WHERE IsConverted = TRUE
      LIMIT 1
    ];
    lc.setConvertedStatus(convertStatus.MasterLabel);
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    Test.stopTest();

    for (Contact conI : [
      SELECT Id, Employees_Min__c
      FROM Contact
      WHERE Id = :con.Id
    ]) {
      System.assertEquals(
        EMP_MIN,
        conI.Employees_Min__c,
        '@@@ Error: employees_min_c mismatch!'
      );
    }
  }
}

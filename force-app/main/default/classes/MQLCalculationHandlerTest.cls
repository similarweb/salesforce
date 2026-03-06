@isTest
public class MQLCalculationHandlerTest {
  @testSetup
  static void prepareData() {
    User u = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() LIMIT 1];
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Pardot_Data_Manipulation_Setting__c pdms1 = new Pardot_Data_Manipulation_Setting__c();
    pdms1.Name = 'JUNK_LEAD_OWNER_ID';
    pdms1.Value__c = u.Id;
    Pardot_Data_Manipulation_Setting__c pdms3 = new Pardot_Data_Manipulation_Setting__c();
    pdms3.Name = 'BASIC_LDR_LEAD_OWNER_ID_LIST';
    pdms3.Value__c = '0050O000007jDGG;005b0000002iwIA';
    insert pdms3;
    insert pdms1;
    Account acc = TestDataFactory.createAccount();
    insert acc;
    Contact cnt = ContactUtils.getContacts(1)[0];
    cnt.AccountId = acc.id;
    cnt.MailingCountry = 'Ukraine';
    cnt.MailingState = '';
    cnt.SW_Fit_Score__c = 'D';
    insert cnt;
    Lead ld = TestDataFactory.createLead();
    ld.SW_Fit_Score__c = 'D';
    ld.Company = 'testCompany';
    insert ld;

    List<BI_Data__c> bids = [SELECT Id, Base_Product__c FROM BI_Data__c];
    for (BI_Data__c bid : bids) {
      bid.Base_Product__c = '1';
      bid.SW_Behavioral_Rate__c = 2;
      bid.ROE_Division__c = 'SMB Sales - US';
    }
    update bids;
  }

  /**
   * @author Itzik Winograd
   * @date 13/07/2021
   * @description: Set fitscore to 'C' on a Contact that is mql=false.
   *				the behavioralRate is already 2
   * @expected: MQL on the Contact will be true since C-2 should be true.
   */
  @isTest
  public static void testMQLforC2GradeContact() {
    Contact cnt = [
      SELECT
        Id,
        MQL__c,
        SW_Fit_Score__c,
        Bi_Data__c,
        BI_Data__r.SW_Behavioral_Rate__c
      FROM Contact
      WHERE MQL__c = FALSE
      LIMIT 1
    ];
    System.debug('@@@ cnt before: ' + cnt);
    cnt.SW_Fit_Score__c = 'C';

    Test.startTest();
    update cnt;
    Test.stopTest();

    cnt = [
      SELECT Id, MQL__c, SW_Fit_Score__c, BI_Data__r.SW_Behavioral_Rate__c
      FROM Contact
      LIMIT 1
    ];
    System.debug('@@@ cnt after' + cnt);
    System.assertEquals(
      true,
      cnt.MQL__c,
      'MQL on Contact is not true as expected. '
    );
  }

  /**
   * @author Itzik Winograd
   * @date 13/07/2021
   * @description: Set fitscore to 'A' on a Lead that is mql=false.
   * 				Set HasOptedOutOfEmail to true.
   * @expected: MQL on the Contact will be true since C-2 should be true.
   * @expected: First_MQL_Date__c, MQL_date__c get today's date.
   */
  @isTest
  public static void testMQLforC2GradeLead() {
    Lead ld = [
      SELECT
        Id,
        MQL__c,
        SW_Fit_Score__c,
        Bi_Data__c,
        BI_Data__r.SW_Behavioral_Rate__c
      FROM Lead
      WHERE MQL__c = FALSE
      LIMIT 1
    ];
    System.debug('@@@ ld before: ' + ld);
    ld.SW_Fit_Score__c = 'C';

    Test.startTest();
    update ld;
    Test.stopTest();

    ld = [
      SELECT
        Id,
        MQL__c,
        SW_Fit_Score__c,
        BI_Data__r.SW_Behavioral_Rate__c,
        First_MQL_Date__c,
        MQL_Date__c
      FROM Lead
      LIMIT 1
    ];
    System.debug('@@@ ld after' + ld);
    System.assertEquals(
      true,
      ld.MQL__c,
      'MQL on Lead is not true as expected. '
    );
    //System.assertEquals(ld.First_MQL_Date__c.date(), Date.today(), 'MQL Dates incompatible');
    System.assertEquals(
      ld.MQL_Date__c.date(),
      Date.today(),
      'MQL Dates incompatible'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 13/07/2021
   * @description: Set fitscore to 'C' on a Contact that is mql=false.
   *				the behavioralRate is already 2
   *				Set HasOptedOutOfEmail to true;
   * @expected: MQL on the Contact will be false HasOptedOutOfEmail = true;
   */
  @isTest
  public static void testMQLforHasOptedOutOfEmail() {
    Lead ld = [
      SELECT Id, MQL__c, SW_Fit_Score__c, HasOptedOutOfEmail
      FROM Lead
      WHERE MQL__c = FALSE
      LIMIT 1
    ];
    System.debug('@@@ ld before: ' + ld);
    ld.SW_Fit_Score__c = 'A';
    ld.HasOptedOutOfEmail = true;

    Test.startTest();
    update ld;
    Test.stopTest();

    ld = [
      SELECT Id, MQL__c, SW_Fit_Score__c, HasOptedOutOfEmail
      FROM Lead
      LIMIT 1
    ];
    System.debug('@@@ ld after' + ld);
    System.assertEquals(
      false,
      ld.MQL__c,
      'MQL on Lead is not False as expected. '
    );
  }

  /**
   * @author Itzik Winograd
   * @date 25/08/2021
   * @description: Change the MQL value to false and make sure that the Date field isnt cahnged.
   * @expected: MQL on the Contact will be false and the date field unchaged = true;
   */
  @isTest
  public static void testMQDatesUnchanged() {
    Lead ld = [
      SELECT Id, MQL__c, SW_Fit_Score__c, HasOptedOutOfEmail
      FROM Lead
      WHERE MQL__c = FALSE
      LIMIT 1
    ];
    System.debug('@@@ ld before: ' + ld);
    ld.SW_Fit_Score__c = 'D';
    ld.MQL_date__c = null;

    Test.startTest();
    update ld;
    Test.stopTest();

    ld = [
      SELECT Id, MQL__c, SW_Fit_Score__c, MQL_date__c
      FROM Lead
      LIMIT 1
    ];
    System.debug('@@@ ld after' + ld);
    System.assertEquals(
      null,
      ld.MQL_date__c,
      'MQL_date__c was changed. it shouldnt.'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 28/12/2021
   * @description: Send values D1, B3
   * @expected: MQL = true
   */
  @isTest
  public static void testcalculateMQLDirect() {
    Boolean mqlValue = MQLCalculationHandler.calculateMQL(1, 'D');
    System.assertEquals(true, mqlValue, 'Error for D1');
    mqlValue = MQLCalculationHandler.calculateMQL(3, 'B');
    System.assertEquals(true, mqlValue, 'Error for B3');
  }
}

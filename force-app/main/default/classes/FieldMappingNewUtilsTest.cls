/**
 * @author Itzik Winograd
 * @date 02/05/2021
 * @description Test class for FieldMappingNewUtils class
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 30/09/2021
 * description - Added test for full converstion using the ClosedWonAlertGong
 * --------------------------------------------------------------------------------------
 */
@isTest
public class FieldMappingNewUtilsTest {
  /**
   * @author Itzik Winograd
   * @date 02/05/2021
   * @description: test the FieldMappingNewUtils class. Initialize the class with TestForFiledMappingNewUtils;
   * @Expect: Fields mapping maps size (source and destination) will be equal in size.
   */
  @isTest
  public static void testFieldMappingNewUtils() {
    FieldMappingNewUtils FMNUtils = new FieldMappingNewUtils(
      'TestForFiledMappingNewUtils'
    );
    System.assertEquals(
      FMNUtils.destinationVsMapping.size(),
      FMNUtils.sourceVsMapping.size(),
      'size of source and destination mismatch!'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 30/09/2021
   * @description: Test setup: create an Account and then map the fields to a new Contact.
   * @expected: The contact fields will match the
   */
  @isTest
  public static void testFieldMappingNewUtilsFullConversion() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );
    Test.startTest();
    Account acc = AccountUtils.getAccounts(1)[0];
    insert acc;

    acc = [
      SELECT Id, OwnerId
      FROM Account
      WHERE Id = :acc.Id
      LIMIT 1
    ];
    User u = new User(Id = acc.OwnerId, Division = 'customDivision');
    update u;
    Contact sourceCon = new Contact();
    sourceCon.AccountId = acc.Id;
    sourceCon.email = 'test@gmail.com';
    sourceCon.LastName = 'TestContact';

    insert sourceCon;
    Test.stopTest();
    System.debug('@@@ u: ' + u);
    sourceCon = [
      SELECT
        Id,
        FirstName,
        LastName,
        Account.Owner.Division,
        Email,
        CreatedDate,
        MIR_Team_Leader__c
      FROM Contact
      WHERE Id = :sourceCon.Id
      LIMIT 1
    ];
    Contact destinationCon = new Contact();
    FieldMappingNewUtils fmnu = new FieldMappingNewUtils(
      'TestForFiledMappingNewUtils'
    );
    destinationCon = (Contact) fmnu.setValuesFromSourceToDestination(
      sourceCon,
      destinationCon
    );
    insert destinationCon;
    System.debug('@@@ con:' + destinationCon);
    System.assertEquals(
      u.Division,
      destinationCon.LinkedIn_Bio__c,
      'Problem in mapping. Account.owner.division is not mapped to LinkedIn_Bio__c.'
    );

    testFieldMappingNewUtilsGetQueries();
  }

  /**
   * @author Itzik Winograd
   * @date 12/10/2021
   * @description: Test the getQuery methods
   * @expected: Each query will return some results.
   */

  public static void testFieldMappingNewUtilsGetQueries() {
    FieldMappingNewUtils FMNUtils = new FieldMappingNewUtils(
      'TestForFiledMappingNewUtils'
    );
    String queryDestination = FMNUtils.getDestinationQuery(
      'Contact',
      'CreatedDate'
    );
    String querySource = FMNUtils.getSourceQuery('Account', 'CreatedDate');
    System.assert(
      Database.Query(queryDestination)[0] != null,
      'Error inqueryDestination '
    );
    System.assert(Database.Query(querySource)[0] != null, 'Error querySource ');
  }
}

/**
 * @author Itzik Winograd
 * @date 06/06/2021
 * @description Test class for the KeepAccountTeamMembers class
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public class KeepAccountTeamMembersTest {
  @testSetup
  public static void testSetup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    Test.setMock(
      HttpCalloutMock.class,
      new TR_Acc_BusinessUnitCalcTest.MockHttpResponseGenerator()
    );

    Integer N = 5;
    //Insert N accounts
    List<Account> acc_lst = AccountUtils.getAccounts(N);
    insert acc_lst;
    Id profileId = getProfileId();
    List<User> users = new List<User>(
      [
        SELECT Id
        FROM User
        WHERE IsActive = TRUE AND ProfileId = :profileId
      ]
    );
    //Insert AccountTeamMembers for each account
    List<AccountTeamMember> atms = new List<AccountTeamMember>();
    for (Account acc : acc_lst) {
      atms.add(new AccountTeamMember(AccountId = acc.Id, UserId = users[0].Id));
      atms.add(new AccountTeamMember(AccountId = acc.Id, UserId = users[1].Id));
    }
    insert atms;
  }

  /**
   * @author Itzik Winograd
   * @date 06/06/2021
   * @description: Get the existing accouns and the current Team Members.
   * Change the account's owner and verify that the team member stays the same.
   * @Expected account team member will remain the same
   */
  @isTest
  public static void testOwnershipChanges() {
    //get a map of current Accounts
    Map<Id, Account> accountsMap = new Map<Id, Account>(
      [
        SELECT Id, OwnerId
        FROM Account
        ORDER BY Id ASC
      ]
    );
    System.debug(
      '@@@ account and owners before update: ' + accountsMap.values()
    );
    //Create a map of current AccountTeam Member
    Map<Id, List<AccountTeamMember>> accsToATM = createMembersMap(
      accountsMap.keySet()
    );
    System.Debug('@@@ accsToATM: ' + accsToATM);

    //get a set of current owners to make sure ownership had changed
    Set<Id> currentOwneres = new Set<Id>();
    for (Id accId : accountsMap.keySet()) {
      currentOwneres.add(accountsMap.get(accId).OwnerId);
    }
    //get an unsued user Id
    Id profileId = getProfileId();
    User u = [
      SELECT Id
      FROM User
      WHERE
        IsActive = TRUE
        AND ProfileId = :profileId
        AND Id NOT IN :currentOwneres
      LIMIT 1
    ][0];

    //change ownership on accounts
    List<Account> updatedAccounts = new List<Account>();
    for (Id accId : accountsMap.keySet()) {
      updatedAccounts.add(new Account(Id = accId, OwnerId = u.Id));
    }
    System.debug('@@@ account and owners to update: ' + updatedAccounts);
    Test.StartTest();
    update updatedAccounts;
    Test.StopTest();

    //Assert accountTeamMember hasnt cahnged
    Map<Id, List<AccountTeamMember>> accsToATMAfterUpdate = createMembersMap(
      accountsMap.keySet()
    );
    System.Debug('@@@ accsToATMAfterUpdate: ' + accsToATMAfterUpdate);

    Integer i;
    for (Id accId : accsToATMAfterUpdate.keySet()) {
      i = 0;
      for (AccountTeamMember atmAfter : accsToATMAfterUpdate.get(accId)) {
        System.assertEquals(
          atmAfter.userId,
          accsToATM.get(accId)[i].UserId,
          '@@@ mismatch in User Ids: new- ' +
            atmAfter.userId +
            ', old- ' +
            accsToATM.get(accId)[i].UserId
        );
        i++;
      }
    }
  }

  /**
   * @author Itzik Winograd
   * @date 06/06/2021
   * @description: for a giving set of account Ids, get their team memebers.
   * @param Set<Id> accIdSet set of account Ids
   * @return Map<Id, List<AccountTeamMember>> a map of account Ids vs a List of their Accoun Team Member
   */
  private static Map<Id, List<AccountTeamMember>> createMembersMap(
    Set<Id> accIdSet
  ) {
    Map<Id, List<AccountTeamMember>> accsToATM = new Map<Id, List<AccountTeamMember>>();
    for (AccountTeamMember atm : [
      SELECT Id, AccountId, UserId
      FROM AccountTeamMember
      WHERE AccountId IN :accIdSet
      ORDER BY AccountId ASC
    ]) {
      if (!accsToATM.containsKey(atm.AccountId)) {
        accsToATM.put(atm.AccountId, new List<AccountTeamMember>());
      }
      accsToATM.get(atm.AccountId).add(atm);
    }
    return accsToATM;
  }

  //return profile Id of "SW Client Services / Support" for the team members
  private static Id getProfileId() {
    return [
      SELECT Id
      FROM Profile
      WHERE Name = 'SW Client Services / Support'
      LIMIT 1
    ][0]
    .Id;
  }
}

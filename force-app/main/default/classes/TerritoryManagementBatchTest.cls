/**
 * Created by Alon.Shalev on 7/19/2022.
 */
@IsTest
public with sharing class TerritoryManagementBatchTest {
  @testSetup
  public static void setup() {
    String SUB_DIVISION = 'NAL-AUSG';
    String INDUSTRY = 'AdTech and AdNetwork';
    String SUB_TYPE = 'Other';
    //Territory
    Territory__c territory = new Territory__c();
    territory.Sub_Division__c = SUB_DIVISION;
    territory.SW_Industry__c = INDUSTRY;
    territory.Industry_Subtype__c = SUB_TYPE;
    territory.OwnerID = UserInfo.getUserId();
    insert territory;
    //Account matched to the territory
    Account acc = new Account();
    acc.Name = 'test';
    acc.SW_Industry__c = INDUSTRY;
    acc.Industry_Subtype__c = SUB_TYPE;
    acc.Re_Evaluate_Territory__c = true;
    insert acc;
    //Account Member with Member_of_Territory__c
    AccountTeamMember accountTM = new AccountTeamMember(
      AccountId = acc.Id,
      UserId = [
        SELECT Id
        FROM User
        WHERE IsActive = TRUE AND Profile.Name LIKE '%SW%'
        LIMIT 1
      ]
      .ID,
      Member_of_Territory__c = true
    );
    insert accountTM;
    //account that does not match to the territory
    Account accUnmatched = new Account();
    accUnmatched.Name = 'test' + 'OTHER';
    accUnmatched.SW_Industry__c = INDUSTRY + 'OTHER';
    accUnmatched.Re_Evaluate_Territory__c = true;
    insert accUnmatched;
    //set Sub_Division_Account__c on BI
    Account acc2 = [SELECT BI_Data__c FROM Account WHERE Id = :acc.Id];
    BI_Data__c bi2 = [
      SELECT Sub_Division_Account__c
      FROM BI_Data__c
      WHERE Id = :acc2.BI_Data__c
    ];
    bi2.Sub_Division_Account__c = SUB_DIVISION;
    update bi2;
  }

  /**
   * @description run the batch
   * @expected The account territory was updated
   *           The team member on the account has only one member
   * */
  @istest
  public static void testBatch() {
    //alon
    Test.startTest();
    String CRON_EXP = '0 0 0 3 9 ? 2100';
    System.schedule(
      'TerritoryManagementBatchTest',
      CRON_EXP,
      new TerritoryManagementBatch(true)
    );
    Database.executeBatch(new TerritoryManagementBatch(true), 5);
    Test.stopTest();
    //assert
    Territory__c territory = [SELECT Id FROM Territory__c];
    Account accAfter = [
      SELECT Territory_Evaluation_Formula__c, Territory__c
      FROM Account
      WHERE Industry_Subtype__c != NULL
    ];
    system.debug('@@@ accAfter-- ' + accAfter);
    system.assertEquals(
      territory.Id,
      accAfter.Territory__c,
      'Account didnt not get populated'
    );
    List<AccountTeamMember> accountTeamMembers = [
      SELECT Id
      FROM AccountTeamMember
      WHERE AccountId = :accAfter.Id
    ];
    system.assertEquals(
      accountTeamMembers.size(),
      1,
      'Account team members was not created properly '
    );
  }
}

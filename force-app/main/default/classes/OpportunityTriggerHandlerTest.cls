@istest
public class OpportunityTriggerHandlerTest {
  @testSetup
  static void setup() {
    System.runAs(new User(Id = UserInfo.getUserId())) {
      Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
      iss.Name = 'Default Value';
      iss.Value__c = 'Sales';
      insert iss;

      InferralSolutionMap__c ismTest = new InferralSolutionMap__c();
      ismTest.SW_Industry__c = 'AdTech and AdNetwork';
      ismTest.Department__c = 'BI / Analytics';
      ismTest.Inferred_Solution__c = 'Research';
      ismTest.Name = 'test';
      insert ismTest;

      InferralSolutionMapContact__c ismCTest = new InferralSolutionMapContact__c();
      ismCTest.SW_Industry__c = 'AdTech and AdNetwork';
      ismTest.Department__c = 'BI / Analytics';
      ismCTest.Inferred_Solution__c = 'Research';
      ismCTest.Name = 'test';
      insert ismCTest;

      Inferral_Solution_Valid_Criteria_List__c islvcl = new Inferral_Solution_Valid_Criteria_List__c();
      islvcl.Name = 'department__c';
      islvcl.Is_Valid__c = true;
      insert islvcl;

      Inferral_Solution_Valid_Criteria_List__c islvcl2 = new Inferral_Solution_Valid_Criteria_List__c();
      islvcl2.Name = 'sw_industry__c';
      islvcl2.Is_Valid__c = true;
      insert islvcl2;

      InferralSolutionCValidCriteriaList__c islcvcl = new InferralSolutionCValidCriteriaList__c();
      islcvcl.Name = 'department__c';
      islcvcl.Is_Valid__c = true;
      insert islcvcl;

      InferralSolutionCValidCriteriaList__c islcvcl2 = new InferralSolutionCValidCriteriaList__c();
      islcvcl2.Name = 'sw_industry__c';
      islcvcl2.Is_Valid__c = true;
      insert islcvcl2;

      //            SimilarWeb_Settings__c currentSettings = new SimilarWeb_Settings__c();
      //            currentSettings.API_Key__c='test';
      //            currentSettings.Create_Date_TimeFrame__c='test';
      //            currentSettings.Enriched_Entities__c='[]';
      //            currentSettings.Invisible_Fields__c='test';
      //            currentSettings.Refresh_Data_Interval__c=0;
      //            currentSettings.Sync_on_create_and_update__c=true;
      //            insert currentSettings;

      Account acc = new Account(
        Name = 'Account_for_user',
        Business_unit__c = 'Inside Sales'
      );
      insert acc;
      Zuora__CustomerAccount__c zca = TestObjectCreator.CreateBillingAccount(
        acc
      );
      zca.Zuora__AccountNumber__c = '123';
      zca.Zuora__DefaultPaymentMethod__c = 'WireTransfer';
      zca.Zuora__BillToWorkEmail__c = 'test@test.com';
      zca.Zuora__Currency__c = 'USD';
      insert zca;
      Zuora__Subscription__c zs = new Zuora__Subscription__c();
      zs.Zuora__Account__c = acc.Id;
      zs.Zuora__Status__c = 'active';
      zs.Zuora__NextRenewalDate__c = Date.today();
      zs.Zuora__SubscriptionEndDate__c = Date.today();
      zs.Zuora__Version__c = 8;
      zs.Zuora__External_Id__c = '8a80c11172b9d0dc01742a94b176269b';
      zs.Zuora__MRR__c = 20000;
      zs.Zuora__CustomerAccount__c = zca.id;
      insert zs;

      User communityUser = createUser(acc);
      insert communityUser;
    }

  }

  @istest
  public static void test() {
    String recordTypeID = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = 'Wolves' AND SobjectType = 'Opportunity'
      LIMIT 1
    ]
    .Id;
    String wrongRecordTypeID = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName != 'Wolves' AND SobjectType = 'Opportunity'
      LIMIT 1
    ]
    .Id;

    Account acc = [
      SELECT Id, Name, Business_unit__c
      FROM Account
      WHERE Name = 'Account_for_user'
    ]; //account whose opps will be visible
    Account acc2 = new Account(
      Name = 'Account_for_user_2',
      Business_unit__c = 'Inside Sales'
    );
    insert acc2;
    System.debug('Point limit - ' + Limits.getQueries());
    Test.startTest();
    List<Opportunity> opps = new List<opportunity>{
      new Opportunity(
        AccountId = acc.Id,
        RecordTypeId = wrongRecordTypeID,
        Name = 'Acc1_Opportunity_1',
        Type = 'New Sell',
        Cycle__c = 'Annually',
        CloseDate = DAte.today(),
        Cycle_Price__c = 123,
        StageName = 'Prospect',
        Similarweb_Forecasting_status__c = 'Pipeline'
      ),
      new Opportunity(
        AccountId = acc2.Id,
        RecordTypeId = wrongRecordTypeID,
        Name = 'Acc2_Opportunity_1',
        Type = 'New Sell',
        Cycle__c = 'Annually',
        CloseDate = DAte.today(),
        Cycle_Price__c = 123,
        StageName = 'Prospect',
        Similarweb_Forecasting_status__c = 'Pipeline'
      )
    };
    insert opps;
    System.debug('Point2 limit - ' + Limits.getQueries());
    Opportunity newOpp = new Opportunity(
      AccountId = acc.Id,
      Name = 'Acc1_Opportunity_2',
      Type = 'New Sell',
      Cycle__c = 'Annually',
      CloseDate = DAte.today(),
      Cycle_Price__c = 123,
      StageName = 'Prospect',
      RecordTypeID = recordTypeID,
      Similarweb_Forecasting_status__c = 'Pipeline'
    );
    insert newOpp;
    System.debug('Point3 limit - ' + Limits.getQueries());
    newOpp.AccountId = acc2.Id;
    update newOpp;
    Test.stopTest();
    System.debug('Point4 limit - ' + Limits.getQueries());
  }

  private static User createUser(Account acc) {
    Profile profileItem = [
      SELECT Id
      FROM Profile
      WHERE Name = :Label.Community_User_Profile_Name
    ];
    Contact testContact = new Contact(
      LastName = 'Contact_for_user',
      Email = 'partner@user.com',
      AccountId = acc.Id
    );
    insert testContact;
    User u = new User(
      Alias = 'standt',
      Email = 'standarduser@testorg.com',
      EmailEncodingKey = 'UTF-8',
      FirstName = 'Testing',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = profileItem.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'adminuser1@testorg.com',
      ContactId = testContact.Id
    );
    return u;
  }

  @istest
  public static void testClosedLostOpp() {
    Account acc = [
      SELECT Id, Name, Business_unit__c
      FROM Account
      WHERE Name = 'Account_for_user'
    ]; //account whose opps will be visible
    Test.startTest();
    Opportunity newOpp = new Opportunity(
      AccountId = acc.Id,
      Name = 'Acc1_Opportunity_2',
      Type = 'New Sell',
      Cycle__c = 'Annually',
      CloseDate = DAte.today(),
      Cycle_Price__c = 123,
      StageName = 'Closed Lost',
      Closed_Lost_Reason__c = 'test reason 1',
      Closed_Lost_Reason_More_details__c = 'more details',
      Closed_Lost_Reason_2__c = 'whatever',
      Opp_will_be_relevant__c = '90 days',
      Solution_Fit__c = 'Marketing: SEO / Content'
    );
    insert newOpp;

    newOpp.StageName = 'Prospect';
    update newOpp;

    Opportunity updated = [
      SELECT
        id,
        Opp_will_be_relevant__c,
        SYS_CloseFlow__c,
        Closed_Lost_Reason__c,
        Closed_Lost_Reason_More_details__c,
        Solution_Fit__c
      FROM Opportunity
      WHERE Id = :newOpp.Id
    ]; //
    System.assertEquals(null, updated.Closed_Lost_Reason__c);
    System.assertEquals(null, updated.Opp_will_be_relevant__c);
    updated.Closed_Lost_Reason__c = 'test reason 1';
    updated.Closed_Lost_Reason_More_details__c = 'more details';
    updated.Opp_will_be_relevant__c = '90 days';
    updated.StageName = 'Closed Lost';
    updated.SYS_CloseFlow__c = true;
    update updated;
    //updated = [select id, SYS_CloseFlow__c from Opportunity where Id=:newOpp.Id];
    //System.assertEquals(false, updated.SYS_CloseFlow__c);
    Test.stopTest();
  }

  @isTest
  private static void testSetForecastCategoryName_onInsert() {
    String recordTypeID = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName != 'Wolves' AND SobjectType = 'Opportunity'
      LIMIT 1
    ]
    .Id;
    Account acc = [
      SELECT Id, Name, Business_unit__c
      FROM Account
      WHERE Name = 'Account_for_user'
    ];

    Test.startTest();
    Opportunity opp = new Opportunity(
      AccountId = acc.Id,
      StageName = 'Prospecting',
      RecordTypeId = recordTypeID,
      Name = 'Acc1_Opportunity_1',
      CloseDate = Date.today().addDays(1),
      SFF_Commit__c = true
    );
    insert opp;
    Test.stopTest();

    opp = [SELECT ForecastCategoryName FROM Opportunity WHERE Id = :opp.Id];
    System.assertEquals('Commit', opp.ForecastCategoryName);
  }

  @isTest
  private static void testSetForecastCategoryName_onUpdate() {
    String recordTypeID = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName != 'Wolves' AND SobjectType = 'Opportunity'
      LIMIT 1
    ]
    .Id;
    Account acc = [
      SELECT Id, Name, Business_unit__c
      FROM Account
      WHERE Name = 'Account_for_user'
    ];

    Test.startTest();
    Opportunity opp = new Opportunity(
      AccountId = acc.Id,
      StageName = 'Prospecting',
      RecordTypeId = recordTypeID,
      Name = 'Acc1_Opportunity_1',
      CloseDate = Date.today().addDays(1),
      SFF_Commit__c = false
    );
    insert opp;

    opp = [SELECT ForecastCategoryName FROM Opportunity WHERE Id = :opp.Id];
    System.assert(!'Commit'.equalsIgnoreCase(opp.ForecastCategoryName));
    opp.SFF_Commit__c = true;
    update opp;
    Test.stopTest();

    opp = [SELECT ForecastCategoryName FROM Opportunity WHERE Id = :opp.Id];
    System.assertEquals('Commit', opp.ForecastCategoryName);
  }

  //    @IsTest
  //    public static void testHandleRenewalOppFromFutureUpsell() {
  //        Account acc = [SELECT Id FROM Account WHERE Name = 'Account_for_user' LIMIT 1];
  //
  //        // Step 1: Create initial Opportunity record with a specific Opp_Reviewed__c value
  //        Opportunity initialOpportunity = new Opportunity(
  //                AccountId = acc.Id,
  //                StageName = 'Closed Won',
  //                CloseDate = Date.today(),
  //                Type = 'Upsell',
  //                Opp_Reviewed__c = 'Pending Billing',  // Initial state,
  //                Probability = 0.1,
  //                Overwrite_ARR__c = 5
  //        );
  //        Opportunity renewalOpp = new Opportunity(
  //                AccountId = acc.Id,
  //                StageName = 'Initial Discovery',
  //                CloseDate = Date.today(),
  //                Type = 'Renewal',
  //                Probability = 0.1,
  //                Overwrite_ARR__c = 5
  //        );
  //        insert new List<Opportunity>{initialOpportunity,renewalOpp};
  //
  //        // Step 2: Update the Opportunity record to change Opp_Reviewed__c and trigger logic
  //        Opportunity updatedOpportunity = new Opportunity(
  //                Id = initialOpportunity.Id,
  //                Opp_Reviewed__c = 'Eden Loren'  // New state that should trigger the logic
  //        );
  //
  //        Test.startTest();
  //
  //        // Update the opportunity to trigger the logic
  //        update updatedOpportunity;
  //
  //        Test.stopTest();
  //    }

  @IsTest
  static void testHandleRenewalOppFromFutureUpsell() {
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Name = 'Account_for_user'
      LIMIT 1
    ];

    Opportunity initialOpportunity = new Opportunity(
      AccountId = acc.Id,
      StageName = 'Closed Won',
      CloseDate = Date.today(),
      Type = 'Upsell',
      Opp_Reviewed__c = 'Pending Legal',
      Overwrite_ARR__c = 5
    );
    Opportunity renewalOpp = new Opportunity(
      AccountId = acc.Id,
      StageName = 'Initial Discovery',
      CloseDate = Date.today(),
      Type = 'Renewal',
      Overwrite_ARR__c = 5
    );

    Test.startTest();
    insert new List<Opportunity>{ initialOpportunity, renewalOpp };

    Opportunity updatedOpportunity = new Opportunity(
      Id = initialOpportunity.Id,
      Opp_Reviewed__c = 'Monica Nguyen'
    );
    update updatedOpportunity;
    Test.stopTest();
  }
}

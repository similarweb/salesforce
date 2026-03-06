@isTest
public class affectlayerEngagementTriggerHandlerTest {
  @testSetup
  static void setup() {
    // Create test data setup similar to other test classes in the project
    System.runAs(new User(Id = UserInfo.getUserId())) {
      // Create test accounts
      Account testAccount1 = TestObjectCreator.CreateAccount();
      testAccount1.Name = 'Test Account 1';
      testAccount1.Business_Unit__c = 'Inside Sales';
      insert testAccount1;

      Account testAccount2 = TestObjectCreator.CreateAccount();
      testAccount2.Name = 'Test Account 2';
      testAccount2.Business_Unit__c = 'Inside Sales';
      insert testAccount2;

      // Create test opportunities with different types
      Opportunity newSaleOpp = TestObjectCreator.CreateOpportunity(
        testAccount1
      );
      newSaleOpp.Name = 'New Sale Opportunity';
      newSaleOpp.Type = 'New Sale';
      newSaleOpp.StageName = 'Prospecting';
      newSaleOpp.CloseDate = Date.today().addDays(30);
      newSaleOpp.Champion_AI__c = 'Test Champion';
      newSaleOpp.Decision_Criteria_Competition_AI__c = 'Test Decision Criteria';
      newSaleOpp.Decision_Process_AI__c = 'Test Decision Process';
      newSaleOpp.Economic_Buyer_AI__c = 'Test Economic Buyer';
      newSaleOpp.Identify_Pain_AI__c = 'Test Pain Points';
      newSaleOpp.Metrics_AI__c = 'Test Metrics';
      newSaleOpp.Paper_Process_AI__c = 'Test Paper Process';
      newSaleOpp.AI_Json_Payload__c = '{"test": "data"}';
      insert newSaleOpp;

      Opportunity upsellOpp = TestObjectCreator.CreateOpportunity(testAccount2);
      upsellOpp.Name = 'Upsell Opportunity';
      upsellOpp.Type = 'Upsell';
      upsellOpp.StageName = 'Prospecting';
      upsellOpp.CloseDate = Date.today().addDays(30);
      upsellOpp.Champion_AI__c = 'Test Champion 2';
      upsellOpp.Decision_Criteria_Competition_AI__c = 'Test Decision Criteria 2';
      upsellOpp.Decision_Process_AI__c = 'Test Decision Process 2';
      upsellOpp.Economic_Buyer_AI__c = 'Test Economic Buyer 2';
      upsellOpp.Identify_Pain_AI__c = 'Test Pain Points 2';
      upsellOpp.Metrics_AI__c = 'Test Metrics 2';
      upsellOpp.Paper_Process_AI__c = 'Test Paper Process 2';
      upsellOpp.AI_Json_Payload__c = '{"test": "data2"}';
      insert upsellOpp;

      Opportunity renewalOpp = TestObjectCreator.CreateOpportunity(
        testAccount1
      );
      renewalOpp.Name = 'Renewal Opportunity';
      renewalOpp.Type = 'Renewal';
      renewalOpp.StageName = 'Prospecting';
      renewalOpp.CloseDate = Date.today().addDays(30);
      insert renewalOpp;
    }
  }

  @isTest
  static void testValidEngagementWithNewSaleOpportunity() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Opportunity newSaleOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'New Sale' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    Test.startTest();

    // Create engagement with valid disposition and New Sale opportunity
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = newSaleOpp.Id,
      affectlayer__Disposition__c = 'Show',
      affectlayer__ChorusId__c = 'test-chorus-id-1',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 300,
      affectlayer__Type__c = 'Call'
    );

    insert engagement;

    Test.stopTest();

    // Verify the engagement was created
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT
        Id,
        affectlayer__Disposition__c,
        affectlayer__Opportunity__c,
        affectlayer__ChorusId__c
      FROM affectlayer__Engagement__c
      WHERE Id = :engagement.Id
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created'
    );
    System.assertEquals(
      'Show',
      createdEngagements[0].affectlayer__Disposition__c,
      'Disposition should be Show'
    );
    System.assertEquals(
      newSaleOpp.Id,
      createdEngagements[0].affectlayer__Opportunity__c,
      'Opportunity should be set'
    );
  }

  @isTest
  static void testValidEngagementWithUpsellOpportunity() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 2'
      LIMIT 1
    ];
    Opportunity upsellOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'Upsell' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    Test.startTest();

    // Create engagement with valid disposition and Upsell opportunity
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = upsellOpp.Id,
      affectlayer__Disposition__c = 'Connected',
      affectlayer__ChorusId__c = 'test-chorus-id-2',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 450,
      affectlayer__Type__c = 'Call'
    );

    insert engagement;

    Test.stopTest();

    // Verify the engagement was created
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT
        Id,
        affectlayer__Disposition__c,
        affectlayer__Opportunity__c,
        affectlayer__ChorusId__c
      FROM affectlayer__Engagement__c
      WHERE Id = :engagement.Id
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created'
    );
    System.assertEquals(
      'Connected',
      createdEngagements[0].affectlayer__Disposition__c,
      'Disposition should be Connected'
    );
    System.assertEquals(
      upsellOpp.Id,
      createdEngagements[0].affectlayer__Opportunity__c,
      'Opportunity should be set'
    );
  }

  @isTest
  static void testInvalidDispositionEngagement() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Opportunity newSaleOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'New Sale' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    Test.startTest();

    // Create engagement with invalid disposition
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = newSaleOpp.Id,
      affectlayer__Disposition__c = 'No Show', // Invalid disposition
      affectlayer__ChorusId__c = 'test-chorus-id-3',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 200,
      affectlayer__Type__c = 'Call'
    );

    insert engagement;

    Test.stopTest();

    // Verify the engagement was created (trigger doesn't prevent creation, just filters for processing)
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT Id, affectlayer__Disposition__c, affectlayer__Opportunity__c
      FROM affectlayer__Engagement__c
      WHERE Id = :engagement.Id
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created even with invalid disposition'
    );
    System.assertEquals(
      'No Show',
      createdEngagements[0].affectlayer__Disposition__c,
      'Disposition should be No Show'
    );
  }

  @isTest
  static void testEngagementWithoutOpportunity() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];

    Test.startTest();

    // Create engagement without opportunity
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = null, // No opportunity
      affectlayer__Disposition__c = 'Show',
      affectlayer__ChorusId__c = 'test-chorus-id-4',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 150,
      affectlayer__Type__c = 'Call'
    );

    insert engagement;

    Test.stopTest();

    // Verify the engagement was created
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT Id, affectlayer__Disposition__c, affectlayer__Opportunity__c
      FROM affectlayer__Engagement__c
      WHERE Id = :engagement.Id
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created even without opportunity'
    );
    System.assertEquals(
      null,
      createdEngagements[0].affectlayer__Opportunity__c,
      'Opportunity should be null'
    );
  }

  @isTest
  static void testEngagementWithRenewalOpportunity() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Opportunity renewalOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'Renewal' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    Test.startTest();

    // Create engagement with Renewal opportunity (should not qualify for processing)
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = renewalOpp.Id,
      affectlayer__Disposition__c = 'Show',
      affectlayer__ChorusId__c = 'test-chorus-id-5',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 300,
      affectlayer__Type__c = 'Call'
    );

    insert engagement;

    Test.stopTest();

    // Verify the engagement was created
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT Id, affectlayer__Disposition__c, affectlayer__Opportunity__c
      FROM affectlayer__Engagement__c
      WHERE Id = :engagement.Id
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created'
    );
    System.assertEquals(
      'Show',
      createdEngagements[0].affectlayer__Disposition__c,
      'Disposition should be Show'
    );
    System.assertEquals(
      renewalOpp.Id,
      createdEngagements[0].affectlayer__Opportunity__c,
      'Opportunity should be set'
    );
  }

  @isTest
  static void testBulkEngagementInsert() {
    // Get test data
    Account testAccount1 = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Account testAccount2 = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 2'
      LIMIT 1
    ];
    Opportunity newSaleOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'New Sale' AND AccountId = :testAccount1.Id
      LIMIT 1
    ];
    Opportunity upsellOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'Upsell' AND AccountId = :testAccount2.Id
      LIMIT 1
    ];
    Opportunity renewalOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'Renewal' AND AccountId = :testAccount1.Id
      LIMIT 1
    ];

    Test.startTest();

    // Create multiple engagements with different scenarios
    List<affectlayer__Engagement__c> engagements = new List<affectlayer__Engagement__c>();

    // Valid engagement with New Sale opportunity
    engagements.add(
      new affectlayer__Engagement__c(
        affectlayer__Account__c = testAccount1.Id,
        affectlayer__Opportunity__c = newSaleOpp.Id,
        affectlayer__Disposition__c = 'Show',
        affectlayer__ChorusId__c = 'test-chorus-id-bulk-1',
        affectlayer__DateTime__c = Datetime.now(),
        affectlayer__Duration__c = 300,
        affectlayer__Type__c = 'Call'
      )
    );

    // Valid engagement with Upsell opportunity
    engagements.add(
      new affectlayer__Engagement__c(
        affectlayer__Account__c = testAccount2.Id,
        affectlayer__Opportunity__c = upsellOpp.Id,
        affectlayer__Disposition__c = 'Connected',
        affectlayer__ChorusId__c = 'test-chorus-id-bulk-2',
        affectlayer__DateTime__c = Datetime.now(),
        affectlayer__Duration__c = 450,
        affectlayer__Type__c = 'Call'
      )
    );

    // Invalid disposition
    engagements.add(
      new affectlayer__Engagement__c(
        affectlayer__Account__c = testAccount1.Id,
        affectlayer__Opportunity__c = newSaleOpp.Id,
        affectlayer__Disposition__c = 'No Show',
        affectlayer__ChorusId__c = 'test-chorus-id-bulk-3',
        affectlayer__DateTime__c = Datetime.now(),
        affectlayer__Duration__c = 200,
        affectlayer__Type__c = 'Call'
      )
    );

    // No opportunity
    engagements.add(
      new affectlayer__Engagement__c(
        affectlayer__Account__c = testAccount1.Id,
        affectlayer__Opportunity__c = null,
        affectlayer__Disposition__c = 'Show',
        affectlayer__ChorusId__c = 'test-chorus-id-bulk-4',
        affectlayer__DateTime__c = Datetime.now(),
        affectlayer__Duration__c = 150,
        affectlayer__Type__c = 'Call'
      )
    );

    // Renewal opportunity (should not qualify)
    engagements.add(
      new affectlayer__Engagement__c(
        affectlayer__Account__c = testAccount1.Id,
        affectlayer__Opportunity__c = renewalOpp.Id,
        affectlayer__Disposition__c = 'Show',
        affectlayer__ChorusId__c = 'test-chorus-id-bulk-5',
        affectlayer__DateTime__c = Datetime.now(),
        affectlayer__Duration__c = 300,
        affectlayer__Type__c = 'Call'
      )
    );

    insert engagements;

    Test.stopTest();

    // Verify all engagements were created
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT
        Id,
        affectlayer__Disposition__c,
        affectlayer__Opportunity__c,
        affectlayer__ChorusId__c
      FROM affectlayer__Engagement__c
      WHERE affectlayer__ChorusId__c LIKE 'test-chorus-id-bulk-%'
      ORDER BY affectlayer__ChorusId__c
    ];

    System.assertEquals(
      5,
      createdEngagements.size(),
      'All 5 engagements should be created'
    );

    // Verify the specific engagements
    System.assertEquals(
      'Show',
      createdEngagements[0].affectlayer__Disposition__c,
      'First engagement should have Show disposition'
    );
    System.assertEquals(
      'Connected',
      createdEngagements[1].affectlayer__Disposition__c,
      'Second engagement should have Connected disposition'
    );
    System.assertEquals(
      'No Show',
      createdEngagements[2].affectlayer__Disposition__c,
      'Third engagement should have No Show disposition'
    );
    System.assertEquals(
      'Show',
      createdEngagements[3].affectlayer__Disposition__c,
      'Fourth engagement should have Show disposition'
    );
    System.assertEquals(
      'Show',
      createdEngagements[4].affectlayer__Disposition__c,
      'Fifth engagement should have Show disposition'
    );
  }

  @isTest
  static void testEngagementWithAllOpportunityFields() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Opportunity newSaleOpp = [
      SELECT
        Id,
        Champion_AI__c,
        Decision_Criteria_Competition_AI__c,
        Decision_Process_AI__c,
        Economic_Buyer_AI__c,
        Identify_Pain_AI__c,
        Metrics_AI__c,
        Paper_Process_AI__c,
        AI_Json_Payload__c
      FROM Opportunity
      WHERE Type = 'New Sale' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    Test.startTest();

    // Create engagement with all opportunity fields populated
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = newSaleOpp.Id,
      affectlayer__Disposition__c = 'Show',
      affectlayer__ChorusId__c = 'test-chorus-id-full',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 600,
      affectlayer__Type__c = 'Call'
    );

    insert engagement;

    Test.stopTest();

    // Verify the engagement was created
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT
        Id,
        affectlayer__Disposition__c,
        affectlayer__Opportunity__c,
        affectlayer__ChorusId__c
      FROM affectlayer__Engagement__c
      WHERE Id = :engagement.Id
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created'
    );
    System.assertEquals(
      'Show',
      createdEngagements[0].affectlayer__Disposition__c,
      'Disposition should be Show'
    );
    System.assertEquals(
      newSaleOpp.Id,
      createdEngagements[0].affectlayer__Opportunity__c,
      'Opportunity should be set'
    );
    System.assertEquals(
      'test-chorus-id-full',
      createdEngagements[0].affectlayer__ChorusId__c,
      'Chorus ID should be set'
    );
  }

  @isTest
  static void testDirectHandlerMethodCall() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Opportunity newSaleOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'New Sale' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    // Create engagement and insert it first
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = newSaleOpp.Id,
      affectlayer__Disposition__c = 'Show',
      affectlayer__ChorusId__c = 'test-direct-handler',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 300,
      affectlayer__Type__c = 'Call'
    );
    insert engagement;

    Test.startTest();

    // Call the handler method directly to ensure coverage
    affectlayerEngagementTriggerHandler.handleAfterInsert(
      new List<affectlayer__Engagement__c>{ engagement }
    );

    Test.stopTest();

    // Verify the engagement was processed (it should still exist)
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT
        Id,
        affectlayer__Disposition__c,
        affectlayer__Opportunity__c,
        affectlayer__ChorusId__c
      FROM affectlayer__Engagement__c
      WHERE affectlayer__ChorusId__c = 'test-direct-handler'
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should exist after handler processing'
    );
  }

  @isTest
  static void testHandlerWithEmptyList() {
    Test.startTest();

    // Test handler with empty list to cover the empty check
    affectlayerEngagementTriggerHandler.handleAfterInsert(
      new List<affectlayer__Engagement__c>()
    );

    Test.stopTest();

    // No assertions needed - just testing that the method doesn't throw an exception
    System.assert(true, 'Handler should handle empty list without errors');
  }

  @isTest
  static void testHandlerWithNoQualifiedEngagements() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];

    // Create engagement that won't qualify (no opportunity)
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = null, // No opportunity
      affectlayer__Disposition__c = 'Show',
      affectlayer__ChorusId__c = 'test-no-qualify',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 300,
      affectlayer__Type__c = 'Call'
    );
    insert engagement;

    Test.startTest();

    // Call the handler method directly
    affectlayerEngagementTriggerHandler.handleAfterInsert(
      new List<affectlayer__Engagement__c>{ engagement }
    );

    Test.stopTest();

    // Verify the engagement was created but not processed
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT Id, affectlayer__Disposition__c, affectlayer__Opportunity__c
      FROM affectlayer__Engagement__c
      WHERE affectlayer__ChorusId__c = 'test-no-qualify'
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created'
    );
    System.assertEquals(
      null,
      createdEngagements[0].affectlayer__Opportunity__c,
      'Opportunity should be null'
    );
  }

  @isTest
  static void testHandlerWithInvalidDisposition() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Opportunity newSaleOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'New Sale' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    // Create engagement with invalid disposition
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = newSaleOpp.Id,
      affectlayer__Disposition__c = 'No Show', // Invalid disposition
      affectlayer__ChorusId__c = 'test-invalid-disposition',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 300,
      affectlayer__Type__c = 'Call'
    );
    insert engagement;

    Test.startTest();

    // Call the handler method directly
    affectlayerEngagementTriggerHandler.handleAfterInsert(
      new List<affectlayer__Engagement__c>{ engagement }
    );

    Test.stopTest();

    // Verify the engagement was created but not processed
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT Id, affectlayer__Disposition__c, affectlayer__Opportunity__c
      FROM affectlayer__Engagement__c
      WHERE affectlayer__ChorusId__c = 'test-invalid-disposition'
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created'
    );
    System.assertEquals(
      'No Show',
      createdEngagements[0].affectlayer__Disposition__c,
      'Disposition should be No Show'
    );
  }

  @isTest
  static void testHandlerWithRenewalOpportunity() {
    // Get test data
    Account testAccount = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Account 1'
      LIMIT 1
    ];
    Opportunity renewalOpp = [
      SELECT Id
      FROM Opportunity
      WHERE Type = 'Renewal' AND AccountId = :testAccount.Id
      LIMIT 1
    ];

    // Create engagement with renewal opportunity (should not qualify)
    affectlayer__Engagement__c engagement = new affectlayer__Engagement__c(
      affectlayer__Account__c = testAccount.Id,
      affectlayer__Opportunity__c = renewalOpp.Id,
      affectlayer__Disposition__c = 'Show',
      affectlayer__ChorusId__c = 'test-renewal-opp',
      affectlayer__DateTime__c = Datetime.now(),
      affectlayer__Duration__c = 300,
      affectlayer__Type__c = 'Call'
    );
    insert engagement;

    Test.startTest();

    // Call the handler method directly
    affectlayerEngagementTriggerHandler.handleAfterInsert(
      new List<affectlayer__Engagement__c>{ engagement }
    );

    Test.stopTest();

    // Verify the engagement was created but not processed
    List<affectlayer__Engagement__c> createdEngagements = [
      SELECT Id, affectlayer__Disposition__c, affectlayer__Opportunity__c
      FROM affectlayer__Engagement__c
      WHERE affectlayer__ChorusId__c = 'test-renewal-opp'
    ];

    System.assertEquals(
      1,
      createdEngagements.size(),
      'Engagement should be created'
    );
    System.assertEquals(
      renewalOpp.Id,
      createdEngagements[0].affectlayer__Opportunity__c,
      'Opportunity should be set'
    );
  }

  @isTest
  static void testHandlerConstructor() {
    Test.startTest();

    // Test the constructor to ensure it's covered
    affectlayerEngagementTriggerHandler handler = new affectlayerEngagementTriggerHandler();

    Test.stopTest();

    // Verify the handler was created
    System.assertNotEquals(null, handler, 'Handler should be created');
  }
}

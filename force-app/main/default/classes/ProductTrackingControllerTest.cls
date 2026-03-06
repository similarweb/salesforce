@IsTest
public class ProductTrackingControllerTest {
  @TestSetup
  static void setUp() {
    Account acc = new Account(Name = 'Test');
    insert acc;

    Opportunity opp = new Opportunity(
      Name = 'Test',
      CloseDate = Date.today(),
      StageName = 'In Progress',
      AccountId = acc.Id,
      Pricebook2Id = Test.getStandardPricebookId()
    );
    insert opp;

    Product2 solution = new Product2(
      Name = 'Test',
      Family = 'App Intelligence',
      New_Business__c = true,
      IsActive = true,
      Product_Tracking__c = true,
      ProductType__c = 'Solution / Delivery'
    );
    insert solution;
    Product2 sku = new Product2(
      Name = 'Test2',
      Family = 'App Intelligence',
      New_Business__c = true,
      IsActive = true,
      Product_Tracking__c = true,
      ProductType__c = 'SKU',
      Parent_Product__c = solution.Id
    );
    insert sku;

    PricebookEntry entry = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = solution.Id,
      UnitPrice = 123,
      IsActive = true
    );
    insert entry;
    PricebookEntry entry2 = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = sku.Id,
      UnitPrice = 123,
      IsActive = true
    );
    insert entry2;
  }

  @IsTest
  static void getDataTest() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

    Test.startTest();
    Map<String, Object> result = ProductTrackingController.getData(opp.Id);

    Test.stopTest();

    List<ProductTrackingController.ParentPDTO> solutions = (List<ProductTrackingController.ParentPDTO>) result.get(
      'solutions'
    );

    solutions.get(0).open = true;
    solutions.get(0).products.get('New Sale').get(0).selected = true;

    String res = ProductTrackingController.saveData(
      JSON.serialize(
        new Map<String, String>{
          'oppId' => opp.Id,
          'subType' => 'New Sale',
          'solutions' => JSON.serialize(solutions)
        }
      )
    );

    System.assertEquals(true, solutions.size() > 0);
    System.assertEquals('Success', res);
  }

  @IsTest
  static void saveDataTest() {
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

    Test.startTest();
    Map<String, Object> result = ProductTrackingController.getData(opp.Id);
    Test.stopTest();

    List<ProductTrackingController.ParentPDTO> solutions = (List<ProductTrackingController.ParentPDTO>) result.get(
      'solutions'
    );

    System.assertEquals(true, solutions.size() > 0);
  }
}

@isTest
public class ProductRatePlanChargeActionContTest {
  @testSetup
  public static void setupDataForTest() {
    zqu__ProductRatePlanCharge__c prpc = new zqu__ProductRatePlanCharge__c(
      zqu__DefaultQuantity__c = 3
    );
    insert prpc;
  }

  @isTest
  public static void defaultQuantityToZeroRemoteTest() {
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM zqu__ProductRatePlanCharge__c
          WHERE zqu__DefaultQuantity__c = 1
        ]
        .size()
    );
    Test.startTest();
    Integer count = ProductRatePlanChargeActionController.defaultQuantityToZeroRemote();
    Test.stopTest();
    System.assertEquals(
      count,
      [
          SELECT Id
          FROM zqu__ProductRatePlanCharge__c
          WHERE zqu__DefaultQuantity__c = 1
        ]
        .size()
    );
  }
}

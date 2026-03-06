/****************************************************************************************************************
Name                		: ProductRatePlanChargeController
Description         		: Select zqu__ProductRatePlanCharge__c. If zqu__DefaultQuantity__c != 1, then zqu__DefaultQuantity__c=0 
Related components 		: 

Created/Modified by               Created/Modified Date           Requested by           Related Task/Issue             
-----------------------------------------------------------------------------------------------------------------
1. Dmitry Trufanov (Synebo)            11.03.2019               Dmitry Trufanov			    [SW-9504] 
****************************************************************************************************************/
@isTest
public class ProductRatePlanChargeControllerTest {

    @testSetup
    static void setup(){
        zqu__ProductRatePlanCharge__c prpc = new zqu__ProductRatePlanCharge__c(zqu__DefaultQuantity__c=3);
        insert prpc;
    }
    
    @isTest static void productRatePlanChargeControllerTest() {
        String s = ProductRatePlanChargeController.defaultQuantityToZero();
        System.assertEquals(0, [SELECT Id,zqu__DefaultQuantity__c FROM zqu__ProductRatePlanCharge__c where zqu__DefaultQuantity__c=3].size());
    }
}
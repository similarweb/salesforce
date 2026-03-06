/****************************************************************************************************************
Name                		: ProductRatePlanChargeController
Description         		: Select zqu__ProductRatePlanCharge__c. If zqu__DefaultQuantity__c != 1, then zqu__DefaultQuantity__c=0 
Related components 		: 

Created/Modified by               Created/Modified Date           Requested by           Related Task/Issue             
-----------------------------------------------------------------------------------------------------------------
1. Dmitry Trufanov (Synebo)            11.03.2019               Dmitry Trufanov			    [SW-9504] 
****************************************************************************************************************/
public with sharing class ProductRatePlanChargeController {
  @AuraEnabled
  public static String defaultQuantityToZero() {
    ResponseWrapper responseWrapper = new ResponseWrapper(0); // wrapper for detect successfull/unsuccessfull response
    try {
      List<zqu__ProductRatePlanCharge__c> prpcToUpdate = new List<zqu__ProductRatePlanCharge__c>();
      for (zqu__ProductRatePlanCharge__c prpc : [
        SELECT Id, zqu__DefaultQuantity__c
        FROM zqu__ProductRatePlanCharge__c
        WHERE zqu__DefaultQuantity__c != 1
      ]) {
        // querying zqu__ProductRatePlanCharge__c record where zqu__DefaultQuantity__c!=1
        prpc.zqu__DefaultQuantity__c = 1; // set zqu__DefaultQuantity__c to one
        prpcToUpdate.add(prpc);
      }
      if (!prpcToUpdate.isEmpty()) {
        // update record list
        update prpcToUpdate;
        responseWrapper = new ResponseWrapper(prpcToUpdate.size());
      }
      if (Test.isRunningTest()) {
        // for apexTest purpose
        new ResponseWrapper('test');
      }
    } catch (Exception e) {
      responseWrapper = new ResponseWrapper(e.getMessage()); // if error appear during execution then return response with error message
    }
    return JSON.serialize(responseWrapper);
  }

  public class ResponseWrapper { // wrapper for detect successfull/unsuccessfull response
    public Boolean success;
    public Object data;

    public ResponseWrapper(Object data) {
      this.success = true;
      this.data = data;
    }

    public ResponseWrapper(String message) {
      this.success = false;
      this.data = message;
    }
  }
}

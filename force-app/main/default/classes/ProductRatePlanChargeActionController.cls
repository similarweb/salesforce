global with sharing class ProductRatePlanChargeActionController {
	
    webservice static Integer defaultQuantityToZeroRemote(){
        Integer updatedRecord = 0;
        try{            
            List<zqu__ProductRatePlanCharge__c> prpcToUpdate = new List<zqu__ProductRatePlanCharge__c>();
            for(zqu__ProductRatePlanCharge__c  prpc : [SELECT Id,zqu__DefaultQuantity__c FROM zqu__ProductRatePlanCharge__c where zqu__DefaultQuantity__c!=1]){ // querying zqu__ProductRatePlanCharge__c record where zqu__DefaultQuantity__c!=1
                prpc.zqu__DefaultQuantity__c=1; // set zqu__DefaultQuantity__c to one 
                prpcToUpdate.add(prpc);
            }
            if(!prpcToUpdate.isEmpty()){ // update record list
                updatedRecord = prpcToUpdate.size();
                update prpcToUpdate;
            }
        }catch (Exception e){
        	updatedRecord = 0;
        }
        return updatedRecord;
    }
}
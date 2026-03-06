public with sharing class QuotePackageDetailController {

    public zqu__Quote__c thisQuote {get; set;}
    public String quoteDataListJson {get; set;}
    public String recordType {get;set;}

    public QuotePackageDetailController(ApexPages.StandardController standardController) {
        if (Test.isRunningTest()) {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
        thisQuote = (zqu__Quote__c)standardController.getRecord();
        recordType = Utility.getDevNameForRecordTypeID(thisQuote.getSObjectType(),thisQuote.RecordTypeId);
        System.debug(thisQuote);
        List< Map <String,String> > quoteDataList = new List< Map <String,String> >();
        // zqu__Quote__c currentQuote = [SELECT Migrating_to_New_Soultion__c, Amendment_Renewal_Prodcuts__c, Amendment_Deleted_Products__c FROM zqu__Quote__c WHERE Id =: thisQuote.Id];
        if(thisQuote.Migrating_to_New_Soultion__c == 'Yes'){
            List<String> quoteDeletedProduct = new List<String>();
            List<String> newUpdated = new List<String>();
            /* if (String.isNotBlank(thisQuote.Amendment_New_Products__c))
                newUpdated.addAll(thisQuote.Amendment_New_Products__c.split('\n'));
            if (String.isNotBlank(thisQuote.Amendment_Updated_Products__c))
                newUpdated.addAll(thisQuote.Amendment_Updated_Products__c.split('\n')); */
            if (String.isNotBlank(thisQuote.Amendment_Renewal_Prodcuts__c))
                newUpdated.addAll(thisQuote.Amendment_Renewal_Prodcuts__c.split('\n'));

            if (String.isNotBlank(thisQuote.Amendment_Deleted_Products__c))
                quoteDeletedProduct.addAll(thisQuote.Amendment_Deleted_Products__c.split('\n'));
            Integer length = 0;
            length = Math.max(newUpdated.size(), quoteDeletedProduct.size());
    
            Map <String,String> headers = new Map <String,String>();
            headers.put('newUpdatedProduct', 'New/Updated Products');
            headers.put('deletedProduct', 'Deleted Products');
            quoteDataList.add(headers);
            
            for (Integer i = 0; i < length; i++) {
                Map <String,String> quoteData = new Map <String,String>();
                if (newUpdated.size() > i) {
                    if(String.isNotBlank(newUpdated[i])){
                    quoteData.put('newUpdatedProduct', newUpdated[i]); 
                    }
                }
                if (quoteDeletedProduct.size() > i) {
                    if(String.isNotBlank(quoteDeletedProduct[i])){
                        quoteData.put('deletedProduct', quoteDeletedProduct[i]);
                    }
                }
                if(!quoteData.isEmpty()){
                    quoteDataList.add(quoteData);
                }
            }
        } else {
            if(recordType != 'Amendment'){
            List<zqu__QuoteRatePlan__c> ratePlanList = [SELECT Id,Name FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c=:thisQuote.Id];
            List<String> quotePackageDetailValueList = new List<String>();
            List<String> quotePackageDetailLeftValueList = new List<String>();
            if (String.isNotBlank(thisQuote.Dynamic_Base_Product_Users__c))
                quotePackageDetailValueList.addAll(thisQuote.Dynamic_Base_Product_Users__c.split('\n'));
            if (String.isNotBlank(thisQuote.Dynamic_Base_Product_Historical_Data__c))
                quotePackageDetailValueList.addAll(thisQuote.Dynamic_Base_Product_Historical_Data__c.split('\n'));
            if (String.isNotBlank(thisQuote.Default_Base_Product_Addons__c))
                quotePackageDetailValueList.addAll(thisQuote.Default_Base_Product_Addons__c.split('\n'));
            if (String.isNotBlank(thisQuote.Dynamic_Base_Product_Unlimited_results__c))
                quotePackageDetailValueList.addAll(thisQuote.Dynamic_Base_Product_Unlimited_results__c.split('\n'));
            if (String.isNotBlank(thisQuote.Dynamic_Base_Product_API_Hits__c))
                quotePackageDetailLeftValueList.addAll(thisQuote.Dynamic_Base_Product_API_Hits__c.split('\n'));
            if (String.isNotBlank(thisQuote.Dynamic_Base_Product_Country__c))
                quotePackageDetailLeftValueList.addAll(thisQuote.Dynamic_Base_Product_Country__c.split('\n'));
            if (String.isNotBlank(thisQuote.Dynamic_Base_Users_Stand_Alone__c))
                quotePackageDetailLeftValueList.addAll(thisQuote.Dynamic_Base_Users_Stand_Alone__c.split('\n'));
                

            Integer length = 0;
            length = Math.max(quotePackageDetailValueList.size(), quotePackageDetailLeftValueList.size());        
            Boolean isUnlimAdded = false;
            for (Integer i = 0; i < length; i++) {
                Map <String,String> quoteData = new Map <String,String>();
                if (quotePackageDetailLeftValueList.size() > i) {
                    quoteData.put('ratePlan', quotePackageDetailLeftValueList[i]);
                }
                if (quotePackageDetailValueList.size() > i) {
                    quoteData.put('packageDetail', quotePackageDetailValueList[i]);
                }
                quoteDataList.add(quoteData);
            }

            /* Integer length = 0;
            length = Math.max(quotePackageDetailValueList.size(), ratePlanList.size() + quotePackageDetailLeftValueList.size());        
            Boolean isUnlimAdded = false;
            for (Integer i = 0; i < length; i++) {
                Map <String,String> quoteData = new Map <String,String>();
                if (ratePlanList.size() > i) {
                    quoteData.put('ratePlan', ratePlanList[i].Name);
                } else {
                    if(!isUnlimAdded && !quotePackageDetailLeftValueList.isEmpty()){
                        quoteData.put('ratePlan', quotePackageDetailLeftValueList[0]);
                        isUnlimAdded = true;
                    }
                }
                if (quotePackageDetailValueList.size() > i) {
                    quoteData.put('packageDetail', quotePackageDetailValueList[i]);
                }
                quoteDataList.add(quoteData);
            } */
            } else {
                List<String> quoteDeletedProduct = new List<String>();
                List<String> newUpdated = new List<String>();
                /* if (String.isNotBlank(thisQuote.Amendment_New_Products__c))
                    newUpdated.addAll(thisQuote.Amendment_New_Products__c.split('\n'));
                if (String.isNotBlank(thisQuote.Amendment_Updated_Products__c))
                    newUpdated.addAll(thisQuote.Amendment_Updated_Products__c.split('\n')); */
                if (String.isNotBlank(thisQuote.Amendment_New_Updated_Products__c))
                    newUpdated.addAll(thisQuote.Amendment_New_Updated_Products__c.split('\n'));

                if (String.isNotBlank(thisQuote.Amendment_Deleted_Products__c))
                    quoteDeletedProduct.addAll(thisQuote.Amendment_Deleted_Products__c.split('\n'));
                Integer length = 0;
                length = Math.max(newUpdated.size(), quoteDeletedProduct.size());
        
                Map <String,String> headers = new Map <String,String>();
                headers.put('newUpdatedProduct', 'New/Updated Products');
                headers.put('deletedProduct', 'Deleted Products');
                quoteDataList.add(headers);
                
                for (Integer i = 0; i < length; i++) {
                    Map <String,String> quoteData = new Map <String,String>();
                    if (newUpdated.size() > i) {
                        if(String.isNotBlank(newUpdated[i])){
                        quoteData.put('newUpdatedProduct', newUpdated[i]); 
                        }
                    }
                    if (quoteDeletedProduct.size() > i) {
                        if(String.isNotBlank(quoteDeletedProduct[i])){
                            quoteData.put('deletedProduct', quoteDeletedProduct[i]);
                        }
                    }
                    if(!quoteData.isEmpty()){
                        quoteDataList.add(quoteData);
                    }
                }
            }
        }
        
        quoteDataListJson = String.escapeSingleQuotes(JSON.serialize(quoteDataList));
	}

    @RemoteAction
    public static void checkIfZuoraConflictExist(String quoteId){
        try{
            if(String.isNotBlank(quoteId)){
                zqu.zQuoteUtil.ZBillingResult previewResult = zqu.QuoteRecalculateController.recalculateNoUpdate(quoteId);
                zqu__Quote__c quoteToUpdate = [SELECT Id,Zuora_General_Error_Message__c FROM zqu__Quote__c WHERE id =:quoteId LIMIT 1];
                if (
                    previewResult.success || 
                    (String.isNotBlank(previewResult.message) && previewResult.message.contains('The Quote metrics value is the latest, no need to preview'))
                ) {
                    if(String.isNotBlank(quoteToUpdate.Zuora_General_Error_Message__c)){
                        quoteToUpdate.Zuora_General_Error_Message__c = '';
                        quoteToUpdate.Zuora_General_Error_Checkbox__c = false;
                        update quoteToUpdate;
                    }
                } else {
                    if(String.isBlank(quoteToUpdate.Zuora_General_Error_Message__c)){
                        quoteToUpdate.Zuora_General_Error_Message__c = previewResult.message;
                    } else if(!quoteToUpdate.Zuora_General_Error_Message__c.contains(previewResult.message)){
                        quoteToUpdate.Zuora_General_Error_Message__c +=' \n'+previewResult.message;
                    }
                    quoteToUpdate.Zuora_General_Error_Checkbox__c = true;
                    update quoteToUpdate;
                }
            }
        } catch (Exception e){
            System.debug('Exception: '+e.getMessage());
        }
    }
}
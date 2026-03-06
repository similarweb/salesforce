public with sharing class ZQuoteRatePlanDomain extends GenericDomain {
    private static Boolean fl = true;
    public ZQuoteRatePlanDomain(List<SObject> newRecords){
        super(newRecords);
    }

    public override void onAfterInsert() {
        System.debug('setDynamicCountryFilters ZQuoteRatePlanDomain onAfterInsert');
        Set<Id> recordsId = new Set<Id>();
        List<zqu__QuoteRatePlan__c> updatedRatePlans = new List<zqu__QuoteRatePlan__c>();
        for (zqu__QuoteRatePlan__c quoteRP_i : (List<zqu__QuoteRatePlan__c>)newRecords) {
            if (quoteRP_i.zqu__ProductRatePlan__c != null) {
                recordsId.add(quoteRP_i.zqu__Quote__c);
            }
            if (quoteRP_i.zqu__AmendmentType__c != null) {
                updatedRatePlans.add(quoteRP_i);
            }
        }
        // if (!recordsId.isEmpty() && !System.isFuture() && !System.isBatch()) {
        //     updateQuoteBaseCategory(recordsId);
        // }
        if (!recordsId.isEmpty()) {
            updateQuoteBaseCategory(recordsId);
        }
        if (!updatedRatePlans.isEmpty()) {
            // BaseProductAddonCalculationHelper.determineRatePlanTypeAndSetDynamicField(updatedRatePlans);
        }
        checkProductsForQuoteUpdate((List<zqu__QuoteRatePlan__c>)newRecords);
    }

    public override void onAfterUpdate(Map<Id,SObject> oldRecordsMap) {
        //if(fl){
            System.debug('setDynamicCountryFilters ZQuoteRatePlanDomain onAfterUpdate');
            System.debug('AFTER UPDATE');
            Set<Id> recordsId = new Set<Id>();
            for (zqu__QuoteRatePlan__c quoteRP_i : (List<zqu__QuoteRatePlan__c>)newRecords) {
                zqu__QuoteRatePlan__c oldQuoteRP_i = (zqu__QuoteRatePlan__c) oldRecordsMap.get(quoteRP_i.Id);
                if (quoteRP_i.zqu__ProductRatePlan__c != oldQuoteRP_i.zqu__ProductRatePlan__c
                    && quoteRP_i.zqu__ProductRatePlan__c != null) {
                    recordsId.add(quoteRP_i.zqu__Quote__c);
                }
            }
            // if (!recordsId.isEmpty() && !System.isFuture() && !System.isBatch()) {
            //     updateQuoteBaseCategory(recordsId);
            // }
            if (!recordsId.isEmpty()) {
                updateQuoteBaseCategory(recordsId);
            }

            // Set<Id> validQrpIds = new Set<Id>();
            // for (zqu__QuoteRatePlan__c qrp_i : (List<zqu__QuoteRatePlan__c>)newRecords) {
            //     validQrpIds.add(qrp_i.zqu__Quote__c);
            // }
            // Map<Id,zqu__Quote__c> qMap = new Map<Id,zqu__Quote__c>([SELECT Id,package__c FROM zqu__Quote__c
            //                                         WHERE Id IN :validQrpIds]);

            // Base_Product_Configuration__c controllingField = Base_Product_Configuration__c.getInstance('Controlling field name');
            //BaseProductAddonCalculationHelper.onBaseProductSet(qMap.values(),controllingField.Value__c);

            // List<zqu__QuoteRatePlanCharge__c> qrpcList = [SELECT Id,Name,zqu__RatePlanName__c,zqu__QuoteRatePlan__c,zqu__Quantity__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :qMap.keySet()];

            BaseProductAddonCalculationHelper.determineRatePlanTypeAndSetDynamicField((List<zqu__QuoteRatePlan__c>)newRecords);
            checkProductsForQuoteUpdate((List<zqu__QuoteRatePlan__c>)newRecords);
        // }
        //fl = false;
    }
    
    public override void onBeforeDelete(){
        for(zqu__QuoteRatePlan__c qrp: (List<zqu__QuoteRatePlan__c>)newRecords){
            System.debug('onBeforeDelete ' + qrp.zqu__AmendmentType__c);
        }
    }

    public override void onAfterDelete(List<SObject> deletedRecordsp) {
        for(zqu__QuoteRatePlan__c qrp: (List<zqu__QuoteRatePlan__c>)deletedRecordsp){
            System.debug('onAfterDelete ' + qrp.zqu__AmendmentType__c);
        }
    }

    private static void updateQuoteBaseCategory (Set<Id> recordsId){
        Base_Product_Configuration__c controllingField = Base_Product_Configuration__c.getInstance('Controlling field name');
        List <zqu__QuoteRatePlan__c> qrpList = [SELECT ID
                                                     , zqu__Quote__c
                                                     , zqu__ProductRatePlan__r.zqu__Product__r.Name 
                                                FROM zqu__QuoteRatePlan__c
                                                WHERE zqu__Quote__c IN :recordsId
                                                      AND zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c = 'Base Products'];



        List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
        Set<Id> quoteIdSet = new Set<Id>();

        for (zqu__QuoteRatePlan__c qrp_i : qrpList) {            
            zqu__Quote__c quote = new zqu__Quote__c();
            quote.Id = qrp_i.zqu__Quote__c;
            if (!Test.isRunningTest()) {
                quote.put(controllingField.Value__c,qrp_i.zqu__ProductRatePlan__r.zqu__Product__r.Name);    
            }
            if(!quoteIdSet.contains(quote.Id)){
                quoteIdSet.add(quote.Id);
                quotesToUpdate.add(quote);
            }
        }
        try{
//            UpdateZQuoteQueueable queueableJob = new UpdateZQuoteQueueable(quotesToUpdate);
//            ID jobID = System.enqueueJob(queueableJob);
        	update quotesToUpdate;
        } catch (Exception ex){
            
        }
    }

    private static void checkProductsForQuoteUpdate(List<zqu__QuoteRatePlan__c> newRecords){
        Set<Id> quoteIdSet = new Set<Id>();
        for(zqu__QuoteRatePlan__c quoteRP_i: newRecords){     
            if(
                String.isNotBlank(quoteRP_i.zqu__QuoteProductName__c) &&
                quoteRP_i.zqu__Quote__c != null
            ){
                quoteIdSet.add(quoteRP_i.zqu__Quote__c);
            }
        }

        if(!quoteIdSet.isEmpty() && !System.isFuture()){
            updateRelatedQuoteFuture(quoteIdSet);
        }
    }

    @future
    private static void updateRelatedQuoteFuture(Set<Id> quoteRatePlanIdSet){
        Set<String> productNameSet = new Set<String>();
        List<zqu__QuoteRatePlan__c> quoteRatePlanToUpdateList = [
            SELECT 
                id,
                zqu__QuoteProductName__c,
                zqu__Quote__c,
                zqu__Quote__r.Contacts_Product__c,
                zqu__Quote__r.Quote_contains_AS_products__c,
                zqu__AmendmentType__c
            FROM zqu__QuoteRatePlan__c
            WHERE zqu__Quote__c IN: quoteRatePlanIdSet
        ];

        for(zqu__QuoteRatePlan__c quoteRatePlan: quoteRatePlanToUpdateList){
            productNameSet.add(quoteRatePlan.zqu__QuoteProductName__c); 
        }

        List<Product2> productList =
        [
            SELECT 
                Id,
                Name,
                Contactproduct__c,
                AS__c
            FROM Product2 
            WHERE Name IN :productNameSet
            AND (Contactproduct__c = 'Yes' OR AS__c = '1')
        ];

        List<Product2> productWithContactList = new List<Product2>();
        List<Product2> productWithASList = new List<Product2>();

        for(Product2 product: productList){
            if(product.Contactproduct__c == 'Yes'){
                productWithContactList.add(product);
            } else if(product.AS__c == '1'){
                productWithASList.add(product);
            }
        }
        Map<Id,zqu__Quote__c> quoteToUpdateMap = new Map<Id,zqu__Quote__c>();
        updateQuotesWithContact(quoteToUpdateMap,productWithContactList,quoteRatePlanToUpdateList);
        updateQuotesWithAS(quoteToUpdateMap,productWithASList,quoteRatePlanToUpdateList);

        if(!quoteToUpdateMap.values().isEmpty()){
//            UpdateZQuoteQueueable queueableJob = new UpdateZQuoteQueueable(quoteToUpdateMap.values());
//            ID jobID = System.enqueueJob(queueableJob);
            update quoteToUpdateMap.values();
        }
    }

    private static void updateQuotesWithContact(
        Map<Id,zqu__Quote__c> quoteToUpdateMap,
        List<Product2> productList,
        List<zqu__QuoteRatePlan__c> quoteRatePlanToUpdateList
    ){

        Set<String> contactProductNameSet = new Set<String>();
        for(Product2 sfProduct: productList){
            contactProductNameSet.add(sfProduct.Name);
        }
        for(zqu__QuoteRatePlan__c quoteRP: quoteRatePlanToUpdateList){
            System.debug('quoteRP--'+quoteRP);
            System.debug('quoteRP--'+quoteRP.zqu__QuoteProductName__c);
            System.debug('contactProductNameSet--'+contactProductNameSet);
            if(
                contactProductNameSet.contains(quoteRP.zqu__QuoteProductName__c) 
            ){
                zqu__Quote__c quoteToUpdate = createQuoteToUpdate(quoteRP,quoteToUpdateMap);
                quoteToUpdate.Contacts_Product__c = (quoteRP.zqu__AmendmentType__c != 'RemoveProduct');
                quoteToUpdateMap.put(quoteToUpdate.Id,quoteToUpdate);
            } else if(
                !quoteToUpdateMap.containsKey(quoteRP.zqu__Quote__c) &&
                quoteRP.zqu__Quote__r.Contacts_Product__c == true
            ){
                zqu__Quote__c quoteToUpdate = createQuoteToUpdate(quoteRP,quoteToUpdateMap);
                quoteToUpdate.Contacts_Product__c = false;
                quoteToUpdateMap.put(quoteToUpdate.Id,quoteToUpdate);
            }
        }
    }

    private static void updateQuotesWithAS(
        Map<Id,zqu__Quote__c> quoteToUpdateMap,
        List<Product2> productList,
        List<zqu__QuoteRatePlan__c> quoteRatePlanToUpdateList
    ){
        System.debug('productList--'+productList);

        Set<String> aSProductNameSet = new Set<String>();
        for(Product2 sfProduct: productList){
            aSProductNameSet.add(sfProduct.Name);
        }
        for(zqu__QuoteRatePlan__c quoteRP: quoteRatePlanToUpdateList){
            if(
                aSProductNameSet.contains(quoteRP.zqu__QuoteProductName__c) 
            ){
                zqu__Quote__c quoteToUpdate = createQuoteToUpdate(quoteRP,quoteToUpdateMap);
                System.debug(' in first condition true'+quoteToUpdate.Quote_contains_AS_products__c);
                quoteToUpdate.Quote_contains_AS_products__c = (quoteRP.zqu__AmendmentType__c != 'RemoveProduct');
                System.debug(' in first condition true'+quoteToUpdate.Quote_contains_AS_products__c);
                quoteToUpdateMap.put(quoteToUpdate.Id,quoteToUpdate);
            } else if(
                !quoteToUpdateMap.containsKey(quoteRP.zqu__Quote__c) &&
                quoteRP.zqu__Quote__r.Quote_contains_AS_products__c == true
            ){
                zqu__Quote__c quoteToUpdate = createQuoteToUpdate(quoteRP,quoteToUpdateMap);
                quoteToUpdate.Quote_contains_AS_products__c = false;
                quoteToUpdateMap.put(quoteToUpdate.Id,quoteToUpdate);
            }
        }
    }

    private static zqu__Quote__c createQuoteToUpdate(zqu__QuoteRatePlan__c quoteRP,Map<Id,zqu__Quote__c> quoteToUpdateMap){

        zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
        if(quoteToUpdateMap.containsKey(quoteRP.zqu__Quote__c)){
            quoteToUpdate = quoteToUpdateMap.get(quoteRP.zqu__Quote__c);
        } else {
            quoteToUpdate.Id = quoteRP.zqu__Quote__c;
        }
        return quoteToUpdate;
    }

    public class Constructor implements GenericDomain.IConstructable
	{
		public GenericDomain constructDomainInstance(List<SObject> sObjectList)
		{
			return new ZQuoteRatePlanDomain(sObjectList);
		}
	}
}
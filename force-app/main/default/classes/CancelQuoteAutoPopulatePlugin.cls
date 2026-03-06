global class CancelQuoteAutoPopulatePlugin extends zqu.CancellationPropertyController.PopulateDefaultFieldValuePlugin{
    global override void populateDefaultFieldValue (SObject record, zqu.PropertyComponentController.ParentController pcc)
    {    
        // System.debug('CancelQuoteAutoPopulatePlugin');
        // System.debug('CancelQuoteAutoPopulatePlugin ' + record.Id);
        if (!Test.isRunningTest()) {
            super.populateDefaultFieldValue(record, pcc);
        }

        String name = String.valueOf(record.get('zqu__Amendment_Name__c'));
        if (name.length() > 80) {
            name = name.substring(0, 80);
            name = name.substring(0, name.lastIndexOf(' '));
        }

        record.put('zqu__Amendment_Name__c', name);

        // System.debug('CancelQuoteAutoPopulatePlugin ' + record.isSet('zqu__CancellationDate__c'));
        // if (record.Id == null && record.isSet('zqu__CancellationDate__c')) {
        //     Date cancelaltionDate = (Date) record.get('zqu__CancellationDate__c');
        //     System.debug('CancelQuoteAutoPopulatePlugin '  + cancelaltionDate);
        //     record.put('zqu__StartDate__c', cancelaltionDate);
        //     record.put('zqu__ValidUntil__c', cancelaltionDate);
        //     record.put('zqu__Service_Activation_Date__c', cancelaltionDate);
        //     record.put('zqu__Customer_Acceptance_Date__c', cancelaltionDate);    
        // } else if(record.Id != null) {
        //     zqu__Quote__c quote = [SELECT Id, zqu__CancellationDate__c FROM zqu__Quote__c WHERE Id=:record.Id LIMIT 1];
        //     Date cancelaltionDate = quote.zqu__CancellationDate__c;
        //     System.debug('CancelQuoteAutoPopulatePlugin '  + cancelaltionDate);
        //     record.put('zqu__StartDate__c', cancelaltionDate);
        //     record.put('zqu__ValidUntil__c', cancelaltionDate);
        //     record.put('zqu__Service_Activation_Date__c', cancelaltionDate);
        //     record.put('zqu__Customer_Acceptance_Date__c', cancelaltionDate);  
        //     quote.zqu__StartDate__c = cancelaltionDate;
        //     update quote;
        // }
    }
}
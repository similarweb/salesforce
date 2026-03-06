public with sharing class UpdatePaymentTypeBatchHelper {
    
    public static void updatePaymentTypeField(List<zqu__Quote__c> quotes){
        Set<String> billingAccountIds = new Set<String>();
        Map<String,String> customerAccToPaymentType = new Map<String,String>();
        List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
        for(zqu__Quote__c quote_i : quotes){
            billingAccountIds.add(quote_i.zqu__ZuoraAccountID__c);
        }

        List<Zuora__CustomerAccount__c> billingAccounts = getRelatedBillingAccount(billingAccountIds);

        customerAccToPaymentType = getPaymentTypes(billingAccounts);

        for(zqu__Quote__c quote_i : quotes){
            quote_i.Payment_Type__c = customerAccToPaymentType.get(quote_i.zqu__ZuoraAccountID__c);
            quotesToUpdate.add(quote_i);
        }
        System.debug('BEFORE UPDATE IN BATCH');
        System.debug(quotesToUpdate);
        if(!quotesToUpdate.isEmpty()){
            Database.update(quotesToUpdate,false);
        }
    }

    public static List<Zuora__CustomerAccount__c> getRelatedBillingAccount(Set<String> billingAccountIds){
        List<Zuora__CustomerAccount__c> relatedBillingAccountList = [SELECT Id
                                                                       , Name
                                                                       , Zuora__DefaultPaymentMethod__c
                                                                       , Zuora__PaymentTerm__c
                                                                       , Zuora__External_Id__c
                                                                       , (SELECT Id, Zuora__PaymentMethod__c, Payment_Type__c FROM Zuora__Payments__r Order By CreatedDate DESC LIMIT 1)
                                                                    FROM Zuora__CustomerAccount__c
                                                                   WHERE Zuora__External_Id__c IN :billingAccountIds
        ];
        if (!relatedBillingAccountList.isEmpty()) {
            return relatedBillingAccountList;
        } 
        return null;
    }

    private static Map<String,String> getPaymentTypes(List<Zuora__CustomerAccount__c> relatedBillingAccounts){
        Map<String,String> customerAccToPaymentType = new Map<String,String>();
        for(Zuora__CustomerAccount__c relatedBillingAccount : relatedBillingAccounts){
            String paymentMethod = '';
            if(relatedBillingAccount.Zuora__Payments__r != null && relatedBillingAccount.Zuora__Payments__r.size() > 0){
                Zuora__Payment__c payment = relatedBillingAccount.Zuora__Payments__r[0];   
                if(String.isNotBlank(payment.Payment_Type__c)){
                    if(payment.Payment_Type__c.containsIgnoreCase('CreditCard') || payment.Payment_Type__c.containsIgnoreCase('Credit Card')){
                        paymentMethod = 'Credit Card';
                    }
                    if(payment.Payment_Type__c.containsIgnoreCase('WireTransfer') || payment.Payment_Type__c.containsIgnoreCase('Wire Transfer')){
                        paymentMethod = 'Wire Transfer';
                    }
                }
            } else {
                paymentMethod = 'Wire Transfer';
            }
            
            if(String.isNotBlank(paymentMethod)){
                customerAccToPaymentType.put(relatedBillingAccount.Zuora__External_Id__c, paymentMethod);
            }
        }
        return customerAccToPaymentType;
    }
}
public class ContractPaymentTermService {
    
    public static String obtainContractTerm(String paymentFrequency, Decimal initialTerm, String paymentType, String paymentTerm, String jpParentName){
        String result = '';
        String error = '';
        String paymentTermId = 'PAYMENT_TERM_VALUE';
        List<ZuoraContractPaymentTermMD__mdt> contractPaymentTermList = [SELECT Id, Payment_Term_Contract__c
                                                                         FROM ZuoraContractPaymentTermMD__mdt 
                                                                         WHERE Payment_Frequency__c =: paymentFrequency AND 
                                                                         Initial_Term__c = :initialTerm AND 
                                                                         Payment_Term__c = :paymentTerm AND 
                                                                         Payment_Type__c =:paymentType AND
                                                                         JP_parent_name__c =: jpParentName
                                                                         LIMIT 1];
        if(contractPaymentTermList.isEmpty()){
            return error;
        } else {
            if (String.isNotBlank(paymentTerm)) {
                result = contractPaymentTermList[0].Payment_Term_Contract__c.replace(paymentTermId, paymentTerm.toLowerCase());
            }
            return result;
        }
    }
    
}
@isTest
public class ContractPaymentTermServiceTest {
    
    @isTest
    public static void obtainContractTerm(){
        String paymentFrequency = 'testFrequency';
        Integer initialTerm = 12;
        String paymentType = 'testType';
        String paymentTerm = 'testTerm';
        String result = ContractPaymentTermService.obtainContractTerm(paymentFrequency, initialTerm, paymentType, paymentTerm,null);
        System.assertEquals('', result);
        
        paymentFrequency = 'Every 2 Years';
        initialTerm = 24;
        paymentType = 'Credit Card';
        paymentTerm = 'Net 15';
        paymentTerm = paymentTerm.toLowerCase();
        result = ContractPaymentTermService.obtainContractTerm(paymentFrequency, initialTerm, paymentType, paymentTerm,null);
        /* System.assertEquals('The License fee for the Initial Term shall be paid by Customer in a single installment, ' + 
                            'via «Quote.PaymentMethod», to the bank account detailed in the invoice,  ' + 
                            'within «Quote.PaymentTerm» of its issuance ' + paymentTerm, result); */
    }
}
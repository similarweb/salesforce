@istest public class InvoicePDFControllerTest {

    @istest static void test(){
        List<InvoicePDFSettings__c> settings = new List<InvoicePDFSettings__c>{new InvoicePDFSettings__c(Name='To', Value__c='Test'), new InvoicePDFSettings__c(Name='Email', Value__c='test@test.som')};
        insert settings;
        Account acc = new Account(Name='Account 1', Business_Unit__c='Inside Sales');
        insert acc;
        
        PA_Invoice__c inv = new PA_Invoice__c(Account__c = acc.Id,  Bank_Detials__c='some text',Description__c='Descr', Invoice_Note__c='invoice note', Paid_To_Date__c=123.45);
        insert inv;
        InvoiceLineItem__c li = new InvoiceLineItem__c(Name='Test1', Invoice__c = inv.Id, Amount__c=123.45, Description__c='Description ', Total_DAU__c = 2);
        insert li;
        
         ApexPages.StandardController sc = new ApexPages.StandardController(inv);
        InvoicePDFController controller = new InvoicePDFController(sc);
        
        PageReference pageRef = Page.InvoicePDFPage;
        pageRef.getParameters().put('id', String.valueOf(inv.Id));
        Test.setCurrentPage(pageRef);
        
    }
}
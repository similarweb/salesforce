public class InvoicePDFController {

    public InvoiceWrapper inv {get;set;}
    public String to {get;set;}
    public String email {get;set;}
    public String defaultCurrency {get;set;}
    public Decimal VATPercent {get;set;}
    
    //public List<> lineItems; 
    
    public InvoicePDFController(ApexPages.StandardController stdController){
        inv = new InvoiceWrapper(stdController.getId());
        to = InvoicePDFSettings__c.getall().containsKey('To') ? InvoicePDFSettings__c.getInstance('To').Value__c : 'SimilarWeb';
        email = InvoicePDFSettings__c.getall().containsKey('Email') ? InvoicePDFSettings__c.getInstance('Email').Value__c : 'admin@fsmsoft.com';
        defaultCurrency =  UserInfo.getDefaultCurrency();
        VATPercent = InvoicePDFSettings__c.getall().containsKey('VAT') ? Decimal.valueOf(InvoicePDFSettings__c.getInstance('VAT').Value__c) : 17.00;
    }
        
    
    public class InvoiceWrapper {
        public String name {get;set;}
        public PA_Invoice__c invoice {get;set;}
        public List<InvoiceLineItem__c> lineItems {get;set;}
        public Decimal Total {get;set;}
        public Decimal PaidToDate {get;set;}
        public Decimal Balance {get;set;}
        
        public Boolean israelAccount {get;set;}
        public Decimal VAT {get;set;}
        
        public InvoiceWrapper(String invId){
            this.invoice = [select id, name, Bank_Detials__c, Account__c, Account__r.Name, Account__r.BillingCountry, Account__r.BillingCity, Account__r.BillingStreet, Account__r.BillingState, 
                        Account__r.BillingPostalCode, Account__r.BankDetials__c, Invoice_Due__c, Invoice_Note__c, Paid_To_Date__c from PA_Invoice__c where Id=:invId];
            this.lineItems = [select Id, Name,Total_DAU__c, Name__c, Amount__c from InvoiceLineItem__c where Invoice__c=:invId];
            this.israelAccount = invoice.Account__r.BillingCountry == 'Israel' ? true : false;
            styleInvoice();
            countTotals();
            System.debug('lineItems ' + lineItems  + '\n' + 'Total ' + Total + ', Balance ' + Balance);
        }
        
        public void styleInvoice(){
            name = this.invoice.Name.replaceAll('([^1-9])*', '');
        }
        
        public void countTotals(){
            Total = 0; PaidToDate =  0; Balance = 0;
            for (InvoiceLineItem__c ili :lineItems ){
                if (ili.Amount__c != null)
                    Total+=ili.Amount__c ;
            }
            if (israelAccount){
                VAT = Total * 0.17;
                Total += VAT;
            }
            Balance = Total + PaidToDate;
        }
    }
    
}
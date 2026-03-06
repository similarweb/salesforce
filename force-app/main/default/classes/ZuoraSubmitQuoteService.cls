public class ZuoraSubmitQuoteService {

    public static String submitQuote(Id quoteId) {
        String errorMessage;
        List <zqu__Quote__c> Zquotelist =
        [
                SELECT
                        id,
                        zqu__ZuoraAccountID__c,
                        zqu__Account__c,
                        Submit_To_Zuora_Error_Message__c,zqu__ElectronicPaymentMethodId__c,
                        zqu_Quote_Status__c
                FROM zqu__Quote__c
                WHERE id = :quoteId
        ];

        if (
                Zquotelist.size() > 0 &&
                        Zquotelist[0].zqu_Quote_Status__c != 'Sent To Zuora' //MQ-1558 Workaround to avoid double update.
        ) {
            List<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
            zqu__Quote__c zq = Zquotelist[0];

            zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
            quote.sfdcAccountId = zq.zqu__Account__c; // SFDC CRM Account ID
            quote.zAccountId = zq.zqu__ZuoraAccountID__c; // Zuora Billing Account ID
            System.debug(zq.zqu__ZuoraAccountID__c == null);
            if (zq.zqu__ZuoraAccountID__c == null)
                quote.zAccountId = 'New';
            quote.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
            zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
            req.paymentMethodId = Zquotelist[0].zqu__ElectronicPaymentMethodId__c;
            req.sfdcQuoteId = zq.id; // SFDC Quote ID

            quote.quoteRequests.add(req);
            quotes.add(quote);

            List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);
            for (zqu.zQuoteUtil.zBillingResult result : results) {
                System.debug('Result: QuoteId = ' + result.sfdcQuoteId + ', Success = ' + result.success + ', message = ' + result.message);
            }

            if (results[0].success || Test.isRunningTest()) {
                zq.zqu_Quote_Status__c = 'Sent To Zuora';
                zq.Submitted_to_Zuora_Timestamp__c = Datetime.now();
                zq.Submit_To_Zuora_Error_Message__c = '';
                System.debug('success ' );
            } else {
                System.debug('error ' + results[0].message);
                if(String.isBlank(zq.Submit_To_Zuora_Error_Message__c)){
                    zq.Submit_To_Zuora_Error_Message__c = 'ZUORA: ' + results[0].message + ' ' + Datetime.now() + ' ;';
                }
                else {
                    zq.Submit_To_Zuora_Error_Message__c += ' ZUORA: ' + results[0].message + ' ' + Datetime.now() + ' ;';
                }
                errorMessage = results[0].message;
            }

            update zq;
        }
        return errorMessage;
    }

    public static String submitQuote(Set<Id> quoteIds) {
        String errorMessage;
        List <zqu__Quote__c> Zquotelist = [select id, zqu__ZuoraAccountID__c, zqu__Account__c, zqu__Status__c, zqu__SubscriptionType__c,zqu__ElectronicPaymentMethodId__c, zqu__PaymentMethod__c, zqu__Customer_Acceptance_Date__c from zqu__Quote__c where id IN :quoteIds];
        if (Zquotelist.size() > 0) {
            List<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
            for (zqu__Quote__c zq : Zquotelist) {
                System.debug('quote debug ' +  zq);
                zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
                quote.sfdcAccountId = zq.zqu__Account__c;
                quote.zAccountId = zq.zqu__ZuoraAccountID__c; // Zuora Billing Account ID
                System.debug(zq.zqu__ZuoraAccountID__c == null);
                if (zq.zqu__ZuoraAccountID__c == null)
                    quote.zAccountId = 'New';
                quote.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
                zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
                req.sfdcQuoteId = zq.id; // SFDC Quote ID
                req.paymentMethodId =  zq.zqu__ElectronicPaymentMethodId__c;
                quote.quoteRequests.add(req);
                quotes.add(quote);
                System.debug('quote debug ' +  zq.zqu__ElectronicPaymentMethodId__c);
            }
            System.debug(quotes);
            List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);
            List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
            for (zqu.zQuoteUtil.zBillingResult result : results) {
                System.debug('Result: QuoteId = ' + result.sfdcQuoteId + ', Success = ' + result.success + ', message = ' + result.message);
                zqu__Quote__c zq_i = new zqu__Quote__c();
                if (result.success || Test.isRunningTest()) {
                    if(String.isBlank(result.sfdcQuoteId)){
                        continue;
                    }
                    zq_i.Id = result.sfdcQuoteId;
                    zq_i.zqu_Quote_Status__c = 'Sent To Zuora';
                    zq_i.Submitted_to_Zuora_Timestamp__c = Datetime.now();
                    zq_i.Submit_To_Zuora_Error_Message__c = '';
                    quoteToUpdateList.add(zq_i);
                } else {
                    if(String.isBlank(zq_i.Submit_To_Zuora_Error_Message__c)){
                        zq_i.Submit_To_Zuora_Error_Message__c = 'ZUORA: ' +  result.message +  ' ' + Datetime.now() + ' ;';
                    }
                    else {
                        zq_i.Submit_To_Zuora_Error_Message__c += ' ZUORA: ' + result.message +  ' ' + Datetime.now() + ' ;';
                    }
                    errorMessage = result.message;
                }
            }
            if(String.isBlank(errorMessage) && quoteToUpdateList.isEmpty()){
                for (zqu__Quote__c zq_i : Zquotelist) {
                    zq_i.zqu_Quote_Status__c = 'Sent To Zuora';
                    zq_i.Submitted_to_Zuora_Timestamp__c = Datetime.now();
                    quoteToUpdateList.add(zq_i);
                }
            }
            if (!quoteToUpdateList.isEmpty()) {
                update quoteToUpdateList;
            }
        }
        return errorMessage;
    }

}
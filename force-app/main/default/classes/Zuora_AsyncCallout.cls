/*obsolete, need to be removed after jobs are tested well*/
public without sharing class Zuora_AsyncCallout {
  /* David Rennert Commented out becuase it is no longer in use
    @future(callout=true)
    public static void sendQuote(list <id> QuoteIDs, boolean FireMapping, boolean FireInvoice) {

        system.debug('TESTING - SendQuote called');
        //if (!utils.isfuture || utils.istest) {
            system.debug('TESTING - SendQuote started');
            //utils.isfuture = true;
            list <zqu__Quote__c> Zquotelist = [select id, zqu__ZuoraAccountID__c, zqu__Account__c, zqu__Status__c, zqu__SubscriptionType__c from zqu__Quote__c where id = :QuoteIDs];
            if (Zquotelist.size() > 0) {
                List<zqu.zQuoteUtil.ZBillingQuoteCollection> quotes = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
                for (zqu__Quote__c zq : Zquotelist) {

                    zqu.zQuoteUtil.ZBillingQuoteCollection quote = new zqu.zQuoteUtil.ZBillingQuoteCollection();
                    quote.sfdcAccountId = zq.zqu__Account__c; // SFDC CRM Account ID
                    quote.zAccountId = zq.zqu__ZuoraAccountID__c; // Zuora Billing Account ID
                    if (zq.zqu__ZuoraAccountID__c == null) quote.zAccountId = 'New';
                    quote.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
                    zqu.zQuoteUtil.ZBillingQuoteRequest req = new zqu.zQuoteUtil.ZBillingQuoteRequest();
                    req.sfdcQuoteId = zq.id; // SFDC Quote ID
                    quote.quoteRequests.add(req);
                    quotes.add(quote);
                }
                List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(quotes);


                map <id, zqu__Quote__c> newmap = new map <id, zqu__Quote__c>();
                map <id, zqu__Quote__c> oldmap = new map <id, zqu__Quote__c>();

                for (zqu.zQuoteUtil.zBillingResult result : results) {
                    System.debug('Result: QuoteId = ' + result.sfdcQuoteId + ', Success = ' + result.success + ', message = ' + result.message);
                    if (result.success) {
                        //updateZuoraObjects(Map<Id, zqu__Quote__c> newMap, Map<Id, zqu__Quote__c> oldMap)
                    }
                }
            //}
        }
    }

//    @future(callout=true)
//    public static void CreateInvoice(list <id> QuoteIDs) {
//        CreateInvoiceLogic (QuoteIDs);
//    }
    public static void CreateInvoiceLogic(list <id> QuoteIDs) {
        system.debug('TESTING - CreateInvoice Called');
        //if (!utils.isfuture || utils.istest) {
            system.debug('TESTING - CreateInvoice started');
            //utils.isfuture = true;
            list <zqu__Quote__c> Zquotelist = [
                    select id, zqu__ZuoraAccountID__c, zqu__Account__c, zqu__Status__c,
                            zqu__TermStartDate__c, zqu__PaymentMethod__c, name
                    from zqu__Quote__c
                    where id = :QuoteIDs
            ];

            map <string, Zuora__CustomerAccount__c> ZBAMap = new map <string, Zuora__CustomerAccount__c>();

            if (Zquotelist.size() > 0) {
                list <string> tempidlist = new list <string>();
                for (zqu__Quote__c zq:Zquotelist) if (zq.zqu__ZuoraAccountID__c != null) tempidlist.add (zq.zqu__ZuoraAccountID__c);
                if (tempidlist.size() > 0) {
                    list <Zuora__CustomerAccount__c> zbalist = [
                            select id, Zuora__Account__c, Zuora__PaymentMethod_Type__c,
                                    Zuora__Zuora_Id__c
                            from Zuora__CustomerAccount__c
                            where Zuora__Zuora_Id__c = :tempidlist
                    ];

                    for (Zuora__CustomerAccount__c zba: zbalist) ZBAMap.put (zba.Zuora__Zuora_Id__c, zba);

                }
            }

            Zuora.zApi api = new Zuora.zApi();
            if (!Test.isRunningTest()) api.zlogin();

            List<Zuora.zObject> invoiceList = new List<Zuora.zObject>();
		
		//list <id> tempaccid = new list <id>();
		//for (zqu__Quote__c zq : Zquotelist)
		//{
			if (zq.zqu__Account__c!=null) tempaccid.add (zq.zqu__Account__c);
		//}
		
		//list <Account> AcList = new list <Account>();
		//if (tempaccid.size()>0)
		//{
		//	AClist = [select id,name,
		//				(select id,Zuora__Zuora_Id__c from Zuora__R00N40000001kyLcEAI__r)
		//			  from Account where id=:tempaccid];
		//}
		//map <id,Account> AccMap = new map <id,Account>();
		//if (AClist.size()>0) AccMap.putall (AClist);
	


            for (zqu__Quote__c zq : Zquotelist) {
                //if (zq.zqu__Account__c!=null)
                //{
                //	if (AccMap.ContainsKey (zq.zqu__Account__c))
                //	{
                //		Account a = AccMap.get (zq.zqu__Account__c);
                //		if (a.Zuora__R00N40000001kyLcEAI__r.size()>0)
                //		{
                //	Zuora__CustomerAccount__c zba = a.Zuora__R00N40000001kyLcEAI__r[0];
                Zuora.zObject invoice = new Zuora.zObject('Invoice');
                if (zq.zqu__TermStartDate__c != null) {
                    datetime InvoiceDate = datetime.newinstance(zq.zqu__TermStartDate__c.year(), zq.zqu__TermStartDate__c.month(), zq.zqu__TermStartDate__c.day());
                    datetime TargetDate = datetime.newinstance(date.today().year(), date.today().month(), date.today().day());


                    string accid = zq.zqu__ZuoraAccountID__c;
                    invoice.setValue('AccountId', accid);
                    invoice.setValue('InvoiceDate', InvoiceDate.format('yyyy-MM-dd'));
                    invoice.setValue('TargetDate', TargetDate.format('yyyy-MM-dd'));
                    invoiceList.add(invoice);
                }

                else
                        system.debug('TESTING: ERROR - No start date found for Quote ' + zq.name);
                //		}
                //	}
                //}
            }
            system.debug('TESTING Invoicelist.size is ' + invoicelist.size());

            List<Zuora.zApi.SaveResult> generateResult = new List<Zuora.zApi.SaveResult>();
            if (!Test.isRunningTest()) generateResult = api.zgenerate(invoiceList); else {
                Zuora.zApi.SaveResult zsr = TestObjectCreator.GenSaveRes();
                generateResult.add (zsr);
            }

            List<Zuora.zObject> objs = new List<Zuora.zObject>(); // For second call

            for (Zuora.zApi.SaveResult zsr : generateResult) {
                system.debug('TESTING Result is ' + zsr.Success);
                if (!zsr.Success) system.debug('TESTING Error is ' + zsr.Errors); else {
                    system.debug('TESTING ID is ' + zsr.id);
                    Zuora.zObject inv = new Zuora.zObject('Invoice');
                    inv.setValue('Id', zsr.id);
                    inv.setValue('Status', 'Posted');
                    objs.add (inv);
                }

            }

            if (objs.size() > 0) {

                List<Zuora.zApi.SaveResult> results = new list <Zuora.zApi.SaveResult>();
                if (!Test.isRunningTest()) results = api.zupdate(objs); else {
                    Zuora.zApi.SaveResult zsr = TestObjectCreator.GenSaveRes();
                    results.add (zsr);
                }

                List<Zuora.zObject> payments = new List<Zuora.zObject>(); // For Payment call

                for (Zuora.zApi.SaveResult zsr : results) {
                    system.debug('TESTING Result is ' + zsr.Success);
                    if (!zsr.Success) system.debug('TESTING Error is ' + zsr.Errors); else {
                        Zuora.zObject pay = new Zuora.zObject('Payment');
                        pay.setValue('InvoiceId', zsr.id);
                        payments.add (pay);
                    }
                }

                if (payments.size() > 0) {
                    List<Zuora.zObject> invpayments = new List<Zuora.zObject>(); // For InvoicePayment call

                    List<Zuora.zApi.SaveResult> paymentresults = new List<Zuora.zApi.SaveResult>();
                    if (!Test.isRunningTest()) paymentresults = api.zupdate(payments);
                    for (Zuora.zApi.SaveResult zsr : paymentresults) {
                        system.debug('TESTING payment Result is ' + zsr.Success);
                        if (!zsr.Success) system.debug('TESTING Error is ' + zsr.Errors); else {
                            Zuora.zObject invpay = new Zuora.zObject('InvoicePayment');
                            invpay.setValue('Amount', 0); //OPEN ISSUE
                            //invpay.setValue('InvoiceId',0); //OPEN How to get this
                            invpay.setValue('PaymentId', zsr.id);

                            invpayments.add (invpay);
                        }
                    }

                    if (invpayments.size() > 0) {
                        List<Zuora.zApi.SaveResult> invpayres = new List<Zuora.zApi.SaveResult>();
                        if (!Test.isRunningTest()) invpayres = api.zupdate(invpayments);
                        for (Zuora.zApi.SaveResult zsr : invpayres) {
                            if (!zsr.Success) system.debug('TESTING invoice payment Error is ' + zsr.Errors);
                        }
                    }


                }

            }
        //}

    }
*/
}

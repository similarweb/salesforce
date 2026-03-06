/**
 * Created by spivak on 2/22/2016.
 */

public class ZCreateInvoice implements Queueable {
  private list<id> m_QuoteIDs;
  private Map<String, zqu__Quote__c> zuoraAccountIdToQuoteMap;

  public ZCreateInvoice(list<id> QuoteIDs) {
    this.m_QuoteIDs = QuoteIDs;
  }

  public void execute(QueueableContext context) {
    CreateInvoiceLogic();
  }

  public void CreateInvoiceLogic() {
    system.debug('TESTING - CreateInvoice started');

    Zuora.zApi api = obtainZApi();
    List<zqu__Quote__c> Zquotelist = [
      SELECT
        id,
        zqu__ZuoraAccountID__c,
        zqu__Account__c,
        zqu__Status__c,
        zqu__TermStartDate__c,
        zqu__PaymentMethod__c,
        payment_frequency1__c,
        zqu__Previewed_SubTotal__c,
        zqu__StartDate__c,
        name
      FROM zqu__Quote__c
      WHERE
        id = :this.m_QuoteIDs
        AND zqu__SoldToContact__r.MailingCountry != 'Japan'
    ];
    if (!Zquotelist.isEmpty()) {
      zuoraAccountIdToQuoteMap = new Map<String, zqu__Quote__c>();
      for (zqu__Quote__c quote_i : Zquotelist) {
        if (String.isNotBlank(quote_i.zqu__ZuoraAccountID__c)) {
          zuoraAccountIdToQuoteMap.put(quote_i.zqu__ZuoraAccountID__c, quote_i);
        }
      }

      Set<Id> quoteIdForPaymentSet = obtainQuoteIdsForPayment(Zquotelist);
      System.debug('quoteIdForPaymentSet ' + quoteIdForPaymentSet);
      List<Zuora.zApi.SaveResult> invoiceGenerationsResults = generateZuoraInvoice(
        api,
        Zquotelist
      );
      if (
        invoiceGenerationsResults != null && !quoteIdForPaymentSet.isEmpty()
      ) {
        List<Zuora.zApi.SaveResult> PaymentGenerationResults = generateZuoraPayment(
          api,
          invoiceGenerationsResults,
          quoteIdForPaymentSet
        );
      }
    }
  }

  private Zuora.zApi obtainZApi() {
    Zuora.zApi api = new Zuora.zApi();
    if (!Test.isRunningTest())
      api.zlogin();
    return api;
  }

  private List<Zuora.zApi.SaveResult> generateZuoraInvoice(
    Zuora.zApi api,
    List<zqu__Quote__c> Zquotelist
  ) {
    List<Zuora.zApi.SaveResult> results;
    List<Zuora.zObject> invoiceList = new List<Zuora.zObject>();
    for (zqu__Quote__c zq : Zquotelist) {
      Zuora.zObject invoice = new Zuora.zObject('Invoice');
      if (zq.zqu__TermStartDate__c != null) {
        datetime quoteStartDateTime = datetime.newinstance(
          zq.zqu__StartDate__c.year(),
          zq.zqu__StartDate__c.month(),
          zq.zqu__StartDate__c.day()
        );
        string accid = zq.zqu__ZuoraAccountID__c;
        invoice.setValue('AccountId', accid);
        invoice.setValue(
          'InvoiceDate',
          quoteStartDateTime.format('yyyy-MM-dd')
        );
        invoice.setValue('TargetDate', quoteStartDateTime.format('yyyy-MM-dd'));
        invoiceList.add(invoice);
      } else {
        system.debug(
          'TESTING: ERROR - No start date found for Quote ' + zq.name
        );
      }
    }

    system.debug('TESTING Invoicelist.size is ' + invoicelist.size());

    List<Zuora.zApi.SaveResult> generateResult = new List<Zuora.zApi.SaveResult>();
    if (!Test.isRunningTest()) {
      generateResult = api.zgenerate(invoiceList);
    } else {
      Zuora.zApi.SaveResult zsr = TestObjectCreator.GenSaveRes();
      generateResult.add(zsr);
    }

    List<Zuora.zObject> objs = new List<Zuora.zObject>(); // For second call

    for (Zuora.zApi.SaveResult zsr : generateResult) {
      system.debug('TESTING Result is ' + zsr.Success);
      if (!zsr.Success) {
        system.debug('TESTING Error is ' + zsr.Errors);
      } else {
        system.debug('TESTING ID is ' + zsr.id);
        Zuora.zObject inv = new Zuora.zObject('Invoice');
        inv.setValue('Id', zsr.id);
        inv.setValue('Status', 'Posted');
        objs.add(inv);
      }
    }

    if (objs.size() > 0) {
      results = new List<Zuora.zApi.SaveResult>();
      if (!Test.isRunningTest()) {
        results = api.zupdate(objs);
      } else {
        Zuora.zApi.SaveResult zsr = TestObjectCreator.GenSaveRes();
        results.add(zsr);
      }

      for (Zuora.zApi.SaveResult zsr : results) {
        system.debug('TESTING Result is ' + zsr.Success);
        if (!zsr.Success) {
          system.debug('TESTING Error is ' + zsr.Errors);
        }
      }
    }
    return results;
  }

  private List<Zuora.zApi.SaveResult> generateZuoraPayment(
    Zuora.zApi api,
    List<Zuora.zApi.SaveResult> invoiceSaveResults,
    Set<Id> quoteIdForPaymentSet
  ) {
    List<Zuora.zApi.SaveResult> paymentresults;
    Map<String, String> invoiceIdToAccountIdMap = new Map<String, String>();
    Map<String, Zuora.zObject> invoiceIdInvoiceMap = new Map<String, Zuora.zObject>();
    Map<String, Zuora.zObject> accountIdToAccountMap = new Map<String, Zuora.zObject>();

    List<Zuora.zObject> payments = new List<Zuora.zObject>();

    String invoiceZQuery = 'Select Id, AccountId, Amount From Invoice Where ';
    for (Integer i = 0; i < invoiceSaveResults.size(); i++) {
      Zuora.zApi.SaveResult zsr = invoiceSaveResults[i];
      if (zsr.Success) {
        if (i != 0) {
          invoiceZQuery += ' OR Id = \'' + zsr.Id + '\' ';
        } else {
          invoiceZQuery += ' Id = \'' + zsr.Id + '\' ';
        }
      }
    }
    List<Zuora.zObject> zuoraInvoiceList = new List<Zuora.zObject>();
    if (!Test.isRunningTest()) {
      zuoraInvoiceList = api.zQuery(invoiceZQuery);
    }

    String accountZQuery = 'SELECT Id, DefaultPaymentMethodId from Account Where ';
    for (Integer i = 0; i < zuoraInvoiceList.size(); i++) {
      Zuora.zObject zInvoice = zuoraInvoiceList[i];
      invoiceIdToAccountIdMap.put(
        (String) zInvoice.getValue('Id'),
        (String) zInvoice.getValue('AccountId')
      );
      invoiceIdInvoiceMap.put((String) zInvoice.getValue('Id'), zInvoice);
      if (i != 0) {
        accountZQuery += ' OR Id = \'' + zInvoice.getValue('AccountId') + '\' ';
      } else {
        accountZQuery += ' Id = \'' + zInvoice.getValue('AccountId') + '\' ';
      }
    }
    List<Zuora.zObject> zuoraAccountList = new List<Zuora.zObject>();
    if (!Test.isRunningTest()) {
      zuoraAccountList = api.zQuery(accountZQuery);
    }
    for (Zuora.zObject zAccoint_i : zuoraAccountList) {
      accountIdToAccountMap.put((String) zAccoint_i.getValue('Id'), zAccoint_i);
    }

    for (Zuora.zApi.SaveResult zsr : invoiceSaveResults) {
      system.debug('TESTING Result is ' + zsr.Success);
      if (!zsr.Success) {
        system.debug('TESTING Error is ' + zsr.Errors);
      } else {
        zqu__Quote__c currQuote = zuoraAccountIdToQuoteMap.get(
          invoiceIdToAccountIdMap.get(zsr.id)
        );
        // System.debug('currQuote.Id ' + currQuote.Id);
        if (!Test.isRunningTest()) {
          if (!quoteIdForPaymentSet.contains(currQuote.Id)) {
            continue;
          }
        }
        Zuora.zObject pay = new Zuora.zObject('Payment');
        //pay.setValue('Id', 'PaymentId');
        pay.setValue('InvoiceId', zsr.id);
        if (invoiceIdInvoiceMap.containsKey(zsr.id)) {
          pay.setValue(
            'Amount',
            invoiceIdInvoiceMap.get(zsr.id).getValue('Amount')
          );
          pay.setValue(
            'AppliedInvoiceAmount',
            invoiceIdInvoiceMap.get(zsr.id).getValue('Amount')
          );
        }
        if (invoiceIdToAccountIdMap.containsKey(zsr.id)) {
          pay.setValue('AccountId', invoiceIdToAccountIdMap.get(zsr.id));
          if (
            accountIdToAccountMap.containsKey(
              invoiceIdToAccountIdMap.get(zsr.id)
            )
          ) {
            pay.setValue(
              'PaymentMethodId',
              (String) (accountIdToAccountMap.get(
                  invoiceIdToAccountIdMap.get(zsr.id)
                )
                .getValue('DefaultPaymentMethodId'))
            );
          }
        }
        pay.setValue('CreatedById', UserInfo.getUserId());
        pay.setValue('CreatedDate', Datetime.now().format('yyyy-MM-dd'));
        pay.setValue('Status', 'Processed');
        if (currQuote != null) {
          pay.setValue(
            'EffectiveDate',
            Utility.convertDateToDatetime(currQuote.zqu__StartDate__c)
              .format('yyyy-MM-dd')
          );
          pay.setValue(
            'Type',
            (currQuote.zqu__PaymentMethod__c == 'Credit Card' ||
              currQuote.zqu__PaymentMethod__c == 'PayPal')
              ? 'Electronic'
              : 'External'
          );
        }
        payments.add(pay);
      }
    }

    if (payments.size() > 0) {
      List<Zuora.zObject> invpayments = new List<Zuora.zObject>(); // For InvoicePayment call

      paymentresults = new List<Zuora.zApi.SaveResult>();
      if (!Test.isRunningTest())
        paymentresults = api.zcreate(payments);

      for (Zuora.zApi.SaveResult zsr : paymentresults) {
        system.debug('TESTING payment Result is ' + zsr.Success);
        if (!zsr.Success) {
          system.debug('TESTING Error is ' + zsr.Errors);
        }
      }
    }
    return paymentresults;
  }

  private Set<Id> obtainQuoteIdsForPayment(List<zqu__Quote__c> quoteList) {
    Set<Id> quoteForPaymentList = new Set<Id>();
    for (zqu__Quote__c quote_i : quoteList) {
      if (
        quote_i.zqu__PaymentMethod__c != 'Other' &&
        quote_i.zqu__PaymentMethod__c != 'Wire Transfer'
      ) {
        quoteForPaymentList.add(quote_i.Id);
      }
    }
    return quoteForPaymentList;
  }
}

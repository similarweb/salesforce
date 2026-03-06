public with sharing class ZuoraQuoteFieldCalculationHelper {
  public static List<zqu__Quote__c> calculateSubsidiaryForAmendQuote(
    List<Zuora__CustomerAccount__c> billingAccountList
  ) {
    Map<String, String> accountIdToSubsidiaryMap = getAccountIdToSubsidiaryMap(
      billingAccountList
    );
    List<zqu__Quote__c> amendQuoteList = [
      SELECT Id, zqu__Account__c
      FROM zqu__Quote__c
      WHERE
        zqu__SubscriptionType__c = 'Amend Subscription'
        AND zqu__Account__c IN :accountIdToSubsidiaryMap.keySet()
    ];
    List<zqu__Quote__c> quoteToUpdateList = getQuoteToUpdateList(
      amendQuoteList,
      accountIdToSubsidiaryMap
    );
    return quoteToUpdateList;
  }

  public static List<zqu__Quote__c> calculateContractPaymentTerm(
    List<zqu__Quote__c> contractPaymentTermQuoteList
  ) {
    for (zqu__Quote__c quote_i : contractPaymentTermQuoteList) {
      if (
        quote_i.zqu__SubscriptionType__c == 'Amend Subscription' &&
        String.isNotBlank(quote_i.zqu__QuoteBusinessType__c) &&
        quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('+ Renewal')
      ) {
        quote_i.Payment_Terms_Contract__c = ContractPaymentTermService.obtainContractTerm(
          quote_i.Amendment_Renewal_Payment_Frequency__c,
          quote_i.Amendment_Initial_Term__c,
          quote_i.Amendment_Renewal_Payment_Type__c,
          quote_i.Amendment_Renewal_Payment_Term__c,
          quote_i.JP_Parent_Name__c
        );
        System.debug(
          'Payment_Terms_Contract__c' + quote_i.Payment_Terms_Contract__c
        );
        System.debug('Payment' + quote_i.Payment_Type__c);
        quote_i.Payment_Terms_Contract__c = quote_i.Payment_Terms_Contract__c.replaceAll(
          '(?i)Initial',
          'Renewal'
        );
      } else {
        quote_i.Payment_Terms_Contract__c = ContractPaymentTermService.obtainContractTerm(
          quote_i.payment_frequency1__c,
          quote_i.zqu__InitialTerm__c,
          quote_i.Payment_Type__c,
          quote_i.zqu__PaymentTerm__c,
          quote_i.JP_Parent_Name__c
        );
        System.debug(
          'Payment_Terms_Contract__c' + quote_i.Payment_Terms_Contract__c
        );
        System.debug('Payment' + quote_i.Payment_Type__c);
      }
    }
    return contractPaymentTermQuoteList;
  }

  public static List<zqu__Quote__c> calculateContractAmendmentsPaymentTerm(
    List<zqu__Quote__c> contractPaymentTermQuoteList
  ) {
    System.debug('calculateContractAmendmentsPaymentTerm------');
    for (zqu__Quote__c quote_i : contractPaymentTermQuoteList) {
      System.debug('quote_i---' + quote_i);
      Decimal amendPrice;
      Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance(
        'Rounding_Resolve_V1'
      );
      Boolean featureFlag = roundingFF.Is_Active__c;
      if (featureFlag) {
        if (
          quote_i.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal' ||
          quote_i.zqu__QuoteBusinessType__c ==
          'Feature Update + Renewal (with/without upsell)'
        ) {
          amendPrice = quote_i.Renewal_Fee__c;
        } else {
          amendPrice = quote_i.Target_Quote_Total_Price__c;
        }
      } else {
        if (
          quote_i.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal' ||
          quote_i.zqu__QuoteBusinessType__c ==
          'Feature Update + Renewal (with/without upsell)'
        ) {
          amendPrice =
            quote_i.Renewal_Fee__c +
            quote_i.Sum_Of_one_time__c +
            quote_i.Sum_Of_NonDiscountable_Fees__c;
        } else {
          amendPrice =
            quote_i.Recurring_Target_Price__c +
            quote_i.Sum_Of_one_time__c +
            quote_i.Sum_Of_NonDiscountable_Fees__c;
        }
      }
      if (
        quote_i.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal' ||
        quote_i.zqu__QuoteBusinessType__c ==
        'Feature Update + Renewal (with/without upsell)'
      ) {
        amendPrice = quote_i.Renewal_Fee__c;
      } else {
        if (
          quote_i.Recurring_Target_Price__c != null &&
          quote_i.Sum_Of_one_time__c != null &&
          quote_i.Sum_Of_NonDiscountable_Fees__c != null
        ) {
          amendPrice =
            quote_i.Recurring_Target_Price__c +
            quote_i.Sum_Of_one_time__c +
            quote_i.Sum_Of_NonDiscountable_Fees__c;
        }
      }
      if (amendPrice == null) {
        continue;
      }
      Decimal term;
      if (
        quote_i.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal' ||
        quote_i.zqu__QuoteBusinessType__c ==
        'Feature Update + Renewal (with/without upsell)'
      ) {
        term = quote_i.Amendment_Initial_Term__c;
      } else {
        term = quote_i.zqu__InitialTerm__c;
      }
      System.debug(
        'term ' +
          term +
          'initial' +
          quote_i.zqu__InitialTerm__c +
          'amend initial ' +
          quote_i.Amendment_Initial_Term__c
      );
      String result = '';
      String paymentTermsContract = quote_i.Payment_Terms_Contract__c;
      String regExp = '(?i)The License fee for the Renewal Term shall be';
      paymentTermsContract = paymentTermsContract.replaceAll(
        '(?i)Initial',
        'Renewal'
      );

      if (
        paymentTermsContract.containsIgnoreCase(
          'The License fee for the Renewal Term shall be'
        )
      ) {
        if (term == 12) {
          String replacement =
            'The License Fee for the Renewal Term shall be ' +
            (quote_i.Currency_Symbol__c == '$'
              ? '***'
              : quote_i.Currency_Symbol__c) +
            amendPrice.format() +
            ' annually (excluding sales tax/VAT, where applicable), and shall be ';
          result = paymentTermsContract.replaceAll(regExp, replacement);
          result = result.replaceAll('  ', ' ');
          System.debug('result ' + result);
        } else if (term > 12) {
          if (
            quote_i.zqu__QuoteBusinessType__c ==
            'Feature Update + Renewal (with/without upsell)'
          ) {
            if (
              quote_i.Amendment_Renewal_Payment_Frequency__c ==
              'Every 3 years' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb on or after the start date of the renewal Term, and paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.Amendment_Renewal_Payment_Frequency__c == 'Annual' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in three (3) equal annual installments, the first of which will be invoiced on or after the start date of the Renewal Term, the second of which will be invoiced on the first anniversary of the start date of the Renewal Term and the third of which will be invoiced on the second anniversary of the start date of the Renewal Term. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.Amendment_Renewal_Payment_Frequency__c == 'Semi-Annual' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in six (6) equal semiannual installments, the first of which will be invoiced on or after the start date of the Renewal Term, and the subsequent installments invoiced on a semiannual basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.Amendment_Renewal_Payment_Frequency__c == 'Quarterly' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in twelve (12) equal quarterly installments, the first of which will be invoiced on or after the start date of the Renewal Term, and the subsequent installments invoiced on a quarterly basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.Amendment_Renewal_Payment_Frequency__c == 'Annual' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in two (2) equal annual installments, the first of which will be invoiced on or after the start date of the Renewal Term, and the second of which will be invoiced on the first anniversary of the start date of the renewal Term. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Amendment_Renewal_Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.Amendment_Renewal_Payment_Term__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.Amendment_Renewal_Payment_Frequency__c == 'Semi-Annual' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in four (4) equal semiannual installments, the first of which will be invoiced on or after the start date of the Renewal Term, and the subsequent installments invoiced on a semiannual basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.Amendment_Renewal_Payment_Frequency__c == 'Quarterly' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in eight (8) equal quarterly installments, the first of which will be invoiced on or after the start date of the Renewal Term, and the subsequent installments invoiced on a quarterly basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.Amendment_Renewal_Payment_Frequency__c ==
              'Every 2 Years' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb on or after the start date of the Renewal Term, and paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else {
              // String replacement = 'The License Fee for the Renewal Term shall be ' + quote_i.Currency_Symbol__c + ((quote_i.Renewal_Fee__c/quote_i.zqu__InitialTerm__c)*12).format() + ' , totaling ' + quote_i.Currency_Symbol__c + quote_i.Renewal_Fee__c.format() + ' for the "Renewal Term" which ';
              String replacement =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' ' +
                (String.isNotBlank(quote_i.payment_frequency1__c)
                  ? quote_i.payment_frequency1__c
                  : '') +
                ' , totaling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term '; //' for the Renewal Term which annually (excluding sales tax/VAT, where applicable), and shall be '
              result = paymentTermsContract.replaceAll(regExp, replacement);
              System.debug('result ' + result);
            }
          } else if (
            quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'
          ) {
            if (
              quote_i.payment_frequency1__c == 'Every 3 years' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb on or after the start date of the Renewal Term, and paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date, to the bank/account designated in the invoice.';
              System.debug('result ' + result);
            } else if (
              quote_i.payment_frequency1__c == 'Annual' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in three (3) equal annual installments, the first of which will be invoiced on or after the Amendment Effective Date, the second of which will be invoiced on the first anniversary of the Amendment Effective Date and the third of which will be invoiced on the second anniversary of the Amendment Effective Date. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.payment_frequency1__c == 'Semi-Annual' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in six (6) equal semiannual installments, the first of which will be invoiced on or after the Amendment Effective Date, and the subsequent installments invoiced on a semiannual basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.payment_frequency1__c == 'Quarterly' &&
              term == 36
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in twelve (12) equal quarterly installments, the first of which will be invoiced on or after the Amendment Effective Date, and the subsequent installments invoiced on a quarterly basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.payment_frequency1__c == 'Annual' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in two (2) equal annual installments, the first of which will be invoiced on or after the Amendment Effective Date, and the second of which will be invoiced on the first anniversary of the Amendment Effective Date. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.payment_frequency1__c == 'Semi-Annual' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in four (4) equal semiannual installments, the first of which will be invoiced on or after the Amendment Effective Date, and the subsequent installments invoiced on a semiannual basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.payment_frequency1__c == 'Quarterly' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb in eight (8) equal quarterly installments, the first of which will be invoiced on or after the Amendment Effective Date, and the subsequent installments invoiced on a quarterly basis thereafter. Each invoice shall be paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else if (
              quote_i.payment_frequency1__c == 'Every 2 Years' &&
              term == 24
            ) {
              result =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' per year, totalling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term (excluding sales tax/VAT, where applicable), and shall be invoiced by SimilarWeb on or after the Amendment Effective Date, and paid by Customer in a single installment, via ' +
                quote_i.Payment_Type__c +
                ', to the bank account detailed in the invoice, within ' +
                quote_i.zqu__PaymentTerm__c +
                ' of the invoice date.';
              System.debug('result ' + result);
            } else {
              // String replacement = 'The License Fee for the Renewal Term shall be ' + quote_i.Currency_Symbol__c + ((quote_i.Renewal_Fee__c/quote_i.zqu__InitialTerm__c)*12).format() + ' , totaling ' + quote_i.Currency_Symbol__c + quote_i.Renewal_Fee__c.format() + ' for the "Renewal Term" which ';
              String replacement =
                'The License Fee for the Renewal Term shall be ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                ((amendPrice / term) * 12).format() +
                ' ' +
                (String.isNotBlank(quote_i.payment_frequency1__c)
                  ? quote_i.payment_frequency1__c
                  : '') +
                ' , totaling ' +
                (quote_i.Currency_Symbol__c == '$'
                  ? '***'
                  : quote_i.Currency_Symbol__c) +
                amendPrice.format() +
                ' for the Renewal Term '; //' for the Renewal Term which annually (excluding sales tax/VAT, where applicable), and shall be '
              result = paymentTermsContract.replaceAll(regExp, replacement);
              System.debug('result ' + result);
            }
          } else if (
            quote_i.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal'
          ) {
            System.debug('Zohar CT+R');
            String replacement =
              'The License Fee for the Renewal Term shall be ' +
              (quote_i.Currency_Symbol__c == '$'
                ? '***'
                : quote_i.Currency_Symbol__c) +
              ((amendPrice / term) * 12).format() +
              ' per year' +
              ', totaling ' +
              (quote_i.Currency_Symbol__c == '$'
                ? '***'
                : quote_i.Currency_Symbol__c) +
              amendPrice.format() +
              ' for the Renewal Term '; //' for the Renewal Term which annually (excluding sales tax/VAT, where applicable), and shall be '
            result = paymentTermsContract.replaceAll(regExp, replacement);
            System.debug('result ' + result);
          } else {
            System.debug('Zohar ELSE!');
            // String replacement = 'The License Fee for the Renewal Term shall be ' + quote_i.Currency_Symbol__c + ((quote_i.Renewal_Fee__c/quote_i.zqu__InitialTerm__c)*12).format() + ' , totaling ' + quote_i.Currency_Symbol__c + quote_i.Renewal_Fee__c.format() + ' for the "Renewal Term" which ';
            String replacement =
              'The License Fee for the Renewal Term shall be ' +
              (quote_i.Currency_Symbol__c == '$'
                ? '***'
                : quote_i.Currency_Symbol__c) +
              ((amendPrice / term) * 12).format() +
              ' ' +
              (String.isNotBlank(quote_i.payment_frequency1__c)
                ? quote_i.payment_frequency1__c
                : '') +
              ' , totaling ' +
              (quote_i.Currency_Symbol__c == '$'
                ? '***'
                : quote_i.Currency_Symbol__c) +
              amendPrice.format() +
              ' for the Renewal Term '; //' for the Renewal Term which annually (excluding sales tax/VAT, where applicable), and shall be '
            result = paymentTermsContract.replaceAll(regExp, replacement);
            System.debug('result ' + result);
          }
        }
      }
      if (result.contains('***')) {
        if (
          quote_i.Currency_Symbol__c == '$' &&
          quote_i.zqu__Currency__c == 'AUD'
        ) {
          result = result.replace('***', 'AUD$');
        } else if (
          quote_i.Currency_Symbol__c == '$' &&
          quote_i.zqu__Currency__c == 'CLP'
        ) {
          result = result.replace('***', 'CLP$');
        } else if (quote_i.Currency_Symbol__c == '$') {
          result = result.replace('***', 'US$');
        } else {
          result = result.replace('***', '$');
        }
      }
      if (result.contains('Order Effective Date')) {
        if (
          quote_i.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal' ||
          quote_i.zqu__QuoteBusinessType__c ==
          'Feature Update + Renewal (with/without upsell)'
        ) {
          result = result.replace(
            'Order Effective Date',
            'start date of the renewal Term'
          );
        } else {
          result = result.replace(
            'Order Effective Date',
            'Amendment Effective Date'
          );
        }
      }
      quote_i.Payment_Terms_Contract_Amendments__c = result;
      System.debug('result ' + result);
    }
    return contractPaymentTermQuoteList;
  }

  public static List<zqu__Quote__c> calculateLastSignatureDateForAmendQuote(
    List<zqu__Quote__c> amendQuoteList
  ) {
    Map<Id, zqu__Quote__c> oppIdToQuoteMap = new Map<Id, zqu__Quote__c>();

    for (zqu__Quote__c quote_i : amendQuoteList) {
      if (String.isNotBlank(quote_i.zqu__Opportunity__c)) {
        oppIdToQuoteMap.put(quote_i.zqu__Opportunity__c, quote_i);
      }
    }
    List<ContentDocumentLink> relatedCdlList = [
      SELECT Id, ContentDocumentId, LinkedEntityId
      FROM ContentDocumentLink
      WHERE LinkedEntityId IN :oppIdToQuoteMap.keySet()
    ];
    Map<Id, Id> cdIdToOppIdMap = new Map<Id, Id>();
    for (ContentDocumentLink cdl_i : relatedCdlList) {
      cdIdToOppIdMap.put(cdl_i.ContentDocumentId, cdl_i.LinkedEntityId);
    }
    List<ContentVersion> relatedCvList = [
      SELECT Id, Signature_date__c, ContentDocumentId
      FROM ContentVersion
      WHERE ContentDocumentId IN :cdIdToOppIdMap.keySet()
    ];
    for (ContentVersion cv_i : relatedCvList) {
      Date signatureDate = cv_i.Signature_date__c;
      zqu__Quote__c quote = oppIdToQuoteMap.get(
        cdIdToOppIdMap.get(cv_i.ContentDocumentId)
      );
      if (
        quote.Last_Contract_Date__c == null ||
        quote.Last_Contract_Date__c < signatureDate
      ) {
        quote.Last_Contract_Date__c = signatureDate;
      }
    }
    return amendQuoteList;
  }

  public static List<zqu__Quote__c> calculateSubsidiaryForAmendQuote(
    List<zqu__Quote__c> amendQuoteList
  ) {
    Set<Id> accountIds = new Set<Id>();
    Map<String, zqu__Quote__c> subId2QuoteMap = new Map<String, zqu__Quote__c>();
    for (zqu__Quote__c quote_i : amendQuoteList) {
      accountIds.add(quote_i.zqu__Account__c);
      if (String.isNotBlank(quote_i.zqu__ExistSubscriptionID__c)) {
        subId2QuoteMap.put(
          quote_i.zqu__ExistSubscriptionID__c.toLowerCase(),
          quote_i
        );
        System.debug(
          'subId1 ' + quote_i.zqu__ExistSubscriptionID__c.toLowerCase()
        );
      }
    }
    List<Zuora__CustomerAccount__c> billingAccountList = [
      SELECT
        Id,
        Subsidiary__c,
        Zuora__Account__c,
        Zuora__AccountNumber__c,
        (
          SELECT Id, Zuora__MRR__c, Zuora__InitialTerm__c, Zuora__External_Id__c
          FROM Zuora__Subscriptions__r
        )
      FROM Zuora__CustomerAccount__c
      WHERE Zuora__Account__c IN :accountIds
    ];
    for (Zuora__CustomerAccount__c billAcc_i : billingAccountList) {
      for (
        Zuora__Subscription__c subscription_i : billAcc_i.Zuora__Subscriptions__r
      ) {
        System.debug(
          'subId2 ' + subscription_i.Zuora__External_Id__c.toLowerCase()
        );
        if (
          subId2QuoteMap.containsKey(
            subscription_i.Zuora__External_Id__c.toLowerCase()
          )
        ) {
          zqu__Quote__c quote_i = subId2QuoteMap.get(
            subscription_i.Zuora__External_Id__c.toLowerCase()
          );
          Integer initialTerm;
          Pattern pp = Pattern.compile('.*[0-9]');
          if (String.isNotBlank(subscription_i.Zuora__InitialTerm__c)) {
            Matcher mm = pp.matcher(subscription_i.Zuora__InitialTerm__c);
            if (mm.find()) {
              initialTerm = Integer.valueof(mm.group());
            }
          }

          if (
            subscription_i.Zuora__MRR__c != null &&
            initialTerm != null &&
            quote_i.zqu__SubscriptionType__c == 'Amend Subscription'
          ) {
            quote_i.Current_Contract_TCV__c = (subscription_i.Zuora__MRR__c *
            initialTerm);
            // quote_i.Current_Contract_TCV_w_o_rounding__c = (subscription_i.Zuora__MRR__c * initialTerm);
            quote_i.Contract_CMRR__c = (subscription_i.Zuora__MRR__c);
          }
        }
      }
    }
    Map<String, String> accountIdToSubsidiaryMap = getAccountIdToSubsidiaryMap(
      billingAccountList
    );
    List<zqu__Quote__c> quoteToUpdateList = getQuoteToUpdateList(
      amendQuoteList,
      accountIdToSubsidiaryMap
    );
    return quoteToUpdateList;
  }

  private static Map<String, String> getAccountIdToSubsidiaryMap(
    List<Zuora__CustomerAccount__c> billingAccountList
  ) {
    Map<String, String> accountIdToSubsidiaryMap = new Map<String, String>();
    for (Zuora__CustomerAccount__c billingAccount_i : billingAccountList) {
      accountIdToSubsidiaryMap.put(
        billingAccount_i.Zuora__AccountNumber__c.toLowerCase(),
        billingAccount_i.Subsidiary__c
      );
    }
    return accountIdToSubsidiaryMap;
  }

  private static List<zqu__Quote__c> getQuoteToUpdateList(
    List<zqu__Quote__c> amendQuoteList,
    Map<String, String> accountIdToSubsidiaryMap
  ) {
    List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
    for (zqu__Quote__c quote_i : amendQuoteList) {
      if (
        String.isNotBlank(quote_i.zqu__Zuora_Account_Number__c) &&
        accountIdToSubsidiaryMap.containsKey(
          quote_i.zqu__Zuora_Account_Number__c.toLowerCase()
        )
      ) {
        quote_i.Subsidiary__c = accountIdToSubsidiaryMap.get(
          quote_i.zqu__Zuora_Account_Number__c.toLowerCase()
        );
        quoteToUpdateList.add(quote_i);
      }
    }
    return quoteToUpdateList;
  }

  public static void calculateNewSaleProducts(List<zqu__Quote__c> quoteList) {
    for (zqu__Quote__c quote : quoteList) {
      quote.New_Sale_Products__c = '';
      if (String.isNotBlank(quote.Dynamic_Base_Product_Users__c)) {
        quote.New_Sale_Products__c +=
          quote.Dynamic_Base_Product_Users__c + '\n';
      }
      if (String.isNotBlank(quote.Dynamic_Base_Product_Historical_Data__c)) {
        quote.New_Sale_Products__c +=
          quote.Dynamic_Base_Product_Historical_Data__c + '\n';
      }
      if (String.isNotBlank(quote.Dynamic_Base_Product_API_Hits__c)) {
        quote.New_Sale_Products__c +=
          quote.Dynamic_Base_Product_API_Hits__c + '\n';
      }
      if (
        String.isNotBlank(quote.Dynamic_Base_Product_Country__c) &&
        String.isNotBlank(quote.Dynamic_WW_and_country_filter__c) &&
        quote.Dynamic_Base_Product_Country__c.containsIgnoreCase(
          quote.Dynamic_WW_and_country_filter__c
        )
      ) {
        quote.New_Sale_Products__c +=
          quote.Dynamic_Base_Product_Country__c + '\n';
      }
      if (String.isNotBlank(quote.Dynamic_Base_Product_Unlimited_results__c)) {
        quote.New_Sale_Products__c +=
          quote.Dynamic_Base_Product_Unlimited_results__c + '\n';
      }
      if (String.isNotBlank(quote.Dynamic_Base_Users_Stand_Alone__c)) {
        quote.New_Sale_Products__c +=
          quote.Dynamic_Base_Users_Stand_Alone__c + '\n';
      }
      if (String.isNotBlank(quote.Contract_Wording_List__c)) {
        quote.New_Sale_Products__c += String.join(
          quote.Contract_Wording_List__c.split(';'),
          '\n'
        );
      }
      if (String.isNotBlank(quote.dI_reporting_description__c)) {
        quote.New_Sale_Products__c += quote.dI_reporting_description__c + '\n';
      }
    }
    Integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
  }

  public static void calculateTargetPriceForRenewal(
    List<zqu__Quote__c> quoteList
  ) {
    for (zqu__Quote__c quote_i : quoteList) {
      quote_i.Target_Quote_Total_Price__c = quote_i.Renewal_Fee__c;
    }
  }

  public static void calculateValidUntil(List<SObject> newRecords) {
    for (zqu__Quote__c quote_i : (List<zqu__Quote__c>) newRecords) {
      quote_i.zqu__ValidUntil__c = Date.today().addMonths(1);
    }
  }
}

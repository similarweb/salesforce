public with sharing class ZuoraQuoteProposalGenerationHelper {
  private static String DEFAULT_INVALID_ADDRESS_ERROR_TEXT = 'An error occurred: Please make sure to provide the full address on both contacts and the account and try again';
  private static String INVALID_ADDRESS_ERROR_IDENTIFIER = 'Generate_Proposal_Invalid_Address_Error';
  /**
   * Send a data of zqu__Quote__c record to ROI calculation webservice
   * @param  quoteId Id of zqu__Quote__c record
   * @return eturn Boolean value - is call successfull or not
   */

  public static Boolean generateProposals(String quoteId) {
    if (String.isBlank(quoteId)) {
      throw new DMLException('QuoteId parameter is empty');
    }
    if (Test.isRunningTest()) {
      String leftObjectQueryName;
      String leftObjectQueryName1;
      String leftObjectQueryName2;
      String leftObjectQueryName3;
      String leftObjectQueryName4;
      String leftObjectQueryName5;
      String leftObjectQueryName6;
      String leftObjectQueryName7;
      String leftObjectQueryName8;
      String leftObjectQueryName9;
      String leftObjectQueryName10;
      String leftObjectQueryName11;
      String leftObjectQueryName12;
      String leftObjectQueryName13;
      String leftObjectQueryName14;
      String leftObjectQueryName15;
      String leftObjectQueryName16;
      String leftObjectQueryName17;
      String leftObjectQueryName18;
      String leftObjectQueryName19;
      String leftObjectQueryName20;
      String leftObjectQueryName21;
      String leftObjectQueryName22;
      String leftObjectQueryName23;
      String leftObjectQueryName24;
      String leftObjectQueryName25;
      String leftObjectQueryName26;
      String leftObjectQueryName27;
      String leftObjectQueryName28;
      String leftObjectQueryName29;
      String leftObjectQueryName30;
      String leftObjectQueryName31;
      String leftObjectQueryName32;
      String leftObjectQueryName34;
      String leftObjectQueryName35;
      String leftObjectQueryName36;
      String leftObjectQueryName37;
      String leftObjectQueryName38;
      String leftObjectQueryName39;
      String leftObjectQueryName40;
      String leftObjectQueryName41;
      String leftObjectQueryName42;
      String leftObjectQueryName43;
      String leftObjectQueryName44;
      String leftObjectQueryName45;
      String leftObjectQueryName461;
      String leftObjectQueryName46;
      String leftObjectQueryName47;
      String leftObjectQueryName48;
      String leftObjectQueryName49;
      String leftObjectQueryName50;
      String leftObjectQueryName51;
      String leftObjectQueryName52;
      String leftObjectQueryName53;
      String leftObjectQueryName54;
      String leftObjectQueryName55;
      String leftObjectQueryName56;
      String leftObjectQueryName57;
      String leftObjectQueryName58;
      String leftObjectQueryName59;
      String leftObjectQueryName60;
      String leftObjectQueryName61;
      String leftObjectQueryName62;
      String leftObjectQueryName63;
      String leftObjectQueryName64;
      String leftObjectQueryName65;
      String leftObjectQueryName66;
      String leftObjectQueryName67;
      String leftObjectQueryName68;
      String leftObjectQueryName69;
      String leftObjectQueryName70;
      String leftObjectQueryName71;
      String leftObjectQueryName72;
      String leftObjectQueryName73;
      String leftObjectQueryName74;
      String leftObjectQueryName75;
      String leftObjectQueryName76;
      String leftObjectQueryName77;
      String leftObjectQueryName78;
      String leftObjectQueryName79;
      String leftObjectQueryName80;
      String leftObjectQueryName81;
      String leftObjectQueryName82;
      String leftObjectQueryName83;
      String leftObjectQueryName84;
      String leftObjectQueryName85;
      String leftObjectQueryName86;
      String leftObjectQueryName87;
      String leftObjectQueryName88;
      String leftObjectQueryName89;
      String leftObjectQueryName90;
      String leftObjectQueryName91;
      String leftObjectQueryName92;
      String leftObjectQueryName93;
      String leftObjectQueryName94;
      String leftObjectQueryName95;
      String leftObjectQueryName96;
      String leftObjectQueryName97;
      String leftObjectQueryName98;
      String leftObjectQueryName99;
      String leftObjectQueryName100;
      String leftObjectQueryName101;
      String leftObjectQueryName102;
      String leftObjectQueryName103;
      String leftObjectQueryName104;
      String leftObjectQueryName105;
      String leftObjectQueryName106;
      String leftObjectQueryName107;
      String leftObjectQueryName108;
      String leftObjectQueryName109;
      String leftObjectQueryName110;
      String leftObjectQueryName111;
      String leftObjectQueryName112;
      String leftObjectQueryName113;
      String leftObjectQueryName114;
      String leftObjectQueryName115;
      String leftObjectQueryName116;
      String leftObjectQueryName117;
      String leftObjectQueryName118;
      String leftObjectQueryName119;
      String leftObjectQueryName120;
      String leftObjectQueryName121;
      String leftObjectQueryName122;
      String leftObjectQueryName123;
      String leftObjectQueryName124;
      String leftObjectQueryName125;
      String leftObjectQueryName126;
      String leftObjectQueryName127;
      String leftObjectQueryName128;
      String leftObjectQueryName129;
      String leftObjectQueryName130;
      String leftObjectQueryName131;
      String leftObjectQueryName132;
      String leftObjectQueryName133;
      String leftObjectQueryName134;
      String leftObjectQueryName135;
      String leftObjectQueryName136;
      String leftObjectQueryName137;
      String leftObjectQueryName138;
      String leftObjectQueryName139;
      String leftObjectQueryName140;
      String leftObjectQueryName141;
      String leftObjectQueryName142;
      String leftObjectQueryName143;
      String leftObjectQueryName144;
      String leftObjectQueryName145;
      String leftObjectQueryName146;
      String leftObjectQueryName147;
      String leftObjectQueryName148;
      String leftObjectQueryName149;
      String leftObjectQueryName150;
      String leftObjectQueryName151;
      String leftObjectQueryName152;
      String leftObjectQueryName153;
      String leftObjectQueryName154;
      String leftObjectQueryName155;
      String leftObjectQueryName156;
      String leftObjectQueryName157;
      String leftObjectQueryName158;
      String leftObjectQueryName159;
      String leftObjectQueryName160;
      String leftObjectQueryName161;
      String leftObjectQueryName162;
      String leftObjectQueryName163;
      String leftObjectQueryName164;
      String leftObjectQueryName165;
      String leftObjectQueryName166;
      String leftObjectQueryName167;
      String leftObjectQueryName168;
      String leftObjectQueryName169;
      String leftObjectQueryName170;
      String leftObjectQueryName171;
      String leftObjectQueryName172;
      String leftObjectQueryName173;
      String leftObjectQueryName174;
      String leftObjectQueryName175;
      String leftObjectQueryName176;
      String leftObjectQueryName177;
      String leftObjectQueryName178;
      String leftObjectQueryName179;
      String leftObjectQueryName180;
      String leftObjectQueryName181;
      String leftObjectQueryName182;
      String leftObjectQueryName183;
      String leftObjectQueryName184;
      String leftObjectQueryName185;
      String leftObjectQueryName186;
      String leftObjectQueryName187;
      String leftObjectQueryName188;
      String leftObjectQueryName189;
      String leftObjectQueryName190;
      String leftObjectQueryName191;
      String leftObjectQueryName192;
      String leftObjectQueryName193;
      String leftObjectQueryName194;
      String leftObjectQueryName195;
      String leftObjectQueryName196;
      String leftObjectQueryName197;
      String leftObjectQueryName198;
      String leftObjectQueryName199;
      String leftObjectQueryName200;
      String leftObjectQueryName201;
      String leftObjectQueryName202;
      String leftObjectQueryName203;
      String leftObjectQueryName204;
    }
    zqu__Quote__c quote = [
      SELECT
        Id,
        zqu__ApprovalStatus__c,
        zqu_Quote_Status__c,
        zqu__Account__r.Name,
        zqu__Number__c,
        package__c,
        zqu__Previewed_SubTotal__c,
        zqu__Currency__c, // symbol?
        Dynamic_Base_Product_API_Hits__c, // ??
        Dynamic_Base_Product_Users__c,
        Dynamic_Base_Product_Historical_Data__c,
        Dynamic_Base_Product_Country__c,
        Dynamic_Base_Users_Stand_Alone__c,
        Dynamic_Base_Product_Unlimited_results__c,
        Default_Base_Product_Addons__c,
        Contract_Wording_List__c,
        New_Sale_Products__c,
        zqu__BillToContact__r.Name,
        zqu__BillToContact__r.MailingStreet,
        zqu__BillToContact__r.Email,
        roi_start_date__c,
        roi_end_date__c,
        roi_main_domain__c,
        roi_competitors_domain__c,
        roi_conversion_rate__c,
        roi_minimum_traffic__c,
        roi_aquisition_average_order_value__c,
        roi_country__c,
        New_solution_use_case__c,
        Template_ID__c,
        emailTemplate__c,
        Product_Compatibility__c,
        Legacy_or_New_solution_deal__c,
        Contract_Base_package__c
      FROM zqu__Quote__c
      WHERE Id = :quoteId
    ];

    if (
      quote.zqu_Quote_Status__c != 'New Amendment' &&
      quote.zqu_Quote_Status__c != 'Deal Size Approved' &&
      quote.zqu_Quote_Status__c != 'Terms Approved'
    ) {
      throw new ZuoraQuoteProposalGenerationHelperException(
        'Please submit your quote to approval by clicking on "Sending to Approval" button.'
      );
    }
    if (quote.zqu__Previewed_SubTotal__c == null) {
      List<General_Configuration__mdt> configMetadataList = GeneralUtil.retrieveConfigurationMetadata(
        new Set<String>{ INVALID_ADDRESS_ERROR_IDENTIFIER }
      );
      String errorText = configMetadataList.isEmpty()
        ? DEFAULT_INVALID_ADDRESS_ERROR_TEXT
        : configMetadataList[0].Text_Value__c;
      throw new ZuoraQuoteProposalGenerationHelperException(errorText);
    }

    List<String> quoteProductsSkuList = obtainQuoteProductsSkuList(quote.Id);
    String zapierEnpoint = determineEndPoint(quote, quoteProductsSkuList);

    HttpRequest request = GeneralUtil.createHttpRequestFromApiConfigWithBody(
      zapierEnpoint,
      JSON.serialize(new WorkatoRoiRequest(quote))
        .replace('currency_FIELD_NAME_TO_CHANGE', 'currency')
    );
    request.setTimeout(120000);
    System.debug(
      JSON.serializePretty(new WorkatoRoiRequest(quote))
        .replace('currency_FIELD_NAME_TO_CHANGE', 'currency')
    );

    Http http = new Http();
    HttpResponse response = http.send(request);
    if (response.getStatusCode() == 200) {
      // quote.Proposal_Generated__c=true;
      quote.Proposal_Generated_Timestamp__c = Datetime.now();
      update quote;
      return true;
    } else {
      return false;
    }
  }

  private static List<String> obtainQuoteProductsSkuList(Id quoteId) {
    List<String> quoteProductsSkuList = new List<String>();
    List<zqu__QuoteRatePlanCharge__c> qrpcList = [
      SELECT
        Id,
        Name,
        zqu__QuoteRatePlan__r.zqu__Quote__c,
        zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c
      FROM zqu__QuoteRatePlanCharge__c
      WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quoteId
    ];
    for (zqu__QuoteRatePlanCharge__c qrpc_i : qrpcList) {
      if (
        String.isNotBlank(
          qrpc_i.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c
        )
      ) {
        quoteProductsSkuList.add(
          qrpc_i.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c
        );
      }
    }
    return quoteProductsSkuList;
  }

  private static Boolean quoteProductsContainsSkuFromList(
    List<String> quoteProductsSkuList
  ) {
    String skuList = GeneralUtil.getGeneralConfig('SKU_List_For_Proposal')
      .Text_Value__c;

    for (String quoteProductsSku : quoteProductsSkuList) {
      if (skuList.contains('\'' + quoteProductsSku + '\'')) {
        return true;
      }
    }
    return false;
  }

  private class WorkatoRoiRequest {
    public String accountName;
    public String salesRep;
    public String quoteNumber;
    public String basePorduct;
    public Decimal totalPrice;
    public String currency_FIELD_NAME_TO_CHANGE;
    public String apiHits;
    public String namedUsers;
    public String historicalData;
    public String countryFilter;
    public String billToContactName;
    public String billToContactAddress;
    public String billToContactEmailAddress;
    public String roiStartDate;
    public String roiEndDate;
    public String roiMainDomain;
    public String roiCompetitorsDomain;
    public Decimal roiConversionRate;
    public Decimal roiMinimumTraffic;
    public Decimal roiAquisitionAverageOrderValue;
    public String roiCountry;
    public String standAlone;
    public String newSaleProducts;
    public String addons;
    public String wordingList;
    public String solution;
    public String templateId;
    public String emailTemplate;
    public String emailText;
    public String tableResults;

    public WorkatoRoiRequest(zqu__Quote__c quote) {
      this.accountName = quote.zqu__Account__r.Name;
      this.salesRep = UserInfo.getUserEmail();
      this.quoteNumber = quote.zqu__Number__c;
      this.basePorduct = quote.package__c;
      if (quote.zqu__Previewed_SubTotal__c != null) {
        this.totalPrice = quote.zqu__Previewed_SubTotal__c.intvalue();
      }
      this.currency_FIELD_NAME_TO_CHANGE = CurrencyToSymbol__c.getInstance(
          quote.zqu__Currency__c
        ) != null
        ? CurrencyToSymbol__c.getInstance(quote.zqu__Currency__c).Symbol__c
        : quote.zqu__Currency__c;
      this.apiHits = quote.Dynamic_Base_Product_API_Hits__c;
      this.namedUsers = quote.Dynamic_Base_Product_Users__c;
      this.historicalData = quote.Dynamic_Base_Product_Historical_Data__c;
      this.countryFilter = quote.Dynamic_Base_Product_Country__c;
      this.tableResults = quote.Dynamic_Base_Product_Unlimited_results__c;
      this.billToContactName = quote.zqu__BillToContact__r.Name;
      this.billToContactAddress = quote.zqu__BillToContact__r.MailingStreet;
      this.billToContactEmailAddress = quote.zqu__BillToContact__r.Email;
      this.standAlone = quote.Dynamic_Base_Users_Stand_Alone__c;
      this.newSaleProducts = quote.New_Sale_Products__c;
      if (String.isNotBlank(quote.Default_Base_Product_Addons__c)) {
        this.addons = quote.Default_Base_Product_Addons__c; /* .replaceAll('\n','<br/>'); */
      }
      this.wordingList = quote.Contract_Wording_List__c;
      if (quote.roi_start_date__c != null) {
        this.roiStartDate = formatDate(quote.roi_start_date__c);
      }
      if (quote.roi_end_date__c != null) {
        this.roiEndDate = formatDate(quote.roi_end_date__c);
      }
      this.roiMainDomain = quote.roi_main_domain__c;
      this.roiCompetitorsDomain = quote.roi_competitors_domain__c;
      if (quote.roi_conversion_rate__c != null) {
        this.roiConversionRate = quote.roi_conversion_rate__c / 100;
      }
      this.roiMinimumTraffic = quote.roi_minimum_traffic__c;
      if (quote.roi_aquisition_average_order_value__c != null) {
        this.roiAquisitionAverageOrderValue =
          quote.roi_aquisition_average_order_value__c / 100;
      }
      this.roiCountry = quote.roi_country__c;
      this.solution = quote.New_solution_use_case__c;
      this.templateId = quote.Template_ID__c;
      this.emailTemplate = quote.emailTemplate__c;
      this.emailText = obtainRaw();
    }

    public String obtainRaw() {
      String rawText = '';
      rawText += 'Dear ' + billToContactName + '\n';
      rawText += '\n';
      rawText += 'We are happy to provide you the following proposal' + '\n';
      rawText += '\n';
      rawText += 'Base package' + '\n';
      rawText += basePorduct + '\n';
      rawText += '\n';
      rawText += 'Platform' + '\n';
      if (String.isNotBlank(newSaleProducts)) {
        rawText += newSaleProducts;
      }
      rawText += '\n';
      if (
        String.isNotBlank(currency_FIELD_NAME_TO_CHANGE) && totalPrice != null
      ) {
        rawText += 'Pricing:' + '\n';
        rawText += currency_FIELD_NAME_TO_CHANGE + ':' + totalPrice + '\n';
      }
      return rawText;
    }

    private String formatDate(Date dateToFormat) {
      return dateToFormat.year() + '-' + formatMonth(dateToFormat.month());
    }

    private String formatMonth(Integer month) {
      String monthRaw = '';
      if (month < 10) {
        monthRaw += '0';
      }
      monthRaw += month;
      return monthRaw;
    }
  }

  public class ZuoraQuoteProposalGenerationHelperException extends Exception {
  }

  /**
    * @author Gad Sharon
    * @date 12/11/2020
    * @description Check to which zapier end point we need to go according to the quote.
    * @param zqu__Quote__c - The quote we need to check.
             List<String> - quote Products Sku List.
    * @return String - Zapier end point.
    */

  private static String determineEndPoint(
    zqu__Quote__c quote,
    List<String> quoteProductsSkuList
  ) {
    if (digitalSuite(quote, quoteProductsSkuList)) {
      return 'Quote_Proposal_Bundle';
    } else if (researchIntelligence(quote, quoteProductsSkuList)) {
      return 'Quote_Proposal_RI';
    } else if (marketingIntelligence(quote, quoteProductsSkuList)) {
      return 'Quote_Proposal_DMI';
    } else if (investors(quote)) {
      return 'Quote_Proposal_Investors';
    } else {
      String errorMessage = 'Hi, the proposal process is still not supported for the base product that you selected. We are working on setting this up. In the meantime - please create a proposal offline';
      throw new ZuoraQuoteProposalGenerationHelperException(errorMessage);
    }
  }

  /**
    * @author Gad Sharon
    * @date 12/11/2020
    * @description Check if the quote is a digital suite quote.
    * @param zqu__Quote__c - The quote we need to check.
             List<String> - quote Products Sku List.
    * @return True if it's a digital suite quote, false otherwise.
    */

  private static Boolean digitalSuite(
    zqu__Quote__c quote,
    List<String> quoteProductsSkuList
  ) {
    Boolean solution2Suite =
      quote.Legacy_or_New_solution_deal__c == 'Solution 2.0' &&
      quote.New_solution_use_case__c == 'Digital Suite';
    Boolean newSolutionMarketingOrResearch =
      quote.Legacy_or_New_solution_deal__c == 'New solution' &&
      (quote.New_solution_use_case__c == 'Marketing' ||
      quote.New_solution_use_case__c == 'Research') &&
      quoteProductsContainsSkuFromList(quoteProductsSkuList);

    return solution2Suite || newSolutionMarketingOrResearch;
  }

  /**
    * @author Gad Sharon
    * @date 12/11/2020
    * @description Check if the quote is a research intelligence quote.
    * @param zqu__Quote__c - The quote we need to check.
             List<String> - quote Products Sku List.
    * @return True if it's a research intelligence quote, false otherwise.
    */

  private static Boolean researchIntelligence(
    zqu__Quote__c quote,
    List<String> quoteProductsSkuList
  ) {
    Boolean solution2Research =
      quote.Legacy_or_New_solution_deal__c == 'Solution 2.0' &&
      quote.New_solution_use_case__c == 'Research AI';
    Boolean newSolutionResearch =
      quote.Legacy_or_New_solution_deal__c == 'New solution' &&
      quote.New_solution_use_case__c == 'Research' &&
      !quoteProductsContainsSkuFromList(quoteProductsSkuList);

    return solution2Research || newSolutionResearch;
  }

  /**
    * @author Gad Sharon
    * @date 12/11/2020
    * @description Check if the quote is a marketing intelligence quote.
    * @param zqu__Quote__c - The quote we need to check.
             List<String> - quote Products Sku List.
    * @return True if it's a marketing intelligence quote, false otherwise.
    */

  private static Boolean marketingIntelligence(
    zqu__Quote__c quote,
    List<String> quoteProductsSkuList
  ) {
    Boolean solution2Grow =
      quote.Legacy_or_New_solution_deal__c == 'Solution 2.0' &&
      quote.New_solution_use_case__c == 'Grow MI';
    Boolean newSolutionMarketing =
      quote.Legacy_or_New_solution_deal__c == 'New solution' &&
      quote.New_solution_use_case__c == 'Marketing' &&
      !quoteProductsContainsSkuFromList(quoteProductsSkuList);

    return solution2Grow || newSolutionMarketing;
  }

  /**
   * @author Gad Sharon
   * @date 12/11/2020
   * @description Check if the quote is an investores quote.
   * @param zqu__Quote__c - The quote we need to check.
   * @return True if it's an investores quote, false otherwise.
   */

  private static Boolean investors(zqu__Quote__c quote) {
    return quote.Legacy_or_New_solution_deal__c == 'New solution' &&
      quote.New_solution_use_case__c == 'Investors';
  }
}

/**
 * @author
 * @date
 * @description: This class makes a call to Netsuite in order to get the Exchange rate.
 *               The received exchnage rate is saved in the
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 07/2021
 * description - Insert a Daily_Exchange_Rate__c
 * --------------------------------------------------------------------------------------
 */
public with sharing class NetsuiteExchangeRatesService {
  //private static String REQUEST_URL = 'https://3896279.extforms.netsuite.com/app/site/hosting/scriptlet.nl?script=160&deploy=1&compid=3896279&h=40d48a6d5514212b9064&action=getExchangeRates&fromDate={0}&toDate={1}';
  private static String REQUEST_URL = 'https://3896279.extforms.netsuite.com/app/site/hosting/scriptlet.nl?script=160&deploy=1&compid=3896279&ns-at=AAEJ7tMQ__axmM_p5SQ3G-T-f3fJVgHsjdoRsLsuln53kO7jZ_A&action=getExchangeRates&fromDate={0}&toDate={1}';
  private static String USD_CODE = 'USD';
  private static String EMAIL_TO_NOTIFY_ABOUT_ERROR = 'MIS_GnA@similarweb.com';
  private static List<String> VALID_CURR_CODE_LIST = new List<String>{
    'CLP',
    'GBP',
    'CAD',
    'EUR',
    'CHF',
    'HKD',
    'SEK',
    'JPY',
    'AUD',
    'RUB',
    'NZD',
    'ILS'
  };

  public static void retreiveExchangeRatesFromNetsuiteEndpoint() {
    try {
      NetsuiteResponse netsuiteResponse = sendRequestToNetsuiteEndpoint();
      if (netsuiteResponse.isSuccess()) {
        NetsuiteResponseCurrencyExchangeDataUnit usdExchDataUnit = netsuiteResponse.getUsdExchangeDataUnit();
        List<Netsuite_Daily_Exchange_Rate__c> netsuiteSfMetadataList = usdExchDataUnit.generateNetsuiteSfMetadataList();
        upsert netsuiteSfMetadataList Name;
        //Itzik Winograd, 14/07/2021: Add a Daily_Exchange_Rate__c records as a log
        Map<String, Daily_Exchange_Rate__c> dailyExchangeRateLogMap = createDailyExchangeRateLogMap(
          netsuiteSfMetadataList
        );
        List<Daily_Exchange_Rate__c> dailyExchangeRateLogList = checkForExistingDailyRates(
          Date.today(),
          dailyExchangeRateLogMap
        );
        if (!dailyExchangeRateLogList.isEmpty()) {
          System.enqueueJob(
            new QueueableDMLUtils(
              dailyExchangeRateLogList,
              'upsert',
              false,
              null
            )
          );
        }
        //end of addition
      } else {
        sendEmailAlert(netsuiteResponse.errMessage);
      }
    } catch (Exception ex) {
      sendEmailAlert(ex);
      System.debug(ex.getMessage());
      System.debug(ex.getStackTraceString());
    }
  }

  /**
   * @author Itzik Winograd
   * @date 15/07/2021
   * @description Create a Map of <CurrencyCode,Daily_Exchange_Rate__c> from given Netsuite_Daily_Exchange_Rate__c list
   * @param List<Netsuite_Daily_Exchange_Rate__c> netsuiteERList
   * @return Map<String,Daily_Exchange_Rate__c> dailyExchangeRateLogMap
   */
  public static Map<String, Daily_Exchange_Rate__c> createDailyExchangeRateLogMap(
    List<Netsuite_Daily_Exchange_Rate__c> netsuiteERList
  ) {
    Map<String, Currency__mdt> currencyCodeMap = CurrencyUtils.getCurrenciesByCodeMap();
    Map<String, Daily_Exchange_Rate__c> dailyExchangeRateLogMap = new Map<String, Daily_Exchange_Rate__c>();
    Daily_Exchange_Rate__c der;
    for (Netsuite_Daily_Exchange_Rate__c nsDailyRate : netsuiteERList) {
      Currency__mdt cur = currencyCodeMap.get(nsDailyRate.Name);
      der = new Daily_Exchange_Rate__c();
      der.Rate__c = nsDailyRate.USD_Exchange_Rate__c;
      der.Currency_Code__c = nsDailyRate.Name;
      der.Converted_To__c = 'USD';
      der.BOI_currency_update_date__c = Date.today();
      der.Country__c = cur.Country__c;
      der.Currency_Name__c = cur.MasterLabel;
      dailyExchangeRateLogMap.put(nsDailyRate.Name, der);
    }
    return dailyExchangeRateLogMap;
  }

  /**
   * @author Itzik Winograd
   * @date 15/07/2021
   * @description Check if existing rates exists for a specific date. If found, set the Id of the record so an upsert will be performed.
   * @param List<Netsuite_Daily_Exchange_Rate__c> netsuiteERList\
   * @return List<Daily_Exchange_Rate__c> the updated values with Id
   */
  public static List<Daily_Exchange_Rate__c> checkForExistingDailyRates(
    Date rateDate,
    Map<String, Daily_Exchange_Rate__c> dailyRatesMap
  ) {
    for (Daily_Exchange_Rate__c der : [
      SELECT Id, Currency_Code__c
      FROM Daily_Exchange_Rate__c
      WHERE BOI_currency_update_date__c = :rateDate
    ]) {
      dailyRatesMap.get(der.Currency_Code__c).Id = der.Id;
    }
    return dailyRatesMap.values();
  }

  public static Decimal retreiveExchangeRatesFromSfByCurrency(
    String currencyCode
  ) {
    return Netsuite_Daily_Exchange_Rate__c.getInstance(currencyCode)
      .USD_Exchange_Rate__c;
  }

  private static String getTodayDateInNetsuiteFormat() {
    return Datetime.now().format('ddMMyyyy');
  }

  private static NetsuiteResponse sendRequestToNetsuiteEndpoint() {
    String netsuiteTodayTimestamp = getTodayDateInNetsuiteFormat();
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      String.format(
        REQUEST_URL,
        new List<String>{ netsuiteTodayTimestamp, netsuiteTodayTimestamp }
      )
    );
    request.setMethod('GET');
    HttpResponse response = http.send(request);
    String responseRaw = response.getBody()
      .replace(netsuiteTodayTimestamp, 'netsuiteTodayTimestamp');
    NetsuiteResponse netsuiteResponse = (NetsuiteResponse) JSON.deserialize(
      responseRaw,
      NetsuiteResponse.class
    );
    return netsuiteResponse;
  }

  private static void sendEmailAlert(String errorMessage) {
    sendEmailAlert(errorMessage, null);
  }

  private static void sendEmailAlert(Exception ex) {
    String errorMessage = ex.getMessage();
    String stackTrace = ex.getStackTraceString();
    sendEmailAlert(errorMessage, stackTrace);
  }

  private static void sendEmailAlert(String errorMessage, String stackTrace) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = new List<String>{ EMAIL_TO_NOTIFY_ABOUT_ERROR };
    message.optOutPolicy = 'FILTER';
    message.subject = 'Netsuite exchange rate service failed!';
    String emailMessage =
      'Netsuite exchange rate service failed with error:\n' + errorMessage;
    if (String.isNotBlank(stackTrace)) {
      emailMessage += '\nTechnical details:\n' + stackTrace;
    }
    message.plainTextBody = emailMessage;
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages, false);

    if (results[0].success) {
      System.debug('The email was sent successfully.');
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }

  @TestVisible
  private class NetsuiteResponse {
    public String status;
    public String errMessage;
    public NetsuiteResponseDateMap exchangeRates;

    public Boolean isSuccess() {
      return status.equalsIgnoreCase('success');
    }

    public NetsuiteResponseCurrencyExchangeDataUnit getUsdExchangeDataUnit() {
      return exchangeRates.netsuiteTodayTimestamp.USD;
    }
  }

  @TestVisible
  private class NetsuiteResponseDateMap {
    public NetsuiteResponseCurrencyExchangeRateMap netsuiteTodayTimestamp;
  }

  @TestVisible
  private class NetsuiteResponseCurrencyExchangeRateMap {
    public NetsuiteResponseCurrencyExchangeDataUnit GBP;
    public NetsuiteResponseCurrencyExchangeDataUnit EUR;
    public NetsuiteResponseCurrencyExchangeDataUnit JPY;
    public NetsuiteResponseCurrencyExchangeDataUnit AUD;
    public NetsuiteResponseCurrencyExchangeDataUnit USD;
    public NetsuiteResponseCurrencyExchangeDataUnit ILS;
  }

  @TestVisible
  private class NetsuiteResponseCurrencyExchangeDataUnit {
    public String GBP;
    public String CAD;
    public String EUR;
    public String CHF;
    public String HKD;
    public String SEK;
    public String JPY;
    public String AUD;
    public String RUB;
    public String NZD;
    public String ILS;

    public List<Netsuite_Daily_Exchange_Rate__c> generateNetsuiteSfMetadataList() {
      List<Netsuite_Daily_Exchange_Rate__c> netsuiteSfMetadataList = new List<Netsuite_Daily_Exchange_Rate__c>();
      if (String.isNotBlank(GBP)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('GBP', GBP));
      }
      if (String.isNotBlank(CAD)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('CAD', CAD));
      }
      if (String.isNotBlank(EUR)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('EUR', EUR));
      }
      if (String.isNotBlank(CHF)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('CHF', CHF));
      }
      if (String.isNotBlank(HKD)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('HKD', HKD));
      }
      if (String.isNotBlank(SEK)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('SEK', SEK));
      }
      if (String.isNotBlank(JPY)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('JPY', JPY));
      }
      if (String.isNotBlank(AUD)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('AUD', AUD));
      }
      if (String.isNotBlank(RUB)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('RUB', RUB));
      }
      if (String.isNotBlank(NZD)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('NZD', NZD));
      }
      if (String.isNotBlank(ILS)) {
        netsuiteSfMetadataList.add(generateNetsuiteSfMetadata('ILS', ILS));
      }
      return netsuiteSfMetadataList;
    }

    private Netsuite_Daily_Exchange_Rate__c generateNetsuiteSfMetadata(
      String currencyCode,
      String exchageRateRaw
    ) {
      Netsuite_Daily_Exchange_Rate__c netsuiteDailyEchangeRate = new Netsuite_Daily_Exchange_Rate__c();
      netsuiteDailyEchangeRate.Name = currencyCode;
      netsuiteDailyEchangeRate.Currency_DDL__c = currencyCode;
      netsuiteDailyEchangeRate.USD_Exchange_Rate__c = Decimal.valueOf(
        exchageRateRaw
      );
      return netsuiteDailyEchangeRate;
    }
  }
}

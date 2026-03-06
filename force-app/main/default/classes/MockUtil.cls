@isTest
public class MockUtil {
  @TestVisible
  private static Boolean isSuccessfull = true;

  public static Object obtainMockProvider(Type typeToMock) {
    System.StubProvider mockProviderInstance = (System.StubProvider) Type.forName(
        'MockUtil.' + typeToMock.getName().replace('.', '') + 'MockProvider'
      )
      .newInstance();
    return Test.createStub(typeToMock, mockProviderInstance);
  }

  public static HttpCalloutMock obtainHttpMock(Type typeToMock) {
    return (HttpCalloutMock) Type.forName(
        'MockUtil.' + typeToMock.getName().replace('.', '') + 'HttpMock'
      )
      .newInstance();
  }

  public static WebServiceMock obtainWebServiceMock(Type typeToMock) {
    return (WebServiceMock) Type.forName(
        'MockUtil.' + typeToMock.getName().replace('.', '') + 'WebServiceMock'
      )
      .newInstance();
  }

  public class ZQuoteServiceMockProvider implements System.StubProvider {
    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      if (!isSuccessfull) {
        throw new DMLException();
      }

      if (stubbedMethodName == 'setQuoteAsReadyForBilling') {
        return this.setQuoteAsReadyForBilling((String) listOfArgs[0]);
      }

      if (returnType.getName() == 'String') {
        return '';
      } else if (returnType.getName() == 'Boolean') {
        return true;
      } else {
        return null;
      }
    }

    private zqu__Quote__c setQuoteAsReadyForBilling(String quoteId) {
      zqu__Quote__c quote = [
        SELECT
          Id,
          zqu_Quote_Status__c,
          zqu__SubscriptionType__c,
          zqu__PaymentMethod__c,
          Is_Finalized__c,
          document_format__c,
          zqu__SoldToContact__c,
          zqu__SoldToContact__r.FirstName,
          zqu__SoldToContact__r.LastName,
          zqu__SoldToContact__r.MailingAddress,
          zqu__SoldToContact__r.MailingCity,
          zqu__SoldToContact__r.MailingPostalCode,
          zqu__SoldToContact__r.MailingState,
          zqu__SoldToContact__r.MailingStreet,
          zqu__SoldToContact__r.MailingCountry,
          zqu__BillToContact__c,
          zqu__BillToContact__r.FirstName,
          zqu__BillToContact__r.LastName,
          zqu__BillToContact__r.MailingAddress,
          zqu__BillToContact__r.MailingCity,
          zqu__BillToContact__r.MailingPostalCode,
          zqu__BillToContact__r.MailingState,
          zqu__BillToContact__r.MailingStreet,
          zqu__BillToContact__r.MailingCountry,
          Customer_requests_to_pay_immediately__c
        FROM zqu__Quote__c
        WHERE Id = :quoteId
        LIMIT 1
      ];
      return quote;
    }
  }

  public class ZQuoteServiceHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      Map<String, Object> responseMap = new Map<String, Object>();
      responseMap.put('status', 'ok');

      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serializePretty(responseMap));
      res.setStatusCode(200);
      return res;
    }
  }

  public class SwUtilsMock implements HttpCalloutMock {
    public Httpresponse respond(HttpRequest req) {
      Map<String, Object> data = new Map<String, Object>();
      Map<String, Object> response = new Map<String, Object>();
      Map<String, Object> leadEnrichmentCountryValues = new Map<String, Object>();
      Map<String, Object> countries = new Map<String, Object>();
      Map<String, Object> world = new Map<String, Object>();
      world.put('end_date', '2020-06');
      countries.put('world', world);
      leadEnrichmentCountryValues.put('countries', countries);
      response.put(
        'lead_enrichment_country_values',
        leadEnrichmentCountryValues
      );
      data.put('response', response);
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serializePretty(data));
      res.setStatusCode(200);
      return res;
    }
  }

  public class NetsuiteExchangeRatesServiceHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      NetsuiteExchangeRatesService.NetsuiteResponse netsuiteResponse = generateMockHttpResponseBody();
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serializePretty(netsuiteResponse));
      res.setStatusCode(200);
      return res;
    }

    private NetsuiteExchangeRatesService.NetsuiteResponse generateMockHttpResponseBody() {
      NetsuiteExchangeRatesService.NetsuiteResponseCurrencyExchangeDataUnit netsuiteResponseCurrencyExchangeDataUnit = new NetsuiteExchangeRatesService.NetsuiteResponseCurrencyExchangeDataUnit();
      netsuiteResponseCurrencyExchangeDataUnit.GBP = '.1';
      netsuiteResponseCurrencyExchangeDataUnit.CAD = '.2';
      netsuiteResponseCurrencyExchangeDataUnit.EUR = '.3';
      netsuiteResponseCurrencyExchangeDataUnit.CHF = '.4';
      netsuiteResponseCurrencyExchangeDataUnit.HKD = '.5';
      netsuiteResponseCurrencyExchangeDataUnit.SEK = '.6';
      netsuiteResponseCurrencyExchangeDataUnit.JPY = '.7';
      netsuiteResponseCurrencyExchangeDataUnit.AUD = '.8';
      netsuiteResponseCurrencyExchangeDataUnit.RUB = '.9';
      netsuiteResponseCurrencyExchangeDataUnit.NZD = '.11';
      netsuiteResponseCurrencyExchangeDataUnit.ILS = '.12';
      NetsuiteExchangeRatesService.NetsuiteResponseCurrencyExchangeRateMap netsuiteResponseCurrencyExchangeRateMap = new NetsuiteExchangeRatesService.NetsuiteResponseCurrencyExchangeRateMap();
      netsuiteResponseCurrencyExchangeRateMap.USD = netsuiteResponseCurrencyExchangeDataUnit;
      NetsuiteExchangeRatesService.NetsuiteResponseDateMap netsuiteResponseDateMap = new NetsuiteExchangeRatesService.NetsuiteResponseDateMap();
      netsuiteResponseDateMap.netsuiteTodayTimestamp = netsuiteResponseCurrencyExchangeRateMap;
      NetsuiteExchangeRatesService.NetsuiteResponse netsuiteResponse = new NetsuiteExchangeRatesService.NetsuiteResponse();
      if (isSuccessfull) {
        netsuiteResponse.status = 'success';
        netsuiteResponse.errMessage = '';
        netsuiteResponse.exchangeRates = netsuiteResponseDateMap;
      } else {
        netsuiteResponse.status = 'fail';
        netsuiteResponse.errMessage = 'Test Error';
      }
      return netsuiteResponse;
    }
  }

  public class ZuoraContractGenerationHelperHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      Map<String, Object> responseMap = new Map<String, Object>();
      responseMap.put('success', true);
      responseMap.put('file', 'testResultFileText');

      HttpResponse res = new HttpResponse();
      if (req.getEndpoint().containsIgnoreCase('testFileUrl')) {
        res.setHeader('Content-Type', 'application/pdf');
      } else {
        res.setHeader('Content-Type', 'application/json');
      }
      res.setBody(JSON.serializePretty(responseMap));
      res.setStatusCode(200);
      return res;
    }
  }

  public class CheckVatViesServiceWebServiceMock implements WebServiceMock {
    public void doInvoke(
      Object stub,
      Object request,
      Map<String, Object> response,
      String endpoint,
      String soapAction,
      String requestName,
      String responseNS,
      String responseName,
      String responseType
    ) {
      CheckVatTypesService.checkVatResponse_element response_x = new CheckVatTypesService.checkVatResponse_element();
      response_x.valid = true;
      response.put('response_x', response_x);
    }
  }

  public class MetadataServiceFacadeMockProvider implements System.StubProvider {
    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      if (returnType.getName() == 'String')
        return '';
      if (returnType.getName() == 'Boolean')
        return false;
      else
        return null;
    }
  }

  public class ZuoraApiServiceMockProvider implements System.StubProvider {
    public Map<String, Object> getSubscriptionDataResponse;
    public Boolean updateAccountCertificateIdResponse;

    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      if (stubbedMethodName == 'getSubscriptionData') {
        return this.getSubscriptionData();
      } else if (stubbedMethodName == 'updateAccountCertificateId') {
        return this.updateAccountCertificateId();
      } else {
        return null;
      }
    }

    private Map<String, Object> getSubscriptionData() {
      return this.getSubscriptionDataResponse;
    }

    private Boolean updateAccountCertificateId() {
      return this.updateAccountCertificateIdResponse;
    }
  }

  public class ZuoraAuthApiServiceMockProvider implements System.StubProvider {
    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      return listOfArgs[0];
    }
  }

  public class ZSubscriptionServiceMockProvider implements System.StubProvider {
    public Object handleMethodCall(
      Object stubbedObject,
      String stubbedMethodName,
      Type returnType,
      List<Type> listOfParamTypes,
      List<String> listOfParamNames,
      List<Object> listOfArgs
    ) {
      if (stubbedMethodName == 'updateRelatedAccounts') {
        return this.updateRelatedAccounts(listOfArgs[0]);
      } else {
        return null;
      }
    }

    private List<Account> updateRelatedAccounts(Object arg) {
      Set<Id> accountIds = (Set<Id>) arg;
      List<Account> updatedAccounts = new List<Account>();
      for (Id accId : accountIds) {
        Account mockAcc = new Account(
          Id = accId,
          fr_NextRenewalDate__c = Date.today()
        );
        updatedAccounts.add(mockAcc);
      }
      return updatedAccounts;
    }
  }

  public class ZendeskIntegrationServiceHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      Map<String, Object> responseMap = new Map<String, Object>();
      Map<String, Object> ticketBody = new Map<String, Object>();
      ticketBody.put('id', 35436);
      ticketBody.put('subject', 'subject');
      ticketBody.put('description', 'description');
      Map<String, Object> ticketField = new Map<String, Object>();
      Map<String, Object> customOption = new Map<String, Object>();
      customOption.put('name', 'New Sale');
      customOption.put('value', 'new_sale');
      ticketField.put('id', Long.valueof('360011070757'));
      ticketField.put('type', 'tagger');
      ticketField.put(
        'custom_field_options',
        new List<Map<String, Object>>{ customOption }
      );
      responseMap.put(
        'ticket_fields',
        new List<Map<String, Object>>{ ticketField }
      );
      responseMap.put('ticket', ticketBody);

      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serialize(responseMap));
      res.setStatusCode(201);
      return res;
    }
  }

  public class ZendeskIntegrationServiceErrorHttpMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      Map<String, Object> responseMap = new Map<String, Object>();
      responseMap.put('error', 'error');
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serialize(responseMap));
      res.setStatusCode(500);
      return res;
    }
  }
}

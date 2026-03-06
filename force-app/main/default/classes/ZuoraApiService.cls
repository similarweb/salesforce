public class ZuoraApiService {
  private final Integer REQUEST_TIMEOUT;
  @TestVisible
  private ZuoraAuthApiService authService;
  private Map<String, String> zuoraContactGenerationSettings;

  public ZuoraApiService() {
    REQUEST_TIMEOUT = 120000;
    this.authService = new ZuoraAuthApiService();
    this.zuoraContactGenerationSettings = new Map<String, String>();
    for (Zuora_Quote_Contact_Generation_Setting__mdt zqcgs_i : [
      SELECT DeveloperName, Value__c
      FROM Zuora_Quote_Contact_Generation_Setting__mdt
    ]) {
      this.zuoraContactGenerationSettings.put(
        zqcgs_i.DeveloperName,
        zqcgs_i.Value__c
      );
    }
  }

  // public void updateRenewalCloneOfAmendQuote(List<QuoteProductsChangeUnit> quoteProductsChangeUnitList){
  //     for (QuoteProductsChangeUnit quoteProductsChangeUnit_i : quoteProductsChangeUnitList) {
  //         zqu.Quote zQuote = zqu.Quote.getInstance(quoteProductsChangeUnit_i.targetQuoteId);
  //         String subscriptionId = zQuote.getSObject().zqu__ExistSubscriptionID__c;
  //         Decimal contractedMrr = 0;

  //         String endpoint = this.zuoraContactGenerationSettings.get('Endpoint') + '/v1/subscriptions/' + subscriptionId;
  //         Map<String, Object> responseBodyMap = this.getSubscriptionData(endpoint);

  //         contractedMrr =(Decimal)responseBodyMap.get('contractedMrr');
  //         Date subscriptionEndDate =Date.valueOf((String)responseBodyMap.get('subscriptionStartDate')).addMonths(zQuote.getSObject().zqu__RenewalTerm__c.intValue());
  //         zQuote.getSObject().Current_Contract_TCV__c = (contractedMrr * zQuote.getSObject().zqu__Initialterm__c ).setScale(0,System.RoundingMode.UP);
  //         // zQuote.getSObject().Current_Contract_TCV_w_o_rounding__c = contractedMrr * zQuote.getSObject().zqu__Initialterm__c;
  //         zQuote.getSObject().Contract_CMRR__c = (contractedMrr);
  //         if(zQuote.getSObject().zqu__QuoteBusinessType__c != 'Renewal (with/without upsell)'){
  //             zQuote.getSObject().zqu__InvoiceTargetDate__c = subscriptionEndDate;
  //         }

  //         zQuote.save();
  //     }
  // }

  public Boolean updateAccountCertificateId(
    String accountId,
    String certificateId
  ) {
    String endpoint =
      this.zuoraContactGenerationSettings.get('Endpoint') +
      '/v1/object/account/' +
      accountId;
    HTTPRequest req = generateHttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod('PUT');
    req.setHeader('Content-Type', 'application/json');
    req = this.authService.getAuthorization(req);

    UpdateAccountRequestBody requestBody = new UpdateAccountRequestBody(
      certificateId
    );
    String body = JSON.serialize(requestBody);
    req.setBody(body);

    HTTPResponse res = this.sendHttpRequest(req);

    if (res.getStatusCode() == 200) {
      String responseBody = res.getBody();
      Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
        responseBody
      );
      Boolean isValidResponseBody = responseBodyMap.containsKey('Success');
      if (isValidResponseBody) {
        return (Boolean) responseBodyMap.get('Success');
      } else {
        throw new ZuoraApiServiceException('Invalid response body');
      }
    } else {
      throw new ZuoraApiServiceException(
        'Update account data request failed with status code: ' +
        res.getStatusCode()
      );
    }
  }

  public Map<String, Object> getSubscriptionData(String subscriptionId) {
    String endpoint =
      this.zuoraContactGenerationSettings.get('Endpoint') +
      '/v1/subscriptions/' +
      subscriptionId;
    HTTPRequest req = generateHttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod('GET');
    req.setHeader('Content-Type', 'application/json');
    req = this.authService.getAuthorization(req);
    HTTPResponse res = this.sendHttpRequest(req);

    if (res.getStatusCode() == 200) {
      String responseBody = res.getBody();
      Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
        responseBody
      );
      Boolean isValidResponseBody = responseBodyMap.containsKey('success');
      Boolean isSuccessResponse = (Boolean) responseBodyMap.get('success');
      if (isValidResponseBody && isSuccessResponse) {
        return responseBodyMap;
      } else {
        throw new ZuoraApiServiceException('Invalid response body');
      }
    } else {
      throw new ZuoraApiServiceException(
        'Get Subscription data request failed with status code: ' +
        res.getStatusCode()
      );
    }
  }

  public Map<String, Object> generateContractInZuora(
    String quoteId,
    String templateId
  ) {
    String contractType = 'pdf';

    HTTPRequest req = generateHttpRequest();
    req.setEndpoint(
      this.zuoraContactGenerationSettings.get('Endpoint') +
      '/v1/quotes/document'
    );
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    req = this.authService.getAuthorization(req);
    req.setBody(
      generateDocumentCreationRequestBody(quoteId, templateId, contractType)
    );

    HTTPResponse res = this.sendHttpRequest(req);

    if (res.getStatusCode() == 200) {
      String responseBody = res.getBody();
      Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
        responseBody
      );
      Boolean isValidResponseBody = responseBodyMap.containsKey('success');
      Boolean isSuccessResponse = (Boolean) responseBodyMap.get('success');
      if (isValidResponseBody && isSuccessResponse) {
        return responseBodyMap;
      } else {
        throw new ZuoraApiServiceException('Invalid response body');
      }
    } else {
      throw new ZuoraApiServiceException(
        'Generate Contract request failed with status code: ' +
        res.getStatusCode()
      );
    }
  }

  public HTTPResponse obtainDocumentFromZuora(String quoteId, String fileUrl) {
    HTTPRequest req = generateHttpRequest();
    req.setEndpoint(
      this.zuoraContactGenerationSettings.get('Endpoint') + fileUrl
    );
    req.setMethod('GET');
    req.setHeader('Content-Type', 'application/json');
    req = this.authService.getAuthorization(req);

    HTTPResponse res = this.sendHttpRequest(req);

    if (res.getStatusCode() == 200) {
      return res;
    } else {
      throw new ZuoraApiServiceException(
        'Obtain Document request failed with status code: ' +
        res.getStatusCode()
      );
    }
  }

  private static String generateDocumentCreationRequestBody(
    String quoteId,
    String templateId,
    String contractType
  ) {
    Map<String, Object> requestBodyMap = new Map<String, Object>();
    requestBodyMap.put('documentType', contractType);
    requestBodyMap.put('locale', 'en_US');
    requestBodyMap.put('quoteId', quoteId);
    requestBodyMap.put(
      'serverUrl',
      URL.getSalesforceBaseUrl().toExternalForm() +
        '/services/Soap/u/28.0/' +
        UserInfo.getOrganizationId()
    );
    requestBodyMap.put(
      'sessionId',
      JwtCredentials.getInstance().getAccessToken()
    );
    requestBodyMap.put('templateId', templateId);
    requestBodyMap.put('useSFDCLocale', '1');
    requestBodyMap.put('zquotesMajorVersion', '7');
    requestBodyMap.put('zquotesMinorVersion', '0');
    return JSON.serialize(requestBodyMap);
  }

  private HTTPRequest generateHttpRequest() {
    HTTPRequest req = new HTTPRequest();
    req.setTimeout(REQUEST_TIMEOUT);
    return req;
  }

  private HTTPResponse sendHttpRequest(HTTPRequest req) {
    Http http = new Http();
    return http.send(req);
  }

  public class ZuoraApiServiceException extends Exception {
  }

  private class UpdateAccountRequestBody {
    public String TaxExemptCertificateID;

    public UpdateAccountRequestBody(String certificateId) {
      this.TaxExemptCertificateID = certificateId;
    }
  }
}

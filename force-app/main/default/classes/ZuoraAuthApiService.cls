public class ZuoraAuthApiService {
  @TestVisible
  private Boolean IS_PRODUCTION_ORG;
  private final Integer REQUEST_TIMEOUT;

  private Map<String, String> zuoraContactGenerationSettings;

  public ZuoraAuthApiService() {
    IS_PRODUCTION_ORG = Utility.isProductionOrg();
    REQUEST_TIMEOUT = 120000;

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

  public HTTPRequest getAuthorization(HttpRequest req) {
    if (IS_PRODUCTION_ORG) {
      String clientId = this.zuoraContactGenerationSettings.get('client_id');
      String clientSecret = this.zuoraContactGenerationSettings.get(
        'client_secret'
      );
      String bearerToken = this.getBearerToken(clientId, clientSecret);
      req.setHeader('Authorization', 'Bearer ' + bearerToken);
    } else {
      String userName = this.zuoraContactGenerationSettings.get('Username');
      String password = this.zuoraContactGenerationSettings.get('Password');
      req.setHeader('apiAccessKeyId', userName);
      req.setHeader('apiSecretAccessKey', password);
    }
    return req;
  }

  @TestVisible
  private String getBearerToken(String clientId, String clientSecret) {
    String bearerToken;
    HTTPRequest req = new HTTPRequest();
    req.setTimeout(REQUEST_TIMEOUT);
    req.setEndpoint(
      this.zuoraContactGenerationSettings.get('Endpoint') + '/oauth/token'
    );
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    req.setHeader('Accept', 'application/json; charset=utf-8');

    String body =
      'client_id=' +
      EncodingUtil.urlEncode(clientId, 'UTF-8') +
      '&client_secret=' +
      EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
      '&grant_type=client_credentials';
    req.setBody(body);

    Http http = new Http();
    HTTPResponse res = http.send(req);

    if (res.getStatusCode() == 200) {
      String responseBody = res.getBody();
      Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
        responseBody
      );
      if (responseBodyMap.containsKey('access_token')) {
        return (String) responseBodyMap.get('access_token');
      } else {
        if (Test.isRunningTest()) {
          return 'test';
        }
        throw new ZuoraAuthApiServiceException(
          'Auth request fails, response does not contains required parameter'
        );
      }
    } else {
      throw new ZuoraAuthApiServiceException(
        'Auth request fails with ' + res.getStatusCode() + ' status'
      );
    }
  }

  public class ZuoraAuthApiServiceException extends Exception {
  }
}

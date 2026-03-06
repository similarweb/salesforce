/**
 * @author Itzik Winograd
 * @date 18/04/2020
 * @description Test class for GetSalesforceAccessToken
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
@isTest
public class GetSalesforceAccessTokenTest {
  /**
   * @author Itzik Winograd
   * @date 02/05/2021
   * @description: test the getAccessToken method in the GetSalesforceAccessTokenTest class.
   * Send 'Salesforce_Access_Token' as the api name of the api config to test.
   * @Expect: The token received from the method will be the isTest response in the class:{"access_token":"someToken"}
   */
  @isTest
  public static void getAccessTokenTest() {
    Test.setMock(
      HttpCalloutMock.class,
      new GetSalesforceAccessTokenTest.SalesforceTokenMock()
    );
    String token = GetSalesforceAccessToken.getAccessToken(
      'Salesforce_Access_Token'
    );
    System.debug('@@@ token: ' + token);
    System.assertEquals(
      '{"access_token":"someToken"}',
      token,
      'getAccessTokenTest mismatch, token is: ' + token
    );
  }

  /**
   * @author Itzik Winograd
   * @date 02/05/2021
   * @description: test the getTokenFromResponse method in the GetSalesforceAccessTokenTest class.
   * Send a mock response from salesfore as a param and expect this response parsed, and "someToken" retuend as token.
   * @Expect: The token received from the method will be 'someToken'
   */
  @isTest
  public static void getTokenFromResponseTest() {
    Test.startTest();
    HTTPResponse res = GetSalesforceAccessTokenTest.getSalesforceResponseMock(
      200
    );
    HttpRequest request = null;
    String responseToken = GetSalesforceAccessToken.getTokenFromResponse(
      res,
      request
    );
    System.debug('@@@ getTokenFromResponseTestL ' + responseToken);
    System.assertEquals(
      'someToken',
      responseToken,
      'getTokenFromResponseTest mismatch, responseToken is: ' + responseToken
    );
    //test with error code and not 200.
    //Expect null as the response and one log record
    HTTPResponse resError = GetSalesforceAccessTokenTest.getSalesforceResponseMock(
      401
    );
    String responseTokenError = GetSalesforceAccessToken.getTokenFromResponse(
      resError,
      request
    );
    System.assertEquals(
      null,
      responseTokenError,
      'getTokenFromResponseTest - error mismatch, responseToken is: ' +
      responseTokenError
    );
    Test.stopTest();
    Integer logSize = [SELECT Id FROM Apex_Event_Log__c].size();
    System.assertEquals(1, logSize, 'log size mismatch. logSize: ' + logSize);
  }

  /**
   * @author Itzik Winograd
   * @date 28/12/2021
   * @description: test the headers pair of authentication
   * @Expect: headerPair will have an 'Authorization' key
   */
  @isTest
  public static void testCreateRequestHeaders() {
    Map<String, String> headerPair = GetSalesforceAccessToken.createRequestHeaders(
      'some_token'
    );
    System.assert(
      headerPair.containsKey('Authorization'),
      'No Authorization key found!'
    );
  }
  public static HttpResponse getSalesforceResponseMock(Integer code) {
    HttpResponse res = new HttpResponse();
    res.setHeader('ContentType', 'application/json');
    Map<String, String> respMap = new Map<String, String>();
    respMap.put('access_token', 'someToken');
    res.setBody(JSON.serialize(respMap));
    res.setStatusCode(code);
    return res;
  }

  public class SalesforceTokenMock implements System.HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      return GetSalesforceAccessTokenTest.getSalesforceResponseMock(200);
    }
  }
}

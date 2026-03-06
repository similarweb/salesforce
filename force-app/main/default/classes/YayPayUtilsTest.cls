@isTest
global class YayPayUtilsTest {
  private static final String YAYPAY_API_CONFIG_TOKEN_NAME = 'YayPay_Integration_Token';
  private static final String YAYPAY_API_CONFIG_GET_DATA_NAME = 'YayPay_Integration_Data';

  /**
   * @author Itzik Winograd
   * @date 06/03/2022
   * @description get a token for yaypay
   * @expected make sure the token does not contain error.
   */
  @isTest
  public static void getYayPayAccessTokenTest() {
    Test.setMock(HttpCalloutMock.class, new YayPayUtilsTest.YayPayHttpMock());
    String token = YayPayUtils.getYayPayAccessToken('v2');
    System.assert(
      !token.contains('error'),
      'error in getYayPayAccessTokenTest'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 06/03/2022
   * @description get a token for yaypay
   * @expected make sure the token does not contain error.
   */
  @isTest
  public static void getCustomerActivitiesnTest() {
    Test.setMock(HttpCalloutMock.class, new YayPayUtilsTest.YayPayHttpMock());
    String response = YayPayUtils.getCustomerActivities(
      YayPayUtils.getYayPayAccessToken('v2'),
      'zuoraExternalAcctId',
      0,
      200
    );
    System.assert(response != null, 'error in getCustomerActivitiesnTest');
  }
  /**
   * @author Itzik Winograd
   * @date 06/03/2022
   * @description get a token for yaypay
   * @expected make sure the token does not contain error.
   */
  @isTest
  public static void getARSpecialistMappingTest() {
    Test.setMock(HttpCalloutMock.class, new YayPayUtilsTest.YayPayHttpMock());
    String arSpecialistMap = YayPayUtils.getARSpecialistMapping(
      YayPayUtils.getYayPayAccessToken('v2'),
      0,
      200
    );
    System.assert(
      arSpecialistMap != null,
      'error in getCustomerActivitiesnTest'
    );
  }

  /**
   * @author Itzik Winograd
   * @date 06/03/2022
   * @description get a token for yaypay
   * @expected make sure the token does not contain error.
   */
  @isTest
  public static void setARSpecialistBillingTest() {
    Test.setMock(HttpCalloutMock.class, new YayPayUtilsTest.YayPayHttpMock());
    HttpRequest yayPaySetARSpecialistRequest = YayPayUtils.setARSpecialistInYayPay('token', 'test', 'email@test.com');
    Http http = new Http();
    HTTPResponse res = http.send(yayPaySetARSpecialistRequest);
    System.assert(res.getStatusCode()<300, 'Error: setARSpecialistBilligTest did not response 200 family!');
  }

  /**
   * @author Itzik Winograd
   * @date 01/03/2022
   * @description http mock for yaypay
   */
  global class YayPayHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
      HTTPResponse response;
      if (req.getEndpoint().contains('token')) {
        response = getTokenMock(req);
      } else if (req.getEndpoint().contains('armapping')) {
        response = getARMappingMock(req);
      } else if (req.getEndpoint().contains('activities')) {
        response = getActivitiesMock(req);
      } else if (req.getEndpoint().contains('link')) {
        response = setARSpecialistResponse(req);
      }
      System.debug('@@@ YayPayHttpMock returns: ' + response);
      return response;
    }

    global HTTPResponse getTokenMock(HTTPRequest req) {
      Map<String, Object> responseMap = new Map<String, Object>{
        'access_token' => 'myAccessToken'
      };
      responseMap.put('status', 'ok');
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serializePretty(responseMap));
      res.setStatusCode(200);
      return res;
    }

    public HTTPResponse getARMappingMock(HTTPRequest req) {
      Map<String, Object> responseMap = new Map<String, Object>{
        'ar_mapping' => new List<Object>{
          new Map<String, String>{
            'ar_email' => 'YayPayEmailTest@test.com',
            'customer_name' => 'testName',
            'customer_int_id' => 'zuoraExternalAcctId'
          }
        },
        'meta_data' => new Map<String, Integer>{ 'total_records' => 1 }
      };
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serializePretty(responseMap));
      res.setStatusCode(200);
      return res;
    }

    public HTTPResponse getActivitiesMock(HTTPRequest req) {
      Map<String, Object> responseMap = new Map<String, Object>{
        'activities' => new List<Object>{
          new Map<String, String>{
            'details' => '',
            'creator' => 'Tester Test',
            'activity_note' => 'OUT',
            'created_date' => '2022-03-01T12:00:11',
            'activity_type' => 'NOTE',
            'customer_name' => 'testName',
            'customer_int_id' => 'zuoraExternalAcctId'
          }
        },
        'meta_data' => null
      };
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(JSON.serializePretty(responseMap));
      res.setStatusCode(200);
      return res;
    }
    public HTTPResponse setARSpecialistResponse(HTTPRequest req) {
      System.debug('@@@ req: ' + req.toString());
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{}');
      res.setStatusCode(req.getEndpoint()?.contains('error')  ? 400 : 201);
      return res;
    }
  } //end YayPayHttpMock class
} //end YayPayUtilsTest class
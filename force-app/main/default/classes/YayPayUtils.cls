/**
 * @author Itzik Winograd
 * @date 15/02/2022
 * @description YayPay integration utils class. Gets an access token and perform the calls.
 *                                                             MIS-1705
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author                        -
 * date                                -
 * description -
 * --------------------------------------------------------------------------------------
 */

public without sharing class YayPayUtils {
  private static final String YAYPAY_API_CONFIG_TOKEN_NAME = 'YayPay_Integration_Token';
  private static final String YAYPAY_API_CONFIG_GET_DATA_NAME = 'YayPay_Integration_Data';
  private static final Integer MAX_TIMEOUT = 60000;

  /**
   * @author Itzik Winograd
   * @date 15/02/2022
   * @description Get authorization access token to YayPay using custom metadata.
   * @param None.
   * @return String accessToken. If result!=200 then return "Error" + error msg.
   * =====
   * @Date 12/07/2022 -
   */
  public static String getYayPayAccessToken(String version) {
    API_Configuration__mdt yaypayAPIConfig = GeneralUtil.getAPIConfig(
      YAYPAY_API_CONFIG_TOKEN_NAME
    );
    String scope = version == 'v1'
      ? 'invoice.api.write'
      : 'ar.read customer.read crm.read';
    HttpRequest yaypayAuthRequest = GeneralUtil.createHttpRequestFromApiConfigWithBody(
      YAYPAY_API_CONFIG_TOKEN_NAME,
      'client_id=' +
        yaypayAPIConfig.Username__c +
        '&client_secret=' +
        yaypayAPIConfig.Password__c +
        '&scope=' +
        scope,
      true
    );
    yaypayAuthRequest.setEndpoint(
      yaypayAuthRequest.getEndpoint() + version + '/token'
    );
    Http http = new Http();
    String accessToken = null;
    HTTPResponse res = http.send(yaypayAuthRequest);
    System.debug('### res of yaypayAuthRequest: ' + res.getBody());
    if (res.getStatusCode() == 200) {
      Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(
        res.getBody()
      );
      if (responseBodyMap.containsKey('access_token')) {
        accessToken = (String) responseBodyMap.get('access_token');
      }
    } else {
      //status code != 200
      accessToken = 'Error: ' + res.getBody();
    }
    return accessToken;
  }

  /**
  * @author Itzik Winograd
    * @date 15/02/2022
    * @description gets a single customer data using API metadata, access token and cusomter Id.
    *                             Not in use under MIS-1705.
    * @param String accessToken.
    * @param String customerId.
    * @return the response body
    
    public static String getCustomerDetails(String accessToken, String customerId){
                if(accessToken == null){
                        return null;
                }
                Http http = new Http();
                Map<String,String> headerPairs = new Map<String,String>();
                headerPairs.put('Authorization', 'Bearer ' + accessToken);
                HttpRequest yayPayCustomerRequest = GeneralUtil.createGetRequest(YAYPAY_API_CONFIG_GET_DATA_NAME, null ,headerPairs, 'customers/'+customerId);
                HTTPResponse res = http.send(yayPayCustomerRequest);
                //System.debug('### res: '+ res.getBody());
                return res.getBody();
        }*/

  /**
   * @author Itzik Winograd
   * @date 15/02/2022
   * @description gets the customer's activities
   * @param String accessToken.
   * @param String customerId.
   * @param Integer pageNumber.
   * @return the response body
   */
  public static String getCustomerActivities(
    String accessToken,
    String customerId,
    Integer pageNumber,
    Integer pageSize
  ) {
    if (accessToken == null) {
      return null;
    }
    pageNumber = pageNumber == null ? 0 : pageNumber;
    Http http = new Http();
    Map<String, String> headerPairs = new Map<String, String>();
    headerPairs.put('Authorization', 'Bearer ' + accessToken);
    String urlActivitiesAddition =
      'v2/customers/' +
      customerId +
      '/activities?activity_type=ALL&page=' +
      pageNumber +
      '&page_size=' +
      pageSize;
    HttpRequest yayPayCustomerRequest = GeneralUtil.createGetRequest(
      YAYPAY_API_CONFIG_GET_DATA_NAME,
      null,
      headerPairs,
      urlActivitiesAddition
    );
    yayPayCustomerRequest.setTimeout(MAX_TIMEOUT);
    HTTPResponse res = http.send(yayPayCustomerRequest);
    //System.debug('### res: '+ res.getBody());
    return res.getBody();
  }

  /**
        * @author Itzik Winograd
        * @date 15/02/2022
        * @description gets the customer's activities
        *                             Not in use under MIS-1705.
        * @param String accessToken.
        * @param Integer pageNumber - the page number of the response, if the response has more than one page
        * @param Integer pageSize - the page size - number of records per page
        * @param String fromDate.
        * @param String toDate.
        * @return the response body

        public static String getRecentlyModifiedCustomers(String accessToken, Integer pageNumber, Integer pageSize, String fromDate, String toDate){
                if(accessToken == null){
                        return null;
                }
                pageNumber = pageNumber == null ? 0 : pageNumber;
                pageSize = pageSize == null ? 50 : pageSize;
                Http http = new Http();
                Map<String,String> headerPairs = new Map<String,String>();
                headerPairs.put('Authorization', 'Bearer ' + accessToken);
                String urlCustomersAddition = 'customers?page='+pageNumber+'&from_date='+fromDate+'&to_date='+toDate+'&page_size='+pageSize;
                HttpRequest yayPayCustomerRequest = GeneralUtil.createGetRequest(YAYPAY_API_CONFIG_GET_DATA_NAME, null ,headerPairs, urlCustomersAddition);
                HTTPResponse res = http.send(yayPayCustomerRequest);
                //System.debug('### res: '+ res.getBody());
                return res.getBody();
        }*/

  /**
   * @author Itzik Winograd
   * @date 15/02/2022
   * @description gets the customer's ar specialist
   * @param String accessToken.
   * @param Integer pageNumber - the page number of the response, if the response has more than one page
   * @param Integer pageSize - the page size - number of records per page
   * @return the response body
   */
  public static String getARSpecialistMapping(
    String accessToken,
    Integer pageNumber,
    Integer pageSize
  ) {
    if (accessToken == null) {
      return null;
    }
    pageNumber = pageNumber == null ? 0 : pageNumber;
    Http http = new Http();
    Map<String, String> headerPairs = new Map<String, String>();
    headerPairs.put('Authorization', 'Bearer ' + accessToken);
    String urlARMappingAdditions =
      'v2/armapping?page=' +
      pageNumber +
      '&page_size=' +
      pageSize;
    HttpRequest yayPayCustomerRequest = GeneralUtil.createGetRequest(
      YAYPAY_API_CONFIG_GET_DATA_NAME,
      null,
      headerPairs,
      urlARMappingAdditions
    );
    yayPayCustomerRequest.setTimeout(MAX_TIMEOUT);
    HTTPResponse res = http.send(yayPayCustomerRequest);
    System.debug('### res: ' + res.getBody());
    return res.getBody();
  }

  /**
   * @author Itzik Winograd
   * @date 03/08/2022
   * @description Sets the customer's ar specialist in YayPay. response shuold be in the 200 family.
   * @param String accessToken.
   * @param String customerInternalId - the internal Id of the customer in YayPay
   * @param String email - AR_Specialits==bulling expert email is YayPay
   * @return the response body
   */
  public static HttpRequest setARSpecialistInYayPay(
    String accessToken,
    String customerInternalId,
    String email
  ) {
    if (accessToken == null) {
      return null;
    }
    Map<String, String> headerPairs = new Map<String, String>();
    headerPairs.put('Authorization', 'Bearer ' + accessToken);
    String urlARMappingAdditions =
      'v1/customers/' +
      customerInternalId +
      '/users/link?email=' +
      email;
    HttpRequest yayPaySetARSpecialistRequest = GeneralUtil.createGetRequest(
      YAYPAY_API_CONFIG_GET_DATA_NAME,
      null,
      headerPairs,
      urlARMappingAdditions
    );
    yayPaySetARSpecialistRequest.setMethod('PATCH');
    yayPaySetARSpecialistRequest.setTimeout(MAX_TIMEOUT);
    System.debug(
      '### yayPaySetARSpecialistRequest: ' + yayPaySetARSpecialistRequest
    );
    return yayPaySetARSpecialistRequest;
  }
}

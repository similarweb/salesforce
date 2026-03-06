/**
* @author Itzik Winograd
* @date 18/04/2020
* @description Static method to get access token to salesforce using the "API Config" 
* custom meta data.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/
public with sharing class GetSalesforceAccessToken { 
    
    /** 
    * @author Itzik Winograd
    * @date 18/04/2021
    * @description: Main method to handle the request and the response.
    * Gets the name of the custom meta data to get values from,
    * Builds a body for the call and parse the response to get the access_token.
    * @return Strng access_token - String access_token - salesforce access token
    */
    public static String getAccessToken(String customMeatDataName){
        String requestBody = createAccessTokenBodyPairs(customMeatDataName);
        HttpRequest request = GeneralUtil.createHttpRequestFromApiConfigWithBody(customMeatDataName,requestBody);
        System.debug('### SF Authentication request: ' + request);
        Http http = new Http();
        if(!Test.isRunningTest()){
        	HttpResponse response = http.send(request); 
            return getTokenFromResponse(response, request);
        } else {
            Test.setMock(HttpCalloutMock.class, new PardotUtilsTest.PardotTokenMock('ok', 200));
            return '{"access_token":"someToken"}';
        }
        
    }


    /** 
    * @author Itzik Winograd
    * @date 18/04/2021
    * @description: Extact the access_token from the response of the call
    * @param HTTPResponse res response of the authentication call
    * @param HttpRequest request sent, in case we have an error to log
    * @return String access_token - salesforce access tokenm, or *null* if authentication failed.
    */
    public static String getTokenFromResponse(HTTPResponse res, HttpRequest request){
        String access_token;
        String responseString =  res.getBody();
        System.debug('### responseString: ' + responseString);
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseBodyMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            if (responseBodyMap.containsKey('access_token')) {
                access_token = (String)responseBodyMap.get('access_token');
                return access_token;
            }
        }
        EventBus.publish(LogEventUtils.createLogEventRecord(new List<String>{''}, 'GetSalesforceAccessToken', 'getTokenFromResponse', 
            String.valueOf(res.getStatusCode()), res.getBody(),'Error', request, null));
        return null;
    }

    /** 
    * @author Itzik Winograd
    * @date 18/04/2021
    * @description: Create body neede for salesforce Authentication request.
    * @param String customMeatDataName - Name of the custom metadata to grab values from
    * @return String requestBody - pairs of key::value seperated with :,, between each pair.
    */
    private static String createAccessTokenBodyPairs(String customMeatDataName){
        FINAL String SEPERATOR = '&';
        String requestBody = '';
        API_Configuration__mdt config = GeneralUtil.getAPIConfig(customMeatDataName);       
        requestBody+='grant_type=password' +                SEPERATOR;
        requestBody+='client_id='+config.Token_Id__c +      SEPERATOR;
        requestBody+='client_secret='+config.Token_Pass__c+ SEPERATOR;
        requestBody+='username='+config.Username__c +       SEPERATOR;
        requestBody+='password='+config.Password__c +       SEPERATOR;
        System.debug('### requestBody: ' + requestBody);
        return requestBody;
    }

    /**
    * @author Itzik Winograd
    * @date 27/12/2021
    * @description Creating header pairs for salesforce integration. use the token
    * @param String access_token - the access token of Salesforce to identify to salesforce
    * @return Map<String,String> headers for the request
    */
    public static Map<String,String> createRequestHeaders(String access_token){
        Map<String,String> headers = new Map<String,String>();
        headers.put('Authorization', 'Bearer ' + access_token);
        return headers;
    }
}
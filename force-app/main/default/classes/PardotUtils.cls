/**
* @author Itzik Winograd
* @date 22/04/2020
* @description Pardot general utils class.
* Establish a connection to pardot using custom meta data and more.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        -  
* description - 
* --------------------------------------------------------------------------------------                     
*/

public with sharing class PardotUtils {
    /**
    * @author Itzik Winograd
    * @date 22/04/2021
    * @description query pardot and expect xml response.
    * @param String access_token - the access token of Salesforce to identify to salesforce
    * @param String customMeatDataName - the custom metadata API Config Name to query by.
    * @param Set<String> fields - a set of field to query pardot by.
    * @return String xmlResponse - response parsed as XML, null otherwise.
    */
    // public static String queryPardot (String customMeatDataName, string access_token, List<String> fields) {
    //     String xmlResponse;
    //     Map<String,String> endpointPairs = createPardotEndpointPairs(fields);
    //     Map<String,String> headerPairs = createPardotHeaders(access_token);
    //     HttpRequest request = GeneralUtil.createGetRequest(customMeatDataName,endpointPairs,headerPairs);
    //     System.debug('### Pardot query request: ' + request);
    //     Http http = new Http();
    //     HttpResponse response = http.send(request);
    //     if(response.getStatusCode() == 200){
    //         xmlResponse = response.getBody();
    //     } else {
    //         EventBus.publish(LogEventUtils.createLogEventRecord(null, 'Pardot Utils', 'queryPardot', 
    //         String.valueOf(response.getStatusCode()), response.getBody(),'Error', request, new List<String>(headerPairs.keySet())));
    //     }
    //     //System.debug('### xmlResponse from Pardot is: ' + xmlResponse);
    //     return xmlResponse;
    // }

    /**
    * @author Itzik Winograd
    * @date 22/04/2021
    * @description Creating header pairs for authentiaction to pardot.
    * @param String 
    * @return 
    */
    // public static Map<String,String> createPardotEndpointPairs(List<String> fields){
    //     Map<String,String> endpointPairs = new Map<String,String>();
    //     endpointPairs.put('fields', String.join(fields,','));
    //     System.debug('### pardot query endpointPairs: ' + endpointPairs);
    //     return endpointPairs;
    // }

    /**
    * @author Itzik Winograd
    * @date 22/04/2021
    * @description Creating header pairs for authentiaction to pardot.
    * @param String access_token - the access token of Salesforce to identify to salesforce
    * @return Map<String,String> headers of necessary pardot 
    */
    public static Map<String,String> createPardotHeaders(String access_token){
        Map<String,String> headers = new Map<String,String>();
        headers.put('Authorization', 'Bearer ' + access_token);
        headers.put('Pardot-Business-Unit-Id', '0Uv0X000000008ZSAQ');
        System.debug('### pardot query headers: ' + headers);
        return headers;
    }

    /**
    * @author Itzik Winograd
    * @date 25/04/2021
    * @description query pardot and expect xml response.
    * @param String access_token - the access token of Salesforce to identify to salesforce
    * @param String customMeatDataName - the custom metadata API Config Name to query by.
    * @param String prospectId - prospectId to query pardot By
    * @return String xmlResponse - response parsed as XML, null otherwise.
    */
    public static String readPardot (String customMeatDataName, string access_token, String prospectId) {
        String xmlResponse;
        Map<String,String> headerPairs = createPardotHeaders(access_token);
        HttpRequest request = GeneralUtil.createGetRequest(customMeatDataName,null,headerPairs, prospectId);
        System.debug('### Pardot query request: ' + request);
        Http http = new Http();
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200){
            xmlResponse = response.getBody();
            //System.debug('### xmlResponse from Pardot is: ' + xmlResponse);
            DOM.Document document = new DOM.Document();
            //if(!Test.isRunningTest()){
             	document.load(xmlResponse);
                if (document.getRootElement().getAttribute('stat',null) == 'ok'){
                	return xmlResponse;
            	}   
            //}
        }
        EventBus.publish(LogEventUtils.createLogEventRecord(new List<String>{prospectId}, 'Pardot Utils', 'readPardot', 
               String.valueOf(response.getStatusCode()), response.getBody(),'Error', request, new List<String>(headerPairs.keySet())));
        if(Test.isRunningTest()){
            	return PardotUtilsTest.getFakePardotReadResponse('fail');    
    	}
        return null;
    }
        
}
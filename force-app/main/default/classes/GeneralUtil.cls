/**
* @author Gad Sharon
* @date 11/11/2020
* @description General functions that can help us throughout the code base
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - 
* date        - 
* description - 
* --------------------------------------------------------------------------------------                     
*/

public with sharing class GeneralUtil {

    private static LeadStatus TMP_CONVERT_LEAD_STATUS;

    /**
    * @author Developer Synebo
    * @date 22/12/2020
    * @description Query LeadStatus depending on the value stored in CS_LeadConvert__c.
    */
    public static LeadStatus CONVERT_LEAD_STATUS {
        get {
            if (TMP_CONVERT_LEAD_STATUS != null) {
                return TMP_CONVERT_LEAD_STATUS;
            }
            CS_LeadConvert__c csConvertStatus = CS_LeadConvert__c.getinstance('LeadConvertStatus');
            LeadStatus convertStatus = null;
            if (csConvertStatus == null) {
                convertStatus = [
                    SELECT Id
                        , MasterLabel 
                    FROM LeadStatus
                    WHERE IsConverted = true 
                    LIMIT 1
                ];
            } else {
                convertStatus = [
                    SELECT Id
                        , MasterLabel 
                    FROM LeadStatus 
                    WHERE 
                        IsConverted = true
                        AND MasterLabel = :csconvertstatus.value__c
                    LIMIT 1
                ];
            }
            TMP_CONVERT_LEAD_STATUS = convertStatus;
            return convertStatus;
        }
    }
    
    /**
    * @author Gad Sharon
    * @date 11/11/2020
    * @description Check on which environment we're working on and return the name of the environment.
    * @param None.  
    * @return String - prod if production, name of the sandbox otherwise.
    */

    public static String getEnvName()
    {
        String envName;
        
        if(System.UserInfo.getOrganizationId() == '00Db0000000Xn8aEAC') {
            envName = 'prod';
        }
        else {
            envName = System.UserInfo.getUserName().substringAfterLast('.').toLowerCase();
        }

        return envName;
    }
    
    /**
    * @author Gad Sharon
    * @date 11/11/2020
    * @description Get a general configuration record by name.
    * @param String - General configuration Name.  
    * @return General_Configuration__mdt - The requested general configuration if exists, null otherwise.
    */

    public static General_Configuration__mdt getGeneralConfig(String generalConfigName) {
        try{
            return [SELECT Number_Value__c, Text_Value__c
                    FROM General_Configuration__mdt
                    Where DeveloperName = :generalConfigName Limit 1];
        }
        catch (exception ex)
        {
            return null;
        }
    }

    /**
    * @author Gad Sharon
    * @date 12/11/2020
    * @description Get an api configuration record according to the name of the configuration and the env.
    * @param String - API configuration name.  
    * @return API_Configuration__mdt - The requested API configuration if exists, null otherwise.
    */
    
    public static API_Configuration__mdt getAPIConfig (String apiConfigName)
    {
        apiConfigName += '_' + getEnvName(); 
        try{
            return [SELECT End_Point__c, Header__c, Method__c, Password__c, Token_Id__c, Token_Pass__c, Username__c
                    FROM API_Configuration__mdt
                    Where DeveloperName = :apiConfigName Limit 1];
        }
        catch (exception ex)
        {
            return null;
        }
    }

    /**
    * @author Gad Sharon
    * @date 12/11/2020
    * @description Create an http request.
    * @param String endPoint - The end point this request is directed to.
    * @param String method - The method of the http request (GET/POST etc...).
    * @param String headers - The headers we should add to the request, 
                                Key + value, separated by '::' between the key and the value and by ',,' between the key + value pair.
                                For example: key1::value1,,key1::value2,,key2::value3.
    * @param String body - The body of the request.
    * @return HttpRequest - The request we created.
    */
    
    public static HttpRequest createHttpRequest (String endPoint, String method, String headers, String body)
    {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(method);
        
        if(!String.isBlank(headers)){
            List <String> pairs = headers.split(',,');
            List <String> lst;
            for(String pair : pairs){
                lst = pair.split('::');
                request.setHeader(lst[0], lst[1]);
            }
        }
        
        if(!String.isBlank(body)){
            request.setBody(body);
        }

        return request;
    }

    /**
    * @author Gad Sharon
    * @date 12/11/2020
    * @description Create an http request.
    * @param String apiConfigName - API configuration name.
    * @param String body - The body of the request.
    * @return HttpRequest - The request we created if we found the api config, null otherwise.
    */
    
    public static HttpRequest createHttpRequestFromApiConfigWithBody (String apiConfigName, String body)
    {
        return createHttpRequestFromApiConfigWithBody (apiConfigName, body, false);
    }

    /**
    * @author Developer Synebo
    * @date 17/12/2020
    * @description Create an http request with authorization header
    * @param String apiConfigName - API configuration name.
    * @param String body - The body of the request.
    * @param Boolean isAuth - Flag to add to the authorization header.
    * @return HttpRequest - The request we created if we found the api config, null otherwise.
    */

    public static HttpRequest createHttpRequestFromApiConfigWithBody (String apiConfigName, String body, Boolean isAuth)
    {
        API_Configuration__mdt config = getAPIConfig(apiConfigName);
        if(config == null)
            return null;
        if(isAuth){
            generateAuthHeader(config);
        }
    
        return createHttpRequest(config.End_Point__c, config.Method__c, config.Header__c, body);
    }

    /**
    * @author Developer Synebo
    * @date 16/11/2020
    * @description Generate authorization header for API_Configuration__mdt instance.
    * @param API_Configuration__mdt config - config for which header will be generated.
    * @return API_Configuration__mdt - config with auth headers added.
    */

    public static API_Configuration__mdt generateAuthHeader (API_Configuration__mdt config)
    {
        String baseAuthHeaderKey = 'Authorization';
        String baseAuthHeaderValue = '';
        if (String.isNotBlank(config.Username__c) && String.isNotBlank(config.Password__c)) {
            baseAuthHeaderValue = generateBaseAuthHeaderValue(config.Username__c,config.Password__c);
        }
        String baseAuthHeader = baseAuthHeaderKey+'::'+baseAuthHeaderValue;
        if (String.isNotBlank(config.Header__c)) {
            baseAuthHeader=',,'+baseAuthHeader;
        }
        config.Header__c = config.Header__c + baseAuthHeader;
        return config;
    }

    /**
    * @author Developer Synebo
    * @date 16/11/2020
    * @description Create value for Base Authorization header.
    * @param String username - Username for base auth.
    * @param String password - Password for base auth.
    * @return String - The generated value for base auth header.
    */

    public static String generateBaseAuthHeaderValue (String username, String password)
    {
        Blob headerValueBlob = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValueBlob);
        return authorizationHeader;
    }

    /**
    * @author Developer Synebo
    * @date 16/11/2020
    * @description Query specific Fields_Mapping__mdt metadata.
    * @param String process - idicates for which abstract process Fields_Mapping__mdt should be retrieved.
    * @return List<Fields_Mapping__mdt> - Fields_Mapping__mdt list.
    */

    public static List<Fields_Mapping__mdt> retrieveFieldMappingMetadataList(String process){
        List<Fields_Mapping__mdt> fieldsList = 
        [
            SELECT 
                Concatenate_Order__c,
                Destination_Field__c,
                Source_Field__c,
                Text_After_Field__c,
                Text_Before_Field__c,
                Process__c,
                Cast_To__c,
                Fixed_Value__c,
                    isRequired__c,
                    Keep_Current_Value__c
            FROM Fields_Mapping__mdt
            WHERE Process__c = :process
            ORDER BY Concatenate_Order__c, Source_Field__c
        ];
        return fieldsList;
    }

    /**
    * @author Itzik Winograd
    * @date 10/01/2021
    * @description Query Fields_Mapping__mdt metadata of some processName.
    * @param Set<String> processes - idicates for which abstract process Fields_Mapping__mdt should be retrieved.
    * @return List<Fields_Mapping__mdt> - Fields_Mapping__mdt list.
    */

    public static List<Fields_Mapping__mdt> retrieveFieldMappingMetadataList(List<String> processes){
        List<Fields_Mapping__mdt> fieldsList = 
        [
            SELECT 
                Concatenate_Order__c,
                Destination_Field__c,
                Source_Field__c,
                Text_After_Field__c,
                Text_Before_Field__c,
                Process__c,
                Cast_To__c,
                Fixed_Value__c,
                    isRequired__c,
                    Keep_Current_Value__c
            FROM Fields_Mapping__mdt
            WHERE Process__c IN :processes
            ORDER BY Process__c, Concatenate_Order__c, Source_Field__c
        ];
        return fieldsList;
    }
    
    /**
    * @author Developer Synebo
    * @date 16/11/2020
    * @description Query specific General_Configuration__mdt metadata.
    * @param Set<String> filedValueSet - set of Developer names to be queried.
    * @return List<General_Configuration__mdt> - General_Configuration__mdt list.
    */

    public static List<General_Configuration__mdt> retrieveConfigurationMetadata(Set<String> filedValueSet){

        List<General_Configuration__mdt> generalConfMeta = [
            SELECT 
                DeveloperName,
                Text_Value__c,
                Number_Value__c
            FROM General_Configuration__mdt
            WHERE DeveloperName IN: filedValueSet
        ];

        return generalConfMeta;
    }

    /**
    * @author Developer Synebo
    * @date 16/11/2020
    * @description Query specific General_Configuration__mdt metadata.
    * @param String identifier - key, with wich Name of metadatarecord should start.
    * @return List<General_Configuration__mdt> - General_Configuration__mdt list.
    */

    public static List<General_Configuration__mdt> retrieveConfigurationMetadata(String identifier){
        identifier = identifier+'%';
        List<General_Configuration__mdt> generalConfMeta = [
            SELECT 
                DeveloperName,
                Text_Value__c,
                Number_Value__c
            FROM General_Configuration__mdt
            WHERE DeveloperName LIKE :identifier
        ];

        return generalConfMeta;
    }

      /**
    * @author Itzik Winograd
    * @date 22/12/2020
    * @description Get field sets by object name and fie name.
    * @param String objectName - the desired object namt to take the Field set from the
    * @param String fieldSetName - the field set name
    * @return List<String> - The requested field set if found, null if none found/misspelled objectName/fieldSetName
    */
    public static List<String> getFieldSet (String objectName, String fieldSetName){
        List<String> returnedFieldSet = new List<String>();
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(ObjectName);
        if(sObjectTypeObj!=null){ 
            Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            //system.debug('====>' + fieldSetObj);
            if (fieldSetObj != null){
                List<Schema.FieldSetMember> fieldSetMemberList = fieldSetObj.getFields();
                //system.debug('fieldSetMemberList ====>' + fieldSetMemberList); 
                for (Schema.FieldSetMember fld : fieldSetMemberList){
                    returnedFieldSet.add(fld.getFieldPath());
                }
                return returnedFieldSet;
            }
        }
        return null;
    }

    /**
    * @author Itzik Winograd
    * @date 13/01/2021
    * @description cast an object to a given type
    * @param Object vlaue - the value to cast
    * @param String castTo - primitive type to cast the object to
    * @param String dateFormat - date format, like 'MM/dd/yyyy'
    * @return Object - casted value
    */

    public static Object castObjectTo(Object value, String castTo, String dateFormat){
        Object retunedValue = value;
        if(castTo == 'Boolean'){
            retunedValue = Boolean.valueOf(value);
        } else if(castTo == 'Integer'){
            retunedValue = Integer.valueOf(value);
        } else if(castTo == 'Datetime'){
            retunedValue = value instanceOf String ? Datetime.valueOf((String)value) : (Datetime)value;
            //retunedValue = Datetime.valueOf((String)value);
        } else if(castTo == 'Date'){
            retunedValue = value instanceOf String ? Date.valueOf((String)value) : (Date)value;
            //retunedValue = Date.valueOf((String)value); //working for GUTest, not other tests
            //retunedValue = value instanceOf Datetime ? ((Datetime)value).date(): (Date)value;
        } else if(castTo == 'Id'){
            retunedValue = Id.valueOf((String)value);
        } else if(castTo == 'Decimal'){
            retunedValue = Decimal.valueOf((String)value);
        } else if(castTo == 'Double'){
            retunedValue = Double.valueOf(value);
        } else if(castTo == 'Long'){
            retunedValue = Long.valueOf((String)value);
        } else if (castTo=='String'){
            if (value instanceOf Date) {
                retunedValue = Datetime.valueOf(value).format(dateFormat);
            } else if (value instanceOf Decimal) {
                retunedValue = Decimal.valueOf((String)value).format();
            } else {
                retunedValue = JSON.serialize(value).removeEnd('"').removeStart('"');
            }
        }
        return retunedValue;
    }
    /**
    * @author Zohar Sinay
    * @date 21/07/2021
    * @description Checks if the specified field exists on the sent SObject
    * @return Boolean - true if exists, false if doesn't (lowercase comparison)
    */
    public static boolean hasSObjectField(SObject so, String fieldName){
        return so.getSobjectType().getDescribe().fields.getMap().keySet().contains(fieldName.toLowerCase());
    }

    /**
    * @author Zohar Sinay
    * @date 01/07/2021
    * @description Get the custom metadata key-pair value from the Country_Picklist_Values metadata
    * @return Map<String,String> - key-pair value for all countries in the custom metadata
    */
    public static Map<String, String> getCountryCodeToName(){
        Map<String, String> countryCodeToNameMap = new Map<String, String>();
        for(Country_Picklist_Values__mdt cnt : [SELECT DeveloperName, CountryName__c FROM Country_Picklist_Values__mdt]){
            countryCodeToNameMap.put(cnt.DeveloperName, cnt.CountryName__c);
        }
        return countryCodeToNameMap;
    }

    /**
    * @author Zohar Sinay
    * @date 01/07/2021
    * @description Get the custom metadata key-pair value from the Fields_Mapping metadata
    * @return Map<String,Fields_Mapping__mdt> - key-pair value for all attributes in the custom metadata
    */
    public static Map<String, Fields_Mapping__mdt> getLeadCaptureByAttribute(List<Fields_Mapping__mdt> fieldsMappingList, String process){
        Map<String, Fields_Mapping__mdt> leadCaptureByAttributeMap = new Map<String, Fields_Mapping__mdt>();
        for(Fields_Mapping__mdt fm : fieldsMappingList){
            if(fm.Process__c == process){
                leadCaptureByAttributeMap.put(fm.Source_Field__c, fm);
            }
        }
        return leadCaptureByAttributeMap;
    }

    public static Map<String,List<Fields_Mapping__mdt>> getLeadCaptureKeyToListMap(List<Fields_Mapping__mdt> fieldsMappingList, String process){ // changed in 29.12.2024 to lowerCase always map
        Map<String,List<Fields_Mapping__mdt>> leadCaptureKeyToListMap = new Map<String, List<Fields_Mapping__mdt>>();
        for(Fields_Mapping__mdt fm : fieldsMappingList){
            if(fm.Process__c == process){
                if(!leadCaptureKeyToListMap.containsKey(fm.Source_Field__c)){
                    leadCaptureKeyToListMap.put(fm.Source_Field__c, new List<Fields_Mapping__mdt>());
                }
                leadCaptureKeyToListMap.get(fm.Source_Field__c).add(fm); // change back to upper case for now 05.1.25
            }

        }
        return leadCaptureKeyToListMap;
    }

    /**
    * @author Itzik Winograd
    * @date 17/01/2021
    * @description Get the custom metadata key-pair value for a given process name from the "General Key-Value pair" cmd
    * @param String processName - the process name by which to get the records for
    * @returnList <General_Key_Value_pair__mdt> - key-pair value for a given process, null if none found
    */
    public static List<General_Key_Value_pair__mdt> getKeyValuePairs(String processName){
        List<General_Key_Value_pair__mdt> pairs = new List<General_Key_Value_pair__mdt>(
            [SELECT Key__c , Value__c  
            FROM General_Key_Value_pair__mdt 
            WHERE ProcessName__c = :processName]);
        if (pairs!= null){
            return pairs;
        }
        return null;
    }

    /**
    * @author Itzik Winograd
    * @date 02/02/2021
    * @description return the object name of a given Id
    * @param Id id - the Id of the record 
    * @return String the object name found, lowercase
    */
    public static String getObjectNameFromId(Id objId) {
        return objId.getSObjectType().getDescribe().getName().toLowerCase();
    }

    /**
    * @author Itzik Winograd
    * @date 16/07/2021
    * @description return the object name from a given SObject
    * @param SObject sobj - the object to get the name from
    * @return String the object name found, lower case
    */
    public static String getObjectNameFromSObject(SObject sobj) {
        return sobj.getSObjectType().getDescribe().getName().toLowerCase();

    }
    

    /**
    * @author Itzik Winograd
    * @date 04/03/2021
    * @description Creates a get request. 
    * @param String apiConfigName - the name of the api config in the custom meta data 
    * @param Map<String,String> endpointPairs - map of key and value to add to the endpoint. 
    * Assuming first argument with "?" is already applied in the custom metadata. 
    * @param Map<String,String> headerPairs - key value pairs to be added as headers.
    * @return 
    */
    public static HTTPRequest createGetRequest(String apiConfigName, Map<String,String> endpointPairs, Map<String,String> headerPairs){
        HTTPRequest request;
        API_Configuration__mdt config = getAPIConfig(apiConfigName);
        //generate endpoint
        String endpoint = config.End_Point__c;
        if(endpoint!=null && endpointPairs != null){
            for (String endpointKey : endpointPairs.keySet()){
                endpoint+='&'+endpointKey+'='+endpointPairs.get(endpointKey);
            }
        }
        //generate headers
        String headers='';
        if(config.Header__c != null){
            headers = config.Header__c;
        }
        if(headerPairs!=null){
            if(headers!=''){
                headers+=',,';
            }
            Integer i = 1;
            for (String headreKey : headerPairs.keySet()){
                headers+=headreKey+'::'+headerPairs.get(headreKey);
                if (i++ < headerPairs.keySet().size()){
                    headers+=',,';
                }
            }
        }
        request = createHttpRequest(endpoint, config.Method__c, headers, '');//body is empty on GET Calls
        return request;
    }


    /**
    * @author Itzik Winograd
    * @date 25/04/2021
    * @description Creates a get request with Additions in the URL. 
    * @param String apiConfigName - the name of the api config in the custom meta data 
    * @param Map<String,String> endpointPairs - map of key and value to add to the endpoint. 
    * @param Map<String,String> headerPairs - key value pairs to be added as headers.
    * @param String endpointUrlAddition - an addition to the url, before the other key-value params
    * @return 
    */
    public static HTTPRequest createGetRequest(String apiConfigName, Map<String,String> endpointPairs, 
                        Map<String,String> headerPairs, String endpointUrlAddition){
        HTTPRequest request;
        API_Configuration__mdt config = getAPIConfig(apiConfigName);
        //generate endpoint
        String endpoint = config.End_Point__c;
        if (endpoint!=null && endpointUrlAddition != null){
            endpoint+=endpointUrlAddition;
        }
        if (endpoint!=null && endpointPairs != null){
            for (String endpointKey : endpointPairs.keySet()){
                endpoint+='&'+endpointKey+'='+endpointPairs.get(endpointKey);
            }
        }
        //generate headers
        String headers='';
        if(config.Header__c != null){
            headers = config.Header__c;
        }
        if(headerPairs!=null){
            if(headers!=''){
                headers+=',,';
            }
            Integer i = 1;
            for (String headreKey : headerPairs.keySet()){
                headers+=headreKey+'::'+headerPairs.get(headreKey);
                if (i++ < headerPairs.keySet().size()){
                    headers+=',,';
                }
            }
        }
        request = createHttpRequest(endpoint, config.Method__c, headers, '');//body is empty on GET Calls
        return request;
    }

    /**
    * @author Itzik Winograd
    * @date 05/10/2021
    * @description Take the exchange rates from the custom settings and return a map of <String-Currrency, Decimal-Rate> for easy use.
    * @param None.  
    * @return Map<String,Decimal> of Currency Code vs. rate.
    */

    public static Map<String,Decimal> getNetsuiteDailyExchangeRateMap(){
        Map<String,Decimal> erMap = new Map<String,Decimal>();
        List<Netsuite_Daily_Exchange_Rate__c> dailyExchangesList = Netsuite_Daily_Exchange_Rate__c.getAll().values();
        for(Netsuite_Daily_Exchange_Rate__c nser : dailyExchangesList){
            erMap.put(nser.Name, nser.USD_Exchange_Rate__c);
        }
        return erMap;
    }

    /**
    * @author Itzik Winograd
    * @date 27/10/2021
    * @description Get the custom metadata key-pair value for a given process name from the "General Key-Value pair" cmd
    * @param String processName - the process name by which to get the records for
    * @return Map<String,String> - key-pair value for a given process, null if none found
    */
    public static Map<String,String> getKeyValuePairsMap(String processName){
        List<General_Key_Value_pair__mdt> cmdtResultsList = GeneralUtil.getKeyValuePairs(processName);
        Map<String,String> returnMap = new Map<String,String>();
        if(!cmdtResultsList.isEmpty()){
            for(General_Key_Value_pair__mdt cmdt : cmdtResultsList){
                returnMap.put(cmdt.Key__c, cmdt.Value__c);
            }
        }
        return returnMap;
    }

    public static boolean isFieldChangeFromSet(Sobject newSObject , SObject oldSObject , Set<String> fieldSet){
        Boolean isChanged = false;
        for(String fieldName : fieldSet){
            if(newSObject.get(fieldName) != oldSObject.get(fieldName)){
                isChanged = true;
                break;
            }
        }
        return isChanged;
        }


    /**
    * @author Itzik Winograd
    * @date 02/10/2022
    * @description Returns the prefix - 3 chars - of any given SObject
    * @param String SObjectName
    * @return String the prefix
    */
    public static String getSObjectPrefixByName(String SObjectName){
        Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
        //system.debug('==>m is==>'+m);
        Schema.SObjectType s = m.get(SObjectName);
        //system.debug('==>Sobject Type is ==>'+s);
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }
    /**
    * @author alon shalev
    * @date 02/10/2022
    * @description Returns event time (before after)
    * @return String the event time
    */

    public static String determineEventTime(){
        String eventTime;
        try{
            eventTime = trigger.isBefore ? 'before' : 'after';

        }catch(Exception ex){
            system.debug('exception -- '+ex.getMessage());
            system.debug('stackTrace--'+ex.getStackTraceString());

        }
        return eventTime;
    }

    /**
    * @author alon shalev
    * @date 02/10/2022
    * @description Returns event type (insert update delete undelete)
    * @return String the event type
    */

    public static string determineEventType(){
        String eventType;
        try{
            eventType = trigger.isInsert ? 'insert' : trigger.isUpdate ? 'update' : trigger.isDelete ? 'delete' : 'undelete';

        }catch(Exception ex){
            system.debug('exception -- '+ex.getMessage());
            system.debug('stackTrace--'+ex.getStackTraceString());

        }
        return eventType;

    }

    /**
     * @date 15/12/2022
     * @author Itzik Winograd
     * @description send an email alert based on an Email Template
     * @param List<Id> unsuccessfullySObjectIdList - object Ids
     * @param String emailTemplateName - developer name of the email template to send
     * @param String emailGeneralConfig - A General Configuration record where the Text_Value__c holds the address
     */
    public static void sendEmailNotifications(List<Id> unsuccessfullySObjectIdList, String emailTemplateName, String emailGeneralConfig){
        EmailTemplate emailTemplate = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body
                                         FROM EmailTemplate
                                        WHERE DeveloperName  =: emailTemplateName
                                        LIMIT 1];
        String address = GeneralUtil.retrieveConfigurationMetadata(emailGeneralConfig)[0].Text_Value__c;
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        for(Id sObjectId: unsuccessfullySObjectIdList){
            Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, UserInfo.getUserId(), sObjectId);
            String emailSubject = email.getSubject();
            String emailTextBody = email.getPlainTextBody();
            System.debug('### emailTextBody: ' + emailTextBody);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setSubject(emailSubject);
            message.setHtmlBody(emailTextBody);
            message.setSenderDisplayName('Notification');
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
            message.toAddresses = new String[] {address};
            messageList.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messageList);

        if (!results[0].success) {
            System.debug('### The following email failed to send: ' +  results[0].errors[0].message);
        }
    }
    
}
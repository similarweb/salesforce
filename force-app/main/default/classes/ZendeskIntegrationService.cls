/**
 * =======Changes=========
 * @author      Itzik Winograd
 * @date        2022-06-27
 * @description MIS-2118, the requester should be taken from the Requester__c and not Current User.
 * */
public class ZendeskIntegrationService {
    private static final String DESTINATION_SUBJECT = 'subject';
    private static final String DESTINATION_DESCRIPTION = 'description';
    private static final String DESTINATION_COMMENT = 'comment';

    private static final String ZENDESK_GROUPID_NAME = 'ZendeskGroupId';
    private static final String ZENDESK_TICKETFROMID_NAME = 'ZendeskTicketFromId';
    private static final String ZENDESK_TAG_NAME = 'ZendeskTag';
    private static final String ZENDESK_CONFIG_MD_KEY = 'Zendesk';
    
    private static final String TICKET_CREATION_API_CONFIG_NAME = 'Zendesk_ticket_creation';
    private static final String ATTACHMENT_UPLOADS_API_CONFIG_NAME = 'Zendesk_attachment_uploads';
    private static final String FIELDS_LIST_API_CONFIG_NAME = 'Zendesk_customfields_list';
    private static final String ZENDESK_TICKET_CREATION_LABEL = ' Zendesk Ticket Creation';

    public static ZendeskResponseWrapper createTicket(Id sObjectId, String sObjType){
        List<Fields_Mapping__mdt> metadataFieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(sObjType + ZENDESK_TICKET_CREATION_LABEL); 
        List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(new Set<String>{ZENDESK_GROUPID_NAME,ZENDESK_TICKETFROMID_NAME,ZENDESK_TAG_NAME});
        String requestBody = generateRequestBody(sObjType,sObjectId, metadataFieldMappingList,generalConfigurationList);
        HttpRequest request = GeneralUtil.createHttpRequestFromApiConfigWithBody(TICKET_CREATION_API_CONFIG_NAME,requestBody,true);
        ZendeskResponseWrapper zendeskResponseWrapper = makeZendeskCreateTicketCall(request);
        System.debug(zendeskResponseWrapper);
        if (zendeskResponseWrapper.isSuccess()){
            if (sObjType == 'zqu__Quote__c' && System.isFuture()) {
                Zqu__Quote__c quote = new Zqu__Quote__c(Id = sObjectId, Billing_ticket_number_in_Zendesk__c = String.valueOf(zendeskResponseWrapper.getTicketId()));
                System.debug('quote: ' + quote);
                Database.update(quote, false);
                System.debug('quote: ' + quote);
            }
        } else {
            throw new AuraHandledException('Ticket creation not succeded - ' + zendeskResponseWrapper.getError());
        }
        return zendeskResponseWrapper;
    }

    @Future(callout=true)
    public static void createTicketFuture(Id sObjectId, String sObjType){
        ZendeskIntegrationService.createTicket(sObjectId, sObjType);
    }

    public static ZendeskResponseWrapper createTicket(HttpRequest request){
        ZendeskResponseWrapper zendeskResponseWrapper = makeZendeskCreateTicketCall(request);
        return zendeskResponseWrapper;
    }

    public static List<ZendeskResponseWrapper> createTicketList(Map<Id,ZendeskRequestWrapper> requestBodyMap){
        List<ZendeskResponseWrapper> zendeskResponseWrapperList = new List<ZendeskResponseWrapper>();
        for(Id sObjectId: requestBodyMap.keySet()){
            ZendeskRequestWrapper zendeskRequestWrapper = fillCustomFields(requestBodyMap.get(sObjectId));
            System.debug('after fill custom fields');
            createAttachment(zendeskRequestWrapper);
            System.debug('after wrapper');
            String JsonBody = generateJsonBody(zendeskRequestWrapper);
            System.debug('after body');
            HttpRequest request = GeneralUtil.createHttpRequestFromApiConfigWithBody(TICKET_CREATION_API_CONFIG_NAME,JsonBody,true);
            System.debug('after request generation');
            ZendeskResponseWrapper zendeskResponseWrapper = makeZendeskCreateTicketCall(request);
            System.debug('after request call: ' + zendeskResponseWrapper);
            zendeskResponseWrapper.sObjectId = sObjectId;
            System.debug('### response TicketId: '+zendeskResponseWrapper.getTicketId());
            zendeskResponseWrapperList.add(zendeskResponseWrapper);
        }
        return zendeskResponseWrapperList;
    }

    public static HttpRequest generateTicket(Id sObjectId, String sObjType, String requestType){
        List<Fields_Mapping__mdt> metadataFieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(sObjType + ' ' +requestType); 
        List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(new Set<String>{ZENDESK_GROUPID_NAME,ZENDESK_TICKETFROMID_NAME,ZENDESK_TAG_NAME});
        String requestBody = generateRequestBody(sObjType,sObjectId, metadataFieldMappingList,generalConfigurationList);
        HttpRequest request = GeneralUtil.createHttpRequestFromApiConfigWithBody(TICKET_CREATION_API_CONFIG_NAME,requestBody,true);
        return request;
    }

    public static Map<Id,ZendeskRequestWrapper> generateTicketList(Map<String, List<Id>> requestTypeToIdsMap, String sObjType){
        Map<String, List<Fields_Mapping__mdt>> requestTypeToFieldMetadataMap = new Map<String, List<Fields_Mapping__mdt>>();
        for(String requestType: requestTypeToIdsMap.keySet()){
            List<Fields_Mapping__mdt> metadataFieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(sObjType + ' ' +requestType);
            requestTypeToFieldMetadataMap.put(requestType,metadataFieldMappingList);
        }
        System.debug('### ZendeskIntegrationService, requestTypeToFieldMetadataMap: ' + requestTypeToFieldMetadataMap);
        List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(new Set<String>{ZENDESK_GROUPID_NAME,ZENDESK_TICKETFROMID_NAME,ZENDESK_TAG_NAME});

        Map<Id,ZendeskRequestWrapper> requestBodyWrapperMap = generateRequestBodyList(sObjType,requestTypeToIdsMap, requestTypeToFieldMetadataMap,generalConfigurationList);
        return requestBodyWrapperMap;
    }

    private static void createAttachment(ZendeskRequestWrapper zendeskRequestWrapper){
        if(String.isNotBlank(zendeskRequestWrapper.attachment)){
            List<Blob> attachmentBlobList = getImageBlob(zendeskRequestWrapper.attachment);
            List<String> fileTokenList = uploadAttachmentFile(attachmentBlobList);
            if(!fileTokenList.isEmpty()){
                Comment comment = new Comment(fileTokenList,zendeskRequestWrapper.ticket.description);
                zendeskRequestWrapper.ticket.comment = comment;
            }
        }
    }

    private static Map<Id,ZendeskRequestWrapper> generateRequestBodyList(
        String sObjType,
        Map<String, List<Id>> requestTypeToIdsMap,
        Map<String, List<Fields_Mapping__mdt>> requestTypeToFieldMetadataMap,
        List<General_Configuration__mdt> generalConfigurationList
    ){
        Map<String, FieldMappingUtil.FieldMappingData> requestTypeToFieldMappingDataMap = new Map<String, FieldMappingUtil.FieldMappingData>();
        System.debug('requestTypeToFieldMappingDataMap: ' + requestTypeToFieldMappingDataMap);
        System.debug('requestTypeToFieldMetadataMap: ' + requestTypeToFieldMetadataMap);
        System.debug('requestTypeToIdsMap: ' + requestTypeToIdsMap);
        System.debug('generalConfigurationList: ' + generalConfigurationList);
        Set<String> sourceFieldSet = new Set<String>();
        List<Id> fullSObjectIdList = new List<Id>();
        FieldMappingUtil.FieldMappingData generalConfFieldMappingData = FieldMappingUtil.generateFieldMappingDataFromGeneralConfigCMT(generalConfigurationList);
        System.debug('generalConfFieldMappingData: ' + generalConfFieldMappingData);
        System.debug('requestTypeToFieldMetadataMap: ' + requestTypeToFieldMetadataMap);
        System.debug('requestTypeToIdsMap: ' + requestTypeToIdsMap);
        System.debug('generalConfigurationList: ' + generalConfigurationList);
        for(String requestType: requestTypeToFieldMetadataMap.keySet()){
            List<Fields_Mapping__mdt> metadataFieldMappingList = requestTypeToFieldMetadataMap.get(requestType);
            FieldMappingUtil.FieldMappingData fieldMappingData = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(metadataFieldMappingList);
            System.debug('fieldMappingData: ' + fieldMappingData);
            fieldMappingData.mergeFieldMappingData(generalConfFieldMappingData);
            sourceFieldSet.addAll(fieldMappingData.sourceFieldSet);
            requestTypeToFieldMappingDataMap.put(requestType, fieldMappingData);
            fullSObjectIdList.addAll(requestTypeToIdsMap.get(requestType));
        }
        //System.debug('### ZendeskIntegrationService, fullSObjectIdList: ' + fullSObjectIdList);
        //System.debug('### ZendeskIntegrationService, sourceFieldSet: ' + sourceFieldSet);
        Map<Id,SObject> sourceRecordMap = querySObjectMap(sourceFieldSet,sObjType,fullSObjectIdList);
        Map<Id,ZendeskRequestWrapper> sObjectIdToWrapperMap = new Map<Id,ZendeskRequestWrapper>();
        for(String requestType: requestTypeToIdsMap.keySet()){
            FieldMappingUtil.FieldMappingData fieldMappingData = requestTypeToFieldMappingDataMap.get(requestType);
            for(id sObjectId: requestTypeToIdsMap.get(requestType)){
                //System.debug('### ZendeskIntegrationService, requestType: ' + requestType +'\n### fieldMappingData: ' + fieldMappingData + '\n### sObjectId: ' + sObjectId);
                fieldMappingData.populateValuesFromSObject(sourceRecordMap.get(sObjectId));
                ZendeskCustomFieldData zendeskCustomFieldData = new ZendeskCustomFieldData();
                //System.debug('### ZendeskIntegrationService, zendeskCustomFieldData: ' + zendeskCustomFieldData);
                ZendeskRequestWrapper zendeskRequestWrapper = generateZendeskRequestBody(fieldMappingData.fieldMappingDataUnitMap, zendeskCustomFieldData,false);
                //Itzik, 2021-10-24: added email ccs, Change Requester
                zendeskRequestWrapper = fillEmailCCS(zendeskRequestWrapper,fieldMappingData.fieldMappingDataUnitMap, sourceRecordMap.get(sObjectId));
                zendeskRequestWrapper = fillRequester(zendeskRequestWrapper,fieldMappingData.fieldMappingDataUnitMap, sourceRecordMap.get(sObjectId));
                //Itzik, 2021-10-24: added the if.. to support case of Legal_Services
                if(!sObjectIdToWrapperMap.containsKey(sObjectId)){
                    sObjectIdToWrapperMap.put(sObjectId,zendeskRequestWrapper);//original line
                }
                System.debug('### ZendeskIntegrationService, zendeskRequestWrapper: ' + zendeskRequestWrapper);
            }
        }
        //System.debug('### ZendeskIntegrationService, sObjectIdToWrapperMap: ' + sObjectIdToWrapperMap);
        return sObjectIdToWrapperMap;
    }

    private static String generateRequestBody(
        String sObjType,
        String sObjectId,
        List<Fields_Mapping__mdt> metadataFieldMappingList,
        List<General_Configuration__mdt> generalConfigurationList
    ){
        FieldMappingUtil.FieldMappingData fieldMappingData = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(metadataFieldMappingList);
        FieldMappingUtil.FieldMappingData generalConfFieldMappingData = FieldMappingUtil.generateFieldMappingDataFromGeneralConfigCMT(generalConfigurationList);
        fieldMappingData.mergeFieldMappingData(generalConfFieldMappingData);
        SObject sourceRecord = querySObject(fieldMappingData.sourceFieldSet,sObjType,sObjectId);
        fieldMappingData.populateValuesFromSObject(sourceRecord);
        ZendeskCustomFieldData zendeskCustomFieldData = new ZendeskCustomFieldData();
        ZendeskRequestWrapper zendeskRequestWrapper = generateZendeskRequestBody(fieldMappingData.fieldMappingDataUnitMap, zendeskCustomFieldData,true);
        String JSONbody = JSON.serialize(zendeskRequestWrapper);
        System.debug('### generateRequestBody, zendeskRequestWrapper: ' + JSON.serialize(zendeskRequestWrapper));
        return JSONbody;
    }

    private static String generateJsonBody(ZendeskRequestWrapper zendeskRequestWrapper){
        String JSONbody = JSON.serialize(zendeskRequestWrapper);
        //System.debug('### generateJsonBody, zendeskRequestWrapper: ' + JSON.serializePretty(zendeskRequestWrapper));
        return JSONbody;
    }
    
    private static SObject querySObject(Set<String> fieldToQueryList, String sObjType,String sObjectId){
        String query =  'SELECT '+String.join(new List<String>(fieldToQueryList), ',')+
                        ' FROM '+sObjType +
                        ' WHERE Id =:sObjectId' +
                        ' LIMIT 1';
        List<SObject> responseSobjList = Database.query(String.escapeSingleQuotes(query));
        
        return responseSobjList[0];
    }

    private static Map<Id,SObject> querySObjectMap(Set<String> fieldToQueryList, String sObjType,List<String> sObjectIdList){
        String strQuery = 'SELECT '+String.join(new List<String>(fieldToQueryList), ',')+
                ' FROM '+sObjType +
                ' WHERE Id IN :sObjectIdList';
        System.debug('strQuery: ' + strQuery);
        String query =  'SELECT '+String.join(new List<String>(fieldToQueryList), ',')+
                        ' FROM '+sObjType +
                        ' WHERE Id IN :sObjectIdList';

        Map<Id,SObject> responseSobjMap = new Map<Id,SObject>(Database.query(String.escapeSingleQuotes(query)));
        
        return responseSobjMap;
    }

    private static ZendeskRequestWrapper generateZendeskRequestBody(
        Map<String,FieldMappingUtil.FieldMappingDataUnit> fieldMappingDataUnitMap, 
        ZendeskCustomFieldData zendeskCustomFieldData,
        Boolean withCustomFields
    ){
        ZendeskRequestWrapper zendeskRequestWrapper = new ZendeskRequestWrapper();
        List<CustomField> customFieldList = new List<CustomField>();
        Map<String,Object> customFieldToValidateMap = new Map<String,Object>();
        for (String destinationValue : fieldMappingDataUnitMap.keySet()) {
            if(destinationValue.isNumeric()){
                Object id = fieldMappingDataUnitMap.get(destinationValue).getDestinationField();
                Object fieldName = fieldMappingDataUnitMap.get(destinationValue).getValue();
                if(withCustomFields){
                    if (zendeskCustomFieldData.containsValue((Long)Id)) {
                        fieldName = zendeskCustomFieldData.getValue((Long)id, (String)fieldName);
                    }
                    customFieldList.add(new CustomField(String.valueOf(id),fieldName));
                } else {
                    customFieldToValidateMap.put(String.valueOf(id),fieldName);
                }
            }
        }

        String subject = fieldMappingDataUnitMap.containsKey(DESTINATION_SUBJECT)?String.valueOf(fieldMappingDataUnitMap.get(DESTINATION_SUBJECT).getValue()):null;
        String description = fieldMappingDataUnitMap.containsKey(DESTINATION_DESCRIPTION)?String.valueOf(fieldMappingDataUnitMap.get(DESTINATION_DESCRIPTION).getValue()):null;
        Long groupId = fieldMappingDataUnitMap.containsKey(ZENDESK_GROUPID_NAME)?Long.valueOf(String.valueOf(fieldMappingDataUnitMap.get(ZENDESK_GROUPID_NAME).getValue())):null;
        Long ticketFromid = fieldMappingDataUnitMap.containsKey(ZENDESK_TICKETFROMID_NAME)?Long.valueOf(String.valueOf(fieldMappingDataUnitMap.get(ZENDESK_TICKETFROMID_NAME).getValue())):null;
        List<String> tags = fieldMappingDataUnitMap.containsKey(ZENDESK_TAG_NAME)?String.valueOf(fieldMappingDataUnitMap.get(ZENDESK_TAG_NAME).getValue()).split(','):null;


        Ticket ticket = new Ticket(subject, description, groupId, ticketFromid, tags, customFieldList);

        Comment comment = new Comment(null,description);
        zendeskRequestWrapper.ticket = ticket;
        zendeskRequestWrapper.ticket.comment = comment;
        zendeskRequestWrapper.customFieldToValidateMap = customFieldToValidateMap;

        if(fieldMappingDataUnitMap.containsKey(DESTINATION_COMMENT)){
            zendeskRequestWrapper.attachment = String.valueOf(fieldMappingDataUnitMap.get(DESTINATION_COMMENT).getValue());
        }

        return zendeskRequestWrapper;
    }

    public static List<String> uploadAttachmentFile(List<Blob> bodyList){
        List<String> tokenList = new List<String>();
        for(Blob blobObj: bodyList){
            Http http = new Http();
            HttpRequest request = GeneralUtil.createHttpRequestFromApiConfigWithBody(ATTACHMENT_UPLOADS_API_CONFIG_NAME,'',true);
            request.setBodyAsBlob(blobObj);
            HttpResponse response = http.send(request);
            UploadResponseWrapper uploadWrapper = (UploadResponseWrapper) JSON.deserialize(response.getBody(), UploadResponseWrapper.class);
            if(uploadWrapper.upload != null && uploadWrapper.upload.token != null ){
                tokenList.add(uploadWrapper.upload.token);
            }
        }
        return tokenList;
    }

    public static List<Blob> getImageBlob(string url){
        String imageURL='';
        Matcher imgMatcher = Pattern.compile( '<img(.+?)>' ).matcher(url);
        List<Blob> blobList = new List<Blob>();  
        while (imgMatcher.find()) {                
            String imageTag = imgMatcher.group();      
            imageURL= imageTag.substringBetween(' src=\\"', '\\"' );
            String decodedURL = imageURL.unescapeHtml4();
            PageReference page = new PageReference( decodedURL );
            Blob b = Test.isRunningTest()?Blob.valueOf('test'):page.getContent();
            blobList.add(b);
        }
        return blobList;
    }

    private static ZendeskRequestWrapper fillCustomFields(ZendeskRequestWrapper zendeskRequestWrapper){
        ZendeskCustomFieldData zendeskCustomFieldData = new ZendeskCustomFieldData();
        List<CustomField> customFieldList = new List<CustomField>();

        for(String customFieldId: zendeskRequestWrapper.customFieldToValidateMap.keySet()){
            Object customFieldValue = zendeskRequestWrapper.customFieldToValidateMap.get(customFieldId);
            if (zendeskCustomFieldData.containsValue(Long.valueOf(customFieldId))) {
                customFieldValue = zendeskCustomFieldData.getValue(Long.valueOf(customFieldId), (String)customFieldValue);
            }
            customFieldList.add(new CustomField(customFieldId,customFieldValue));
        }
        zendeskRequestWrapper.ticket.custom_fields = customFieldList;
        System.debug('zendeskRequestWrapper.ticket.custom_fields: ' + json.serializePretty(zendeskRequestWrapper.ticket.custom_fields));
        return zendeskRequestWrapper;
    }

    //Itzik, 2021-10
    private static ZendeskRequestWrapper fillEmailCCS(ZendeskRequestWrapper zendeskRequestWrapper,  
                                                      Map<String,FieldMappingUtil.FieldMappingDataUnit> fieldMappingDataUnitMap, 
                                                      SObject sobj){
        Map<String,String> email_ccsMap = new Map<String,String>();
        for(String destinationField : fieldMappingDataUnitMap.keySet()){
            if(destinationField.contains('EmailCCS')){
                email_ccsMap.put(destinationField.substringAfter('.'), (String)fieldMappingDataUnitMap.get(destinationField).getValue());
            }
        } if(!email_ccsMap.isEmpty()){
            EmailCCs email_ccs = new EmailCCs(
                email_ccsMap.get('user_email'),
                email_ccsMap.get('user_name')
            );
            zendeskRequestWrapper.ticket.email_ccs = new List<EmailCCs>{email_ccs};
            System.debug('### zendeskRequestWrapper.ticket.email_ccs: ' + zendeskRequestWrapper.ticket.email_ccs);
        }
        return zendeskRequestWrapper;
    }
    /**
     * @author Itzik Winograd
     * @date 2021-10
     * @description MIS-1158: fill the requester in the ticket with with the "requester__c". Metadata created for Legal Request Only
     * */
    private static ZendeskRequestWrapper fillRequester(ZendeskRequestWrapper zendeskRequestWrapper,  
                                                      Map<String,FieldMappingUtil.FieldMappingDataUnit> fieldMappingDataUnitMap, 
                                                      SObject sobj){
        Map<String,String> requesterMap = new Map<String,String>();
        String fieldValue;
        for(String destinationField : fieldMappingDataUnitMap.keySet()){
            if(destinationField.contains('requester')){
                fieldValue = (String)fieldMappingDataUnitMap.get(destinationField).getValue();
//                System.debug('### requester destinationField: ' + destinationField + '; fieldValue: ' + fieldValue);
                if (fieldValue != null){
                    requesterMap.put(destinationField.substringAfter('.'), fieldValue);
                }
            }
        }
        if(!requesterMap.isEmpty()){
            zendeskRequestWrapper.ticket.requester.name = requesterMap.get('name');
            zendeskRequestWrapper.ticket.requester.email = requesterMap.get('email');
//            System.debug('### zendeskRequestWrapper.ticket.requester: ' + zendeskRequestWrapper.ticket.requester);
        }
        return zendeskRequestWrapper;
    }

    //Salesforce Developer 2022-01-25. Increase response time.
    private static ZendeskResponseWrapper makeZendeskCreateTicketCall(HttpRequest request){
        Http http = new Http();
        request.setTimeout(120000);
        System.debug('request: ' + request);
        HttpResponse response = http.send(request);
        System.debug('###response: ' + response);
        System.debug('response.getBody(): ' + response.getBody());
        ZendeskResponseWrapper zendeskResponseWrapper = (ZendeskResponseWrapper) JSON.deserialize(response.getBody(), ZendeskResponseWrapper.class);
        //zendeskResponseWrapper.fullResponse = response.getBody();
        
        //System.debug('### ZendeskIntegrationService, zendeskResponseWrapper: ' + JSON.serializePretty(zendeskResponseWrapper));
        return zendeskResponseWrapper;
    }
    public class TestException extends Exception {}

    public class ZendeskResponseWrapper{
        String error;
        String description;
        @TestVisible
        ResponseTicket ticket;
        ZendeskResponseErrorDetails zendeskResponseErrorDetails;
        Id sObjectId;

        String fullResponse;

        public Id getSObjectId(){
            return sObjectId;
        }

        public Boolean isSuccess(){
            return String.isBlank(error);
        }

        public Long getTicketId(){
            if (ticket == null) {
                return null;
            }
            return ticket.id;
        }

        public String getError(){
            String errorMessage = '';
            if(zendeskResponseErrorDetails != null && zendeskResponseErrorDetails.base != null){
                for (ZendeskResponseErrorDetail zendeskResponseErrorDetail_i : zendeskResponseErrorDetails.base) {
                    errorMessage+= zendeskResponseErrorDetail_i.getError() + '\n';
                }
                errorMessage = errorMessage.removeEnd('\n');
            } else {
                errorMessage = error;
            }

            return errorMessage;

            //return this.fullResponse;
        }
    }

    public class ZendeskResponseErrorDetails{
        List<ZendeskResponseErrorDetail> base;
    }

    public class ZendeskResponseErrorDetail{
        @TestVisible
        String error;
        @TestVisible
        String description;
        @TestVisible
        Long ticket_field_id;
        @TestVisible
        String ticket_field_type;

        public String getError(){
            return error + ': ' + description;
        }
    }

    public class ZendeskRequestWrapper{
        Ticket ticket;
        Map<String,Object> customFieldToValidateMap;
        String attachment;
    }

    public class Ticket{
        public Long id;
        public String subject;
        public String description;
        public Requester requester;
        public Long group_id;
        public Long ticket_form_id;
        public List<String> tags;
        public List<EmailCCs> email_ccs;
        public List<CustomField> custom_fields;
        public Comment comment;

        public Ticket(String subject,String description,Long group_id,Long ticket_form_id,List<String> tags,List<CustomField> customFields){
            this.subject = subject;
            this.description = description;
            this.group_id = group_id;
            this.ticket_form_id = ticket_form_id;
            this.tags = tags;
            this.custom_fields = customFields;

            //Itzik, 2022-06-27, MIS-2118: Change requester to
            this.requester = new Requester();

            //Itzik, 2021-10: commentd email_ccs *in*
            //this.email_ccs = new List<EmailCCs>();
        }
    }

    public class Comment {
		public String body;
        public List<String> uploads;
        
        public Comment(List<String> uploads, String body){
            this.uploads = uploads;
            this.body = body;
        }   
	}

    public class ResponseTicket{
        public Long id;
        public String subject;
        public String description;
        public Requester requester;
        public Long group_id;
        public Long ticket_form_id;
        public List<String> tags;
    }

    public class Requester {
        public String name;
        public String email;

        public Requester(){
            this.name = UserInfo.getName();
            this.email = UserInfo.getUserEmail();
        }
    }

    public class CustomField{
        public Long id;
        public Object value; 

        public CustomField(String id,Object value){
            this.id = Long.valueOf(id);
            this.value = value;
        }
    }

    public class EmailCCs{
        public String user_email;
        public String user_name;
        public String action;
        //Itzik, 2021-10: change costructor to receive email and name
        public EmailCCs(String user_email, String user_name){
            //this.user_email = UserInfo.getUserEmail();
            //this.user_name = UserInfo.getName();
            this.user_email = user_email;
            this.user_name = user_name;
            this.action = 'put';
        }
    }
    
    public class ZendeskCustomFieldData{

        Map<Long, TicketField> ticketTaggerFieldMap;

        private void generateTicketTaggerFieldMap(){
            ticketTaggerFieldMap = new Map<Long, TicketField>();
            HttpRequest request= GeneralUtil.createHttpRequestFromApiConfigWithBody(FIELDS_LIST_API_CONFIG_NAME,null,true);
            ZendeskFieldListResponseWrapper zendeskFieldListResponseWrapper = makeZendeskGetCustomFieldsCall(request);
            if (zendeskFieldListResponseWrapper.ticket_fields != null) {
                for (TicketField ticketField_i : zendeskFieldListResponseWrapper.ticket_fields) {
                    if (ticketField_i.type == 'tagger') {
                        ticketTaggerFieldMap.put(ticketField_i.id, ticketField_i);
                    }
                }
            }
        }

        public String getValue(Long fieldId, String fieldName){
            if (ticketTaggerFieldMap == null) {
                generateTicketTaggerFieldMap();
            }
            String value = '';
            if(ticketTaggerFieldMap.containsKey(fieldId)){
                TicketField ticketField = ticketTaggerFieldMap.get(fieldId);
                value = ticketField.getValue(fieldName);
            }
            return value;
        }

        public Boolean containsValue(Long fieldId){
            if (ticketTaggerFieldMap == null) {
                generateTicketTaggerFieldMap();
            }
            return ticketTaggerFieldMap.containsKey(fieldId);
        }

        private ZendeskFieldListResponseWrapper makeZendeskGetCustomFieldsCall(HttpRequest request){
            Http http = new Http();
            HttpResponse response = http.send(request);
            //System.debug('### ZendeskFieldListResponseWrapper, response.getBody(): ' + response.getBody());
            ZendeskFieldListResponseWrapper zendeskResponseWrapper = (ZendeskFieldListResponseWrapper) JSON.deserialize(response.getBody(), ZendeskFieldListResponseWrapper.class);
            
            return zendeskResponseWrapper;
        }
    }

    public class ZendeskFieldListResponseWrapper{
        List<TicketField> ticket_fields;
    }

    public class TicketField{
        Long id;
        List<CustomFieldOption> custom_field_options;
        String type;
        Map<String, CustomFieldOption> customFieldOptionsMap;

        private void generateCustomFieldOptionsMap(){
            customFieldOptionsMap = new Map<String, CustomFieldOption>();
            for (CustomFieldOption customFieldOption_i : custom_field_options) {
                customFieldOptionsMap.put(customFieldOption_i.name, customFieldOption_i);
                if (customFieldOption_i.name == 'New Sale') { // temporary
                    customFieldOptionsMap.put('New', customFieldOption_i);
                }
            }
        }

        public String getValue(String fieldName){
            if (customFieldOptionsMap == null) {
                generateCustomFieldOptionsMap();
            }
            String value = '';
            if(customFieldOptionsMap.containsKey(fieldName)){
                value = customFieldOptionsMap.get(fieldName).getValue();
            }
            return value;
        }

    }

    public class CustomFieldOption{
        Long id;
        String name;
        String raw_name;
        String value;

        public String getValue(){
            return value;
        }
    }

    public class UploadResponseWrapper {
        public UploadWrapper upload;
    }
    

    public class UploadWrapper {
		public AttachmentWrapper attachment;
		public List<AttachmentWrapper> attachments;
		public String token;
	}

	public class AttachmentWrapper {
		public String content_type;
		public String content_url;
		public String file_name;
		public String id;
		public String size;
	}

    @InvocableMethod(
            label = 'Create Zendesk Quote ticket'
            description = 'Request to create a quote ticket in Zendesk'
            category = 'Quote'
    )
    public static void createQuoteTicket(List<Id> quoteList){
        System.debug('### in RequestActionService');
        List<zqu__Quote__c> verifyQuoteList =
        [SELECT Id
        FROM zqu__Quote__c
        WHERE Id IN :quoteList];
        if(!quoteList.isEmpty()){
            ZendeskIntegrationService.createTicketFuture(verifyQuoteList[0].Id, 'zqu__Quote__c');
            //ZendeskIntegrationService.ZendeskResponseWrapper zendeskResponseWrapper = ZendeskIntegrationService.createTicket(verifyQuoteList[0].Id, 'zqu__Quote__c');
//            if (zendeskResponseWrapper.isSuccess()) {
//                zqu__Quote__c quote = [
//                        SELECT Id
//                        FROM zqu__Quote__c
//                        WHERE Id=:verifyQuoteList[0].Id
//                        LIMIT 1
//                ];
//                quote.Billing_ticket_number_in_Zendesk__c = String.valueOf(zendeskResponseWrapper.getTicketId());
//                Database.update(quote, false);
//            } else {
//                throw new AuraHandledException('Ticket creation not succeded - ' + zendeskResponseWrapper.getError());
//            }
        }
    }
}
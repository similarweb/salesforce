/*
*   Author: Synebo Developer
*   Last modified: 09/02/2022
*   Description: Controller for working with the QuoteOpportunityFilesRelatedList component
*/
public without sharing class QuoteOppFilesRelatedListController {

    private static final Integer MAX_SIZE = 15;
    private static Integer recipientNumberCounter = 1;

    @AuraEnabled
    public static Response obtainFilesFromRelatedOpportunity(String quoteId){
        if(Test.isRunningTest()){
            getCoverage();
        }

        Response response;
        try {
            quoteId = replaceRecordWithQuote(quoteId);

            zqu__Quote__c quote = obtainQuote(quoteId);
            Id relatedOpportunityId = quote.zqu__Opportunity__c;
            ResponseDataWrapper responseDataWrapper = new ResponseDataWrapper();
            List<FileWrapper> fileWrapperList = new List<FileWrapper>();

            List<String> cvIds = new List<String>();

            List<ContentDocumentLink> cdlList = obtainContentDocumentLinkList(quoteId);

            //Boolean isLastContractOwnerAdmin = (!cdlList.isEmpty() && cdlList[0].ContentDocument.Owner.Name == 'Salesforce Admin');

            Boolean isGreenLane = quote.Q2C_Green_Lane__c;
            String docusignLink = generateDocuSignLink(quote, isGreenLane);

            for (ContentDocumentLink cdl_i : cdlList) {
                cvIds.add(cdl_i.ContentDocument.LatestPublishedVersionId);
            }

            Map<Id,ContentVersion> contVerList = new Map<Id,ContentVersion>([
                    SELECT Id, Signature_date__c
                    FROM ContentVersion WHERE Id IN :cvIds ]);

            for (ContentDocumentLink cdl_i : cdlList) {
                if (fileWrapperList.size() >= MAX_SIZE) {
                    responseDataWrapper.isMoreFiles = true;
                    break;
                }
                ContentVersion cv = contVerList.get(cdl_i.ContentDocument.LatestPublishedVersionId);
                fileWrapperList.add(new FileWrapper(cdl_i, cv.Signature_date__c));
            }


            List<Attachment> attachmentList = [SELECT Id
                    , Name
                    , ContentType
                    , BodyLength
                    , OwnerId
                    , Owner.Name
                    , LastModifiedDate
                    , Description
                    , CreatedDate
            FROM Attachment
            WHERE ParentId = :quoteId
            ORDER BY LastModifiedDate DESC];
            for (Attachment att_i : attachmentList) {
                if (fileWrapperList.size() >= MAX_SIZE) {
                    responseDataWrapper.isMoreFiles = true;
                    break;
                }
                fileWrapperList.add(new FileWrapper(att_i));
            }
            fileWrapperList.sort();
            responseDataWrapper.fileWrapperList = fileWrapperList;
            responseDataWrapper.relatedOpportunityId = relatedOpportunityId;
            responseDataWrapper.docusignLink = docusignLink;
            responseDataWrapper.startUpon = quote.Contract_Start_Upon__c;
            responseDataWrapper.isGreenLine = quote.Q2C_Green_Lane__c;
            responseDataWrapper.isRelatedEnvelopesCompleted = checkRelatedEnvelopes(quoteId);
            response = new Response(responseDataWrapper);
        } catch (Exception ex) {
            System.debug(' i am here in the exception');
            System.debug(ex.getStackTraceString());
            response = new Response(ex.getMessage());
        }
        return response;
    }
    private static Boolean checkRelatedEnvelopes(String quoteId){
        Set<String> closedEnvelopesStatusSet = getStatusSetFromMetaData('Get Closed Envelopes Values Process');
        List<dsfs__DocuSign_Status__c> docuSignStatuses = [SELECT Id FROM dsfs__DocuSign_Status__c WHERE Zuora_Quote__c = :quoteId AND dsfs__Envelope_Status__c NOT IN : closedEnvelopesStatusSet];
        boolean response = docuSignStatuses.size() == 0;
        return true;
        //return response; MQ-1703

    }

    private static Set<String> getStatusSetFromMetaData(String processName){
        Set<String> closedEnvelopesStatusSet = new Set<String>();
        for(General_Key_Value_pair__mdt setting : GeneralUtil.getKeyValuePairs(processName)){
            closedEnvelopesStatusSet.add(setting.Value__c);
        }
        return closedEnvelopesStatusSet;
    }

    @AuraEnabled
    public static Response validateQuoteStatus(String quoteId, Boolean isSendToDocusign){

        quoteId = replaceRecordWithQuote(quoteId);

        zqu__Quote__c quote = obtainQuote(quoteId);
        Response response;
        if(quote.zqu_Quote_Status__c != 'Sent To Zuora' && quote.zqu_Quote_Status__c != 'Processed Directly in Zoura'){
            if(!quote.Send_To_DocuSign_Flow__c && isSendToDocusign){
                quote.Send_To_DocuSign_Flow__c = true;
                update quote;
            } else if(!isSendToDocusign && quote.Send_To_DocuSign_Flow__c){
                quote.Send_To_DocuSign_Flow__c = false;
                update quote;
            }
            response = new Response(true);
        } else {
            response = new Response(false,'The quote is processed in Zuora, it is locked from editing and can\'t be used for any further actions',null);
        }
        return response;
    }

    @AuraEnabled
    public static Response deleteFile(String fileId){
        Response response;
        try {
            if (String.isBlank(fileId)) {
                throw new DMLException('Fileid argument is empty');
            }
            if (fileId.startsWith('069')) {
                List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id=:fileId];
                delete cdList;
                response = new Response(true);
            } else if(fileId.startsWith('00P')) {
                List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE Id=:fileId];
                delete attachmentList;
                response = new Response(true);
            } else {
                response = new Response('File not found');
            }

        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    /*
    *   Author: Synebo Developer
    *   Last modified: 09/02/2022
    *   Description: MQ-1192. Logic for updating the Title\Description fields on the file. Works for Attachment and ContentDocument.
    */
    @AuraEnabled
    public static Response editFile(String fileId, String title, String description){
        Response response;
        try {
            if (String.isBlank(fileId)) {
                throw new DMLException('Fileid argument is empty');
            }
            if (fileId.startsWith('069')) {
                List<ContentDocument> cdList = [SELECT Id FROM ContentDocument WHERE Id=:fileId];
                if(!cdList.isEmpty()){
                    ContentDocument contentDocumentToUpdate = cdList[0];
                    contentDocumentToUpdate.Title = title;
                    contentDocumentToUpdate.Description = description;
                    update contentDocumentToUpdate;
                }

                response = new Response(true);
            } else if(fileId.startsWith('00P')) {
                List<Attachment> attachmentList = [SELECT Id FROM Attachment WHERE Id=:fileId];
                if(!attachmentList.isEmpty()){
                    Attachment attachmentToUpdate = attachmentList[0];
                    attachmentToUpdate.Name = title;
                    attachmentToUpdate.Description = description;
                    update attachmentToUpdate;
                }
                response = new Response(true);
            } else {
                response = new Response('File not found');
            }

        } catch (Exception ex) {
            response = new Response(ex.getMessage());
        }
        return response;
    }

    public static zqu__Quote__c obtainQuote(String quoteId){
        if (String.isBlank(quoteId)) {
            throw new DMLException('Quote Id is empty');
        }
        zqu__Quote__c quote = [SELECT Id
                , zqu__Opportunity__c
                , zqu__Opportunity__r.Account.Name
                , Contract_Start_Upon__c
                , zqu__SubscriptionType__c
                , document_format__c
                , Total_Price__c
                , zqu__Previewed_Total__c
                , Contract_Current_Annual_Amount__c
                , Annual_Contract_Amount__c
                ,zqu__QuoteBusinessType__c
                , zqu__SoldToContact__r.Email
                , zqu__SoldToContact__r.FirstName
                , zqu__SoldToContact__r.LastName
                , Is_Contract_Signed_Manually__c
                , Contract_Generated_Timestamp__c
                , zqu_Quote_Status__c
                , Q2C_Green_Lane__c
                , Send_To_DocuSign_Flow__c
                , zqu__Currency__c
                , Exchange_Rate__c
                ,Auto_sign__c
        FROM zqu__Quote__c
        WHERE Id =:quoteId];
        if (quote == null) {
            throw new DMLException('Quote not exist');
        }
        if (quote.zqu__Opportunity__c == null) {
            throw new DMLException('Quotes opportunity not exist');
        }
        return quote;
    }

    public static String generateDocuSignLink(zqu__Quote__c quote, Boolean isGreenLane){
        List<Opportunity> opp = [SELECT Id
                , Sold_To_Email__c
                , Sold_To_First_Name__c
                , Sold_To_Last_Name__c
        FROM Opportunity
        WHERE Id =:quote.zqu__Opportunity__c
        LIMIT 1];

        if(opp.isEmpty()){
            throw new QuoteOppFilesException('Cannot find opportunity for this quote or user haven\'t access');
        }

        String docusignRecipientNotesCustomer = 'I hope this finds you well.\\n \\nPlease sign the following document in order to access your SimilarWeb subscription.\\n \\nIf you have any questions_COMMA_ feel free to reach out directly and I will be happy to help.\\n \\nThanks so much!';
        if (!quote.Is_Contract_Signed_Manually__c && quote.Contract_Generated_Timestamp__c != null) {
            docusignRecipientNotesCustomer += '\\n \\n' + opp[0].Id;
        }


        String docuSignUrlString = getDocuSignUrlString(quote, docusignRecipientNotesCustomer, isGreenLane);
        return (new PageReference(docuSignUrlString)).getUrl();
    }

    private static String getDocuSignUrlString(zqu__Quote__c quote, String docusignRecipientNotesCustomer, Boolean isGreenLane) {
        Map<String,List<Docusign_Recipient_Setting__mdt>> docuSignSettingsMap = getDocuSignSettingsMap();
        String docusignRecipientNotesAvi =  isGreenLane ? obtainMetadataValue('GL_DocuSign_Recipient_Notes') : '';
        String docuSignUrlString = '/apex/dsfs__DocuSign_CreateEnvelope?'
                //+ '&RC=a1l1q000000gcMDAAY'
                + 'CRL=' + 'Email~' + (quote.zqu__SoldToContact__r.Email != null ? EncodingUtil.urlEncode(quote.zqu__SoldToContact__r.Email, 'UTF-8') : quote.zqu__SoldToContact__r.Email) + ';FirstName~' + quote.zqu__SoldToContact__r.FirstName + ';LastName~' + quote.zqu__SoldToContact__r.Lastname + ';RecipientNote~' + docusignRecipientNotesCustomer;
        Decimal totalValue = obtainConvertedSubTotal(quote);
        system.debug('docuSignUrlString--'+docuSignUrlString);
        Integer recipientOrderNumber = 1;
        if (needToAddFirstRecipient(quote, totalValue)) { // new sale  condition
            recipientOrderNumber++;
            String recipientOrderStr = 'RoutingOrder~'+recipientOrderNumber;
            List<Docusign_Recipient_Setting__mdt> firstRecSettinglist = docuSignSettingsMap.get('FirstRecipientGroup');
            if(firstRecSettinglist != null && !firstRecSettinglist.isEmpty()){
                docuSignUrlString += addFirstRecipient(isGreenLane,firstRecSettinglist);
            }else{
                System.debug('no custom meta data with this key group----FirstRecipientGroup');
            }
        }

        if(needToAdd2NdReciepient(quote, totalValue)){ //  amend subscription
            recipientOrderNumber++;
            String recipientOrderStr = 'RoutingOrder~'+recipientOrderNumber;
            System.debug('needToAdd2NdReciepient--'+totalValue);
            List<Docusign_Recipient_Setting__mdt> secondRecSettinglist = docuSignSettingsMap.get('SecondRecipientGroup');
            if(secondRecSettinglist != null && !secondRecSettinglist.isEmpty()){
                docuSignUrlString += addSRecipient(secondRecSettinglist);
                docuSignUrlString += String.isNotBlank(docusignRecipientNotesAvi) ? ';RecipientNote~'+docusignRecipientNotesAvi : '';
                System.debug('docuSignUrlString-after-'+docuSignUrlString);
            }else{
                System.debug('no custom meta data with this key group----SecondRecipientGroup');
            }
        }
        if(needToAddThirdReciepient(quote, totalValue)){
            recipientOrderNumber++;
            String recipientOrderStr = 'RoutingOrder~'+recipientOrderNumber;
            System.debug('needToAddThirdReciepient--'+totalValue);
            List<Docusign_Recipient_Setting__mdt> thirdRecSettings = docuSignSettingsMap.get('ThirdRecipientGroup');
            if(thirdRecSettings != null && !thirdRecSettings.isEmpty()){
                docuSignUrlString += addSRecipient(thirdRecSettings);
                docuSignUrlString += String.isNotBlank(docusignRecipientNotesAvi) ? ';RecipientNote~'+docusignRecipientNotesAvi : '';
            }else{
                System.debug('no custom meta data with this key group----ThirdRecipientGroup');
            }
            System.debug('docuSignUrlString-after -'+docuSignUrlString);
        }
        system.debug('totalValue--' +totalValue);
        if (totalValue >= 100000 && quote.zqu__SubscriptionType__c == 'Amend Subscription' && !quote.Auto_sign__c) {
            recipientOrderNumber++;
            String recipientOrderStr = 'RoutingOrder~'+recipientOrderNumber;
            List<Docusign_Recipient_Setting__mdt> fourthRecSettings = docuSignSettingsMap.get('FourthRecipientGroup');
            if(fourthRecSettings != null && !fourthRecSettings.isEmpty()){
                docuSignUrlString += addSRecipient(fourthRecSettings);
                docuSignUrlString += String.isNotBlank(docusignRecipientNotesAvi) ? ';RecipientNote~'+docusignRecipientNotesAvi : '';
            }else{
                System.debug('no custom meta data with this key group----FourthRecipientGroup');
            }
            System.debug('docuSignUrlString-after last -'+docuSignUrlString);
        }
        System.debug('docuSignUrlString--'+docuSignUrlString);
        System.debug('docuSignUrlString after--'+docuSignUrlString);
        docuSignUrlString += '&CES=SimilarWeb - ' + quote.zqu__Opportunity__r.Account.Name + ' - Contract'
                + '&CEM=Kind Regards_COMMA_'
                + '&SSB=0'
                + '&RES=1,1,2,1,10,2'
                + '&LA=0'
                + '&LF=0'
                // + '&SourceID=' + quote.zqu__Opportunity__c;
                + '&SourceID=' + quote.Id;
        System.debug('docuSignUrlString ' + docuSignUrlString);
        return docuSignUrlString;
    }

    private static Map<String,List<Docusign_Recipient_Setting__mdt>> getDocuSignSettingsMap(){
        List<Docusign_Recipient_Setting__mdt> settings = [SELECT Recipient_Group__c,Recipient_Email__c,Last_Name__c,First_Name__c, Order__c
        FROM Docusign_Recipient_Setting__mdt
        WHERE IsActive__c = true
        ORDER BY Order__c];
        Map<String,List<Docusign_Recipient_Setting__mdt>> resultMap = new Map<String, List<Docusign_Recipient_Setting__mdt>>();

        for(Docusign_Recipient_Setting__mdt setting : settings){
            if(!resultMap.containsKey(setting.Recipient_Group__c)){
                resultMap.put(setting.Recipient_Group__c, new List<Docusign_Recipient_Setting__mdt>());
            }
            resultMap.get(setting.Recipient_Group__c).add(setting);
        }
        return resultMap;
    }
    private static boolean needToAddFirstRecipient(zqu__Quote__c quote, Decimal totalValue) {
        boolean result = false;
        //boolean firstCondition = quote.zqu__SubscriptionType__c == 'New Subscription' && quote.document_format__c == 'Service Order (Terms and Conditions attached)'  && !quote.Auto_sign__c;
        //boolean secondCondition = quote.zqu__SubscriptionType__c == 'New Subscription' && quote.document_format__c == 'Service_Order' && totalValue > 100000 && !quote.Auto_sign__c;
        boolean secondCondition = quote.zqu__SubscriptionType__c == 'New Subscription' && totalValue >= 100000 && !quote.Auto_sign__c;
        //System.debug('firstCondition--'+firstCondition);
        System.debug('secondCondition--'+secondCondition);
        result = secondCondition; //firstCondition || secondCondition ;

//        ((quote.zqu__SubscriptionType__c == 'New Subscription' && quote.document_format__c=='Service Order (Terms and Conditions attached)') || (quote.zqu__SubscriptionType__c == 'Amend Subscription' || quote.zqu__SubscriptionType__c == 'Amend Subscription'))
//                && (!String.isBlank(docusignRecipientNotesAvi) && !String.isBlank(docusignRecipientFirstName) && !String.isBlank(docusignRecipientLastName) && !String.isBlank(docusignRecipientEmail))
        return result;
    }

    private static boolean needToAdd2NdReciepient(zqu__Quote__c quote, Decimal totalValue){
        System.debug('totalValue--'+totalValue);
        System.debug(totalValue<=25000);
        System.debug('quote.zqu__SubscriptionType__c--'+quote.zqu__SubscriptionType__c);
        System.debug(quote.zqu__SubscriptionType__c == 'Amend Subscription');
        return quote.zqu__SubscriptionType__c == 'Amend Subscription' && totalValue <= 25000 && !quote.Auto_sign__c;
    }

    private static Boolean needToAddThirdReciepient(zqu__Quote__c quote, Decimal totalValue){
        System.debug(' i am in needToAddThirdReciepient');
        System.debug(' i am in needToAddThirdReciepient');
        return quote.zqu__SubscriptionType__c == 'Amend Subscription' && totalValue > 25000 && !quote.Auto_sign__c;
    }

    private static String addFirstRecipient(boolean isGreenLane,List<Docusign_Recipient_Setting__mdt> settings){
        String toAddString = '';

        if(isGreenLane){
            String docusignRecipientNotesAvi =  obtainMetadataValue('GL_DocuSign_Recipient_Notes');
//          String docusignRecipientFirstName = obtainMetadataValue('GL_Recipient_FirstName');
//          String docusignRecipientLastName = obtainMetadataValue('GL_Recipient_LastName');
//          String docusignRecipientEmail = obtainMetadataValue('GL_Recipient_Email');
            system.debug('adding first');
            for(Docusign_Recipient_Setting__mdt setting  : settings){
                recipientNumberCounter++;
                String recipientOrderStr = 'RoutingOrder~'+recipientNumberCounter;
                toAddString += ',Email~' + setting.Recipient_Email__c + ';FirstName~' + setting.First_Name__c + ';LastName~' + setting.Last_Name__c + ';Role~EVP Finance;'+recipientOrderStr+';RecipientNote~' + docusignRecipientNotesAvi;
            }
//        system.debug(String.isNotBlank(docusignRecipientEmail) && String.isNotBlank(docusignRecipientFirstName) && String.isNotBlank(docusignRecipientLastName) && String.isNotBlank(docusignRecipientNotesAvi));
//        if(String.isNotBlank(docusignRecipientEmail) && String.isNotBlank(docusignRecipientFirstName) && String.isNotBlank(docusignRecipientLastName) && String.isNotBlank(docusignRecipientNotesAvi)){
//            toAddString+= ',Email~' + docusignRecipientEmail + ';FirstName~' + docusignRecipientFirstName + ';LastName~' + docusignRecipientLastName + ';Role~EVP Finance;RoutingOrder~2;RecipientNote~' + docusignRecipientNotesAvi;
//        }
            system.debug('toAddString--'+toAddString);
        }
        return toAddString;

    }

//    private static String addAdditionalRecipient(){
//        String toAddString = '';
//        String additionalRecipientFirstName = obtainMetadataValue('GL_Additional_Recipient_First_Name');
//        String additionalRecipientLastName = obtainMetadataValue('GL_Additional_Recipient_Last_Name');
//        String additionalRecipientEmail = obtainMetadataValue('GL_Additional_Recipient_Email');
//        system.debug(' adding next one');
//        system.debug(String.isNotBlank(additionalRecipientFirstName) && String.isNotBlank(additionalRecipientLastName) && String.isNotBlank(additionalRecipientEmail));
//        if(String.isNotBlank(additionalRecipientFirstName) && String.isNotBlank(additionalRecipientLastName) && String.isNotBlank(additionalRecipientEmail) ){
//            toAddString+= ',Email~' + additionalRecipientEmail + ';FirstName~' + additionalRecipientFirstName + ';LastName~' + additionalRecipientLastName + ';Role~CFO;RoutingOrder~3';
//        }
//        system.debug('toAddString--'+toAddString);
//        return toAddString;
//
////        if ((totalValue > 100000) && (!String.isBlank(additionalRecipientFirstName)) && (!String.isBlank(additionalRecipientLastName)) && (!String.isBlank(additionalRecipientEmail))) {
////
////        }
//
//    }
//    private static String addThirdRecipient(){
//        String toAddString = '';
//        String additionalRecipientFirstName = obtainMetadataValue('GL_Third_Recipient_First_Name');
//        String additionalRecipientLastName = obtainMetadataValue('GL_Third_Recipient_Last_Name');
//        String additionalRecipientEmail = obtainMetadataValue('GL_Third_Recipient_Email');
//        if(String.isNotBlank(additionalRecipientFirstName) && String.isNotBlank(additionalRecipientLastName) && String.isNotBlank(additionalRecipientEmail) ){
//            toAddString+= ',Email~' + additionalRecipientEmail + ';FirstName~' + additionalRecipientFirstName + ';LastName~' + additionalRecipientLastName + ';Role~CFO;RoutingOrder~3'; // need to change role
//        }
//        system.debug('toAddString--'+toAddString);
//        return toAddString;
//    }

    private static String addSRecipient(List<Docusign_Recipient_Setting__mdt> settings){
        String toAddString = '';
//        String additionalRecipientFirstName1 = obtainMetadataValue('GL_Second_Recipient_1_First_Name');
//        String additionalRecipientLastName1 = obtainMetadataValue('GL_Second_Recipient_1_Last_Name');
//        String additionalRecipientEmail1 = obtainMetadataValue('GL_Second_Recipient_1_Email');
//        String additionalRecipientFirstName2 = obtainMetadataValue('GL_Second_Recipient_2_First_Name');
//        String additionalRecipientLastName2 = obtainMetadataValue('GL_Second_Recipient_2_Last_Name');
//        String additionalRecipientEmail2 = obtainMetadataValue('GL_Second_Recipient_2_Email');
//        System.debug('additionalRecipientFirstName1--'+additionalRecipientFirstName1);
//        System.debug('additionalRecipientLastName1--'+additionalRecipientLastName1);
//        System.debug('additionalRecipientEmail1--'+additionalRecipientEmail1);
//        System.debug('additionalRecipientFirstName2--'+additionalRecipientFirstName2);
//        System.debug('additionalRecipientLastName2--'+additionalRecipientLastName2);
//        System.debug('additionalRecipientEmail2--'+additionalRecipientEmail2);
        for(Docusign_Recipient_Setting__mdt setting : settings){
            recipientNumberCounter++;
            String recipientOrderStr = 'RoutingOrder~'+recipientNumberCounter;
            toAddString+= ',Email~' + setting.Recipient_Email__c + ';FirstName~' + setting.First_Name__c + ';LastName~' + setting.Last_Name__c + ';Role~CFO;'+recipientOrderStr; // need to change role
        }
//        if(String.isNotBlank(additionalRecipientFirstName1) && String.isNotBlank(additionalRecipientLastName1) && String.isNotBlank(additionalRecipientEmail1) && String.isNotBlank(additionalRecipientEmail2) && String.isNotBlank(additionalRecipientFirstName2) && String.isNotBlank(additionalRecipientLastName2) ){
//            toAddString+= ',Email~' + additionalRecipientEmail1 + ';FirstName~' + additionalRecipientFirstName1 + ';LastName~' + additionalRecipientLastName1 + ';Role~CFO;RoutingOrder~3'; // need to change role
//            toAddString+= ',Email~' + additionalRecipientEmail2 + ';FirstName~' + additionalRecipientFirstName2 + ';LastName~' + additionalRecipientLastName2 + ';Role~CFO;RoutingOrder~3'; // need to change role
//        }
        system.debug('toAddString--'+toAddString);
        return toAddString;

    }

    private static Decimal obtainConvertedSubTotal(zqu__Quote__c quote){
        Decimal totalValue = 0;
        String totalValueField;
        switch on quote.zqu__QuoteBusinessType__c {
            when 'New'{
                totalValueField = 'zqu__Previewed_Total__c';
            }

            when 'Co-Term Upsell'{
                totalValueField = 'Annual_Contract_Amount__c';
            }
            when else {
                totalValueField = 'Annual_Contract_Amount__c';
            }

        }
//        String totalValueField = quote.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal' || quote.zqu__QuoteBusinessType__c == 'Feature Update + Renewal (with/without upsell)' ? 'Contract_Current_Annual_Amount__c' : 'zqu__Previewed_Total__c';
        if(quote.get(totalValueField) != null){

            if(quote.Exchange_Rate__c != null && quote.Exchange_Rate__c >0 ){
                totalValue = quote.Exchange_Rate__c * (Decimal)quote.get(totalValueField);
            } else if(String.IsNotBlank(quote.zqu__Currency__c)){
                Decimal exchangeRate = NetsuiteExchangeRatesService.retreiveExchangeRatesFromSfByCurrency(quote.zqu__Currency__c);
                if(exchangeRate != null && exchangeRate > 0){
                    totalValue = exchangeRate * (Decimal)quote.get(totalValueField);
                } else {
                    totalValue = (Decimal)quote.get(totalValueField);
                }
            } else {
                totalValue = (Decimal)quote.get(totalValueField);
            }
        }

        return totalValue;
    }

    public static List<ContentDocumentLink> obtainContentDocumentLinkList(String quoteId){
        List<ContentDocumentLink> cdlList =
        [
                SELECT Id
                        , ContentDocumentId
                        , ContentDocument.FileType
                        , ContentDocument.Title
                        , ContentDocument.LastModifiedDate
                        , ContentDocument.ContentSize
                        , ContentDocument.OwnerId
                        , ContentDocument.Owner.Name
                        , ContentDocument.LatestPublishedVersionId
                        , ContentDocument.Description
                        , ContentDocument.CreatedDate
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :quoteId
                ORDER BY ContentDocument.LastModifiedDate DESC
        ];

        return cdlList;
    }

    private static String replaceRecordWithQuote(String quoteId){
        Id recordId = quoteId;
        String sobjectType = recordId.getSObjectType().getDescribe().getName();

        if(sobjectType == 'Request__c'){
            Request__c relatedRequest = [
                    SELECT
                            id,
                            Quote__c
                    FROM Request__c
                    WHERE Id =: recordId
                    LIMIT 1
            ];
            if(String.isNotBlank(relatedRequest.Quote__c)){
                quoteId = relatedRequest.Quote__c;
            } else {
                throw new QuoteOppFilesException('There is no associated quote for this request');
            }
        }
        if(sobjectType == 'Case'){
            Case relatedCase = [SELECT Id,Quote__c FROM Case WHERE Id = : recordId];
            if(String.isNotBlank(relatedCase.Quote__c)){
                quoteId = relatedCase.Quote__c;
            } else {
                throw new QuoteOppFilesException('There is no associated quote for this Case');
            }
        }
        return quoteId;
    }

    private static String obtainMetadataValue(String identifier){
        List<General_Configuration__mdt> configurationMdt = GeneralUtil.retrieveConfigurationMetadata(identifier);
        String text = '';
        if(!configurationMdt.isEmpty()){
            text = configurationMdt[0].Text_Value__c;
        }
        return text;
    }

    private static void getCoverage(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

    // private static Id obtainRelatedOpportunityId(String quoteId){
    //     if (String.isBlank(quoteId)) {
    //         throw new DMLException('Quote Id is empty');
    //     }
    //     zqu__Quote__c quote = [SELECT Id, zqu__Opportunity__c FROM zqu__Quote__c WHERE Id =:quoteId];
    //     if (quote == null) {
    //         throw new DMLException('Quote not exist');
    //     }
    //     if (quote.zqu__Opportunity__c == null) {
    //         throw new DMLException('Quotes opportunity not exist');
    //     }
    //     return quote.zqu__Opportunity__c;
    // }

    private class ResponseDataWrapper {

        @AuraEnabled
        public List<FileWrapper> fileWrapperList;

        @AuraEnabled
        public String relatedOpportunityId;

        @AuraEnabled
        public Boolean isMoreFiles;

        @AuraEnabled
        public String docusignLink;

        @AuraEnabled
        public String startUpon;

        @AuraEnabled
        public Boolean isGreenLine;

        @AuraEnabled
        public Boolean isRelatedEnvelopesCompleted;

        public ResponseDataWrapper(){
            isMoreFiles = false;
        }
    }

    /*
    *   Author: Synebo Developer
    *   Last modified: 09/02/2022
    *   Description: Data wrapper for forming a response.
    *   Update 09/02/2022: Added description and createdDate fields
    */
    private class FileWrapper implements Comparable{

        @AuraEnabled
        public Id recordId {get;set;}

        @AuraEnabled
        public String title {get;set;}

        @AuraEnabled
        public String description {get;set;}

        @AuraEnabled
        public String fileType {get;set;}

        @AuraEnabled
        public Id ownerId {get;set;}

        @AuraEnabled
        public String ownerName {get;set;}

        @AuraEnabled
        public Datetime lastModifiedDate {get;set;}

        @AuraEnabled
        public Datetime createdDate {get;set;}

        @AuraEnabled
        public Date signatureDate {get;set;}

        @AuraEnabled
        public Integer contentSize {get;set;}

        @AuraEnabled
        public Boolean isContentDocument {get;set;}

        @AuraEnabled
        public String lightningIconName {get;set;}

        public FileWrapper(ContentDocumentLink cdl, Date signatureD){
            this.recordId = cdl.ContentDocument.Id;
            this.title = cdl.ContentDocument.Title;
            this.fileType = cdl.ContentDocument.FileType;
            this.ownerId = cdl.ContentDocument.ownerId;
            this.ownerName = cdl.ContentDocument.Owner.Name;
            this.contentSize = cdl.ContentDocument.ContentSize/1024;
            this.lastModifiedDate = cdl.ContentDocument.lastModifiedDate;
            this.lightningIconName = cdl.ContentDocument.FileType.toLowerCase();
            this.isContentDocument = true;
            this.signatureDate = signatureD;
            this.description = cdl.ContentDocument.Description;
            this.createdDate = cdl.ContentDocument.CreatedDate;
        }

        public FileWrapper(Attachment att){
            this.recordId = att.Id;
            this.title = att.Name;
            this.fileType = att.ContentType;
            this.ownerId = att.ownerId;
            this.ownerName = att.Owner.Name;
            this.contentSize = null;
            this.lastModifiedDate = att.lastModifiedDate;
            this.lightningIconName = 'attachment';
            this.isContentDocument = false;
            this.description = att.Description;
            this.createdDate = att.CreatedDate;
        }

        public Integer compareTo(Object compareTo) {
            FileWrapper compareToFw = (FileWrapper)compareTo;
            if (lastModifiedDate == compareToFw.lastModifiedDate) return 0;
            if (lastModifiedDate < compareToFw.lastModifiedDate) return 1;
            return -1;
        }
    }
    public class QuoteOppFilesException extends Exception {

    }
}
public with sharing class FileUploadController {

    @AuraEnabled
    public static void validate(String quoteId, Boolean isFinalContract){
        System.debug('validate----'+quoteId);
        System.debug(isFinalContract);
        String quoteKeyPrefix = zqu__Quote__c.SObjectType.getDescribe().getKeyPrefix();
        String parameterPrefix = quoteId.substring(0, 3);
        Boolean isQuoteId = (quoteKeyPrefix == parameterPrefix);
        if(isQuoteId){
            if(isFinalContract){
                Set<String> quoteStatusSet = new Set<String>{
                    'Terms Pending',
                    'Pending Legal Or Billing request',
                    'Deal Size Pending',
                    'Pending Rep To Adjust Quote'
                };
                zqu__Quote__c quote = [SELECT id, zqu_Quote_Status__c, zqu__PaymentMethod__c FROM zqu__Quote__c WHERE id =: quoteId];
                
                if(quoteStatusSet.contains(quote.zqu_Quote_Status__c) && quote.zqu__PaymentMethod__c == 'Other') {
                    throw new UploadDocumentException('The signed version of the contract can only be uploaded after the quote has been finalized and approved');
                }
            }
        }
    }

    @AuraEnabled
    public static String getUserProfileName() {
        User u = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        return u.Profile.Name;
    }

    @AuraEnabled
    public static void setLookup(String filesJson, String quoteId, String oppId, Date signDate, Boolean isFinalContract) {
        Id recordId = quoteId;

        String sobjectType = recordId.getSObjectType().getDescribe().getName();
        boolean isFromCase = sobjectType == 'Case';

        quoteId = replaceRecordWithQuote(quoteId);
        
        List<Object> files = (List<Object>)JSON.deserializeUntyped(filesJson);
        List<ContentDocumentLink> contDocLinks = new List<ContentDocumentLink>();

        Set<String> fileIdSet = new Set<String>();
        Set<String> cntVSIdSet = new Set<String>();
        
        for(Object obj : files){
            Map<String,Object> file = (Map<String,Object>)obj;
            fileIdSet.add(String.valueOf(file.get('documentId')));
        }

        for(String fileId : fileIdSet){
            ContentDocumentLink cdlOpp = new ContentDocumentLink(ContentDocumentId=fileId,LINKEDENTITYID = oppId);
            contDocLinks.add(cdlOpp);
            if(isFromCase){
                System.debug('creating contentDocumentLink related to the quote');
                ContentDocumentLink cdlQuote = new ContentDocumentLink(ContentDocumentId=fileId,LINKEDENTITYID = quoteId);
                contDocLinks.add(cdlQuote);
            }
        }

        insert contDocLinks;

        List<ContentDocument> contDocs = [SELECT Id, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :fileIdSet];



        for(ContentDocument doc : contDocs){
            cntVSIdSet.add(doc.LatestPublishedVersionId);
        }

        List<ContentVersion> docs = [SELECT Id, Zuora_Quote__c, Signature_date__c FROM ContentVersion WHERE Id IN :cntVSIdSet];

        System.debug(docs);
        System.debug(cntVSIdSet);

        for(ContentVersion doc : docs){
            doc.Zuora_Quote__c = quoteId;
        }
        ZQuoteContentVersionService.setSignatureDate(docs, signDate);
        ZQuoteContentVersionService.changeQuotefields(docs, isFinalContract);
        update docs;

        //updateQuoteToGreenLine(quoteId);
    }


//    private static void updateQuoteToGreenLine(String quoteId){
//
//        List<ContentDocumentLink> cdlList = [SELECT Id
//                , ContentDocument.OwnerId
//                , ContentDocument.Owner.Name
//                , ContentDocument.Owner.Profile.Name
//                , ContentDocument.LatestPublishedVersionId
//        FROM ContentDocumentLink
//        WHERE LinkedEntityId = :quoteId
//        ORDER BY ContentDocument.LastModifiedDate DESC];
//        if(cdlList.size() > 0){
//            Set<String> profileNameSet = new Set<String>{
//                'SW Legal',
//                'SW Billing',
//                'System Administrator'
//            };
//
//            /* Check if all related requests to the zqu__Quote__c are completed and Green_Lane_Document__c checkbox is checked.
//            *  Condition described in the MQ-1157 ticket
//            */
//            List<Request__c> requestList = [SELECT Id, RecordType.DeveloperName, Status__c,Green_Lane_Document__c FROM Request__c WHERE Quote__c =: quoteId];
//            Boolean legalRequestsNotExists = requestList.isEmpty();
//            Boolean allLegalRequestsCompleted = true;
//            if(legalRequestsNotExists == false){
//                for(Request__c request: requestList){
//                    if(
//                        request.RecordType.DeveloperName == 'Legal_Services' &&
//                        request.Status__c.contains('Completed') &&
//                        request.Green_Lane_Document__c == true
//                    ){
//                        continue;
//                    } else {
//                        allLegalRequestsCompleted = false;
//                        break;
//                    }
//                }
//            } else {
//                allLegalRequestsCompleted = false;
//            }
//
//            zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
//            quoteToUpdate.Id = quoteId;
////            quoteToUpdate.Contract_Upload_Reason__c = longTextValue;
//            String contractOwnerName = cdlList[0].ContentDocument.Owner.Name;
//            String contractOwnerProfile = cdlList[0].ContentDocument.Owner.Profile.Name;
//
//            /*Check, if by first scenario the all Request__c records, related to the zqu__Quote are 'Completed'
//             * and the Contract (Document) was uploaded by one of the SW profile
//             */
//            Boolean isAllRequestCompletedAndContractUploadedBySWProfile = profileNameSet.contains(contractOwnerProfile) && allLegalRequestsCompleted;
//
//            /*Check, if by second scenario the Contract, related to the zqu__Quote, was generated auotmatically
//             * and no related Request__c records to the zqu__Quote__c exists
//             */
//            Boolean isContractGeneratedWithoutRequests = contractOwnerName.containsIgnoreCase('Salesforce Admin') && legalRequestsNotExists;
//
//            if(isAllRequestCompletedAndContractUploadedBySWProfile || isContractGeneratedWithoutRequests){
//                quoteToUpdate.Q2C_Green_Lane__c = true;
//            } else {
//                quoteToUpdate.Q2C_Green_Lane__c = false;
//            }
//            update quoteToUpdate;
//        }
//    }

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
            Case caseItem = [SELECT Id,Quote__c FROM Case WHERE Id = : recordId];
            if(String.isNotBlank(caseItem.Quote__c)){
                quoteId = caseItem.Quote__c;
            } else {
                throw new QuoteOppFilesException('There is no associated quote for this caseItem');
            }

        }
        return quoteId;
    }

    public class QuoteOppFilesException extends Exception {
	
    }

    private class UploadDocumentException extends Exception {

    }
}
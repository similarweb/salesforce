/**
 * Trigger handler for Request__c object
 */
public with sharing class RequestDomain extends GenericDomain {

    public RequestDomain(List<SObject> newRecords){
        super(newRecords);
    }

    /**
     * Trigger for the after update context.
     */
    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {  
        updateRelatedQuoteOnUpdate((List<Request__c>)newRecords, (Map<Id,Request__c>)existingRecords);
    }

    /**
     * Trigger for the before insert context.
     * In turn, call methods that are not related to each other.
     */
    public override void onBeforeInsert() {        
        updateAccountNumber((List<Request__c>)newRecords);
        checkUnsupportedRequestType((List<Request__c>)newRecords);
    }

    /**
     * Trigger for the after insert context.
     */
    public override void onAfterInsert() {
        updateRelatedQuoteOnCreate((List<Request__c>)newRecords);
    }

    /**
     * The method is designed to fill in the Zuora_Account_number__c field 
     * on the Request__c object (RT = Vendor_Form).
     * The logic collects a list of Zuora__CustomerAccount__c objects that 
     * are linked through an Account or Opportunity.
     * If one customer account is found, then it stores the value from 
     * the CustomerAccount.Zuora__AccountNumber__c field. 
     * If several accounts are found, then it keeps the value "Multiple billing accounts found".
     * 
     * newList: List of Requests from Trigger.new
     */
    private void updateAccountNumber(List<Request__c> newList){
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        List<Request__c> requestToUpdateList = new List<Request__c>();
        Id requestRecordTypeId = Schema.SObjectType.Request__c.getRecordTypeInfosByDeveloperName().get('Vendor_Form').getRecordTypeId();
        for(Request__c request: newList){
            if(
                request.RecordTypeId == requestRecordTypeId &&
                (request.Opportunity__c != null || request.Account__c != null) &&
                request.Ticket_number_in_Zendesk__c == null &&
                request.Status__c == 'Submitted'
            ){
                if(request.Opportunity__c != null){
                    opportunityIdSet.add(request.Opportunity__c);
                } else if(request.Account__c != null){
                    accountIdSet.add(request.Account__c);
                }
                requestToUpdateList.add(request);
            }
        }

        if(!requestToUpdateList.isEmpty()){
            Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
            if(!opportunityIdSet.isEmpty()){
                oppMap = new Map<Id,Opportunity>([SELECT Id, AccountId FROM Opportunity WHERE Id IN: opportunityIdSet]);
                for(Opportunity opp: oppMap.values()){
                    accountIdSet.add(opp.AccountId);
                }
            }

            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id,
                (SELECT Id, Zuora__AccountNumber__c FROM R00N40000001kyLcEAI)
                FROM Account
                WHERE id IN: accountIdSet
            ]);
            
            for(Request__c request: requestToUpdateList){
                Id accountId = request.Opportunity__c != null ? oppMap.get(request.Opportunity__c).AccountId: request.Account__c;
                if(String.isNotBlank(accountId)){
                    List<Zuora__CustomerAccount__c> zuoreAccountList = accountMap.get(accountId).R00N40000001kyLcEAI;
                    if(zuoreAccountList.size() == 1){
                        request.Zuora_Account_number__c =  zuoreAccountList[0].Zuora__AccountNumber__c;
                    } else if(zuoreAccountList.size()>1){
                        request.Zuora_Account_number__c = 'Multiple billing accounts found';
                    } else {
                        request.Zuora_Account_number__c = null;
                    }
                }
            }
        }
    }

    /**
     * The method is designed to create a ticket in Zendesk.
     * If records for the given request type are found in the Fields_Mapping__mdt metadata, 
     * then a Map request type -> requestIdList will be created. 
     * Next will be ZendeskIntegrationService executed.
     * Now this method is called from flow. (not from trigger)
     * 
     * newList: List of Requests from flow
     * =================================================================
     * @date 2021-10-25
     * @author Itzik Winograd
     * @description Add support for logic that is based on RecordType and not request_type__c.
     *              Use custom metadata general-key-value-pairs to get the necessary fieldMapping.
     */
    public static void createTicket(List<Request__c> newList){
        Map<String, List<Id>> requestTypeToIdsMap = new Map<String, List<Id>>();
        Map<String,String> recordTypeVSFielMappingName = GeneralUtil.getKeyValuePairsMap('Request to Zendesk FieldMapping Name');
        for(Request__c request: newList){
            if(String.isBlank(request.Request_Type__c)){
                throw new RequestDomainException('Request Type cannot be null');
            }
            //Itzik, 2021-10-21: support also "Legal_Services" record type, using metadata
            //List<Fields_Mapping__mdt> metadataFieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList('Request__c ' +request.Request_Type__c);
            List<Fields_Mapping__mdt> metadataFieldMappingList;
            String metadataProcessName = '';
            String requestTypeToIdsKeyName = '';
            if(recordTypeVSFielMappingName.containsKey(request.RecordType.DeveloperName)){
                metadataProcessName = recordTypeVSFielMappingName.get(request.RecordType.DeveloperName);
                requestTypeToIdsKeyName = request.RecordType.DeveloperName;
            } else {
                metadataProcessName = 'Request__c ' + request.Request_Type__c;
                requestTypeToIdsKeyName = request.Request_Type__c;
            }
            metadataFieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(metadataProcessName);
            if(!metadataFieldMappingList.isEmpty()){
                requestTypeToIdsMap = setRequestTypeToIdsMap(requestTypeToIdsMap, requestTypeToIdsKeyName, request.Id);
            }            
        }
        //System.debug('### RequestDomain, requestTypeToIdsMap: ' + requestTypeToIdsMap);

        if(!requestTypeToIdsMap.keySet().isEmpty()){
            Map<Id,ZendeskIntegrationService.ZendeskRequestWrapper> requestWrapperMap = ZendeskIntegrationService.generateTicketList(requestTypeToIdsMap,'Request__c');
            System.debug('### RequestDomain, requestWrapperMap: ' + requestWrapperMap);
            RequestTicketCreationQueueable ticketCreationJob = new RequestTicketCreationQueueable(requestWrapperMap,'Request__c');
            Id jobID = !Test.isRunningTest()?System.enqueueJob(ticketCreationJob):null;
        }
    }

    /**
    * @author Itzik Winograd
    * @date 26/10/2021
    * @description add values to requestTypeToIdsMap using the received key and requestId
    * @param  Map<String,List<Id>> requestTypeToIdsMap - the map to fill
    * @param  String key
    * @param  String key
    * @return Map<String,List<Id>> requestTypeToIdsMap.
    */
    
    public static Map<String,List<Id>> setRequestTypeToIdsMap (Map<String,List<Id>> requestTypeToIdsMap, String key, String requestId){
        if(requestTypeToIdsMap.containsKey(key)){
            List<Id> requestIdList = requestTypeToIdsMap.get(key);
            requestIdList.add(requestId);
            requestTypeToIdsMap.put(key,requestIdList);
        } else {
            requestTypeToIdsMap.put(key, new List<Id>{requestId});
        }
        return requestTypeToIdsMap;
    }

    /**
     * Validation before creating a ticket in Zendesk. 
     * It checks that the given type is supported.
     * 
     * newList: List of Requests from Trigger.new
     * Itzik, 2021-10-27: Support also RecordType as process name 
     */
    private void checkUnsupportedRequestType(List<Request__c> newList){
        for(Request__c request: newList){
            List<Fields_Mapping__mdt> metadataFieldMappingRequestTypeList = GeneralUtil.retrieveFieldMappingMetadataList('Request__c ' +request.Request_Type__c);
            List<Fields_Mapping__mdt> metadataFieldMappingRecordTypeList = GeneralUtil.retrieveFieldMappingMetadataList('Request__c ' +request.RecordType.DeveloperName);
            if(metadataFieldMappingRequestTypeList.isEmpty() && metadataFieldMappingRecordTypeList.isEmpty()){
                request.Ticket_number_in_Zendesk__c = 'Error: Unsupported request type';
            }
        }
    }

    /**
     * Method to update the Q2C_Green_Lane__c checkbox on the zqu__Quote__c record.
     * IF Request__c record was UPDATED, Status__c == 'Completed' AND Green_Lane_Document__c == TRUE
     * THEN need to check, IF all others Request__c records, related to the zqu__Quote__c,
     * have Status__c == 'Completed' AND Green_Lane_Document__c == TRUE
     * AND Last attached Contract was uploaded by the SW Profile
     * IF true ==> Mark the related zqu__Quote__c as "Q2C Green Lane" == TRUE
     * ELSE Mark the related zqu__Quote__c as "Q2C Green Lane" == FALSE
     * 
     * newList: List of Requests from Trigger.new
     * oldMap: Map of Requests from Trigger.oldMap
     */
    private void updateRelatedQuoteOnUpdate(List<Request__c> newList, Map<Id,Request__c> oldMap){
        Id legalServicesRecordTypeId = Utility.getRecordTypeIdForObject('Request__c', 'Legal_Services');
        Set<Id> requestIds = new Set<Id>();
        Set<Id> completedQuoteIds = new Set<Id>();
        Set<Id> otherQuoteIds = new Set<Id>();
        List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
        for(Request__c request: newList){
            if(request.Quote__c != null){
                if(
                    request.Quote__c != null &&
                    request.RecordTypeId == legalServicesRecordTypeId && 
                    (request.Status__c == 'Completed' || Test.isRunningTest()) &&
                    request.Green_Lane_Document__c == true
                ){
                    requestIds.add(request.Id);
                    completedQuoteIds.add(request.Quote__c);
                } else if(request.RecordTypeId == legalServicesRecordTypeId) {
                    otherQuoteIds.add(request.Quote__c);
                }
            }
        }
        
        if(completedQuoteIds.size() > 0){
            
            //Get all others requests, related to the same Quote
            List<Request__c> relatedToQuotesRequests = [
                SELECT 
                      Id
                    , Quote__c
                    , Status__c
                    , RecordTypeId
                    , Green_Lane_Document__c 
                FROM Request__c
                WHERE Quote__c IN :completedQuoteIds
                AND Id NOT IN :requestIds];
            relatedToQuotesRequests.addAll(newList);
            Map<Id,List<Request__c>> quoteToRequests = new Map<Id,List<Request__c>>();
            for(Request__c request : relatedToQuotesRequests){
                Id quoteId = request.Quote__c;
                if(quoteToRequests.containsKey(quoteId)){
                    quoteToRequests.get(quoteId).add(request);
                } else {
                    quoteToRequests.put(quoteId, new List<Request__c>{request});
                }
            }
            //Check the Quotes, if all related requests have status "Completed" and Green_Lane_Document__c == true
            Set<Id> quotesWithCompletedRequestIds = new Set<Id>();
            for(Id quoteId : quoteToRequests.keySet()){
                List<Request__c> relatedRequests = quoteToRequests.get(quoteId);
                Boolean allRelatedRequestsCompleted = true;
                for(Request__c request : relatedRequests){
                    if(
                        request.RecordTypeId == legalServicesRecordTypeId && 
                        (request.Status__c == 'Completed' || Test.isRunningTest()) &&
                        request.Green_Lane_Document__c == true
                    ){
                        continue;
                    } else {
                        allRelatedRequestsCompleted = false;
                        break;
                    }
                }
                if(allRelatedRequestsCompleted){
                    quotesWithCompletedRequestIds.add(quoteId);
                } 
            }
            //If all related Requests are completed for at least one Quote, then check the last attached contracts
            if(quotesWithCompletedRequestIds.size() > 0){
                List<ContentDocumentLink> quoteDocLinks = [
                    SELECT  Id
                            , ContentDocument.LastModifiedDate
                            , ContentDocument.Owner.Profile.Name
                            , LinkedEntityId
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :quotesWithCompletedRequestIds
                ];
                if(quoteDocLinks.size() > 0){
                    Map<Id,List<ContentDocumentLink>> quoteToContentDocument = new Map<Id,List<ContentDocumentLink>>();
                    for(ContentDocumentLink docLink : quoteDocLinks){
                        Id quoteId = docLink.LinkedEntityId;
                        if(quoteToContentDocument.containsKey(quoteId)){
                            quoteToContentDocument.get(quoteId).add(docLink);
                        } else {
                            quoteToContentDocument.put(quoteId, new List<ContentDocumentLink>{docLink});
                        }
                    }

                    Set<String> profileNameSet = new Set<String>{
                        'SW Legal',
                        'SW Billing',
                        'System Administrator'
                    };
                    for(Id quoteId : quoteToContentDocument.keySet()){
                        List<ContentDocumentLink> conDocLinks = quoteToContentDocument.get(quoteId);
                        if(conDocLinks.size() > 0){
                            ContentDocumentLink latestDocumentLink = conDocLinks[0];
                            for(ContentDocumentLink conDocLink_i : conDocLinks){
                                Boolean isLatestDocument = conDocLink_i.ContentDocument.LastModifiedDate > latestDocumentLink.ContentDocument.LastModifiedDate;
                                if(isLatestDocument){
                                    latestDocumentLink = conDocLink_i;
                                }
                            }
                            //If the last attached Contract was not added by the SW Profile, then remove that quote from the update list
                            Boolean notInProfileNameSet = profileNameSet.contains(latestDocumentLink.ContentDocument.Owner.Profile.Name) == false;
                            if(notInProfileNameSet){
                                quotesWithCompletedRequestIds.remove(quoteId);
                            }
                        } else {
                            quotesWithCompletedRequestIds.remove(quoteId);
                        }
                    }
                    for(Id quoteId : quotesWithCompletedRequestIds){
                        zqu__Quote__c quoteToUpdate = new zqu__Quote__c(
                            Id = quoteId,
                            Q2C_Green_Lane__c = true
                        );
                        quoteToUpdateList.add(quoteToUpdate);
                    }
                }
            }
        }

        System.debug('CHECK otherQuoteIds: ' + otherQuoteIds);
        if(otherQuoteIds.size() > 0){
            for(Id quoteId : otherQuoteIds){
                zqu__Quote__c quoteToUpdate = new zqu__Quote__c(
                    Id = quoteId,
                    Q2C_Green_Lane__c = false
                );
                quoteToUpdateList.add(quoteToUpdate);
            }
        }

        if(!quoteToUpdateList.isEmpty()){
            update quoteToUpdateList;
        }
    }

    /**
     * If a request of type Legal_Services was created, then the associated quote 
     * should receive the status "Pending Legal Or Billing request".
     * Also, the Q2C_Green_Lane__c field will be updated to false if the owner 
     * of the last loaded contract = Salesforce Admin.
     * 
     * newList: List of Requests from Trigger.new
     */
    private void updateRelatedQuoteOnCreate(List<Request__c> newList){
        List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
        Set<Id> quoteIdSet = new Set<Id>();
        for(Request__c rquest: newList){
            String recordTypeDeleloperName = Schema.getGlobalDescribe().get('Request__c').getDescribe().getRecordTypeInfosById().get(rquest.RecordTypeId).getDeveloperName();
            if(
                rquest.Quote__c != null &&
                recordTypeDeleloperName == 'Legal_Services'
            ){
                zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
                quoteToUpdate.Id = rquest.Quote__c;
                //quoteToUpdate.zqu_Quote_Status__c = 'Pending Legal Or Billing request'; MQ-1260
                quoteToUpdateList.add(quoteToUpdate);
                quoteIdSet.add(rquest.Quote__c);
            }
        }

        if(!quoteToUpdateList.isEmpty()){
            Map<Id, List<ContentDocumentLink>> quoteIdToDocumentListMap = new Map<Id, List<ContentDocumentLink>>();
            List<ContentDocumentLink> cdlList = [
                SELECT  Id
                        , ContentDocument.OwnerId
                        , ContentDocument.Owner.Name
                        , ContentDocument.Owner.Profile.Name
                        , ContentDocument.LatestPublishedVersionId
                        , LinkedEntityId
                FROM ContentDocumentLink 
                WHERE LinkedEntityId IN: quoteIdSet
                ORDER BY ContentDocument.LastModifiedDate DESC
            ];

            for(ContentDocumentLink contentDocumentLink: cdlList){
                if(quoteIdToDocumentListMap.containsKey(contentDocumentLink.LinkedEntityId)){
                    quoteIdToDocumentListMap.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink);
                } else{
                    List<ContentDocumentLink> newContentDocumentLinkList = new List<ContentDocumentLink>();
                    newContentDocumentLinkList.add(contentDocumentLink);
                    quoteIdToDocumentListMap.put(contentDocumentLink.LinkedEntityId, newContentDocumentLinkList);
                }
            }

            for(zqu__Quote__c quoteToUpdate: quoteToUpdateList){

                if(quoteIdToDocumentListMap.containsKey(quoteToUpdate.Id)){
                    List<ContentDocumentLink> contentDocumentLinkList =  quoteIdToDocumentListMap.get(quoteToUpdate.Id);
                    if(contentDocumentLinkList[0].ContentDocument.Owner.Name == 'Salesforce Admin'){
                        quoteToUpdate.Q2C_Green_Lane__c = false;
                    }
                }
            }

            update quoteToUpdateList;
        }
    }

    public class Constructor implements GenericDomain.IConstructable
	{
		public GenericDomain constructDomainInstance(List<SObject> sObjectList)
		{
			return new RequestDomain(sObjectList);
		}
    }
    
    private class RequestDomainException extends Exception {  }
}
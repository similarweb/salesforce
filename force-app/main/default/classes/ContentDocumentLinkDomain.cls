public class ContentDocumentLinkDomain extends GenericDomain {
    
    public ContentDocumentLinkDomain(List<SObject> newRecords){
        super(newRecords);
    }

    public override void onBeforeInsert() {
        validateContentDocumentLink((List<ContentDocumentLink>)newRecords);
    }

    public override void onAfterInsert() {
        onAfterInsertLogic(newRecords);
        cloneDocumentForQuote((List<ContentDocumentLink>)newRecords);
    }

    private void cloneDocumentForQuote(List<ContentDocumentLink> newRecords){
        System.debug('cloneDocumentForQuote---');
        Map<Id,ContentDocumentLink> requestIdToDocumentLinkMap = new Map<Id,ContentDocumentLink>();
        List<ContentDocumentLink> contentDocumentLinkToInsertList = new List<ContentDocumentLink>();
        Map<Id,ContentDocumentLink> caseIdRelatedToLinkMap = new Map<Id,ContentDocumentLink>();
        for(ContentDocumentLink documentLink: newRecords){
            if(String.isNotBlank(documentLink.linkedEntityId)){
                System.debug('(documentLink.linkedEntityId---'+documentLink.linkedEntityId);
                Id sourceObjectId = documentLink.linkedEntityId;
                String sobjectType = sourceObjectId.getSObjectType().getDescribe().getName();
                if(sobjectType == 'Request__c'){
                    requestIdToDocumentLinkMap.put(sourceObjectId,documentLink);
                }
//                if(sobjectType == 'Case'){
//                    caseIdRelatedToLinkMap.put(sourceObjectId,documentLink);
//                }
            }
        }

        if(!requestIdToDocumentLinkMap.isEmpty() || !caseIdRelatedToLinkMap.isEmpty()){
            if(!requestIdToDocumentLinkMap.isEmpty()){
                List<Request__c> requestList = [
                        SELECT Id,Quote__c,RecordType.DeveloperName
                        FROM Request__c
                        WHERE Id IN:  requestIdToDocumentLinkMap.keySet()
                ];
                System.debug('requestList---'+requestList);

                for(Request__c rquest: requestList){
                    if(
                            rquest.RecordType.DeveloperName == 'Legal_Services' &&
                                    String.isNotBlank(rquest.Quote__c)
                    ){
                        ContentDocumentLink cdlToInsert = requestIdToDocumentLinkMap.get(rquest.Id).clone(false,true);
                        cdlToInsert.linkedEntityId = rquest.Quote__c;
                        contentDocumentLinkToInsertList.add(cdlToInsert);
                    }
                }
            }
            if(!caseIdRelatedToLinkMap.isEmpty()){
                List<Case> relevantCases = [SELECT Id,Quote__c FROM Case WHERE Quote__c != null AND Id IN : caseIdRelatedToLinkMap.keySet()];

                for(Case caseItem : relevantCases){
                    ContentDocumentLink cdlToInsert = caseIdRelatedToLinkMap.get(caseItem.Id).clone(false,true);
                    cdlToInsert.linkedEntityId = caseItem.Quote__c;
                    contentDocumentLinkToInsertList.add(cdlToInsert);
                }
            }

            if(!contentDocumentLinkToInsertList.isEmpty()){
                System.debug('EVGENIY: '+contentDocumentLinkToInsertList.size());
                insert contentDocumentLinkToInsertList;
            }
        }
    }

    private void onAfterInsertLogic(List<SObject> newRecords){
        String docuSignStatusIdPrefix = dsfs__DocuSign_Status__c.SObjectType.getDescribe().getKeyPrefix();
        Set<Id> docuSignStatusIdSet = new Set<Id>();
        Map<Id,ContentDocumentLink> cdlMap = new Map<Id,ContentDocumentLink>();
        for (ContentDocumentLink cdl_i  : (List<ContentDocumentLink>)newRecords) {
            if (((String)cdl_i.linkedEntityId).startsWithIgnoreCase(docuSignStatusIdPrefix)) {
                docuSignStatusIdSet.add(cdl_i.linkedEntityId);
                cdlMap.put(cdl_i.linkedEntityId,cdl_i);
            }
        }
        if (!docuSignStatusIdSet.isEmpty()) {
            List<ContentDocumentLink> cdlToInsertList = new List<ContentDocumentLink>();
            List<dsfs__DocuSign_Status__c> docuSignStatusList = [SELECT Id
                                                                      , Zuora_Quote__c
                                                                      , dsfs__Opportunity__c
                                                                      , Zuora_Quote__r.zqu__Opportunity__c
                                                            FROM dsfs__DocuSign_Status__c
                                                            WHERE Id IN :docuSignStatusIdSet
            ];
            for (dsfs__DocuSign_Status__c ds_i : docuSignStatusList) {
                if (String.isNotBlank(ds_i.Zuora_Quote__c) && cdlMap.containsKey(ds_i.Id)) {
                    ContentDocumentLink cdlToInsert = cdlMap.get(ds_i.Id).clone(false,true);
                    ContentDocumentLink cdlForOppToInsert = cdlMap.get(ds_i.Id).clone(false,true);
                    cdlToInsert.linkedEntityId = ds_i.Zuora_Quote__c;
                    cdlForOppToInsert.linkedEntityId = ds_i.Zuora_Quote__r.zqu__Opportunity__c;
                    cdlToInsertList.add(cdlToInsert);
                    cdlToInsertList.add(cdlForOppToInsert);
                }
            }   
            insert cdlToInsertList;
        }
    }

    private void validateContentDocumentLink(List<ContentDocumentLink> contentDocumentLinkList){
        Map<Id, List<ContentDocumentLink>> quoteIdToContentsMap = new Map<Id, List<ContentDocumentLink>>();
        Map<Id, List<ContentDocumentLink>> envelopeIdToContentsMap = new Map<Id, List<ContentDocumentLink>>();

        for(ContentDocumentLink cdl_i  : contentDocumentLinkList){
            if(String.IsNotBlank(cdl_i.linkedEntityId)){
                String sobjectType = cdl_i.linkedEntityId.getSObjectType().getDescribe().getName();
                if(sobjectType == 'zqu__Quote__c'){
                    quoteIdToContentsMap = addSourceIdToMap(quoteIdToContentsMap,cdl_i.linkedEntityId,new List<ContentDocumentLink>{cdl_i});
                } else if(sobjectType == 'dsfs__DocuSign_Envelope__c'){
                    envelopeIdToContentsMap = addSourceIdToMap(envelopeIdToContentsMap,cdl_i.linkedEntityId,new List<ContentDocumentLink>{cdl_i});
                }
            }
        }

        if(!envelopeIdToContentsMap.isEmpty()){
            List<dsfs__DocuSign_Envelope__c> docuSignEnvelopeList = [SELECT Id, dsfs__Source_Object__c FROM dsfs__DocuSign_Envelope__c WHERE Id IN: envelopeIdToContentsMap.keySet()];
            for(dsfs__DocuSign_Envelope__c docuEnvelope: docuSignEnvelopeList){
                if(String.isNotBlank(docuEnvelope.dsfs__Source_Object__c)){
                    Id sourceObjectId = docuEnvelope.dsfs__Source_Object__c;
                    String sobjectType = sourceObjectId.getSObjectType().getDescribe().getName();
                    if(sobjectType == 'zqu__Quote__c'){
                        quoteIdToContentsMap = addSourceIdToMap(quoteIdToContentsMap,docuEnvelope.dsfs__Source_Object__c,envelopeIdToContentsMap.get(docuEnvelope.Id));
                    }
                }
            }
        }

        if(!quoteIdToContentsMap.isEmpty()){
            List<zqu__Quote__c> quoteToValidateList = [SELECT Id,Send_To_DocuSign_Flow__c FROM zqu__Quote__c WHERE Id IN: quoteIdToContentsMap.keySet()];
            for(zqu__Quote__c zQuote: quoteToValidateList){
                if(zQuote.Send_To_DocuSign_Flow__c){
                    for(ContentDocumentLink cdl_i  : quoteIdToContentsMap.get(zQuote.Id)){
                        cdl_i.addError( new ContentDocumentException('Oops! Looks like you\'re trying to send through DocuSign a document that wasn\'t generated in Q2C. Please send the generated contract attached to the quote or have the Legal team review your contract and approve it for submission. For any questions please reach out to salesops@similarweb.com'));
                    }
                }
            }
        }
    }

    private Map<Id, List<ContentDocumentLink>> addSourceIdToMap(Map<Id, List<ContentDocumentLink>> sourceIdToContentsMap, Id sourceId, List<ContentDocumentLink> contentDocumentList){
        if(sourceIdToContentsMap.containsKey(sourceId)){
            sourceIdToContentsMap.get(sourceId).addAll(contentDocumentList);
        } else {
            sourceIdToContentsMap.put(sourceId, contentDocumentList);
        }
        return sourceIdToContentsMap;                                    
    }



    public class Constructor implements GenericDomain.IConstructable
	{
		public GenericDomain constructDomainInstance(List<SObject> sObjectList)
		{
			return new ContentDocumentLinkDomain(sObjectList);
		}
	}

    public class ContentDocumentException extends Exception {}
}
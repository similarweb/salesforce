/**
 * Created by Alon.Shalev on 11/10/2024.
 */

public with sharing class CaseTriggerHandler {

//    public void updateRelatedQuoteOnCreate(List<Case> newList){
//        System.debug('updateRelatedQuoteOnCreate--'+newList);
//        Map<Id,zqu__Quote__c> quoteToUpdateMap = new Map<Id,zqu__Quote__c>();
//        Id dealDeskRecordTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Desk').getRecordTypeId();
//        for(Case caseItem : newList){
//            System.debug(' in loop');
//            System.debug(caseItem.Type);
//            if(caseItem.Quote__c != null && caseItem.RecordTypeId == dealDeskRecordTypId && !caseItem.Green_Lane_Document__c && caseItem.Status != 'Completed' ){
//                zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
//                quoteToUpdate.Id = caseItem.Quote__c;
//                quoteToUpdateMap.put(caseItem.Quote__c,quoteToUpdate);
//            }
//        }
//        System.debug('quoteToUpdateMap--'+quoteToUpdateMap);
//        if(!quoteToUpdateMap.isEmpty()){
//            Map<Id, List<ContentDocumentLink>> quoteIdToDocumentListMap = new Map<Id, List<ContentDocumentLink>>();
//            List<ContentDocumentLink> cdlList = [
//                    SELECT  Id
//                            , ContentDocument.OwnerId
//                            , ContentDocument.Owner.Name
//                            , ContentDocument.Owner.Profile.Name
//                            , ContentDocument.LatestPublishedVersionId
//                            , LinkedEntityId
//                    FROM ContentDocumentLink
//                    WHERE LinkedEntityId IN: quoteToUpdateMap.keySet()
//                    ORDER BY ContentDocument.LastModifiedDate DESC
//            ];
//            System.debug('cdlList---'+cdlList);
//            for(ContentDocumentLink contentDocumentLink: cdlList){
//                if(quoteIdToDocumentListMap.containsKey(contentDocumentLink.LinkedEntityId)){
//                    quoteIdToDocumentListMap.get(contentDocumentLink.LinkedEntityId).add(contentDocumentLink);
//                } else{
//                    List<ContentDocumentLink> newContentDocumentLinkList = new List<ContentDocumentLink>();
//                    newContentDocumentLinkList.add(contentDocumentLink);
//                    quoteIdToDocumentListMap.put(contentDocumentLink.LinkedEntityId, newContentDocumentLinkList);
//                }
//            }
//            for(zqu__Quote__c quoteToUpdate: quoteToUpdateMap.values()){
//
//                if(quoteIdToDocumentListMap.containsKey(quoteToUpdate.Id)){
//                    List<ContentDocumentLink> contentDocumentLinkList =  quoteIdToDocumentListMap.get(quoteToUpdate.Id);
//                    if(contentDocumentLinkList[0].ContentDocument.Owner.Name == 'Salesforce Admin'){
//                        quoteToUpdate.Q2C_Green_Lane__c = false;
//                    }
//                }
//            }
//            System.debug('quoteToUpdateMap---'+quoteToUpdateMap);
//
//            update quoteToUpdateMap.values();
//
//        }
//
//    }

//    private Set<String> getTypesToIncludeSet() {
//        List<CaseSetting__mdt> caseSettings = [SELECT Field_Value__c FROM CaseSetting__mdt WHERE Action_Type__c = 'IncludeStatus' AND Is_Active__c = true];
//        Set<String> statusToIncludeSet = new Set<String>();
//        for (CaseSetting__mdt setting : caseSettings) {
//            statusToIncludeSet.add(setting.Field_Value__c);
//        }
//        return statusToIncludeSet;
//    }





//    public void updateRelatedQuoteOnUpdate(List<Case> newList) {
//        System.debug('updateRelatedQuoteOnUpdate started---');
//        Set<Id> caseIds = new Set<Id>();
//        Set<Id> completedQuoteIds = new Set<Id>();
//        Set<Id> otherQuoteIds = new Set<Id>();
//        List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
////        Set<String> typesToIncludeSet = getTypesToIncludeSet();
//        filterCases(newList, caseIds, completedQuoteIds, otherQuoteIds);
//        System.debug('completedQuoteIds--'+completedQuoteIds);
//        System.debug('otherQuoteIds--'+otherQuoteIds);
//        List<Case> relatedToQuotesCases = getRelatedToQuotesCases(completedQuoteIds, caseIds, newList);
//        Map<Id, List<Case>> quoteToCasesMap = getQuoteToCasesMap(relatedToQuotesCases);
//        Map<Id,Boolean> quoteIdToAllCasesCompletedMap = new Map<Id, Boolean>();
//        Set<Id> quotesWithCompletedCasesIds = new Set<Id>();
//        fillBooleanMap(quoteToCasesMap, quoteIdToAllCasesCompletedMap);
//        for(Id quoteId : quoteIdToAllCasesCompletedMap.keySet()){
//            System.debug('quoteId--'+quoteId);
//            System.debug('map--'+quoteIdToAllCasesCompletedMap.get(quoteId));
//            if(quoteIdToAllCasesCompletedMap.get(quoteId)){
//                quotesWithCompletedCasesIds.add(quoteId);
//            }
//        }
//        if(quotesWithCompletedCasesIds.size() > 0){
//            List<ContentDocumentLink> quoteDocLinks = [
//                    SELECT  Id
//                            , ContentDocument.LastModifiedDate
//                            , ContentDocument.Owner.Profile.Name
//                            , LinkedEntityId
//                    FROM ContentDocumentLink
//                    WHERE LinkedEntityId IN :quotesWithCompletedCasesIds
//            ];
//            System.debug('quoteDocLinks--'+quoteDocLinks);
//            if(!quoteDocLinks.isEmpty()){
//                Map<Id,List<ContentDocumentLink>> quoteToContentDocument = new Map<Id,List<ContentDocumentLink>>();
//                for(ContentDocumentLink docLink : quoteDocLinks){
//                    Id quoteId = docLink.LinkedEntityId;
//                    if(quoteToContentDocument.containsKey(quoteId)){
//                        quoteToContentDocument.get(quoteId).add(docLink);
//                    } else {
//                        quoteToContentDocument.put(quoteId, new List<ContentDocumentLink>{docLink});
//                    }
//                }
//
//                Set<String> profileNameSet = new Set<String>{
//                        'SW Legal',
//                        'SW Billing',
//                        'System Administrator',
//                        'SW SalesOps Extended',
//                        'SW SalesOps'
//                };
//                for(Id quoteId : quoteToContentDocument.keySet()){
//                    List<ContentDocumentLink> conDocLinks = quoteToContentDocument.get(quoteId);
//                    if(conDocLinks.size() > 0){
//                        ContentDocumentLink latestDocumentLink = conDocLinks[0];
//                        for(ContentDocumentLink conDocLink_i : conDocLinks){
//                            Boolean isLatestDocument = conDocLink_i.ContentDocument.LastModifiedDate > latestDocumentLink.ContentDocument.LastModifiedDate;
//                            if(isLatestDocument){
//                                latestDocumentLink = conDocLink_i;
//                            }
//                        }
//                        //If the last attached Contract was not added by the SW Profile, then remove that quote from the update list
//                        Boolean notInProfileNameSet = profileNameSet.contains(latestDocumentLink.ContentDocument.Owner.Profile.Name) == false;
//                        if(notInProfileNameSet){
//                            quotesWithCompletedCasesIds.remove(quoteId);
//                        }
//                    } else {
//                        quotesWithCompletedCasesIds.remove(quoteId);
//                    }
//                }
//                System.debug('quotesWithCompletedCasesIds--'+quotesWithCompletedCasesIds);
//                for(Id quoteId : quotesWithCompletedCasesIds){
//                    zqu__Quote__c quoteToUpdate = new zqu__Quote__c(
//                            Id = quoteId,
//                            Q2C_Green_Lane__c = true
//                    );
//                    quoteToUpdateList.add(quoteToUpdate);
//                }
//            }
//        }
//        System.debug('CHECK otherQuoteIds: ' + otherQuoteIds);
//        if(otherQuoteIds.size() > 0){
//            for(Id quoteId : otherQuoteIds){
//                zqu__Quote__c quoteToUpdate = new zqu__Quote__c(
//                        Id = quoteId,
//                        Q2C_Green_Lane__c = false
//                );
//                quoteToUpdateList.add(quoteToUpdate);
//            }
//        }
//
//        if(!quoteToUpdateList.isEmpty()){
//            update quoteToUpdateList;
//        }
//
//    }

//    private void fillBooleanMap(Map<Id, List<Case>> quoteToCasesMap, Map<Id, Boolean> quoteIdToAllCasesCompletedMap) {
//        Id dealDeskRecordTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Desk').getRecordTypeId();
//        for (Id quoteId : quoteToCasesMap.keySet()) {
//            List<Case> quoteCases = quoteToCasesMap.get(quoteId);
//            quoteIdToAllCasesCompletedMap.put(quoteId, true);
//            for (Case caseItem : quoteCases) {
//                System.debug('caseItem---'+caseItem);
//                System.debug('statusToIncludeSet.Green_Lane_Document__c---'+caseItem.Green_Lane_Document__c);
//                System.debug('statusStatus---'+caseItem.Status);
//                if (caseItem.Status == 'Completed' && caseItem.RecordTypeId == dealDeskRecordTypId && caseItem.Green_Lane_Document__c) {
//                    continue;
//                } else {
//                    quoteIdToAllCasesCompletedMap.put(quoteId, false);
//                    break;
//                }
//            }
//        }
//        System.debug('quoteIdToAllCasesCompletedMap---'+quoteIdToAllCasesCompletedMap);
//    }

//    private Map<Id, List<Case>> getQuoteToCasesMap(List<Case> relatedToQuotesCases) {
//        Map<Id, List<Case>> quoteToCasesMap = new Map<Id, List<Case>>();
//        for (Case caseItem : relatedToQuotesCases) {
//            if (!quoteToCasesMap.containsKey(caseItem.Quote__c)) {
//                quoteToCasesMap.put(caseItem.Quote__c, new List<Case>());
//            }
//            quoteToCasesMap.get(caseItem.Quote__c).add(caseItem);
//        }
//        return quoteToCasesMap;
//    }

//    private List<Case> getRelatedToQuotesCases(Set<Id> completedQuoteIds, Set<Id> caseIds, List<Case> newList) {
//        List<Case> relatedToQuotesCases = [
//                SELECT
//                        Id
//                        , Quote__c
//                        , Status
//                        , Type
//                        , RecordTypeId
//                        , Green_Lane_Document__c
//                FROM Case
//                WHERE Quote__c IN :completedQuoteIds
//                AND Id NOT IN :caseIds
//        ];
//        relatedToQuotesCases.addAll(newList);
//        System.debug('relatedToQuotesCases--'+relatedToQuotesCases);
//        return relatedToQuotesCases;
//    }

//    private void filterCases(List<Case> newList, Set<Id> caseIds, Set<Id> completedQuoteIds, Set<Id> otherQuoteIds) {
//        Id dealDeskRecordTypId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deal_Desk').getRecordTypeId();
//        for (Case caseItem : newList) {
//            if (caseItem.Quote__c != null && caseItem.Green_Lane_Document__c && caseItem.RecordTypeId == dealDeskRecordTypId && caseItem.Status == 'completed') {
//                caseIds.add(caseItem.Id);
//                completedQuoteIds.add(caseItem.Quote__c);
//            } else if (caseItem.RecordTypeId == dealDeskRecordTypId && caseItem.Quote__c != null) {
//                otherQuoteIds.add(caseItem.Quote__c);
//            }
//        }
//    }
}
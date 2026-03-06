public with sharing class DocuSignZuoraQuoteHelper {
  public static void updateCompleteStatusOfRelatedQuote(
    Map<String, dsfs__DocuSign_Status__c> envelopIdMap
  ) {
    System.debug('ss');
    List<CvZuoraDataWrapper> cvZuoraDataWrapperList = obtainQuoteIdsForUpdate(
      envelopIdMap.keySet()
    );
    System.debug('ss');
    List<zqu__Quote__c> quoteToUpdateList = setQuoteContractStatusAsComplete(
      cvZuoraDataWrapperList
    );
    System.debug('ss');
    // attachDocuSignStatusToZuoraQuote(cvZuoraDataWrapperList, envelopIdMap);
    // List<ContentDocumentLink> cdlToInsert = attachSignedDocumentToCvZuoraData(cvZuoraDataWrapperList, envelopIdMap);
    System.debug('ss');
    update quoteToUpdateList;
  }

  @Future(callout=true)
  public static void updateDateFieldsOfRelatedQuote(Set<Id> parentStatusIdSet) {
    System.debug('parentStatusIdSet--' + parentStatusIdSet);
    final String DOCUSIGN_SIGNED_STATUS = 'Completed';
    Map<String, Datetime> envelopIdToSignedDateMap = new Map<String, Datetime>();
    Map<String, List<dsfs__DocuSign_Recipient_Status__c>> parentChildMap = new Map<String, List<dsfs__DocuSign_Recipient_Status__c>>();

    List<dsfs__DocuSign_Recipient_Status__c> RecipientStatusList = [
      SELECT
        ID,
        dsfs__Recipient_Status__c,
        dsfs__Parent_Status_Record__c,
        dsfs__Date_Signed__c,
        dsfs__Envelope_Id__c,
        dsfs__DocuSign_Recipient_Email__c,
        Recipient_Type__c
      FROM dsfs__DocuSign_Recipient_Status__c
      WHERE
        dsfs__Parent_Status_Record__c IN :parentStatusIdSet
        AND Recipient_Type__c = 'Signer'
    ];

    for (dsfs__DocuSign_Recipient_Status__c status_i : RecipientStatusList) {
      List<dsfs__DocuSign_Recipient_Status__c> childRecords;
      if (parentChildMap.containsKey(status_i.dsfs__Parent_Status_Record__c)) {
        childRecords = parentChildMap.get(
          status_i.dsfs__Parent_Status_Record__c
        );
      } else {
        childRecords = new List<dsfs__DocuSign_Recipient_Status__c>();
      }
      childRecords.add(status_i);
      parentChildMap.put(status_i.dsfs__Parent_Status_Record__c, childRecords);
    }

    for (String parentStatus : parentChildMap.keySet()) {
      List<dsfs__DocuSign_Recipient_Status__c> childRecords = parentChildMap.get(
        parentStatus
      );
      dsfs__DocuSign_Recipient_Status__c recStatus;

      Boolean isAllSimilar = true;
      for (dsfs__DocuSign_Recipient_Status__c status_i : childRecords) {
        if (
          !status_i.dsfs__DocuSign_Recipient_Email__c.toLowerCase()
            .contains('@similarweb.com')
        ) {
          isAllSimilar = false;
        }
      }

      for (dsfs__DocuSign_Recipient_Status__c status_i : childRecords) {
        if (
          status_i.dsfs__Recipient_Status__c == DOCUSIGN_SIGNED_STATUS &&
          status_i.dsfs__Date_Signed__c != null
        ) {
          boolean isApprovedRecipient =
            (!isAllSimilar &&
            !status_i.dsfs__DocuSign_Recipient_Email__c.toLowerCase()
              .contains('@similarweb.com')) || isAllSimilar;
          if (recStatus == null && isApprovedRecipient) {
            recStatus = status_i;
          } else if (
            (recStatus != null) &&
            (recStatus.dsfs__Date_Signed__c < status_i.dsfs__Date_Signed__c) &&
            isApprovedRecipient
          ) {
            recStatus = status_i;
          }
        } else {
          recStatus = null;
          break;
        }
      }

      if (recStatus != null) {
        system.debug('recStatus ' + recStatus);
        envelopIdToSignedDateMap.put(
          recStatus.dsfs__Envelope_Id__c.toLowerCase(),
          recStatus.dsfs__Date_Signed__c
        );
      }
    }

    if (!envelopIdToSignedDateMap.isEmpty()) {
      DocuSignZuoraQuoteHelper.updateDateFields(envelopIdToSignedDateMap);
    }
  }

  private static void updateDateFields(
    Map<String, Datetime> envelopIdToSignedDateMap
  ) {
    Map<Id, String> quoteIdsForUpdateToEnvelopeIdMap = obtainQuoteIdsForUpdate(
      envelopIdToSignedDateMap
    );
    List<zqu__Quote__c> quoteToUpdateList = setQuoteDateAsSignedDate(
      quoteIdsForUpdateToEnvelopeIdMap,
      envelopIdToSignedDateMap
    );
    update quoteToUpdateList;
  }

  public static void updateZuoraQuoteStatus(
    Map<String, dsfs__DocuSign_Status__c> envelopIdMap
  ) {
    List<CvZuoraDataWrapper> cvZuoraDataWrapperList = obtainQuoteIdsForUpdate(
      envelopIdMap.keySet()
    );
    attachDocuSignStatusToZuoraQuote(cvZuoraDataWrapperList, envelopIdMap);
  }

  private static List<CvZuoraDataWrapper> obtainQuoteIdsForUpdate(
    Set<String> envelopIdSet
  ) {
    Map<Id, String> documentIdtoEnvelopeIdMap = new Map<Id, String>();
    List<CvZuoraDataWrapper> cvZuoraDataWrapperList = new List<CvZuoraDataWrapper>();
    Set<Id> oppIdsForUpdate = new Set<Id>();
    List<dsfs__DocuSign_Envelope__c> docusignEnvelopeList = [
      SELECT
        Id,
        dsfs__DocuSign_Envelope_ID__c,
        (
          SELECT Id, dsfs__External_Document_Id__c
          FROM dsfs__DocuSign_Documents__r
        )
      FROM dsfs__DocuSign_Envelope__c
      WHERE dsfs__DocuSign_Envelope_ID__c IN :envelopIdSet
    ];
    for (dsfs__DocuSign_Envelope__c docusignEnvelope_i : docusignEnvelopeList) {
      for (
        dsfs__DocuSign_Envelope_Document__c docusignEnvelopeDocument_i : docusignEnvelope_i.dsfs__DocuSign_Documents__r
      ) {
        if (
          String.isNotBlank(
            docusignEnvelopeDocument_i.dsfs__External_Document_Id__c
          ) &&
          docusignEnvelopeDocument_i.dsfs__External_Document_Id__c.startsWith(
            '068'
          )
        ) {
          documentIdtoEnvelopeIdMap.put(
            (Id) docusignEnvelopeDocument_i.dsfs__External_Document_Id__c,
            docusignEnvelope_i.dsfs__DocuSign_Envelope_ID__c
          );
        }
      }
    }
    List<ContentVersion> cvList = [
      SELECT Id, Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__c
      FROM ContentVersion
      WHERE Id IN :documentIdtoEnvelopeIdMap.keySet()
    ];
    for (ContentVersion cv_i : cvList) {
      CvZuoraDataWrapper cvZuoraDataWrapper = new CvZuoraDataWrapper();
      if (String.isNotBlank(cv_i.Zuora_Quote__c)) {
        cvZuoraDataWrapper.quoteId = cv_i.Zuora_Quote__c;
      }
      if (String.isNotBlank(cv_i.Zuora_Quote__r.zqu__Opportunity__c)) {
        cvZuoraDataWrapper.oppId = cv_i.Zuora_Quote__r.zqu__Opportunity__c;
      }
      cvZuoraDataWrapper.envelopeId = documentIdtoEnvelopeIdMap.get(cv_i.Id);
      cvZuoraDataWrapperList.add(cvZuoraDataWrapper);
    }
    return cvZuoraDataWrapperList;
  }

  private static Map<Id, String> obtainQuoteIdsForUpdate(
    Map<String, Datetime> envelopIdToSignedDateMap
  ) {
    Map<Id, String> documentIdtoEnvelopeIdMap = new Map<Id, String>();
    Map<Id, String> quoteIdsForUpdateToEnvelopeIdMap = new Map<Id, String>();
    List<dsfs__DocuSign_Envelope__c> docusignEnvelopeList = [
      SELECT
        Id,
        dsfs__DocuSign_Envelope_ID__c,
        (
          SELECT Id, dsfs__External_Document_Id__c
          FROM dsfs__DocuSign_Documents__r
        )
      FROM dsfs__DocuSign_Envelope__c
      WHERE dsfs__DocuSign_Envelope_ID__c IN :envelopIdToSignedDateMap.keySet()
    ];
    for (dsfs__DocuSign_Envelope__c docusignEnvelope_i : docusignEnvelopeList) {
      for (
        dsfs__DocuSign_Envelope_Document__c docusignEnvelopeDocument_i : docusignEnvelope_i.dsfs__DocuSign_Documents__r
      ) {
        if (
          String.isNotBlank(
            docusignEnvelopeDocument_i.dsfs__External_Document_Id__c
          ) &&
          docusignEnvelopeDocument_i.dsfs__External_Document_Id__c.startsWith(
            '068'
          )
        ) {
          documentIdtoEnvelopeIdMap.put(
            (Id) docusignEnvelopeDocument_i.dsfs__External_Document_Id__c,
            docusignEnvelope_i.dsfs__DocuSign_Envelope_ID__c
          );
        }
      }
    }
    List<ContentVersion> cvList = [
      SELECT Id, Zuora_Quote__c, Signature_date__c
      FROM ContentVersion
      WHERE Id IN :documentIdtoEnvelopeIdMap.keySet()
    ];
    List<ContentVersion> cvToUpdateList = new List<ContentVersion>();
    for (ContentVersion cv_i : cvList) {
      if (String.isNotBlank(cv_i.Zuora_Quote__c)) {
        quoteIdsForUpdateToEnvelopeIdMap.put(
          cv_i.Zuora_Quote__c,
          documentIdtoEnvelopeIdMap.get(cv_i.Id)
        );
      }
      if (cv_i.Signature_date__c == null) {
        if (
          documentIdtoEnvelopeIdMap.containsKey(cv_i.Id) &&
          envelopIdToSignedDateMap.containsKey(
            documentIdtoEnvelopeIdMap.get(cv_i.Id)
          ) &&
          envelopIdToSignedDateMap.containsKey(
            documentIdtoEnvelopeIdMap.get(cv_i.Id)
          ) != null
        ) {
          cv_i.Signature_date__c = envelopIdToSignedDateMap.get(
              documentIdtoEnvelopeIdMap.get(cv_i.Id)
            )
            .date();
        }
        cvToUpdateList.add(cv_i);
      }
    }
    update cvToUpdateList;
    return quoteIdsForUpdateToEnvelopeIdMap;
  }

  private static List<zqu__Quote__c> setQuoteContractStatusAsComplete(
    List<CvZuoraDataWrapper> cvZuoraDataWrapperList
  ) {
    List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
    Set<Id> quoteIdSet = new Set<Id>();
    for (CvZuoraDataWrapper czdw_i : cvZuoraDataWrapperList) {
      if (String.isNotBlank(czdw_i.quoteId)) {
        quoteIdSet.add(czdw_i.quoteId);
      }
    }
    List<zqu__Quote__c> quoteList = [
      SELECT Id, zqu_Quote_Status__c, Is_Contract_Signed_Manually__c
      FROM zqu__Quote__c
      WHERE
        Id IN :quoteIdSet
        AND (((NOT RecordType.Name LIKE '%ReadOnly%')
        AND (zqu_Quote_Status__c = 'Terms approved'
        OR zqu_Quote_Status__c = 'New Amendment'))
        OR zqu_Quote_Status__c = 'Approved By Billing')
    ];
    for (zqu__Quote__c quote_i : quoteList) {
      quote_i.zqu_Quote_Status__c = 'Contract Signed';
      quote_i.Is_Contract_Signed_Manually__c = false;
      quoteToUpdateList.add(quote_i);
    }
    return quoteToUpdateList;
  }

  private static List<zqu__Quote__c> setQuoteDateAsSignedDate(
    Map<Id, String> quoteIdsForUpdateToEnvelopeIdMap,
    Map<String, Datetime> envelopIdToSignedDateMap
  ) {
    Set<String> envelopeIdSet = new Set<String>();
    List<zqu__Quote__c> quoteToUpdateList = [
      SELECT Id, zqu__SubscriptionType__c, MultiSubscription__c
      FROM zqu__Quote__c
      WHERE
        Id IN :quoteIdsForUpdateToEnvelopeIdMap.keySet()
        AND Contract_Start_Upon__c = 'Signature Date'
        AND (NOT RecordType.Name LIKE '%ReadOnly%')
    ];
    System.debug(JSON.serializePretty(envelopIdToSignedDateMap));
    for (zqu__Quote__c quoteToUpdate : quoteToUpdateList) {
      String envelopeId = (quoteIdsForUpdateToEnvelopeIdMap.get(
          quoteToUpdate.Id
        ))
        .toLowerCase();
      System.debug(JSON.serializePretty(envelopeId));
      if (envelopIdToSignedDateMap.containsKey(envelopeId)) {
        Datetime signedDate = envelopIdToSignedDateMap.get(envelopeId);
        quoteToUpdate.zqu__Customer_Acceptance_Date__c = signedDate.date();
        quoteToUpdate.zqu__Service_Activation_Date__c = signedDate.date();
        quoteToUpdate.zqu__StartDate__c = signedDate.date();
        if (
          quoteToUpdate.zqu__SubscriptionType__c != 'Amend Subscription' &&
          !quoteToUpdate.MultiSubscription__c
        ) {
          quoteToUpdate.zqu__TermStartDate__c = signedDate.date();
        }
      }
    }
    System.debug(JSON.serializePretty(quoteToUpdateList));
    return quoteToUpdateList;
  }

  private static void attachDocuSignStatusToZuoraQuote(
    List<CvZuoraDataWrapper> cvZuoraDataWrapperList,
    Map<String, dsfs__DocuSign_Status__c> envelopIdMap
  ) {
    for (CvZuoraDataWrapper cvzdw_i : cvZuoraDataWrapperList) {
      if (
        String.isNotBlank(cvzdw_i.envelopeId) &&
        envelopIdMap.containsKey(cvzdw_i.envelopeId)
      ) {
        dsfs__DocuSign_Status__c dsStatus = envelopIdMap.get(
          cvzdw_i.envelopeId
        );
        if (String.isNotBlank(cvzdw_i.quoteId)) {
          dsStatus.Zuora_Quote__c = cvzdw_i.quoteId;
        }
        if (String.isNotBlank(cvzdw_i.oppId)) {
          dsStatus.dsfs__Opportunity__c = cvzdw_i.oppId;
        }
      }
    }
  }

  public static void setDocuSignStatusToOpportunity(
    List<dsfs__DocuSign_Recipient_Status__c> newRecords
  ) {
    Set<Id> docuSignStatusesIds = new Set<Id>();
    for (dsfs__DocuSign_Recipient_Status__c recStatus_i : newRecords) {
      docuSignStatusesIds.add(recStatus_i.dsfs__Parent_Status_Record__c);
    }
    List<dsfs__DocuSign_Status__c> docuSignStatuses = [
      SELECT
        Id,
        dsfs__Opportunity__c,
        Zuora_Quote__c,
        Zuora_Quote__r.zqu__Opportunity__c
      FROM dsfs__DocuSign_Status__c
      WHERE Id IN :docuSignStatusesIds
    ];
    for (dsfs__DocuSign_Status__c docuSStatus_i : docuSignStatuses) {
      docuSStatus_i.dsfs__Opportunity__c = docuSStatus_i.Zuora_Quote__r.zqu__Opportunity__c;
    }

    if (!docuSignStatuses.isEmpty()) {
      update docuSignStatuses;
    }
  }

  /* private static List<ContentDocumentLink> attachSignedDocumentToCvZuoraData(List <CvZuoraDataWrapper> cvZuoraDataWrapperList
                                                                             , Map<String,Id> envelopIdMap)
    {
        List<ContentDocumentLink> signedContractCdlList = new List<ContentDocumentLink>();
        List<ContentDocumentLink> cdlToInsert= new List<ContentDocumentLink>();
        Set<Id> docuSignStatusIdSet = new Set<Id>();
        System.debug('cvZuoraDataWrapperList ' + JSON.serializePretty( + cvZuoraDataWrapperList));
        
        for (CvZuoraDataWrapper cvzdw_i : cvZuoraDataWrapperList) {
            if (String.isNotBlank(cvzdw_i.envelopeId) && envelopIdMap.containsKey(cvzdw_i.envelopeId)) {
                docuSignStatusIdSet.add(envelopIdMap.get(cvzdw_i.envelopeId));
            }
        }
        if (!docuSignStatusIdSet.isEmpty()) {
            signedContractCdlList = [SELECT Id
                                        , LinkedEntityId
                                        , ContentDocumentId 
                                        , ShareType
                                        , Visibility
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId IN :docuSignStatusIdSet
        ];
        }
        System.debug('signedContractCdlList ' + JSON.serializePretty(signedContractCdlList));
        Map<Id,ContentDocumentLink> cdlMap = new Map<Id,ContentDocumentLink>();
        for (ContentDocumentLink cdl_i : signedContractCdlList) {
            cdlMap.put(cdl_i.LinkedEntityId,cdl_i);
        }
        for (CvZuoraDataWrapper cvzdw_i : cvZuoraDataWrapperList) {
            if (String.isNotBlank(cvzdw_i.envelopeId) && envelopIdMap.containsKey(cvzdw_i.envelopeId)) {
                if (cdlMap.containsKey(envelopIdMap.get(cvzdw_i.envelopeId))) {
                    ContentDocumentLink cdl = cdlMap.get(envelopIdMap.get(cvzdw_i.envelopeId));
                    if (String.isNotBlank(cvzdw_i.quoteId)) {
                        ContentDocumentLink cdlQuote = cdl.clone(false,true);
                        cdlQuote.LinkedEntityId = cvzdw_i.quoteId;
                        cdlToInsert.add(cdlQuote);
                    }
                }
            }
        }
        return cdlToInsert;
    } */

  private class CvZuoraDataWrapper {
    public Id quoteId;
    public Id oppId;
    public String envelopeId;
  }
}

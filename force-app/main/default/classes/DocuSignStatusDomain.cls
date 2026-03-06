public with sharing class DocuSignStatusDomain extends GenericDomain {

    public static final String DOCUSIGN_SIGNED_STATUS = 'Completed';

    public DocuSignStatusDomain(List<SObject> newRecords){
        super(newRecords);
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        Map<String,dsfs__DocuSign_Status__c> envelopIdMap = new Map<String,dsfs__DocuSign_Status__c>();
        for (dsfs__DocuSign_Status__c status_i : (List<dsfs__DocuSign_Status__c>)newRecords) {
            dsfs__DocuSign_Status__c oldStatus_i = (dsfs__DocuSign_Status__c)existingRecords.get(status_i.Id);

            if (status_i.dsfs__Envelope_Status__c == DOCUSIGN_SIGNED_STATUS
                && 
                oldStatus_i.dsfs__Envelope_Status__c != status_i.dsfs__Envelope_Status__c)
            {
                if (String.isNotBlank(status_i.dsfs__DocuSign_Envelope_ID__c)) {
                    envelopIdMap.put(status_i.dsfs__DocuSign_Envelope_ID__c.toLowerCase(),status_i);
                }
            }
        }
        System.debug('envelopIdMap ' + envelopIdMap);
        if (!envelopIdMap.isEmpty()) {
            DocuSignZuoraQuoteHelper.updateZuoraQuoteStatus(envelopIdMap);
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords) {

        Map<String,dsfs__DocuSign_Status__c> envelopIdMap = new Map<String,dsfs__DocuSign_Status__c>();
        for (dsfs__DocuSign_Status__c status_i : (List<dsfs__DocuSign_Status__c>)newRecords) {
            dsfs__DocuSign_Status__c oldStatus_i = (dsfs__DocuSign_Status__c)existingRecords.get(status_i.Id);

            if (status_i.dsfs__Envelope_Status__c == DOCUSIGN_SIGNED_STATUS
                && 
                oldStatus_i.dsfs__Envelope_Status__c != status_i.dsfs__Envelope_Status__c)
            {
                if (String.isNotBlank(status_i.dsfs__DocuSign_Envelope_ID__c)) {
                    envelopIdMap.put(status_i.dsfs__DocuSign_Envelope_ID__c.toLowerCase(),status_i);
                }
            }
        }
        System.debug('envelopIdMap ' + envelopIdMap);
        if (!envelopIdMap.isEmpty()) {
            DocuSignZuoraQuoteHelper.updateCompleteStatusOfRelatedQuote(envelopIdMap);
        }
        updatedRealtedQuotes((List<dsfs__DocuSign_Status__c>)newRecords);
    }

    public override void onBeforeInsert() {
        updatedRealtedQuotes((List<dsfs__DocuSign_Status__c>)newRecords);
    }

    public override void onAfterInsert() {
        Map<String,dsfs__DocuSign_Status__c> envelopIdMap = new Map<String,dsfs__DocuSign_Status__c>();
        for (dsfs__DocuSign_Status__c status_i : (List<dsfs__DocuSign_Status__c>)newRecords) {
            if (status_i.dsfs__Envelope_Status__c == DOCUSIGN_SIGNED_STATUS)
            {
                if (String.isNotBlank(status_i.dsfs__DocuSign_Envelope_ID__c))
                {
                    envelopIdMap.put(status_i.dsfs__DocuSign_Envelope_ID__c.toLowerCase(),status_i);
                }
            }
        }
        if (!envelopIdMap.isEmpty()) {
            DocuSignZuoraQuoteHelper.updateCompleteStatusOfRelatedQuote(envelopIdMap);
        }

        updatedRealtedQuotes((List<dsfs__DocuSign_Status__c>)newRecords);
    }

    private void updatedRealtedQuotes(List<dsfs__DocuSign_Status__c> newDocusignStatusList){
        List<zqu__Quote__c> quoteToUpdateList = new List<zqu__Quote__c>();
         for(dsfs__DocuSign_Status__c docuStatus: newDocusignStatusList){
            if(String.isNotBlank(docuStatus.Zuora_Quote__c)){
                zqu__Quote__c quoteToUpdate = new zqu__Quote__c();
                quoteToUpdate.Id = docuStatus.Zuora_Quote__c;
                quoteToUpdate.Send_To_DocuSign_Flow__c = false;
                quoteToUpdateList.add(quoteToUpdate);
            }
         }

         if(!quoteToUpdateList.isEmpty()){
            update quoteToUpdateList;
         }
    }

    public class Constructor implements GenericDomain.IConstructable
	{
		public GenericDomain constructDomainInstance(List<SObject> sObjectList)
		{
			return new DocuSignStatusDomain(sObjectList);
		}
	}

}
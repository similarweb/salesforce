/**
 * @author Itzik Winograd
 * @date 02/10/2022
 * @description MIS-3023: On the Proposal__c object, check/uncheck the field Proposal_added__c when attachment added/deleted.
 */
public without sharing class ProposalAttachmentProcess implements IProcessHandler{
    List<Log_Event__e> logEvents = new List<Log_Event__e>();


    /**
     * @author Itzik Winograd
     * @date 02/10/2022
     * @description Main handler
     * @param List<Sobject>Trigger.new
     * @param Map<Id,SObject>
     */
    public void handle(List<SObject> cdLinksList, Map<Id,SObject> cdLinksByIdsMap){
        if(GeneralUtil.determineEventTime()=='after' && GeneralUtil.determineEventType()=='insert'){ //if(cdLinksList != null){//insert
            handleInsert(cdLinksList);
        } else if(GeneralUtil.determineEventTime()=='before' && GeneralUtil.determineEventType()=='delete'){ //delete
            handleDelete(cdLinksByIdsMap);
        }
        if(!logEvents.isEmpty()){
            EventBus.publish(logEvents);
        }
    }

    /**
     * @author Itzik Winograd
     * @date 02/10/2022
     * @description handle insert - check if the linkedEntityId has the prefix of the proposal and update the proposal
     * @param List<ContentDocumentLink>cdLinksList
     */
    public void handleInsert(List<ContentDocumentLink> cdLinksList){
        System.debug('### ProposalAttachmentProcess - insert');
        String proposalPrefix = GeneralUtil.getSObjectPrefixByName('Proposal__c');
        List<Proposal__c> proposalsToUpdate = new List<Proposal__c>();
        Set<Id> proposalIdsSet = new Set<Id>();
        for(ContentDocumentLink cdl : cdLinksList) {
            if(((String)cdl.LinkedEntityId).startsWithIgnoreCase(proposalPrefix)){
                if(!proposalIdsSet.contains((Id)cdl.LinkedEntityId)){
                    proposalIdsSet.add(cdl.LinkedEntityId);
                    proposalsToUpdate.add(createProposal(cdl.LinkedEntityId,true));
                }
            }
        }
        updateProposals(proposalsToUpdate);
    }

    /**
     * @author Itzik Winograd
     * @date 02/10/2022
     * @description handle insert - check if the linkedEntityId has the prefix of the proposal and update the proposal
     * @param List<ContentDocumentLink>cdLinksList
     */
    public void handleDelete(Map<Id,SObject> cdLinksMap){
        Id cdlId = (Id)(cdLinksMap.values()[0].Id);
        String objectName = cdlId.getSObjectType().getDescribe().getName();
        System.debug('### ProposalAttachmentProcess - delete - ' + objectName);
        //This method could be triggered both by ContentDocument and ContentDocumentLink, so this is a query to always work with CDLinks
        if(!cdLinksMap.values().isEmpty() && objectName == 'ContentDocument'){
            cdLinksMap = new Map<Id,ContentDocumentLink>([
                    SELECT Id, LinkedEntityId, ContentDocumentId
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId IN: cdLinksMap.keySet()
            ]);
        }
        String proposalPrefix = GeneralUtil.getSObjectPrefixByName('Proposal__c');
        List<Proposal__c> proposalsToUpdate = new List<Proposal__c>();
        List<Id> proposalsIds = new List<Id>();
        for(ContentDocumentLink cdl : (List<ContentDocumentLink>)cdLinksMap.values()) { //Collect the ids of Proposal's attachments
            if(((String)cdl.LinkedEntityId).startsWithIgnoreCase(proposalPrefix)){
                proposalsIds.add(cdl.LinkedEntityId);
            }
        }
        System.debug('### ProposalAttachmentProcess - proposalsIds: ' + proposalsIds);
        List<Proposal__c> existingProposalsAndLinks = [ //get the Proposal and their attachments
                SELECT Id, Proposal_added__c,
                (SELECT Id
                FROM ContentDocumentLinks
                WHERE Id NOT IN: cdLinksMap.keySet())
                FROM Proposal__c
                WHERE Id IN :proposalsIds
                AND Proposal_added__c = true
                ORDER BY Id DESC
        ];
        System.debug('### ProposalAttachmentProcess - existingProposalsAndLinks: ' + existingProposalsAndLinks);
        for(Proposal__c proposal : existingProposalsAndLinks){ //set false only if the Proposal has no attachments
            System.debug('### ProposalAttachmentProcess - existingProposalsAndLinks.proposal.ContentDocumentLinks: ' + proposal.ContentDocumentLinks);
            if(proposal.ContentDocumentLinks.size()==0){
                proposalsToUpdate.add(createProposal(proposal.Id,false));
            }
        }
        System.debug('### ProposalAttachmentProcess - proposalsToUpdate: ' + proposalsToUpdate);

        updateProposals(proposalsToUpdate);
    }

    /**
     * @author Itzik Winograd
     * @date 02/10/2022
     * @description Updates a list of Proposal__c
     * @param List<Proposal__c> proposalsToUpdate
     */
    public void updateProposals(List<Proposal__c> proposalsToUpdate){
        if(!proposalsToUpdate.isEmpty()){
            System.debug('### ProposalAttachmentProcess - updateProposals: ' + proposalsToUpdate);
            List<Database.SaveResult> proposalSR = Database.update(proposalsToUpdate,false);
            for (Integer i = 0; i < proposalSR.size(); i++) {
                Database.SaveResult result = proposalSR[i];
                if (!result.isSuccess()) {
                    logEvents.add(LogEventUtils.createLogEventRecord(new List<Id>{proposalsToUpdate[i].Id}, 'ProposalAttachmentProcess', 'updateProposals',
                            '', result.getErrors().toString(), 'Error',null,null));
                }
            }
        }
    }

    /**
     * @author Itzik Winograd
     * @date 02/10/2022
     * @description return a new proposal with true/false on the Proposal_added__c
     * @param String Id id of the proposal
     * @param Boolean for the Proposal_added__c field
     */
    public Proposal__c createProposal(String proposalId, Boolean bool) {
        return new Proposal__c(
                Id = proposalId,
                Proposal_added__c = bool
        );
    }


}
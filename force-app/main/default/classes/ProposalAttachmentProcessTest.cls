/**
 * Created by itzik.winograd on 03/10/2022.
 */
/**
 * @author Itzik Winograd
 * @date 03/10/2022
 * @description MIS-3023: Test for ProposalAttachmentProcess class
 */
@isTest
public with sharing class ProposalAttachmentProcessTest {
    /**
     * @author Itzik Winograd
     * @date 03/10/2022
     * @description create Proposals
     */
    @TestSetup
    public static void createProposals(){
        Account acc = AccountUtils.getAccounts(1)[0];
        insert acc;

        Opportunity opp = TestDataFactory.createOpportunity(acc);
        insert opp;

        List<Proposal__c> proposals = new List<Proposal__c>();
        proposals.add(new Proposal__c(Opportunity__c = opp.Id));
        proposals.add(new Proposal__c(Opportunity__c = opp.Id));
        insert proposals;
    }

    /**
     * @author Itzik Winograd
     * @date 03/10/2022
     * @description Add attachments to proposals
     * @expected the proposal's Proposal__Added__c will be true
     */
    @IsTest
    public static void insertAttachmentsToProposalsTest(){
        List<Proposal__c> proposals = [SELECT Id, Proposal_added__c FROM Proposal__c WHERE Proposal_added__c = false];
        Test.startTest();
            for(Proposal__c proposal : proposals){
                if(proposal.Proposal_added__c == false){
                    createAttachment(Proposal.Id);
                }
            }
        Test.stopTest();

        proposals = [SELECT Id, Proposal_added__c FROM Proposal__c WHERE Id IN :proposals];
        for(Proposal__c proposal : proposals){
            System.assert(proposal.Proposal_added__c == true, 'Error: Proposal_added__c should be true!');
        }
    }

    /**
     * @author Itzik Winograd
     * @date 03/10/2022
     * @description Delete all the contentDocuments
     * @expected the proposal's Proposal__Added__c will be false since there are no attachments
     */
    @IsTest
    public static void DeleteAttachmentsFromProposalsTest(){
        List<Proposal__c> proposals = [SELECT Id, Proposal_added__c FROM Proposal__c];
        for(Proposal__c proposal : proposals){
            createAttachment(Proposal.Id);
        }

        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument];
        Test.startTest();
            delete contentDocuments;
        Test.stopTest();

        proposals = [SELECT Id, Proposal_added__c FROM Proposal__c WHERE Proposal_added__c = false];
        for(Proposal__c proposal : proposals){
            System.assert(proposal.Proposal_added__c == false, 'Error: Proposal_added__c should be true!');
        }
    }

    /**
     * @author Itzik Winograd
     * @date 03/10/2022
     * @description Delete all the contentDocumentsLinks - its simulating a click on "remove from record" on the attachments list
     * @expected the proposal's Proposal__Added__c will be false since there are no attachments
     */
    @IsTest
    public static void DeleteFilesLinkOnProposalsTest(){
        Map<Id,Proposal__c> proposalsMap = new Map<Id,Proposal__c>([SELECT Id, Proposal_added__c FROM Proposal__c]);
        for(Proposal__c proposal : proposalsMap.values()){
            createAttachment(Proposal.Id);
        }

        List<ContentDocumentLink> contentDocumentLinks = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId IN :proposalsMap.keySet()];
        Test.startTest();
            delete contentDocumentLinks;
        Test.stopTest();
        proposalsMap = new Map<Id,Proposal__c>([SELECT Id, Proposal_added__c FROM Proposal__c]);
        for(Proposal__c proposal : proposalsMap.values()){
            System.assert(proposal.Proposal_added__c == false, 'Error: Proposal_added__c should be true!');
        }
    }

    /**
     * @author Itzik Winograd
     * @date 03/10/2022
     * @description create an attachment for a given Id
     * @param Id linkedEntityId - id to link the new attachment to
     * @return none
     */
    public static void createAttachment(Id linkedEntityId) {
        ContentVersion content = new ContentVersion();
        content.Title = 'Header_Picture1';
        content.PathOnClient = '/' + content.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData = bodyBlob;
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentLink = new ContentDocumentLink();
        contentLink.LinkedEntityId = linkedEntityId;
        contentLink.contentDocumentId = [SELECT contentDocumentId FROM ContentVersion WHERE Id = :content.Id].contentDocumentId;
        contentLink.ShareType = 'V';
        insert contentLink;
    }

}
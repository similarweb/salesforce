/**
 * @author Itzik Winograd
 * @date 02/10/2022
 * @description ContentDocumentLinkTrigger
 */
trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before insert, before delete) {
    GenericDomain.triggerHandler(ContentDocumentLinkDomain.class);
    TriggerProcessingManager.handle('ContentDocumentLink');
}
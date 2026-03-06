/**
 * @author Itzik Winograd
 * @date 02/10/2022
 * @description ContentDocumentTrigger
 */

trigger ContentDocumentTrigger on ContentDocument(before delete) {
  TriggerProcessingManager.handle('ContentDocument');
}

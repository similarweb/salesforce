({
  onInit: function (component, event, helper) {
    helper.obtainFilesFromRelatedOpp(component, helper);
  },

  onFileItemClick: function (component, event, helper) {
    helper.fileItemClickHandler(component, event);
  },

  onViewAllClick: function (component, event, helper) {
    helper.viewAllClickHandler(component, event);
  },

  handleApplicationRefreshFired: function (component, event, helper) {
    helper.obtainFilesFromRelatedOpp(component, helper);
  },

  sendToDocuSign: function (component, event, helper) {
    helper.sendToDocuSign(component, event, helper);
  },
  uploadButton: function (component, event, helper) {
    helper.uploadFile(component, event, helper);
  },

  /*
   *   Author: Synebo Developer
   *   Last modified: 09/02/2022
   *   Description: MQ-1192. Logic for pressing the "Delete" or "Edit" buttons in the file drop-down menu. Creates a modal window
   */
  onMenuItemSelect: function (component, event, helper) {
    var selectedMenuItemValue = event.getParam("value");
    if (selectedMenuItemValue.includes("delete")) {
      var index = selectedMenuItemValue.split("_")[1];
      component.set("v.indexToDelete", index);
      component.set("v.isDeleteModal", true);
    } else if (selectedMenuItemValue.includes("edit")) {
      var index = selectedMenuItemValue.split("_")[1];
      var fileItem = component.get("{!v.opportunityAttachments}")[index];
      component.set("v.indexToEdit", index);
      component.set("v.isEditModal", true);
      component.set("v.titleText", fileItem.title);
      component.set("v.createdDate", fileItem.createdDate);
      component.set("v.lastModDate", fileItem.lastModifiedDate);
      component.set("v.descriptionText", fileItem.description);
    }
  },

  /*
   *   Author: Synebo Developer
   *   Last modified: 09/02/2022
   *   Description: MQ-1192. Close all modal windows.
   */
  closeModal: function (component, event, helper) {
    component.set("v.isDeleteModal", false);
    component.set("v.isEditModal", false);
  },

  /*
   *   Author: Synebo Developer
   *   Last Modified: 09/02/2022
   *   Description: MQ-1192. Method for deleting a file.
   */
  onDeleteRecord: function (component, event, helper) {
    var index = component.get("{!v.indexToDelete}");
    if (index != undefined && index.length > 0) {
      helper.deleteRecord(component, helper, index);
    }
    component.set("v.isDeleteModal", false);
  },

  /*
   *   Author: Synebo Developer
   *   Created Date: 09/02/2022
   *   Description: MQ-1192. Method for editing a file.
   */
  onEditRecord: function (component, event, helper) {
    var index = component.get("{!v.indexToEdit}");
    if (index != undefined && index.length > 0) {
      helper.editRecord(component, helper, index);
    }
    component.set("v.isEditModal", false);
  }
});

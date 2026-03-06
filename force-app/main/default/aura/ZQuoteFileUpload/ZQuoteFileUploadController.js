({
  onCloseButtonClick: function (component, event, helper) {
    helper.closeModal(component, event, helper);
  },
  onUploadButtonClick: function (component, event, helper) {
    helper.handleProcessUpload(component, helper);
  },
  onUploadFinished: function (component, event, helper) {
    helper.handleUploadFinished(component, event, helper);
  },
  onInit: function (component, event, helper) {
    // let recordId = component.get('v.quoteId');
    // let prefix = recordId.substring(0, 3);
    // let startingDefault = prefix == '500' ? 'false' : 'true';
    // let textRequired = startingDefault == 'true';
    // component.find("isFinSelect").set("v.value", startingDefault);
    // component.set("v.isTextAreaRequired",textRequired);
    // helper.initialize(component, event, helper,textRequired);
    component.find("isFinSelect").set("v.value", "false");
    helper.initialize(component, event, helper);
    // component.set("v.isFinalContract", false);
  },
  handleTextAreaChange: function (component, event, helper) {
    var longTextValue = component.get("v.longTextValue");
    component.set("v.isTextAreaFilled", !!longTextValue); // Convert to boolean
  }
});

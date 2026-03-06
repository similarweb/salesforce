({
  handleWorldListValueSelectedEvent: function (component, event, helper) {
    component.set("v.fullName", event.getParam("fullName"));
    component.set("v.label", event.getParam("label"));
  },

  clearFullName: function (component, event) {
    component.set("v.fullName", "");
  },

  onDeleteClick: function (component, event, helper) {
    helper.deleteWordListValue(component, helper);
  }
});

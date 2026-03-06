({
  handleBaseProductValueSelectedEvent: function (component, event, helper) {
    helper.obtainWordPicklistValuesForBaseProduct(component, event);
  },

  onDeleteClick: function (component, event, helper) {
    helper.deleteBaseProductValue(component, helper);
  },

  onEditClick: function (component, event, helper) {
    component.set("v.shownEditValueModal", true);
  }
});

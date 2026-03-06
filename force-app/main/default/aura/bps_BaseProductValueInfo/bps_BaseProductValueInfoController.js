({
  handleBaseProductValueSelectedEvent: function (component, event, helper) {
    helper.obtainWordPicklistValuesForBaseProduct(component, event);
    helper.obtainDefaultAddonsForBaseProduct(component);
    helper.obtainDynamicAddonsForBaseProduct(component);
    helper.obtainNumOfUsers(component);
    helper.obtainBaseProductsRestrictOptions(component);
  },

  onDeleteClick: function (component, event, helper) {
    helper.deleteBaseProductValue(component, helper);
  },

  onEditClick: function (component, event, helper) {
    component.set("v.shownEditValueModal", true);
  }
});

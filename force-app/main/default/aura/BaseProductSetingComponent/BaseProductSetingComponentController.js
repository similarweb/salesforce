({
  doInit: function (component, event, helper) {
    helper.obtainBaseProductPicklistValues(component);
  },

  onEditBaseProductClick: function (component, event, helper) {
    component.set("v.shownBaseProductContractModal", true);
  }
});

({
  onBaseProductSelection: function (component, event, helper) {
    component.set("v.baseProductFullName", event.currentTarget.dataset.value);
    component.set("v.baseProductLabel", event.currentTarget.dataset.label);
    component.set(
      "v.highlitedIndx",
      parseInt(event.currentTarget.dataset.index)
    );
    var baseProductValueSelectedEvent = $A.get("e.c:BaseProductValueSelected");
    baseProductValueSelectedEvent.setParams({
      fullName: event.currentTarget.dataset.value,
      label: event.currentTarget.dataset.label
    });
    baseProductValueSelectedEvent.fire();
  },

  onAddValuesClick: function (component, event, helper) {
    component.set("v.shownAddValuesModal", true);
  },

  onDeleteClick: function (component, event, helper) {
    helper.deleteBaseProductValue(component, helper);
  },

  onEditClick: function (component, event, helper) {
    component.set("v.shownEditValueModal", true);
  }
});

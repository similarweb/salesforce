({
  onWorldListValueSelection: function (component, event, helper) {
    component.set(
      "v.highlitedIndx",
      parseInt(event.currentTarget.dataset.index)
    );
    var worldPicklSelectedEvent = $A.get("e.c:bps_WordListValueSelected");
    worldPicklSelectedEvent.setParams({
      fullName: event.currentTarget.dataset.value,
      label: event.currentTarget.dataset.label
    });
    worldPicklSelectedEvent.fire();
  },

  onAddValuesClick: function (component, event, helper) {
    component.set("v.shownWordListDualModal", true);
  }
});

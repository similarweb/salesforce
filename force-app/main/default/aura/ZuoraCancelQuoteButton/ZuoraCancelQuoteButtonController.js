({
  onButtonClick: function (component, event, helper) {
    helper.showModalPopupOptions(
      component,
      "Quote Cancellation",
      "You are requesting to cancel the quote. This action will lock the quote from any change.",
      [{ title: "Approve", action: component.get("c.onApproveBtnClick") }]
    );
  },

  onApproveBtnClick: function (component, event, helper) {
    helper.cancellQuoteAction(component, helper);
  }
});

({
  onInit: function (component, event, helper) {
    helper.obtainRequestsFromRelatedOpp(component, helper);
  },

  onRequestItemClick: function (component, event, helper) {
    helper.requestItemClickHandler(component, event);
  },

  onViewAllClick: function (component, event, helper) {
    helper.viewAllClickHandler(component, event);
  },

  handleApplicationRefreshFired: function (component, event, helper) {
    helper.obtainRequestsFromRelatedOpp(component, helper);
  },

  openModal: function (component, event, helper) {
    component.set("v.isModalOpen", true);
  },

  closeModal: function (component, event, helper) {
    component.set("v.isModalOpen", false);
  }
});

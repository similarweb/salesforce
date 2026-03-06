({
  setLoading: function (component, isLoading) {
    component.set("v.isLoading", isLoading);
  },

  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    var params = {
      title: title,
      type: type,
      duration: 10000
    };
    if (message) {
      params.message = message;
    }
    toastEvent.setParams(params);
    toastEvent.fire();
  },

  showModalPopup: function (component, title, message) {
    var modalWindowData = {};
    modalWindowData.title = title;
    modalWindowData.message = message;
    modalWindowData.isComment = false;
    modalWindowData.isHint = false;
    component.set("v.modalWindowData", modalWindowData);
    component.set("v.isModalOpen", true);
  },

  showModalPopupWithHint: function (component, title, message, hint) {
    var modalWindowData = {};
    modalWindowData.title = title;
    modalWindowData.message = message;
    modalWindowData.isHint = true;
    modalWindowData.hint = hint;
    modalWindowData.isComment = false;
    component.set("v.modalWindowData", modalWindowData);
    component.set("v.isModalOpen", true);
  },

  showModalPopupComment: function (component, title) {
    var modalWindowData = {};
    modalWindowData.title = title;
    modalWindowData.isComment = false;
    modalWindowData.isHint = true;
    component.set("v.modalWindowData", modalWindowData);
    component.set("v.isModalOpen", true);
  },

  showModalPopupOptions: function (component, title, message, buttonArray) {
    var modalWindowData = {};
    modalWindowData.title = title;
    modalWindowData.isCustom = true;
    modalWindowData.message = message;
    modalWindowData.buttonArray = buttonArray;
    modalWindowData.isHint = false;
    component.set("v.modalWindowData", modalWindowData);
    component.set("v.isModalOpen", true);
  },

  showModalPopupLoading: function (component, title, isLoading) {
    var modalWindowData = {};
    modalWindowData.title = title;
    modalWindowData.isComment = false;
    modalWindowData.isHint = false;
    component.set("v.isLoading", isLoading);
    component.set("v.modalWindowData", modalWindowData);
    component.set("v.isModalOpen", isLoading);
  },

  validateEmail: function (email) {
    const re =
      /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
  }
});

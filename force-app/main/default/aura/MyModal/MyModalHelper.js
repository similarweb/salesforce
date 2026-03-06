/**
 * Created by Alon.Shalev on 8/7/2023.
 */

({
  closeModal: function (component, event, helper) {
    component.set("v.isOpen", false);
    component.set("v.recordId", null);
    if (typeof component.get("v.onClose") === "function") {
      component.get("v.onClose")();
    }
    // window.parent.postMessage('reloadVFPage', '*');
  }
});

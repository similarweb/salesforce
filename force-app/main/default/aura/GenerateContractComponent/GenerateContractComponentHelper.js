({
  generatePreviewContract: function (component, helper) {
    var date1 = new Date();
    component.set("v.isLoading", true);
    var action = component.get("c.generatePreviewContract");
    action.setParams({
      quoteId: component.get("v.recordId"),
      isValidate: true
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          component.set("v.isLoading", true);
          component.set("v.zuoraFileUrl", responseObj.content);
          helper.checkIfContractGeneratedAndSaveInSf(component, helper, date1);
        } else {
          helper.showToast("error", "Error!", responseObj.message);
          $A.get("e.force:closeQuickAction").fire();
        }
      } else {
        $A.get("e.force:closeQuickAction").fire();
      }
    });
    //$A.enqueueAction(action);
  },
  checkIfContractGeneratedAndSaveInSf: function (component, helper, date1) {
    component.set("v.isLoading", true);
    var action = component.get("c.obtainAndSaveContract");
    action.setParams({
      quoteId: component.get("v.recordId"),
      fileUrl: component.get("v.zuoraFileUrl"),
      modeRaw: "saving"
    });
    action.setCallback(this, function (response) {
      component.set("v.isLoading", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseObj = response.getReturnValue();
        if (responseObj.success) {
          component.set("v.salesforceFileId", responseObj.message);
          var date2 = new Date();
          console.log(diff_seconds(date2, date1));
          setTimeout(
            $A.getCallback(function () {
              $A.get("e.lightning:openFiles").fire({
                recordIds: [responseObj.message]
              });
            }),
            1000
          );
          var refreshEvent = $A.get("e.c:ApplicationRefresgEvent");
          refreshEvent.fire();
          //window.open(responseObj.message);
          function diff_seconds(dt2, dt1) {
            debugger;
            var diff = (dt2.getTime() - dt1.getTime()) / 1000;
            return Math.abs(Math.round(diff));
          }
        } else {
          helper.showToast("error", "Error!", responseObj.message);
        }
      } else {
      }
      $A.get("e.force:closeQuickAction").fire();
    });
    $A.enqueueAction(action);
  },
  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    var params = {
      title: title,
      type: type
    };
    if (message) {
      params.message = message;
    }
    toastEvent.setParams(params);
    toastEvent.fire();
  }
});

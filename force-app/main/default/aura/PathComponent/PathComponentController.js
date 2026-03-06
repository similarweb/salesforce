({
  doInit: function (component, event, helper) {
    var pathMode = component.get("v.pathMode");
    if (pathMode == 1) {
      helper.obtainAttributes(component, event);
      if (component.get("v.journeyName") != null) {
        var interval = window.setInterval(
          $A.getCallback(function () {
            helper.obtainAttributes(component, event);
            debugger;
          }),
          60000
        );
        component.set("v.intervalId", interval);
      }
    } else if (pathMode == 2) {
      helper.obtainAttributesForLeadSearch(component, event);
    }
  },
  journeyNameChange: function (component, event, helper) {
    var pathMode = component.get("v.pathMode");
    if (pathMode == 1) {
      helper.obtainAttributes(component, event);
    } else if (pathMode == 2) {
      helper.obtainAttributesForLeadSearch(component, event);
    }
  },
  refreshClick: function (component, event, helper) {
    var pathMode = component.get("v.pathMode");
    if (pathMode == 1) {
      helper.obtainAttributes(component, event);
    } else if (pathMode == 2) {
      helper.obtainAttributesForLeadSearch(component, event);
    }
  },
  searchParamChange: function (component, event, helper) {
    helper.obtainAttributesForLeadSearch(component, event);
  },
  fieldParamChange: function (component, event, helper) {
    helper.obtainAttributesForLeadSearch(component, event);
  },
  handleDestroy: function (component, event, helper) {
    window.clearInterval(component.get("v.intervalId"));
  },
  handleJourneyPathSettingChanged: function (component, event, helper) {
    var pathMode = component.get("v.pathMode");
    if (pathMode == 1) {
      helper.obtainAttributes(component, event);
    } else if (pathMode == 2) {
      helper.obtainAttributesForLeadSearch(component, event);
    }
  }
});

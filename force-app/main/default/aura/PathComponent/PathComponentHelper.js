({
  obtainAttributes: function (component, event) {
    var action = component.get("c.obtainPathAtributes");
    action.setParams({ journeyName: component.get("v.journeyName") });

    component.set("v.loaded", !component.get("v.loaded"));
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());

        if (responseJson.success) {
          var data = responseJson.data;
          console.log(data);
          var steps = data.steps;
          component.set("v.isStepInfoVisible", true);
          component.set("v.steps", steps);
          debugger;
          component.set("v.recordsInTheJourney", data.recordsInTheJourney);
          component.set(
            "v.averageJourneyTimeLastThreeHours",
            data.averageJourneyTimeLastThreeHours
          );
          component.set(
            "v.recordBrichingSLA",
            data.completedRecordsInTheJourney
          );
          var journeyInfoEvent = component.getEvent("JourneyInfoEvent");
          journeyInfoEvent.setParams({
            recordsInTheJourney: data.recordsInTheJourney,
            averageJourneyTimeLastThreeHours:
              data.averageJourneyTimeLastThreeHours,
            recordBrichingSLA: data.completedRecordsInTheJourney
          });
          journeyInfoEvent.fire();
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  obtainAttributesForLeadSearch: function (component, event) {
    var inputValue = component.get("v.searchParam");
    var selectValue = component.get("v.fieldParam");
    var action = component.get("c.obtainLeadListByParam");
    action.setParams({
      searchParam: inputValue,
      fieldParam: selectValue
    });
    component.set("v.loaded", !component.get("v.loaded"));
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          var data = responseJson.data;
          console.log(data);
          component.set("v.isStepInfoVisible", false);
          component.set(
            "v.averageJourneyTimeLastThreeHours",
            data.averageJourneyTimeLastThreeHours
          );
          component.set("v.recordBrichingSLA", data.recordBrichingSLA);
          //component.set("v.journeyName",data.journeyName);
          component.set("v.recordsInTheJourney", data.recordsInTheJourney);
          component.set("v.steps", data.steps);
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  }
});

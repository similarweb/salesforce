({
	obtainJourneyPathSettings : function(component,journeyName) {
		var action = component.get("c.obtainJourneyPathSettings");
        action.setParams({
            "journeyName": journeyName,
        });
        component.set('v.loaded', !component.get('v.loaded'));
        action.setCallback(this, function(response) {
            component.set('v.loaded', !component.get('v.loaded'));
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseJson = JSON.parse(response.getReturnValue());      
                if(responseJson.success){
                    var data = responseJson.data;
                    component.set('v.journeyPathSettingList',data);
                    this.sortData(component, 'Step_Order__c', 'asc');                    
                }
            } else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);		
	},
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.journeyPathSettingList");
        var reverse = sortDirection != 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.journeyPathSettingList", data);
        if(sortDirection == 'asc'){
            cmp.set("v.sortedDir", 'desc');
        } else {
           cmp.set("v.sortedDir", 'asc'); 
        } 
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    }
})
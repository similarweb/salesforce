({
    
    
    
    RemoteFindIDByPhoneT1: function (phone, callStatus, ivrid, callDirection, cmp) {
        //console.log(phone);
        //return;
        var action = cmp.get("c.FindObjectByPhone");
		action.setParams({ phoneNumber : phone });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state: ' + state);
            if (state === "SUCCESS") {
                // Alert the user with the value returned from the server
                //console.log("From server: " + response.getReturnValue())
                
                var coustomerResp = JSON.parse(response.getReturnValue());
                
                var notificationBar = cmp.find("outName");
                var coustomeDataView = "Incoming Call: ";
        		notificationBar.set("v.value", coustomeDataView);
        
        		var notificationBar = cmp.find("outName2");
                var coustomeDataView2 = coustomerResp.Name;
        		notificationBar.set("v.value", coustomeDataView2);
        
        		var notificationBar = cmp.find("outName3");
                var coustomeDataView3 = phone;
        		notificationBar.set("v.value", coustomeDataView3);
                
                
                
                
                
                
                
                //var notificationBar = cmp.find("outName");
                //var coustomeDataView = "<span class='call-type-title'>Incoming Call:</span> " + coustomerResp.Name;
        		//notificationBar.set("v.value", coustomeDataView);
                
                
                //Clear cash
               	window.localStorage.setItem('call-data', '{"vclightniingcalldata":""}');
                if(callStatus == "Talking"|| (callStatus == "Dialing" && callDirection == "Click2Call"))
                	this.RemoteCreateTaskFromClick2CallT1(response.getReturnValue(), ivrid, cmp);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    GetTaskByID: function (ivrid, ID, cmp) {
        console.log('ivrid', ivrid);
        console.log('ID', ID);
        var action = cmp.get("c.GetTaskDB");
        action.setParams({ paramID : ID});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state2: ' + state);
            if (cmp.isValid() && state === "SUCCESS") {
                // Alert the user with the value returned from the server2
                //console.log("From server2: " + response.getReturnValue());
                //var notificationBar = cmp.find("outName");
        		//notificationBar.set("v.value", response.getReturnValue());
        		cmp.set("v.tasks", response.getReturnValue());
        		
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    RemoteCreateTaskFromClick2CallT1: function (customerData, ivrid, cmp) {
        //console.log('ivrid', ivrid);
        var customerData = JSON.parse(customerData);
        //console.log(customerData);
        var action = cmp.get("c.CreateTaskFromClick2Call");
        action.setParams({ ivrUniqueID : ivrid, customerID : customerData.ID});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //console.log('state2: ' + state);
            if (state === "SUCCESS") {
                //console.log("From server2: " + response.getReturnValue());
        		var TaskResp = JSON.parse(response.getReturnValue());
                //console.log(TaskResp.InsertResult);
 
                if(typeof(TaskResp.InsertResult) != "string"){
                	var host = window.location.host;
                	window.open('https://'+ host +'/one/one.app#/sObject/'+ TaskResp.InsertResult.Id +'/view');
                }
        		//this.GetTaskByID(ivrid, TaskResp.InsertResult.Id, cmp); 
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})
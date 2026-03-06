({
	doInit : function(component, event, helper) {
        console.log('start doinit');
        component.set("v.emaildata", {});
        var action = component.get("c.getProspectId");
        action.setParams({recid : component.get("v.recordId"), sobjectname : component.get("v.sObjectName")});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                console.log(res);
                if(res!=null){
                    component.set("v.pardotid", res);
                    var nextaction = component.get("c.getparams");
                    $A.enqueueAction(nextaction);
                }
                else{
                    var nextaction = component.get("c.errorhandle");
                    $A.enqueueAction(nextaction);
                }
            }
            else{
                var nextaction = component.get("c.errorhandle");
                $A.enqueueAction(nextaction);
            }
        });
        $A.enqueueAction(action);
    },
    getparams : function(component, event, helper) {
        console.log('start params');
        var action = component.get("c.getParams");
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                console.log(res);
                if(res!=null){
                    component.set("v.params", res);
                    var nextaction = component.get("c.getvisitors");
                    $A.enqueueAction(nextaction);
                }
                else{
                    var nextaction = component.get("c.errorhandle");
                    $A.enqueueAction(nextaction);
                }
            }
            else{
                var nextaction = component.get("c.errorhandle");
                $A.enqueueAction(nextaction);
            }
        });
        $A.enqueueAction(action);
    },
    getvisitors : function(component, event, helper) {
        console.log("start getvisitors");
        var action = component.get("c.getVisitors");
        var parm = component.get("v.params");
        var pard = component.get("v.pardotid");
        action.setParams({recid : component.get("v.recordId"), prospectid : pard, params: parm});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                console.log(res);
                if(res!=null){
                    component.set("v.result", res);
                    console.log(res.visitor_activity);
                    if(res.visitor_activity!=null){
                        var showed = new Array();
                        for(var i=0;i<res.visitor_activity.length;i++)
                            if(res.visitor_activity[i].init)
                                showed.push(res.visitor_activity[i]);
                        component.set("v.showedvisitoractivities", showed);
                        if(res.visitor_activity.length==showed.length){
                            var load = component.find("myLoadMore");
                            $A.util.toggleClass(load, "slds-hide");
                        }
                        var nextaction = component.get("c.setsummary");
                        $A.enqueueAction(nextaction);
                    }
                    else{
                        var nextaction = component.get("c.errorhandle");
                        $A.enqueueAction(nextaction);
                    }
                }
                else{
                    var nextaction = component.get("c.errorhandle");
                    $A.enqueueAction(nextaction);
                }
            }
            else{
                var nextaction = component.get("c.errorhandle");
                $A.enqueueAction(nextaction);
            }
        });
        $A.enqueueAction(action);
    },
    setsummary : function(component, event, helper) {
        console.log("start setsummary");
        var action = component.get("c.setSummary");
        var myAttribute = component.get("v.result");
        console.log(JSON.stringify(myAttribute));
        action.setParams({vasstr : JSON.stringify(myAttribute)});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
                console.log(res);
                if(res!=null){
                    var sum = new Array();
                    for (var key in res){
                        sum.push({name: key, val: res[key]});
                    }
                    sum.sort(function(a, b){
                        var x = a.name.toLowerCase();
                        var y = b.name.toLowerCase();
                        if (x < y) {return -1;}
                        if (x > y) {return 1;}
                        return 0;
                    });
                    component.set("v.visitorsummary", sum);
                    console.log(sum);
                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                }
                else{
                    var nextaction = component.get("c.errorhandle");
                    $A.enqueueAction(nextaction);
                }
            }
            else{
                var nextaction = component.get("c.errorhandle");
                $A.enqueueAction(nextaction);
            }
            
        });
        $A.enqueueAction(action);
    },
    loadMore : function(component, event, helper) {
        console.log('start load more');
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
		var action = component.get("c.setInitMore");
        var myAttribute = component.get("v.result");
        var parm = component.get("v.params");
        action.setParams({vasstr : JSON.stringify(myAttribute), params: parm});
		action.setCallback(this, function(response){
			var state = response.getState();
			console.log(state);
			if(state === 'SUCCESS'){
				var res = response.getReturnValue();
                console.log(res);
                if(res!=null){
                    component.set("v.result", res);
                    if(res.visitor_activity!=null){
                        var showed = new Array();
                        for(var i=0;i<res.visitor_activity.length;i++){
                            console.log(res.visitor_activity[i].visits);
                            if(res.visitor_activity[i].init)
                                showed.push(res.visitor_activity[i]);
                        }
                        component.set("v.showedvisitoractivities", showed);
                        if(res.visitor_activity.length==showed.length){
                            var load = component.find("myLoadMore");
                            $A.util.toggleClass(load, "slds-hide");
                        }
                        var spinner = component.find("mySpinner");
                        $A.util.toggleClass(spinner, "slds-hide");
                    }
                    else{
                        var nextaction = component.get("c.errorhandle");
                        $A.enqueueAction(nextaction);
                    }
                }
                else{
                    var nextaction = component.get("c.errorhandle");
                    $A.enqueueAction(nextaction);
                }
            }
            else{
                var nextaction = component.get("c.errorhandle");
                $A.enqueueAction(nextaction);
            }
            
		});
        $A.enqueueAction(action);
	},
    Summary : function(component, event, helper) {
        var spinner = component.find("mySummary");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    errorhandle : function(component, event, helper) {
        var load = component.find("myLoadMore");
        $A.util.toggleClass(load, "slds-hide");
        component.set("v.showedvisitoractivities", [{"created_at":null,"created_at_new":null,"details":"No activity on the website","grpname":"Errors","header":"Error","icon":"standard:link","id":null,"init":true,"showmore":false,"type":1,"type_name":"Error"}]);
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    moreinfo : function(component, event, helper) {
        var ctarget = event.currentTarget; 
    	var params = ctarget.dataset.value;
    	var id_str = params.split(';')[0];
        var details = document.getElementById(id_str);
        $A.util.toggleClass(details, "slds-hide");
        if(params.split(';').length==2&&params.split(';')[1]!=null&&params.split(';')[1]!=''&&params.split(';')[1]!='null'){
            console.log('start email get');
            var parm = component.get("v.params");
            var email_str = params.split(';')[1];
            console.log(email_str);
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
            var obj = component.get("v.emaildata");
            var txt;
            if(obj[email_str] != undefined){
                txt = 'Email: '+obj[email_str];
                var details = document.getElementById(params);
                details.innerHTML = txt;
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
            }
            else{
                var action = component.get("c.getEmailData");
                action.setParams({emailid : email_str, params: parm, curmap: JSON.stringify(obj)});
                action.setCallback(this, function(response){
                    var state = response.getState();
                    console.log(state);
                    if(state === 'SUCCESS'){
                        var res = response.getReturnValue();
                        console.log(res);
                        if(res!=null){
                            component.set("v.emaildata", res);
                            var obj = component.get("v.emaildata");
                            txt = 'Email: '+obj[email_str];
                            var details = document.getElementById(params);
                            details.innerHTML = txt;
                        }
                        else{
                            var nextaction = component.get("c.errorhandle");
                            $A.enqueueAction(nextaction);
                        }
                    }
                    else{
                        var nextaction = component.get("c.errorhandle");
                        $A.enqueueAction(nextaction);
                    }
                    var spinner = component.find("mySpinner");
                    $A.util.toggleClass(spinner, "slds-hide");
                });
                $A.enqueueAction(action);
            }
        }
    }
})
({
	initiateFields : function(cmp, callback) {
        var fieldDesc = [{"Contact" : ["Department__c"], }, 
                         {"Opportunity" : ['Closed_Lost_Reason__c', 'Competition__c', 'Competitor_Product__c', 
                                           'Issues_with_Data_We_Show__c', 'Missing_coverage_or_feature__c', 'Missing_Data_or_Feature__c',
                                           'Deal_Lost_To_a_Competitor__c', 'Opp_Will_be_Relevant__c', 'Cycle__c','Section_in_PRO_w_accuracy_issues__c',
                                          'Primary_Solution__c','Secondary_Solution__c','Secondary_Use_Case__c','Primary_Use_Case__c','CSA_Satisfaction_Score__c']},
                         {"Account" : ["SW_Industry__c"]}];
        
		var action = cmp.get("c.getPicklistFieldsDetails");
        action.setParams({fieldDescString : JSON.stringify(fieldDesc)});

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                if (resp.success) {
                    resp.content.Opportunity.CSA_Satisfaction_Score__c.shift();
                	cmp.set('v.fieldDetails', resp.content);  
                    
                    if (resp.content['Account'].SW_Industry__c)
                    	cmp.set('v.newAccSWIndustry', resp.content['Account'].SW_Industry__c[0]);
                    
                    if (callback) 
	                    $A.enqueueAction(callback);
                }
                
            }
            else {}
        });
        $A.enqueueAction(action);
        
        if (window.location.href.indexOf('lightning') != -1){
            cmp.set("v.isLEX",true);
        } else {
            cmp.set("v.isLEX",false);
        }
	},
    
  	showToast : function(isLEX, type, title, message) {
        /*if (isLEX) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type" : type,
                "title": title,
                "message": message
            });
            toastEvent.fire();
        } else { */ 
            alert(message);
        //}
   }, 
    
    validateOpp : function (cmp) {
        var oppIsValid = true;
        var lghtInputsToValidate = ['primarySolution','secondarySolution', 'additional-notes', 'relevance', 
                                   'missing-platf', 'missing-cover', 'data-issues', 'section-issues', 
                                   'country-issues', 'accIndustry', 'cycle','using-compet', 'CSASatisfactionScore']; //, 'cyclePrice'
        
        var selectedClosedReasons = cmp.get('v.selectedClosedReasons');
        var closedReason = cmp.find('close-reason-chbx');
        var selectedCopetitorProducts = cmp.get('v.selectedCopetitorProducts');
        if (!selectedClosedReasons || selectedClosedReasons.length == 0) {
            oppIsValid = false;
            if (closedReason) {
                Object.keys(closedReason).forEach(function (key) {
                  var elem = closedReason[key];
                  $A.util.addClass(elem, 'slds-has-error');
                    cmp.set('v.closedLostReasonHasError', true);
                });
            }
        } else {
            this.cleanClosedReasons(cmp);
        }
		
        var selectedCompetitors = cmp.get('v.selectedCopetitorProducts');
        var otherCompetitor = cmp.get('v.opportunity.Other_Competitors__c');
        var competitorValid = true;
        var otherComp = cmp.find('other-comp');
        if (otherComp){
            if (selectedCompetitors && selectedCompetitors.length > 0) {
                for (var i = 0; i < selectedCompetitors.length; i++) {
                    if (selectedCompetitors[i].value == 'Other' && !otherCompetitor){
                        competitorValid = false;
                        oppIsValid = false;
                        cmp.set('v.showOtherCompetitorProduct', true);
                        otherComp.setCustomValidity('Please provide details on other compitetors.'); 
                        break;
                    }
                }
            }
            if (competitorValid && otherComp)
                otherComp.setCustomValidity(''); 
            otherComp.reportValidity();
        }
		        
        for (var i = 0; i < lghtInputsToValidate.length; i++) {
            debugger;
            var elem = cmp.find(lghtInputsToValidate[i]);
            if (elem) {
                if (typeof elem.reportValidity === 'function'){
                    if (! elem.reportValidity())
                		oppIsValid = false;
                }
                else if (elem.get('v.validity')){
                    if (!elem.get('v.validity').valid){
                        oppIsValid = false;
                        elem.showHelpMessageIfInvalid();
                    }
                }
            }
        }
        
        return oppIsValid;
    }, 
    //current source format is as exm. 2018-11-24 to mm/dd/yyyy
    formatDate : function(sourceDate) {
        var date = new Date(sourceDate);
        var day = date.getDate();
        var month = date.getMonth() + 1;
        var year = date.getFullYear();
        
        return day + '/' + (month < 10 ? '0' + month : month) + '/' + year;
    }, 
    
    updateRelatedAccount : function(cmp, accountId, fields){
        var action = cmp.get("c.updateRelatedAccount");
        action.setParams({ accountId : accountId, strfields : fields });
        
        action.setCallback(this, function(response) {
            cmp.set('v.showConfirmationModal', false);
                var state = response.getState();
                if (state === "SUCCESS") {
                    var resp = response.getReturnValue();
                    if (!resp.success) {
                        this.showToast(cmp.get('v.isLEX'), 'error', undefined, 'Error happened : ' + resp.message);
                    }
                }
                else {
        			this.showToast(cmp.get('v.isLEX'), 'error', undefined, 'Error happened : ' + response.getError());
                }
            }); 
            
        	$A.enqueueAction(action);
    }, 
    
    setCheckedReasons : function (cmp, oppReasons){
        var allReasons = cmp.get('v.fieldDetails.Opportunity.Closed_Lost_Reason__c');
        var existing = oppReasons.split(';');
        
        for (var i = 0; i < allReasons.length; i++){
            var value = allReasons[i].groupName + ' - ' + allReasons[i].reasonName;
            if (existing.indexOf(value) != -1)
                allReasons[i].selected = true;
        }
        cmp.set('v.selectedClosedReasons', existing);
        cmp.set('v.fieldDetails.Opportunity.Closed_Lost_Reason__c', allReasons);
    },
    
    setCheckedCompetitorProds : function (cmp, oppExistingOpts){
        var existingOpts = oppExistingOpts.split(';');
        var allValues = cmp.get('v.fieldDetails.Opportunity.Competitor_Product__c');
        var updatedAll = [];
        var selectedList = [];
        for (var i=0; i < allValues.length; i++){
        	var matched = false;
            for (var j = 0; j < existingOpts.length; j++){
                if (allValues[i].value == existingOpts[j]){
                    selectedList.push(allValues[i]);
                    matched = true;
                } 
            }
            if (!matched)
                updatedAll.push(allValues[i]);
        }
        cmp.set('v.fieldDetails.Opportunity.Competitor_Product__c', updatedAll);
        cmp.set('v.selectedCopetitorProducts', selectedList);
    }, 
    
    cleanClosedReasons : function (cmp) {
        var closedReason = cmp.find('close-reason-chbx');
        if (closedReason) {
                Object.keys(closedReason).forEach(function (key) {
                  var elem = closedReason[key];
                  $A.util.removeClass(elem, 'slds-has-error');  
                    cmp.set('v.closedLostReasonHasError', false);
                });
            }
    }, 
    
    setDefault : function (cmp, opp) {
        var fieldDetails = cmp.get('v.fieldDetails');
        debugger;
        if (!opp.Issues_with_Data_We_Show__c ){
        var allIssues = cmp.get('v.fieldDetails.Opportunity.Issues_with_Data_We_Show__c');
        if (allIssues)
	    	cmp.set('v.opportunity.Issues_with_Data_We_Show__c', allIssues[0].value);
        }
        /*if (!opp.Missing_Data_or_Feature__c ){
        	var allMissing = cmp.get('v.fieldDetails.Opportunity.Missing_Data_or_Feature__c');
            if (allMissing)
	        	cmp.set('v.opportunity.Missing_Data_or_Feature__c', '');//allMissing[0].value
        }*/        
        if (!opp.Competition__c ){
        	var allCompetitions = cmp.get('v.fieldDetails.Opportunity.Competition__c');
            if (allCompetitions)
	        	cmp.set('v.opportunity.Competition__c', ''); //allCompetitions[0].value
        }
        if (!opp.Deal_Lost_To_a_Competitor__c){
        	var allDealLosts = cmp.get('v.fieldDetails.Opportunity.Deal_Lost_To_a_Competitor__c');
            if (allDealLosts)
	        	cmp.set('v.opportunity.Deal_Lost_To_a_Competitor__c', allDealLosts[0].value);
        }
        if (!opp.Cycle__c){
            var allCycles = cmp.get('v.fieldDetails.Opportunity.Cycle__c');
            if (allCycles)
	        	cmp.set('v.newCycle', allCycles[0].value);
        }
    }
})
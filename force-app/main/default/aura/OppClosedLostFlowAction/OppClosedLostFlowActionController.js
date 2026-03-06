({
	doInit : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire() ;
        var message;
        var rec = cmp.get('v.record');
        if (rec.IsClosed){
            //cmp.set('v.message', 'This opportunity is already closed.'); 
            message = 'This opportunity is already closed.';
        } else if( rec.Type != 'Renewal' && rec.Type != 'New Sale' && rec.Type != 'Upsell') {
            //cmp.set('v.message', "This flow isn't supported by this opportunity type");
            message = "This flow isn't supported by this opportunity type";
        } else {
        	var recordId = cmp.get('v.recordId');
            if (recordId){
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                  "url": "/apex/OppClosedLostFlowPage?id=" + recordId,
                  "isredirect": "true"
                });
                urlEvent.fire();
                

            }
        }
        if (message) {
             var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: message,
                type: 'warning'
            });
            toastEvent.fire();
        }
	}
})
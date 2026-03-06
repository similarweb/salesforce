({
    doInit: function(cmp) {
        
        var currentUserId = $A.get("$SObjectType.CurrentUser.Id");       
        cmp.set("v.currUserId",currentUserId);
        
        var req = new XMLHttpRequest();     
        req.onreadystatechange = function(event) {
            if (req.readyState == 4) {
                if (req.status === 200) {                    
	                cmp.set("v.setMeOnInit", "");
	                var iframe = cmp.find("iframe"); 
            	    $A.util.removeClass(iframe, "hide");
                } else {
                    cmp.set("v.setMeOnInit", "Please connect to SimilarWeb VPN in order to show this page.");
                }
            }
        };

        req.open('GET', 'https://datacollection-hermes-production.op-us-east-1.datacollection-grid.int.similarweb.io/health');
        req.send(null);        
        
    }
})
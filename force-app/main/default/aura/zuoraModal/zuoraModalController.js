({
	Save : function(cmp, event, helper) {
	console.log('executing save go to new Quote...');
		var newQuoteEvent = cmp.getEvent("newQuoteEvent");
		newQuoteEvent.fire();
	},
	closeModel : function(cmp, event, helper) {
		cmp.set('v.isOpen',false);
	}
})
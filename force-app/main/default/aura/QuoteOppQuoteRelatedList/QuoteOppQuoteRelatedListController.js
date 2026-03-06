({
    onInit : function(component, event, helper) {
        helper.obtailnRelatedQuotesAction(component, helper);
    },

    onItemClick : function(component, event, helper) {
        helper.itemClickHandler(component,event);
    },

    onViewAllClick : function(component, event, helper) {
        helper.viewAllClickHandler(component,event);
    },

    handleApplicationRefreshFired : function(component, event, helper) {
        helper.obtailnRelatedQuotesAction(component,helper);
	},
	
	onFileItemClick : function(component, event, helper) {
        helper.fileItemClickHandler(component,event);
    },

    /* onMenuItemSelect : function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");
        if (selectedMenuItemValue.includes('delete')) {
            var index = selectedMenuItemValue.split('_')[1];
            helper.deleteRecord(component,helper,index);
        }
    } */
})
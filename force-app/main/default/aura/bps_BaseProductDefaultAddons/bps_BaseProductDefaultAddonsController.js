({
    onAddValuesClick : function(component, event, helper) {
        component.set('v.shownAddValuesModal',true);
    },

    onAddonsListChange : function(component, event, helper) {
        var addonsList = event.getParam("value");
        var valuesListRaw = '';
        addonsList.forEach(addon => {
            valuesListRaw+=addon+'\n';
        });
        component.set('v.valuesListRaw',valuesListRaw);
    }
})
({
	emitClose: function(component) {
        var event = component.getEvent('onclose');
        event.fire();
    }, 
    setError : function(component,message){
        component.set('v.errorMessage',message);
    },
})
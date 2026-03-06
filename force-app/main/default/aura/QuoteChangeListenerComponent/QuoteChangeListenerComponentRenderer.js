({
	unrender : function() {
        console.log('test unrender');
        this.superUnrender();
    },
    rerender : function(){
        console.log('test rerender');
    }
})
({
	fillPicklist : function(cmp,  inputtedname, inArrr) {  
        var options = [];
        var inputsel = cmp.find(inputtedname);

        if (inputsel){
            
            for(var i = 0; i < inArrr.length; i++){
                options.push({"class": "optionClass", label: inArrr[i].label, value: inArrr[i].value, selected : inArrr[i].value == window.countryValue || inArrr[i].value == window.stateValue});
            }
            /*if (inArrr.length > 0)
            	options[1].selected = "true";*/
            inputsel.set("v.options", options);
        }
    }
})
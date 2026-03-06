({
    onButtonClick : function(component, event, helper) {
       helper.checkQuoteForASRequests(component, event, helper);
      //helper.generatePreviewContract(component,helper);
    },

    handleASProductEvent : function(component, event, helper) {
      let message = event.getParam("message");
      if(message == "generate"){
            helper.generatePreviewContract(component, helper);
      }
    },

    handleGenerateContractEvent : function(component, event, helper) {
      var message = event.getParam("message");
      console.log('Event handle: '+message);
      
      if(message === 'generate contract and send to docusign'){
         helper.generatePreviewContract(component,helper,true);
      } else if(message === 'generate contract'){
         helper.generatePreviewContract(component,helper);
      }
      
     }
})
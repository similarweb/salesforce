global class Response {
    @AuraEnabled 
    global Boolean success {get;set;}
    @AuraEnabled 
  	global String message {get;set;}
    @AuraEnabled 
    global Object content {get;set;}
    
    global Response(){}
    
    global Response(Object content){
        this.success = true;
        this.message = '';
        this.content = content;
    }
    global Response(String message){
        this.success = false;
        this.message = message;
    }
    
    global Response(Boolean success, Object content){
        this.success = success;
        this.message = '';
        this.content = content;
    }
    
    global Response(Boolean success, String message){
        this.success = success;
        this.message = message;
    }
    
    global Response(Boolean success, String message, Object content){
        this.success = success;
        this.message = message;
        this.content = content;
    }
    
}
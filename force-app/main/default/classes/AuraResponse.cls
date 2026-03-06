global without sharing class AuraResponse {
	@AuraEnabled
	global Boolean success{get;set;}
	@AuraEnabled
	global String message{get;set;}
	@AuraEnabled
	global String page{get;set;}
	@AuraEnabled
	global String title{get;set;}  
    public  AuraResponse (Boolean success,String title,String message) {
    	this.success = success;
    	this.message = message;
    	this.title = title;
    }
    public static  AuraResponse  factory(Boolean success,String title,String message) {
    	AuraResponse  obj = new AuraResponse(success,title,message);
    	return obj;
    }
    public static  AuraResponse  succeed(String title,String message) { return factory(true,title,message); }
    public static  AuraResponse  failed(String title,String message) { return factory(false,title,message); }
    public static void selfTest() {
    	AuraResponse a = succeed('success','success');
    	a.page = 'test';
    	failed('failed','failed');
    }
}
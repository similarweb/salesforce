@isTest
public class BiApiMockImp implements System.HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();            
        if(req.getEndpoint().contains('http://biapi.similarweb.io/api/v1')){
            res.setHeader('ContentType','application/json');            
            Map<String,String> respMap = new Map<String,String>();
            respMap.put('SW_Fit_Score__c', 'A');
            res.setBody(JSON.serialize(respMap));
            res.setStatusCode(200);
        }
        return res;
    }
    
}
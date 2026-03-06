@isTest
public class NewBiApiMockImp implements System.HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();            
       // if(req.getEndpoint().contains('http://biapi.similarweb.io/api/v1')){
            res.setHeader('ContentType','application/json');            
            Map<String,String> respMap = new Map<String,String>();
            respMap.put('fit_score', '60');
    		respMap.put('fit_prediction', 'B');
	        respMap.put('is_tam', '0');
            respMap.put('timestamp', '\"2020-05-05T12:29:21.965952\"');
            res.setBody(JSON.serialize(respMap));
            res.setStatusCode(200);
       // }
        return res;
    }    
}
@isTest
public class InferredSolutionApiMock implements System.HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    if (req.getEndpoint().contains('tooling/sobjects/CustomField')) {
      res.setHeader('ContentType', 'application/json');
      Map<String, String> respMap = new Map<String, String>();
      respMap.put('SW_Fit_Score__c', 'A');
      res.setBody(JSON.serialize(respMap));
      res.setStatusCode(201);
    }
    return res;
  }
}

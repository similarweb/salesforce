/**
 * Created by Alon.Shalev on 4/14/2025.
 */

public with sharing class GroudonMockService implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody('{"message": "Lead successfully processed"}');
        res.setStatusCode(201);
        return res;
    }

}
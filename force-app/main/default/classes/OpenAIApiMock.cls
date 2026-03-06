@isTest
global class OpenAIApiMock implements HttpCalloutMock {
    Boolean isSuccess;

    public OpenAIApiMock(Boolean isSuccess) {
        this.isSuccess = isSuccess;
    }

    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if (isSuccess) {
            res.setBody('{"choices": [{"message": {"role": "assistant", "content": "Sample content"}}]}');
            res.setStatusCode(200);
        } else {
            res.setBody('Error');
            res.setStatusCode(500);
        }
        return res;
    }
}
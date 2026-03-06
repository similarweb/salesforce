@isTest
private class ZuoraAuthApiServiceTest {
    
    @IsTest
    static void Sandbox_Auth_Test(){
        String clientId = 'a1111aaa-10ab-1aa0-011b-10000aaa0011'; 
        String clientSecret = 'adfsdfsdfsd/dfsdfadfsdfadfwfwefwefsdverve';
        String token = '1b111aab000b100bb11bba0a00b11b11';

        String responseBody = '{'+
                              '    "access_token": "' + token + '",'+
                              '    "token_type": "bearer",'+
                              '    "expires_in": 3598'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraAuthApiService apiService = new ZuoraAuthApiService();
        Test.startTest();
            HttpRequest req = new HttpRequest();
            req = apiService.getAuthorization(req);
            String apiAccessKeyId = req.getHeader('apiAccessKeyId');
            String apiSecretAccessKey = req.getHeader('apiSecretAccessKey');
        Test.stopTest();
    }

    @IsTest
    static void PROD_Auth_Test(){
        String clientId = 'a1111aaa-10ab-1aa0-011b-10000aaa0011'; 
        String clientSecret = 'adfsdfsdfsd/dfsdfadfsdfadfwfwefwefsdverve';
        String token = '1b111aab000b100bb11bba0a00b11b11';

        String responseBody = '{'+
                              '    "access_token": "' + token + '",'+
                              '    "token_type": "bearer",'+
                              '    "expires_in": 3598'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraAuthApiService apiService = new ZuoraAuthApiService();
                            apiService.IS_PRODUCTION_ORG = true;
        Test.startTest();
            HttpRequest req = new HttpRequest();
            req = apiService.getAuthorization(req);
            String bearerToken = req.getHeader('Authorization');
        Test.stopTest();
    }

    @IsTest
    static void getBearerToken_Success_Test(){
        String clientId = 'a1111aaa-10ab-1aa0-011b-10000aaa0011'; 
        String clientSecret = 'adfsdfsdfsd/dfsdfadfsdfadfwfwefwefsdverve';
        String token = '1b111aab000b100bb11bba0a00b11b11';

        String responseBody = '{'+
                              '    "access_token": "' + token + '",'+
                              '    "token_type": "bearer",'+
                              '    "expires_in": 3598'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraAuthApiService apiService = new ZuoraAuthApiService();
        Test.startTest();
            String bearerToken = apiService.getBearerToken(clientId, clientSecret);
            System.assertEquals(token, bearerToken);
        Test.stopTest();
    }

    @IsTest
    static void getBearerToken_InvalidBody_Test(){
        String clientId = 'a1111aaa-10ab-1aa0-011b-10000aaa0011'; 
        String clientSecret = 'adfsdfsdfsd/dfsdfadfsdfadfwfwefwefsdverve';

        String responseBody = '{'+
                              '    "token_type": "bearer",'+
                              '    "expires_in": 3598'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraAuthApiService apiService = new ZuoraAuthApiService();
        Test.startTest();
            try {
                apiService.getBearerToken(clientId, clientSecret);
            } catch(Exception ex){
                System.assertEquals(ex.getMessage(), 'Auth request fails, response does not contains required parameter');
            }
        Test.stopTest();
    }

    @IsTest
    static void getBearerToken_InvalidStatus_Test(){
        String clientId = 'a1111aaa-10ab-1aa0-011b-10000aaa0011'; 
        String clientSecret = 'adfsdfsdfsd/dfsdfadfsdfadfwfwefwefsdverve';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(400);
                     testResp.setHeader('ContentType','application/json');

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraAuthApiService apiService = new ZuoraAuthApiService();
        Test.startTest();
            try {
                apiService.getBearerToken(clientId, clientSecret);
            } catch(Exception ex){
                System.assert(ex.getMessage().containsIgnoreCase('Auth request fails with '));
                System.assert(ex.getMessage().containsIgnoreCase(' status'));
            }
        Test.stopTest();
    }

    private class ZuoraServiceMock implements HttpCalloutMock {
        private HttpResponse res;

        public ZuoraServiceMock(HttpResponse res){
            this.res = res;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            return this.res;
        }
    }
}
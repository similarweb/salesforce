@isTest
private class ZuoraApiServiceTest {

    @TestSetup
    static void setup() {
        Utils.CodeOff = true;
        TestDataFactory.createSimilarWeb_CS();
        TestDataFactory.createBaseProductConfiguration_CS();
        TestDataFactory.createInferredSolutionSettings_CS();
        insert TestDataFactory.createBaseProductContract_CS();
        insert TestDataFactory.createBaseProductConfiguration_CS();
        insert TestDataFactory.createBaseProductControlling_CS();
        insert TestDataFactory.createBaseProductDependent_CS();     
        insert TestDataFactory.createBaseProductDefaultAddon_CS();
        insert TestDataFactory.createBaseProductDynamicAddon_CS();
        insert TestDataFactory.createBaseProductNumOfUsers_CS();
    }

    @IsTest
    static void updateAccountCertificateId_Success_True_Test(){
        String accountId = '1a11a1aa11a1a1a111111111011a1a1a';
        String certificateId = 'TS110110111';
        String responseBody = '{'+
                              '    "Success": true,'+
                              '    "Id": "' + accountId + '"'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
                        apiService.authService = (ZuoraAuthApiService)MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        Test.startTest();
            Boolean isUpdated = apiService.updateAccountCertificateId(accountId, certificateId);
            System.assert(isUpdated);
        Test.stopTest();
    }

    @IsTest
    static void updateAccountCertificateId_InvalidBody_Error_Test(){
        String accountId = '1a11a1aa11a1a1a111111111011a1a1a';
        String certificateId = 'TS110110111';
        String responseBody = '{'+
                              '    "Id": "' + accountId + '"'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
                        apiService.authService = (ZuoraAuthApiService)MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        Test.startTest();
            try {
                Boolean isUpdated = apiService.updateAccountCertificateId(accountId, certificateId);
            } catch(Exception ex){
                System.assertEquals(ex.getMessage(), 'Invalid response body');
            }
        Test.stopTest();
    }

    @IsTest
    static void updateAccountCertificateId_StatusCode_Error_Test(){
        String accountId = '1a11a1aa11a1a1a111111111011a1a1a';
        String certificateId = 'TS110110111';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(400);
                     testResp.setHeader('ContentType','application/json');

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
                        apiService.authService = (ZuoraAuthApiService)MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        Test.startTest();
            try {
                Boolean isUpdated = apiService.updateAccountCertificateId(accountId, certificateId);
            } catch(Exception ex){
                System.assert(ex.getMessage().containsIgnoreCase('Update account data request failed with status code: '));
            }
        Test.stopTest();
    }

    @IsTest
    static void getSubscriptionData_Success_True_Test(){
        String subscriptionId = '1a11a1aa11a1a1a111111111011a1a1a';
        
        String responseBody = '{'+
                              '    "success": true'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
                        apiService.authService = (ZuoraAuthApiService)MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        Test.startTest();
            Map<String, Object> responseData = apiService.getSubscriptionData(subscriptionId);
            System.assert((Boolean)responseData.get('success'));
        Test.stopTest();
    }

    @IsTest
    static void getSubscriptionData_InvalidBody_Error_Test(){
        String subscriptionId = '1a11a1aa11a1a1a111111111011a1a1a';
        
        String responseBody = '{'+
                              '    "success": false'+
                              '}';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(200);
                     testResp.setHeader('ContentType','application/json');
                     testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
                        apiService.authService = (ZuoraAuthApiService)MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        Test.startTest();
            try {
                apiService.getSubscriptionData(subscriptionId);
            } catch(Exception ex){
                System.assertEquals(ex.getMessage(), 'Invalid response body');
            }
        Test.stopTest();
    }

    @IsTest
    static void getSubscriptionData_StatusCode_Error_Test(){
        String subscriptionId = '1a11a1aa11a1a1a111111111011a1a1a';

        HttpResponse testResp = new HttpResponse();
                     testResp.setStatusCode(400);
                     testResp.setHeader('ContentType','application/json');

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
                        apiService.authService = (ZuoraAuthApiService)MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        Test.startTest();
            try {
                apiService.getSubscriptionData(subscriptionId);
            } catch(Exception ex){
                System.assert(ex.getMessage().containsIgnoreCase('Get Subscription data request failed with status code: '));
            }
        Test.stopTest();
    }

    @isTest
    static void generateContractInZuoraTest() {
        String quoteId = 'test';
        String templateId = 'test';
        String responseBody = '{'+
                              '    "success": true'+
                              '}';

        HttpResponse testResp = new HttpResponse();
        testResp.setStatusCode(200);
        testResp.setHeader('ContentType','application/json');
        testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
        apiService.authService = (ZuoraAuthApiService) MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        
        Test.startTest();
        Map<String, Object> responseData = apiService.generateContractInZuora(quoteId, templateId);
        System.assert((Boolean) responseData.get('success'));
        Test.stopTest();
    }

    @isTest
    static void obtainDocumentFromZuoraTest() {
        String quoteId = 'test';
        String fileUrl = 'test';
        String responseBody = '{'+
                              '    "success": true'+
                              '    "file": 123'+
                              '}';

        HttpResponse testResp = new HttpResponse();
        testResp.setStatusCode(200);
        testResp.setHeader('ContentType','application/msword');
        testResp.setBody(responseBody);

        Test.setMock(HttpCalloutMock.class, new ZuoraServiceMock(testResp));
        ZuoraApiService apiService = new ZuoraApiService();
        apiService.authService = (ZuoraAuthApiService) MockUtil.obtainMockProvider(ZuoraAuthApiService.class);
        
        Test.startTest();
        HTTPResponse res = apiService.obtainDocumentFromZuora(quoteId, fileUrl);
        System.assertEquals(200, res.getStatusCode());
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
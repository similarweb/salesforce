@isTest
private class CheckVatServiceTest {
  @isTest
  static void TestCheckVat_CaseB() {
    test.starttest();
    Test.setMock(
      WebServiceMock.class,
      new CheckVatServiceMockImpl('IE', '6388047V')
    );
    system.debug('TESTING CaseB run');
    String output = new WSVATService().checkVat('IE', '6388047V');
    //System.assertEquals('Mock response', output);
    test.stoptest();
  }

  @isTest
  static void TestAsyncCheckVat() {
    ContinuationCheckVatController demoWSDLClass = new ContinuationCheckVatController();

    // Invoke the continuation by calling the action method
    Continuation conti = demoWSDLClass.startRequest();

    // Verify that the continuation has the proper requests
    Map<String, HttpRequest> requests = conti.getRequests();
    System.assertEquals(requests.size(), 1);

    // Perform mock callout
    // (i.e. skip the callout and call the callback method)
    HttpResponse response = new HttpResponse();
    //        String mockBody = 'checkVatResponse_elementFuture:[WebServiceCalloutFuture.label=Continuation-1]';
    String tt = 'checkVatResponse_element:[address=3RD FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4, address_type_info=(address, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, true), apex_schema_type_info=(urn:ec.europa.eu:taxud:vies:services:checkVat:types, true, true), countryCode=IE, countryCode_type_info=(countryCode, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false), field_order_type_info=(countryCode, vatNumber, requestDate, valid, name, address), name=GOOGLE IRELAND LIMITED, name_type_info=(name, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, true), requestDate=2016-10-21 00:00:00, requestDate_type_info=(requestDate, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false), valid=true, valid_type_info=(valid, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false), vatNumber=6388047V, vatNumber_type_info=(vatNumber, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false)]';
    String tempString =
      '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">' +
      '<soap:Body>' +
      '<checkVatResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">' +
      '<countryCode>IE</countryCode>' +
      '<vatNumber>6388047V</vatNumber>' +
      '<requestDate>2016-10-21+02:00</requestDate>' +
      '<valid>true</valid>' +
      '<name>GOOGLE IRELAND LIMITED</name>' +
      '<address>3RD FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4</address>' +
      '</checkVatResponse>' +
      '</soap:Body>' +
      '</soap:Envelope>';
    response.setBody(tempString);
    // Set the fake response for the continuation
    String requestLabel = requests.keyset().iterator().next();
    Test.setContinuationResponse(requestLabel, response);
    test.starttest();
    // Invoke callback method
    Object result = Test.invokeContinuationMethod(demoWSDLClass, conti);
    System.debug(demoWSDLClass);

    // result is the return value of the callback
    System.assertEquals(null, result);

    // Verify that the controller's result variable
    //   is set to the mock response.

    System.assertEquals(tt, demoWSDLClass.result);
    test.stoptest();
  }
}

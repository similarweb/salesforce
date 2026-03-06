@isTest
private class CheckVatAproxServiceTest {

   @isTest
   static void TestCheckVat_CaseB1() { 
   		test.starttest();   	 
        Test.setMock(WebServiceMock.class, new CheckVatAproxServiceMockImpl('IE','6388047V','','','','','','IE','6388047V'));      
        String output = new WSVATService().checkVatAprox('IE','6388047V','','','','','','IE','6388047V');
        test.stoptest();        
     //   System.assertEquals('Mock response', output);
    }
    
    static testMethod void TestAsyncCheckVatAprox() {
    	ContinuationCheckVatAproxController demoWSDLClass = 
            new  ContinuationCheckVatAproxController();

        // Invoke the continuation by calling the action method
        Continuation conti = demoWSDLClass.startRequest();

        // Verify that the continuation has the proper requests
        Map<String, HttpRequest> requests = conti.getRequests();
        System.assertEquals(requests.size(), 1);

        // Perform mock callout 
        // (i.e. skip the callout and call the callback method)
        HttpResponse response = new HttpResponse();
        //        String mockBody = 'checkVatResponse_elementFuture:[WebServiceCalloutFuture.label=Continuation-1]';
      	String tt = 'checkVatApproxResponse_element:[apex_schema_type_info=(urn:ec.europa.eu:taxud:vies:services:checkVat:types, true, true), countryCode=IE, countryCode_type_info=(countryCode, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false), field_order_type_info=(countryCode, vatNumber, requestDate, valid, traderName, traderCompanyType, traderAddress, traderStreet, traderPostcode, traderCity, ...), requestDate=2016-10-21 00:00:00, requestDate_type_info=(requestDate, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false), requestIdentifier=WAPIAAAAVfnsVX5V, requestIdentifier_type_info=(requestIdentifier, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false), traderAddress=3RD FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4, traderAddress_type_info=(traderAddress, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderCity=---, traderCityMatch=null, traderCityMatch_type_info=(traderCityMatch, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderCity_type_info=(traderCity, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderCompanyType=---, traderCompanyTypeMatch=null, traderCompanyTypeMatch_type_info=(traderCompanyTypeMatch, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderCompanyType_type_info=(traderCompanyType, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, true), traderName=GOOGLE IRELAND LIMITED, traderNameMatch=null, traderNameMatch_type_info=(traderNameMatch, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderName_type_info=(traderName, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, true), traderPostcode=---, traderPostcodeMatch=null, traderPostcodeMatch_type_info=(traderPostcodeMatch, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderPostcode_type_info=(traderPostcode, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderStreet=null, traderStreetMatch=null, traderStreetMatch_type_info=(traderStreetMatch, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), traderStreet_type_info=(traderStreet, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 0, 1, false), valid=true, valid_type_info=(valid, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false), vatNumber=6388047V, vatNumber_type_info=(vatNumber, urn:ec.europa.eu:taxud:vies:services:checkVat:types, null, 1, 1, false)]';
      	String tempString = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
   						   '<soap:Body>'+
     						 '<checkVatApproxResponse xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">'+
        						 '<countryCode>IE</countryCode>'+
        						 '<vatNumber>6388047V</vatNumber>'+
         						 '<requestDate>2016-10-21+02:00</requestDate>'+
         						 '<valid>true</valid>'+
         						 '<traderName>GOOGLE IRELAND LIMITED</traderName>'+
         						 '<traderCompanyType>---</traderCompanyType>'+
         						 '<traderPostcode>---</traderPostcode>'+
         						 '<traderCity>---</traderCity>'+
         						 '<traderAddress>3RD FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4</traderAddress>'+
         						'<requestIdentifier>WAPIAAAAVfnsVX5V</requestIdentifier>'+
      						 '</checkVatApproxResponse>'+
  							'</soap:Body>'+
                           '</soap:Envelope>';
        response.setBody(tempString);
        // Set the fake response for the continuation
        String requestLabel = requests.keyset().iterator().next();
        Test.setContinuationResponse(requestLabel, response);

        // Invoke callback method
        Object result = Test.invokeContinuationMethod(demoWSDLClass, conti);
        System.debug(demoWSDLClass);

        // result is the return value of the callback
        System.assertEquals(null, result);

        // Verify that the controller's result variable
        //   is set to the mock response.
			
        System.assertEquals(tt, demoWSDLClass.result);
    }
}
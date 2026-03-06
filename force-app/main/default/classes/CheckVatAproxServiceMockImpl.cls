/**  CheckVatServiceMockImpl:
      -test web service callouts
	  -to make fake response from the callouts
	  -constructor allowing multiple responses (some trick)
	  -@IsTest - we use only for testing the web service.
 */
@isTest
global class CheckVatAproxServiceMockImpl implements WebServiceMock {
  public String codeCountry;
  public String vatNumber;
  public String traderName;
  public String traderCompanyType;
  public String traderStreet;
  public String traderPostCode;
  public String traderCity;
  public String requesterCountryCode;
  public String requesterVatNumber;

  global CheckVatAproxServiceMockImpl() {
    codeCountry = '';
    vatNumber = '';
    traderName = '';
    traderCompanyType = '';
    traderStreet = '';
    traderPostCode = '';
    traderCity = '';
    requesterCountryCode = '';
    requesterVatNumber = '';
  }

  global CheckVatAproxServiceMockImpl(
    String CodeCountry,
    String VatNumber,
    String tName,
    String tCompanyType,
    String tStreet,
    String tPostCode,
    String tCity,
    String rCountryCode,
    String rVatNumber
  ) {
    codeCountry = CodeCountry;
    vatNumber = VatNumber;
    traderName = tName;
    traderCompanyType = tCompanyType;
    traderStreet = tStreet;
    traderPostCode = tPostCode;
    traderCity = tCity;
    requesterCountryCode = rCountryCode;
    requesterVatNumber = rVatNumber;
  }

  global void doInvoke(
    Object stub,
    Object request,
    Map<String, Object> response,
    String endpoint,
    String soapAction,
    String requestName,
    String responseNS,
    String responseName,
    String responseType
  ) {
    /* CheckVatViesService.checkVatPort checkVat = new CheckVatViesService.checkVatPort();
          CheckVatTypesService.checkVatApproxResponse_element  
    	 			checkVatResponse = checkVat.checkVatApprox(codeCountry, vatNumber, traderName, traderCompanyType, traderStreet, 
                                    traderPostCode, traderCity, requesterCountryCode, requesterVatNumber);           	 */
    CheckVatTypesService.checkVatApproxResponse_element checkVatResponse = new CheckVatTypesService.checkVatApproxResponse_element();
  }
}

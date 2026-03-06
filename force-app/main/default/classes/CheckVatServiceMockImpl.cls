/**  CheckVatServiceMockImpl:
      -test web service callouts
	  -to make fake response from the callouts
	  -constructor allowing multiple responses (some trick)
	  -@IsTest - we use only for testing the web service.
 */
@isTest
global class CheckVatServiceMockImpl implements WebServiceMock {
  public String codeCountry;
  public String vatNumber;

  global CheckVatServiceMockImpl() {
    codeCountry = '';
    vatNumber = '';
  }

  global CheckVatServiceMockImpl(String CodeCountry, String VatNumber) {
    codeCountry = CodeCountry;
    vatNumber = VatNumber;
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
    CheckVatViesService.checkVatPort checkVat = new CheckVatViesService.checkVatPort();
    CheckVatTypesService.checkVatResponse_element checkVatResponse = checkVat.checkVat(
      codeCountry,
      vatNumber
    );
    response.put(
      'response_x',
      new CheckVatTypesService.checkVatResponse_element()
    );
  }
}

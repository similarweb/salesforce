public class ContinuationCheckVatAproxController {
  AsyncCheckVatTypesService.checkVatApproxResponse_elementFuture checkVatResponseFuture;
  public String result { get; set; }

  //action method
  public Continuation startRequest() {
    Integer TIME_OUT_SECS = 60;
    Continuation conti = new Continuation(TIME_OUT_SECS);
    conti.continuationMethod = 'processResponse';

    AsyncCheckVatViesService.AsynccheckVatPort asyncCheckVatPort = new AsyncCheckVatViesService.AsynccheckVatPort();
    checkVatResponseFuture = asyncCheckVatPort.beginCheckVatApprox(
      conti,
      'IE',
      '6388047V',
      '',
      '',
      '',
      '',
      '',
      'IE',
      '6388047V'
    );
    //checkVatResponseFuture = asyncCheckVatPort.beginCheckVatApprox(conti,'IE','6388047V','GOOGLE IRELAND LIMITED','3RD FLOOR ,GORDON HOUSE ,BARROW STREET ,DUBLIN 4','','','Dublin','IE','6388047V');

    return conti;
  }
  // Callback method
  public Object processResponse() {
    CheckVatTypesService.checkVatApproxResponse_element checkVatResponse = checkVatResponseFuture.getValue();
    result = String.valueOf(checkVatResponse);

    // Return null to re-render the original Visualforce page
    return null;
  }
}

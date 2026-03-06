/*
 * Made by Dmitry Trufanov from Synebo
 */
@isTest
public class ExchangeRatesSchedulerMockImp implements System.HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    if (
      req.getEndpoint().contains('https://www.boi.org.il/currency.xml?curr')
    ) {
      res.setHeader('ContentType', 'text/xml');
      res.setStatusCode(200);
      res.setBody(
        '<CURRENCIES><LAST_UPDATE>2019-10-03</LAST_UPDATE><CURRENCY><NAME>Dollar</NAME><UNIT>1</UNIT><CURRENCYCODE>CAD</CURRENCYCODE><COUNTRY>Canada</COUNTRY><RATE>2.6211</RATE><CHANGE>-0.331</CHANGE></CURRENCY></CURRENCIES>'
      );
    }
    return res;
  }
}

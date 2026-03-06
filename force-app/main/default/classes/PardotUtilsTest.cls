/**
 * @author Itzik Winograd
 * @date 27/04/2021
 * @description: Test class for PardotUtils class
 */
@isTest
public class PardotUtilsTest {
  /**
   * @author Itzik Winograd
   * @date 27/04/2021
   * @description: Set a mock as a response from pardot.
   * @expected: The response from the pardot mock is not null and contains 'ok'
   */
  @isTest
  public static void pardotUtilsReadTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PardotUtilsTest.PardotTokenMock('ok', 200)
    );
    String pardotResponse = PardotUtils.readPardot(
      'Pardot_Read',
      'someToken',
      '1'
    );
    Test.stopTest();
    System.debug('@@@ pardotResponse: ' + pardotResponse);
    System.assertEquals(
      true,
      pardotResponse.containsIgnoreCase('ok'),
      'Pardot response does not contains ok. pardotResponse: ' + pardotResponse
    );
  }

  /**
   * @author Itzik Winograd
   * @date 02/05/2021
   * @description: Set a mock as a response from pardot with error code
   * @expected: null response and one log record created
   */
  @isTest
  public static void pardotUtilsReadErrorTest() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new PardotUtilsTest.PardotTokenMock('fail', 400)
    );
    String pardotErrorResponse = PardotUtils.readPardot(
      'Pardot_Read',
      'someToken',
      '1'
    );
    System.debug('@@@ pardotResponse: ' + pardotErrorResponse);
    Test.stopTest();
    System.assertEquals(
      true,
      pardotErrorResponse.containsIgnoreCase('fail'),
      'Pardot response does not contains fail. pardotErrorResponse: ' +
      pardotErrorResponse
    );
    Integer logSize = Database.countQuery(
      'SELECT count() FROM Apex_Event_Log__c'
    );
    System.assertEquals(1, logSize, 'Pardot read error - logsize: ' + logSize);
  }

  public class PardotTokenMock implements System.HttpCalloutMock {
    String stat = '';
    Integer code = 0;
    public PardotTokenMock(String stat, Integer code) {
      this.stat = stat;
      this.code = code;
    }
    public HTTPResponse respond(HTTPRequest req) {
      return PardotUtilsTest.getPardotResponse(stat, code);
    }
  }

  //Returns a fake response of Read query to pardot
  public static String getFakePardotReadResponse(String stat) {
    return '<?xml version="1.0" encoding="UTF-8"?>' +
      '<rsp stat="' +
      stat +
      '" version="1.0">' +
      '<prospect>' +
      '<id>1</id>' +
      '<phone>123456</phone>' +
      '</prospect>' +
      '</rsp>';
  }
  //Returns Pardot response with giver status and code
  public static HTTPResponse getPardotResponse(String stat, Integer code) {
    HttpResponse res = new HttpResponse();
    res.setHeader('ContentType', 'text/xml; charset=utf-8');
    String XMLresult = PardotUtilsTest.getFakePardotReadResponse(stat);
    res.setBody(XMLresult);
    res.setStatusCode(code);
    return res;
  }
}

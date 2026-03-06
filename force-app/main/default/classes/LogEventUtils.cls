/**
 * @author Itzik Winograd
 * @date 09/03/2021
 * @description Utils class for Log Event - latform event
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 04/04/2021
 * description - Log creation is done with List<String> for ids instead of strings.
 * --------------------------------------------------------------------------------------
 */
public with sharing class LogEventUtils {
  /**
   * @author Itzik Winograd
   * @date 09/03/2021
   * @Description Create a Log_Event__e record without Http request.
   * @param List<String> ids - The Id/Ids of the log related records
   * @param String apexClass - apex class name generated this log
   * @param String apexMethod - apex method generated this log
   * @param String info - detailed information about the record causing this log
   * @param String detailedError - error message if exists
   * @param String logType - Info or Error
   * @return Log_Event__e with all fields assigned
   */
  public static Log_Event__e createLogEventRecord(
    List<String> ids,
    String apexClass,
    String apexMethod,
    String info,
    String detailedError,
    String logType
  ) {
    return new Log_Event__e(
      Record_Ids__c = idsListToString(ids),
      Log_Type__c = logType,
      Apex_class__c = apexClass,
      Apex_Method__c = apexMethod,
      Detailed_Error_Message__c = detailedError,
      Detailed_Information__c = info
    );
  }

  /**
   * @author ALON SHALEV
   * @date 03/11/2022
   * @Description Create a Log_Event__e record without Http request.
   * @param List<String> ids - The Id/Ids of the log related records
   * @param String relatedId - The Id of a related lookup
   * @param String apexClass - apex class name generated this log
   * @param String apexMethod - apex method generated this log
   * @param String info - detailed information about the record causing this log
   * @param String detailedError - error message if exists
   * @param String logType - Info or Error
   * @return Log_Event__e with all fields assigned
   */
  public static Log_Event__e createLogEventRecord(
    List<String> ids,
    String relatedId,
    String apexClass,
    String apexMethod,
    String info,
    String detailedError,
    String logType
  ) {
    return new Log_Event__e(
      Record_Ids__c = idsListToString(ids),
      Log_Type__c = logType,
      Apex_class__c = apexClass,
      Apex_Method__c = apexMethod,
      Detailed_Error_Message__c = detailedError,
      Detailed_Information__c = info,
      Related_Record_Id__c = relatedId
    );
  }

  /**
   * @author Itzik Winograd
   * @date 09/03/2021
   * @Description Create a Log_Event__e record with Http request.
   * For headrs, loop over list of headers-keys and get the headers.
   * @param List<String> ids - The Id/Ids of the log related records
   * @param String apexClass - apex class name generated this log
   * @param String apexMethod - apex method generated this log
   * @param String info - detailed information about the record causing this log
   * @param String detailedError - error message if exists
   * @param String logType - Info or Error
   * @param httpRequest httpRequest - httpRequest rellevant for the log
   * @param List<String> headersKeys - headers of the request
   * @return Log_Event__e with all fields assigned
   */
  public static Log_Event__e createLogEventRecord(
    List<String> ids,
    String apexClass,
    String apexMethod,
    String info,
    String detailedError,
    String logType,
    HttpRequest httpRequest,
    List<String> headersKeys
  ) {
    Log_Event__e logEvent = LogEventUtils.createLogEventRecord(
      ids,
      apexClass,
      apexMethod,
      info,
      detailedError,
      logType
    );
    if (headersKeys != null) {
      String headers = '';
      for (String key : headersKeys) {
        headers += httpRequest.getHeader(key) + ';; ';
      }
      logEvent.Http_Headers__c = headers;
      logEvent.Http_Type__c = httpRequest.getMethod();
      logEvent.Http_Body__c = httpRequest.getBody();
      logEvent.Http_Endpoint__c = httpRequest.getEndpoint();
    }
    return logEvent;
  }

  /**
   * @author Itzik Winograd
   * @date 09/03/2021
   * @Description Create a Log_Event__e record with Http request.
   * For headrs, loop over list of headers-keys and get the headers.
   * @param List<SObject> ids - list of SObect Ids
   * @param String apexClass - apex class name generated this log
   * @param String apexMethod - apex method generated this log
   * @param String info - detailed information about the record causing this log
   * @param String detailedError - error message if exists
   * @param String logType - Info or Error
   * @param httpRequest httpRequest - httpRequest rellevant for the log
   * @return Log_Event__e with all fields assigned
   */
  public static Log_Event__e createLogEventRecord(
    List<SObject> records,
    String apexClass,
    String apexMethod,
    String info,
    String detailedError,
    String logType,
    HttpRequest httpRequest,
    List<String> headersKeys
  ) {
    List<String> idsList = new List<String>();
    for (SObject sobj : records) {
      idsList.add(sobj.Id);
    }
    return LogEventUtils.createLogEventRecord(
      idsList,
      apexClass,
      apexMethod,
      info,
      detailedError,
      logType,
      httpRequest,
      headersKeys
    );
  }

  /**
   * @author Itzik Winograd
   * @date 04/04/2021
   * @Description Convert a list<String> to a Semicolon-delimited string of ids.
   * @param List<String> idsList - The Id/Ids of the log related records as a List
   * @return String of ids seperated by ;
   */
  public static String idsListToString(List<String> idsList) {
    String idsAsString = '';
    for (String id : idsList) {
      idsAsString += id + ';';
    }
    return idsAsString;
  }
}

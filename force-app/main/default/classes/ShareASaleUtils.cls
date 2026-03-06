/**
 * @author Itzik Winograd
 * @date 27/05/2021
 * @description ShareASale utils class for all general ShareASale-related functions.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public with sharing class ShareASaleUtils {
  private static String authDateFormat = 'E, dd MMMM YYYY hh:mm:ss';
  private static String orderDateFormat = 'MM/dd/yyyy';

  /**
   * @author Itzik Winograd
   * @date 03/03/2021
   * @description generate a call to shareasale with NewTransaction
   * @param SObject sobj to base the call on.
   * @param String action = the action value shoul be on the call
   * @return List<Account> - list of accounts null if none requested
   */
  public static HttpRequest createShareASaleNewTransactionRequest(
    SObject sobj,
    String action
  ) {
    Map<String, String> headerPairs = createHeaders(action);
    Map<String, String> endpointPairs = createEndpoint(action, sobj);
    HttpRequest request = GeneralUtil.createGetRequest(
      'ShareAsale_Transaction',
      endpointPairs,
      headerPairs
    );
    System.debug(
      'request.getHeader(): x-ShareASale-Date: ' +
      request.getHeader('x-ShareASale-Date')
    );
    System.debug(
      'request.getHeader(): x-ShareASale-Authentication: ' +
      request.getHeader('x-ShareASale-Authentication')
    );
    System.debug('request.getEndpoint(): ' + request.getEndpoint());
    return request;
  }

  /**
   * @author Itzik Winograd
   * @date 03/03/2021
   * @Description Create the requested headers for the shareASale transaction.
   * Call structure can be found here: https://account.shareasale.com/m-apiips.cfm
   * @param None
   * @return Map<String,String> - The Headers needed to generate a call as a key-value Map.
   */
  private static Map<String, String> createHeaders(String action) {
    Map<String, String> headerPairs = new Map<String, String>();
    API_Configuration__mdt config = GeneralUtil.getAPIConfig(
      'ShareAsale_Transaction'
    );
    string apiToken = config.Token_Id__c;
    string apiSecret = config.Token_Pass__c;
    String currentDateTime = (System.now()).format(authDateFormat) + ' GMT';
    //YourAPIToken:CurrentDateInUTCFormat:APIActionValue:YourAPISecret
    String stringToHash =
      apiToken +
      ':' +
      currentDateTime +
      ':' +
      action +
      ':' +
      apiSecret;

    System.debug('### String before hashing: ' + stringToHash);
    Blob targetBlob = Blob.valueOf(stringToHash);
    Blob hash = Crypto.generateDigest('SHA-256', targetBlob);

    headerPairs.put('x-ShareASale-Date', currentDateTime);
    headerPairs.put(
      'x-ShareASale-Authentication',
      EncodingUtil.convertToHex(hash)
    );

    return headerPairs;
  }

  /**
   * @author Itzik Winograd
   * @date 03/03/2021
   * @Description - Get the values from the current SObject record for the call.
   * @param String action - the actino name to be added as a param
   * @param SOBject sobj.
   * @return Map<String,String> - The parameters needed to generate a call as a key-value Map.
   */
  private static Map<String, String> createEndpoint(
    String action,
    SObject sobj
  ) {
    Map<String, String> endpointPairs = new Map<String, String>();
    endpointPairs.put('action', action);
    //populate common shareasale attributes
    for (
      General_Key_Value_pair__mdt cmdt : GeneralUtil.getKeyValuePairs(
        'ShareASale Transaction'
      )
    ) {
      endpointPairs.put(cmdt.Key__c, (String) sobj.get(cmdt.Value__c));
    }
    //get the process name matching for the current action
    String processName = '';
    for (
      General_Key_Value_pair__mdt cmdt : GeneralUtil.getKeyValuePairs(
        'ShareASale_Action_to_Process_Name'
      )
    ) {
      if (cmdt.Key__c == action) {
        processName = cmdt.Value__c;
      }
    }
    System.debug('### createEndpoint - processName: ' + processName);
    //populate specific attributes for the received action
    if (processName != '') {
      for (
        General_Key_Value_pair__mdt cmdt : GeneralUtil.getKeyValuePairs(
          processName
        )
      ) {
        endpointPairs.put(cmdt.Key__c, (String) sobj.get(cmdt.Value__c));
      }
    }
    if (action == 'new') {
      endpointPairs.put('transtype', 'lead');
    }
    if (action == 'reference') {
      endpointPairs.put('transtype', 'sale');
      endpointPairs.put('xtype', 'New%20Customer');
      endpointPairs.put(
        'date',
        ((DateTime) sobj.get('CreatedDate')).format(orderDateFormat)
      );
    }

    System.debug('### endpointPairs: ' + endpointPairs);
    return endpointPairs;
  }
}

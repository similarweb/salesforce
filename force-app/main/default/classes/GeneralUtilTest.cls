/**
 * @author Gad Sharon
 * @date 17/11/2020
 * @description Test class for the class "GeneralUtil"
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      - Developer Synebo
 * date        - 22/12/2020
 * description - Test method to cover CONVERT_LEAD_STATUS property
 * --------------------------------------------------------------------------------------
 * author      - Itzik Winograd
 * date        - 06/02/2022
 * description - changed createGetRequestWithEnpointTest to use Test_Record
 * --------------------------------------------------------------------------------------
 */

@isTest
public with sharing class GeneralUtilTest {
  @isTest
  public static void getEnvNameUnitTest() {
    String s = generalUtil.getEnvName();
  }

  @isTest
  public static void getGeneralConfigUnitTest() {
    General_Configuration__mdt gc = generalUtil.getGeneralConfig('just a test');
  }

  @isTest
  public static void getAPIConfigUnitTest() {
    API_Configuration__mdt apiConfig = generalUtil.getAPIConfig('just a test');
  }

  @isTest
  public static void createHttpRequest() {
    String endpoint = 'http://www.example.com';
    String method = 'POST';
    String headers = 'Content-Type::application/json';
    String body = '{"Hello": "world"}';

    GeneralUtil.createHttpRequest(endPoint, method, headers, body);
  }

  @isTest
  public static void createHttpRequestFromApiConfigWithBody() {
    GeneralUtil.createHttpRequestFromApiConfigWithBody(
      'just a test',
      '{"Hello": "world"}'
    );
  }

  /** @Description: test for the retrieveFieldMappingMetadataList method
   * test both methods with different signature: String and List<String>
   * @Expected: more than one field-mapping records for each query.
   */
  @isTest
  public static void retrieveFieldMappingMetadataListTest() {
    Test.startTest();
    List<Fields_Mapping__mdt> fieldMappingMetadata = GeneralUtil.retrieveFieldMappingMetadataList(
      'zqu__Quote__c Zendesk Ticket Creation'
    );
    List<Fields_Mapping__mdt> fieldMappingMetadata2 = GeneralUtil.retrieveFieldMappingMetadataList(
      new List<String>{ 'zqu__Quote__c Zendesk Ticket Creation' }
    );
    Test.stopTest();
    System.assert(
      fieldMappingMetadata.size() > 0,
      'error in retrieveFieldMappingMetadataList(String)'
    );
    System.assert(
      fieldMappingMetadata2.size() > 0,
      'error in retrieveFieldMappingMetadataList(List<String>)'
    );
  }

  /** @date: 31/10/2022
   * @Description: test for the retrieveConfigurationMetadataTest mehod. make a get on the GeneralConfig with "test"
   * @Expected: at least one record will be found.
   */
  @isTest
  public static void retrieveConfigurationMetadataTest() {
    List<General_Configuration__mdt> cmdList = GeneralUtil.retrieveConfigurationMetadata(
      'test'
    );
    System.assertEquals(cmdList.size() > 0, true);
  }

  @isTest
  public static void generateBaseAuthHeaderValueTest() {
    Test.startTest();
    String baseAuthHeaderValue = GeneralUtil.generateBaseAuthHeaderValue(
      'username',
      'password'
    );
    Test.stopTest();
  }

  @isTest
  public static void generateAuthHeaderTest() {
    API_Configuration__mdt apiConfig = new API_Configuration__mdt();
    Test.startTest();
    GeneralUtil.generateAuthHeader(apiConfig);
    Test.stopTest();
  }

  @isTest
  public static void getConvertLeadStatus() {
    Test.startTest();
    LeadStatus leadStatus = GeneralUtil.CONVERT_LEAD_STATUS;
    Test.stopTest();
    System.assert(leadStatus != null);
  }

  /** @Description: test for the castObjectTo method
   * @Expected: Each casting type will return value without errors.
   */
  @isTest
  public static void testCasting() {
    Object result;
    Object obj;
    String castTo;
    Test.startTest();
    obj = 'True';
    castTo = 'Boolean';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = '154545';
    castTo = 'Integer';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +'is: ' +result);

    obj = '2021-10-29 20:03:20';
    castTo = 'Datetime';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +'is: '+result);

    obj = '2021-10-29';
    castTo = 'Date';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = '0067a00000HUQW8AAP';
    castTo = 'Id';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = '151.242';
    castTo = 'Decimal';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = '151.242242787984545';
    castTo = 'Double';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = '1234567890123456';
    castTo = 'Long';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = 'my Sample Text';
    castTo = 'String';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = '01/01/2021';
    castTo = 'String';
    result = GeneralUtil.castObjectTo(obj, castTo, 'DD/mm/yyyy');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);

    obj = '78975.23';
    castTo = 'String';
    result = GeneralUtil.castObjectTo(obj, castTo, '');
    //System.debug('====== ' +obj+ ' casted to '+ castTo +' is: '+ result);
    Test.stopTest();
  }

  /** @Description: test for the getKeyValuePairs method
   * @Expected: the results from the query wont be null.
   */
  @isTest
  public static void testMdtGetKeyValuePairs() {
    List<General_Key_Value_pair__mdt> pairs = new List<General_Key_Value_pair__mdt>(
      GeneralUtil.getKeyValuePairs('Campaign Creation Process')
    );
    System.assertNotEquals(
      pairs.size(),
      null,
      'Problem in Get Key Value Pairs'
    );
  }

  /** @Description: test for the getFieldSetTest method
   * @Expected: the results from the query wont be null.
   */
  @isTest
  public static void getFieldSetTest() {
    List<String> fieldSetList = GeneralUtil.getFieldSet(
      'Account',
      'zqu__Fields_For_Select_Billing_Account'
    );
    System.assertNotEquals(null, fieldSetList, 'Erro in getFieldSetTest');
  }

  /** @Description: test for the getFieldSetTest method
   * @Expected: the results from the query wont be null.
   */
  @isTest
  public static void getObjectNameFromIdTest() {
    String objName = GeneralUtil.getObjectNameFromId('0030X00002bixRdQAI');
    System.assertEquals(
      'contact',
      objName,
      'Error in getObjectNameFromId - object Name is not contact!'
    );
  }

  /** @Description: test for the createGetRequestTest method
   * @Expected:set enpoint and header and expect them to appear on the rquest.
   */
  @isTest
  public static void createGetRequestTest() {
    String endpoint = 'ep';
    Map<String, String> endpointPairs = new Map<String, String>();
    endpointPairs.put(endpoint, '01');

    String header = 'hd';
    Map<String, String> headerPairs = new Map<String, String>();
    headerPairs.put(header, '01');

    HttpRequest request = GeneralUtil.createGetRequest(
      'Test_Record',
      endpointPairs,
      headerPairs
    );
    System.assert(
      request.getEndpoint().contains(endpoint),
      'Error in endpoint: ' + request.getEndpoint()
    );
    System.assert(
      request.getHeader(header).contains('01'),
      'Error in Header: ' + request.getHeader(header)
    );
  }

  /** @Description: test for the createGetRequestTest method that adds parameter to the URL.
   * @Expected:set enpoint and header and expect them to appear on the rquest.
   * @Also, expect the 'additionalHeaderText' to appear on the Endpoing
   */
  @isTest
  public static void createGetRequestWithEnpointTest() {
    String endpoint = 'ep';
    Map<String, String> endpointPairs = new Map<String, String>();
    endpointPairs.put(endpoint, '01');

    String header = 'hd';
    Map<String, String> headerPairs = new Map<String, String>();
    headerPairs.put(header, '01');

    String addition = 'additionalHeaderText';
    HttpRequest request = GeneralUtil.createGetRequest(
      'Pardot_Read',
      endpointPairs,
      headerPairs,
      addition
    );
    System.assert(
      request.getEndpoint().contains(endpoint),
      'Error in endpoint: ' + request.getEndpoint()
    );
    System.assert(
      request.getHeader(header).contains('01'),
      'Error in Header: ' + request.getHeader(header)
    );
    System.assert(
      request.getEndpoint().contains(addition),
      'Error in endpoint addtition: ' + request.getHeader(header)
    );
  }

  /** @date: 05/10/2021
   * @Description: test for the getNetsuiteDailyExchangeRateMap mehod. Get the values from the custom metadata and compare them to the map
   * @Expected:the map size and rates will be equal when taken from the GeneralUtils class and from the Map
   */
  @isTest
  public static void getCurrencyForRate() {
    Map<String, Decimal> erMap = GeneralUtil.getNetsuiteDailyExchangeRateMap();
    List<Netsuite_Daily_Exchange_Rate__c> dailyExchangesList = Netsuite_Daily_Exchange_Rate__c.getAll()
      .values();
    System.assertEquals(dailyExchangesList.size(), erMap.keySet().size());
    for (Netsuite_Daily_Exchange_Rate__c nser : dailyExchangesList) {
      System.assertEquals(nser.USD_Exchange_Rate__c, erMap.get(nser.Name));
    }
  }

  /** @date: 31/10/2022
   * @Description: test for the hasSObjectField mehod. Check if there is a "Name" field on Account
   * @Expected: true
   */
  @isTest
  public static void hasSObjectFieldTest() {
    Account acc = new Account(Name = 'test name');
    System.assertEquals(GeneralUtil.hasSObjectField(acc, 'Name'), true);
  }

  /** @date: 31/10/2022
   * @Description: test for the getCountryCodeToName mehod. Check that countrycodes exists
   * @Expected: true
   */
  @isTest
  public static void getCountryCodeToNameTest() {
    Map<String, String> countryCodeToNameMap = GeneralUtil.getCountryCodeToName();
    System.assert(countryCodeToNameMap.keySet().size() > 0);
  }

  /** @date: 31/10/2022
   * @Description: test for the getKeyValuePairsMap mehod. make a get on the test record
   * @Expected: true
   */
  @isTest
  public static void getKeyValuePairsMapTest() {
    Map<String, String> keyValuePairsMap = GeneralUtil.getKeyValuePairsMap(
      'Test'
    );
    System.assert(keyValuePairsMap.keySet().size() > 0);
  }

  /** @date: 31/10/2022
   * @Description: test for the getSObjectPrefixByName mehod. Make sure Account is 001
   * @Expected: true
   */
  @isTest
  public static void getSObjectPrefixByNameTest() {
    String accountPrefix = GeneralUtil.getSObjectPrefixByName('Account');
    System.assert(accountPrefix == '001');
  }

  /** @date: 31/10/2022
   * @Description: test for the getSObjectPrefixByName method. Make sure Account is 001
   * @Expected: true
   */
  @isTest
  public static void getObjectNameFromSObjectTest() {
    Account acc = new Account(Name = 'testName');
    String sobjectName = GeneralUtil.getObjectNameFromSObject(acc);
    System.assert(sobjectName == 'account');
  }

  /** @date: 20/12/2022
   * @Description: test for the sendEmailNotifications, use dedicated test email template and the billing email notifications config
   * @Expected: true
   */
  @isTest
  public static void sendEmailNotifications() {
    Account acc = AccountUtils.getAccounts(1)[0];
    insert acc;
    GeneralUtil.sendEmailNotifications(
      new List<Id>{ acc.Id },
      'Test_for_sendEmailNotifications',
      'Billing_notification_email'
    );
  }
}

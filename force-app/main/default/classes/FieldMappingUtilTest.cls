@isTest
public class FieldMappingUtilTest {
  @TestSetup
  static void setup() {
    TestDataFactory.createSimilarWeb_CS();
    TestDataFactory.createBaseProductConfiguration_CS();
    TestDataFactory.createInferredSolutionSettings_CS();
    insert TestDataFactory.createBaseProductContract_CS();
    insert TestDataFactory.createBaseProductConfiguration_CS();
    insert TestDataFactory.createBaseProductControlling_CS();
    insert TestDataFactory.createBaseProductDependent_CS();
    insert TestDataFactory.createBaseProductDefaultAddon_CS();
    insert TestDataFactory.createBaseProductDynamicAddon_CS();
    insert TestDataFactory.createBaseProductNumOfUsers_CS();

    Account a = TestDataFactory.CreateAccount();
    a.billingcountry = 'Israel';
    insert a;
    Contact c = TestDataFactory.CreateContact(a, 'test@testing.com');
    c.MailingCountry = 'Israel';
    insert c;
    Opportunity opp = TestDataFactory.CreateOpportunity(a);
    insert opp;
    zqu__Quote__c quote = TestDataFactory.createZQuote(opp, c);
    insert quote;
  }

  @isTest
  static void generateFieldMappingDataTest() {
    String sObjType = 'zqu__Quote__c';
    zqu__Quote__c quoteObj = [SELECT Id FROM zqu__Quote__c LIMIT 1];
    List<Fields_Mapping__mdt> metadataFieldMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
      sObjType + ' Zendesk Ticket Creation'
    );
    List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(
      new Set<String>{ 'ZendeskGroupId', 'ZendeskTicketFromId', 'ZendeskTag' }
    );
    Test.startTest();
    FieldMappingUtil.FieldMappingData fieldMappingData = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(
      metadataFieldMappingList
    );
    FieldMappingUtil.FieldMappingData generalConfFieldMappingData = FieldMappingUtil.generateFieldMappingDataFromGeneralConfigCMT(
      generalConfigurationList
    );
    fieldMappingData.mergeFieldMappingData(generalConfFieldMappingData);
    SObject sourceRecord = querySObject(
      fieldMappingData.sourceFieldSet,
      sObjType,
      quoteObj.id
    );
    fieldMappingData.populateValuesFromSObject(sourceRecord);
    Object destination = fieldMappingData.fieldMappingDataUnitMap.get('subject')
      .getDestinationField();
    String value = (String) fieldMappingData.fieldMappingDataUnitMap.get(
        'subject'
      )
      .getValue();
    String valueDescription = (String) fieldMappingData.fieldMappingDataUnitMap.get(
        'description'
      )
      .getValue();

    Test.stopTest();
    System.assert(
      fieldMappingData.sourceFieldSet.size() > 0 &&
        fieldMappingData.fieldMappingDataUnitMap.size() > 0 &&
        value.length() > 0
    );
  }

  @isTest
  public static void testPopulateValues() {
    List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
      'Account to Related Contacts'
    );
    FieldMappingUtil.FieldMappingData fmd = FieldMappingUtil.generateFieldMappingDataFromFieldMappingCMT(
      fieldsMappingList
    );
    String query = fmd.getRecordsFromSObject('Account', 'Id');
    String query2 = fmd.getRecordsFromDestinationSObject('Contact', 'Id');
    Account acc = Database.query(query);
    SObject mySObject = fmd.populateValuesAndReturnSObject(acc, acc);
    String df = FieldMappingUtil.dateFormat;
  }

  private static SObject querySObject(
    Set<String> fieldToQueryList,
    String sObjType,
    String sObjectId
  ) {
    String query =
      'SELECT ' +
      String.join(new List<String>(fieldToQueryList), ',') +
      ' FROM ' +
      sObjType +
      ' WHERE Id =:sObjectId' +
      ' LIMIT 1';
    List<SObject> responseSobjList = Database.query(
      String.escapeSingleQuotes(query)
    );

    return responseSobjList[0];
  }
}

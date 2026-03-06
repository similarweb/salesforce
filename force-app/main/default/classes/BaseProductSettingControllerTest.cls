@isTest
public class BaseProductSettingControllerTest {
  @isTest
  public static void retreiveBaseProductContractValuesTest() {
    Test.startTest();
    Response response = BaseProductSettingController.retreiveBaseProductContractValues();
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.retreiveBaseProductContractValues();
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  /* @isTest
    public static void addBaseProductContractValuesTest() {
        String valuesListRaw = 'Test2\nTest3';
        Test.startTest();
        Response response = BaseProductSettingController.addBaseProductContractValues(valuesListRaw);
        MockUtil.isSuccessfull = false;
        Response faultResponse = BaseProductSettingController.addBaseProductContractValues(valuesListRaw);
        Test.stopTest();
        System.assertEquals(true,response.success);
        System.assertEquals(false,faultResponse.success);
    }

    @isTest
    public static void editBaseProductContractValuesTest() {
        Test.startTest();
        Response response = BaseProductSettingController.editBaseProductContractValues('Test1','EditedLabel');
        MockUtil.isSuccessfull = false;
        Response faultResponse = BaseProductSettingController.editBaseProductContractValues('Test1','EditedLabel');
        Test.stopTest();
        System.assertEquals(true,response.success);
        System.assertEquals(false,faultResponse.success);
    } 

    @isTest
    public static void deleteBaseProductContractValuesTest() {
        Test.startTest();
        Response response = BaseProductSettingController.deleteBaseProductContractValues('Test1');
        MockUtil.isSuccessfull = false;
        Response faultResponse = BaseProductSettingController.editBaseProductContractValues('Test1','EditedLabel');
        Test.stopTest();
        System.assertEquals(true,response.success);
        System.assertEquals(false,faultResponse.success);
    } */

  @isTest
  public static void retreiveBaseProductPicklistValuesTest() {
    Test.startTest();
    Response response = BaseProductSettingController.retreiveBaseProductPicklistValues();
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.retreiveBaseProductPicklistValues();
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void addBaseProductPicklistValuesTest() {
    String fullNameListRaw = 'Test2\nTest3';
    Test.startTest();
    Response response = BaseProductSettingController.addBaseProductPicklistValues(
      fullNameListRaw
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.addBaseProductPicklistValues(
      fullNameListRaw
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void deleteBaseProductPicklistValuesTest() {
    String fullNameToDelete = 'Test1';
    Test.startTest();
    Response response = BaseProductSettingController.deleteBaseProductPicklistValues(
      fullNameToDelete
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.deleteBaseProductPicklistValues(
      fullNameToDelete
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void editBaseProductPicklistValuesTest() {
    String newLabel = 'newTest1';
    String fullName = 'Value1';
    Test.startTest();
    Response response = BaseProductSettingController.editBaseProductPicklistValues(
      fullName,
      newLabel
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.editBaseProductPicklistValues(
      fullName,
      newLabel
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void retreiveWorldListPicklistValuesForDependentValueTest() {
    String controllingFieldValue = 'Controlling field name';
    Test.startTest();
    Response response = BaseProductSettingController.retreiveWorldListPicklistValuesForDependentValue(
      controllingFieldValue
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.retreiveWorldListPicklistValuesForDependentValue(
      controllingFieldValue
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void addWorldListPicklistValueTest() {
    String fullNameListRaw = 'newTest1\nnewTest2';
    Test.startTest();
    Response response = BaseProductSettingController.addWorldListPicklistValue(
      fullNameListRaw
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.addWorldListPicklistValue(
      fullNameListRaw
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void addDependencyWorldListPicklistValueTest() {
    List<String> fullNameList = new List<String>{ 'newTest1', 'newTest2' };
    String fullNameListRaw = JSON.serialize(fullNameList);
    String controllingFieldValue = 'Controlling field name';
    Test.startTest();
    Response response = BaseProductSettingController.addDependencyWorldListPicklistValue(
      controllingFieldValue,
      fullNameListRaw
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.addDependencyWorldListPicklistValue(
      controllingFieldValue,
      fullNameListRaw
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void deleteWorldListPicklistValueTest() {
    String fullNameToDelete = 'Value1';
    Test.startTest();
    Response response = BaseProductSettingController.deleteWorldListPicklistValue(
      fullNameToDelete
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.deleteWorldListPicklistValue(
      fullNameToDelete
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void editWorldListPicklistValuesTest() {
    String newLabel = 'newTest1';
    String fullName = 'Value1';
    Test.startTest();
    Response response = BaseProductSettingController.editWorldListPicklistValues(
      fullName,
      newLabel
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.editWorldListPicklistValues(
      fullName,
      newLabel
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void retrieveDefaultAddonsForBaseProductTest() {
    String fullName = 'Value1';
    Test.startTest();
    Response response = BaseProductSettingController.retrieveDefaultAddonsForBaseProduct(
      fullName
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.retrieveDefaultAddonsForBaseProduct(
      fullName
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void retrieveDynamicAddonsForBaseProductTest() {
    String fullName = 'Value1';
    Test.startTest();
    Response response = BaseProductSettingController.retrieveDynamicAddonsForBaseProduct(
      fullName
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.retrieveDynamicAddonsForBaseProduct(
      fullName
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void retrieveDefaultNumberOfUsersForBaseProductTest() {
    String fullName = 'Value1';
    Test.startTest();
    Response response = BaseProductSettingController.retrieveDefaultNumberOfUsersForBaseProduct(
      fullName
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.retrieveDefaultNumberOfUsersForBaseProduct(
      fullName
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void setDefaultAddonsForBaseProductTest() {
    String fullNameListRaw = 'Value1,Value2';
    String controllingName = 'controllingName1';
    Test.startTest();
    Response response = BaseProductSettingController.setDefaultAddonsForBaseProduct(
      fullNameListRaw,
      controllingName
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.setDefaultAddonsForBaseProduct(
      fullNameListRaw,
      controllingName
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void setDynamicAddonsForBaseProductTest() {
    String fullNameListRaw = 'Value1,Value2';
    String controllingName = 'controllingName1';
    Test.startTest();
    Response response = BaseProductSettingController.setDynamicAddonsForBaseProduct(
      fullNameListRaw,
      controllingName
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.setDynamicAddonsForBaseProduct(
      fullNameListRaw,
      controllingName
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }

  @isTest
  public static void setDefaultNumberOfUsersForBaseProductTest() {
    Integer numberOfUsers = 5;
    String controllingName = 'controllingName1';
    Test.startTest();
    Response response = BaseProductSettingController.setDefaultNumberOfUsersForBaseProduct(
      numberOfUsers,
      controllingName
    );
    MockUtil.isSuccessfull = false;
    Response faultResponse = BaseProductSettingController.setDefaultNumberOfUsersForBaseProduct(
      numberOfUsers,
      controllingName
    );
    Test.stopTest();
    System.assertEquals(true, response.success);
    System.assertEquals(false, faultResponse.success);
  }
}

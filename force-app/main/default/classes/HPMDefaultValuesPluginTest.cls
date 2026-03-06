@isTest
public class HPMDefaultValuesPluginTest {
  @isTest
  static void getAdditionalParametersTest() {
    Test.startTest();
    PageReference pageRef = Page.AccountRedirect;
    Test.setCurrentPage(pageRef);
    pageRef.getParameters().put('field_accountId', String.valueOf('testId'));
    HPMDefaultValuesPlugin hPMDefaultValuesPlugin = new HPMDefaultValuesPlugin();
    Map<String, String> additionalParameterMap = hPMDefaultValuesPlugin.getAdditionalParameters(
      'TestMethod'
    );
    Test.stopTest();
  }
}

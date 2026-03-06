@isTest
public class ChatGPTControllerTest {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;
  }

  @isTest
  static void testGetChatGPTResponseSuccess() {
    Lead testLead = new Lead(
      LastName = 'Test Lead',
      Company = 'Test Company',
      Email = 'test@tos.com',
      Website = 'www.test.com'
    );
    insert testLead;

    Test.setMock(HttpCalloutMock.class, new OpenAIApiMock(true));

    Test.startTest();
    String result = ChatGPTController.getChatGPTResponse(testLead.Id);
    Test.stopTest();

    System.assertNotEquals(null, result, 'Result should not be null');
    System.assertNotEquals(
      'Error: Error',
      result,
      'Result should not be an error message'
    );
  }

  @isTest
  static void testGetChatGPTResponseError() {
    Lead testLead = new Lead(
      LastName = 'Test Lead',
      Company = 'Test Company',
      Email = 'test@tos.com',
      Website = 'www.test.com'
    );
    insert testLead;

    Test.setMock(HttpCalloutMock.class, new OpenAIApiMock(false));

    Test.startTest();
    String result = ChatGPTController.getChatGPTResponse(testLead.Id);
    Test.stopTest();

    System.assertEquals(
      true,
      result.contains('Error'),
      'Result should be an error message'
    );
  }
}

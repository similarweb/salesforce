@isTest
public class AddNewACHCallbackTest {
  @isTest
  static void processCallbackParametersTest() {
    Test.startTest();
    AddNewACHCallback addNewACHCallback = new AddNewACHCallback();
    addNewACHCallback.processCallbackParameters();
    Test.stopTest();
  }
}

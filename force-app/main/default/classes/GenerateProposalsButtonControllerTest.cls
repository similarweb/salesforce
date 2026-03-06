@isTest
public class GenerateProposalsButtonControllerTest {
  @TestSetup
  static void setup() {
  }

  @isTest
  static void testSuccess() {
    MockUtil.isSuccessfull = true;
    Test.startTest();
    GenerateProposalsButtonController.generateProposals('quoteId');
    Test.stopTest();
  }

  @isTest
  static void testFalse() {
    MockUtil.isSuccessfull = false;
    Test.startTest();
    GenerateProposalsButtonController.generateProposals('quoteId');
    Test.stopTest();
  }
}

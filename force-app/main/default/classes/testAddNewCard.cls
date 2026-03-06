@IsTest(SeeAllData=true)
public with sharing class testAddNewCard {
  static testMethod void AddNewCardTest() {
    Test.startTest();

    // Instantiate Your Test Controller
    AddNewCard anc = new AddNewCard();
    anc.getExtraParameters();
    anc.successActions();
    anc.getPageRef();
    anc.getBackURL();
    anc.getNextURL();
    anc.navigateBack();
    // Call all the methods in your Class
    anc.getNewTypeOptions();
    anc.changeType();

    anc.hostedPageChange = 'NewACH';
    anc.changeType();

    anc.hostedPageChange = 'NewCreditCard';
    anc.changeType();

    Test.stopTest();
  }
}

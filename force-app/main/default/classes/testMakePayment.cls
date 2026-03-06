/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(SeeAllData=true)
private class testMakePayment {
  static testMethod void MakePaymentTest() {
    Test.startTest();

    MakePayment mp = new MakePayment();

    mp.confirmError();
    mp.makePaymentNow();
    mp.paymentType = 'electronic';
    mp.makePaymentNow();
    mp.cancel();
    mp.getPaymentMethodOptions();
    mp.getExternalPaymentMethodOptions();
    mp.updateValues();
    mp.updateInvoiceTotal();
    mp.updateTotal();
    mp.updateDate();
    mp.getPageRef();
    mp.getExtraParameters();
    mp.getBackURL();
    mp.navigateBack();
    mp.getNextUrl();
    mp.getPaymentTypeOptions();
    mp.toACH();
    mp.updateRemaining();
    mp.successActions();
    mp.cancelValidation();
    mp.getValidateMonthOptions();
    mp.getValidateYearOptions();
    mp.validateInfo();
    mp.openValidation();

    Test.stopTest();
  }
}

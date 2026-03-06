@isTest
public with sharing class WSVATServiceTest {
  @isTest
  static void checkIsVatValidTest() {
    Test.starttest();
    Test.setMock(
      WebServiceMock.class,
      new CheckVatServiceMockImpl('IE', '6388047V')
    );
    Boolean isVatValid = new WSVATService().checkIsVatValid('IE', '6388047V');
    Test.stoptest();
  }

  @isTest
  static void checkIsVatValid2Test() {
    Test.starttest();
    Test.setMock(
      WebServiceMock.class,
      new CheckVatServiceMockImpl('IE', '6388047V')
    );
    Boolean isVatValid = new WSVATService().checkIsVatValid('IE 6388047V');
    Test.stoptest();
  }

  @isTest
  static void checkVatTest() {
    Test.starttest();
    Test.setMock(
      WebServiceMock.class,
      new CheckVatServiceMockImpl('IE', '6388047V')
    );
    String output = new WSVATService().checkVat('IE', '6388047V');
    Test.stoptest();
  }

  @isTest
  static void checkVatAproxTest() {
    Test.starttest();
    Test.setMock(
      WebServiceMock.class,
      new CheckVatAproxServiceMockImpl(
        'IE',
        '6388047V',
        '',
        '',
        '',
        '',
        '',
        'IE',
        '6388047V'
      )
    );
    String output = new WSVATService()
      .checkVatAprox('IE', '6388047V', '', '', '', '', '', 'IE', '6388047V');
    Test.stoptest();
  }
}

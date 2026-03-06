@isTest
public with sharing class JwtCredentialsTest {
  @TestSetup
  static void setup() {
    insert TestDataFactory.createBaseProductConfiguration_CS();
  }

  @isTest
  static void test() {
    JwtCredentials.getInstance().getAccessToken();
  }
}

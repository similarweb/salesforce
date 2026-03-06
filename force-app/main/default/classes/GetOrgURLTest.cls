@isTest
public with sharing class GetOrgURLTest {
  @isTest
  private static void test() {
    Response resp = GetOrgURL.getUrl();
    String urlToCheck = URL.getSalesforceBaseUrl().toExternalForm();
    System.assertEquals(urlToCheck, resp.message);
  }
}

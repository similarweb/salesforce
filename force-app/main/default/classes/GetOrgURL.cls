public with sharing class GetOrgURL {
  @AuraEnabled
  public static Response getUrl() {
    Response resp;
    resp = new Response(URL.getSalesforceBaseUrl().toExternalForm());
    System.debug(resp);
    return resp;
  }
}

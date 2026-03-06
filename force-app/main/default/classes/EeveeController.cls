public with sharing class EeveeController {
  @AuraEnabled(cacheable=false)
  public static String getData(String recordId) {
    String iframeUrl = 'https://eevee.int.similarweb.io/agent/deck';

    Account a = [
      SELECT
        Id,
        Website,
        BillingCountryCode,
        BI_Data__c,
        BI_Data__r.Top_10_Searches__c
      FROM Account
      WHERE Id = :recordId
    ];

    iframeUrl +=
      '?primary=' +
      (a.Website == 'no_website' || String.isBlank(a.Website)
        ? 'N/A'
        : a.Website);
    iframeUrl +=
      '&country=' +
      (String.isBlank(a.BillingCountryCode)
        ? 'N/A'
        : a.BillingCountryCode.toLowerCase());

    if (
      String.isNotBlank(a.BI_Data__c) &&
      String.isNotBlank(a.BI_Data__r.Top_10_Searches__c)
    ) {
      List<String> competitors = a.BI_Data__r.Top_10_Searches__c.split(', ');
      List<String> top4Competitors = new List<String>();
      Integer cnt = 0;

      for (String c : competitors) {
        if (cnt < 4) {
          top4Competitors.add(c);
          cnt++;
        } else {
          break;
        }
      }

      iframeUrl += '&competitors=' + String.join(top4Competitors, ',');
    }

    return iframeUrl;
  }

  @AuraEnabled(cacheable=false)
  public static String getContactEmailsData(String recordId) {
    String iframeUrl = 'https://eevee.int.similarweb.io/agent/draft---30-second-pe';

    Contact c = [
      SELECT
        Id,
        Website_Domain__c,
        MailingCountryCode,
        LinkedIn_Profile__c,
        Title
      FROM Contact
      WHERE Id = :recordId
    ];

    iframeUrl +=
      '?company_domain=' +
      (String.isBlank(c.Website_Domain__c) ? 'N/A' : c.Website_Domain__c);
    iframeUrl +=
      '&country=' +
      (String.isBlank(c.MailingCountryCode) ? 'N/A' : c.MailingCountryCode);
    iframeUrl +=
      '&linkedin_url=' +
      (String.isBlank(c.LinkedIn_Profile__c)
        ? (String.isBlank(c.Title) ? 'N/A' : c.Title)
        : c.LinkedIn_Profile__c);

    return iframeUrl;
  }
}

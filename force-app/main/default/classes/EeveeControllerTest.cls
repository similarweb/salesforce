@isTest
private class EeveeControllerTest {
  @testSetup
  static void setup() {
    Inferral_Solution_Settings__c iss = new Inferral_Solution_Settings__c();
    iss.Name = 'Default Value';
    iss.Value__c = 'Sales';
    insert iss;
  }

  @isTest
  static void testGetData_NoWebsite_NoCountry_NoCompetitors() {
    Account a = new Account(
      Name = 'NoWebAcct',
      Website = 'no_website'
      // BillingCountryCode left null
    );
    insert a;

    Test.startTest();
    String url = EeveeController.getData(a.Id);
    Test.stopTest();

    System.assert(
      url.startsWith('https://eevee.int.similarweb.io/agent/deck?primary=N/A'),
      'primary should be N/A for no_website'
    );
    System.assert(
      url.contains('&country=N/A'),
      'country should be N/A when BillingCountryCode is blank'
    );
    System.assert(
      !url.contains('&competitors='),
      'competitors param should be absent when BI data missing'
    );
  }

  @isTest
  static void testGetData_WithWebsite_Country_AndCompetitors_Top4() {
    Account a = new Account(
      Name = 'WithBI',
      Website = 'example.com',
      BillingCountryCode = 'US'
    );
    insert a;

    Account updatedAcc = [SELECT Id, BI_Data__c FROM Account WHERE Id = :a.Id];

    BI_Data__c biData = [
      SELECT Id, Top_10_Searches__c
      FROM BI_Data__c
      WHERE Id = :updatedAcc.BI_Data__c
    ];
    biData.Top_10_Searches__c = 'compA, compB, compC, compD, compE';
    update biData;

    Test.startTest();
    String url = EeveeController.getData(a.Id);
    Test.stopTest();

    System.debug('My URL: ' + url);

    System.assert(
      url.contains('?primary=example.com') ||
      url.contains('&primary=example.com'),
      'primary should contain the account website'
    );
    System.assert(url.contains('&country=us'), 'country should be lowercased');
    // Top 4 competitors should be joined by commas
    System.assert(
      url.contains('&competitors=compA,compB,compC,compD'),
      'competitors should contain top 4 values joined by comma'
    );
  }

  @isTest
  static void testGetContactEmailsData_WithDomainAndCountry() {
    Account a = new Account(Name = 'Test Account', Website = 'example.com');
    insert a;

    Contact c = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      AccountId = a.Id,
      Email = 'john.doe@example.com',
      MailingCountryCode = 'US',
      LinkedIn_Profile__c = 'https://linkedin.com/in/johndoe'
    );
    insert c;

    Test.startTest();
    String url = EeveeController.getContactEmailsData(c.Id);
    Test.stopTest();

    System.assert(
      url.startsWith(
        'https://eevee.int.similarweb.io/agent/draft---30-second-pe'
      ),
      'URL should start with correct endpoint'
    );
    System.assert(
      url.contains('company_domain=example.com'),
      'company_domain should match Website_Domain__c'
    );
    System.assert(
      url.contains('&country=') && !url.contains('&country=N/A'),
      'country parameter should be present and not N/A'
    );
    System.assert(
      url.contains('&linkedin_url=https://linkedin.com/in/johndoe'),
      'linkedin_url should match LinkedIn_Profile__c'
    );
  }

  @isTest
  static void testGetContactEmailsData_NoDomainNoCountry() {
    Account a = new Account(Name = 'Test Account No Website');
    insert a;

    Contact c = new Contact(
      FirstName = 'Jane',
      LastName = 'Smith',
      AccountId = a.Id,
      Email = 'jane.smith@test.com'
      // MailingCountryCode and LinkedIn_Profile__c left null
    );
    insert c;

    Test.startTest();
    String url = EeveeController.getContactEmailsData(c.Id);
    Test.stopTest();

    System.assert(
      url.contains('company_domain=N/A'),
      'company_domain should be N/A when Account.Website is blank'
    );
    System.assert(
      url.contains('&country=N/A'),
      'country should be N/A when MailingCountryCode is blank'
    );
    System.assert(
      url.contains('&linkedin_url=N/A'),
      'linkedin_url should be N/A when LinkedIn_Profile__c is blank'
    );
  }
}

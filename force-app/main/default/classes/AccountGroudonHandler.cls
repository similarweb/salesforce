public with sharing class AccountGroudonHandler implements GroudonQueueable.GroudonHandler {
  public List<Account> accounts;

  public AccountGroudonHandler(Account a) {
    this.accounts = new List<Account>{ a };
  }

  public AccountGroudonHandler(List<Account> accounts) {
    this.accounts = accounts;
  }

  public void process() {
    List<Log_Event__e> eventList = new List<Log_Event__e>();
    API_Configuration__mdt apiConfiguration = GeneralUtil.getAPIConfig(
      'Groudon_Integration'
    );

    GroudonIntegrationService groudonService = new GroudonIntegrationService(
      new AccountGroudonRequestGenerator(),
      new AccountGroudonResponseGenerator(),
      apiConfiguration
    );

    try {
      GroudonIntegrationService.GroudonResponse response = this.accounts.size() >
        1
        ? groudonService.callGroudonBulk(this.accounts)
        : groudonService.callGroudon(this.accounts.get(0));

      for (Account a : this.accounts) {
        fillLog(a, response, eventList);
      }
    } catch (Exception ex) {
      Log_Event__e log = new Log_Event__e();
      log.Email__c = this.accounts.size() > 1
        ? 'mass update'
        : this.accounts.isEmpty() ? 'no accounts' : this.accounts[0].Name;
      log.Apex_class__c = 'GroudonIntegrationService';
      log.Apex_Method__c = 'callGroudon';
      log.Record_Ids__c = this.accounts.size() > 1
        ? 'mass update'
        : this.accounts.isEmpty() ? 'no accounts' : this.accounts[0].id;
      log.Log_Type__c = 'Error';
      log.Http_Body__c = 'no payload available';
      log.Detailed_Error_Message__c =
        ex.getMessage() +
        ' ' +
        ex.getStackTraceString();
      log.SF_Type__c = 'Account';
      eventList.add(log);
    }
    List<Account> accountsAfterLambdaCallout = [
      SELECT Id
      FROM Account
      WHERE Id IN :this.accounts
    ];
    for (Account a : accountsAfterLambdaCallout) {
      a.Force_Enrichment__c = false;
      a.Groudon_Timestamp__c = Datetime.now();
      a.Groudon_Enrichment_Date__c = Datetime.now();
      a.Groudon_Call_Status__c = 'Enrichment_Ended';
    }

    if (!eventList.isEmpty()) {
      Eventbus.publish(eventList);
    }

    update accountsAfterLambdaCallout;
  }

  private void fillLog(
    Account a,
    GroudonIntegrationService.GroudonResponse response,
    List<Log_Event__e> eventList
  ) {
    Log_Event__e log = new Log_Event__e();
    log.Email__c = a.Name;
    log.Apex_Method__c = this.accounts.size() > 0
      ? 'callGroudonBulk'
      : 'callGroudonSingle';
    log.Apex_class__c = 'GroudonIntegrationService';
    log.Record_Ids__c = a.id;
    log.Log_Type__c = response.isSuccess ? 'Info' : 'Error';
    log.Http_Body__c = response.leadIdToBodyMap.get(a.Id);
    log.Sub_Type__c = 'callGroudon';
    log.SF_Type__c = 'Account';
    eventList.add(log);
  }

  public class AccountGroudonRequestGenerator implements GroudonQueueable.GroudonRequestGenerator {
    public GroudonIntegrationService.GroudonRequest generate(SObject record) {
      Account accountItem = (Account) record;

      GroudonIntegrationService.GroudonRequest requestBody = new GroudonIntegrationService.GroudonRequest();

      requestBody.first_name = null;
      requestBody.last_name = null;
      requestBody.domain = accountItem.Website_Domain__c;
      requestBody.Country_Code = accountItem.Country_Code_ISO3__c;
      requestBody.email = accountItem.Email__c;
      requestBody.industry = accountItem.SW_Industry__c;
      requestBody.website = accountItem.Website;
      requestBody.Business_Unit = accountItem.Business_Unit__c;
      requestBody.Clean_Domain = accountItem.Clean_Domain__c;
      requestBody.country = accountItem.BillingCountry;
      requestBody.Email_address_domain_type = accountItem.Email_address_domain_type_SFDC__c;
      requestBody.Employees_Min = accountItem.Employees_Min__c;
      requestBody.Company = accountItem.Name;
      requestBody.sf_id = accountItem.Id;
      requestBody.timestamp = Datetime.now();
      requestBody.sf_type = 'Account';

      return requestBody;
    }
  }

  public class AccountGroudonResponseGenerator implements GroudonQueueable.GroudonResponseGenerator {
    public GroudonIntegrationService.GroudonResponse generate(
      List<GroudonIntegrationService.GroudonRequest> requestBodies
    ) {
      GroudonIntegrationService.GroudonResponse groudonResponse = new GroudonIntegrationService.GroudonResponse();

      for (GroudonIntegrationService.GroudonRequest r : requestBodies) {
        groudonResponse.accountIdToBodyMap.put(
          r.sf_id,
          JSON.serializePretty(r, true)
        );
      }

      return groudonResponse;
    }
  }
}

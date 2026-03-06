/**
 * @author Itzik Winograd
 * @date 03/08/2022
 * @description MIS-2458, MIS-2367: look for accounts with Billing_Expert_Changed__c = true and pass the BillingExpert - the ARSpecialist - to YayPay.
 *              Upon success, remove the flag from the Account.
 */
public without sharing class YayPaySetARSpecialistBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
  private List<Log_Event__e> logEvents = new List<Log_Event__e>();
  private String accessToken;
  private final Integer CALLS_LIMIT = 40;
  private final String YAYPAY_RESCHEDULED_JOB_NAME = 'YayPaySetARSpecialistBatch - Scheduled';
  private final String BILLING_ACCOUNT_CUSTOM_QUERY = 'YayPay_GetBillingAccountsForYayPayUpdate';
  private final Integer MINUTES_BETWEEN_BATCHES = Integer.valueOf(
    GeneralUtil.getGeneralConfig('YayPayTimeBetweenBatches').Number_Value__c
  );
  private integer callsCount = 0;
  public Boolean alreadyScheduled = false;

  /**
   * @author Itzik Winograd
   * @description Batch start. Get yaypay token and use CMD to query for flagged accounts
   */
  public Database.QueryLocator start(Database.BatchableContext BC) {
    accessToken = YayPayUtils.getYayPayAccessToken('v1');
    String accountsQuery;
    if (accessToken.contains('error')) {
      logEvents.add(
        LogEventUtils.createLogEventRecord(
          null,
          'YayPaySetARSpecialistBatch',
          'execute',
          'Error: Failed to get Access Token',
          accessToken,
          'Error'
        )
      );
      accountsQuery = null; //This would cause an error on the return statement.
    } else {
      accountsQuery = CustomQueriesUtils.getCustomQuery(
        BILLING_ACCOUNT_CUSTOM_QUERY
      );
      System.debug(
        '### YayPaySetARSpecialistBatch query: ' +
        Database.getQueryLocator(accountsQuery)
      );
    }
    return Database.getQueryLocator(accountsQuery);
  }

  /**
   * @author Itzik Winograd
   * @description Batch execute. If there is no Billing_expert__c or the response from YayPay is OK - uncheck the flag on the account.
   */
  public void execute(
    Database.BatchableContext BC,
    List<Account> scopeAccounts
  ) {
    List<Account> accountsToUpdateList = new List<Account>();
    for (Account acc : scopeAccounts) {
      if (callsCount < CALLS_LIMIT) {
        System.debug(
          '### YayPaySetARSpecialistBatch - callsCount: ' + callsCount
        );
        Boolean sendARSpecialistSucceeded = sendARSpecialistRequest(
          accessToken,
          acc.Id,
          acc.Latest_Zuora_Account_ID__c,
          acc.Billing_expert__r.email
        );
        if (
          acc?.Billing_expert__r?.email == null ||
          acc?.Latest_Zuora_Account_ID__c == null ||
          sendARSpecialistSucceeded
        ) {
          accountsToUpdateList.add(
            new Account(Id = acc.Id, Billing_Expert_Changed__c = false)
          );
        }
      }
    }
    if (!accountsToUpdateList.isEmpty()) {
      updateAccounts(accountsToUpdateList);
    }
    if (callsCount >= CALLS_LIMIT && !alreadyScheduled) {
      //if there are more account records to process
      try {
        rescheduleJob();
      } catch (Exception ex) {
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<Id>(),
            'YayPaySetARSpecialistBatch',
            'execute',
            'Unable to schedule future job',
            ex.getMessage(),
            'Error'
          )
        );
      }
    }
    if (!logEvents.isEmpty()) {
      EventBus.publish(logEvents);
      logEvents.clear();
    }
    if (alreadyScheduled == true) {
      System.debug('### YayPaySetARSpecialistBatch: Aborting job!');
      System.abortJob(BC.getJobId());
    }
  }

  /**
   * @author Itzik Winograd
   * @description reschedule the bath job since the remote limit was hit.
   */
  public void rescheduleJob() {
    System.debug('### YayPaySetARSpecialistBatch: Rescheduling job!');
    String cronExpression = createCronExpression();
    abortCurrentBatchJobs();
    System.schedule(
      YAYPAY_RESCHEDULED_JOB_NAME + ' - ' + cronExpression,
      cronExpression,
      new YayPaySetARSpecialistScheduler()
    );
    alreadyScheduled = true;
  }

  /**
   * @author Itzik Winograd
   * @description abort all current running scheduled ARSpecialist batch jobs
   */
  public void abortCurrentBatchJobs() {
    List<CronTrigger> jobsList = [
      SELECT Id, CronJobDetail.Name
      FROM CronTrigger
      WHERE CronJobDetail.Name LIKE :(YAYPAY_RESCHEDULED_JOB_NAME + '%')
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    for (CronTrigger job : jobsList) {
      System.abortJob(job.Id);
    }
  }

  /**
   * @author Itzik Winograd
   * @description Create a cron expression for datetime now + x minutes from custom metadata
   */
  public String createCronExpression() {
    Integer schedulerMinute = DateTime.now().minute() + MINUTES_BETWEEN_BATCHES;
    Integer year = Datetime.now().year();
    Integer month = Datetime.now().month();
    Integer day = Datetime.now().day();
    Integer hour = Datetime.now().hour();
    //        String dayOfWeek = Datetime.now().format('E');
    String dayOfWeek = '?';
    String cronExpression =
      '0 ' +
      schedulerMinute +
      ' ' +
      hour +
      ' ' +
      day +
      ' ' +
      month +
      ' ' +
      dayOfWeek +
      ' ' +
      year;
    System.debug(
      '### yayPaySetARSpecialistRequest cronExpression: ' + cronExpression
    );
    return cronExpression;
  }

  /**
   * @author Itzik Winograd
   * @description Sends the response to YayPay. Create a log on failures, return boolean on the call success.
   * @param String accessToken
   * @param String accountId
   * @param String customerInternalId
   * @param String email
   */
  private Boolean sendARSpecialistRequest(
    String accessToken,
    String accountId,
    String customerInternalId,
    String email
  ) {
    Boolean successSetToYayPay = false;
    if (customerInternalId == null) {
      successSetToYayPay = true;
    } else {
      HttpRequest req = YayPayUtils.setARSpecialistInYayPay(
        accessToken,
        customerInternalId,
        email
      );
      Http http = new Http();
      HTTPResponse res = http.send(req);
      callsCount += 1;
      if (res.getStatusCode() < 299) {
        successSetToYayPay = true;
      } else {
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<String>{ accountId },
            'YayPaySetARSpecialistBatch',
            'execute',
            '',
            'Error from YayPay: ' + res.getBody(),
            'Error',
            req,
            new List<String>{ req.getHeader('Authorization') }
          )
        );
      }
    }
    return successSetToYayPay;
  }

  /**
   * @author Itzik Winograd
   * @description removes the Billing_Expert_Changed__c from the accounts
   * @param List<Account> accountsToUpdateList
   */
  private void updateAccounts(List<Account> accountsToUpdateList) {
    List<Database.SaveResult> resultsList = Database.update(
      accountsToUpdateList,
      false
    );
    for (Integer i = 0; i < resultsList.size(); i++) {
      Database.SaveResult result = resultsList[i];
      if (!result.isSuccess()) {
        logEvents.add(
          LogEventUtils.createLogEventRecord(
            new List<String>{ accountsToUpdateList[i].Id },
            'YayPaySetARSpecialistBatch',
            'execute',
            JSON.serialize(resultsList[i]),
            'Can\'t remove the ChangeBillingExpert flag from the account. Error:' +
            result.getErrors().toString(),
            'Error'
          )
        );
      }
    }
  }

  /**
   * @author Itzik Winograd
   * @description Batch finish method.
   */
  public void finish(Database.BatchableContext BC) {
    System.debug('### yayPaySetARSpecialistRequest finish!');
  }
}

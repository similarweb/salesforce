/*
 * Made by Viktoriia from Synebo
 */
global class BusinessUnitUpdateBatch implements Database.Batchable<sObject>, Schedulable {
  private static final Integer TIME_MARGIN = 1;
  private static Integer LAST_N_DAYS = 7;
  private String query;
  private DateTime previousRunTime;
  private Integer batchSize = 10;

  private Map<String, String> domainFieldsMap;

  global BusinessUnitUpdateBatch() {
  }

  global BusinessUnitUpdateBatch(Integer batchSize, DateTime previousTime) {
    this.batchSize = batchSize;
    this.previousRunTime = previousTime;
  }

  global BusinessUnitUpdateBatch(DateTime previousTime) {
    this.previousRunTime = previousTime;
  }

  global void execute(SchedulableContext SC) {
    //        //Schedule the batch in that value of minutes that is set in custom settings
    //        List<CronTrigger> cts = [SELECT ID, PreviousFireTime, NextFireTime, CronExpression, CronJobDetail.Name  FROM crontrigger
    //                            WHERE Id=: SC.getTriggerId() ];
    //        System.abortJob(SC.getTriggerId());
    //
    //        List<BatchTimePeriodsSettings__c> cs = [SELECT Name , Value__c
    //                                          		FROM  BatchTimePeriodsSettings__c
    //                                          		WHERE Name =: cts.get(0).CronJobDetail.Name
    //                                          		LIMIT 1];
    //        Integer schedulerMinute = DateTime.now().minute() + (cs.isEmpty() ? 30 : Integer.valueOf(cs[0].Value__c));
    //
    //        if(schedulerMinute < 60){
    //        	System.schedule(cts[0].CronJobDetail.Name, '0 '+ schedulerMinute +' * * * ?', this.batchSize != null ? new BusinessUnitUpdateBatch(this.batchSize) : new BusinessUnitUpdateBatch());
    //        } else {
    //            System.schedule(cts[0].CronJobDetail.Name, '0 '+ Math.abs(60 - schedulerMinute) +' * * * ?', this.batchSize != null ? new BusinessUnitUpdateBatch(this.batchSize) : new BusinessUnitUpdateBatch());
    //        }
    //        DateTime schPreviousRunTime = !cts.isEmpty() && cts[0].PreviousFireTime != null ? cts[0].PreviousFireTime.addMinutes(- Integer.valueOf(cs[0].Value__c) - TIME_MARGIN) :
    //        								DateTime.now().addHours(-1);
    //        System.debug('SC.getTriggerId() ' + SC.getTriggerId() + ', cron ' + cts[0] + '\nschPreviousRunTime ' + schPreviousRunTime);
    DateTime schPreviousRunTime = DateTime.now().addMinutes(-16);
    Database.executeBatch(new BusinessUnitUpdateBatch(schPreviousRunTime), 10);
  }

  global Database.QueryLocator start(Database.BatchableContext BC) {
    try {
      LAST_N_DAYS = Integer.valueOf(Label.BU_Batch_Run_for_Last_N_days);
    } catch (Exception e) {
    }
    Id secureIntegrationUserId = [
      SELECT Id
      FROM User
      WHERE Name = 'Secure Integration'
    ]
    .id;
    List<String> excludedLeadRecordType = !String.isEmpty(
        Label.Excluded_Lead_RecordType_For_BU_Batch
      )
      ? Label.Excluded_Lead_RecordType_For_BU_Batch.split(',')
      : new List<String>();
    /*Take all Leads that are:
     * ((created in that value of LAST_N_DAYS that is set in Label BU_Batch_Run_for_Last_N_days AND
     *    Has no value in Business_Unit__c)
     *   OR Employee_Min_Update_Timestamp__c
     *   OR Recalculate_Business_Unit__c = true )
     * AND RecordTypeId not in Label Excluded_Lead_RecordType_For_BU_Batch
     * AND Polygraph_Update_Timestamp__c!=null
     */
    query =
      'SELECT Id,OwnerId,CreatedById,Country,CountryCodeFromLeadCapture__c,CountryCode, Business_Unit__c, Employees_Min__c, Clean_Domain__c,Polygraph_Company_Name__c,Orchestration_Journey__c, Email_address_domain_type__c, Recalculate_Business_Unit__c, LinkedIn_Profile__c, Strategic_Pod__c, Strategic_Region__c ' +
      'FROM Lead ' +
      'WHERE ((CreatedDate=LAST_N_DAYS:' +
      LAST_N_DAYS +
      +' AND Business_Unit__c = NULL ' +
      (excludedLeadRecordType.isEmpty()
        ? ''
        : ') ' +
          'OR (Employee_Min_Update_Timestamp__c > ' +
          previousRunTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') +
          ') ' +
          'OR (Recalculate_Business_Unit__c = true)) ' +
          'AND Lead.RecordTypeId NOT IN (\'' +
          String.join(excludedLeadRecordType, ',') +
          '\'' +
          ') ' +
          'AND Polygraph_Update_Timestamp__c!=null ');
      //                'AND ((sw_connector__swId__c != null  AND Website != null) OR  Website = null  OR CreatedById != :secureIntegrationUserId)'

    System.debug(
      '### BusinessUnitUpdateBatch previousRunTime: ' +
        previousRunTime +
        ', \nquery: ' +
        query
    );
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Sobject> scope) {
    system.debug(scope.size());
    //Pardot_Data_Manipulation_Setting__c ldrOwnerSetting = Pardot_Data_Manipulation_Setting__c.getInstance('LDR_LEAD_OWNER_ID');
    String ldrOwnerSetting = String.valueOf(
      Pardot_Data_Manipulation_Setting__c.getInstance('LDR_LEAD_OWNER_ID')
        .Value__c
    );
    BusinessUnitUpdateHelper buuh = new BusinessUnitUpdateHelper();
    buuh.updateBusinessUnit(
      scope,
      'Clean_Domain__c',
      'Country',
      ldrOwnerSetting,
      false
    );
  }

  global void finish(Database.BatchableContext BC) {
  }
}

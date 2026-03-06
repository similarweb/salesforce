public class NewBiApiInteractionHandler {
  @testVisible
  private static Boolean doChainJob = true;
  private String entityType;
  private static Boolean alreadyRun = false;
  private static List<String> contactParamsList = GeneralUtil.getFieldSet(
    'Contact',
    'fit_score_fields_contact'
  );
  private static List<String> leadParamsList = GeneralUtil.getFieldSet(
    'Lead',
    'fit_score_fields_lead'
  );
  //    private static List<String> contactParamsList=GeneralUtil.getGeneralConfig('BiAPIFields_Contact').Text_Value__c.split(','); // maybe caused problems.
  private static List<String> accountParamsList = GeneralUtil.getGeneralConfig(
      'BiAPIFields_Account'
    )
    .Text_Value__c.split(',');

  private static List<Schema.DisplayType> numericTypeList = new List<Schema.DisplayType>{
    Schema.DisplayType.Double,
    Schema.DisplayType.Integer,
    Schema.DisplayType.Long,
    Schema.DisplayType.Currency
  };
  private static String dateParamMock = '2100-01-01';
  private static Map<String, String> apiNameToParamMap = new Map<String, String>();
  private static Map<String, String> accApiNameToParamMap = new Map<String, String>();
  private static Map<String, Schema.SObjectField> leadFieldMap;
  private static Map<String, Schema.SObjectField> contactFieldMap;
  private static Map<String, Schema.SObjectField> accountFieldMap;
  private static Map<String, String> contactToAccountFields = new Map<String, String>();

  static {
    apiNameToParamMap.put('name', 'contact_name');
    apiNameToParamMap.put('MailingCountry', 'country');
    apiNameToParamMap.put('Mailingcity', 'city');
    apiNameToParamMap.put('mailingstate', 'state');
    apiNameToParamMap.put(
      'dfox__company_last_funding_amount__c',
      'dfox__company_last_funding_amt__c'
    );
    apiNameToParamMap.put(
      'dfox__company_revenue_estimate__c',
      'dfox__company_revenue_estimate_amt__c'
    );
    apiNameToParamMap.put(
      'swid__r.website_category__c',
      'swid__r_website_category__c'
    );
    apiNameToParamMap.put('Email', 'email');
    apiNameToParamMap.put('Id', 'id');
    apiNameToParamMap.put('Country', 'country');
    apiNameToParamMap.put('Department__c', 'department__c');
    apiNameToParamMap.put('Employees_Min__c', 'employees_min__c');
    apiNameToParamMap.put('SW_Industry__c', 'sw_industry__c');
    apiNameToParamMap.put('Website', 'website');
    apiNameToParamMap.put('Website__c', 'website__c');
    //apiNameToParamMap.put('sw_industry__c','label_sw_industry__c');
    accApiNameToParamMap.put('employees_max__c', 'account_employees_max');
    accApiNameToParamMap.put('billingcountry', 'account_country');
    accApiNameToParamMap.put('number_of_contacts__c', 'users_in_account');
    accApiNameToParamMap.put('lastmodifieddate', 'account_last_modified_date');
    //accApiNameToParamMap.put('ROE_Division__c', 'roe_division__c');

    contactToAccountFields.put('Employees_Min__c', 'Employees_Min_FR__c');
    contactToAccountFields.put(
      'MailingCountryCode',
      'Account.BillingCountryCode'
    );
    contactToAccountFields.put('MailingCountry', 'Account.BillingCountry');
    contactToAccountFields.put('SW_Industry__c', 'Account.SW_Industry__c');

    leadFieldMap = Lead.SObjectType.getDescribe().fields.getMap();
    contactFieldMap = Contact.SObjectType.getDescribe().fields.getMap();
    accountFieldMap = Account.SObjectType.getDescribe().fields.getMap();
  }

  public static List<String> getParamsListByEntityType(String entityType) {
    if (entityType == 'Lead') {
      return leadParamsList;
    } else if (entityType == 'Contact') {
      return contactParamsList;
    } else if (entityType == 'Account') {
      return accountParamsList;
    } else {
      throw new UnsupportedEntityException('This entity type is unsupported');
    }
  }

  public void updateFitScoreLastRequest(List<SObject> newList) {
    if (checkIfFitScoreRelevant(newList)) {
      for (SObject sObj : newList) {
        if (sObj.get('Fit_Score_Last_Request_Date__c') != Date.today()) {
          sObj.put('Fit_Score_Count__c', 0);
        }
        if (((Decimal) sObj.get('Fit_Score_Count__c')) < 5) {
          sObj.put('Fit_Score_Last_Request_Date__c', Date.today());
        }
      }
    }
  }

  private boolean checkIfFitScoreRelevant(List<SObject> newList) {
    Boolean needToUpdate = false;
    for (SObject sObj : newList) {
      for (String fieldName : contactParamsList) {
        if (GeneralUtil.hasSObjectField(sObj, fieldName)) {
          if (sObj.get(fieldName) != null) {
            needToUpdate = true;
            break;
          }
        }
      }
    }
    return needToUpdate;
  }

  public NewBiApiInteractionHandler(String entityType) {
    this.entityType = entityType;
  }
  //*Main method. creates chunks of 100, set values to some fitscore dates fields and create chenged values map (Being called on update)
  public void fitscoreOnDfoxChange(
    sObject[] triggerNew,
    Map<Id, sObject> triggerOldMap
  ) {
    List<Sobject> relevantForFitScoreList = new List<SObject>(); // alon shalev 15.5.23
    System.debug('!!!=============');
    System.debug('!!!fitscoreOnDfoxChange New');
    System.debug('!!!entityType' + entityType);
    //*Map of Index,Set<Id> to split the incoming trigger records to chunks
    Map<Integer, Set<Id>> chunckedMap = new Map<Integer, Set<Id>>();
    //*map of recordId and the changed field and value (field...from...to...)
    Map<Id, String> idToChangedFieldMap = new Map<Id, String>();
    if (entityType == 'Account') {
      Set<Id> accIds = new Set<Id>();
      for (Integer i = 0; i < triggerNew.size(); i++) {
        sObject obj_i = triggerNew[i];
        sObject oldObj_i = triggerOldMap.get(obj_i.Id);
        String changedField = fieldChangeCheck(obj_i, oldObj_i);
        if (String.isNotBlank(changedField)) {
          accIds.add(obj_i.Id);
          idToChangedFieldMap.put(obj_i.Id, changedField);
        }
      }
      Integer iterator = 0;
      System.debug('accIds ' + accIds);
      for (Contact cnt_i : [
        SELECT Id
        FROM Contact
        WHERE AccountId IN :accIds
      ]) {
        Integer index = iterator / 100;
        if (!chunckedMap.containsKey(index)) {
          chunckedMap.put(index, new Set<Id>());
        }
        chunckedMap.get(index).add(cnt_i.Id);
        iterator++;
      }
    } else {
      //*for entityType contact/lead
      if (entityType == 'Contact' && triggerOldMap == null) {
        if (checkIfFitScoreRelevant(triggerNew)) {
          for (Integer i = 0; i < triggerNew.size(); i++) {
            Integer index = i / 100;
            if (!chunckedMap.containsKey(index)) {
              chunckedMap.put(index, new Set<Id>());
            }
            chunckedMap.get(index).add(triggerNew[i].Id);
            idToChangedFieldMap.put(
              triggerNew[i].Id,
              ' record is new first time getting fit Score'
            );
          }
        }
      } else {
        for (Integer i = 0; i < triggerNew.size(); i++) {
          sObject obj_i = triggerNew[i];
          sObject oldObj_i = triggerOldMap != null
            ? triggerOldMap.get(obj_i.Id)
            : null;
          System.debug('Loop');
          //*assign 0 to fit_score_count if Fit_Score_Last_Request_Date__c isnt today
          if (obj_i.get('Fit_Score_Last_Request_Date__c') != Date.today()) {
            System.debug('Lead is reset');
            if (triggerOldMap != null) {
              // its a way to understand the context // if its in after we cant update the record
              obj_i.put('Fit_Score_Count__c', 0);
            }
          }
          if (((Decimal) obj_i.get('Fit_Score_Count__c')) < 5) {
            if (triggerOldMap != null) {
              // its a way to understand the context // if its in after we cant update the record
              obj_i.put('Fit_Score_Last_Request_Date__c', Date.today());
            }
            // ld_i.Fit_Score_Count__c++;
            //leadToUpdate.add(ld_i);
            System.debug('Lead count ' + obj_i.get('Fit_Score_Count__c'));
            //newbaih.fitscoreOnDfoxChange(Trigger.new,Trigger.oldMap);
            String changedField = oldObj_i != null
              ? fieldChangeCheck(obj_i, oldObj_i)
              : null;
            //obj_i.put('SW_Fit_Score__c', null);
            System.debug('!!!changedField ' + changedField);
            System.debug(
              'obj_i.get(SW_Fit_Score__c) ' + obj_i.get('SW_Fit_Score__c')
            );

            if (
              (entityType != 'Lead' &&
              (String.isNotBlank(changedField) ||
              (obj_i.get('SW_Fit_Score__c') == null))) ||
              (entityType == 'Lead' &&
              (String.isNotBlank(changedField) ||
              (obj_i.get('SW_Fit_Score__c') == null)))
            ) {
              relevantForFitScoreList.add(obj_i); // alon shalev 15.5.23
              System.debug('!!!TRUE NEW');

              Integer index = i / 100;
              if (!chunckedMap.containsKey(index)) {
                chunckedMap.put(index, new Set<Id>());
              }
              chunckedMap.get(index).add(obj_i.Id);
              if (String.isNotBlank(changedField)) {
                idToChangedFieldMap.put(
                  obj_i.Id,
                  ' first change captured ' +
                    changedField +
                    ' changed from ' +
                    oldObj_i.get(changedField) +
                    ' to ' +
                    obj_i.get(changedField)
                );
              } else {
                idToChangedFieldMap.put(
                  obj_i.Id,
                  ' record is new first time getting fit Score'
                );
              }
            }
          } else {
            System.debug('Limit of Lead');
          }
        }
      }
    }
    //        if(!relevantForFitScoreList.isEmpty()){
    //            DynamicFitScoreGenerator fitScoreGenerator = new DynamicFitScoreGenerator(relevantForFitScoreList);
    //            fitScoreGenerator.generateFitScore();
    //        }// alon shalev 15.5.23
    if (!chunckedMap.isEmpty() && !alreadyRun) {
      //!System.isFuture()  && !System.isBatch()
      alreadyRun = true;
      /*
            for(Integer key_i : chunckedMap.keySet()){
                fitscoreOnDfoxChangeFuture(chunckedMap.get(key_i),entityType);        WITH FUTURE METHOD
            }
            */
      System.debug('doChainJob - ' + doChainJob);
      //*enqueue a job with this chunk, entityType and idToChangedFieldMap
      System.enqueueJob(
        new BiApiInteractionFitScoreJob(
          chunckedMap,
          entityType,
          idToChangedFieldMap
        )
      );
    }
  }

  @TestVisible
  private String fieldChangeCheck(sObject obj, sObject oldObj) {
    String changedField;

    if (entityType == 'Lead') {
      for (String param_i : leadParamsList) {
        if (param_i != 'swid__r.website_category__c') {
          if (obj.get(param_i) != oldObj.get(param_i)) {
            System.debug('1 ' + param_i);
            changedField = param_i;
            break;
          }
        }
      }
    } else if (entityType == 'Contact') {
      for (String param_i : contactParamsList) {
        if (obj.get(param_i) != oldObj.get(param_i)) {
          System.debug('2 ' + param_i);
          changedField = param_i;
          break;
        }
      }
      /*for(String param_i : accountParamsList){ 
                System.debug('param_i ' + param_i);
                System.debug('ii ' + obj.getSObject('Account'));
                if(contactIdToAccMap.containsKey((String)obj.get('Account__c')) && (contactIdToAccMap.get(obj.get('Account__c'))).get(param_i) != oldObj.getSObject('Account').get(param_i)){
                    System.debug('3 ' + param_i);
                    isChanged = true;
                    break;
                }
            }*/
    } else if (entityType == 'Account') {
      if (
        obj.get('number_of_contacts__c') != oldObj.get('number_of_contacts__c')
      ) {
        System.debug('3 ' + 'number_of_contacts__c');
        changedField = 'number_of_contacts__c';
      }
    }
    return changedField;
  }

  @future(callout=true)
  public static void fitscoreOnDfoxChangeFuture(
    Set<Id> objIdSet,
    String entityType
  ) {
    fitscoreOnDfoxChangeHelper(objIdSet, entityType);
  }

  public static void fitscoreOnDfoxChangeSynchronius(
    List<sObject> recordsToUpdate,
    String entityType
  ) {
    //  List<BI_Data__c> bdToUpdate = new List<BI_Data__c>();
    try {
      String parameterString;
      for (sObject sObj_i : recordsToUpdate) {
        System.debug('Before generateParameterString - ' + Datetime.now());
        parameterString = generateParameterString(sObj_i, entityType);
        System.debug('Before sendFitScoreCall - ' + Datetime.now());
        String responseBody = sendFitScoreCall(parameterString, entityType);
        System.debug('Before parseResponse - ' + Datetime.now());
        parseResponse(responseBody, sObj_i);
        //   BI_Data__c bd = parseResponse(responseBody,sObj_i);
        //   if(bd != null){
        //   bdToUpdate.add(bd);
      }
      // }

      // if(bdToUpdate.size() > 0){
      // System.debug('Update bdToUpdate'+ bdToUpdate.size());
      // update bdToUpdate;
      // }
      update recordsToUpdate; //test
    } catch (Exception ex) {
      System.debug(
        'BIAPI HANDLER EXCEPTION - ' +
          ex.getMessage() +
          ' line ' +
          ex.getLineNumber()
      );
    }
  }

  public static List<sObject> fitscoreOnDfoxChangeHelper(
    Set<Id> objIdSet,
    String entityType,
    Map<Id, String> idToChangedFieldMap
  ) {
    List<sObject> recordsToRetry = new List<sObject>();
    if (entityType == 'Account')
      entityType = 'Contact';
    List<sObject> recordsToUpdate = obtainRecordsForFitscore(
      objIdSet,
      entityType,
      idToChangedFieldMap
    );
    if (!recordsToUpdate.isEmpty()) {
      //*actually perform a fitscroe call
      recordsToRetry.addAll(
        fitscoreMainLogic(
          recordsToUpdate,
          entityType,
          idToChangedFieldMap,
          false
        )
      );
    }
    return recordsToRetry;
  }

  public static Map<String, List<sObject>> lockRecords(
    List<sObject> recordsToUpdate,
    Map<Id, String> idToChangedFieldMap,
    Boolean isRetry
  ) {
    List<sObject> recordsToRetry = new List<sObject>();
    List<sObject> filteredRecordsToUpdate = new List<sObject>();
    Map<Id, sObject> recordsToRetryMap = new Map<Id, sObject>();
    List<Fit_Score_Call_Log__c> failedLogsToInsert = new List<Fit_Score_Call_Log__c>();
    for (sObject sObj_i : recordsToUpdate) {
      recordsToRetryMap.put(sObj_i.Id, sObj_i);
    }
    Approval.LockResult[] lrList = Approval.lock(
      new List<Id>(recordsToRetryMap.keySet()),
      false
    );
    for (Approval.LockResult lr : lrList) {
      if (lr.isSuccess()) {
        filteredRecordsToUpdate.add(recordsToRetryMap.get(lr.getId()));
      } else {
        recordsToRetry.add(recordsToRetryMap.get(lr.getId()));
        failedLogsToInsert.add(
          buildFailedLogObject(
            'UNABLE TO LOCK RECORD EXCEPTION',
            'UNABLE TO LOCK RECORD EXCEPTION',
            'Record is locked',
            lr.getId(),
            '',
            buildChangedFieldMessage(lr.getId(), idToChangedFieldMap),
            isRetry
          )
        );
      }
    }
    return new Map<String, List<sObject>>{
      'recordsToUpdate' => filteredRecordsToUpdate,
      'recordsToRetry' => recordsToRetry,
      'failedLogsToInsert' => failedLogsToInsert
    };
  }

  public static void unlockRecords(List<sObject> recordsToUpdate) {
    Map<Id, sObject> recordsToRetryMap = new Map<Id, sObject>();
    for (sObject sObj_i : recordsToUpdate) {
      recordsToRetryMap.put(sObj_i.Id, sObj_i);
    }
    Approval.UnlockResult[] lrList = Approval.unlock(
      new List<Id>(recordsToRetryMap.keySet()),
      true
    );
  }

  public static List<sObject> fitscoreOnDfoxChangeHelper(
    Set<Id> objIdSet,
    String entityType
  ) {
    return fitscoreOnDfoxChangeHelper(
      objIdSet,
      entityType,
      new Map<Id, String>()
    );
  }

  //*get the current records data from SF DB. Construct a query dynamically based on the paramsList above.
  public static List<sObject> obtainRecordsForFitscore(
    Set<Id> objIdSet,
    String entityType,
    Map<Id, String> idToChangedFieldMap
  ) {
    System.debug('objIdSet--' + objIdSet);
    List<sObject> recordsToUpdate = new List<sObject>();
    alreadyRun = true;
    System.debug('Timestamp before querying records - ' + Datetime.now());
    String query = 'SELECT ';
    if (entityType == 'Lead') {
      for (String param_i : leadParamsList) {
        query += param_i + ',';
      }
    }
    if (entityType == 'Contact') {
      for (String param_i : contactParamsList) {
        query += param_i + ',';
      }
      for (String param_i : accountParamsList) {
        query += 'Account.' + param_i + ',';
      }
      for (String param_j : contactToAccountFields.values()) {
        query += param_j + ',';
      }
      query += 'Account.SW_Industry__c' + ','; // Workaround due to Sw Industry on Contact - formula field with labels hardcoded
    }
    query = query.removeEnd(',');
    query += ', BI_Data__c';
    query = removeDuplicate(query);
    query += ' FROM ' + entityType;
    query += ' WHERE ID IN : objIdSet';
    //query+=' FOR UPDATE'; // to avoid UNABLE_TO_LOCK_ROW_ISSUE
    recordsToUpdate = Database.query(query);
    System.debug('Timestamp after querying records - ' + Datetime.now());
    System.debug('recordsToUpdate--' + recordsToUpdate.size());
    return recordsToUpdate;
  }

  //*generates the request and performs the http call
  public static List<sObject> fitscoreMainLogic(
    List<sObject> recordsToUpdate,
    String entityType,
    Map<Id, String> idToChangedFieldMap,
    Boolean isRetry
  ) {
    System.debug('in fitscoreMainLogic');
    List<sObject> recordsToRetry = new List<sObject>();
    String parameterString;
    Map<Id, String> sObjIdToCallBodyMap = new Map<Id, String>();
    Map<Id, String> sObjIdToResponseMap = new Map<Id, String>();
    List<Fit_Score_Call_Log__c> failedLogsToInsert = new List<Fit_Score_Call_Log__c>();
    //List<BI_Data__c> bdToUpdate = new List<BI_Data__c>();
    for (sObject sObj_i : recordsToUpdate) {
      try {
        parameterString = generateParameterString(sObj_i, entityType); //*generates the request
        sObjIdToCallBodyMap.put(sObj_i.Id, parameterString);
        String responseBody = sendFitScoreCall(parameterString, entityType); //*perform the call
        sObjIdToResponseMap.put(sObj_i.Id, responseBody);

        //  BI_Data__c bd = parseResponse(responseBody,sObj_i);
        parseResponse(responseBody, sObj_i);
        //  if(bd != null){
        // bdToUpdate.add(bd);
        // }
      } catch (System.CalloutException ex) {
        String exMsg =
          'READ TIME OUT EXCEPTION - ' +
          ex.getMessage() +
          ' line ' +
          ex.getLineNumber() +
          ', stacktrace:\n' +
          ex.getStackTraceString();
        failedLogsToInsert.add(
          buildFailedLogObject(
            'READ TIME OUT EXCEPTION',
            exMsg,
            'Read time out',
            sObj_i.Id,
            parameterString,
            buildChangedFieldMessage(sObj_i.Id, idToChangedFieldMap),
            isRetry
          )
        );
        recordsToRetry.add(sObj_i);
      } catch (FailedStatusCodeException ex) {
        String exMsg =
          'Status code not 200 - ' +
          ex.getMessage() +
          ' line ' +
          ex.getLineNumber() +
          ', stacktrace:\n' +
          ex.getStackTraceString();
        failedLogsToInsert.add(
          buildFailedLogObject(
            'STATUS CODE EXCEPTION',
            exMsg,
            'Response not 200',
            sObj_i.Id,
            parameterString,
            buildChangedFieldMessage(sObj_i.Id, idToChangedFieldMap),
            isRetry
          )
        );
        recordsToRetry.add(sObj_i);
      }
    }
    Map<String, List<sObject>> lockingResult = lockRecords(
      recordsToUpdate,
      idToChangedFieldMap,
      isRetry
    );
    recordsToUpdate = lockingResult.get('recordsToUpdate');
    recordsToRetry.addAll(lockingResult.get('recordsToRetry'));
    failedLogsToInsert.addAll(
      (List<Fit_Score_Call_Log__c>) lockingResult.get('failedLogsToInsert')
    );
    insert failedLogsToInsert;
    try {
      //   System.debug('Update bdToUpdate: '+ bdToUpdate.size());
      //   if(bdToUpdate.size() > 0){
      //   update bdToUpdate;
      //   }
      update recordsToUpdate;
      List<Fit_Score_Call_Log__c> succesfullLogsToInstallList = new List<Fit_Score_Call_Log__c>();
      for (Id key_i : sObjIdToCallBodyMap.keySet()) {
        String bodyCall = sObjIdToCallBodyMap.get(key_i);
        System.debug('bodyCall' + bodyCall);
        String responseBody = sObjIdToResponseMap.get(key_i);
        succesfullLogsToInstallList.add(
          buildSuccessfulLogObject(
            'Successfull',
            key_i,
            bodyCall,
            buildChangedFieldMessage(key_i, idToChangedFieldMap),
            isRetry,
            responseBody
          )
        );
      }
      insert succesfullLogsToInstallList;
    } catch (Exception ex) {
      Integer numErrors = ex.getNumDml();
      String exMsg =
        'UPDATE EXCEPTION - ' +
        ex.getMessage() +
        ' line ' +
        ex.getLineNumber() +
        ', stacktrace:\n' +
        ex.getStackTraceString();
      insert buildFailedLogObject(
        'UPDATE EXCEPTION',
        exMsg,
        'Update',
        buildChangedFieldMessage(idToChangedFieldMap),
        isRetry
      );
      recordsToRetry = recordsToUpdate;
    }
    unlockRecords(recordsToUpdate);
    return recordsToRetry;
  }

  //*generates a sting of params based on the pramasList abover
  public static String generateParameterString(
    sObject sObj,
    String entityType
  ) {
    System.debug('generateParameterString--');
    String parameterString = '?';
    parameterString += 'sfdc_type=' + entityType;

    if (entityType == 'Lead') {
      for (String param_i : leadParamsList) {
        System.debug('param_i--' + param_i);
        String paramBiApi = param_i;
        if (apiNameToParamMap.containsKey(param_i)) {
          paramBiApi = apiNameToParamMap.get(param_i);
        }
        System.debug('paramBiApi after change --' + paramBiApi);
        parameterString +=
          '&' +
          paramBiApi +
          '=' +
          getFormattedParameter(param_i, 'Lead', sObj);
      }
      // parameterString +='&first_create_date=' + getFormattedParameter('createddate','Lead',sObj);
    }

    if (entityType == 'Contact') {
      for (String param_i : contactParamsList) {
        String paramBiApi = param_i;
        System.debug('paramBiApi before change --' + paramBiApi);
        if (apiNameToParamMap.containsKey(param_i)) {
          paramBiApi = apiNameToParamMap.get(param_i);
        }
        System.debug('paramBiApi after change --' + paramBiApi);
        parameterString +=
          '&' +
          paramBiApi +
          '=' +
          getFormattedParameter(param_i, 'Contact', sObj);
      }
      for (String param_i : accountParamsList) {
        String paramBiApi = param_i;
        if (accApiNameToParamMap.containsKey(param_i)) {
          paramBiApi = accApiNameToParamMap.get(param_i);
        }
        parameterString +=
          '&' +
          paramBiApi +
          '=' +
          getFormattedParameter(param_i, 'Account', sObj);
      }
      /* if(sObj.Id!=null){
                List<Lead> convertedLead = [SELECT CreatedDate, ConvertedContactId FROM Lead WHERE ConvertedContactId = :sObj.Id];   
                if(convertedLead.size()>0){
                    parameterString +='&first_create_date=' + EncodingUtil.urlEncode(String.valueOf(convertedLead[0].CreatedDate), 'UTF-8');    
                } else {
                    parameterString +='&first_create_date=' + getFormattedParameter('createddate','Contact',sObj);
                }
            } else {
                parameterString +='&first_create_date=' + getFormattedParameter('createddate','Contact',sObj);    
            }   */
    }

    return parameterString;
  }
  //*perform the call
  public static String sendFitScoreCall(
    String parameterString,
    String entityType
  ) {
    System.debug('!sendFitScoreCall');
    System.debug('!entityType=' + entityType);
    System.debug('!parameterString=' + parameterString);
    List<General_Key_Value_pair__mdt> settings = [
      SELECT id, Value__c, Key__c
      FROM General_Key_Value_pair__mdt
      WHERE
        IsActive__c = TRUE
        AND ProcessName__c = 'NewBiApiInteractionHandler Token'
    ];

    String username = 'sf_admin';
    String password = 'DE7r(Gx$F^?FJqGu';
    System.debug(
      ' ----------------------- BI API PARAMETER STRING ----------------------- '
    );
    for (Integer i = 0; i < parameterString.length(); i = i + 300) {
      Integer iEffectiveEnd = (i + 300 > (parameterString.length() - 1)
        ? parameterString.length() - 1
        : i + 300);
      System.debug(parameterString.substring(i, iEffectiveEnd));
    }
    System.debug(
      ' ----------------------- BI API PARAMETER STRING ----------------------- '
    );
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    if (!settings.isEmpty()) {
      request.setHeader(settings[0].Key__c, settings[0].Value__c);
    }
    String endpoint = 'http://biapi.similarweb.io/api/v1/';
    if (entityType == 'Lead') {
      endpoint += 'leadfitscore'; //test: leadfitscore
    } else if (entityType == 'Contact') {
      endpoint += 'contactfitscore'; //test: contactfitscore
    }
    request.setEndpoint(endpoint + parameterString);
    System.debug('!endpoint ' + endpoint + parameterString);
    request.setMethod('GET');
    Blob headerValue = Blob.valueOf(username + ':' + password);
    String authorizationHeader =
      'Basic ' + EncodingUtil.base64Encode(headerValue);
    request.setHeader('Authorization', authorizationHeader);
    request.setTimeout(30000);
    HttpResponse response = http.send(request);
    System.debug('response.getStatusCode =' + response.getStatusCode());
    System.debug(response.getBody());
    if (response.getStatusCode() != 200) {
      throw new FailedStatusCodeException(
        response.getStatus() + ' ' + response.getBody()
      );
    }
    System.debug('response ' + response);
    return response.getBody();
  }

  public static void parseResponse(String responseRaw, sObject obj) {
    System.debug(
      ' ------------------------------------- RESPONSE RAW ------------------------------------- '
    );
    System.debug(responseRaw);
    System.debug(
      ' ------------------------------------- RESPONSE RAW ------------------------------------- '
    );
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      responseRaw
    );
    System.debug(
      ' ------------------------------------- RESPONSE MAP ------------------------------------- '
    );
    System.debug(responseMap);
    System.debug(
      ' ------------------------------------- RESPONSE MAP ------------------------------------- '
    );
    //obj.put('SW_Fit_Score__c',responseMap.get('SW_Fit_Score__c'));
    //obj.put('SW_Fit_Score__c',responseMap.get('SW_Fit_Score__c'));
    //obj.put('SW_Fit_Score_Timestamp__c',responseMap.get('timestamp'));

    try {
      // String relatedBiDataID = [SELECT  BI_Data__c  FROM Contact WHERE Id =: obj.Id].BI_Data__c;
      // BI_Data__c bd = new BI_Data__c();
      //  if(obj.get('BI_Data__c') != null){
      DateTime timestampDateTime = null;
      Boolean tamFlag = ((String) responseMap.get('is_tam') == '1')
        ? true
        : false;
      timestampDateTime = DateTime.valueOf(
        String.valueOf(responseMap.get('timestamp'))
          .replace('T', ' ')
          .replace('"', '')
      );
      //obj.put('Id', obj.get('BI_Data__c'));
      obj.put(
        'SW_Fit_Score_Value__c',
        Integer.valueOf(responseMap.get('fit_score'))
      );
      obj.put('SW_Fit_Score__c', responseMap.get('fit_prediction'));
      obj.put('TAM__C', tamFlag);
      obj.put('SW_Fit_Score_Timestamp__c', timestampDateTime); //SW Fit Score Label   SW Fit Score TAM

      //  System.debug('!bdToUpdate =' + bd);
      //  return bd;
      //  } else {
      //      return null;
      //}
    } catch (Exception e) {
      System.debug(e.getLineNumber() + e.getMessage());
      //return null;
    }
  }

  public static String getFormattedParameter(
    String param,
    String sObjectType,
    sObject sObj
  ) {
    if (param != 'swid__r.website_category__c') {
      Object fieldValue = sObjectType == 'Account'
        ? sObj.getSObject('Account').get(param)
        : sObj.get(param);
      if (
        sObjectType == 'Contact' && contactToAccountFields.containsKey(param)
      ) {
        if (contactToAccountFields.get(param).contains('.')) {
          fieldValue = sObj.getSObject('Account')
            .get(contactToAccountFields.get(param).split('\\.')[1]);
        } else {
          fieldValue = sObj.get(contactToAccountFields.get(param));
        }
      }
      if (fieldValue == null) {
        Map<String, Schema.SObjectField> fieldMap;
        if (sObjectType == 'Lead') {
          fieldMap = leadFieldMap;
        } else if (sObjectType == 'Contact') {
          fieldMap = contactFieldMap;
        } else if (sObjectType == 'Account') {
          fieldMap = accountFieldMap;
        }
        if (
          fieldMap.get(param).getDescribe().getType() ==
          Schema.DisplayType.Date ||
          fieldMap.get(param).getDescribe().getType() ==
          Schema.DisplayType.DateTime
        ) {
          return EncodingUtil.urlEncode(dateParamMock, 'UTF-8');
        } else if (
          fieldMap.containsKey(param) &&
          numericTypeList.contains(fieldMap.get(param).getDescribe().getType())
        ) {
          if (param.equalsIgnoreCase('SI_Enrichment_Visits__c')) {
            return 'null';
          }
          return '0';
        } else {
          return 'null';
        }
      }
      return EncodingUtil.urlEncode(String.valueOf(fieldValue), 'UTF-8');
    } else {
      try {
        Object fieldValue = sObj.getSObject('swid__r')
          .get('website_category__c');
        return EncodingUtil.urlEncode(String.valueOf(fieldValue), 'UTF-8');
      } catch (Exception e) {
        System.debug(
          'Exception on try to fetch related swid__r, website_category__c' +
            e.getMessage() +
            e.getLineNumber()
        );
        return 'null';
      }
    }
  }

  @TestVisible
  public class BiApiInteractionFitScoreJob implements Queueable, Database.AllowsCallouts {
    private Map<Integer, Set<Id>> chunckedMap;
    private String entityType;
    private Map<Integer, List<sObject>> recordsToRetryMap;
    private Map<Id, String> idToChangedFieldMap = new Map<Id, String>();
    //*consstructor of a BiApiInteractionFitScoreJob
    public BiApiInteractionFitScoreJob(
      Map<Integer, Set<Id>> chunckedMap,
      String entityType,
      Map<Id, String> idToChangedFieldMap
    ) {
      this.chunckedMap = chunckedMap;
      this.entityType = entityType;
      this.idToChangedFieldMap = idToChangedFieldMap;
      recordsToRetryMap = new Map<Integer, List<sObject>>();
    }

    public BiApiInteractionFitScoreJob(
      Map<Integer, Set<Id>> chunckedMap,
      String entityType,
      Map<Integer, List<sObject>> recordsToRetryMap,
      Map<Id, String> idToChangedFieldMap
    ) {
      this.chunckedMap = chunckedMap;
      this.entityType = entityType;
      this.idToChangedFieldMap = idToChangedFieldMap;
      this.recordsToRetryMap = recordsToRetryMap;
    }

    public void execute(QueueableContext context) {
      system.debug('started execute');
      system.debug('chunckedMap--' + chunckedMap.values().size());
      system.debug('recordsToRetryMap' + recordsToRetryMap.values().size());
      try {
        NewBiApiInteractionHandler.alreadyRun = true;
        List<sObject> recordsToRetry;
        //Set<Id> recordsIdToRetry = new Set<Id>();
        List<Fit_Score_Call_Log__c> failedQueryLogs = new List<Fit_Score_Call_Log__c>();
        for (Integer index_i : chunckedMap.keySet()) {
          try {
            //*get the records most recent values from the DB
            System.debug('chunckedMap---' + chunckedMap.get(index_i));
            recordsToRetry = fitscoreOnDfoxChangeHelper(
              chunckedMap.get(index_i),
              entityType,
              idToChangedFieldMap
            );
          } catch (System.QueryException ex) {
            String exMsg =
              'QUERY EXCEPTION - ' +
              ex.getMessage() +
              ' line ' +
              ex.getLineNumber() +
              ', stacktrace:\n' +
              ex.getStackTraceString();
            System.debug(exMsg);
            //recordsIdToRetry.addAll(chunckedMap.get(index_i));
            failedQueryLogs.add(
              buildFailedLogObject(
                'QUERY EXCEPTION',
                exMsg,
                'Record is locked',
                buildChangedFieldMessage(idToChangedFieldMap),
                false
              )
            );
          }
          chunckedMap.remove(index_i);
          break;
        }
        insert failedQueryLogs;
        if (!recordsToRetry.isEmpty())
          recordsToRetryMap.put(recordsToRetryMap.size(), recordsToRetry);
        if (chunckedMap.size() > 0 && doChainJob)
          System.enqueueJob(
            new BiApiInteractionFitScoreJob(
              chunckedMap,
              entityType,
              recordsToRetryMap,
              idToChangedFieldMap
            )
          );
        else if (recordsToRetryMap.size() > 0 && doChainJob)
          System.enqueueJob(
            new BiApiInteractionRetryJob(
              recordsToRetryMap,
              entityType,
              idToChangedFieldMap
            )
          );
      } catch (Exception ex) {
        String exMsg =
          'BIAPI HANDLER EXCEPTION - ' +
          ex.getMessage() +
          ' line ' +
          ex.getLineNumber() +
          ', stacktrace:\n' +
          ex.getStackTraceString();
        System.debug(exMsg);
        insert buildFailedLogObject(
          'BIAPI HANDLER EXCEPTION',
          exMsg,
          'Other',
          buildChangedFieldMessage(idToChangedFieldMap),
          false
        );
      }
    }
  }

  @TestVisible
  private class BiApiInteractionRetryJob implements Queueable, Database.AllowsCallouts {
    private Map<Integer, List<sObject>> recordsToRetryMap;
    private Set<Id> recordsIdToRetry;
    private String entityType;
    private Map<Id, String> idToChangedFieldMap = new Map<Id, String>();

    public BiApiInteractionRetryJob(
      Map<Integer, List<sObject>> recordsToRetryMap,
      String entityType,
      Map<Id, String> idToChangedFieldMap
    ) {
      this.recordsToRetryMap = recordsToRetryMap;
      this.entityType = entityType;
      this.idToChangedFieldMap = idToChangedFieldMap;
    }

    public void execute(QueueableContext context) {
      try {
        NewBiApiInteractionHandler.alreadyRun = true;
        System.debug(
          ' ------------------------------------- RECORDS TO RETRY START ------------------------------------- '
        );
        if (!recordsToRetryMap.isEmpty()) {
          for (Integer index_i : recordsToRetryMap.keySet()) {
            retry(recordsToRetryMap.get(index_i));
            recordsToRetryMap.remove(index_i);
            break;
          }
        }
        if (recordsToRetryMap.size() > 0)
          System.enqueueJob(
            new BiApiInteractionRetryJob(
              recordsToRetryMap,
              entityType,
              idToChangedFieldMap
            )
          );
      } catch (Exception ex) {
        String exMsg =
          'BIAPI HANDLER EXCEPTION - ' +
          ex.getMessage() +
          ' line ' +
          ex.getLineNumber() +
          ', stacktrace:\n' +
          ex.getStackTraceString();
        System.debug(exMsg);
        insert buildFailedLogObject(
          'BIAPI HANDLER EXCEPTION ON RETRY',
          exMsg,
          'Other',
          buildChangedFieldMessage(idToChangedFieldMap),
          true
        );
      }
    }

    private void retry(List<sObject> recordsToRetry) {
      if (entityType == 'Account')
        entityType = 'Contact';
      fitscoreMainLogic(recordsToRetry, entityType, idToChangedFieldMap, true);
    }
  }

  private static String removeDuplicate(String commaSeparatedStr) {
    List<String> values = commaSeparatedStr.split(',');

    Set<String> uniqueValues = new Set<String>();

    for (String value : values) {
      String trimmedValue = value.trim();
      uniqueValues.add(value); // to remove any spaces after or before commas
    }

    return String.join(new List<String>(uniqueValues), ',');
  }

  @TestVisible
  private static Fit_Score_Call_Log__c buildFailedLogObject(
    String name,
    String exMsg,
    String errorType,
    String entityId,
    String callBody,
    String changeFieldInfo,
    Boolean isRetry
  ) {
    if (isRetry)
      name += ' ON RETRY';
    return new Fit_Score_Call_Log__c(
      Name = name + ' - ' + Datetime.now(),
      Error_log__c = exMsg,
      Error_Type__c = errorType,
      Entity_Id__c = entityId,
      Type__c = 'Failed',
      Call_Body__c = callBody,
      Cause__c = changeFieldInfo
    );
  }

  @TestVisible
  private static Fit_Score_Call_Log__c buildFailedLogObject(
    String name,
    String exMsg,
    String errorType,
    String changeFieldInfo,
    Boolean isRetry
  ) {
    if (isRetry)
      name += ' ON RETRY';
    return new Fit_Score_Call_Log__c(
      Name = name + ' - ' + Datetime.now(),
      Error_log__c = exMsg,
      Error_Type__c = errorType,
      Type__c = 'Failed',
      Cause__c = changeFieldInfo
    );
  }

  @TestVisible
  private static Fit_Score_Call_Log__c buildSuccessfulLogObject(
    String name,
    String entityId,
    String callBody,
    String changeFieldInfo,
    Boolean isRetry,
    String rawResponse
  ) {
    if (isRetry)
      name += ' ON RETRY';
    return new Fit_Score_Call_Log__c(
      Name = name + ' - ' + Datetime.now(),
      Type__c = 'Successful',
      Entity_Id__c = entityId,
      Call_Body__c = callBody,
      Cause__c = changeFieldInfo,
      Response__c = rawResponse
    );
  }

  @TestVisible
  private static String buildChangedFieldMessage(
    String id,
    Map<Id, String> idToChangedFieldMap
  ) {
    String result;
    if (idToChangedFieldMap.containsKey(id))
      result = idToChangedFieldMap.get(id);
    return result;
  }

  @TestVisible
  private static String buildChangedFieldMessage(
    Map<Id, String> idToChangedFieldMap
  ) {
    String result = '';
    for (String key_i : idToChangedFieldMap.keySet()) {
      String changedFieldInfo = idToChangedFieldMap.get(key_i);
      result += 'Id: ' + key_i + ', info: ' + changedFieldInfo + '\n';
    }
    return result;
  }

  private class UnsupportedEntityException extends Exception {
  }
  private class FailedStatusCodeException extends Exception {
  }
}

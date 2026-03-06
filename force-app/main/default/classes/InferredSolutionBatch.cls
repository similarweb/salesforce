public class InferredSolutionBatch implements Database.Batchable<sObject>, Database.Stateful {
  private String sObjType;
  private String condition;
  private Integer runNumber = 0;
  private Set<Id> rerunIdSet = new Set<Id>();

  public InferredSolutionBatch(String sObjType) {
    this.sObjType = sObjType;
  }
  public InferredSolutionBatch(String sObjType, String condition) {
    this.sObjType = sObjType;
    this.condition = condition;
  }

  public InferredSolutionBatch(
    String sObjType,
    String condition,
    Integer runNumber
  ) {
    this.sObjType = sObjType;
    this.condition = condition;
    this.runNumber = runNumber;
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id,Name,';
    if (sObjtype == 'Lead') {
      Set<String> leadFieldList = Schema.SObjectType.Lead.fields.getMap()
        .keySet();
      Set<String> invalidColumnsList = new Set<String>();
      for (Inferral_Solution_Valid_Criteria_List__c isvc_i : [
        SELECT Name
        FROM Inferral_Solution_Valid_Criteria_List__c
        WHERE Is_Valid__c = FALSE
      ]) {
        invalidColumnsList.add(isvc_i.Name);
      }
      for (
        String schemaField : Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
          .keySet()
      ) {
        if (
          schemaField.endsWith('__c') &&
          !invalidColumnsList.contains(schemaField)
        ) {
          if (!leadFieldList.contains(schemaField))
            schemaField = schemaField.removeEnd('__c');
          query += schemaField + ',';
        }
      }
      query = query.removeEnd(',');
      query += ' FROM Lead'; //
    } else if (sObjtype == 'Contact') {
      Set<String> contactFieldList = Schema.SObjectType.Contact.fields.getMap()
        .keySet();
      Set<String> invalidColumnsList = new Set<String>();
      for (InferralSolutionCValidCriteriaList__c isvc_i : [
        SELECT Name
        FROM InferralSolutionCValidCriteriaList__c
        WHERE Is_Valid__c = FALSE
      ]) {
        invalidColumnsList.add(isvc_i.Name);
      }
      for (
        String schemaField : Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
          .keySet()
      ) {
        if (
          schemaField.endsWith('__c') &&
          !invalidColumnsList.contains(schemaField)
        ) {
          if (!contactFieldList.contains(schemaField))
            schemaField = schemaField.removeEnd('__c');
          query += schemaField + ',';
        }
      }
      query = query.removeEnd(',');
      query += ' FROM Contact';
    }
    if (String.isNotBlank(condition))
      query += ' WHERE ' + condition;
    //        query+=' WHERE Id IN (\'00Q0O00000z6cDQ\',\'00Q0O00000z6cDa\',\'00Q0O00000z6cDf\',\'00Q0O00000z6cDp\',\'00Q0O00000z6cDu\',\'00Q0O00000z6cDz\',\'00Q0O00000z6cET\',\'00Q0O00000z6cEE\',\'00Q0O00000z6cEi\',\'00Q0O00000z6cQP\')';
    System.debug('query ' + query);
    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    if (sObjtype == 'Lead') {
      Set<String> invalidColumnsList = new Set<String>();
      for (Inferral_Solution_Valid_Criteria_List__c isvc_i : [
        SELECT Name
        FROM Inferral_Solution_Valid_Criteria_List__c
        WHERE Is_Valid__c = FALSE
      ]) {
        invalidColumnsList.add(isvc_i.Name);
      }
      Set<String> schemaFieldList = Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
        .keySet();
      Set<String> leadFieldList = Schema.SObjectType.Lead.fields.getMap()
        .keySet();
      for (String schemaField : schemaFieldList) {
        if (
          !schemaField.endsWith('__c') ||
          invalidColumnsList.contains(schemaField) ||
          schemaField == 'Inferred_Solution__c'
        ) {
          schemaFieldList.remove(schemaField);
        }
      }
      Map<String, InferralSolutionMap__c> inferralSolutionMap = InferralSolutionMap__c.getAll();
      for (sObject sObj_i : scope) {
        String keyName = '';
        for (String schemaField : schemaFieldList) {
          if (!leadFieldList.contains(schemaField))
            schemaField = schemaField.removeEnd('__c');
          String sObjValue = sObj_i.get(schemaField) == null
            ? 'NULL'
            : (String) sObj_i.get(schemaField);
          keyName += sObjValue + ' + ';
        }
        keyName = keyName.removeEnd(' + ');
        System.debug('keyName - ' + keyName);
        String index = EncodingUtil.convertToHex(
          Crypto.generateDigest('MD5', Blob.valueOf(keyName))
        );
        if (inferralSolutionMap.containsKey(index)) {
          sObj_i.put(
            'Inferred_Solution__c',
            inferralSolutionMap.get(index).Inferred_Solution__c
          );
        } else {
          Boolean valueFound = false;
          for (InferralSolutionMap__c ism_i : inferralSolutionMap.values()) {
            Boolean ch = false;
            for (String schemaField : schemaFieldList) {
              if (
                ism_i.get(schemaField) != 'NULL' &&
                ism_i.get(schemaField) != sObj_i.get(schemaField)
              ) {
                ch = true;
                break;
              }
            }
            if (ch) {
              continue;
            } else {
              sObj_i.put('Inferred_Solution__c', ism_i.Inferred_Solution__c);
              valueFound = true;
              break;
            }
          }
          if (!valueFound) {
            sObj_i.put(
              'Inferred_Solution__c',
              Inferral_Solution_Settings__c.getValues('Default Value').Value__c
            );
          }
        }
      }
    } else if (sObjtype == 'Contact') {
      Set<String> invalidColumnsList = new Set<String>();
      for (InferralSolutionCValidCriteriaList__c isvc_i : [
        SELECT Name
        FROM InferralSolutionCValidCriteriaList__c
        WHERE Is_Valid__c = FALSE
      ]) {
        invalidColumnsList.add(isvc_i.Name);
      }
      Set<String> schemaFieldList = Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
        .keySet();
      Set<String> contactFieldList = Schema.SObjectType.Contact.fields.getMap()
        .keySet();
      for (String schemaField : schemaFieldList) {
        if (
          !schemaField.endsWith('__c') ||
          invalidColumnsList.contains(schemaField) ||
          schemaField == 'Inferred_Solution__c'
        ) {
          schemaFieldList.remove(schemaField);
        }
      }
      Map<String, InferralSolutionMapContact__c> inferralSolutionMap = InferralSolutionMapContact__c.getAll();
      for (sObject sObj_i : scope) {
        String keyName = '';
        for (String schemaField : schemaFieldList) {
          if (!contactFieldList.contains(schemaField))
            schemaField = schemaField.removeEnd('__c');
          String sObjValue = sObj_i.get(schemaField) == null
            ? 'NULL'
            : (String) sObj_i.get(schemaField);
          keyName += sObjValue + ' + ';
        }
        keyName = keyName.removeEnd(' + ');
        System.debug('keyNameSS - ' + keyName);
        String index = EncodingUtil.convertToHex(
          Crypto.generateDigest('MD5', Blob.valueOf(keyName))
        );
        System.debug(
          'inferralSolutionMap.containsKey(index) - ' +
          inferralSolutionMap.containsKey(index)
        );
        if (inferralSolutionMap.containsKey(index)) {
          sObj_i.put(
            'Inferred_Solution__c',
            inferralSolutionMap.get(index).Inferred_Solution__c
          );
        } else {
          Boolean valueFound = false;
          for (
            InferralSolutionMapContact__c ism_i : inferralSolutionMap.values()
          ) {
            Boolean ch = false;
            for (String schemaField : schemaFieldList) {
              if (
                ism_i.get(schemaField) != 'NULL' &&
                ism_i.get(schemaField) != sObj_i.get(schemaField)
              ) {
                ch = true;
                break;
              }
            }
            if (ch) {
              continue;
            } else {
              sObj_i.put('Inferred_Solution__c', ism_i.Inferred_Solution__c);
              valueFound = true;
              break;
            }
          }
          if (!valueFound) {
            sObj_i.put(
              'Inferred_Solution__c',
              Inferral_Solution_Settings__c.getValues('Default Value').Value__c
            );
          }
        }
      }
    }
    List<Database.SaveResult> resultsList = Database.update(scope, false);
    for (Integer i = 0; i < resultsList.size(); i++) {
      Database.SaveResult result = resultsList[i];
      if (!result.isSuccess()) {
        rerunIdSet.add(scope[i].Id);
      }
    }
  }

  public void finish(Database.BatchableContext BC) {
    runNumber++;
    System.debug('runNumber: ' + runNumber);
    if ((runNumber < 4) && (!rerunIdSet.isEmpty())) {
      System.debug('### runNumber < 4: ' + runNumber);
      System.debug('### rerunIdSet: ' + rerunIdSet);
      String rerunCondit = ' Id IN: (';
      for (ID id_i : rerunIdSet) {
        rerunCondit += ' \'' + id_i + '\',';
      }
      rerunCondit = rerunCondit.substringBeforeLast(',') + ')';
      System.debug(rerunCondit);
      InferredSolutionBatch rerunBatch = new InferredSolutionBatch(
        sObjType,
        rerunCondit,
        runNumber
      );
    }
  }
}

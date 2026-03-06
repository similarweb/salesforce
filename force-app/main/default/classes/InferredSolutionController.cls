public class InferredSolutionController {
  @AuraEnabled
  public static String obtainInferredSolutionData(String type) {
    Map<String, Object> responseMap = new Map<String, Object>();
    if (type == 'Lead') {
      List<InferralSolutionField> inferralSolutionMapFieldList = new List<InferralSolutionField>();
      Set<String> invalidColumnsList = new Set<String>();
      for (Inferral_Solution_Valid_Criteria_List__c isvc_i : [
        SELECT Name
        FROM Inferral_Solution_Valid_Criteria_List__c
        WHERE Is_Valid__c = FALSE
      ]) {
        invalidColumnsList.add(isvc_i.Name);
      }
      Schema.DescribeFieldResult infFieldDescribe;
      for (
        Schema.SObjectField field_i : Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
          .values()
      ) {
        Schema.DescribeFieldResult dfr = field_i.getDescribe();
        String fieldApiName = dfr.getName();
        if (fieldApiName == 'Inferred_Solution__c') {
          infFieldDescribe = dfr;
        } else {
          if (
            fieldApiName.endsWith('__c') &&
            !invalidColumnsList.contains(fieldApiName.toLowerCase())
          ) {
            InferralSolutionField isf = new InferralSolutionField(
              dfr.getLabel(),
              fieldApiName
            );
            inferralSolutionMapFieldList.add(isf);
          }
        }
      }
      InferralSolutionField isf = new InferralSolutionField(
        infFieldDescribe.getLabel(),
        infFieldDescribe.getName()
      );
      inferralSolutionMapFieldList.add(isf);

      List<PickListFieldData> infPickListFieldDataList = new List<PickListFieldData>();
      Map<String, Schema.SObjectField> leadFieldMap = Schema.SObjectType.Lead.fields.getMap();
      Map<String, List<PickListFieldData>> picklistFieldMap = new Map<String, List<PickListFieldData>>();
      for (InferralSolutionField field_i : inferralSolutionMapFieldList) {
        Schema.DescribeFieldResult dfr;
        if (leadFieldMap.containsKey(field_i.fieldName)) {
          dfr = leadFieldMap.get(field_i.fieldName).getDescribe();
        } else {
          dfr = leadFieldMap.get(field_i.fieldName.removeEnd('__c'))
            .getDescribe();
        }
        List<PickListFieldData> pickListFieldDataList = new List<PickListFieldData>();
        for (PicklistEntry pe_i : dfr.getPicklistValues()) {
          pickListFieldDataList.add(new PickListFieldData(pe_i));
        }
        if (dfr.getName() == 'Inferred_Solution__c') {
          infPickListFieldDataList = pickListFieldDataList;
        } else {
          pickListFieldDataList.add(new PickListFieldData());
          picklistFieldMap.put(
            dfr.getName().toLowerCase().endsWith('__c')
              ? dfr.getName().toLowerCase()
              : dfr.getName().toLowerCase() + '__c',
            pickListFieldDataList
          );
        }
      }
      picklistFieldMap.put('inferred_solution__c', infPickListFieldDataList);

      responseMap.put('picklistFieldMap', picklistFieldMap);
      responseMap.put('records', InferralSolutionMap__c.getAll().values());
      responseMap.put('fieldMetadata', inferralSolutionMapFieldList);
    } else if (type == 'Contact') {
      List<InferralSolutionField> inferralSolutionMapFieldList = new List<InferralSolutionField>();
      Set<String> invalidColumnsList = new Set<String>();
      for (InferralSolutionCValidCriteriaList__c isvc_i : [
        SELECT Name
        FROM InferralSolutionCValidCriteriaList__c
        WHERE Is_Valid__c = FALSE
      ]) {
        invalidColumnsList.add(isvc_i.Name);
      }
      Schema.DescribeFieldResult infFieldDescribe;
      for (
        Schema.SObjectField field_i : Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
          .values()
      ) {
        Schema.DescribeFieldResult dfr = field_i.getDescribe();
        String fieldApiName = dfr.getName();
        if (fieldApiName == 'Inferred_Solution__c') {
          infFieldDescribe = dfr;
        } else {
          if (
            fieldApiName.endsWith('__c') &&
            !invalidColumnsList.contains(fieldApiName.toLowerCase())
          ) {
            InferralSolutionField isf = new InferralSolutionField(
              dfr.getLabel(),
              fieldApiName
            );
            inferralSolutionMapFieldList.add(isf);
          }
        }
      }
      InferralSolutionField isf = new InferralSolutionField(
        infFieldDescribe.getLabel(),
        infFieldDescribe.getName()
      );
      inferralSolutionMapFieldList.add(isf);

      List<PickListFieldData> infPickListFieldDataList = new List<PickListFieldData>();
      Map<String, Schema.SObjectField> leadFieldMap = Schema.SObjectType.Contact.fields.getMap();
      Map<String, List<PickListFieldData>> picklistFieldMap = new Map<String, List<PickListFieldData>>();
      for (InferralSolutionField field_i : inferralSolutionMapFieldList) {
        System.debug('field_i.fieldName - ' + field_i.fieldName);
        Schema.DescribeFieldResult dfr;
        if (
          leadFieldMap.containsKey(field_i.fieldName) &&
          field_i.fieldName != 'SW_Industry__c'
        ) {
          dfr = leadFieldMap.get(field_i.fieldName).getDescribe();
        } else if (field_i.fieldName == 'SW_Industry__c') {
          System.debug('ccc');
          dfr = Schema.SObjectType.Account.fields.getMap()
            .get(field_i.fieldName)
            .getDescribe();
        } else {
          dfr = leadFieldMap.get(field_i.fieldName.removeEnd('__c'))
            .getDescribe();
        }
        List<PickListFieldData> pickListFieldDataList = new List<PickListFieldData>();
        for (PicklistEntry pe_i : dfr.getPicklistValues()) {
          pickListFieldDataList.add(new PickListFieldData(pe_i));
        }
        if (dfr.getName() == 'Inferred_Solution__c') {
          infPickListFieldDataList = pickListFieldDataList;
        } else {
          pickListFieldDataList.add(new PickListFieldData());
          picklistFieldMap.put(
            dfr.getName().toLowerCase().endsWith('__c')
              ? dfr.getName().toLowerCase()
              : dfr.getName().toLowerCase() + '__c',
            pickListFieldDataList
          );
        }
      }
      picklistFieldMap.put('inferred_solution__c', infPickListFieldDataList);

      responseMap.put('picklistFieldMap', picklistFieldMap);
      responseMap.put(
        'records',
        InferralSolutionMapContact__c.getAll().values()
      );
      responseMap.put('fieldMetadata', inferralSolutionMapFieldList);
    }
    responseMap.put(
      'defaultValue',
      Inferral_Solution_Settings__c.getValues('Default Value').Value__c
    );
    return JSON.serialize(new Response(responseMap));
  }

  @AuraEnabled
  public static String saveInferredSolutionData(
    String inferredSolutionDataRaw,
    String type
  ) {
    try {
      if (type == 'Lead') {
        Set<String> invalidColumnsList = new Set<String>();
        for (Inferral_Solution_Valid_Criteria_List__c isvc_i : [
          SELECT Name
          FROM Inferral_Solution_Valid_Criteria_List__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Lead.fields.getMap();

        Map<String, List<String>> fieldNameToValueListMap = new Map<String, List<String>>();
        Set<String> schemaFieldList = Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
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
        Set<String> inferralSolutionKeyList = InferralSolutionMap__c.getAll()
          .keySet();
        for (String field_i : schemaFieldList) {
          System.debug('field_i - ' + field_i);
          if (!fieldMap.containsKey(field_i))
            field_i = field_i.removeEnd('__c');
          Schema.DescribeFieldResult fieldResult = fieldMap.get(field_i)
            .getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          List<String> pickListValuesList = new List<String>();
          for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getValue());
          }
          pickListValuesList.add('NULL');
          fieldNameToValueListMap.put(field_i, pickListValuesList);
        }

        List<InferralSolutionMap__c> ifsList = (List<InferralSolutionMap__c>) JSON.deserializeStrict(
          inferredSolutionDataRaw,
          List<InferralSolutionMap__c>.class
        );
        for (InferralSolutionMap__c ifs_i : ifsList) {
          String index = '';
          Boolean checkAllNullValue = true;
          for (String field_i : schemaFieldList) {
            String value = (String) ifs_i.get(field_i);
            System.debug('field_i ' + field_i);
            System.debug('value ' + value);
            if (String.IsBlank(value)) {
              value = 'NULL';
            }
            if (value != 'NULL') {
              checkAllNullValue = false;
            }
            String fieldkey = field_i;
            if (!fieldNameToValueListMap.containsKey(field_i))
              fieldkey = field_i.removeEnd('__c');
            if (
              value != null &&
              !fieldNameToValueListMap.get(fieldkey).contains(value)
            ) {
              throw new InvalidValueException(
                'Invalid value - ' + value + ' in ' + field_i
              );
            }
            ifs_i.put(field_i, value);
            index += value + ' + ';
          }
          if (checkAllNullValue)
            throw new InvalidValueException('All NULL Value');
          index = index.removeEnd(' + ');
          if (String.IsBlank(ifs_i.Inferred_Solution__c)) {
            ifs_i.Inferred_Solution__c = 'NULL';
          }
          System.debug('index ' + index);
          ifs_i.Name = EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(index))
          );
          if (
            String.IsBlank(ifs_i.Id) &&
            inferralSolutionKeyList.contains(ifs_i.Name)
          )
            throw new InvalidValueException('Duplicate value');
        }
        try {
          upsert ifsList;
        } catch (Exception e) {
          return JSON.serialize(new Response('Duplicate values'));
        }
        return JSON.serialize(
          new Response(InferralSolutionMap__c.getAll().values())
        );
      } else if (type == 'Contact') {
        Set<String> invalidColumnsList = new Set<String>();
        for (InferralSolutionCValidCriteriaList__c isvc_i : [
          SELECT Name
          FROM InferralSolutionCValidCriteriaList__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();

        Map<String, List<String>> fieldNameToValueListMap = new Map<String, List<String>>();
        Set<String> schemaFieldList = Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
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
        Set<String> inferralSolutionKeyList = InferralSolutionMapContact__c.getAll()
          .keySet();
        for (String field_i : schemaFieldList) {
          System.debug('field_i - ' + field_i);
          if (!fieldMap.containsKey(field_i))
            field_i = field_i.removeEnd('__c');

          Schema.DescribeFieldResult fieldResult = fieldMap.get(field_i)
            .getDescribe();
          List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
          List<String> pickListValuesList = new List<String>();
          for (Schema.PicklistEntry pickListVal : ple) {
            pickListValuesList.add(pickListVal.getValue());
          }
          pickListValuesList.add('NULL');
          fieldNameToValueListMap.put(field_i, pickListValuesList);
        }

        List<InferralSolutionMapContact__c> ifsList = (List<InferralSolutionMapContact__c>) JSON.deserializeStrict(
          inferredSolutionDataRaw,
          List<InferralSolutionMapContact__c>.class
        );
        for (InferralSolutionMapContact__c ifs_i : ifsList) {
          String index = '';
          Boolean checkAllNullValue = true;
          for (String field_i : schemaFieldList) {
            String value = (String) ifs_i.get(field_i);
            if (String.IsBlank(value)) {
              value = 'NULL';
            }
            if (value != 'NULL') {
              checkAllNullValue = false;
            }
            System.debug('field_i ' + field_i);
            System.debug('value ' + value);
            String fieldkey = field_i;
            if (!fieldNameToValueListMap.containsKey(field_i))
              fieldkey = field_i.removeEnd('__c');
            if (
              value != null &&
              !fieldNameToValueListMap.get(fieldkey).contains(value) &&
              field_i != 'SW_Industry__c'
            ) {
              throw new InvalidValueException(
                'Invalid value - ' + value + ' in ' + field_i
              );
            }
            ifs_i.put(field_i, value);
            index += value + ' + ';
          }
          if (checkAllNullValue)
            throw new InvalidValueException('All NULL Value');
          index = index.removeEnd(' + ');
          if (String.IsBlank(ifs_i.Inferred_Solution__c)) {
            ifs_i.Inferred_Solution__c = 'NULL';
          }
          ifs_i.Name = EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(index))
          );
          if (
            String.IsBlank(ifs_i.Id) &&
            inferralSolutionKeyList.contains(ifs_i.Name)
          )
            throw new InvalidValueException('Duplicat value');
        }
        try {
          upsert ifsList;
        } catch (Exception e) {
          return JSON.serialize(new Response('Duplicate values'));
        }
        return JSON.serialize(
          new Response(InferralSolutionMapContact__c.getAll().values())
        );
      }
    } catch (Exception e) {
      return JSON.serialize(new Response(e.getMessage()));
    }
    return '';
  }

  @AuraEnabled
  public static String removeInferredSolutionRecord(
    String csName,
    String type
  ) {
    try {
      if (type == 'Lead') {
        csName = csName.replaceAll('"', '');
        InferralSolutionMap__c ismToRemove = [
          SELECT Id
          FROM InferralSolutionMap__c
          WHERE Name = :csName
          LIMIT 1
        ];
        delete ismToRemove;
        return JSON.serialize(
          new Response(InferralSolutionMap__c.getAll().values())
        );
      } else if (type == 'Contact') {
        csName = csName.replaceAll('"', '');
        InferralSolutionMapContact__c ismToRemove = [
          SELECT Id
          FROM InferralSolutionMapContact__c
          WHERE Name = :csName
          LIMIT 1
        ];
        delete ismToRemove;
        return JSON.serialize(
          new Response(InferralSolutionMapContact__c.getAll().values())
        );
      }
    } catch (Exception e) {
      return JSON.serialize(new Response(e.getMessage()));
    }
    return '';
  }

  @AuraEnabled
  public static String createInferredSolutionColumn(
    String columnName,
    String type
  ) {
    try {
      if (type == 'Lead') {
        Set<String> schemaFieldList = Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
          .keySet();
        Set<String> inferralSolutionKeyList = InferralSolutionMap__c.getAll()
          .keySet();
        Set<String> invalidColumnsList = new Set<String>();
        for (Inferral_Solution_Valid_Criteria_List__c isvc_i : [
          SELECT Name
          FROM Inferral_Solution_Valid_Criteria_List__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Lead.fields.getMap();
        if (
          !fieldMap.containsKey(columnName) ||
          (fieldMap.get(columnName).getDescribe().getPicklistValues().size() ==
          0)
        ) {
          return JSON.serialize(new Response('No such coolumn on Lead'));
        }

        Inferral_Solution_Valid_Criteria_List__c mc = Inferral_Solution_Valid_Criteria_List__c.getValues(
          (columnName).toLowerCase()
        );
        if (mc == null)
          mc = Inferral_Solution_Valid_Criteria_List__c.getValues(
            (columnName + '__c').toLowerCase()
          );
        if (mc != null) {
          if (mc.Is_Valid__c)
            return JSON.serialize(new Response('Column already exist'));
          mc.Is_Valid__c = true;
          update mc;
          String fieldapiname = columnName.endsWith('__c')
            ? columnName
            : columnName + '__c';
          for (String schemaField : schemaFieldList) {
            if (
              (!schemaField.endsWith('__c') ||
              invalidColumnsList.contains(schemaField) ||
              schemaField == 'Inferred_Solution__c') &&
              schemaField != fieldapiname
            ) {
              schemaFieldList.remove(schemaField);
            }
          }
          String query = 'SELECT ID,';
          for (String field_i : schemaFieldList) {
            query += field_i + ',';
          }
          query = query.removeEnd(',') + ' FROM InferralSolutionMap__c';
          List<InferralSolutionMap__c> ismToUpdate = Database.query(query);
          for (InferralSolutionMap__c ism_i : ismToUpdate) {
            ism_i.put(fieldapiname, 'NULL');
            String index = '';
            for (String field_i : schemaFieldList) {
              String value = (String) ism_i.get(field_i);
              if (String.IsBlank(value)) {
                value = 'NULL';
              }
              ism_i.put(field_i, value);
              index += value + ' + ';
            }
            index = index.removeEnd(' + ');
            ism_i.Name = EncodingUtil.convertToHex(
              Crypto.generateDigest('MD5', Blob.valueOf(index))
            );
            if (
              String.IsBlank(ism_i.Id) &&
              inferralSolutionKeyList.contains(ism_i.Name)
            )
              throw new InvalidValueException('Duplicate value');
          }
          update ismToUpdate;
        } else {
          String objectapiname = 'InferralSolutionMap__c';
          String fieldapiname = columnName.endsWith('__c')
            ? columnName
            : columnName + '__c';

          String fieldlabel = columnName.removeEnd('__c').replaceAll('_', ' ');
          String fielddescription = '';

          HttpRequest requestinside = new HttpRequest();
          requestinside.setHeader('Content-Type', 'application/json');
          System.debug(URL.getSalesforceBaseUrl().toExternalForm());
          requestinside.setEndpoint(
            'callout:new_partial/services/data/v45.0/tooling/sobjects/CustomField'
          );
          requestinside.setMethod('POST');
          requestinside.setHeader(
            'Authorization',
            'Bearer ' + JwtCredentials.getInstance().getAccessToken()
          );
          String fieldDef = '{"Metadata" : ';
          String metadef =
            '"type" : "Text","description" : "' +
            fielddescription +
            '", "inlineHelpText" : "","precision" : null,"label" : "' +
            fieldlabel +
            '","length" : 255,"required" : false';
          fieldDef += '{' + metadef + '},';
          fieldDef +=
            '"FullName" : "' +
            objectapiname +
            '.' +
            fieldapiname +
            '"}';
          system.debug(fieldDef);
          requestinside.setBody(fieldDef);
          Http http = new Http();
          HTTPResponse res = http.send(requestinside);
          System.debug('res ' + res.getBody());
          if (res.getStatusCode() == 201) {
            Inferral_Solution_Valid_Criteria_List__c isvcl = new Inferral_Solution_Valid_Criteria_List__c(
              name = (fieldapiname).toLowerCase(),
              Is_Valid__c = true
            );
            insert isvcl;
          } else {
            throw new CreateColimnFailedException(res.getStatus());
          }
        }
      } else if (type == 'Contact') {
        Set<String> schemaFieldList = new Set<String>(
          Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
            .keySet()
        );
        Set<String> inferralSolutionKeyList = InferralSolutionMapContact__c.getAll()
          .keySet();
        Set<String> invalidColumnsList = new Set<String>();
        for (InferralSolutionCValidCriteriaList__c isvc_i : [
          SELECT Name
          FROM InferralSolutionCValidCriteriaList__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }

        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
        if (
          columnName != 'SW_Industry__c' &&
          (!fieldMap.containsKey(columnName) ||
          (fieldMap.get(columnName).getDescribe().getPicklistValues().size() ==
          0))
        ) {
          return JSON.serialize(new Response('No such coolumn on Contact'));
        }

        InferralSolutionCValidCriteriaList__c mc = InferralSolutionCValidCriteriaList__c.getValues(
          columnName.endsWith('__c')
            ? columnName.toLowerCase()
            : columnName.toLowerCase() + '__c'
        );
        if (mc == null)
          mc = InferralSolutionCValidCriteriaList__c.getValues(
            (columnName + '__c').toLowerCase()
          );
        if (mc != null) {
          if (mc.Is_Valid__c)
            return JSON.serialize(new Response('Column already exist'));
          mc.Is_Valid__c = true;
          update mc;
          String fieldapiname = columnName.endsWith('__c')
            ? columnName
            : columnName + '__c';
          for (String schemaField : schemaFieldList) {
            if (
              (!schemaField.endsWith('__c') ||
              invalidColumnsList.contains(schemaField) ||
              schemaField == 'Inferred_Solution__c') &&
              schemaField != fieldapiname
            ) {
              schemaFieldList.remove(schemaField);
            }
          }
          //String query = 'SELECT ID,' + fieldapiname+' FROM InferralSolutionMapContact__c';
          String query = 'SELECT ID,';
          for (String field_i : schemaFieldList) {
            query += field_i + ',';
          }
          query = query.removeEnd(',') + ' FROM InferralSolutionMapContact__c';
          List<InferralSolutionMapContact__c> ismToUpdate = Database.query(
            query
          );
          for (InferralSolutionMapContact__c ism_i : ismToUpdate) {
            ism_i.put(fieldapiname, 'NULL');
            String index = '';
            for (String field_i : schemaFieldList) {
              String value = (String) ism_i.get(field_i);
              if (String.IsBlank(value)) {
                value = 'NULL';
              }
              ism_i.put(field_i, value);
              index += value + ' + ';
            }
            index = index.removeEnd(' + ');
            System.debug('cc Contact index ' + index);
            ism_i.Name = EncodingUtil.convertToHex(
              Crypto.generateDigest('MD5', Blob.valueOf(index))
            );
            if (
              String.IsBlank(ism_i.Id) &&
              inferralSolutionKeyList.contains(ism_i.Name)
            )
              throw new InvalidValueException('Duplicate value');
          }
          update ismToUpdate;
        } else {
          String objectapiname = 'InferralSolutionMapContact__c';
          String fieldapiname = columnName.endsWith('__c')
            ? columnName
            : columnName + '__c';

          String fieldlabel = columnName.removeEnd('__c').replaceAll('_', ' ');
          String fielddescription = '';

          HttpRequest requestinside = new HttpRequest();
          requestinside.setHeader('Content-Type', 'application/json');
          System.debug(URL.getSalesforceBaseUrl().toExternalForm());
          requestinside.setEndpoint(
            'callout:new_partial/services/data/v45.0/tooling/sobjects/CustomField'
          );
          requestinside.setMethod('POST');
          requestinside.setHeader(
            'Authorization',
            'Bearer ' + JwtCredentials.getInstance().getAccessToken()
          );
          String fieldDef = '{"Metadata" : ';
          String metadef =
            '"type" : "Text","description" : "' +
            fielddescription +
            '", "inlineHelpText" : "","precision" : null,"label" : "' +
            fieldlabel +
            '","length" : 255,"required" : false';
          fieldDef += '{' + metadef + '},';
          fieldDef +=
            '"FullName" : "' +
            objectapiname +
            '.' +
            fieldapiname +
            '"}';
          system.debug(fieldDef);
          requestinside.setBody(fieldDef);
          Http http = new Http();
          HTTPResponse res = http.send(requestinside);
          System.debug('res ' + res.getBody());
          if (res.getStatusCode() == 201) {
            InferralSolutionCValidCriteriaList__c isvcl = new InferralSolutionCValidCriteriaList__c(
              name = (fieldapiname).toLowerCase(),
              Is_Valid__c = true
            );
            insert isvcl;
          } else {
            throw new CreateColimnFailedException(res.getStatus());
          }
        }
      }
    } catch (Exception e) {
      return JSON.serialize(new Response(e.getMessage()));
    }
    return JSON.serialize(new Response(true, 'success'));
  }

  @AuraEnabled
  public static String removeInferredSolutionColumn(
    String columnName,
    String type
  ) {
    Savepoint sp = Database.setSavepoint();
    try {
      if (type == 'Lead') {
        System.debug('columnName ' + columnName);
        Inferral_Solution_Valid_Criteria_List__c isvcl = Inferral_Solution_Valid_Criteria_List__c.getValues(
          columnName.toLowerCase()
        );
        if (isvcl == null) {
          return JSON.serialize(new Response('No such column'));
        }
        isvcl.Is_Valid__c = false;

        Set<String> invalidColumnsList = new Set<String>();
        for (Inferral_Solution_Valid_Criteria_List__c isvc_i : [
          SELECT Name
          FROM Inferral_Solution_Valid_Criteria_List__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }
        List<InferralSolutionMap__c> ismToUpdate = InferralSolutionMap__c.getAll()
          .values();
        Integer size = 0;
        for (
          String fieldApiName : Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
            .keySet()
        ) {
          if (
            fieldApiName.endsWith('__c') &&
            !invalidColumnsList.contains(fieldApiName) &&
            fieldApiName != columnName &&
            fieldApiName != 'Inferred_Solution__c'
          ) {
            size++;
          }
        }
        if (size == 0)
          return JSON.serialize(
            new Response('At least one column should persist')
          );
        for (InferralSolutionMap__c ism_i : ismToUpdate) {
          String key = '';
          for (
            String fieldApiName : Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
              .keySet()
          ) {
            if (
              fieldApiName.endsWith('__c') &&
              !invalidColumnsList.contains(fieldApiName) &&
              fieldApiName != columnName &&
              fieldApiName != 'Inferred_Solution__c'
            ) {
              System.debug('fieldApiName ' + fieldApiName);
              key += ism_i.get(fieldApiName) + ' + ';
            }
          }
          key = key.removeEnd(' + ');
          System.debug('key ' + key);
          ism_i.Name = EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(key))
          );
        }
        try {
          update ismToUpdate;
        } catch (Exception e) {
          return JSON.serialize(new Response('Duplicate values'));
        }
        update isvcl;
      } else if (type == 'Contact') {
        System.debug('columnName ' + columnName);
        InferralSolutionCValidCriteriaList__c isvcl = InferralSolutionCValidCriteriaList__c.getValues(
          columnName.toLowerCase()
        );
        if (isvcl == null) {
          return JSON.serialize(new Response('No such column'));
        }
        isvcl.Is_Valid__c = false;

        Set<String> invalidColumnsList = new Set<String>();
        for (InferralSolutionCValidCriteriaList__c isvc_i : [
          SELECT Name
          FROM InferralSolutionCValidCriteriaList__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }
        Integer size = 0;
        for (
          String fieldApiName : Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
            .keySet()
        ) {
          if (
            fieldApiName.endsWith('__c') &&
            !invalidColumnsList.contains(fieldApiName) &&
            fieldApiName != columnName &&
            fieldApiName != 'Inferred_Solution__c'
          ) {
            size++;
          }
        }
        if (size == 0)
          return JSON.serialize(
            new Response('At least one column should persist')
          );
        List<InferralSolutionMapContact__c> ismToUpdate = InferralSolutionMapContact__c.getAll()
          .values();
        for (InferralSolutionMapContact__c ism_i : ismToUpdate) {
          String key = '';
          for (
            String fieldApiName : Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
              .keySet()
          ) {
            if (
              fieldApiName.endsWith('__c') &&
              !invalidColumnsList.contains(fieldApiName) &&
              fieldApiName != columnName &&
              fieldApiName != 'Inferred_Solution__c'
            ) {
              System.debug('fieldApiName ' + fieldApiName);
              System.debug('columnName ' + columnName);
              key += ism_i.get(fieldApiName) + ' + ';
            }
          }
          key = key.removeEnd(' + ');
          System.debug('size ' + size);
          ism_i.Name = EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(key))
          );
        }
        try {
          update ismToUpdate;
        } catch (Exception e) {
          return JSON.serialize(new Response('Duplicate values'));
        }
        update isvcl;
      }
    } catch (Exception e) {
      //Database.rollback(sp);
      return JSON.serialize(new Response(e.getMessage()));
    }
    return JSON.serialize(new Response(true, 'success'));
  }

  @AuraEnabled
  public static String saveDefault(String value) {
    Inferral_Solution_Settings__c iss = Inferral_Solution_Settings__c.getValues(
      'Default Value'
    );
    iss.Value__c = value;
    update iss;
    return JSON.serialize(new Response(true, iss.Value__c));
  }

  @AuraEnabled
  public static String runLogic(String type, String condition) {
    try {
      ApexClass aC = [
        SELECT Id, Name
        FROM ApexClass
        WHERE Name = 'InferredSolutionBatch'
      ];
      List<AsyncApexJob> aaj = [
        SELECT Id, Status, ApexClassID
        FROM AsyncApexJob
        WHERE
          ApexClassID = :aC.Id
          AND (Status = 'Processing'
          OR Status = 'Queued')
      ];
      System.debug('condition ' + condition);
      if (aaj.size() > 0) {
        return JSON.serialize(new Response('Batch is running'));
      } else {
        if (String.isBlank(condition))
          Database.executeBatch(new InferredSolutionBatch(type));
        else
          Database.executeBatch(new InferredSolutionBatch(type, condition));
      }
      return JSON.serialize(new Response(true, 'success'));
    } catch (Exception e) {
      return JSON.serialize(new Response(e.getMessage()));
    }
  }

  @AuraEnabled
  public static String checkIfBatchRunning(String type) {
    ApexClass aC = [
      SELECT Id, Name
      FROM ApexClass
      WHERE Name = 'InferredSolutionBatch'
    ];
    List<AsyncApexJob> aaj = [
      SELECT Id, Status, ApexClassID
      FROM AsyncApexJob
      WHERE
        ApexClassID = :aC.Id
        AND (Status = 'Processing'
        OR Status = 'Queued')
    ];
    if (aaj.size() > 0) {
      return JSON.serialize(new Response(true));
    }
    return JSON.serialize(new Response(false));
  }

  @AuraEnabled
  public static String recalculateIndex(String type) {
    try {
      String objectapiname;
      Set<String> schemaFieldList;
      Set<String> inferralSolutionKeyList;
      Set<String> invalidColumnsList;
      if (type == 'Lead') {
        objectapiname = 'InferralSolutionMap__c';
        schemaFieldList = Schema.SObjectType.InferralSolutionMap__c.fields.getMap()
          .keySet();
        inferralSolutionKeyList = InferralSolutionMap__c.getAll().keySet();
        invalidColumnsList = new Set<String>();
        for (Inferral_Solution_Valid_Criteria_List__c isvc_i : [
          SELECT Name
          FROM Inferral_Solution_Valid_Criteria_List__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }
      } else if (type == 'Contact') {
        objectapiname = 'InferralSolutionMapContact__c';
        schemaFieldList = new Set<String>(
          Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap()
            .keySet()
        );
        inferralSolutionKeyList = InferralSolutionMapContact__c.getAll()
          .keySet();
        invalidColumnsList = new Set<String>();
        for (InferralSolutionCValidCriteriaList__c isvc_i : [
          SELECT Name
          FROM InferralSolutionCValidCriteriaList__c
          WHERE Is_Valid__c = FALSE
        ]) {
          invalidColumnsList.add(isvc_i.Name);
        }
      }
      for (String schemaField : schemaFieldList) {
        if (
          !schemaField.endsWith('__c') ||
          invalidColumnsList.contains(schemaField) ||
          schemaField == 'Inferred_Solution__c'
        ) {
          schemaFieldList.remove(schemaField);
        }
      }
      String query = 'SELECT ID,';
      for (String field_i : schemaFieldList) {
        query += field_i + ',';
      }
      query = query.removeEnd(',') + ' FROM ' + objectapiname;

      List<sObject> ismToUpdate = Database.query(query);
      for (sObject ism_i : ismToUpdate) {
        String index = '';
        for (String field_i : schemaFieldList) {
          String value = (String) ism_i.get(field_i);
          if (String.IsBlank(value)) {
            value = 'NULL';
            ism_i.put(field_i, value);
          }
          index += value + ' + ';
        }
        index = index.removeEnd(' + ');
        System.debug('cc Contact index ' + index);
        ism_i.put(
          'Name',
          EncodingUtil.convertToHex(
            Crypto.generateDigest('MD5', Blob.valueOf(index))
          )
        );
      }
      update ismToUpdate;
      return JSON.serialize(new Response(true, 'success'));
    } catch (Exception ex) {
      return JSON.serialize(new Response(false, ex.getMessage()));
    }
  }

  @AuraEnabled
  public static String checkBatchCondition(String type, String condition) {
    try {
      String query = 'SELECT COUNT(ID)num FROM';
      if (type == 'Lead') {
        query += ' Lead WHERE ';
      } else if (type == 'Contact') {
        query += ' Contact WHERE ';
      }
      query += condition;
      AggregateResult[] groupedResults = Database.query(query);
      String returnMessage =
        'Total records for update - ' + groupedResults[0].get('num');
      return JSON.serialize(new Response(true, returnMessage));
    } catch (Exception ex) {
      return JSON.serialize(
        new Response(false, 'Invalid query - ' + ex.getMessage())
      );
    }
  }

  public class InvalidValueException extends Exception {
  }

  public class CreateColimnFailedException extends Exception {
  }

  public class InferralSolutionField {
    public String label;
    public String fieldName;

    public InferralSolutionField(String label, String fieldName) {
      this.label = label;
      this.fieldName = fieldName;
    }
  }

  public class PickListFieldData {
    public String label;
    public String value;

    public PickListFieldData(Schema.PicklistEntry pe) {
      this.label = pe.getLabel();
      this.value = pe.getValue();
    }

    public PickListFieldData() {
      this.label = 'NULL';
      this.value = 'NULL';
    }
  }
}

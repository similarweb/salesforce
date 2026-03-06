public with sharing class BaseProductMetadataManipulationHelper {
  private static String baseProductPicklistName {
    get {
      if (baseProductPicklistName == null) {
        Base_Product_Configuration__c controllingField = Base_Product_Configuration__c.getInstance(
          'Controlling field name'
        );
        if (controllingField == null || controllingField.Value__c == null) {
          throw new InvalidSettingException('No controling field setted');
        }
        baseProductPicklistName = controllingField.Value__c;
      }
      return baseProductPicklistName;
    }
    set {
    }
  }
  private static String wordListPicklistName {
    get {
      if (wordListPicklistName == null) {
        Base_Product_Configuration__c controlledField = Base_Product_Configuration__c.getInstance(
          'Controlled field name'
        );
        if (controlledField == null || controlledField.Value__c == null) {
          throw new InvalidSettingException('No controled field setted');
        }
        wordListPicklistName = controlledField.Value__c;
      }
      return wordListPicklistName;
    }
    set {
    }
  }
  private static String baseProductPicklistApiName {
    get {
      if (baseProductPicklistApiName == null) {
        baseProductPicklistApiName = 'zqu__Quote__c.' + baseProductPicklistName;
      }
      return baseProductPicklistApiName;
    }
    set {
    }
  }
  private static String wordListPicklistApiName {
    get {
      if (wordListPicklistApiName == null) {
        wordListPicklistApiName = 'zqu__Quote__c.' + wordListPicklistName;
      }
      return wordListPicklistApiName;
    }
    set {
    }
  }
  /**
   * Retrieve records from Base_Product_Contract__c custom setting
   *
   * @return list of PicklistValue objects - wrapper for
   *         Base_Product_Contract__c record which contains Label
   *         and Value fields.
   */
  public static List<PicklistValue> retreiveBaseProductContractValues() {
    List<PicklistValue> picklistValueList = new List<PicklistValue>();
    for (
      Base_Product_Contract__c bpc_i : Base_Product_Contract__c.getAll()
        .values()
    ) {
      PicklistValue pv = new PicklistValue(bpc_i.Label__c, bpc_i.Value__c);
      picklistValueList.add(pv);
    }
    return picklistValueList;
  }

  /**
   * Retrieve records from Base_Product_Controlling_Obj__c custom setting
   *
   * @return list of PicklistValue objects - wrapper for
   *         Base_Product_Contract__c record which contains Label
   *         and Value fields.
   */
  public static List<PicklistValue> retreiveBaseProductPicklistValues() {
    //MetadataServiceFacade service = new MetadataServiceFacade(JwtCredentials.getInstance());
    //MetadataService.CustomField customField = service.obtainCustomField(baseProductPicklistApiName);
    //List<PicklistValue> picklistValueList = service.obtainPicklistValueList(customField);
    List<PicklistValue> picklistValueList = new List<PicklistValue>();
    for (
      Base_Product_Controlling_Obj__c bpc : Base_Product_Controlling_Obj__c.getAll()
        .values()
    ) {
      PicklistValue picklistValue = new PicklistValue(
        bpc.Label__c,
        bpc.Value__c
      );
      picklistValueList.add(picklistValue);
    }
    return picklistValueList;
  }

  /**
   * Add values to Base product picklist - to Base_Product_Controlling_Obj__c custom setting
   * and to Base product picklist field
   *
   * @param  fullNameListRaw string with picklist values separated by "\n" character.
   * @return                 return errors which occured during work of SF Metadata API, which
   *                         inserted new value into picklist field . If no errors occured -
   *                         return blank string.
   */
  public static String addBaseProductPicklistValues(String fullNameListRaw) {
    if (String.isBlank(fullNameListRaw)) {
      throw new NoParamException('No fullNameListRaw param');
    }
    List<String> fullNameList = fullNameListRaw.split('\n');

    MetadataServiceFacade service = new MetadataServiceFacade(
      JwtCredentials.getInstance()
    );
    MetadataService.CustomField customField = service.obtainCustomField(
      baseProductPicklistApiName
    );
    MetadataService.CustomObject customObject = service.obtainCustomObject(
      'zqu__Quote__c'
    );
    MetadataService.CustomObject customObjectAmend = service.obtainCustomObject(
      'zqu__Quote__c'
    );

    service.addPicklistValueToCustomObjectRTs(
      customObject,
      baseProductPicklistName,
      fullNameList
    );
    service.addPicklistValueToCustomField(customField, fullNameList);

    MetadataService.CustomField customFieldAmend = service.obtainCustomField(
      'zqu__Quote__c.Package_Amendment__c'
    );
    service.addPicklistValueToCustomObjectRTs(
      customObjectAmend,
      'Package_Amendment__c',
      fullNameList
    );
    service.addPicklistValueToCustomField(customFieldAmend, fullNameList);

    List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.upsertMetadata(
      new List<MetadataService.Metadata>{ customField, customFieldAmend },
      true
    );
    String errors = service.obtainErrors(lstResults);
    if (String.isBlank(errors)) {
      List<Base_Product_Controlling_Obj__c> bpcList = new List<Base_Product_Controlling_Obj__c>();
      for (String fullName : fullNameList) {
        Base_Product_Controlling_Obj__c bpc = new Base_Product_Controlling_Obj__c();
        bpc.Name = Utility.hashCode(fullName);
        bpc.Value__c = fullName;
        bpc.Label__c = fullName;
        bpcList.add(bpc);
      }
      insert bpcList;
      System.debug(
        'Custom object Record Types: ' + customObject.recordTypes[0]
      );
      System.debug(
        'Custom object Record Types: ' +
        JSON.serialize(customObject.recordTypes[0])
      );
      if (!Test.isRunningTest()) {
        system.debug(
          ': Heap size is ' +
            limits.getHeapSize() +
            ' enforced is ' +
            limits.getLimitHeapSize()
        );
        System.enqueueJob(
          new UpdateRtMdataQueueable(
            service,
            customObject.recordTypes,
            baseProductPicklistName
          )
        );
        System.enqueueJob(
          new UpdateRtMdataQueueable(
            service,
            customObjectAmend.recordTypes,
            'Package_Amendment__c'
          )
        );
      }
    }
    return errors;
  }

  /**
   * Delete values from Base product picklist - from Base_Product_Controlling_Obj__c custom
   * setting and from Base product picklist field
   *
   * @param  fullNameToDelete api name of picklist value which need to be deleted.
   * @return                  return errors which occured during work of SF Metadata API, which
   *                          inserted new value into picklist field . If no errors occured -
   *                          return blank string.
   */
  public static String deleteBaseProductPicklistValues(
    String fullNameToDelete
  ) {
    if (String.isBlank(fullNameToDelete)) {
      throw new NoParamException('No fullName param');
    }
    MetadataServiceFacade service = new MetadataServiceFacade(
      JwtCredentials.getInstance()
    );
    MetadataService.CustomField customField = service.obtainCustomField(
      baseProductPicklistApiName
    );
    List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.deleteMetadata(
      'PicklistValue',
      new List<String>{
        baseProductPicklistApiName +
        '.' +
        fullNameToDelete,
        'zqu__Quote__c.Package_Amendment__c.' + fullNameToDelete
      },
      true
    );
    String errors = service.obtainErrors(lstResults);
    if (String.isBlank(errors)) {
      Base_Product_Controlling_Obj__c bpc = Base_Product_Controlling_Obj__c.getInstance(
        Utility.hashCode(fullNameToDelete)
      );
      delete bpc;
      List<Base_Product_Dependent__c> bpdList = [
        SELECT Id, Controlling__c, Dependent__c
        FROM Base_Product_Dependent__c
        WHERE Controlling__c = :fullNameToDelete
      ];
      delete bpdList;
    }
    return errors;
  }

  /**
   * Edit label of specific value from Base product picklist - in the Base product field
   * itself and in Base_Product_Controlling_Obj__c custom setting
   *
   * @param  fullName api name of picklist value which need to be edited.
   * @param  label    new label of Base Product picklist value.
   * @return          return errors which occured during work of SF Metadata API, which
   *                  edited picklist value. If no errors occured - return blank string.
   */
  public static String editBaseProductPicklistValues(
    String fullName,
    String label
  ) {
    if (String.isBlank(fullName)) {
      throw new NoParamException('No fullName param');
    }
    if (String.isBlank(label)) {
      throw new NoParamException('No label param');
    }
    MetadataServiceFacade service = new MetadataServiceFacade(
      JwtCredentials.getInstance()
    );
    MetadataService.CustomField customField = service.obtainCustomField(
      baseProductPicklistApiName
    );
    service.renamePicklistVlaueLabel(customField, fullName, label);
    List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.updateMetadata(
      new List<MetadataService.Metadata>{ customField },
      true
    );
    String errors = service.obtainErrors(lstResults);
    if (String.isBlank(errors)) {
      Base_Product_Controlling_Obj__c bpc = Base_Product_Controlling_Obj__c.getInstance(
        Utility.hashCode(fullName)
      );
      bpc.Label__c = label;
      update bpc;
    }
    return errors;
  }

  /**
   * Retrieve records from Base_Product_Dependent__c custom setting
   * where Controlling__c field equals to a specific value from a param.
   *
   * @param  controllingFieldValue value which is used to filter Base_Product_Dependent__c
   *                               records which will be returned.
   * @return                       list of PicklistValue objects - wrapper for
   *                               Base_Product_Contract__c record which contains Label
   *                               and Value fields.
   */
  public static List<PicklistValue> retreiveWorldListPicklistValuesForDependentValue(
    String controllingFieldValue
  ) {
    if (String.isBlank(controllingFieldValue)) {
      throw new NoParamException('No controlling param');
    }
    //MetadataServiceFacade service = new MetadataServiceFacade(JwtCredentials.getInstance());
    //MetadataService.CustomField customField = service.obtainCustomField(wordListPicklistApiName);
    List<PicklistValue> picklistValueList = new List<PicklistValue>();
    List<Base_Product_Dependent__c> bpdsList = [
      SELECT Id, Dependent__c
      FROM Base_Product_Dependent__c
      WHERE Controlling__c = :controllingFieldValue
    ];
    if (bpdsList != null && bpdsList.size() > 0) {
      for (Base_Product_Dependent__c bpds : bpdsList) {
        System.debug('bpds ' + bpds);
        Base_Product_Contract__c bpc = Base_Product_Contract__c.getInstance(
          Utility.hashCode(bpds.Dependent__c)
        );
        System.debug('bpc ' + bpc);
        PicklistValue pv = new PicklistValue(bpc.Label__c, bpc.Value__c);
        picklistValueList.add(pv);
      }
    }

    //List<PicklistValue> picklistValueList = service.obtainPicklistValueList(customField,controllingFieldValue);
    return picklistValueList;
  }

  /**
   * Add values to Word list picklist - to Base_Product_Contract__c custom setting
   * and to Word list picklist field.
   *
   * @param  fullNameListRaw string with picklist values separated by "\n" character.
   * @return                 return errors which occured during work of SF Metadata API, which
   *                         inserted new value into picklist field . If no errors occured -
   *                         return blank string.
   */
  public static String addWorldListPicklistValue(String fullNameListRaw) {
    if (String.isBlank(fullNameListRaw)) {
      throw new NoParamException('No picklistValueRaw param');
    }
    List<String> fullNameList = fullNameListRaw.split('\n');

    MetadataServiceFacade service = new MetadataServiceFacade(
      JwtCredentials.getInstance()
    );
    MetadataService.CustomField customField = service.obtainCustomField(
      wordListPicklistApiName
    );
    MetadataService.CustomObject customObject = service.obtainCustomObject(
      'zqu__Quote__c'
    );
    MetadataService.CustomObject customObjectAmend = service.obtainCustomObject(
      'zqu__Quote__c'
    );

    service.addPicklistValueToCustomObjectRTs(
      customObject,
      wordListPicklistName,
      fullNameList
    );
    service.addPicklistValueToCustomField(customField, fullNameList);

    MetadataService.CustomField customFieldAmend = service.obtainCustomField(
      'zqu__Quote__c.Contract_Wording_List_Amend__c'
    );
    service.addPicklistValueToCustomObjectRTs(
      customObjectAmend,
      'Contract_Wording_List_Amend__c',
      fullNameList
    );
    service.addPicklistValueToCustomField(customFieldAmend, fullNameList);

    List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.upsertMetadata(
      new List<MetadataService.Metadata>{ customField, customFieldAmend },
      true
    );
    String errors = service.obtainErrors(lstResults);
    if (String.isBlank(errors)) {
      List<Base_Product_Contract__c> bpcListToAdd = new List<Base_Product_Contract__c>();
      for (String fullName : fullNameList) {
        Base_Product_Contract__c bpc = new Base_Product_Contract__c(
          Label__c = fullName,
          Value__c = fullName,
          Name = Utility.hashCode(fullName)
        );
        bpcListToAdd.add(bpc);
      }
      if (bpcListToAdd.size() > 0) {
        insert bpcListToAdd;
      }
      System.debug(customObject.recordTypes);
      if (!Test.isRunningTest()) {
        System.enqueueJob(
          new UpdateRtMdataQueueable(
            service,
            customObject.recordTypes,
            wordListPicklistName
          )
        );
        System.enqueueJob(
          new UpdateRtMdataQueueable(
            service,
            customObjectAmend.recordTypes,
            'Contract_Wording_List_Amend__c'
          )
        );
      }
    }
    return errors;
  }

  /**
   * Make certain values of Word List picklist dependant from the value of
   * Base product picklist
   *
   * @param  controllingFieldValue value which is used to set Dependent__c
   *                               value of Base_Product_Dependent__c
   *                               records which will be created.
   * @param  fullNameListRaw       string with picklist values separated by "\n" character.
   * @return                       return errors which occured during work of SF Metadata API, which
   *                               inserted new value into picklist field. If no errors occured -
   *                               return blank string.
   */
  public static String addDependencyWorldListPicklistValue(
    String controllingFieldValue,
    String fullNameListRaw
  ) {
    if (String.isBlank(controllingFieldValue)) {
      throw new NoParamException('No controlling param');
    }
    if (String.isBlank(fullNameListRaw)) {
      throw new NoParamException('No picklistValueRaw param');
    }
    MetadataServiceFacade service = new MetadataServiceFacade(
      JwtCredentials.getInstance()
    );
    List<String> fullNameList = (List<String>) JSON.deserialize(
      fullNameListRaw,
      List<String>.class
    );
    List<Base_Product_Dependent__c> bpdList = [
      SELECT Id, Controlling__c, Dependent__c
      FROM Base_Product_Dependent__c
      WHERE Controlling__c = :controllingFieldValue
    ];
    delete bpdList;
    bpdList = new List<Base_Product_Dependent__c>();
    for (String fullName : fullNameList) {
      System.debug('controllingFieldValue ' + controllingFieldValue);
      System.debug('fullName ' + fullName);
      Base_Product_Dependent__c bpds = new Base_Product_Dependent__c();
      bpds.Name = Utility.hashCode(controllingFieldValue + fullName);
      bpds.Controlling__c = controllingFieldValue;
      bpds.Dependent__c = fullName;
      bpdList.add(bpds);
    }
    insert bpdList;
    System.enqueueJob(
      new UpdateDependentPicklistMdataQueueable(
        controllingFieldValue,
        service,
        wordListPicklistApiName,
        baseProductPicklistName,
        fullNameList
      )
    );
    System.enqueueJob(
      new UpdateDependentPicklistMdataQueueable(
        controllingFieldValue,
        service,
        'zqu__Quote__c.Contract_Wording_List_Amend__c',
        'Package_Amendment__c',
        fullNameList
      )
    );

    return '';
  }

  /**
   * Delete value of Word List picklist
   *
   * @param  fullNameToDelete api name of value from Word List picklist
   * @return                  return errors which occured during work of SF Metadata API, which
   *                          deleted value from picklist field. If no errors occured -
   *                          return blank string.
   */
  public static String deleteWorldListPicklistValue(String fullNameToDelete) {
    if (String.isBlank(fullNameToDelete)) {
      throw new NoParamException('No fullName param');
    }
    MetadataServiceFacade service = new MetadataServiceFacade(
      JwtCredentials.getInstance()
    );
    MetadataService.CustomField customField = service.obtainCustomField(
      wordListPicklistApiName
    );
    List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.deleteMetadata(
      'PicklistValue',
      new List<String>{ wordListPicklistApiName + '.' + fullNameToDelete },
      true
    );

    MetadataService.CustomField customFieldAmend = service.obtainCustomField(
      'zqu__Quote__c.Contract_Wording_List_Amend__c'
    );
    List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResultsAmend = service.deleteMetadata(
      'PicklistValue',
      new List<String>{
        'zqu__Quote__c.Contract_Wording_List_Amend__c' +
        '.' +
        fullNameToDelete
      },
      true
    );
    String errors = service.obtainErrors(lstResults);
    if (String.isBlank(errors)) {
      List<Base_Product_Dependent__c> bpdList = [
        SELECT Id, Controlling__c, Dependent__c
        FROM Base_Product_Dependent__c
        WHERE Dependent__c = :fullNameToDelete
      ];
      delete bpdList;
      Base_Product_Contract__c bpcToDelete = Base_Product_Contract__c.getInstance(
        Utility.hashCode(fullNameToDelete)
      );
      delete bpcToDelete;
    }
    return errors;
  }

  /**
   * Edit label of specific value from Word List picklist - in the Word List field
   * itself and in Base_Product_Contract__c custom setting
   *
   * @param  fullName api name of picklist value which need to be edited.
   * @param  label    new label of Word lsit picklist value.
   * @return          return errors which occured during work of SF Metadata API, which
   *                  edited picklist value. If no errors occured - return blank string.
   */
  public static String editWorldListPicklistValues(
    String fullName,
    String label
  ) {
    if (String.isBlank(fullName)) {
      throw new NoParamException('No fullName param');
    }
    if (String.isBlank(label)) {
      throw new NoParamException('No label param');
    }
    MetadataServiceFacade service = new MetadataServiceFacade(
      JwtCredentials.getInstance()
    );
    MetadataService.CustomField customField = service.obtainCustomField(
      wordListPicklistApiName
    );
    service.renamePicklistVlaueLabel(customField, fullName, label);
    List<MetadataServiceFacade.MetadataDmlResultWrapper> lstResults = service.updateMetadata(
      new List<MetadataService.Metadata>{ customField },
      true
    );
    String errors = service.obtainErrors(lstResults);
    if (String.isBlank(errors)) {
      Base_Product_Contract__c bpc = new Base_Product_Contract__c(
        Label__c = label,
        Value__c = fullName,
        Name = Utility.hashCode(fullName)
      );
      upsert bpc Name;
    }
    return errors;
  }

  /**
   * Retrieve records of Base_Product_Default_Addon__c custom settings, filtered by
   * Controlling__c field
   *
   * @param  controllingName value of Controlling__c field which is used to filter.
   *                         Base_Product_Default_Addon__c records which will be returned.
   * @return                 list of Addons names.
   */
  public static List<String> retrieveDefaultAddonsForBaseProduct(
    String controllingName
  ) {
    List<String> result = new List<String>();
    for (Base_Product_Default_Addon__c bpda : [
      SELECT Addon__c
      FROM Base_Product_Default_Addon__c
      WHERE Controlling__c = :controllingName
    ]) {
      result.add(bpda.Addon__c);
    }
    return result;
  }

  public static Map<String, List<String>> retrieveBaseProductsRestrictOptions() {
    Map<String, List<String>> resultMap = new Map<String, List<String>>();
    for (Dynamic_Addons_Restrict_Options__mdt setting : [
      SELECT Restrict_Option_Text__c, Type__c
      FROM Dynamic_Addons_Restrict_Options__mdt
      WHERE Active__c = TRUE
    ]) {
      if (!resultMap.containsKey(setting.Type__c)) {
        resultMap.put(setting.Type__c, new List<String>());
      }
      resultMap.get(setting.Type__c).add(setting.Restrict_Option_Text__c);
    }
    return resultMap;
  }

  /**
   * Retrieve records of Base_Product_Dynamic_Addon__c custom settings, filtered by
   * Controlling__c field.
   *
   * @param  controllingName value of Controlling__c field which is used to filter
   *                         Base_Product_Dynamic_Addon__c records which will be returned.
   * @return                 list of Addons names
   */
  public static List<String> retrieveDynamicAddonsForBaseProduct(
    String controllingName
  ) {
    List<String> result = new List<String>();
    for (Base_Product_Dynamic_Addon__c bpda : [
      SELECT Addon__c
      FROM Base_Product_Dynamic_Addon__c
      WHERE Controlling__c = :controllingName
    ]) {
      result.add(bpda.Addon__c);
    }
    return result;
  }

  /**
   * Retrieve record of Base_Product_Num_of_Users__c custom settings, with certain
   * value in Controlling__c field.
   *
   * @param  controllingName value of Controlling__c field which is used to get specific
   *                         Base_Product_Num_of_Users__c record.
   * @return                 list of Addons names
   */
  public static Integer retrieveDefaultNumberOfUsersForBaseProduct(
    String controllingName
  ) {
    Base_Product_Num_of_Users__c bpnou = Base_Product_Num_of_Users__c.getInstance(
      Utility.hashCode(controllingName)
    );
    if (bpnou != null) {
      return bpnou.Number_of_User__c.intValue();
    } else {
      return null;
    }
  }

  /**
   * Add records of Base_Product_Default_Addon__c custom setting with specific Controlling__c
   * value, and delete all current Base_Product_Default_Addon__c record with that Controlling__c
   * value.
   *
   * @param  fullNameListRaw string with picklist values separated by "\n" character.
   * @param  controllingName value of Controlling__c field.
   */
  public static void setDefaultAddonsForBaseProduct(
    String fullNameListRaw,
    String controllingName
  ) {
    delete [
      SELECT ID
      FROM Base_Product_Default_Addon__c
      WHERE Controlling__c = :controllingName
    ];
    if (String.isNotBlank(fullNameListRaw)) {
      List<String> fullNameList = fullNameListRaw.split('\n');
      List<Base_Product_Default_Addon__c> newDefaultAddonsList = new List<Base_Product_Default_Addon__c>();
      for (String fullName : fullNameList) {
        Base_Product_Default_Addon__c bpda = new Base_Product_Default_Addon__c();
        bpda.Name = Utility.hashCode(fullName + controllingName);
        bpda.Addon__c = fullName;
        bpda.Controlling__c = controllingName;
        newDefaultAddonsList.add(bpda);
      }
      insert newDefaultAddonsList;
    }
  }

  /**
   * Add records of Base_Product_Dynamic_Addon__c custom setting with specific Controlling__c
   * value, and delete all current Base_Product_Dynamic_Addon__c record with that Controlling__c
   * value.
   * @param  fullNameListRaw string with picklist values separated by "\n" character.
   * @param  controllingName value of Controlling__c field.
   */
  public static void setDynamicAddonsForBaseProduct(
    String fullNameListRaw,
    String controllingName
  ) {
    delete [
      SELECT ID
      FROM Base_Product_Dynamic_Addon__c
      WHERE Controlling__c = :controllingName
    ];
    if (String.isNotBlank(fullNameListRaw)) {
      List<String> fullNameList = fullNameListRaw.split('\n');
      List<Base_Product_Dynamic_Addon__c> newDynamicAddonsList = new List<Base_Product_Dynamic_Addon__c>();
      for (String fullName : fullNameList) {
        Base_Product_Dynamic_Addon__c bpda = new Base_Product_Dynamic_Addon__c();
        /* if (fullName.containsIgnoreCase(ZQuoteService.API_HITS_ADDON_POSTFIX)) {
                    bpda.Postfix__c = ZQuoteService.API_HITS_ADDON_POSTFIX;
                } else */ if (
          fullName.startsWithIgnoreCase(
            ZQuoteService.HISTORICAL_DATA_ADDON_PREFIX
          ) &&
          fullName.endsWithIgnoreCase(
            ZQuoteService.HISTORICAL_DATA_ADDON_POSTFIX
          )
        ) {
          bpda.Postfix__c = ZQuoteService.HISTORICAL_DATA_ADDON_POSTFIX;
        } else if (
          fullName.containsIgnoreCase(ZQuoteService.WEBSITE_RESULT_POSTFIX)
        ) {
          bpda.Postfix__c = ZQuoteService.WEBSITE_RESULT_POSTFIX;
        } else if (
          fullName.startsWithIgnoreCase(
            ZQuoteService.HISTORICAL_DATA_ADDON_PREFIX
          ) &&
          fullName.endsWithIgnoreCase(
            ZQuoteService.HISTORICAL_DATA_ONAPI_ADDON_POSTFIX
          ) &&
          controllingName.contains('Lead Enrichment')
        ) {
          bpda.Postfix__c = ZQuoteService.HISTORICAL_DATA_ONAPI_ADDON_POSTFIX;
        } else if (
          (fullName.startsWithIgnoreCase(
            ZQuoteService.LITE_ACCESS_DATA_ADDON_PREFIX
          )) &&
          fullName.endsWithIgnoreCase(
            ZQuoteService.WW_HISTORICAL_DATA_ADDON_POSTFIX
          ) &&
          controllingName.contains('Lead Enrichment')
        ) {
          bpda.Postfix__c = ZQuoteService.WW_HISTORICAL_DATA_ADDON_POSTFIX;
        } else if (
          fullName.containsIgnoreCase(
            ZQuoteService.ALL_CFS_WITH_WW_ON_API_FULLNAME
          ) && controllingName.contains('Lead Enrichment')
        ) {
          bpda.Postfix__c = ZQuoteService.ALL_CFS_WITH_WW_ON_API_POSTFIX;
        }
        if (String.isBlank(bpda.Postfix__c)) {
          throw new InvalidAddonPostfixException(
            'Invalid postfix - should be \'' +
              ZQuoteService.HISTORICAL_DATA_ADDON_POSTFIX +
              '\' or \'' +
              ZQuoteService.WEBSITE_RESULT_POSTFIX +
              '\''
          ); //'Invalid postfix - should be \'' + ZQuoteService.API_HITS_ADDON_POSTFIX + '\' or \'' + ZQuoteService.HISTORICAL_DATA_ADDON_POSTFIX + '\''
        }
        bpda.Name = Utility.hashCode(fullName + controllingName);
        bpda.Addon__c = fullName;
        bpda.Controlling__c = controllingName;
        newDynamicAddonsList.add(bpda);
      }
      insert newDynamicAddonsList;
    }
  }

  /**
   * Upsert record of Base_Product_Num_of_Users__c custom setting with specific Controlling__c
   * value.
   *
   * @param  numberOfUsers   value of Number_of_User__c field
   * @param  controllingName value of Controlling__c field
   */
  public static void setDefaultNumberOfUsersForBaseProduct(
    Integer numberOfUsers,
    String controllingName
  ) {
    if (numberOfUsers == null) {
      throw new NoParamException('No numberOfUsers param');
    }
    Base_Product_Num_of_Users__c bpnou = Base_Product_Num_of_Users__c.getInstance(
      Utility.hashCode(controllingName)
    );
    if (bpnou != null) {
      bpnou.Number_of_User__c = numberOfUsers;
    } else {
      bpnou = new Base_Product_Num_of_Users__c();
      bpnou.Name = Utility.hashCode(controllingName);
      bpnou.Number_of_User__c = numberOfUsers;
      bpnou.Controlling__c = controllingName;
    }
    upsert bpnou Name;
  }

  private class NoParamException extends Exception {
  }
  private class InvalidAddonPostfixException extends Exception {
  }
  private class InvalidSettingException extends Exception {
  }
}

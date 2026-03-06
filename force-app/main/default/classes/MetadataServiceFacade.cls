public with sharing class MetadataServiceFacade {
  private MetadataService.MetadataPort service;
  public final static String LOCK_ERROR_MESSAGE = 'unable to obtain exclusive access to this record';

  public MetadataServiceFacade(String aud, String iss, String certificate) {
    service = createService(aud, iss, certificate);
  }

  public MetadataServiceFacade(JwtCredentials jwtCredentials) {
    service = createService(
      jwtCredentials.aud,
      jwtCredentials.iss,
      jwtCredentials.certificate
    );
  }

  public MetadataServiceFacade() {
    String sessionId = UserInfo.getSessionId();
    service = createService(sessionId);
  }

  public MetadataService.CustomField obtainCustomField(String customFieldName) {
    MetadataService.CustomField customField = (MetadataService.CustomField) service.readMetadata(
        'CustomField',
        new List<String>{ customFieldName }
      )
      .getRecords()[0];
    return customField;
  }

  /* public List<MetadataService.RecordType> obtainCustomObjectRTs(String customObjectName){
        MetadataService.CustomObject customObject = (MetadataService.CustomObject) service.readMetadata('CustomObject', new String[] { customObjectName}).getRecords()[0];
        return customObject.recordTypes;
    } */

  public MetadataService.CustomObject obtainCustomObject(
    String customObjectName
  ) {
    MetadataService.CustomObject customObject = (MetadataService.CustomObject) service.readMetadata(
        'CustomObject',
        new List<String>{ customObjectName }
      )
      .getRecords()[0];
    return customObject;
  }

  public List<MetadataService.RecordType> addPicklistValueToCustomObjectRTs(
    MetadataService.CustomObject customObject,
    String picklistName,
    List<String> fullNameList
  ) {
    for (MetadataService.RecordType rt_i : customObject.recordTypes) {
      System.debug('RT СustomObject: ' + customObject.fullName);
      System.debug('RT FullName: ' + rt_i.fullName);
      String newFullName = customObject.fullName + '.' + rt_i.fullName;
      if (!rt_i.fullName.contains('.')) {
        rt_i.fullName = newFullName;
      }
      ((MetadataService.Metadata) rt_i).fullName = rt_i.fullName;
      MetadataService.RecordTypePicklistValue rtpv;
      for (
        MetadataService.RecordTypePicklistValue rtpv_i : rt_i.picklistValues
      ) {
        System.debug('rtpv_i.picklist: ' + rtpv_i.picklist);
        if (rtpv_i.picklist == picklistName) {
          rtpv = rtpv_i;
          break;
        }
      }
      rt_i.picklistValues = new List<MetadataService.RecordTypePicklistValue>();
      if (rtpv == null) {
        rtpv = new MetadataService.RecordTypePicklistValue();
        rtpv.picklist = picklistName;
        rtpv.values = new List<MetadataService.PicklistValue>();
      }
      for (String fullName : fullNameList) {
        MetadataService.PicklistValue pv = new MetadataService.PicklistValue();
        pv.fullName = fullName;
        pv.default_x = false;
        rtpv.values.add(pv);
      }
      rt_i.picklistValues.add(rtpv);
      System.debug('s ' + JSON.serializePretty(rtpv));
    }
    return customObject.recordTypes;
  }

  /* public List<MetadataService.RecordType> addPicklistValueToCustomObjectRTs(String objectApiName
                                                                            , String picklistName
                                                                            , List<String> fullNameList)
    {
        List<MetadataService.RecordType> recordTypeMdList = obtainCustomObjectRTs(objectApiName);
        System.debug('recordTypeMdList size ' + recordTypeMdList.size());
        System.debug('s1 ' + JSON.serializePretty(recordTypeMdList[0]));
        // List<RecordType> recordTypeSObjectList = [SELECT Id
        //                                      , Description
        //                                      , DeveloperName
        //                                      , Name
        //                                      , NamespacePrefix
        //                                 FROM RecordType
        //                                 WHERE SobjectType =: objectApiName
        //                                       AND isActive = true];
        // System.debug(recordTypeSObjectList.size());
        // for (RecordType rt_i : recordTypeSObjectList) {
        //     MetadataService.RecordType rtMd = new MetadataService.RecordType();
        //     rtMd.fullName = '';
        //     if (String.isNotBlank(rt_i.NamespacePrefix)) {
        //         rtMd.fullName = rt_i.NamespacePrefix+'__';
        //     }
        //     rtMd.fullName += rt_i.DeveloperName;
        //     rtMd.active = true;
        //     rtMd.description = rt_i.Description;
        //     rtMd.label = rt_i.Name;
        //     rtMd.picklistValues = new List<MetadataService.RecordTypePicklistValue>();
        //     recordTypeMdList.add(rtMd);
        // }

        for (MetadataService.RecordType rtMd_i : recordTypeMdList){       
            MetadataService.RecordTypePicklistValue rtpv; 
            for(MetadataService.RecordTypePicklistValue rtpv_i : rtMd_i.picklistValues){                        
                if(rtpv_i.picklist == picklistName){
                    rtpv = rtpv_i;
                    break;
                }
            }
            System.debug('s2 ' + JSON.serializePretty(rtpv));
            rtMd_i.picklistValues = new List<MetadataService.RecordTypePicklistValue>();
            if (rtpv == null){
                System.debug('cc');
                rtpv = new MetadataService.RecordTypePicklistValue();
                rtpv.picklist = picklistName;
                rtpv.values = new List <MetadataService.PicklistValue> ();
            }
            for (String fullName: fullNameList) {
                MetadataService.PicklistValue pv = new MetadataService.PicklistValue();
                pv.fullName = fullName;
                pv.default_x = false;
                rtpv.values.add(pv);
            }
            rtMd_i.picklistValues.add(rtpv);
            System.debug('s ' + JSON.serializePretty(rtpv));
        }
       
        return recordTypeMdList;
    } */

  public MetadataService.CustomField addPicklistValueToCustomField(
    MetadataService.CustomField customField,
    List<String> fullNameList
  ) {
    fullNameList = fullNameList.clone(); //to avoid change in caller scope
    for (
      MetadataService.CustomValue objCustomValue : customField.valueSet.valueSetDefinition.value
    ) {
      if (
        objCustomValue.isActive != null &&
        objCustomValue.isActive == false &&
        fullNameList.contains(objCustomValue.fullName)
      ) {
        System.debug('Facade: ' + objCustomValue);
        objCustomValue.isActive = true;
        objCustomValue.label = objCustomValue.fullName; // if value has edited label and then was deactivated
        fullNameList.remove(fullNameList.indexOf(objCustomValue.fullName));
      }
    }

    for (String fullName : fullNameList) {
      PicklistValue picklistValueToAdd = new PicklistValue(fullName, fullName);
      MetadataService.CustomValue metadataPicklistValueToAdd = new MetadataService.CustomValue();
      metadataPicklistValueToAdd.fullName = picklistValueToAdd.value;
      metadataPicklistValueToAdd.label = picklistValueToAdd.label;
      metadataPicklistValueToAdd.default_x = false;
      metadataPicklistValueToAdd.isActive = true;

      customField.valueSet.valueSetDefinition.value.add(
        metadataPicklistValueToAdd
      );
    }

    return customField;
  }

  /* public Map<String,PicklistValue> obtainPicklistValueMap(MetadataService.CustomField customField){
        Map<String,PicklistValue> picklistValueMap = new Map<String,PicklistValue>();
        for (MetadataService.CustomValue objCustomValue : customField.valueSet.valueSetDefinition.value){
            if (objCustomValue.isActive == null || objCustomValue.isActive == true) {
                PicklistValue pv = new PicklistValue(objCustomValue.label,objCustomValue.fullName);
                picklistValueMap.put(objCustomValue.fullName,pv);
            }
        }
        return picklistValueMap;
    }

    public List<PicklistValue> obtainPicklistValueList(MetadataService.CustomField customField){
        List<PicklistValue> picklistValueList = obtainPicklistValueMap(customField).values();
        return picklistValueList;
    }

    public List<PicklistValue> obtainPicklistValueList(MetadataService.CustomField customField,String controllingFieldValue){
        List<PicklistValue> picklistValueList = new List<PicklistValue>();
        Map<String,PicklistValue> picklistValueMap = obtainPicklistValueMap(customField);
        for(MetadataService.ValueSettings objValueSettings : customField.valueSet.valueSettings){
            if (objValueSettings.controllingFieldValue.contains(controllingFieldValue) && picklistValueMap.containsKey(objValueSettings.valueName)) {
                picklistValueList.add(picklistValueMap.get(objValueSettings.valueName));                                    
            }
        }
        return picklistValueList;
    } */

  public Map<String, List<String>> obtainPicklistValueDependentMap(
    MetadataService.CustomField customField
  ) {
    Map<String, List<String>> dependantPicklistValueMap = new Map<String, List<String>>();
    if (
      customField != null &&
      customField.valueSet != null &&
      customField.valueSet.valueSettings != null
    ) {
      for (
        MetadataService.ValueSettings objValueSettings : customField.valueSet.valueSettings
      ) {
        for (
          String controllingFieldValue_i : objValueSettings.controllingFieldValue
        ) {
          List<String> valueList = new List<String>();
          if (dependantPicklistValueMap.containsKey(controllingFieldValue_i)) {
            valueList = dependantPicklistValueMap.get(controllingFieldValue_i);
          }
          valueList.add(objValueSettings.valueName);
          dependantPicklistValueMap.put(controllingFieldValue_i, valueList);
        }
      }
    }
    return dependantPicklistValueMap;
  }

  public MetadataService.CustomField renamePicklistVlaueLabel(
    MetadataService.CustomField customField,
    String fullName,
    String newLabel
  ) {
    Boolean isFound = false;
    for (
      MetadataService.CustomValue objCustomValue : customField.valueSet.valueSetDefinition.value
    ) {
      if (objCustomValue.fullName == fullName) {
        objCustomValue.label = newLabel;
        isFound = true;
        break;
      }
    }

    if (!isFound) {
      throw new MetadataNotFoundException(
        'No picklist value with such api name found'
      );
    }
    return customField;
  }

  public List<MetadataService.ValueSettings> addDependentPicklistValues(
    MetadataService.CustomField customField,
    List<String> fullNameList,
    String controllingFieldValue
  ) {
    Map<String, MetadataService.ValueSettings> newValueSettings = new Map<String, MetadataService.ValueSettings>();
    if (
      customField.valueSet != null &&
      customField.valueSet.valueSettings != null
    ) {
      for (
        MetadataService.ValueSettings objValueSettings : customField.valueSet.valueSettings
      ) {
        if (
          !objValueSettings.controllingFieldValue.contains(
            controllingFieldValue
          ) || fullNameList.contains(objValueSettings.valueName)
        ) {
          newValueSettings.put(objValueSettings.valueName, objValueSettings);
        } else if (
          objValueSettings.controllingFieldValue.contains(
            controllingFieldValue
          ) && objValueSettings.controllingFieldValue.size() > 1
        ) {
          objValueSettings.controllingFieldValue.remove(
            objValueSettings.controllingFieldValue.indexOf(
              controllingFieldValue
            )
          );
          newValueSettings.put(objValueSettings.valueName, objValueSettings);
        }
      }
    }
    if (fullNameList.isEmpty()) {
      MetadataService.ValueSettings nullValueSetting = new MetadataService.ValueSettings();
      nullValueSetting.valueName = 'NULL_VALUE';
      nullValueSetting.controllingFieldValue = new List<String>{
        controllingFieldValue
      };
      newValueSettings.put(nullValueSetting.valueName, nullValueSetting);
    } else {
      for (String fullName : fullNameList) {
        MetadataService.ValueSettings metadataPicklistDependencyDataToAdd;
        if (newValueSettings.containsKey(fullName)) {
          metadataPicklistDependencyDataToAdd = newValueSettings.get(fullName);
          metadataPicklistDependencyDataToAdd.controllingFieldValue.add(
            controllingFieldValue
          );
        } else {
          metadataPicklistDependencyDataToAdd = new MetadataService.ValueSettings();
          metadataPicklistDependencyDataToAdd.valueName = fullName;
          metadataPicklistDependencyDataToAdd.controllingFieldValue = new List<String>{
            controllingFieldValue
          };
        }
        newValueSettings.put(
          metadataPicklistDependencyDataToAdd.valueName,
          metadataPicklistDependencyDataToAdd
        );
      }
    }
    return newValueSettings.values();
  }

  public String obtainErrors(List<MetadataDmlResultWrapper> lstResultsWrapper) {
    String errors = '';
    for (MetadataDmlResultWrapper mdrv : lstResultsWrapper) {
      if (!mdrv.isSuccess && mdrv.error != LOCK_ERROR_MESSAGE) {
        errors += mdrv.error + ';\n';
      }
    }
    return errors;
  }

  public Boolean checkForLockErrors(
    List<MetadataDmlResultWrapper> lstResultsWrapper
  ) {
    Boolean isLockError = false;
    for (MetadataDmlResultWrapper mdrv : lstResultsWrapper) {
      if (!mdrv.isSuccess) {
        if (mdrv.error == LOCK_ERROR_MESSAGE) {
          isLockError = true;
          break;
        }
      }
    }
    return isLockError;
  }

  public List<MetadataDmlResultWrapper> upsertMetadata(
    List<MetadataService.Metadata> metadataList,
    Boolean isRetryOnLock
  ) {
    List<MetadataService.UpsertResult> lstResults = service.upsertMetadata(
      metadataList
    );
    List<MetadataDmlResultWrapper> lstResultsWrapper = new List<MetadataDmlResultWrapper>();
    for (MetadataService.UpsertResult rst : lstResults) {
      lstResultsWrapper.add(new MetadataDmlResultWrapper(rst));
    }
    if (isRetryOnLock && checkForLockErrors(lstResultsWrapper)) {
      System.enqueueJob(new UpdateMdataQueueable(this, metadataList, 'UPSERT'));
    }
    return lstResultsWrapper;
  }

  public List<MetadataDmlResultWrapper> updateMetadata(
    List<MetadataService.Metadata> metadataList,
    Boolean isRetryOnLock
  ) {
    List<MetadataService.SaveResult> lstResults = service.updateMetadata(
      metadataList
    );
    List<MetadataDmlResultWrapper> lstResultsWrapper = new List<MetadataDmlResultWrapper>();
    for (MetadataService.SaveResult rst : lstResults) {
      lstResultsWrapper.add(new MetadataDmlResultWrapper(rst));
    }
    if (isRetryOnLock && checkForLockErrors(lstResultsWrapper)) {
      System.enqueueJob(new UpdateMdataQueueable(this, metadataList, 'UPDATE'));
    }
    return lstResultsWrapper;
  }

  public List<MetadataDmlResultWrapper> deleteMetadata(
    String type,
    List<String> metadataNameList,
    Boolean isRetryOnLock
  ) {
    List<MetadataService.DeleteResult> lstResults = service.deleteMetadata(
      type,
      metadataNameList
    );
    List<MetadataDmlResultWrapper> lstResultsWrapper = new List<MetadataDmlResultWrapper>();
    for (MetadataService.DeleteResult rst : lstResults) {
      lstResultsWrapper.add(new MetadataDmlResultWrapper(rst));
    }
    if (isRetryOnLock && checkForLockErrors(lstResultsWrapper)) {
      System.enqueueJob(new UpdateMdataQueueable(this, type, metadataNameList));
    }
    return lstResultsWrapper;
  }

  public MetadataService.MetadataPort createService(
    String aud,
    String iss,
    String certificate
  ) {
    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.timeout_x = 40000;
    Auth.JWT jwt = new Auth.JWT();
    jwt.setSub(UserInfo.getUserName());
    jwt.setAud(aud);
    jwt.setIss(iss);
    Auth.JWS jws = new Auth.JWS(jwt, certificate);
    String tokenEndpoint =
      URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/token';
    Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(
      tokenEndpoint,
      jws
    );
    if (!Test.isRunningTest()) {
      String accessToken = bearer.getAccessToken();
      service.SessionHeader.sessionId = accessToken;
    } else {
      service.SessionHeader.sessionId = 'accessToken';
    }
    return service;
  }

  public MetadataService.MetadataPort createService(String sessionId) {
    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.timeout_x = 40000;
    service.SessionHeader.sessionId = sessionId;
    return service;
  }

  public class MetadataDmlResultWrapper {
    Boolean isSuccess;
    String error;

    public MetadataDmlResultWrapper(MetadataService.SaveResult updateResult) {
      wrap(updateResult.success, updateResult.errors);
    }

    public MetadataDmlResultWrapper(MetadataService.UpsertResult upsertResult) {
      wrap(upsertResult.success, upsertResult.errors);
    }

    public MetadataDmlResultWrapper(MetadataService.DeleteResult deleteResult) {
      wrap(deleteResult.success, deleteResult.errors);
    }

    private void wrap(Boolean success, MetadataService.Error[] errors) {
      isSuccess = success;
      if (!success) {
        if (errors.size() > 0) {
          error = errors[0].message;
        }
      }
    }
  }

  public class MetadataNotFoundException extends Exception {
  }
}

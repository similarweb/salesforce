/*************************************************************************************************************
 * @name			ZuoraSObjectUpdatePlugin
 * @author			Synebo Developer
 * @created			07 / 07 / 2022
 * @description		MQ-1582. Plugin for use in Zrules. It is necessary to specify in the attributes
 *                  the api name of the field and the value in order to update the object.
 *                  Attributes support types: String, Boolean.
 *
 **************************************************************************************************************/
global with sharing class ZuoraSObjectUpdatePlugin implements zqu.CustomActionPlugin {
  global void perform(
    zqu.DataObject masterObject,
    Map<String, Object> attributes,
    String[] logs
  ) {
    Id sObjectId;
    if (Test.isRunningTest()) {
      sObjectId = [SELECT Id FROM zqu__Quote__c LIMIT 1].Id;
    } else {
      sObjectId = (String) masterObject.get('Id');
    }

    if (attributes.isEmpty()) {
      throw new zqu.CustomValidationException(
        'You must specify at least 1 attribute. (ZuoraSObjectUpdatePlugin)'
      );
    }

    String apiName = sObjectId.getSObjectType().getDescribe().getName();

    SObjectType sObjectType = Schema.getGlobalDescribe().get(apiName);
    Map<String, Schema.SObjectField> mfields = sObjectType.getDescribe()
      .fields.getMap();
    String objectLabel = (String) Schema.getGlobalDescribe()
      .get(apiName)
      .getDescribe()
      .getLabel();
    updateRelatedQuote(sObjectId, attributes, mfields, apiName);
    String fieldsLine = '';
    for (String field : attributes.keySet()) {
      fieldsLine += field + ', ';
    }
    fieldsLine.removeEnd(', ');
    logs.add(
      'The "' + fieldsLine + '" fields have been updated to ' + objectLabel
    );
  }

  private void updateRelatedQuote(
    String sObjectId,
    Map<String, Object> attributes,
    Map<String, Schema.SObjectField> mfields,
    String apiName
  ) {
    if (String.isNotBlank(sObjectId)) {
      sObject sObj = Schema.getGlobalDescribe().get(apiName).newSObject();
      sObj.put('Id', sObjectId);

      for (String key : attributes.keySet()) {
        if (mfields.containsKey(key)) {
          if (attributes.get(key) == 'true') {
            sObj.put(key, true);
          } else if (attributes.get(key) == 'false') {
            sObj.put(key, false);
          } else {
            sObj.put(key, attributes.get(key));
          }
        } else {
          throw new zqu.CustomValidationException(
            'Object "' +
              apiName +
              '" does not contain field "' +
              key +
              '". (ZuoraSObjectUpdatePlugin)'
          );
        }
      }

      update sObj;
    }
  }

  global Boolean isUpdateAction() {
    return true;
  }
  global Boolean isAddRemoveAction() {
    return true;
  }
  global Boolean isValidateAction() {
    return true;
  }
}

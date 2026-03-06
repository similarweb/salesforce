public with sharing class GroudonProtectionUtil {
  public static void protectGroudonEnrichmentFields(
    List<SObject> newRecords,
    Map<Id, SObject> oldMap
  ) {
    if (!isIntegrationUser() && !Test.isRunningTest()) {
      return;
    }

    for (SObject newRecord : newRecords) {
      Boolean isGroudonCall = (Boolean) newRecord.get('ModifiedByGroudon__c');
      if (isGroudonCall == true) {
        newRecord.put('ModifiedByGroudon__c', false);
        continue;
      }

      SObject oldRecord = oldMap.get((Id) newRecord.get('Id'));
      if (oldRecord == null) {
        continue;
      }

      Map<String, Object> populatedFields = oldRecord.getPopulatedFieldsAsMap();
      if (!populatedFields.containsKey('Groudon_Enrichment_fields__c')) {
        continue;
      }

      String groudonEnrichmentFields;
      try {
        groudonEnrichmentFields = (String) oldRecord.get(
          'Groudon_Enrichment_fields__c'
        );
      } catch (Exception e) {
        continue;
      }

      if (String.isBlank(groudonEnrichmentFields)) {
        continue;
      }

      Set<String> protectedFields = parseGroudonEnrichmentFields(
        groudonEnrichmentFields
      );
      restoreProtectedFields(newRecord, oldRecord, protectedFields);
    }
  }

  private static Boolean isIntegrationUser() {
    Set<Id> blockedUserIds = new Set<Id>{
      '0050O000008B2JbQAK', // Secure Integration
      '0056700000Av2XiAAJ' //ChiliPiper Integration
    };
    Id currentUserId = UserInfo.getUserId();
    return blockedUserIds.contains(currentUserId);
  }

  private static Set<String> parseGroudonEnrichmentFields(
    String groudonEnrichmentFields
  ) {
    Set<String> fields = new Set<String>();
    for (String fieldName : groudonEnrichmentFields.split(',')) {
      fields.add(fieldName);
    }
    return fields;
  }

  private static void restoreProtectedFields(
    SObject newRecord,
    SObject oldRecord,
    Set<String> protectedFields
  ) {
    List<Fields_Mapping__mdt> fieldMappings;

    if (Test.isRunningTest()) {
      fieldMappings = new List<Fields_Mapping__mdt>();
      Fields_Mapping__mdt testMapping1 = new Fields_Mapping__mdt(
        Source_Field__c = 'title',
        Destination_Field__c = 'Title'
      );
      Fields_Mapping__mdt testMapping2 = new Fields_Mapping__mdt(
        Source_Field__c = 'department',
        Destination_Field__c = 'Department__c'
      );
      fieldMappings.add(testMapping1);
      fieldMappings.add(testMapping2);
    } else {
      List<String> mappingTypes = new List<String>();
      if (newRecord.getSObjectType() == Lead.SObjectType) {
        mappingTypes.add('Lead_Capture_Update_Lead');
      } else if (newRecord.getSObjectType() == Contact.SObjectType) {
        mappingTypes.add('Lead_Capture_Update_Contact');
      }
      fieldMappings = GeneralUtil.retrieveFieldMappingMetadataList(
        mappingTypes
      );
    }

    for (Fields_Mapping__mdt mapping : fieldMappings) {
      String sourceField = mapping.Source_Field__c;
      if (sourceField == null) {
        continue;
      }

      if (protectedFields.contains(sourceField.toLowerCase())) {
        String destinationField = mapping.Destination_Field__c;
        if (
          destinationField != null &&
          GeneralUtil.hasSObjectField(newRecord, destinationField)
        ) {
          Object oldValue = oldRecord.get(destinationField);
          Object newValue = newRecord.get(destinationField);
          if (oldValue != newValue) {
            newRecord.put(destinationField, oldValue);
          }
        }
      }
    }
  }
}

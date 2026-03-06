public with sharing class RenewalAiAwaitingController {
  @AuraEnabled(cacheable=false)
  public static Boolean checkFieldsPopulated(
    String recordId,
    List<String> fieldNames
  ) {
    if (
      String.isBlank(recordId) ||
      fieldNames == null ||
      fieldNames.isEmpty()
    ) {
      return false;
    }

    String fieldsStr = String.join(fieldNames, ', ');
    String query =
      'SELECT ' +
      fieldsStr +
      ' FROM Opportunity WHERE Id = :recordId LIMIT 1';

    try {
      List<SObject> records = Database.query(query);
      if (records.isEmpty()) {
        return false;
      }

      SObject record = records[0];

      for (String fieldName : fieldNames) {
        Object fieldValue = record.get(fieldName);
        if (fieldValue != null && String.valueOf(fieldValue) != '') {
          return true;
        }
      }

      return false;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error checking fields: ' + e.getMessage()
      );
    }
  }
}

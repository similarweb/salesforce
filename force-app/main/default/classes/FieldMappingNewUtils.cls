/**
 * @author Itzik Winograd
 * @date 26/04/2021
 * @description Utilize the field mapping utils in a simple way.
 * --------------------------------------------------------------------------------------
 * CHANGE HISTORY:
 * --------------------------------------------------------------------------------------
 * author      -
 * date        -
 * description -
 * --------------------------------------------------------------------------------------
 */
public with sharing class FieldMappingNewUtils {
  public Map<String, FieldMappingNewUtils.FieldMappingUnit> sourceVsMapping = new Map<String, FieldMappingNewUtils.FieldMappingUnit>();
  public Map<String, FieldMappingNewUtils.FieldMappingUnit> destinationVsMapping = new Map<String, FieldMappingNewUtils.FieldMappingUnit>();

  /**
   * @author Itzik Winograd
   * @date 26/04/2021
   * @description Constructor. Gets a the "Process Name" in the FieldMapping custom meta data records,
   * And builds maps of all the Source/Destination field name vs the FieldMappingUnit they are in.
   * @param String fieldMappingProcessName "Process Name" in the FieldMapping custom meta data records .
   */
  public FieldMappingNewUtils(String fieldMappingProcessName) {
    List<Fields_Mapping__mdt> fieldsMappingList = GeneralUtil.retrieveFieldMappingMetadataList(
      fieldMappingProcessName
    );
    if (fieldsMappingList.size() > 0) {
      for (Fields_Mapping__mdt fmd : fieldsMappingList) {
        FieldMappingUnit fmu = new FieldMappingUnit(fmd);
        sourceVsMapping.put(fmu.source, fmu);
        destinationVsMapping.put(fmu.destination, fmu);
      }
    } else {
      sourceVsMapping = null;
      destinationVsMapping = null;
      Eventbus.publish(
        LogEventUtils.createLogEventRecord(
          null,
          'FieldMappingNewUtils',
          'Constructor for process' + fieldMappingProcessName,
          null,
          'No field mapping with the process name ' +
            fieldMappingProcessName +
            ' was found!',
          'Error'
        )
      );
    }
  }

  /**
   * @author Itzik Winograd
   * @date 30/09/2021
   * @description Gets a source SObject and a destination Sobject, and return the destination SObject with values from the source according to the mapping.
   * @param SObject sourceRecord - Source SObject
   * @param SObject destinationSObject - Destination SObject
   * @return SObject the "destinationSObject" with values from the mapping, or null if there was a problem in constructing the FieldMappingUtils.
   */
  public SObject setValuesFromSourceToDestination(
    SObject sourceSObject,
    SObject destinationSObject
  ) {
    if (destinationVsMapping != null) {
      for (FieldMappingUnit fmu : destinationVsMapping.values()) {
        if (GeneralUtil.hasSObjectField(destinationSObject, fmu.destination)) {
          //put the value only if the destination field is valid
          System.debug(
            '### fmnu, assign to fmu.destination: ' + fmu.destination
          );
          destinationSObject.put(fmu.destination, fmu.getValue(sourceSObject));
        }
      }
      System.debug(
        '### setValuesFromSourceToDestination returned sobject: ' +
        destinationSObject
      );
      return destinationSObject;
    } else {
      return null;
    }
  }

  /**
   * @author Itzik Winograd
   * @date 28/02/2021
   * @description Provides a query of all the destinations fields. returns a query with SELECT..FROM, without "WHERE"
   * @param String objectName - the object name to query from.
   * @param String  additionalFields - more fields to query, if needed. pass '' if none neede.
   * @return String query.
   */
  public String getDestinationQuery(
    String objectName,
    String additionalFields
  ) {
    String query = 'SELECT ';
    for (String field : destinationVsMapping.keySet()) {
      if (
        GeneralUtil.hasSObjectField(
          Schema.getGlobalDescribe().get(objectName).newSObject(),
          field
        )
      ) {
        query += field + ',';
      }
    }
    query += additionalFields;
    query = query.removeEnd(',');
    query += ' FROM ' + objectName;
    return query;
  }

  /**
   * @author Itzik Winograd
   * @date 28/02/2021
   * @description Provides a query of all the Source fields. returns a query with SELECT..FROM, without "WHERE"
   * @param String objectName - the object name to query from.
   * @param String  additionalFields - more fields to query, if needed. pass '' if none neede.
   * @return String query.
   */
  public String getSourceQuery(String objectName, String additionalFields) {
    String query = 'SELECT ';
    for (String field : sourceVsMapping.keySet()) {
      if (
        sourceVsMapping.get(field).fixedValue == null &&
        GeneralUtil.hasSObjectField(
          Schema.getGlobalDescribe().get(objectName).newSObject(),
          field
        )
      ) {
        query += field + ',';
      }
    }
    query += additionalFields;
    query = query.removeEnd(',');
    query += ' FROM ' + objectName;
    return query;
  }

  /**
   * @author Itzik Winograd
   * @date 26/04/2021
   * @description represents a single unit of field mapping
   * --------------------------------------------------------------------------------------
   * CHANGE HISTORY:
   * --------------------------------------------------------------------------------------
   * author      - Itzik Winograd
   * date        - 30/09/2021
   * description - Added the getValue method to support full mapping from sourec SObject
   *               to destination SObjcet.
   * --------------------------------------------------------------------------------------
   */
  public class FieldMappingUnit {
    public String destination;
    public String source;
    public String castTo;
    public String fixedValue;

    //Constructor to build a field mapping unit.
    //Gets a single Fields_Mapping__mdt record at a time and parse it respectively.
    public FieldMappingUnit(Fields_Mapping__mdt fieldMappingRecord) {
      this.destination = fieldMappingRecord.Destination_Field__c;
      this.source = fieldMappingRecord.Source_Field__c;
      this.castTo = fieldMappingRecord.Cast_To__c;
      this.fixedValue = fieldMappingRecord.Fixed_Value__c;
    }

    //get a value, convert it and return it
    public Object convertValue(Object value, String dateFormat) {
      return GeneralUtil.castObjectTo(value, castTo, dateFormat);
    }

    /**
     * @author Itzik Winograd
     * @date 30/09/2021
     * @description make a loop over the "source" field in order to handle values from parent records
     *              (e.g. Parent__r.AnotherParent__r.Parent_Contact__r.Account.SomeField__c).
     * @param SObject sourceSObject.
     * @return Object the object value.
     */
    public Object getValue(SObject sourceSObject) {
      Object objectValue = null;
      if (fixedValue == null) {
        List<String> splitString = source.split('\\.');
        SObject currentSourceSObject = sourceSObject;
        for (Integer i = 0; i < splitString.size(); i++) {
          //System.debug('@@@ currentSourceSObject ' + currentSourceSObject);
          //System.debug('@@@ splitString[i]: ' + splitString[i]);
          if (currentSourceSObject == null) {
            //System.debug('@@@ currentSourceSObject null and break!');
            break; //safty mechanism
          }
          if (i + 1 == splitString.size()) {
            //final assignment when we are at the field itself, make sure this field exists
            if (
              GeneralUtil.hasSObjectField(currentSourceSObject, splitString[i])
            ) {
              objectValue = currentSourceSObject.get(splitString[i]);
              System.debug('@@@ updated objectValue: ' + objectValue);
            } else {
              return null;
            }
          } else {
            //the way to make us progress in the parents tree
            currentSourceSObject = currentSourceSObject.getSObject(
              splitString[i]
            );
            //System.debug('@@@ progressing in the parents tree. currentSourceSObject: ' + currentSourceSObject);
          }
        }
        //System.debug('@@@ final objectValue: ' + objectValue);
        return objectValue == null
          ? ''
          : convertValue(objectValue, 'YYYY-MM-DDThh:mm:ssZ');
        //return convertValue(objectValue,'YYYY-MM-DDThh:mm:ssZ');
      } else {
        return convertValue((Object) fixedValue, 'YYYY-MM-DDThh:mm:ssZ');
      }
    }
  }
}

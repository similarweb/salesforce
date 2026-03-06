public with sharing class FieldMappingUtil {

    private static final String DEFAULT_DATE_FORMAT = 'MM/dd/yyyy';
    private static final String DATE_FORMAT_CONFIG_NAME = 'FieldMappingDateFormat';

    public static String dateFormat{
        get{
            if (dateFormat == null) {
                List<General_Configuration__mdt> generalConfigurationList = GeneralUtil.retrieveConfigurationMetadata(new Set<String>{DATE_FORMAT_CONFIG_NAME});
                if (!generalConfigurationList.isEmpty() && String.isNotBlank(generalConfigurationList[0].Text_Value__c)) {
                    dateFormat = generalConfigurationList[0].Text_Value__c;
                } else {
                    dateFormat = DEFAULT_DATE_FORMAT;
                }
            }
            return dateFormat;
        }
        private set;
    }

    public static FieldMappingData generateFieldMappingDataFromFieldMappingCMT(List<Fields_Mapping__mdt> metadataFieldMappingList){
        System.debug('metadataFieldMappingList--'+metadataFieldMappingList);
        FieldMappingData fieldMappingData = new FieldMappingData();

        Map<String,FieldMappingDataUnit> fieldMappingDataUnitMap = new Map<String,FieldMappingDataUnit>();
        for(Fields_Mapping__mdt fieldMapping:metadataFieldMappingList){
            FieldMappingDataUnit fieldMappingDataUnit = new FieldMappingDataUnit(fieldMapping);
            System.debug('fieldMappingDataUnit--'+fieldMappingDataUnit);
            System.debug('fieldMapping.Source_Field__c--'+fieldMapping.Source_Field__c);
            if(fieldMappingDataUnitMap.containsKey(fieldMapping.Destination_Field__c)){
                fieldMappingDataUnitMap.get(fieldMapping.Destination_Field__c).setNextPart(fieldMappingDataUnit);
            } else {
                fieldMappingDataUnitMap.put(fieldMapping.Destination_Field__c, fieldMappingDataUnit);
            }
            if(String.isNotBlank(fieldMapping.Source_Field__c)){
                fieldMappingData.sourceFieldSet.add(fieldMapping.Source_Field__c );
            }
            fieldMappingData.destinationFieldSet.add(fieldMapping.Destination_Field__c);
        }

        fieldMappingData.fieldMappingDataUnitMap = fieldMappingDataUnitMap;
        System.debug('fieldMappingData--'+fieldMappingData);

        return fieldMappingData;
    }

    public static FieldMappingData generateFieldMappingDataFromGeneralConfigCMT(List<General_Configuration__mdt> generalConfigurationList){
        FieldMappingData fieldMappingData = new FieldMappingData();
    
        Map<String,FieldMappingDataUnit> fieldMappingDataUnitMap = new Map<String,FieldMappingDataUnit>();
        for(General_Configuration__mdt generalConf: generalConfigurationList){
            FieldMappingDataUnit fieldMappingDataUnit = new FieldMappingDataUnit(generalConf.DeveloperName,generalConf);
            if(fieldMappingDataUnitMap.containsKey(fieldMappingDataUnit.sourceField)){
                fieldMappingDataUnitMap.get(fieldMappingDataUnit.sourceField).setNextPart(fieldMappingDataUnit);
            } else {
                fieldMappingDataUnitMap.put(generalConf.DeveloperName, fieldMappingDataUnit);
            }
        }

        fieldMappingData.fieldMappingDataUnitMap = fieldMappingDataUnitMap;

        return fieldMappingData;
    }

    public class FieldMappingData{

        public Set<String> sourceFieldSet;
        public Set<String> destinationFieldSet; 
        public Map<String,FieldMappingDataUnit> fieldMappingDataUnitMap;

        public FieldMappingData(){
            fieldMappingDataUnitMap = new Map<String,FieldMappingDataUnit>();
            sourceFieldSet = new Set<String>();
            destinationFieldSet = new Set<String>();
        }

        public FieldMappingData mergeFieldMappingData(FieldMappingData fieldMappingData){
            sourceFieldSet.addAll(fieldMappingData.sourceFieldSet);
            fieldMappingDataUnitMap.putAll(fieldMappingData.fieldMappingDataUnitMap);
            return this;
        }

        public void populateValuesFromSObject(SObject sourceRecord){
            for (FieldMappingDataUnit fieldMappingDataUnit_i : fieldMappingDataUnitMap.values()) {
                fieldMappingDataUnit_i.setValue(sourceRecord);
            }
        }

        /** 
        * @author Itzik Winograd
        * @date 28/02/2021
        * @description Provides a query of all the fields in the sourceFieldSet. returns a query with SELECT..FROM, without "WHERE"
        * @param String objectName - the object name to query from.
        * @param String  additionalFields - more fields to query
        * @return String query.
        */    
        public Sobject populateValuesAndReturnSObject(SObject sourceRecord, SObject toSObject){
            populateValuesFromSObject(sourceRecord);
            SObject prototypeChild = Schema.getGlobalDescribe().get(String.valueOf(toSObject.getSObjectType())).newSObject();
            Object obj;
            for(String destinationField : fieldMappingDataUnitMap.keySet()){ //loop over all the destination-field values
                obj = fieldMappingDataUnitMap.get(destinationField).getValue(); 
                prototypeChild.put(destinationField, obj); //put in the prototypeChild a value from the parent
                //System.debug('### destinationField: ' + destinationField + ', value: ' + obj);
            }
            prototypeChild.put('Id', toSObject.get('Id'));
            System.debug('### populateValuesAndReturnSObject returned sobject: ' + prototypeChild);
            return prototypeChild;
        }
    	
        /** 
        * @author Itzik Winograd
        * @date 14/02/2021
        * @description Provides a query of all the fields in the sourceFieldSet. returns a query with SELECT..FROM, without "WHERE"
        * @param String objectName - the object name to query from.
        * @param String  additionalFields - more fields to query
        * @return String query.
        */    
        public String getRecordsFromSObject (String objectName, String additionalFields){
            String query = 'SELECT ';
            for (String field : sourceFieldSet){
                query += field+',';
            }
            query += additionalFields;
            query = query.removeEnd(',');
            query += ' FROM ' + objectName;
            return query;
        }

        /** 
        * @author Itzik Winograd
        * @date 28/02/2021
        * @description Provides a query of all the fields in the destinationFieldSet. returns a query with SELECT..FROM, without "WHERE"
        * @param String objectName - the object name to query from.
        * @param String  additionalFields - more fields to query
        * @return String query.
        */    
        public String getRecordsFromDestinationSObject (String objectName, String additionalFields){
            String query = 'SELECT ';
            for (String field : destinationFieldSet){
                query += field+',';
            }
            query += additionalFields;
            query = query.removeEnd(',');
            query += ' FROM ' + objectName;
            return query;
        }
    }

    public class FieldMappingDataUnit{
        private Object sObjectValue;
        private String castTo;
        private String destinationFieldText;
        private Long destinationFieldLong;
        private String sourceField;
        private String leftText;
        private String rightText;
        private Integer order;
        private FieldMappingDataUnit nextPart;
        private String fixedValue;

        public FieldMappingDataUnit(Fields_Mapping__mdt fieldMappingCMT){
            sourceField = fieldMappingCMT.Source_Field__c;
            destinationFieldText = fieldMappingCMT.Destination_Field__c;
            if (String.isNotBlank(fieldMappingCMT.Destination_Field__c) && fieldMappingCMT.Destination_Field__c.isNumeric()) {
                destinationFieldLong = Long.valueOf(fieldMappingCMT.Destination_Field__c);
            }
            leftText = fieldMappingCMT.Text_Before_Field__c;
            rightText = fieldMappingCMT.Text_After_Field__c;
            order = Integer.valueOf(fieldMappingCMT.Concatenate_Order__c);
            castTo = fieldMappingCMT.Cast_To__c;
            fixedValue = fieldMappingCMT.Fixed_Value__c;
        }

        public FieldMappingDataUnit(String destinationField, General_Configuration__mdt generalConfigCMT){
            destinationFieldText = destinationField;
            sObjectValue = generalConfigCMT.Text_Value__c;
            if (generalConfigCMT.Number_Value__c != null) {
                sObjectValue = generalConfigCMT.Number_Value__c;
            }
        }

        public void setNextPart(FieldMappingDataUnit fieldMappingDataUnit){
            if (nextPart == null) {
                nextPart = fieldMappingDataUnit;
            } else {
                nextPart.setNextPart(fieldMappingDataUnit);
            }
        }

        public void setValue(SObject sourceRecord){
            if(String.isNotBlank(sourceField)){
                List<String> splitString = sourceField.split('\\.');
                SObject currentObject = sourceRecord;
                for(Integer i=0; i<splitString.size();i++){
                    if (currentObject == null) {
                        break;
                    }
                    if(i+1 == splitString.size()){
                        this.sObjectValue = currentObject.get(splitString[i]);
                    } else {
                        currentObject = currentObject.getSObject(splitString[i]);
                    }
                }
                if (nextPart != null) {
                    nextPart.setValue(sourceRecord);
                }

            }
        }

        public Object getDestinationField(){
            Object destinationField = destinationFieldText;
            if (destinationFieldLong != null) {
                destinationField = destinationFieldLong;
            }
            return destinationField;
        }

        public Object getValue(){
            Object value = sObjectValue;
            String textValue = '';

            if(String.isBlank(fixedValue)){
                if(value != null) {
                    if (castTo=='String'){
                        if (value instanceOf Date) {
                            value = ((Datetime)value).format(dateFormat);
                        } else if (value instanceOf Decimal) {
                            value = ((Decimal)value).format();
                        } else {
                            value = JSON.serialize(value).removeEnd('"').removeStart('"');
                        }
                    } else if (castTo=='Datetime') {
                        value = (Datetime)value;
                    } else if (castTo=='Integer'){
                        value = ((Decimal)value).intValue();
                    } else if(castTo=='Date') {
                        value = value instanceOf Datetime ? ((Datetime)value).date(): (Date)value;
                    } else if(castTo=='Id'){
                        value = (Id)value;
                    } else if(castTo=='Boolean'){
                        value = (Boolean)value;
                    } else if(castTo=='Decimal'){
                        value = (Decimal)value;
                    } else if(castTo=='Double'){
                        value = (Double)value;
                    } else if(castTo=='Long'){
                        value = (Long)value;
                    }
                }
                if (String.isNotBlank(leftText) || String.isNotBlank(rightText)) {
                    leftText = String.isBlank(leftText) ? '' : leftText.unescapeJava() + ' ';
                    rightText = String.isBlank(rightText) ? '' : ' ' + rightText.unescapeJava();
                    textValue=leftText + value + rightText;
                }
            } else {
                textValue = fixedValue;
            }
            if (nextPart != null) {
                textValue+=' ' + nextPart.getValue();
            }
            if (String.isNotBlank(textValue)) {
                value = textValue;
            }
            System.debug('value----'+value);
            return value;
        }
    }
}
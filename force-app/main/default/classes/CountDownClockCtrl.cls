/**
 * Created by Alon.Shalev on 10/8/2024.
 */

public with sharing class CountDownClockCtrl {

    @AuraEnabled
    public static Map<String, Object> getMQLInfoFromApex(String objectType,String recordId) {
        Map<String, Decimal> mqlMap = new Map<String, Decimal>();
        List<General_Key_Value_pair__mdt> settings = [SELECT Id,Key__c,Value__c FROM General_Key_Value_pair__mdt WHERE ProcessName__c = 'CountDownClock'];
        for(General_Key_Value_pair__mdt setting : settings){
            mqlMap.put(setting.Key__c,Decimal.valueOf(setting.Value__c));
        }
        String query = 'SELECT SW_Fit_Score__c,BI_Data__r.Intent_Score__c,SLA_Start_Timestamp__c,mql_status__c';
        query += objectType == 'Lead' ? ' FROM Lead' : ' FROM Contact';
        query += ' WHERE Id = : recordId LIMIT 1';
        SObject record = Database.query(query);
        Map<String,object> resultMap = new Map<String, Object>();
        resultMap.put('mqlMap',mqlMap);
        resultMap.put('SobjectInfo',record);
        return resultMap;
    }

}
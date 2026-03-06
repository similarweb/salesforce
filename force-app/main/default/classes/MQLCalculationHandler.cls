/**
* @author Itzik Winograd
* @date 13/07/2021
* @description Hadnles MQL Calculateion for Leads and Contacts.
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 18/08/2021
* description - Add assignment to the First_MQL_Date__c and MQL_date__c. Method: assignMQLDates.
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 29/08/2021
* description - In ordre to easly debug the MQL calculation process, logs creation was added.
*               Logs will be created with depend on the value in the custom metadata "Create_MQL_Logs" for true/false.
*               The process will create Apex_Event_Log__c records with the calculation considerations.
* --------------------------------------------------------------------------------------
*/
public class MQLCalculationHandler {

    private List<Log_Event__e> logEventList = new List<Log_Event__e>();
    Boolean createLogs = GeneralUtil.getGeneralConfig('Create_MQL_Logs').Text_Value__c == 'true' ? true : false;

    /**
    * @author Itzik Winograd
    * @date 01/07/2021
    * @description: Handle MQL Calculation
    * @param List<SObject> newList
    * @param Map<Id,SObject> oldMap
    * @return void.
    */
    public void handle (List<SObject> newList, Map<Id,SObject> oldMap){
        filterAndSetMQL(newList, oldMap);
    }

    /**
    * @author Itzik Winograd
    * @date 01/07/2021
    * @description: Filters the recrods and sent to MQL calculation. save the current MQL calc to make sure if it has been changed.
    * @param List<SObject> newList
    * @param Map<Id,SObject> oldMap
    * @return void
    */
    public void filterAndSetMQL (List<SObject> newList, Map<Id,SObject> oldMap){
        String objectName = '';
        SObject oldSObject;
        Boolean currentMql = false;
        for (SObject sobj : newList){ 
            currentMql = (Boolean)sobj.get('MQL__c');
            oldSObject = oldMap != null ? oldMap.get((Id)sobj.get('Id')) : null;
            objectName = GeneralUtil.getObjectNameFromSObject(sobj);
            System.debug('### objectName: ' + objectName);
            if(objectName == 'lead'){
                sobj.put('MQL__c', filterAndSetLead(sobj, oldSObject));
            } else if(objectName == 'contact'){
                sobj.put('MQL__c', filterAndSetContact(sobj, oldSObject));
            }
            assignMQLDates(sobj, currentMql);
        }
        if(createLogs && !logEventList.isEmpty()){
            Eventbus.publish(logEventList);
        }
    }
    /**
    * @author Itzik Winograd
    * @date 25/08/2021
    * @description: Assign values to the MQL_date__c and First_MQL_Date__c.
    *               MQL_date__c - will get value when the value has changed and currently is true
    *               First_MQL_Date__c - when MQL is true and First_MQL_Date__c is null.
    * @param SObject sobj to update
    * @param Boolean currentMql
    * @return SObject update sobject
    */
    public static SObject assignMQLDates(SObject sobj, Boolean currentMqlValue) {
        Boolean newMQLValue = (Boolean)sobj.get('MQL__c');
        if(newMQLValue == true){
            if(currentMqlValue != newMQLValue){ //MQL__c was changed
                sobj.put('MQL_date__c', Datetime.now());
            }
//            if(sobj.get('First_MQL_Date__c') == null){//this is the first MQL__c calculation
//                sobj.put('First_MQL_Date__c', Datetime.now());
//            }
        }
        return sobj;
    }

    /**
    * @author Itzik Winograd
    * @date 13/07/2021
    * @description: Filter leads: is changed company, status, fitscore, HasOptedOutOfEmail 
    * @param SObject newSObject
    * @param SObject oldSObject
    * @return List<SObject> filteredList
    */
    public Boolean filterAndSetLead (SObject newSObject, SObject oldSObject){
        Boolean result = false;
        String fitScore = (String)newSObject.get('SW_Fit_Score__c');
        Decimal behavioralRate = (Decimal)newSObject.get('SW_Behavioral_Rate__c');
        if(newSObject.get('status') == 'Unqualified' || 
          newSObject.get('HasOptedOutOfEmail') == true || 
          (newSObject.get('company')!=null &&
          !isCompanyValueValid(((String)newSObject.get('company')).toLowerCase()))){
            result = false;
            logEventList.add(createMQLLogRecord(newSObject,'MQL = false. \nReason: Lead Unqualified / HasOptedOutOfEmail / invalid company', null, null));
        } else if(oldSObject!=null){ //its an update
            boolean hasChanged = false;
            List<String> changedFieldsList = new List<String>{'status' , 'HasOptedOutOfEmail', 'SW_Fit_Score__c', 'company','MQL__c'};
            for (String fieldName : changedFieldsList){ 
                if (checkIsFieldsChanged(newSObject,oldSObject, fieldName)){ //check if this field has changed
                    result = calculateMQL(behavioralRate, fitScore);
                    String currentValue = String.valueOf(newSObject.get(fieldName));
                    String oldValue = String.valueOf(oldSObject.get(fieldName));
                    logEventList.add(createMQLLogRecord(newSObject,
                        'MQL = '+result+'. \nReason: '+fieldName+' on the Lead has changed from '+ oldValue +' to ' +currentValue+'.', 
                        fitScore, behavioralRate));
                    hasChanged = true;
                }
            }
            if (!hasChanged) { 
                result = mqlUnchanged(newSObject,behavioralRate, fitScore);
            }
        } else if (oldSObject==null){//its an insert
            result = calculateMQL(behavioralRate, fitScore);
            //logEventList.add(createMQLLogRecord(newSObject,'MQL = '+result+'. \nReason: Lead insert.', fitScore, behavioralRate));//No logs needed on insert - there is no record Id

        } else { //do not change the value
            result = mqlUnchanged(newSObject,behavioralRate, fitScore);
        }
        return result;
    }
    /**
    * @author Itzik Winograd
    * @date 29/08/2021
    * @description set the value of MQL to be the MQL itself. Also create a log for unchanged mql.
    * @param SObject sobj
    * @param Decimal behavioralRate
    * @param String fitScore 
    * @return Boolean the MQL value.
    */
    public Boolean mqlUnchanged(SObject newSObject, Decimal behavioralRate, String fitScore){
        Boolean result =  (Boolean)newSObject.get('MQL__c');
        logEventList.add(createMQLLogRecord(newSObject,'MQL = '+result+'. \nReason: MQL unchanged.', fitScore, behavioralRate));
        //return calculateMQL(behavioralRate, fitScore);
        return result;
    }
    /**
    * @author Itzik Winograd
    * @date 13/07/2021
    * @description: Check if the value under the received fieldName is changed.
    * @param SObject newSObject
    * @param SObject oldSObject
    * @param String fieldName - the fieldName to comapare
    * @return Boolean is this field's value has changed
    */
    public Boolean checkIsFieldsChanged (SObject newSObject, SObject oldSObject, String fieldName){
        Boolean result = false;
        result = newSObject.get(fieldName) != oldSObject.get(fieldName);
        System.debug('### MQL check if the Fields ' + fieldName + ' has changed.\n' +
            'Current value = ' + newSObject.get(fieldName) + '\n' + 
            'Old Value = ' + oldSObject.get(fieldName) + '\n' + 
            'So checkIsFieldsChanged is: ' + result);
        return result;
    }

    /**
    * @author Itzik Winograd
    * @date 13/07/2021
    * @description: Make sure company value is different from no/no_company/similarweb/[[Unknown]]
    * @param String companyValue 
    * @return Boolean true if the companyValue does not exist in the forbidden list
    */
    public Boolean isCompanyValueValid (String companyValue){
        Set<String> forbiddenCountriesSet = new Set<String> {
            '[[Unknown]]','similarweb','no_company','no'
        };
        Boolean result = !forbiddenCountriesSet.contains(companyValue);
        return result;
    }



    /**
    * @author Itzik Winograd
    * @date 13/07/2021
    * @description: Filter contacts: is changed accountId, status__c, fitscore, hasoptOut
    * @param SObject newSObject
    * @param SObject oldSObject
    * @return Boolean should this record be calculated
    */
    public Boolean filterAndSetContact (SObject newSObject, SObject oldSObject){
        Boolean result = false;
        String fitScore = (String)newSObject.get('SW_Fit_Score__c');
        Decimal behavioralRate = (Decimal)newSObject.get('SW_Behavioral_Rate__c');
        if(newSObject.get('status__c') == 'Unqualified' || 
          newSObject.get('HasOptedOutOfEmail') == true){
            result = false;
            logEventList.add(createMQLLogRecord(newSObject,'MQL = false. \nReason: Contact Unqualified / HasOptedOutOfEmail', null, null));
        } else if(oldSObject!=null){ //its an update
            Boolean hasChanged = false;
            List<String> changedFieldsList = new List<String>{'status__c' , 'HasOptedOutOfEmail', 'SW_Fit_Score__c', 'accountId','MQL__c'};
            for (String fieldName : changedFieldsList){ 
                if (checkIsFieldsChanged(newSObject,oldSObject, fieldName)){ //check if this field has changed
                    result = calculateMQL(behavioralRate, fitScore);
                    String currentValue = String.valueOf(newSObject.get(fieldName));
                    String oldValue = String.valueOf(oldSObject.get(fieldName));
                    logEventList.add(createMQLLogRecord(newSObject,
                        'MQL = '+result+'. \nReason: '+fieldName+' on the Contact has changed from '+ oldValue +' to ' +currentValue+'.', 
                        fitScore, behavioralRate));
                    hasChanged = true;
                }
            }
            if (!hasChanged) { 
                result = mqlUnchanged(newSObject,behavioralRate, fitScore);
            }
        } else if (oldSObject==null){//its an insert
            result = calculateMQL(behavioralRate, fitScore);
            //logEventList.add(createMQLLogRecord(newSObject,'MQL = '+result+'. \nReason: Contact insert.', fitScore, behavioralRate));//No logs needed on insert - there is no record Id
        } else { //do not change the value
            result = mqlUnchanged(newSObject,behavioralRate, fitScore);
        }
        return result;
    }

    /**
    * @author Itzik Winograd
    * @date 01/07/2021
    * @description: Calculate the MQL: 
    *               br=1 and fs=A/B/C
    *               br=2 and fs=A/B/C
    *               br=3 and fs=A
    * @param Decimal behavioralRate = can be 1/2/3
    * @param String fitScore 
    * @return Boolean
    * ==============
    * Date: 28/12/2021
    * author: Itzik Winograd
    * Description: MIS-1692: add B3, D1 to MQL=TRUE, so new mapping is:
    *               br=1 and fs=A/B/C/D
    *               br=2 and fs=A/B/C
    *               br=3 and fs=A/B
    */
    public static Boolean calculateMQL (Decimal behavioralRate, String fitScore){
        if (
            (behavioralRate == 1 
            && (fitScore == 'A' || fitScore == 'B' || fitScore == 'C' || fitScore == 'D'))
            ||
            (behavioralRate == 2 
                && (fitScore == 'A' || fitScore == 'B' || fitScore == 'C'))
            ||
            (behavioralRate == 3 
            && (fitScore == 'A' || fitScore == 'B' ))
            )
        {
            return true;
        } else {
            return false;
        }
    }

    /**
    * @author Itzik Winograd
    * @date 29/08/2021
    * @description add a log recrod to the logs list.
    * @param SObject sobj.
    * @param String logMessage: the message to log in the detail section.  
    * @param  String fitScore
    * @param Decimal behavioralRate
    * @return Void.
    */
    public static Log_Event__e createMQLLogRecord(SObject sobj, String logMessage,  String fitScore, Decimal behavioralRate){
        return
            LogEventUtils.createLogEventRecord(new List<Sobject>{sobj}, 'MQLCalculationHandler', 'filterAndSetMQL', 
            logMessage + '\nSW_Fit_Score__c = ' + fitScore +' \n'+'SW_Behavioral_Rate__c = ' + Integer.valueOf(behavioralRate),
            null, 'info',null,null);
    
    } 

    
}
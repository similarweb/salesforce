public class InferredSolutionHandler {
    
    private Boolean isUpdateValid = true;
    private String sObjtype;
    
    public InferredSolutionHandler(String sObjtype){
        this.sObjtype = sObjtype;
    }
    
    public void setInferredSolution(List<sObject> newList,  Map<Id, sObject> oldMap) {
        System.debug(sObjtype);
         System.debug(newList);
         System.debug(oldMap);
        if(sObjtype == 'Lead'){
            Set<String> invalidColumnsList = new Set<String>();
            for(Inferral_Solution_Valid_Criteria_List__c isvc_i: [SELECT Name FROM Inferral_Solution_Valid_Criteria_List__c WHERE Is_Valid__c=false]){
                invalidColumnsList.add(isvc_i.Name);
            }
            Set<String> schemaFieldList = Schema.SObjectType.InferralSolutionMap__c.fields.getMap().keySet();
            Set<String> leadFieldList = Schema.SObjectType.Lead.fields.getMap().keySet();
            for(String schemaField : schemaFieldList){
                if(!schemaField.endsWith('__c') || invalidColumnsList.contains(schemaField) || schemaField == 'Inferred_Solution__c'){
                    schemaFieldList.remove(schemaField);
                }
            }
            Map<String,InferralSolutionMap__c> inferralSolutionMap = InferralSolutionMap__c.getAll();        
            if(oldMap == null){
                for(sObject sObj_i : newList){
                    String keyName='';
                    for(String schemaField : schemaFieldList){ 
                        if(!leadFieldList.contains(schemaField))
                            schemaField = schemaField.removeEnd('__c');
                        // New
                        String sObjValue = (sObj_i.get(schemaField) == null || sObj_i.get(schemaField) == 'NULL') ? 'NULL' : (String)sObj_i.get(schemaField);
                        // Old
                        // String sObjValue = sObj_i.get(schemaField) == null ? 'NULL' : (String)sObj_i.get(schemaField);
                        keyName+= sObjValue + ' + ';   
                    }
                    keyName = keyName.removeEnd(' + ');
                    System.debug('keyName - ' + keyName);
                    String index = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',Blob.valueOf(keyName)));
                    if(inferralSolutionMap.containsKey(index)){                 
                        sObj_i.put('Inferred_Solution__c', inferralSolutionMap.get(index).Inferred_Solution__c);
                    }  else {
                        Boolean valueFound = false;
                        for(InferralSolutionMap__c ism_i : inferralSolutionMap.values()){
                            Boolean ch = false;
                            for(String schemaField : schemaFieldList){                                
                                if(ism_i.get(schemaField) != 'NULL' && ism_i.get(schemaField) != sObj_i.get(schemaField)){
                                    ch = true;
                                    break;
                                }
                            }
                            if(ch){
                                continue;
                            } else {
                                sObj_i.put('Inferred_Solution__c', ism_i.Inferred_Solution__c);
                                valueFound = true;
                                break;
                            }
                        }
                        if(!valueFound){
                            sObj_i.put('Inferred_Solution__c', Inferral_Solution_Settings__c.getValues('Default Value').Value__c);
                        }
                    }
                }
            } else {
                for(sObject sObj_i : newList){
                    sObject oldObject = (sObject)oldMap.get(sObj_i.Id);
                    String keyName='';
                    Boolean isUpdated = false;
                    for(String schemaField : schemaFieldList){
                        if(!leadFieldList.contains(schemaField))
                            schemaField = schemaField.removeEnd('__c');
                        if(sObj_i.get(schemaField) != oldObject.get(schemaField))
                            isUpdated=true;
                        System.debug('keyName - ' + keyName);
                        // New
                        String sObjValue = (sObj_i.get(schemaField) == null || sObj_i.get(schemaField) == 'NULL') ? 'NULL' : (String)sObj_i.get(schemaField);
                        // Old
                        // String sObjValue = sObj_i.get(schemaField) == null ? 'NULL' : (String)sObj_i.get(schemaField);
                        keyName+= sObjValue + ' + ';        
                    }
                    if(isUpdated){
                        keyName = keyName.removeEnd(' + ');
                        System.debug('keyName - ' + keyName);
                        String index = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',Blob.valueOf(keyName)));
                        if(inferralSolutionMap.containsKey(index)){  
                            sObj_i.put('Inferred_Solution__c', inferralSolutionMap.get(index).Inferred_Solution__c);
                        } else {
                            Boolean valueFound = false;
                            for(InferralSolutionMap__c ism_i : inferralSolutionMap.values()){
                                Boolean ch = false;
                                for(String schemaField : schemaFieldList){
                                    if(!leadFieldList.contains(schemaField))
                                        schemaField = schemaField.removeEnd('__c');
                                    if(ism_i.get(schemaField) != 'NULL' && ism_i.get(schemaField) != sObj_i.get(schemaField)){
                                        ch = true;
                                        break;
                                    }
                                }
                                if(ch){
                                    continue;
                                } else {
                                    sObj_i.put('Inferred_Solution__c', ism_i.Inferred_Solution__c);
                                    valueFound = true;
                                    break;
                                }
                            }
                            if(!valueFound){
                                sObj_i.put('Inferred_Solution__c', Inferral_Solution_Settings__c.getValues('Default Value').Value__c);
                            }
                        }
                    }
                }             
            } 
        } else if(sObjtype == 'Contact'){
            System.debug('INIT');
            Set<String> invalidColumnsList = new Set<String>();
            for(InferralSolutionCValidCriteriaList__c isvc_i: [SELECT Name FROM InferralSolutionCValidCriteriaList__c WHERE Is_Valid__c=false]){
                invalidColumnsList.add(isvc_i.Name);
            }
            Set<String> schemaFieldList = Schema.SObjectType.InferralSolutionMapContact__c.fields.getMap().keySet();
            Set<String> contactFieldList = Schema.SObjectType.Contact.fields.getMap().keySet();
            for(String schemaField : schemaFieldList){
                if(!schemaField.endsWith('__c') || invalidColumnsList.contains(schemaField) || schemaField == 'Inferred_Solution__c'){
                    schemaFieldList.remove(schemaField);
                }
            }         
            Map<String,InferralSolutionMapContact__c> inferralSolutionMap = InferralSolutionMapContact__c.getAll();        
            if(oldMap == null){     
                for(sObject sObj_i : newList){
                    String keyName='';
                    for(String schemaField : schemaFieldList){
                        if(!contactFieldList.contains(schemaField))
                            schemaField = schemaField.removeEnd('__c');
                        // New
                        String sObjValue = (sObj_i.get(schemaField) == null || sObj_i.get(schemaField) == 'NULL') ? 'NULL' : (String)sObj_i.get(schemaField);
                        // Old
                        // String sObjValue = sObj_i.get(schemaField) == null ? 'NULL' : (String)sObj_i.get(schemaField);
                        keyName+= sObjValue + ' + ';   
                    }
                    keyName = keyName.removeEnd(' + ');
                    System.debug('keyNameSS - ' + keyName);
                    String index = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',Blob.valueOf(keyName)));
                    System.debug('inferralSolutionMap.containsKey(index) - ' + inferralSolutionMap.containsKey(index));
                    if(inferralSolutionMap.containsKey(index)){                 
                        sObj_i.put('Inferred_Solution__c', inferralSolutionMap.get(index).Inferred_Solution__c);
                    } else {
                        Boolean valueFound = false;
                        for(InferralSolutionMapContact__c ism_i : inferralSolutionMap.values()){
                            Boolean ch = false;
                            for(String schemaField : schemaFieldList){                                
                                if(ism_i.get(schemaField) != 'NULL' && ism_i.get(schemaField) != sObj_i.get(schemaField)){
                                    ch = true;
                                    break;
                                }
                            }
                            if(ch){
                                continue;
                            } else {
                                sObj_i.put('Inferred_Solution__c', ism_i.Inferred_Solution__c);
                                valueFound = true;
                                break;
                            }
                        }
                        if(!valueFound){
                            sObj_i.put('Inferred_Solution__c', Inferral_Solution_Settings__c.getValues('Default Value').Value__c);
                        }
                    }
                }
            } else {
                for(sObject sObj_i : newList){
                    sObject oldObject = (sObject)oldMap.get(sObj_i.Id);
                    String keyName='';
                    Boolean isUpdated = false;
                    for(String schemaField : schemaFieldList){
                        if(!contactFieldList.contains(schemaField))
                            schemaField = schemaField.removeEnd('__c');
                        System.debug('schemaField '+schemaField);
                        if(sObj_i.get(schemaField) != oldObject.get(schemaField) || schemaField.equalsIgnoreCase('SW_Industry__c'))
                            isUpdated=true;
                        System.debug('keyName - ' + keyName);
                        // New
                        String sObjValue = (sObj_i.get(schemaField) == null || sObj_i.get(schemaField) == 'NULL') ? 'NULL' : (String)sObj_i.get(schemaField);
                        // Old
                        // String sObjValue = sObj_i.get(schemaField) == null ? 'NULL' : (String)sObj_i.get(schemaField);
                        keyName+= sObjValue + ' + ';        
                    }
                    if(isUpdated){
                        keyName = keyName.removeEnd(' + ');
                        System.debug('keyName - ' + keyName);
                        String index = EncodingUtil.convertToHex(Crypto.generateDigest('MD5',Blob.valueOf(keyName)));
                        if(inferralSolutionMap.containsKey(index)){                 
                            sObj_i.put('Inferred_Solution__c', inferralSolutionMap.get(index).Inferred_Solution__c);
                        } else {
                            Boolean valueFound = false;
                            for(InferralSolutionMapContact__c ism_i : inferralSolutionMap.values()){
                                Boolean ch = false;
                                for(String schemaField : schemaFieldList){
                                    if(!contactFieldList.contains(schemaField))
                                        schemaField = schemaField.removeEnd('__c');
                                    if(ism_i.get(schemaField) != 'NULL' && ism_i.get(schemaField) != sObj_i.get(schemaField)){
                                        ch = true;
                                        break;
                                    }
                                }
                                if(ch){
                                    continue;
                                } else {
                                    sObj_i.put('Inferred_Solution__c', ism_i.Inferred_Solution__c);
                                    valueFound = true;
                                    break;
                                }
                            }
                            if(!valueFound){
                                sObj_i.put('Inferred_Solution__c', Inferral_Solution_Settings__c.getValues('Default Value').Value__c);
                            }
                        }
                    }
                }             
            } 
        }
    }
}
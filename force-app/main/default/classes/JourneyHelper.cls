public class JourneyHelper {
    private static final String WEBSITE_STEP = 'Website';
    private static final String PARDOT_STEP = 'Pardot';
    private static final String SFCD_STEP = 'Salesforce Created';
    private static final String JOURNEY_DECISION_STEP = 'Journey Decision';
    private static final String POLYGRAPH_STEP = 'Polygraph';
    private static final String DATA_FOX_STEP = 'Datafox';
    private static final String CLEARBIT_STEP = 'Clearbit';
    //private static final String ENRICHMENT_STEP = 'Enrichment';
    private static final String FIT_SCORE_STEP = 'Fit Score';
    private static final String BEHAVIORAL_RATE_STEP = 'Behavioral Rate';
    private static final String BUSINESS_UNIT_STEP = 'Business Unit';
    private static final String MQL_STEP = 'MQL';
    //private static final String LDR_DECISION_STEP = 'LDR Decision';
    private static final String ROUTING_STEP = 'Routing';
    private static final String COMPLETED_JOURNEY_STEP = 'Completed Journey';
    private static final String leadQuery = 'SELECT Id,CreatedDate,Name,Email,Journey_Completed_Timestamp__c,LeanData__Reporting_Timestamp__c,Sent_to_Polygraph__c,Clearbit_Timestamp__c,LD_Update_DateTime__c,LeanData__Routing_Action__c,LeanData__Routing_Status__c,Polygraph_Update_Timestamp__c,SW_Fit_Score_Timestamp__c,First_Behavioral_Rate_Timestamp__c,Business_unit_timestamp__c,First_MQL_Calc__c FROM Lead WHERE ';
    
    private static Map<String,List<Journey_Path_Setting__c>> settingMap;
    private static Map<String,String> stepSettingMap;

    static{
        settingMap = new Map<String,List<Journey_Path_Setting__c>>();
        stepSettingMap = new Map<String,String>();
    }

    public static String getQuery(String journeyName){
        List<Journey_Path_Setting__c> pathSettingList = getSettings(journeyName);
        String query = leadQuery;
        List<String> criteriaList = new List<String>();
        if(!pathSettingList.isEmpty()){
            Journey_Path_Setting__c previousStep;
            for(Journey_Path_Setting__c setting_i : pathSettingList){
                //String criteria = generateCriteria(setting_i.Step_Name__c);
                String sN = previousStep == null ? null : previousStep.Step_Name__c;
                String criteria = generateCriteriaPath(setting_i.Step_Name__c,sN);
                if(String.isNotBlank(criteria)){
                    criteriaList.add(criteria);
                }
                previousStep = setting_i;
            }
            if(!criteriaList.isEmpty()){
                query += '(' + String.join(criteriaList, ' OR ') + ') AND ';
            }
        }
        query += ' CreatedDate >= :fixedDate AND isConverted = false AND Exclude_from_Funnel_Journey__c = false AND Orchestration_Journey__c=:journeyName AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('merged')+ '\' AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('merged - master')+ '\'AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('merged - update')+ '\'AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('error')+ '\'AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('not processed')+ '\'  LIMIT 10000';
        System.debug('query ' + query);
        return query;
    }

    private static List<Journey_Path_Setting__c> getSettings(String journeyName){
        if(!settingMap.containsKey(journeyName)){
            settingMap.put(journeyName,[SELECT Id,Name,Journey_Name__c,Step_Name__c,Step_Order__c,Step_SLA__c FROM Journey_Path_Setting__c WHERE Journey_Name__c = :journeyName AND Active__c = true ORDER BY Step_Order__c ASC]);
        }
        return settingMap.get(journeyName);
    }
    
    public static List<Journey_Path_Setting__c> getJourneyPathSettings(String journeyName){
        List<Journey_Path_Setting__c> jps = [SELECT Id,Name,Journey_Name__c,Step_Name__c,Step_Order__c,Active__c,Step_SLA__c FROM Journey_Path_Setting__c WHERE Journey_Name__c = :journeyName];        
        return jps;
    }
    
    public static Map<String,String> getStepSettingMap(){
        if(stepSettingMap.isEmpty()){
            List<Journey_Step_Setting__c> stepSettings = [SELECT Name,TimeStampName__c FROM Journey_Step_Setting__c];            
            for(Journey_Step_Setting__c jss : stepSettings){
                stepSettingMap.put(jss.Name,jss.TimeStampName__c);
            }
        }
        return stepSettingMap;
    }

    private static Map<String,Journey_Path_Setting__c> getStepMap(String journeyName){
        Map<String,Journey_Path_Setting__c> stepMap = new Map<String,Journey_Path_Setting__c>();
        List<Journey_Path_Setting__c> pathSettingList = getSettings(journeyName);
        for(Journey_Path_Setting__c setting_i : pathSettingList){
            stepMap.put(setting_i.Step_Name__c,setting_i);
        }
        return stepMap;
    }

    public static String getStepQuery(String journeyName,String stepName){
        Map<String,Journey_Path_Setting__c> stepMap = getStepMap(journeyName);
        String query = leadQuery;
        List<String> criteriaList = new List<String>();
        System.debug('stepName ' + stepName);
        String previousStep;
        if(stepName != null && stepName!=COMPLETED_JOURNEY_STEP){
            for(String step: stepMap.keySet()){    
                System.debug('previousStep ' + previousStep);
                String criteria = generateCriteriaStep(step,stepName,previousStep);  
                previousStep = step;
                
                if(String.isNotBlank(criteria)){
                    criteriaList.add(criteria);
                }            
                if(step == stepName){
                    break;
                }            
            }
            if(!criteriaList.isEmpty()){
                query += '(' + String.join(criteriaList, ' AND ') + ') AND ';
            }
        } else if(stepName==COMPLETED_JOURNEY_STEP){
            String criteria = generateCriteriaStep(stepName,stepName,previousStep);
            
            if(String.isNotBlank(criteria)){
                 query += '(' + criteria + ') AND ';
            }
        }
        query += ' CreatedDate >= :fixedDate AND isConverted = false AND Exclude_from_Funnel_Journey__c = false AND Orchestration_Journey__c=:journeyName AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('merged')+ '\' AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('merged - master')+ '\'AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('merged - update')+ '\'AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('error')+ '\'AND LeanData__Routing_Status__c!=\''+String.escapeSingleQuotes('not processed')+ '\'  LIMIT 10000';
        return query;
    }

    /*private static String generateCriteria(String stepName){
        String criteria = '';
        if(stepName == POLYGRAPH_STEP){
            criteria = 'Polygraph_Update_Timestamp__c = null';
        }/*else if(stepName == ENRICHMENT_STEP){
            criteria = '(Enrichment_Test_Timestamp__c = null)';
        }else if(stepName == FIT_SCORE_STEP){
            criteria = '(Enrichment_Test_Timestamp__c != null AND SW_Fit_Score_Timestamp__c = null)';
        }else if(stepName == BEHAVIORAL_RATE_STEP){
            criteria = '(SW_Fit_Score_Timestamp__c != null AND First_Behavioral_Rate_Timestamp__c = null)';
        }else if(stepName == BUSINESS_UNIT_STEP){
            criteria = '(First_Behavioral_Rate_Timestamp__c != null AND Business_unit_timestamp__c = null)';
        }else if(stepName == MQL_STEP){
            criteria = '(Business_unit_timestamp__c != null AND First_MQL_Calc__c = null)';
        }else if(stepName == COMPLETED_JOURNEY_STEP){
            criteria = '(LeanData__Reporting_Timestamp__c != null AND LeanData__Routing_Status__c != null)';
        } else if(stepName == ROUTING_STEP){
            criteria = '(First_MQL_Calc__c != null AND LeanData__Reporting_Timestamp__c = null)';
        }
        
      
        return criteria;
    }*/
    
    private static String generateCriteriaPath(String stepName, String peviousStepName){
        String criteria = '';
        System.debug('stepname ' + stepName + 'previousStepName ' + peviousStepName);
        List<Journey_Step_Setting__c> stepSettings = [SELECT Name,TimeStampName__c FROM Journey_Step_Setting__c];
        Map<String,String> stepSettingsMap = new Map<String,String>();
        for(Journey_Step_Setting__c jss : stepSettings){
            stepSettingsMap.put(jss.Name,jss.TimeStampName__c);
        }
        
        if(peviousStepName == null){
            criteria = stepSettingsMap.get(stepName) + ' = null';
        } else if(stepName == COMPLETED_JOURNEY_STEP){
            criteria = '(LeanData__Routing_Action__c != null AND Journey_Completed_Timestamp__c > :d24hAgo AND ' + stepSettingsMap.get(stepName) + ' != null AND (LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('routed')+ '\' OR LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('routed - update')+ '\' OR LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('converted')+ '\' OR LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('converted - update')+ '\'))';
            System.debug('criteria Completed ' + criteria);
        } else if(stepName == ROUTING_STEP){
             criteria = '(' + stepSettingsMap.get(peviousStepName) + ' != null AND ' + stepSettingsMap.get(stepName) + ' = null)';
        } else {
            criteria = '(' + stepSettingsMap.get(peviousStepName) + ' != null AND ' + stepSettingsMap.get(stepName) + ' = null  AND Journey_Completed_Timestamp__c = null)';
        }
        System.debug('criteria ' + criteria);
        return criteria;
    }
    
    private static String generateCriteriaStep(String stepName, String currStepName, String previousStep){
        String criteria = '';
        List<Journey_Step_Setting__c> stepSettings = [SELECT Name,TimeStampName__c FROM Journey_Step_Setting__c];
        Map<String,String> stepSettingsMap = new Map<String,String>();
        for(Journey_Step_Setting__c jss : stepSettings){
            stepSettingsMap.put(jss.Name,jss.TimeStampName__c);
        }
        if(stepName == COMPLETED_JOURNEY_STEP){            
            criteria = '(' + stepSettingsMap.get(stepName) + ' != null AND LeanData__Routing_Action__c != null AND Journey_Completed_Timestamp__c > :d24hAgo AND ' + stepSettingsMap.get(stepName) + ' != null AND (LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('routed')+ '\' OR LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('routed - update')+ '\' OR LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('converted')+ '\' OR LeanData__Routing_Status__c=\''+String.escapeSingleQuotes('converted - update')+ '\'))';
        } else if(stepName == currStepName && !(stepName == COMPLETED_JOURNEY_STEP)){
            criteria = '(' + stepSettingsMap.get(stepName) + ' = null)';
        }  else{
			criteria = '(' + stepSettingsMap.get(stepName) + ' != null AND Journey_Completed_Timestamp__c = null)';          
        }
        
        return criteria;
    }
    
    public static Map<String,List<Lead>> getRecordsPerStep(String journeyName, String query){
        Map<String,List<Lead>> stepToLeadMap = new Map<String,List<Lead>>();
        DateTime d24hAgo = DateTime.now().addHours(-24);
        DateTime fixedDate = datetime.newInstance(2018, 12, 9);
        List<Journey_Path_Setting__c> pathSettingList = getSettings(journeyName);
        if(!pathSettingList.isEmpty()){
            for(Journey_Path_Setting__c setting_i : pathSettingList){
                stepToLeadMap.put(setting_i.Step_Name__c, new List<Lead>());
            }
            List<Lead> leadList = (List<Lead>)Database.query(query);
            for(Lead lead_i : leadList){
                /*if(lead_i.Polygraph_Update_Timestamp__c == null && stepToLeadMap.containsKey(POLYGRAPH_STEP)){
                    stepToLeadMap.get(POLYGRAPH_STEP).add(lead_i);
                }else if(lead_i.Enrichment_Test_Timestamp__c == null){
                    stepToLeadMap.get(ENRICHMENT_STEP).add(lead_i);
                }else if(lead_i.Enrichment_Test_Timestamp__c != null && lead_i.SW_Fit_Score_Timestamp__c == null){
                    stepToLeadMap.get(FIT_SCORE_STEP).add(lead_i);
                }else if(lead_i.SW_Fit_Score_Timestamp__c != null && lead_i.First_Behavioral_Rate_Timestamp__c == null && stepToLeadMap.containsKey(BEHAVIORAL_RATE_STEP)){
                    stepToLeadMap.get(BEHAVIORAL_RATE_STEP).add(lead_i);
                }else if(lead_i.First_Behavioral_Rate_Timestamp__c != null && lead_i.Business_unit_timestamp__c == null && stepToLeadMap.containsKey(BUSINESS_UNIT_STEP)){
                    stepToLeadMap.get(BUSINESS_UNIT_STEP).add(lead_i);
                }else if(lead_i.Business_unit_timestamp__c != null && lead_i.First_MQL_Calc__c == null && stepToLeadMap.containsKey(MQL_STEP)){
                    stepToLeadMap.get(MQL_STEP).add(lead_i);
                }else if(lead_i.First_MQL_Calc__c != null && lead_i.LD_Timestamp__c == null && stepToLeadMap.containsKey(LDR_DECISION_STEP)){
                    stepToLeadMap.get(LDR_DECISION_STEP).add(lead_i);
                }else if(lead_i.First_MQL_Calc__c != null && lead_i.LeanData__Reporting_Timestamp__c == null && stepToLeadMap.containsKey(ROUTING_STEP)){
                    stepToLeadMap.get(ROUTING_STEP).add(lead_i);
                }else if(lead_i.LeanData__Reporting_Timestamp__c != null && lead_i.LeanData__Routing_Status__c != null && stepToLeadMap.containsKey(COMPLETED_JOURNEY_STEP)){
                    stepToLeadMap.get(COMPLETED_JOURNEY_STEP).add(lead_i);
                }*/
                String previousStepName;
                for(String stepName : stepToLeadMap.keySet()){
                    
                    Boolean contains = isStepContainsLead(stepName,previousStepName,lead_i);
                    if(contains){
                        stepToLeadMap.get(stepName).add(lead_i);
                        break;
                    }
                    previousStepName = stepName;
                }
                    
            }
        }
        return stepToLeadMap;
    }
    
    public static Boolean isStepContainsLead(String stepName, String peviousStepName, Lead lead){
        Boolean contains;
        DateTime currentTimestamp;
        DateTime previousTimestamp; 
        if(stepName == WEBSITE_STEP || stepName == PARDOT_STEP || stepName == SFCD_STEP || stepName == JOURNEY_DECISION_STEP){
            contains = false;
        } else if(stepName == COMPLETED_JOURNEY_STEP){
            previousTimestamp = obtainTimestampFromStepName(peviousStepName, lead);
            contains = (peviousStepName != null && lead.LeanData__Routing_Action__c!= null) ? true : false;
        } else if(peviousStepName == null){            
            currentTimestamp = obtainTimestampFromStepName(stepName, lead);
            contains = currentTimestamp == null ? true : false;
            contains = lead.Journey_Completed_Timestamp__c == null ? contains : false;
        } else {
            previousTimestamp = obtainTimestampFromStepName(peviousStepName, lead);
            currentTimestamp = obtainTimestampFromStepName(stepName, lead);
            contains = (peviousStepName != null && currentTimestamp == null) ? true : false;
            contains = lead.Journey_Completed_Timestamp__c == null ? contains : false;
        }       
        return contains;
    }
    
    public static DateTime obtainTimestampFromStepName(String stepName, Lead lead){
        DateTime timestamp;        
        Map<String,String> stepMap = getStepSettingMap();
        /*       
        if(stepMap.get(stepName) == 'Polygraph_Update_Timestamp__c'){
            timestamp = lead.Polygraph_Update_Timestamp__c;
        } else if(stepMap.get(stepName) == 'Clearbit_Timestamp__c'){
            timestamp = lead.Clearbit_Timestamp__c;
        } else if(stepMap.get(stepName) == 'SW_Fit_Score_Timestamp__c'){
            timestamp = lead.SW_Fit_Score_Timestamp__c;
        } else if(stepMap.get(stepName) == 'First_Behavioral_Rate_Timestamp__c'){
            timestamp = lead.First_Behavioral_Rate_Timestamp__c;
        } else if(stepMap.get(stepName) == 'Business_unit_timestamp__c'){
            timestamp = lead.Business_unit_timestamp__c;
        } else if(stepMap.get(stepName) == 'First_MQL_Calc__c'){
            timestamp = lead.First_MQL_Calc__c;
        } else if(stepMap.get(stepName) == 'LeanData__Reporting_Timestamp__c'){
            timestamp = lead.LeanData__Reporting_Timestamp__c;
        } else if(stepMap.get(stepName) == 'LD_Update_DateTime__c'){
            timestamp = lead.LD_Update_DateTime__c;
        } else if(stepMap.get(stepName) == 'CreatedDate'){
            timestamp = lead.CreatedDate;
        }else if (stepMap.get(stepName) == 'Journey_Completed_Timestamp__c'){
            timestamp= lead.Journey_Completed_Timestamp__c;
        } */
		if(stepMap.get(stepName) != null){
            String fieldName = stepMap.get(stepName);
            System.debug('stepMap.get(stepName) '+ fieldName);
            timestamp = (Datetime) lead.get(fieldName);
        }       
        return timestamp;
    }
    
    public static Map<String,List<Lead>> getRecordsDone(String journeyName, String query){
        DateTime d24hAgo = DateTime.now().addHours(-24);
        DateTime fixedDate = datetime.newInstance(2018, 12, 9);
        Map<String,List<Lead>> stepToLeadMap = new Map<String,List<Lead>>();
        List<Journey_Path_Setting__c> pathSettingList = getSettings(journeyName);
        if(!pathSettingList.isEmpty()){
            for(Journey_Path_Setting__c setting_i : pathSettingList){
                stepToLeadMap.put(setting_i.Step_Name__c, new List<Lead>());
            }
            List<Lead> leadList = (List<Lead>)Database.query(query);
            for(Lead lead_i : leadList){
                /*if(lead_i.Polygraph_Update_Timestamp__c != null && stepToLeadMap.containsKey(POLYGRAPH_STEP)){
                    stepToLeadMap.get(POLYGRAPH_STEP).add(lead_i);
                }if(lead_i.First_Behavioral_Rate_Timestamp__c != null && stepToLeadMap.containsKey(BEHAVIORAL_RATE_STEP)){
                    stepToLeadMap.get(BEHAVIORAL_RATE_STEP).add(lead_i);
                } if(lead_i.Business_unit_timestamp__c != null && stepToLeadMap.containsKey(BUSINESS_UNIT_STEP)){
                    stepToLeadMap.get(BUSINESS_UNIT_STEP).add(lead_i);
                } if(lead_i.First_MQL_Calc__c != null && stepToLeadMap.containsKey(MQL_STEP)){
                    stepToLeadMap.get(MQL_STEP).add(lead_i);
                } if(lead_i.LD_Timestamp__c != null && stepToLeadMap.containsKey(LDR_DECISION_STEP)){
                    stepToLeadMap.get(LDR_DECISION_STEP).add(lead_i);
                } if(lead_i.SW_Fit_Score_Timestamp__c != null && stepToLeadMap.containsKey(FIT_SCORE_STEP)){
                    stepToLeadMap.get(FIT_SCORE_STEP).add(lead_i);
                } if(lead_i.LeanData__Reporting_Timestamp__c != null && stepToLeadMap.containsKey(ROUTING_STEP)){
                    stepToLeadMap.get(ROUTING_STEP).add(lead_i);
                }*/
                for(String stepName : stepToLeadMap.keySet()){
                    Boolean contains = isStepDone(stepName,lead_i);
                    if(contains){
                        stepToLeadMap.get(stepName).add(lead_i);
                    } else{
                        System.debug('stepName ' + stepName);
                        break;
                    }   
                }
            }
        }
        return stepToLeadMap;
    }
    
    public static Boolean isStepDone(String stepName, Lead lead){
        if(lead.Journey_Completed_Timestamp__c!= null && (lead.LeanData__Routing_Status__c=='routed'||lead.LeanData__Routing_Status__c=='routed - update'||lead.LeanData__Routing_Status__c=='converted' || lead.LeanData__Routing_Status__c=='converted - update'))
            return true;
        Boolean contains; 
        contains = obtainTimestampFromStepName(stepName, lead) != null ? true : false;                          
        return contains;
    }


    public static JourneyController.DetailedFunnelTable generateStepInfo(String journeyName,String stepName, String query,Boolean isReport){
        DateTime d24hAgo = DateTime.now().addHours(-24);
        DateTime fixedDate = datetime.newInstance(2018, 12, 9);
        List<Lead> leadList = (List<Lead>) Database.query(query);
        if(isReport)
        {
            List<Lead> tempLeadList = leadList;
            leadList = new List<Lead>();
            for(Lead lead : tempLeadList){
                Long differenceBetweenHours = (DateTime.now().getTime() - lead.Journey_Completed_Timestamp__c.getTime())/1000/60/60;
                if(differenceBetweenHours<3){
                   leadList.add(lead); 
                }
            }            
        }
        System.debug('journeyName ' + journeyName);
        System.debug('leadList ' + leadList);
        JourneyController.DetailedFunnelTable defailedTable = new JourneyController.DetailedFunnelTable(journeyName,stepName,leadList.size(),Datetime.now(),leadList);
        System.debug('defailedTable ' + defailedTable);
        return defailedTable;
    }
    
    public static JourneyController.Path generateGenericPath(Map<String,List<Lead>> stepToLeadMap, String journeyName,Map<String,Long> calculatedSLA){
        List<JourneyController.Step> stepList = new List<JourneyController.Step>();        
        Map<String,Journey_Path_Setting__c> stepMap = getStepMap(journeyName);
        Integer maxStepOrder=0;
        Long avgTime = 0;        
        for(String stepName : stepToLeadMap.keySet()){
            Journey_Path_Setting__c pathSetting = stepMap.get(stepName);
            if(pathSetting.Step_Order__c > maxStepOrder){
                maxStepOrder = (Integer) pathSetting.Step_Order__c;
            }
        }
        
        List<JourneyController.Step> tmpStepList = new List<JourneyController.Step>(maxStepOrder);
        Integer leadCount = 0;
        Integer completedLeadCount = 0;
        Boolean isDone = false;
        String ss;        
        for(String stepName : stepToLeadMap.keySet()){
            if(stepToLeadMap.get(stepName).size()>0){                
                isDone = true;
                ss=stepName;
            }
        }
        String prevStepName;
        for(String stepName : stepToLeadMap.keySet()){
            Journey_Path_Setting__c pathSetting = stepMap.get(stepName);
            List<Lead> leadList = stepToLeadMap.get(stepName);
            if(stepName != COMPLETED_JOURNEY_STEP){
                leadCount += leadList.size();
            } else {
                for(Lead lead : leadList){
                     
                    DateTime currentTimestamp = lead.Journey_Completed_Timestamp__c;
                    DateTime previousTimestamp = lead.CreatedDate;
                    Long differenceBetweenHours = (Datetime.now().getTime() - lead.Journey_Completed_Timestamp__c.getTime())/1000/60/60;
                    if(differenceBetweenHours<3){                          
                        completedLeadCount++;                  
                    }                                    
                    /*
                   DateTime previousTimestamp = lead.CreatedDate;//obtainTimestampFromStepName(previousStepName, lead);  
                    Long differenceBetweenHours = (DateTime.now().getTime() - previousTimestamp.getTime())/1000/60/60;
                     if(differenceBetweenHours<3){  
                        completedLeadCount++;                 
                    }*/  
                }
                
            }
            Long timeProcess = calculatedSLA.containsKey(stepName) ? calculatedSLA.get(stepName) : 0;
            String timeProcessString;
            if(timeProcess != 0){              
                Integer hours = (Integer)(timeProcess/1000/60/60);
                Integer minutes = Math.mod((Integer)(timeProcess/1000/60),60);   
                Integer seconds = Math.mod((Integer)(timeProcess/1000),60);      
                timeProcessString = hours < 10 ? '0' + hours +':' : hours +':';
                timeProcessString += minutes < 10 ? '0'+minutes + ':': minutes + ':';
                timeProcessString += seconds < 10 ? '0'+seconds: '' + seconds;
            } else {
                timeProcessString = '00:00:00';
            }
            tmpStepList.set(pathSetting.Step_Order__c.intValue()-1,new JourneyController.Step(stepName,leadList.size(),pathSetting.Step_SLA__c,timeProcessString,false));
            prevStepName = stepName;
        }
        for(JourneyController.Step step_i : tmpStepList){
            if(step_i != null){
                if(isDone){
                    step_i.done = true;
                }
                if(step_i.stepName == ss){
                    isDone=false;
                }
                stepList.add(step_i);
            }
        }
        if(completedLeadCount != 0)
            avgTime = calculatedSLA.get(COMPLETED_JOURNEY_STEP);
        String avgTimeString;
        System.debug('avgTime ' + avgTime);
        if(avgTime != 0 && avgTime != null){              
            Integer hours = (Integer)(avgTime/1000/60/60);
            Integer minutes = Math.mod((Integer)(avgTime/1000/60),60);  
            Integer seconds = Math.mod((Integer)(avgTime/1000),60); 
            avgTimeString = hours < 10 ? '0' + hours +':' : hours +':';
            avgTimeString+=  minutes < 10 ? '0'+minutes + ':': minutes + ':';
            avgTimeString += seconds < 10 ? '0'+seconds: '' + seconds;
        } else {
            avgTimeString = '00:00:00';
        }
        JourneyController.Path path = new JourneyController.Path(journeyName,leadCount,avgTimeString,2,stepList,completedLeadCount);
        return path; 
    }
    
    public static JourneyController.Path generateGenericPath(Map<String,List<Lead>> stepToLeadMap,List<Lead> lead){
        List<JourneyController.Step> stepList = new List<JourneyController.Step>();
        String journeyName = '';
        if(!lead.isEmpty()){
            journeyName = lead[0].Orchestration_Journey__c;
        }
        Map<String,Journey_Path_Setting__c> stepMap = getStepMap(journeyName);
        Integer maxStepOrder=0;
        for(String stepName : stepToLeadMap.keySet()){
            Journey_Path_Setting__c pathSetting = stepMap.get(stepName);
            if(pathSetting.Step_Order__c > maxStepOrder){
                maxStepOrder = (Integer) pathSetting.Step_Order__c;
            }
        }
        List<JourneyController.Step> tmpStepList = new List<JourneyController.Step>(maxStepOrder);
        Integer leadCount = 0;        
        Boolean isDone = false;
        String ss;        
        for(String stepName : stepToLeadMap.keySet()){
            if(stepToLeadMap.get(stepName).size()>0){                
                isDone = true;
                ss=stepName;
            }
        }
        for(String stepName : stepToLeadMap.keySet()){
            
            Journey_Path_Setting__c pathSetting = stepMap.get(stepName);
            List<Lead> leadList = stepToLeadMap.get(stepName);
            leadCount += leadList.size();
            tmpStepList.set(pathSetting.Step_Order__c.intValue()-1,new JourneyController.Step(stepName,leadList.size(),'','',false));
        }
       
        for(JourneyController.Step step_i : tmpStepList){
            if(step_i != null){
                if(isDone){
                    step_i.done = true;
                }
                if(step_i.stepName == ss){
                    isDone=false;
                }
                stepList.add(step_i);
            }
        }
        
        JourneyController.Path path = new JourneyController.Path('General Journey',leadCount,'',2,stepList,0);
        return path;
    }
    
    public static List<Lead> generateLeadInfo(String searchParameter, String field){
        String query = 'SELECT Id,Name,Email,CreatedDate,Journey_Completed_Timestamp__c,LeanData__Reporting_Timestamp__c,Clearbit_Timestamp__c,Polygraph_Update_Timestamp__c,SW_Fit_Score_Timestamp__c,First_Behavioral_Rate_Timestamp__c,Business_unit_timestamp__c,First_MQL_Calc__c,LeanData__Routing_Action__c,LeanData__Routing_Status__c,LD_Update_DateTime__c,Orchestration_Journey__c FROM Lead WHERE ' +field +  '= :searchParameter AND CreatedDate >= :fixedDate LIMIT 1';
        System.debug('searchParameter ' + searchParameter);
        System.debug('query ' + query);
        DateTime fixedDate = datetime.newInstance(2018, 12, 9);
        List<Lead> leadList = Database.query(query);
        return leadList;
    }
    
    public static  Map<String,List<Lead>> createLeadToStepMapping(List<Lead> leadList/*, Map<String,List<Lead>> stepToLeadMap*/){
        Map<String,List<Lead>> stepToLeadMap = new Map<String,List<Lead>>();
        String journeyName = '';
        if(!leadList.isEmpty()){
            journeyName = leadList[0].Orchestration_Journey__c;
        }
        List<Journey_Path_Setting__c> pathSettingList = getSettings(journeyName);
        System.debug('pathSettingList ' + pathSettingList);
        if(!pathSettingList.isEmpty()){
            for(Journey_Path_Setting__c setting_i : pathSettingList){
                stepToLeadMap.put(setting_i.Step_Name__c, new List<Lead>());
            }
            for(Lead lead_i : leadList){
                /*if(lead_i.Polygraph_Update_Timestamp__c == null && stepToLeadMap.containsKey(POLYGRAPH_STEP)){
                    stepToLeadMap.get(POLYGRAPH_STEP).add(lead_i);
                }else if(lead_i.Enrichment_Test_Timestamp__c == null){
                    stepToLeadMap.get(ENRICHMENT_STEP).add(lead_i);
                }else if(lead_i.Enrichment_Test_Timestamp__c != null && lead_i.SW_Fit_Score_Timestamp__c == null && stepToLeadMap.containsKey(FIT_SCORE_STEP)){
                    stepToLeadMap.get(FIT_SCORE_STEP).add(lead_i);
                }else if(lead_i.SW_Fit_Score_Timestamp__c != null && lead_i.First_Behavioral_Rate_Timestamp__c == null && stepToLeadMap.containsKey(BEHAVIORAL_RATE_STEP)){
                    stepToLeadMap.get(BEHAVIORAL_RATE_STEP).add(lead_i);
                }else if(lead_i.First_Behavioral_Rate_Timestamp__c != null && lead_i.Business_unit_timestamp__c == null && stepToLeadMap.containsKey(BUSINESS_UNIT_STEP)) {
                    stepToLeadMap.get(BUSINESS_UNIT_STEP).add(lead_i);
                }else if(lead_i.Business_unit_timestamp__c != null && lead_i.First_MQL_Calc__c == null && stepToLeadMap.containsKey(MQL_STEP)){
                    stepToLeadMap.get(MQL_STEP).add(lead_i);
                }else if(lead_i.First_MQL_Calc__c != null && lead_i.LD_Timestamp__c == null && stepToLeadMap.containsKey(LDR_DECISION_STEP)){
                    stepToLeadMap.get(LDR_DECISION_STEP).add(lead_i);
                }else if(lead_i.LeanData__Routing_Status__c != null && stepToLeadMap.containsKey(COMPLETED_JOURNEY_STEP)){
					stepToLeadMap.get(COMPLETED_JOURNEY_STEP).add(lead_i);
				}*/
                String previousStepName;
                for(String stepName : stepToLeadMap.keySet()){
                    Boolean contains = isStepContainsLead(stepName,previousStepName,lead_i);
                    if(contains){
                        stepToLeadMap.get(stepName).add(lead_i);
                        break;
                    }
                    previousStepName = stepName;
                }
            }
        }
        return stepToLeadMap;
    }
    
    public static Map<String,Long> calculateSLA(Map<String,List<Lead>> stepToLeadMap){
        Map<String,Long> result = new Map<String,Long>();
        //String previousStepName='CreatedDate';
        for(String stepName : stepToLeadMap.keySet()){
            Long sum = 0;
            Integer count = 0;
            Long delta = 0;
            DateTime now = DateTime.now();
            List<Lead> leadList = stepToLeadMap.get(stepName);
            /*if(stepName==POLYGRAPH_STEP){                
                for(Lead lead: leadList){
                    Long differenceBetweenHours = (now.getTime() - lead.Polygraph_Update_Timestamp__c.getTime())/1000/60/60;
                    if(differenceBetweenHours<3 && lead.Sent_to_Polygraph__c!=null){
                        DateTime stepIn = lead.Sent_to_Polygraph__c;
                        DateTime stepOut = lead.Polygraph_Update_Timestamp__c;   
                        sum+= stepOut.getTime() - stepIn.getTime();
                        count++;                    
                    }
                }          
            } else if(stepName == CLEARBIT_STEP){                
                for(Lead lead: leadList){
                    
                    if(lead.Clearbit_Timestamp__c !=null){
                        Long differenceBetweenHours = (now.getTime() - lead.Clearbit_Timestamp__c.getTime())/1000/60/60;
                        if(differenceBetweenHours<3 && lead.Polygraph_Update_Timestamp__c!=null){
                            DateTime stepIn = lead.CreatedDate;
                            DateTime stepOut = lead.Clearbit_Timestamp__c;
                            sum+= stepOut.getTime() - stepIn.getTime();
                            count++;
                        }
                    } else {
                        if(lead.Polygraph_Update_Timestamp__c!=null){
                            DateTime stepIn = lead.CreatedDate;
                            DateTime stepOut = now;   
                            sum+= stepOut.getTime() - stepIn.getTime();
                            count++;
                        }
                    }
                    
                }    
            } else if(stepName == BEHAVIORAL_RATE_STEP){
                for(Lead lead: leadList){ 
                    Long differenceBetweenHours = (now.getTime() - lead.First_Behavioral_Rate_Timestamp__c.getTime())/1000/60/60;
                    if(differenceBetweenHours<3 && lead.SW_Fit_Score_Timestamp__c!=null){
                        DateTime stepIn = lead.SW_Fit_Score_Timestamp__c;
                        DateTime stepOut = lead.First_Behavioral_Rate_Timestamp__c;    
                        sum+= stepOut.getTime() - stepIn.getTime();
                        count++;                    
                    }
                }                
            } else if(stepName == BUSINESS_UNIT_STEP){
                for(Lead lead: leadList){ 
                    Long differenceBetweenHours = (now.getTime() - lead.Business_unit_timestamp__c.getTime())/1000/60/60;
                    if(differenceBetweenHours<3 && lead.First_Behavioral_Rate_Timestamp__c!=null){
                        DateTime stepIn = lead.First_Behavioral_Rate_Timestamp__c;
                        DateTime stepOut = lead.Business_unit_timestamp__c;    
                        sum+= stepOut.getTime() - stepIn.getTime();
                        count++;                    
                    }
                }     
            } else if(stepName == MQL_STEP){
                for(Lead lead: leadList){ 
                    Long differenceBetweenHours = (now.getTime() - lead.First_MQL_Calc__c.getTime())/1000/60/60;
                    if(differenceBetweenHours<3 && lead.Business_unit_timestamp__c!=null){
                        DateTime stepIn = lead.Business_unit_timestamp__c;
                        DateTime stepOut = lead.First_MQL_Calc__c;    
                        sum+= stepOut.getTime() - stepIn.getTime();
                        count++;                    
                    }
                }     
            } else if(stepName == ROUTING_STEP){
                for(Lead lead: leadList){ 
                    Long differenceBetweenHours = (now.getTime() - lead.LeanData__Reporting_Timestamp__c.getTime())/1000/60/60;
                    if(differenceBetweenHours<3 && lead.First_MQL_Calc__c!=null){
                        DateTime stepIn = lead.First_MQL_Calc__c;
                        DateTime stepOut = lead.LeanData__Reporting_Timestamp__c;    
                        sum+= stepOut.getTime() - stepIn.getTime();
                        count++;                    
                    }
                }   
            }*/
            /*System.debug('stepName ' + stepName);
            System.debug('previousStepName ' + previousStepName);
             for(Lead lead: leadList){
                Long differenceBetweenHours = (now.getTime() - lead.createdDate.getTime())/1000/60/60;
                System.debug('differenceBetweenHours ' + differenceBetweenHours);
                if(differenceBetweenHours<3){
                    DateTime stepIn = lead.createdDate;
                    DateTime stepOut = now;   
                    sum+= stepOut.getTime() - stepIn.getTime();
                    count++;                    
                }
            }*/ 
            if(stepName==POLYGRAPH_STEP){
                for(Lead lead: leadList){
                    Long differenceBetweenHours = (now.getTime() - lead.Polygraph_Update_Timestamp__c.getTime())/1000/60/60;
                    System.debug('differenceBetweenHours ' + differenceBetweenHours);
                    if(differenceBetweenHours<3){
                        //DateTime stepIn = lead.Sent_to_Polygraph__c;
                        DateTime stepIn = lead.CreatedDate;
                        DateTime stepOut = lead.Polygraph_Update_Timestamp__c;   
                        sum+= stepOut.getTime() - stepIn.getTime();
                        count++;                    
                    }
                } 
            } else if(/*previousStepName == null ||*/ stepName==JOURNEY_DECISION_STEP || stepName==WEBSITE_STEP|| stepName==PARDOT_STEP || stepName==SFCD_STEP ){
                //previousStepName = stepName;
                continue;
            } /*else if(stepName==CLEARBIT_STEP){
                for(Lead lead: leadList){ 
                    DateTime currentTimestamp = obtainTimestampFromStepName(stepName, lead);
                    DateTime previousTimestamp = obtainTimestampFromStepName(previousStepName, lead);   
                                                             
                    if(currentTimestamp !=null){
                        Long differenceBetweenHours = (now.getTime() - currentTimestamp.getTime())/1000/60/60;
                        if(differenceBetweenHours<3 && previousTimestamp!=null){
                            DateTime stepIn = lead.CreatedDate;
                            DateTime stepOut = currentTimestamp;
                            sum+= stepOut.getTime() - stepIn.getTime();
                            count++;
                        }
                    } else if(previousTimestamp!=null){                        
                        DateTime stepIn = lead.CreatedDate;
                        DateTime stepOut = now;   
                        sum+= stepOut.getTime() - stepIn.getTime();
                        count++;                        
                    }
                } 
            } else if(stepName==FIT_SCORE_STEP){
                for(Lead lead: leadList){ 
                    DateTime currentTimestamp = obtainTimestampFromStepName(stepName, lead);
                    DateTime previousTimestamp = obtainTimestampFromStepName(previousStepName, lead);  
                    Long differenceBetweenHours = (now.getTime() - currentTimestamp.getTime())/1000/60/60;
                    System.debug('stepName ' + stepName);
                    System.debug('previousStepName ' + previousStepName);
                    System.debug('currentTimestamp ' + currentTimestamp);
                    System.debug('differenceBetweenHours ' + differenceBetweenHours);
                    if(differenceBetweenHours<3){                          
                        sum+= previousTimestamp.getTime() - currentTimestamp.getTime();
                        count++;                    
                    }                    
                } 
            } */else {
                for(Lead lead: leadList){ 
                    DateTime currentTimestamp = obtainTimestampFromStepName(stepName, lead);
                    if(currentTimestamp == null)
                        continue;
                    DateTime previousTimestamp = lead.CreatedDate;//obtainTimestampFromStepName(previousStepName, lead);  
                    Long differenceBetweenHours = (now.getTime() - currentTimestamp.getTime())/1000/60/60;
                    System.debug('differenceBetweenHours ' + differenceBetweenHours);
                    System.debug('stepName ' + stepName);
                    //System.debug('previousStepName ' + previousStepName);
                    System.debug('currentTimestamp ' + currentTimestamp);
                    System.debug('previousTimestamp ' + previousTimestamp);
                    if(differenceBetweenHours<3){  
                        sum+= currentTimestamp.getTime() - previousTimestamp.getTime();
                        count++;                    
                    }                    
                } 
            }            
            //previousStepName = stepName;            
            if(count != 0){
                delta = sum/count;
                result.put(stepName,delta);
            }
        }
        return result;
    }
}
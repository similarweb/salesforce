global without sharing class DependentPicklistLghtn {
	
    public class OptionEntry {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get;set;}
        
        public OptionEntry(String label, String value){
            this.label = label;
            this.value = value;
        }
    }
    
    public class DependedPicklistsWrapper {
        @AuraEnabled
        public OptionEntry key {get; set;}
        @AuraEnabled
        public List <OptionEntry> valueList {get; set;}
        
        public DependedPicklistsWrapper(OptionEntry key, List<OptionEntry> valueList) {
            this.key = key;
            this.valueList = new List <OptionEntry>();
            this.valueList.addAll(valueList);
        }
    }
    
    @AuraEnabled
    public static Response getDependedPicklist(String sobjectName, String parent, String dependent) {
        try {
            System.debug('sobjectName ' + sobjectName +  ', parent ' + parent + '. dependent ' + dependent);
            Map <String, List <String>> tmpMap = new Map <String, List <String>>();
            tmpMap = DependentPickListInfo.getFieldDependencies(sobjectName,
                                                       parent,
                                                       dependent);
            System.debug('tmpMap ' + tmpMap);
            List <DependedPicklistsWrapper> wrapperToReturn = new List <DependedPicklistsWrapper>();
            List<OptionEntry> options;
            
                for (String key_i : tmpMap.keySet()) {
                    options = new List<OptionEntry>();
                    for (String val : tmpMap.get(key_i))
                        options.add(new OptionEntry(val, val));
                    wrapperToReturn.add(new DependedPicklistsWrapper(new OptionEntry(key_i, key_i), options));
                }
            
            return new Response(true, wrapperToReturn);
        } catch (Exception e) {
            return new Response(false, e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static Response getFieldDetails(String sobjectName, String parent, String dependent){
        String errorMessage = '';
        Schema.SObjectType t = Schema.getGlobalDescribe().get(sobjectName);
        Map<String,Schema.SObjectField> objectFields;
        Map<String, String> fieldDetails = new Map<String, String>();
        
        System.debug('sobjectName ' + sobjectName +  ', parent ' + parent + '. dependent :' + dependent + '.');
        
        if (t == null){
      		errorMessage = 'SObject type ' + sobjectName + ' not found.';
        } else {
            objectFields = t.getDescribe().fields.getMap();
            if (!objectFields.containsKey(parent))
                errorMessage += 'Parent Field ' + parent + ' not found.';
            if (!objectFields.containsKey(dependent))
                errorMessage += 'Dependent Field ' + dependent + ' not found.';
        }
        if (String.isEmpty(errorMessage)) {
            fieldDetails.put('parentLabel', objectFields.get(parent).getDescribe().getLabel());
            fieldDetails.put('dependentLabel', objectFields.get(dependent).getDescribe().getLabel());
            /*if (parent.toLowerCase().contains('countrycode') && dependent.toLowerCase().contains('statecode')){
                fieldDetails.put('parentLabel', fieldDetails.get('parentLabel').replace('Code', ''));
                fieldDetails.put('dependentLabel', fieldDetails.get('dependentLabel').replace('Code', ''));
            }*/
        }
        return String.isEmpty(errorMessage) ? new Response(true, fieldDetails) : new Response(false, errorMessage);
    }
}
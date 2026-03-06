public with sharing class JwtCredentials {
    
    private static JwtCredentials instance;
    private static String SUBJECT_DEVNAME = 'subject_jwt';
    public String iss {get;private set;}
    public String aud {get;private set;}
    public String certificate {get;private set;}

    public static JwtCredentials getInstance(){
        if (instance == null) {
            instance = new JwtCredentials();
        }
        return instance;
    }
    
    private JwtCredentials() {
        Map<String,Base_Product_Configuration__c> configMap = Base_Product_Configuration__c.getAll();

        if (!configMap.containsKey('Aud') || configMap.get('Aud').Value__c == null) {
            throw new InvalidSettingException('No aud setted');
        }        
        if (!configMap.containsKey('Iss') || configMap.get('Iss').Value__c == null) {
            throw new InvalidSettingException('No iss setted');
        }        
        if (!configMap.containsKey('Certificate') || configMap.get('Certificate').Value__c == null) {
            throw new InvalidSettingException('No certificate setted');
        }

        Base_Product_Configuration__c audCS = configMap.get('Aud');
        Base_Product_Configuration__c issCS = configMap.get('Iss');
        Base_Product_Configuration__c certificateCS = configMap.get('Certificate');

        iss = issCS.Value__c;
        aud = audCS.Value__c;
        certificate = certificateCS.Value__c;
    }

    /*
        Updated by Synebo Developer 14.03.2022
        MQ-1481: Using metadata to dynamically set Subject.
    */
    public String getAccessToken(){
        Auth.JWT jwt = new Auth.JWT();    
        String accessToken = '';
        
        String jwtSubject = obtainSubjectFromMetadata();

        if(String.isNotBlank(jwtSubject)){
            jwt.setSub(jwtSubject); 
            jwt.setAud(aud); 
            jwt.setIss(iss);
            Auth.JWS jws = new Auth.JWS(jwt, certificate);
            String tokenEndpoint = URL.getSalesforceBaseUrl().toExternalForm() + '/services/oauth2/token';
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
            if (Test.isRunningTest()) {
                accessToken =  'testAccessToken';
            } else {
                accessToken = bearer.getAccessToken();
            }
        } else {
            throw new InvalidSettingException('Subject value not found in metadata');
        }
        
        return accessToken;
    }

    /*
        Created by Synebo Developer 14.03.2022
        MQ-1481: get Subject value from metadata
    */
    private String obtainSubjectFromMetadata(){
        String jwtSubject = '';
        List<Zuora_Quote_Contact_Generation_Setting__mdt> contactGenerationList = [SELECT DeveloperName,Value__c FROM Zuora_Quote_Contact_Generation_Setting__mdt WHERE DeveloperName =: SUBJECT_DEVNAME];
        if(!contactGenerationList.isEmpty()){
            jwtSubject = contactGenerationList[0].Value__c;
        }
        return jwtSubject;
    }

    private class InvalidSettingException extends Exception {  }
}
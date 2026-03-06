public with sharing class GroudonIntegrationService {
    private static GroudonQueueable.GroudonRequestGenerator requestGenerator;
    private static GroudonQueueable.GroudonResponseGenerator responseGenerator;
    private static API_Configuration__mdt apiConfiguration;

    public GroudonIntegrationService(GroudonQueueable.GroudonRequestGenerator requestGeneratorInstance,
                                     GroudonQueueable.GroudonResponseGenerator responseGeneratorInstance,
                                     API_Configuration__mdt apiConfigurationInstance) {
        requestGenerator = requestGeneratorInstance;
        responseGenerator = responseGeneratorInstance;
        apiConfiguration = apiConfigurationInstance;
    }

    public GroudonResponse callGroudonBulk(List<SObject> recordList) {
        List<GroudonRequest> requestList = new List<GroudonRequest>();
        for(SObject record : recordList){
            requestList.add(requestGenerator.generate(record));
        }
        GroudonResponse groudonResponse = responseGenerator.generate(requestList);

        generateRequest(JSON.serialize(requestList), groudonResponse);

        return groudonResponse;
    }

    public GroudonResponse callGroudon(SObject record) {
        List<GroudonRequest> requestList = new List<GroudonRequest>{requestGenerator.generate(record)};
        GroudonResponse groudonResponse = responseGenerator.generate(requestList);

        generateRequest(JSON.serialize(requestList), groudonResponse);

        return groudonResponse;
    }

    private void generateRequest(String jsonBody, GroudonResponse groudonResponse) {
//        String endPoint = 'https://bga53dxur5ga27y64ihci2hiku0fnfoh.lambda-url.us-east-1.on.aws/';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiConfiguration.End_Point__c);
        req.setMethod(apiConfiguration.Method__c);
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);

        Http http = new Http();
        HTTPResponse res;

        try {
            res = http.send(req);
            if (res.getStatusCode() != 201) {
                throw new GroudonIntegrationServiceException('status is not 201');
            }

            groudonResponse.isSuccess = true;
            groudonResponse.responseMsg = 'Success ' + res.getBody();
            groudonResponse.responseStatus = res.getStatus();
        } catch (Exception e) {
            groudonResponse.isSuccess = false;
            groudonResponse.responseStatus = res.getStatus();
            groudonResponse.responseMsg = 'Error calling Groudon endpoint: ' + e.getMessage() + ' ' + e.getStackTraceString();
        }
    }



    public class GroudonRequest {
        public String first_name;
        public String last_name;
        public String domain;
        public String Country_Code;
        public String Department_C;
        public String Department_Other_Description;
        public String email;
        public String linkedin_profile;
        public String Seniority;
        public String industry;
        public String job_title;
        public String Industry_Other_Description;
        public String Title_Other_Description;
        public String Pre_mapped_industry;
        public String Pre_Mapped_Title;
        public String website;
        public String Use_of_Similarweb;
        public String title;
        public String Strategic_Pod;
        public Decimal SI_Enrichment_Visits;
        public String ROE_Division;
        public String Quiz_Data_Incomplete;
        public String MIR_Status;
        public String Lugia_Linkedin_Profile;
        public String LinkedIn;
        public String Lugia_Fit_Score;
        public Decimal Employees_Min;
        public String Business_Unit;
        public String Email_address_domain_type;
        public String country;
        public String Clean_Domain;
        public String Lugia_Employees_Count;
        public String Lugia_Fit_Score_Reasoning;
        public String Fit_Score_Test;
        public String SW_Fit_Score_Reason;
        public String Company;
        public Datetime timestamp;
        public String sf_id;
        public String clientIp;
        public String sf_type;
        public String Registration_Type;
        public String LeadSource;
    }

    public class GroudonResponse{
        public Boolean isSuccess;
        public String responseStatus;
        public String responseMsg;
        public Map<Id,String> leadIdToBodyMap = new Map<Id, String>();
        public Map<Id,String> contactIdToBodyMap = new Map<Id, String>();
    }

    public class GroudonIntegrationServiceException extends Exception{}
}
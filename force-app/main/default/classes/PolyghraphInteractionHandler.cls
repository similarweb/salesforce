/*
 * Made by Dmitry Trufanov from Synebo
 */
public class PolyghraphInteractionHandler {
  //    public void enrichLeadList(){
  //        try{
  //            System.debug('===PolyghraphInteractionHandler.enrichLeadList===');
  //            Map<Integer,Set<Id>> chunckedMap = new Map<Integer,Set<Id>>();
  //            for(Integer i=0;i<Trigger.new.size();i++){
  //                Lead lead_i = (Lead)Trigger.new[i];
  //                Integer index = i/100;
  //                if(!chunckedMap.containsKey(index)){
  //                    chunckedMap.put(index,new Set<Id>());
  //                }
  //                chunckedMap.get(index).add(lead_i.Id);
  //            }
  //            if(!chunckedMap.isEmpty()){
  //                for(Integer key_i : chunckedMap.keySet()){
  //                    enrichLeadListFuture(chunckedMap.get(key_i));
  //                }
  //            }
  //        }catch(Exception ex){
  //            System.debug(ex);
  //        }
  //    }

  public void enrichContactList(List<Contact> contactList) {
    try {
      System.debug('===PolyghraphInteractionHandler.enrichLeadList===');
      Map<Integer, Set<Id>> chunckedMap = new Map<Integer, Set<Id>>();
      for (Integer i = 0; i < Trigger.new.size(); i++) {
        Contact contact_i = contactList[i];
        Integer index = i / 100;
        if (!chunckedMap.containsKey(index)) {
          chunckedMap.put(index, new Set<Id>());
        }
        chunckedMap.get(index).add(contact_i.Id);
      }
      if (!chunckedMap.isEmpty()) {
        for (Integer key_i : chunckedMap.keySet()) {
          enrichContactListFuture(chunckedMap.get(key_i));
        }
      }
    } catch (Exception ex) {
      System.debug(ex);
    }
  }

  //    @future (callout=true)
  //    public static void enrichLeadListFuture(Set<Id> leadIdSet){
  //        System.debug('===PolyghraphInteractionHandler.enrichLeadListFuture===');
  //        System.debug('leadIdSet:'+leadIdSet);
  //        List<Lead> leadList = [SELECT Id,Email,Polygraph_Update_Timestamp__c, clientIp__c, Website FROM Lead WHERE Id IN :leadIdSet];
  //        for(Lead lead_i : leadList){
  //            if(lead_i.Polygraph_Update_Timestamp__c == null){
  //                try{
  //                    String token = generatePolygraphToken();
  //                    String requestBody = generateBody(lead_i);
  //                    String responseBody = sendToPolygraph(requestBody,token);
  //                    parseResponse(responseBody,lead_i);
  //                    lead_i.Polygraph_Send_Status__c = 'Sent';
  //                }catch(Exception ex){
  //                    System.debug(ex.getMessage());
  //                    System.debug(ex.getStackTraceString());
  //                    lead_i.Polygraph_Error__c = ex.getMessage();
  //                    lead_i.Polygraph_Send_Status__c = 'Error';
  //                }
  //            }
  //            lead_i.Sent_to_Polygraph__c = System.now();
  //            if(lead_i.Polygraph_Update_Timestamp__c == null){
  //                lead_i.Polygraph_Update_Timestamp__c = System.now();
  //            }
  //        }
  //        update leadList;
  //        //Integer delayValue = Integer.valueOf(20);
  //        //Datetime sysTime = System.now().addSeconds(delayValue);
  //        //String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
  //        //EnrichLeadListSchedulable scheduleItem = new EnrichLeadListSchedulable(leadList);
  //        //String cronId = System.schedule('Scheduled Job ' + sysTime, chronExpression, scheduleItem);
  //    }

  @future(callout=true)
  public static void enrichContactListFuture(Set<Id> contactIdSet) {
    System.debug('===PolyghraphInteractionHandler.enrichLeadListFuture===');
    System.debug('contactIdSet:' + contactIdSet);
    List<Contact> contactList = [
      SELECT Id, Email, Polygraph_Update_Timestamp__c, Website__c
      FROM Contact
      WHERE Id IN :contactIdSet
    ];
    for (Contact cont : contactList) {
      if (cont.Polygraph_Update_Timestamp__c == null) {
        try {
          String token = generatePolygraphToken();
          String requestBody = generateBody(cont);
          String responseBody = sendToPolygraph(requestBody, token);
          parseResponse(responseBody, cont);
          cont.Polygraph_Send_Status__c = 'Sent';
        } catch (Exception ex) {
          System.debug(ex.getMessage());
          System.debug(ex.getStackTraceString());
          cont.Polygraph_Error__c = ex.getMessage();
          cont.Polygraph_Send_Status__c = 'Error';
        }
      }
      cont.Sent_to_Polygraph__c = System.now();
      if (cont.Polygraph_Update_Timestamp__c == null) {
        cont.Polygraph_Update_Timestamp__c = System.now();
      }
    }
    update contactList;
    //Integer delayValue = Integer.valueOf(20);
    //Datetime sysTime = System.now().addSeconds(delayValue);
    //String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    //EnrichLeadListSchedulable scheduleItem = new EnrichLeadListSchedulable(leadList);
    //String cronId = System.schedule('Scheduled Job ' + sysTime, chronExpression, scheduleItem);
  }

  public class PolygraphInteractionException extends Exception {
  }

  private static String sendToPolygraph(String body, String xToken) {
    System.debug('===PolyghraphInteractionHandler.sendToPolygraph===');
    System.debug('body:' + body);
    System.debug('xToken:' + xToken);
    Polygraph_Interaction_Setting__c endpointSetting = Polygraph_Interaction_Setting__c.getInstance(
      'Endpoint'
    );
    if (endpointSetting == null) {
      throw new PolygraphInteractionException(
        'Endpoint to polygraph not exist'
      );
    }
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpointSetting.Value__c + '/api/enrich');
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('x-token', xToken);
    request.setTimeout(30000);
    request.setBody(body);
    HttpResponse response = http.send(request);
    return response.getBody();
  }

  private static String generateBody(Contact contactToEnrich) {
    System.debug('===PolyghraphInteractionHandler.generateBody===');
    System.debug('contactToEnrich:' + contactToEnrich);
    if (contactToEnrich == null) {
      throw new PolygraphInteractionException('Contact not found');
    }
    ContactRequestWrapper wrapper = new ContactRequestWrapper(
      contactToEnrich.Email,
      '',
      contactToEnrich.Website__c
    );
    PolygraphContactRequest request = new PolygraphContactRequest(wrapper);
    String responseBody = JSON.serialize(request);
    System.debug(responseBody);
    return responseBody;
  }

  //    private static String generateBody(Lead leadToEnrich){
  //        System.debug('===PolyghraphInteractionHandler.generateBody===');
  //        System.debug('leadToEnrich:'+leadToEnrich);
  //        if(leadToEnrich == null){
  //            throw new PolygraphInteractionException('Lead not found');
  //        }
  //        LeadWrapper wrapper = new LeadWrapper(leadToEnrich.Email,leadToEnrich.clientIp__c, leadToEnrich.Website);
  //        PolygraphRequest request = new PolygraphRequest(wrapper);
  //        String responseBody = JSON.serialize(request);
  //        System.debug(responseBody);
  //        return responseBody;
  //    }
  //
  //    private static void parseResponse(String responseRaw,Lead leadToEnrich){
  //        System.debug('===PolyghraphInteractionHandler.parseResponse===');
  //        System.debug('responseRaw:'+responseRaw);
  //        System.debug('leadToEnrich:'+leadToEnrich);
  //        PolygraphResponse response = (PolygraphResponse)JSON.deserialize(responseRaw, PolygraphResponse.class);
  //        if(String.isNotBlank(response.Error)){
  //            throw new PolygraphInteractionException(response.Error);
  //        }
  //        leadToEnrich.Polygraph_Email_Type__c = response.contact.emailType;
  //        leadToEnrich.Polygraph_Email__c = response.contact.email;
  //        leadToEnrich.Polygraph_First_Name__c = response.contact.firstName;
  //        leadToEnrich.Polygraph_Last_Name__c = response.contact.lastName;
  //        leadToEnrich.Polygraph_Profile_Pic__c = response.contact.profilePic;
  //        leadToEnrich.Polygraph_Country_Code__c = response.contact.countryCode;
  //        leadToEnrich.Polygraph_Country_Name__c = response.contact.countryName;
  //        leadToEnrich.Polygraph_Title__c = response.contact.title;
  //        leadToEnrich.Polygraph_Seniority__c = response.contact.seniority;
  //        leadToEnrich.Polygraph_Role__c = response.contact.role;
  //        leadToEnrich.Polygraph_Linkedin__c = response.contact.linkedin;
  //        leadToEnrich.Polygraph_Twitter__c = response.contact.twitter;
  //        leadToEnrich.Polygraph_Additional_Email__c = response.contact.additionalEmail==null?'':String.join(response.contact.additionalEmail, ';');
  //        leadToEnrich.polygraph_domains_comparison__c = response.attributes.domainsComparison;
  //        leadToEnrich.Polygraph_Company_Country_Code__c = response.company.countryCode;
  //        leadToEnrich.Polygraph_Company_Country_Name__c = response.company.countryName;
  //        leadToEnrich.Polygraph_Company_State_Name__c = response.company.stateName;
  //        leadToEnrich.Polygraph_Company_State_Code__c = response.company.stateCode;
  //        leadToEnrich.Polygraph_Company_City__c = response.company.city;
  //        leadToEnrich.Polygraph_Company_Employees_Estimated__c = response.company.employeesEstimated;
  //        leadToEnrich.Polygraph_Company_Employees_Range__c = response.company.employeesRange;
  //        leadToEnrich.Polygraph_Company_Name__c = response.company.name;
  //        leadToEnrich.Polygraph_Company_Domain__c = response.company.domain;
  //        leadToEnrich.Polygraph_Company_Logo__c = response.company.logo;
  //        leadToEnrich.Polygraph_Company_Other_Domains__c = response.company.otherDomains==null?'':String.join(response.company.otherDomains, ';');
  //        leadToEnrich.Polygraph_Company_Linkedin__c = response.company.linkedin;
  //        leadToEnrich.Polygraph_Company_Twitter__c = response.company.twitter;
  //        leadToEnrich.Polygraph_Company_Facebook__c = response.company.facebook;
  //        leadToEnrich.Polygraph_Company_Annual_Revenue__c = response.company.annualRevenue;
  //        //leadToEnrich.Polygraph_Employee_Min__c
  //    }

  private static void parseResponse(String responseRaw, Contact leadToEnrich) {
    System.debug('===PolyghraphInteractionHandler.parseResponse===');
    System.debug('responseRaw:' + responseRaw);
    System.debug('leadToEnrich:' + leadToEnrich);
    PolygraphResponse response = (PolygraphResponse) JSON.deserialize(
      responseRaw,
      PolygraphResponse.class
    );
    if (String.isNotBlank(response.Error)) {
      throw new PolygraphInteractionException(response.Error);
    }
    leadToEnrich.Polygraph_Email_Type__c = response.contact.emailType;
    leadToEnrich.Polygraph_Email__c = response.contact.email;
    leadToEnrich.Polygraph_First_Name__c = response.contact.firstName;
    leadToEnrich.Polygraph_Last_Name__c = response.contact.lastName;
    leadToEnrich.Polygraph_Country_Code__c = response.contact.countryCode;
    leadToEnrich.Polygraph_Country_Name__c = response.contact.countryName;
    leadToEnrich.Polygraph_Title__c = response.contact.title;
    leadToEnrich.Polygraph_Seniority__c = response.contact.seniority;
    leadToEnrich.Polygraph_Role__c = response.contact.role;
    leadToEnrich.Polygraph_Linkedin__c = response.contact.linkedin;
    leadToEnrich.Polygraph_Twitter__c = response.contact.twitter;
    leadToEnrich.Polygraph_Additional_Email__c = response.contact.additionalEmail ==
      null
      ? ''
      : String.join(response.contact.additionalEmail, ';');
    leadToEnrich.polygraph_domains_comparison__c = response.attributes.domainsComparison;
    leadToEnrich.Polygraph_Company_Country_Name__c = response.company.countryName;
    leadToEnrich.Polygraph_Company_State_Name__c = response.company.stateName;
    leadToEnrich.Polygraph_Company_City__c = response.company.city;
    leadToEnrich.Polygraph_Company_Employees_Estimated__c = response.company.employeesEstimated;
    leadToEnrich.Polygraph_Company_Employees_Range__c = response.company.employeesRange;
    leadToEnrich.Polygraph_Company_Name__c = response.company.name;
    leadToEnrich.Polygraph_Company_Domain__c = response.company.domain;
    leadToEnrich.Polygraph_Company_Logo__c = response.company.logo;
    leadToEnrich.Polygraph_Company_Other_Domains__c = response.company.otherDomains ==
      null
      ? ''
      : String.join(response.company.otherDomains, ';');
    leadToEnrich.Polygraph_Company_Linkedin__c = response.company.linkedin;
    leadToEnrich.Polygraph_Company_Twitter__c = response.company.twitter;
    leadToEnrich.Polygraph_Company_Facebook__c = response.company.facebook;
    leadToEnrich.Polygraph_Company_Annual_Revenue__c = response.company.annualRevenue;
    //leadToEnrich.Polygraph_Employee_Min__c
  }

  public static String generatePolygraphToken() {
    System.debug('===PolyghraphInteractionHandler.generatePolygraphToken===');
    Polygraph_Interaction_Setting__c passwordSetting = Polygraph_Interaction_Setting__c.getInstance(
      'Token_Password'
    );
    if (passwordSetting == null) {
      throw new PolygraphInteractionException('Password for token not exist');
    }
    Polygraph_Interaction_Setting__c userKeySetting = Polygraph_Interaction_Setting__c.getInstance(
      'UserKey'
    );
    if (userKeySetting == null) {
      throw new PolygraphInteractionException('Userkey for token not exist');
    }
    Blob password = Blob.valueOf(passwordSetting.Value__c);
    Blob IV = Crypto.generateAesKey(128);
    Blob data = Blob.valueOf(
      userKeySetting.Value__c + '|' + System.now().getTime()
    );
    Blob encryptedData = Crypto.encrypt('AES256', password, IV, data);
    String hexData = EncodingUtil.convertToHex(encryptedData);
    String hexIV = EncodingUtil.convertToHex(IV);
    String xToken = hexIV + '$' + hexData;
    return xToken;
  }

  public class PolygraphRequest {
    public LeadWrapper lead;

    public PolygraphRequest(LeadWrapper lead) {
      this.lead = lead;
    }
  }

  public class PolygraphContactRequest {
    public ContactRequestWrapper lead;

    public PolygraphContactRequest(ContactRequestWrapper contact) {
      this.lead = contact;
    }
  }

  public class ContactRequestWrapper {
    public String email;
    public String clientIp;
    public String website;

    public ContactRequestWrapper(
      String email,
      String clientIp,
      String website
    ) {
      this.email = email;
      this.clientIp = clientIp;
      this.website = website;
    }
  }

  public class LeadWrapper {
    public String email;
    public String clientIp;
    public String website;

    public LeadWrapper(String email, String clientIp, String website) {
      this.email = email;
      this.clientIp = clientIp;
      this.website = website;
    }
  }

  public class PolygraphResponse {
    public ContactWrapper contact;
    public AttributesWrapper attributes;
    public CompanyWrapper company;
    public String Error;
  }

  public class ContactWrapper {
    public String emailType;
    public String email;
    public String firstName;
    public String lastName;
    public String profilePic;
    public String countryCode;
    public String countryName;
    public String title;
    public String seniority;
    public String role;
    public String linkedin;
    public String twitter;
    public List<String> additionalEmail;
  }

  public class AttributesWrapper {
    public String domainsComparison;
  }

  public class CompanyWrapper {
    public String countryCode;
    public String countryName;
    public String stateName;
    public String stateCode;
    public String city;
    public String employeesEstimated;
    public String employeesRange;
    public String name;
    public String domain;
    public String logo;
    public List<String> otherDomains;
    public String linkedin;
    public String twitter;
    public String facebook;
    public String annualRevenue;
  }
}

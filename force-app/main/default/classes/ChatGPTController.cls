/**
 * Created by zohar.sinay on 11/05/2023.
 */

public with sharing class ChatGPTController {
  @AuraEnabled
  public static String getChatGPTResponse(Id recordId) {
    System.debug('getChatGPTResponse----');
    String website;
    String fullName;
    String title;
    String objectApiName;
    HttpRequest req = new HttpRequest();
    Http http = new Http();
    SObject record;
    try {
      // Describe the sObject to determine its type
      Schema.SObjectType objectType = recordId.getSObjectType();
      objectApiName = objectType.getDescribe().getName();

      // Determine the object type and query accordingly
      if (objectApiName == 'Lead') {
        record = [
          SELECT Website, Title, Name
          FROM Lead
          WHERE Id = :recordId
          LIMIT 1
        ];
      } else if (objectApiName == 'Account') {
        record = [
          SELECT Website, Name
          FROM Account
          WHERE Id = :recordId
          LIMIT 1
        ];
      } else {
        return 'Error: Invalid object type';
      }
      website = (String) record.get('Website');
      fullName = (String) record.get('Name');
      title = (String) record.get('Title');
    } catch (Exception e) {
      System.debug(
        'e---' + e.getMessage() + ' stacktrace -- ' + e.getStackTraceString()
      );
      return 'Error: record does not exist or other SOQL error';
    }

    //        Lead lid = [SELECT Website From Lead WHERE Id = :leadId LIMIT 1];
    try {
      String env = GeneralUtil.getEnvName();
      List<General_Key_Value_pair__mdt> settings = [
        SELECT Id, Value__c, Key__c
        FROM General_Key_Value_pair__mdt
        WHERE
          ProcessName__c = 'ChatGptButton'
          AND IsActive__c = TRUE
          AND Key__c = :env
      ];
      if (settings.isEmpty()) {
        System.debug('not found');
        return 'no api key available in the General_Key_Value_pair__mdt for ' +
          GeneralUtil.getEnvName();
      }
      String apiKey = settings[0].Value__c;

      String endpoint = 'https://api.openai.com/v1/chat/completions';

      String prompt =
        '1. Extract and Analyze the Email Domain ' +
        website +
        '\n' +
        'Use the domain to retrieve publicly available information about the company’s official name, industry, products/services, and target market.\n' +
        '2. Classify the Company\n' +
        'Similarweb Industry Categories\n' +
        'Assign the company to one of the following categories:\n' +
        'AdTech and AdNetwork\n' +
        'Agency\n' +
        'Automotive\n' +
        'B2B Software\n' +
        'B2C Internet Services\n' +
        'Classifieds\n' +
        'Consulting and Market Research\n' +
        'CPG (Consumer Packaged Goods)\n' +
        'Education\n' +
        'Equity Research\n' +
        'Financial Services\n' +
        'Gambling and Gaming\n' +
        'Hedge Funds and Asset Management\n' +
        'Investment Banking\n' +
        'Investors\n' +
        'Logistics and Shipping\n' +
        'Other\n' +
        'Payments\n' +
        'Pharma and Healthcare\n' +
        'Private Equity and Venture Capital\n' +
        'Public Sector, Non-Profit, Fraud and Compliance\n' +
        'Publishers and Media\n' +
        'Retail and eCommerce\n' +
        'Telecom\n' +
        'Travel\n' +
        'General Industry Classification\n' +
        'Determine whether the company primarily operates as B2B, B2C, D2C, or a hybrid model.\n' +
        '\n' +
        '\n' +
        '\n' +
        '\n' +
        '\n' +
        '\n' +
        'Role-Specific Context\n' +
        '\n' +
        'Use the prospect’s ' +
        title +
        ' to hypothesize key challenges, responsibilities, or objectives (e.g., a Sales Director might prioritize pipeline growth; a Marketing Manager might focus on lead generation and campaign performance).\n' +
        '4. Provide a Structured Response in a table\n' +
        'Your final output should contain the following sections:\n' +
        '\n' +
        'Company Name\n' +
        '\n' +
        'The official name of the company.\n' +
        'Industry Category\n' +
        '\n' +
        'The most relevant category from Similarweb’s established list.\n' +
        'General Industry\n' +
        '\n' +
        'State whether the company is B2B, B2C, D2C, or hybrid.\n' +
        'Short Company Description on 7a What they sell 7b.  How they make money\n' +
        '\n' +
        'A concise summary of the company’s business operations, services, and target market.\n' +
        'Prospect Information: Name and Role: ' +
        fullName +
        ' and their ' +
        title +
        '.\n' +
        'Persona Insights: Briefly outline potential pain points or key objectives based on their role.\n' +
        'How Similarweb Can Help (Tailored to the Prospect)\n' +
        '\n' +
        'Web Intelligence: Emphasize competitor analysis, traffic benchmarking, and digital strategy optimization.\n' +
        'Sales Intelligence: Focus on discovering new leads, refining prospecting, and identifying growth opportunities.\n' +
        'API Integration: Highlight how Similarweb data can seamlessly integrate into the company’s workflow.\n' +
        'Role-Specific Recommendations: Provide a problem-solving angle directly tied to the prospect’s title and company objectives (e.g., for a Marketing Manager, talk about campaign optimization and competitor insights; for a Director of Sales, emphasize pipeline expansion and lead generation).\n' +
        'LinkedIn Links: Company LinkedIn Profile ';
      prompt += ' Please format your response as HTML as it need to appear as a table with <br> for line breaks ';
      prompt += ' Important : Set the table\'s background color to white. Use inline CSS in the <table> tag but it should look like a table with grey borders ';
      prompt += 'Important: Do not wrap the output in triple backticks (```), and do not prepend "html" or any other language label. Output raw HTML only. This is going to be rendered directly in a web view, so your response must start and end with HTML tags only. ';

      System.debug('prom[t---' + prompt);

      req.setEndpoint(endpoint);
      req.setMethod('POST');
      req.setHeader('Authorization', 'Bearer ' + apiKey);
      req.setHeader('Content-Type', 'application/json');
      req.setTimeout(120000);

      String body = JSON.serialize(
        new Map<String, Object>{
          'messages' => new List<Map<String, Object>>{
            new Map<String, Object>{ 'role' => 'user', 'content' => prompt }
          },
          'model' => 'gpt-4-turbo',
          'max_tokens' => 1000,
          'n' => 1
        }
      );
      System.debug('body--' + body);

      req.setBody(body);

      HttpResponse res = http.send(req);
      if (res.getStatusCode() == 200) {
        Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(
          res.getBody()
        );
        List<Object> choices = (List<Object>) responseObject.get('choices');
        Map<String, Object> choice = (Map<String, Object>) choices.get(0);
        Map<String, Object> message = (Map<String, Object>) choice.get(
          'message'
        );
        String responseText = (String) message.get('content');

        system.debug('response: ' + responseText);
        record.put('ChatGPT_Summary__c', responseText);
        record.put('Chat_Gpt_Last_Call_Datetime__c', Datetime.now());
        update record;
        return responseText;
      } else {
        return 'Error: ' + res.getStatus();
      }
    } catch (Exception ex) {
      return 'Error:' + ex.getMessage();
    }
  }
}

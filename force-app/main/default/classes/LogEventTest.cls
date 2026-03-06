/**
* @author Itzik Winograd
* @date 10/03/2021
* @description Test class for LogEventTrigger, LogEventTriggerHandler and LogEventUtils
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        -  27/11/2022
* description - Added RelatedRecordd / logEvent3
* --------------------------------------------------------------------------------------     
*/
@isTest
public class LogEventTest {
       
	/**
    * @author Itzik Winograd
    * @date 09/03/2021
    * @Description Create 2 log request, set their values and publish them.
    * @Expected The event will be published successfully, then 3 Apex_Event_Log__c   records will be created for them.
    *           We expect that the values on the log are equal to the values on the Apex_Event_Log__c  record.
    * @param none
    * @return none
    */
    @isTest
    public static void logEventTest(){
        //Create HttpRequest
		HttpRequest request = new HttpRequest();
        request.setEndpoint ('https://google.com');
        request.setHeader('h1', 'hv1');
        String endpoint = 'https://www.google.com';
        
        //Create a LogEvent__e record using the LogEventUtils calss
        Log_Event__e logEvent1 = LogEventUtils.createLogEventRecord(
            new List<String>{'123456789012345678'},
            'LogEventTest',
            'logEventUtilsTest',
            'Some serilaized Data', 
            'error message', 
            'Error', 
            request,
            new List<String>{'h1'}
        );
        
        //Create a LogEvent__e record using the LogEventUtils calss, with relatedRecordId
        Log_Event__e logEvent3 = LogEventUtils.createLogEventRecord(
            new List<String>{'123456789012345678'},
            '123456789012345678',
            'LogEventTest',
            'logEventUtilsTest',
            'Some serilaized Data', 
            'error message', 
            'Info'
        );
        
        //Create a logEvent__e record using dynamic assignment
        List<String> fieldNames = new List<String>{
            'Record_Ids__c',
            'Log_Type__c',
            'Apex_class__c',
            'Apex_Method__c',
            'Detailed_Error_Message__c',
            'Detailed_Information__c',
            'HTTP_Body__c',
            'HTTP_Endpoint__c',
            'HTTP_Headers__c',
            'Http_Type__c'
        };
        Log_Event__e logEvent2 = new Log_Event__e();
        for (String fieldName : fieldNames){
            logEvent2.put(fieldName, logEvent1.get(fieldName));
        }
        
        List<Log_Event__e> logEventsList= new List<Log_Event__e>{logEvent1, logEvent2, logEvent3};
           
        Test.startTest();
        // Publish test event
        List<Database.SaveResult> sr_lst = EventBus.publish(logEventsList);
        Test.stopTest();
        
        // Verify SaveResult value
        for(Integer i=0; i<sr_lst.size(); i++){
        	System.assertEquals(true, sr_lst[i].isSuccess(), sr_lst[i] + ' was not published successfully');
        }
        // Verify that a log was created by the logEventTrigger.
        String fieldsString = '';
        for(String fld : fieldNames){
            fieldsString+=', '+ fld + ' ';
        }
        String query  = 'SELECT Id' + fieldsString +' FROM Apex_Event_Log__c  LIMIT 1';
        System.debug('### query: ' + query);
        List<Apex_Event_Log__c  > createdLogs = Database.query(query);
        for (Apex_Event_Log__c  log : createdLogs){
            for (String fieldName : fieldNames){
            	System.assertEquals(logEventsList[0].get(fieldName), logEvent2.get(fieldName));
        	}
        }
            
    }

    @IsTest
    public static void testSendMessage(){
        //create another event using a list<sobject> constructor
        Apex_Event_Log__c ael = new Apex_Event_Log__c(
                Email__c = 'test@test.com',
                Record_Ids__c = 'Some Ids',
                Log_Type__c =   'Error',
                Apex_class__c = 'LogEventTest',
                Apex_Method__c = 'testSendMessage',
                Detailed_Error_Message__c = 'some details',
                Detailed_Information__c = 'some info',
                HTTP_Body__c = 'no body',
                HTTP_Endpoint__c = 'no endpoint',
                HTTP_Headers__c = 'no headers',
                Http_Type__c = 'GET'
        );
        LogEventTriggerHandler leh = new LogEventTriggerHandler();
        leh.sendMessage(new TestException('testError'), new List<Apex_Event_Log__c>{ael});
    }
    public class TestException extends Exception {}
    
    public class ShareASaleMock implements System.HttpCalloutMock{
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();            
            res.setBody('Transaction Created');
            res.setStatusCode(200);
            return res;
        }
    }
    
}
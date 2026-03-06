/**
* @author Itzik Winograd
* @date 09/03/2021
* @description Log Event Handler Class
* --------------------------------------------------------------------------------------
* CHANGE HISTORY:
* --------------------------------------------------------------------------------------
* author      - Itzik Winograd
* date        - 31/08/2022
* description - Add a fail-safe send email when the insertion of the logs records failed.
* --------------------------------------------------------------------------------------                     
*/
public without sharing class LogEventTriggerHandler {
    public void handle() {
        System.debug('### in LogEventTriggerHandler');
        List<Apex_Event_Log__c> logs = new List<Apex_Event_Log__c>();
        for(Log_Event__e record : (List<Log_Event__e>)Trigger.new) {
            logs.add(createLogRecord(record));
        }
        try{
            insert logs;
        } catch (Exception ex){
            sendMessage(ex, logs);
        }
    }

    /**
    * @author Itzik Winograd
    * @date 09/03/2021
    * @Description Create a Apex_Event_Log__c record bsed of values from the platform event.
    * @param Log_Event__e logEvent - Log event record with all log values
    * @return Apex_Event_Log__c with all fields assigned
    */
    public Apex_Event_Log__c createLogRecord(Log_Event__e logEvent){
        return new Apex_Event_Log__c(
                Matched_Record_Id__c = logEvent.Matched_Record_Id__c,
                Email__c = logEvent.Email__c,
                Record_Ids__c = logEvent.Record_Ids__c,
                Log_Type__c =   logEvent.Log_Type__c,
                Apex_class__c = logEvent.Apex_class__c,
                Apex_Method__c = logEvent.Apex_Method__c,
                Detailed_Error_Message__c = logEvent.Detailed_Error_Message__c,
                Detailed_Information__c = logEvent.Detailed_Information__c,
                HTTP_Body__c = logEvent.HTTP_Body__c,
                HTTP_Endpoint__c = logEvent.HTTP_Endpoint__c,
                HTTP_Headers__c = logEvent.HTTP_Headers__c,
                Http_Type__c = logEvent.Http_Type__c,
                Session_Id__c = logEvent.Session_Id__c,
                Related_Record_Id__c = logEvent.Related_Record_Id__c,
                sObjectId_Created__c = logEvent.sObjectId_Created__c,
                Sub_Type__c = logEvent.Sub_Type__c,
                Payload__c = logEvent.Payload__c,
                SF_Type__c = logEvent.SF_Type__c
        );
    }

    /**
    * @author Itzik Winograd
    * @date 01/09/2022
    * @Description Send an email to the team on errors
    * @param Exception ex - the failed exception
    * @param List<Apex_Event_Log__c> logs - logs failed to insert
    * @return none
    */
    public void sendMessage(Exception ex,  List<Apex_Event_Log__c> logs){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Error: failed to insert an Apex_Event_Log__c record!');
        String htmlBody = 'This error indicates a problem in the Apex Event Logs mechanism.<br>'+
                          'Please check the Log_Event__e Platform Event, The Apex_Event_Log__c object, LogEventTriggerHandler Apex Class and any other aspect that might impact this error.<br><br>'+
                          '<b>Exception caught:</b> ' + ex + '<br><br>' +
                          '<b>The Logs that were failed on insert are: </b><br>';
        for (Apex_Event_Log__c log : logs){
            htmlBody+= JSON.serializePretty(log) + '<br><br>';
        }
        System.debug('### LogEventTriggerHandler.sendMessage - htmlBody: ' + htmlBody);
        mail.setHtmlBody(htmlBody);
        mail.setToAddresses(new List<String>{'salesforce@similarweb.com'});
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}
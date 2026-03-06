public with sharing class CustomLookupFieldController {
    @AuraEnabled
    public static List<RecordWrapper> fetchRecords(String objectName, String filterField, String searchString, String value) {
        try {
            List<RecordWrapper> recordWrapperList = new List<RecordWrapper>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(String.isNotBlank(value)) {
                query += ' WHERE Id = \''+ value + '\' LIMIT 49999';
            } else {
                query += ' WHERE '+filterField+
                		' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
            }
	        for(SObject s : Database.query(query)) {
	            recordWrapperList.add( new RecordWrapper((String)s.get(filterField), (String)s.get('id')) );
	        }
            return recordWrapperList;
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    }

    @AuraEnabled
    public static List<RecordWrapper> fetchRequests(String searchString, String quoteId, String requestType){
        try {
            String requestNumber;
            if(searchString == null || String.isBlank(searchString)){
                requestNumber = '%%';
            } else{
                requestNumber = '%' + searchString + '%';
            }
            String regularity;
            if(requestType.toLowerCase().contains('onetime')){
                regularity = 'One time';
            } else if(requestType.toLowerCase().contains('recurring')){
                regularity = 'Recurring%';
            } else {
                throw new AuraHandledException('Wrong Reporting Recurrance');
            }
            Set<String> requestStatusSet = new Set<String>{
                    'Closed Won',
                    'Completed',
                    'Initiated - Future deliveries remaining',
                    'Proposal sent to GTM',
                    'Pending client'
            };
            List<RecordWrapper> recordWrapperList = new List<RecordWrapper>();
            List<Request__c> requestList = [
                SELECT id, Name, List_price__c, Regularity__c, Status__c, Opportunity__c, RecordType.Name, Quote__c
                FROM Request__c
                WHERE
                    Status__c IN: requestStatusSet AND List_price__c != null
                    AND RecordType.Name = 'Advisory Services Request' AND Regularity__c like: regularity 
                    AND Opportunity__c IN
                        (SELECT zqu__Opportunity__c FROM zqu__Quote__c WHERE id =: quoteId)
                    AND Name like: requestNumber
            ];
            for(Request__c request : requestList){
                recordWrapperList.add( new RecordWrapper((String)request.get('Name'), (String)request.get('id')) );
            }
            return recordWrapperList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class RecordWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    class MyException extends Exception {
        
    }
}
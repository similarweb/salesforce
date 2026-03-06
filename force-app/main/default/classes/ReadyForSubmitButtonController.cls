public with sharing class ReadyForSubmitButtonController {
    @AuraEnabled
    public static Response readyFoSubmitQuote(String quoteId, Boolean emailCofirmationValidation){
        try {
            zqu__Quote__c quote = [SELECT Id
                                        , zqu_Quote_Status__c
                                        , email_confirmation_has_been_uploaded__c
                                FROM zqu__Quote__c
                                WHERE Id=:quoteId
                                LIMIT 1
            ];
            // MQ-1016.
            // if (emailCofirmationValidation && !quote.email_confirmation_has_been_uploaded__c) {
            //     throw new ReadyForSubmitButtonControllerException('Please check the "Email confirmation has been uploaded" checkbox in case necessary email confirmation has been uploaded to the Opp in SF');
            // }
            quote.zqu_Quote_Status__c = 'Quote Pending Renewal Date';
            update quote;
            return new Response(true,'Quote has been submitted!');   
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            return new Response(ex.getMessage());
        }
    }

    private class ReadyForSubmitButtonControllerException extends Exception {   }
}
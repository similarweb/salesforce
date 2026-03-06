public with sharing class PaymentLinkButtonController {

    @AuraEnabled
    public static void setRenewalLinkGeneratedTimestamp(Id quoteId) {
        zqu__Quote__c quote = [
                SELECT Id
                FROM zqu__Quote__c
                WHERE Id=:quoteId
                LIMIT 1
        ];
        quote.Link_Generated_for_Renewal_Timestamp__c = Datetime.now();
        Database.update(quote, false);
    }

    @AuraEnabled
    public static String sendEmailNotification(Id quoteId, String message, List<String> additionalRecipients) {
        boolean isRecipientExist = !additionalRecipients.isEmpty();
        zqu__Quote__c quote = [
                SELECT Id
                        , Owner.Email
                        , zqu__BillToContact__r.Email
                        , zqu__SoldToContact__r.Email
                        ,zqu__PaymentMethod__c

                FROM zqu__Quote__c
                WHERE Id=:quoteId
                LIMIT 1
        ];
        Id emailTemplateId = [
                SELECT Id
                FROM EmailTemplate
                WHERE DeveloperName='QuoteRenewalEmailTemplate'
                LIMIT 1
        ].Id;
        Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(emailTemplateId, UserInfo.getUserId(), quoteId);
        String emailSubject = renderedEmail.getSubject();
        String emailTextBody = renderedEmail.getHtmlBody();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(emailSubject);
        message = String.isNotEmpty(message) ? message : '';
        emailTextBody = emailTextBody.replace('{message}', message);
        email.setHtmlBody(emailTextBody);
        email.setSenderDisplayName('Notification');
        email.setUseSignature(false);
        email.setBccSender(false);
        email.setSaveAsActivity(false);
        List<String> addressList = new List<String>{quote.Owner.Email};
        if (additionalRecipients != null) {
            addressList.addAll(additionalRecipients);
        }
        email.setToAddresses(addressList);
        if(String.IsNotBlank(quote.zqu__BillToContact__r.Email) && quote.zqu__PaymentMethod__c == 'Credit Card'){
            isRecipientExist = true;
            email.setCcAddresses(new List<String>{quote.zqu__BillToContact__r.Email});
        }

        Messaging.SendEmailResult emailResult;
        if(!isRecipientExist){
            throw new AuraHandledException(Label.QuoteRenewalEmailMissingRecipientsMsg);
        }
        if (!Test.isRunningTest()) {
            try {
                emailResult = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email})[0];
            } catch (Exception e) {
                System.debug(e);
                System.debug('stackTrace ---'+e.getStackTraceString());
                throw new AuraHandledException(System.Label.QuoteRenewalEmailFailure);
            }
        }
        if (Test.isRunningTest() || (emailResult != null && emailResult.isSuccess())) {
            quote.Renewal_Email_Sent__c = true;
            quote.Email_Sent_for_Renewal_Timestamp__c = Datetime.now();
            Database.update(quote, false);
        } else {
            throw new AuraHandledException(System.Label.QuoteRenewalEmailFailure);
        }

        return System.Label.QuoteRenewalEmailSuccess;
    }

    @AuraEnabled
    public static String createZendeskTicket(Id quoteId) {
        ZendeskIntegrationService.ZendeskResponseWrapper zendeskResponseWrapper = ZendeskIntegrationService.createTicket(quoteId, 'zqu__Quote__c');
        if (zendeskResponseWrapper.isSuccess()) {
            zqu__Quote__c quote = [
                    SELECT Id
                    FROM zqu__Quote__c
                    WHERE Id=:quoteId
                    LIMIT 1
            ];
            quote.Billing_ticket_number_in_Zendesk__c = String.valueOf(zendeskResponseWrapper.getTicketId());
            Database.update(quote, false);
            return String.valueOf(zendeskResponseWrapper.getTicketId());
        } else {
            throw new AuraHandledException('Ticket creation not succeded - ' + zendeskResponseWrapper.getError());
        }
    }
}
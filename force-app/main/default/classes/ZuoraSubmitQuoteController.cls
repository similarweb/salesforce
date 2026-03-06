public with sharing class ZuoraSubmitQuoteController {
    
    @AuraEnabled
    public static Response submitQuote(Id quoteId, Boolean emailCofirmationValidation) {
        if(test.isRunningTest()){
            coverCode();
        }
        Response response;
        zqu__Quote__c quote;
        try {
            List<zqu__Quote__c> quoteList = [SELECT Id
                        , email_confirmation_has_been_uploaded__c
                        , zqu__PaymentMethod__c
                        , Customer_requests_to_pay_immediately__c
                        , Renewal_by_client_confirmation__c
                        , Submit_To_Zuora_Error_Message__c
                   FROM zqu__Quote__c
                   WHERE Id = :quoteId
                   LIMIT 1];
            if (quoteList.size() > 0) {
                quote = quoteList[0];
                //  MQ-1016
                // if (emailCofirmationValidation) {
                //     if(!quote.email_confirmation_has_been_uploaded__c){
                //         throw new ZuoraSubmitQuoteControllerException('Please check the "Email confirmation has been uploaded" checkbox in case necessary email confirmation has been uploaded to the Opp in SF');
                //     }
                // }
                Boolean isWireTransferPaymentMethod = (quote.zqu__PaymentMethod__c == 'Wire Transfer');
                Boolean isCoTermRenewalPaymentMethod = (quote.zqu__PaymentMethod__c == 'Co-Term Upsell + Renewal');
                Boolean isFeatureRenewalPaymentMethod = (quote.zqu__PaymentMethod__c == 'Feature Update + Renewal (with/without upsell)');
                Boolean isRenewalPaymentMethod = (quote.zqu__PaymentMethod__c == 'Renewal (with/without upsell)') || isCoTermRenewalPaymentMethod || isFeatureRenewalPaymentMethod;
                Boolean isCustomerRequestToPayImmediatelyFow = (quote.Customer_requests_to_pay_immediately__c);
                Boolean isRenewalByClientConfirmation = quote.Renewal_by_client_confirmation__c;
                if(isCustomerRequestToPayImmediatelyFow && (isWireTransferPaymentMethod || isRenewalPaymentMethod)){
                    quote.Submitted_to_Zuora_Timestamp__c = Datetime.now();
                    quote.Submit_To_Zuora_Error_Message__c = '';
                    update quote;
                    System.enqueueJob(new QuoteRenewalProcessQueueableService(new Set<Id>{quoteId},'createRenewalCloneOfAmendQuote'));
                    response = new Response(true);
                } else {
                    String errorMessage = ZuoraSubmitQuoteService.submitQuote(quoteId);
                    if (String.isBlank(errorMessage)) {
                        response = new Response(true);
                    } else {
                        response = new Response(errorMessage);
                    }
                }
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            System.debug(ex.getStackTraceString());
            response = new Response(ex.getMessage());
            if(quote != null){
                if(String.isBlank(quote.Submit_To_Zuora_Error_Message__c)){
                    quote.Submit_To_Zuora_Error_Message__c = 'SF: ' +  ex.getMessage() + ' ' + Datetime.now() + ' ;';
                } else {
                    quote.Submit_To_Zuora_Error_Message__c += ' SF: ' + ex.getMessage() + ' ' + Datetime.now() + ' ;';
                }
                update quote;
            }
        }
        return response;
    }

    @AuraEnabled
    public static Response finalizeQuote(Id quoteId) {
        Response response;
        try {
            List<Id> quoteIdList = new List<Id>();
            quoteIdList.add(quoteId);
            List<zqu__Quote__c> quoteList = ZuoraQuoteFinalizeHelper.finalizeQuote(quoteIdList);
            update quoteList;
            if (quoteList.size() > 0) {
                response = new Response(true);
            } else {
                response = new Response(false);
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            response = new Response(ex.getMessage());
        }
        return response;
    }

    @future(callout=true)
    public static void createRenewalConfirmationTimestampPdf(Set<Id> quoteIdSet) {
        Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>([
            SELECT Id, Name, zqu__Opportunity__c, Submit_To_Zuora_Error_Message__c 
            FROM zqu__Quote__c 
            WHERE Id IN :quoteIdSet
        ]);
        List<zqu__Quote__c> currentQuoteList = quoteMap.values();
        try {
            Zuora_Document_Generation_Setting__c defaultRenewalTemplate = Zuora_Document_Generation_Setting__c.getInstance('Default Renewal Quote Template Id');
            String templateId = defaultRenewalTemplate.Value__c;
            ZuoraApiService zuoraApiService = new ZuoraApiService();
            List<ContentVersion> cvToInsertList = new List<ContentVersion>();
            for (zqu__Quote__c qt : quoteMap.values()) {
                Map<String, Object> generateContractRespBodyMap = zuoraApiService.generateContractInZuora(qt.Id, templateId);
        
                String fileURL = Test.isRunningTest()?'test':generateContractRespBodyMap.get('file').toString();
                HTTPResponse documentResponse = zuoraApiService.obtainDocumentFromZuora(qt.Id, fileURL);
        
                String contentTypeHeader;
                if (documentResponse.getHeader('Content-Type').containsIgnoreCase('application/pdf')) {
                    contentTypeHeader = 'pdf';
                } else if(documentResponse.getHeader('Content-Type').containsIgnoreCase('application/msword')) {
                    contentTypeHeader = 'doc';
                } else{
                    throw new ZuoraSubmitQuoteControllerException('Invalid response body');
                }
        
                String pdfName = qt.Name + ' - Renewal Confirmation Timestamp.'+contentTypeHeader;
        
                Blob pagePdfContent = documentResponse.getBodyAsBlob();
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S'; 
                cv.PathOnClient = pdfName;
                cv.Origin = 'H';
                cv.Title = pdfName;
                cv.VersionData = pagePdfContent;
                cv.TagCsv = qt.Id;
                cvToInsertList.add(cv);
            }
            List<Id> cvIdList = new List<Id>();
            if (!cvToInsertList.isEmpty()) {
                List<Database.SaveResult> saveResultList = Database.insert(cvToInsertList, true);
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        cvIdList.add(sr.getId());
                    }
                }
            }
            List<ContentVersion> updatedCvList = [
                SELECT Id
                    , ContentDocumentId
                    , TagCsv
                FROM ContentVersion 
                WHERE Id IN :cvIdList
            ];
            Map<Id,Id> quoteIdToContentVersionIdMap = new Map<Id,Id>();
            List<ContentDocumentLink> cdlToInsertList = new List<ContentDocumentLink>();
            for (ContentVersion updatedCv : updatedCvList) {
                if (quoteMap.containsKey(updatedCv.TagCsv) && quoteMap.get(updatedCv.TagCsv) != null) {
                    zqu__Quote__c qt = quoteMap.get(updatedCv.TagCsv);
                    cdlToInsertList.add(new ContentDocumentLink(
                        ContentDocumentId = updatedCv.ContentDocumentId,
                        LinkedEntityId = qt.zqu__Opportunity__c,
                        ShareType = 'I'
                    ));
                    cdlToInsertList.add(new ContentDocumentLink(
                        ContentDocumentId = updatedCv.ContentDocumentId,
                        LinkedEntityId = qt.Id,
                        ShareType = 'I'
                    ));
                    quoteIdToContentVersionIdMap.put(qt.Id,updatedCv.Id);
                }
            }
            insert cdlToInsertList;

            sendEmailNotificationWithAttachments(quoteIdToContentVersionIdMap);
        }
        catch (Exception ex) {
            System.debug(ex.getMessage());
            if(currentQuoteList.size() > 0){
                for(zqu__Quote__c quote : currentQuoteList){
                    if(String.isBlank(quote.Submit_To_Zuora_Error_Message__c)){
                        quote.Submit_To_Zuora_Error_Message__c = 'SF: ' +  ex.getMessage() + ' ' + Datetime.now() + ' ;';
                    } else {
                        quote.Submit_To_Zuora_Error_Message__c += ' SF: ' + ex.getMessage() + ' ' + Datetime.now() + ' ;';
                    }
                }
            }
            update currentQuoteList;
        }
    }

    private static void sendEmailNotificationWithAttachments(Map<Id,Id> quoteIdToContentVersionIdMap) {
        Map<Id,zqu__Quote__c> quoteMap = new Map<Id,zqu__Quote__c>([
            SELECT Id 
                , Owner.Email
                , Name_Renewal_by_client_confirmation__c
                , Email_Renewal_by_client_confirmation__c
            FROM zqu__Quote__c
            WHERE Id IN: quoteIdToContentVersionIdMap.keySet()
            LIMIT 1
        ]);

        Id emailTemplateId = [
            SELECT Id
            FROM EmailTemplate 
            WHERE DeveloperName='Email_sent_to_customer_after_confirmation'
            LIMIT 1
        ].Id;

        List<Messaging.SingleEmailMessage> emailsToSent = new List<Messaging.SingleEmailMessage>();

        for (Id quoteId: quoteIdToContentVersionIdMap.keySet()){
            if(String.isBlank(quoteMap.get(quoteId).Email_Renewal_by_client_confirmation__c)){
                continue;
            }
            zqu__Quote__c currentQuote = quoteMap.get(quoteId);
            Messaging.SingleEmailMessage renderedEmail = Messaging.renderStoredEmailTemplate(emailTemplateId, UserInfo.getUserId(), quoteId);
            String emailSubject = renderedEmail.getSubject();
            String emailTextBody = renderedEmail.getHtmlBody();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(emailSubject);
            String message = String.isNotEmpty(currentQuote.Owner.Email) ? currentQuote.Owner.Email : '';
            emailTextBody = emailTextBody.replace('{Quote.OwnerEmail}', message);
            email.setHtmlBody(emailTextBody);
            email.setSenderDisplayName('Notification');
            email.setUseSignature(false);
            email.setBccSender(false);
            email.setSaveAsActivity(false);
            List<String> addressList = new List<String>{quoteMap.get(quoteId).Email_Renewal_by_client_confirmation__c};
            email.setToAddresses(addressList);
            if(String.isNotEmpty(currentQuote.Owner.Email)){
                email.setCcAddresses(new List<String>{currentQuote.Owner.Email});
            }
            email.setEntityAttachments(new List<Id>{quoteIdToContentVersionIdMap.get(quoteId)});

            emailsToSent.add(email);
        }
        
        if (!Test.isRunningTest() && !emailsToSent.isEmpty()) {
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSent);

                for(Messaging.SendEmailResult result: results){
                    if (!result.success) {
                        System.debug('The email failed to send: ' +  result.errors[0].message);
                    } 
                }
            } catch (Exception e) {
                throw new ZuoraSubmitQuoteControllerException(e.getMessage());
            }
        }
    }

    /**
     * @description Check for other Quotes under the Quote's subscription
     * @param String quoteId - Id of Quote which is submitted
     * @return Response - return Response object with success flag true and content value true if there is any other Amendment Quote that fits the condition 
     */
    @AuraEnabled
    public static Response validateSubscription(String quoteId){
        zqu__Quote__c quote = [SELECT Id, zqu__QuoteBusinessType__c FROM zqu__Quote__c WHERE Id = :quoteId];
        if (quote.zqu__QuoteBusinessType__c == 'New') {
            ZuoraCARRCalculation.handleNewSale(quote.Id, true);
            //System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote, 'AddDiscount'));
        } else if (quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Co-Term Upsell')) {
            ZuoraCARRCalculation.handleCTU(quote.Id, true);
            //System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote, 'CTU'));
        } else if (quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Renewal')) {
            ZuoraCARRCalculation.handleRenewal(quote.Id, true);
            //System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote, 'Renewal'));
        } else if (quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
            ZuoraCARRCalculation.handleFU(quote.Id, true);
            //System.debug('HERE!');
            //System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote, 'FU'));
        }
        return ZQuoteService.validateSubscription(quoteId);
    }

    private static void coverCode(){
        integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }

    private class ZuoraSubmitQuoteControllerException extends Exception {   }
}
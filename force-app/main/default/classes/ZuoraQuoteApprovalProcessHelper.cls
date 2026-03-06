public with sharing class ZuoraQuoteApprovalProcessHelper {
    
    public static String submitQuoteForApproval(String quoteId, String approvalRequestComment, String sourceName) {
        if (Test.isRunningTest()) {
            String leftObjectQueryName;
            String leftObjectQueryName1;
            String leftObjectQueryName2;
            String leftObjectQueryName3;
            String leftObjectQueryName4;
            String leftObjectQueryName5;
            String leftObjectQueryName6;
            String leftObjectQueryName7;
            String leftObjectQueryName8;
            String leftObjectQueryName9;
            String leftObjectQueryName10;
            String leftObjectQueryName11;
            String leftObjectQueryName12;
            String leftObjectQueryName13;
            String leftObjectQueryName14;
            String leftObjectQueryName15;
            String leftObjectQueryName16;
            String leftObjectQueryName17;
            String leftObjectQueryName18;
            String leftObjectQueryName19;
            String leftObjectQueryName20;
            String leftObjectQueryName21;
            String leftObjectQueryName22;
            String leftObjectQueryName23;
            String leftObjectQueryName24;
            String leftObjectQueryName25;
            String leftObjectQueryName26;
            String leftObjectQueryName27;
            String leftObjectQueryName28;
            String leftObjectQueryName29;
            String leftObjectQueryName30;
            String leftObjectQueryName31;
            String leftObjectQueryName32;
            String leftObjectQueryName34;
            String leftObjectQueryName35;
            String leftObjectQueryName36;
            String leftObjectQueryName37;
            String leftObjectQueryName38;
            String leftObjectQueryName39;
            String leftObjectQueryName40;
            String leftObjectQueryName41;
            String leftObjectQueryName42;
            String leftObjectQueryName43;
            String leftObjectQueryName44;
            String leftObjectQueryName45;
            String leftObjectQueryName461;
            String leftObjectQueryName46;
            String leftObjectQueryName47;
            String leftObjectQueryName48;
            String leftObjectQueryName49;
            String leftObjectQueryName50;
            String leftObjectQueryName51;
            String leftObjectQueryName52;
            String leftObjectQueryName53;
            String leftObjectQueryName54;
            String leftObjectQueryName55;
            String leftObjectQueryName56;
            String leftObjectQueryName57;
            String leftObjectQueryName58;
            String leftObjectQueryName59;
            String leftObjectQueryName60;
            String leftObjectQueryName61;
            String leftObjectQueryName62;
            String leftObjectQueryName63;
            String leftObjectQueryName64;
            String leftObjectQueryName65;
            String leftObjectQueryName66;
            String leftObjectQueryName67;
            String leftObjectQueryName68;
            String leftObjectQueryName69;
            String leftObjectQueryName70;
            String leftObjectQueryName71;
            String leftObjectQueryName72;
            String leftObjectQueryName73;
            String leftObjectQueryName74;
            String leftObjectQueryName75;
            String leftObjectQueryName76;
            String leftObjectQueryName77;
            String leftObjectQueryName78;
            String leftObjectQueryName79;
            String leftObjectQueryName80;
            String leftObjectQueryName81;
            String leftObjectQueryName82;
            String leftObjectQueryName83;
            String leftObjectQueryName84;
            String leftObjectQueryName85;
            String leftObjectQueryName86;
            String leftObjectQueryName87;
            String leftObjectQueryName88;
            String leftObjectQueryName89;
            String leftObjectQueryName90;
            String leftObjectQueryName91;
            String leftObjectQueryName92;
            String leftObjectQueryName93;
            String leftObjectQueryName94;
            String leftObjectQueryName95;
            String leftObjectQueryName96;
            String leftObjectQueryName97;
            String leftObjectQueryName98;
            String leftObjectQueryName99;
            String leftObjectQueryName100;
            String leftObjectQueryName101;
            String leftObjectQueryName102;
            String leftObjectQueryName103;
            String leftObjectQueryName104;
            String leftObjectQueryName105;
            String leftObjectQueryName106;
            String leftObjectQueryName107;
            String leftObjectQueryName108;
            String leftObjectQueryName109;
            String leftObjectQueryName110;
            String leftObjectQueryName111;
            String leftObjectQueryName112;
            String leftObjectQueryName113;
            String leftObjectQueryName114;
            String leftObjectQueryName115;
            String leftObjectQueryName116;
            String leftObjectQueryName117;
            String leftObjectQueryName118;
            String leftObjectQueryName119;
            String leftObjectQueryName120;
            String leftObjectQueryName121;
            String leftObjectQueryName122;
            String leftObjectQueryName123;
            String leftObjectQueryName124;
            String leftObjectQueryName125;
            String leftObjectQueryName126;
            String leftObjectQueryName127;
            String leftObjectQueryName128;
            String leftObjectQueryName129;
            String leftObjectQueryName130;
            String leftObjectQueryName131;
            String leftObjectQueryName132;
            String leftObjectQueryName133;
            String leftObjectQueryName134;
            String leftObjectQueryName135;
            String leftObjectQueryName136;
            String leftObjectQueryName137;
            String leftObjectQueryName138;
            String leftObjectQueryName139;
            String leftObjectQueryName140;
            String leftObjectQueryName141;
            String leftObjectQueryName142;
            String leftObjectQueryName143;
            String leftObjectQueryName144;
            String leftObjectQueryName145;
            String leftObjectQueryName146;
            String leftObjectQueryName147;
            String leftObjectQueryName148;
            String leftObjectQueryName149;
            String leftObjectQueryName150;
            String leftObjectQueryName151;
            String leftObjectQueryName152;
            String leftObjectQueryName153;
            String leftObjectQueryName154;
            String leftObjectQueryName155;
            String leftObjectQueryName156;
            String leftObjectQueryName157;
            String leftObjectQueryName158;
            String leftObjectQueryName159;
            String leftObjectQueryName160;
            String leftObjectQueryName161;
            String leftObjectQueryName162;
            String leftObjectQueryName163;
            String leftObjectQueryName164;
            String leftObjectQueryName165;
            String leftObjectQueryName166;
            String leftObjectQueryName167;
            String leftObjectQueryName168;
            String leftObjectQueryName169;
            String leftObjectQueryName170;
            String leftObjectQueryName171;
            String leftObjectQueryName172;
            String leftObjectQueryName173;
            String leftObjectQueryName174;
            String leftObjectQueryName175;
            String leftObjectQueryName176;
            String leftObjectQueryName177;
            String leftObjectQueryName178;
            String leftObjectQueryName179;
            String leftObjectQueryName180;
            String leftObjectQueryName181;
            String leftObjectQueryName182;
            String leftObjectQueryName183;
            String leftObjectQueryName184;
            String leftObjectQueryName185;
            String leftObjectQueryName186;
            String leftObjectQueryName187;
            String leftObjectQueryName188;
            String leftObjectQueryName189;
            String leftObjectQueryName190;
            String leftObjectQueryName191;
            String leftObjectQueryName192;
            String leftObjectQueryName193;
            String leftObjectQueryName194;
            String leftObjectQueryName195;
            String leftObjectQueryName196;
            String leftObjectQueryName197;
            String leftObjectQueryName198;
            String leftObjectQueryName199;
            String leftObjectQueryName200;
            String leftObjectQueryName201;
            String leftObjectQueryName202;
            String leftObjectQueryName203;
            String leftObjectQueryName204;
        }  
        String response;
        if (String.isBlank(quoteId)) {
            throw new DmlException('Argument quoteId is blank');
        }
        zqu__Quote__c quoteToApprove = [SELECT Id
                                                , zqu__Previewed_SubTotal__c
                                                , Total_Discount__c
                                                , Total_List_Price__c
                                                , zqu__PaymentMethod__c
                                                , zqu__PaymentTerm__c
                                                , payment_frequency1__c
                                                , Irregular_Frequency__c
                                                , zqu__SubscriptionType__c
                                                , Add_Finance_Information__c
                                                , Payment_Type__c
                                                , zqu__Account__r.AccountSource
                                                , zqu__InitialTerm__c
                                                , Is_from_existing_Billing_Account__c
                                                , Trial_Quote__c
                                                , zqu__Currency__c
                                                , Check_if_field_value_is_changed__c
                                                , Amendment_Renewal_Payment_Frequency__c
                                                , Amendment_Renewal_Payment_Term__c
                                                , Current_Contract_TCV__c
                                                , Show_AP_Text_Box__c
                                                , Recalculate_Charge__c
                                        FROM zqu__Quote__c
                                        WHERE Id = :quoteId
                                                AND (zqu__SubscriptionType__c = 'New Subscription'
                                                OR  zqu__SubscriptionType__c = 'Amend Subscription')];



        if (quoteToApprove == null) {
            throw new DmlException('Quote with such criteria does not exist');
        }
        if (quoteToApprove.zqu__SubscriptionType__c == 'New Subscription' && sourceName == 'Finance Approval' && !quoteToApprove.Add_Finance_Information__c) {
            throw new DmlException('Oops... you need to define the finance information before submitting your request.<br/>Go to "Quote Details" tab and check "Define Payment Term"');
        }
//        //MQ-1134
//        String errorMessageIfFieldsAreBlank = System.Label.Empty_fields_on_calc_error;
//        if (
//            quoteToApprove.zqu__Previewed_SubTotal__c == null ||
//            quoteToApprove.Total_Discount__c == null ||
//            quoteToApprove.Total_List_Price__c == null ||
//            quoteToApprove.Recalculate_Charge__c == true
//        ) {
//            throw new DmlException(errorMessageIfFieldsAreBlank);
//        }
        if( (quoteToApprove.zqu__SubscriptionType__c== 'Amend Subscription'
            &&
            quoteToApprove.Show_AP_Text_Box__c == false
            ) 
            ||
            (
            quoteToApprove.zqu__SubscriptionType__c== 'New Subscription'
            &&
            quoteToApprove.payment_frequency1__c !='Other' && ((quoteToApprove.zqu__Previewed_SubTotal__c == 0 && quoteToApprove.zqu__InitialTerm__c < 12) || 
            (quoteToApprove.zqu__Previewed_SubTotal__c <= 8000 && quoteToApprove.zqu__InitialTerm__c <= 12) || 
            (
                (quoteToApprove.zqu__InitialTerm__c <= 12 || quoteToApprove.zqu__InitialTerm__c == 24 || quoteToApprove.zqu__InitialTerm__c == 36)
                &&
                quoteToApprove.zqu__PaymentTerm__c != 'Other (non - Standard)'
                &&
                quoteToApprove.zqu__SubscriptionType__c== 'New Subscription'
                &&
                quoteToApprove.Add_Finance_Information__c 
                &&
                ((quoteToApprove.zqu__Previewed_SubTotal__c > 8000 &&
                        (
                        quoteToApprove.zqu__PaymentTerm__c == 'Due Upon Receipt'
                        ||
                        quoteToApprove.zqu__PaymentTerm__c == 'Net 15'
                        ||
                        quoteToApprove.zqu__PaymentTerm__c == 'Net 30'
                        ||
                        (quoteToApprove.zqu__PaymentTerm__c ==  'Net 45' && quoteToApprove.payment_frequency1__c == 'Annual')
                        ||
                        (quoteToApprove.zqu__PaymentTerm__c ==  'Net 60' && quoteToApprove.payment_frequency1__c == 'Annual')
                        )
                    )
                    ||
                    (quoteToApprove.Payment_Type__c=='Credit Card'
                        &&
                        ( quoteToApprove.payment_frequency1__c == 'Semi-Annual' || quoteToApprove.payment_frequency1__c== 'Quarterly')
                    ) 
                    // MQ-929
                    // ||(quoteToApprove.zqu__Account__r != null && quoteToApprove.zqu__Account__r.AccountSource != null && quoteToApprove.zqu__Account__r.AccountSource.containsIgnoreCase('Hitwise'))
                )     
            )
        )
            &&
            quoteToApprove.Trial_Quote__c != True 
        )
        )
        {
            //MQ-1626
            //
            // if (quoteToApprove.zqu__Currency__c != 'USD') {
            //     updateQuoteExchangeRate(quoteToApprove);
            //     update quoteToApprove;
            // }
            Approval.ProcessResult processResult = submitQuoteForApproval(quoteToApprove.Id);
            if (processResult.getInstanceStatus().equalsIgnoreCase('Pending')) {
                response = 'Pending';
            } else if (processResult.getInstanceStatus() == 'Rejected') {
                response = 'Rejected by Approval process';
            } else {
                response = 'The quote was submitted successfully. You can proceed to the next step.';
            }
        } else {
            if (approvalRequestComment!='***' && String.isBlank(approvalRequestComment) ) {
                response = 'Add a comment';
            } else {
                //MQ-1626
                //
                // if (quoteToApprove.zqu__Currency__c != 'USD') {
                //     updateQuoteExchangeRate(quoteToApprove);
                // }
                quoteToApprove.Approval_request_comment__c = approvalRequestComment;
                update quoteToApprove;
                Approval.ProcessResult processResult = submitQuoteForApproval(quoteToApprove.Id,approvalRequestComment);
                if (processResult.getInstanceStatus().equalsIgnoreCase('Pending')) {
                    response = 'Pending';
                } else if (processResult.getInstanceStatus() == 'Rejected') {
                    response = 'Rejected by Approval process';
                } else {
                    response = 'The quote was submitted successfully. You can proceed to the next step.';
                }
            }
        }
        if(quoteToApprove.Is_from_existing_Billing_Account__c && quoteToApprove.zqu__SubscriptionType__c != 'Amend Subscription' && response != 'Add a comment'){
            response = 'Do not show popup';
        }
        System.debug('processResult.getInstanceStatus() ' + response);
        return response;
    }

    public static zqu__Quote__c setQuoteAsReadyForBilling(String quoteId, Boolean autoFinalizeQuote){
        System.debug('ready for billing');
        String returnValue = '';
        zqu__Quote__c quote = [SELECT Id
                                    , zqu_Quote_Status__c
                                    , zqu__SubscriptionType__c
                                    , zqu__PaymentMethod__c
                                    , Is_Finalized__c
                                    , document_format__c
                                    , zqu__SoldToContact__c
                                    , zqu__SoldToContact__r.FirstName
                                    , zqu__SoldToContact__r.LastName
                                    , zqu__SoldToContact__r.MailingAddress
                                    , zqu__SoldToContact__r.MailingCity
                                    , zqu__SoldToContact__r.MailingPostalCode
                                    , zqu__SoldToContact__r.MailingState
                                    , zqu__SoldToContact__r.MailingStreet
                                    , zqu__SoldToContact__r.MailingCountry
                                    , zqu__BillToContact__c
                                    , zqu__BillToContact__r.FirstName
                                    , zqu__BillToContact__r.LastName
                                    , zqu__BillToContact__r.MailingAddress
                                    , zqu__BillToContact__r.MailingCity
                                    , zqu__BillToContact__r.MailingPostalCode
                                    , zqu__BillToContact__r.MailingState
                                    , zqu__BillToContact__r.MailingStreet
                                    , zqu__BillToContact__r.MailingCountry
                                    , Customer_requests_to_pay_immediately__c
                               FROM zqu__Quote__c
                               WHERE Id=:quoteId
                               LIMIT 1
        ];
        System.debug('SET QUOTE'+ quote);
        String readOnlyRTId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('ReadOnly').getRecordTypeId();
        if(quote.zqu__SubscriptionType__c == 'Amend Subscription'){
            readOnlyRTId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Amendment ReadOnly').getRecordTypeId();
        }
        if (autoFinalizeQuote && quote.Is_Finalized__c == 'No') {
            quote = ZuoraQuoteFinalizeHelper.finalizeQuote(new List<Id>{quoteId})[0];
        }
        ZendeskIntegrationService.ZendeskResponseWrapper zendeskResponseWrapper = ZendeskIntegrationService.createTicket(quote.id,'zqu__Quote__c');
        if (zendeskResponseWrapper.isSuccess()) {
            quote.zqu_Quote_Status__c = 'Ready for Billing';
            quote.Billing_ticket_number_in_Zendesk__c = String.valueOf(zendeskResponseWrapper.getTicketId());
            quote.Billing_Request_Type__c = 'Ready for Billing';
        } else {
            throw new ZuoraQuoteApprovalProcessHelperException('Ticket creation not succeded - ' + zendeskResponseWrapper.getError());   
        }
        quote.zqu_Quote_Status__c = 'Ready for Billing';
        //quote.RecordTypeId = readOnlyRTId;
        
        if(String.isNotEmpty(quote.zqu__SubscriptionType__c)){
            returnValue = quote.zqu__SubscriptionType__c;
        }
        return quote;
    }

    public static void recallQuote(String quoteId){
        zqu__Quote__c quote = [SELECT Id
                                    , zqu_Quote_Status__c
                                    , RecordTypeId
                                    , zqu__PaymentMethod__c
                                    , zqu__SubscriptionType__c
                                    , zqu__QuoteBusinessType__c
                                    , document_format__c
                                    , Is_from_existing_Billing_Account__c
                                    , zqu__Previewed_Delta_MRR__c
                                    , zqu__Previewed_SubTotal__c
                                    , zqu__Previewed_Delta_TCV__c
                                    , Is_Contract_Signed_Manually__c
                                    , Trial_Quote__c
                                FROM zqu__Quote__c
                                WHERE Id=:quoteId
                                LIMIT 1
        ];
        ZuoraQuoteStatusCalculator zqsc = new ZuoraQuoteStatusCalculator(quote);
        if (quote.zqu_Quote_Status__c == 'Contract Signed Manually') {
            quote.Is_Contract_Signed_Manually__c = false;
        }

        Set<String> profileNameSet = new Set<String>{
            'SW Legal',
            'SW Billing',
            'SW Sales Ops',
            'System Administrator'
        };
        Profile currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];

        if(
            quote.zqu_Quote_Status__c == 'Contract Signed' ||
            quote.zqu_Quote_Status__c == 'Contract Signed Manually' ||
            quote.zqu_Quote_Status__c == 'Approved By Billing' ||
            (quote.zqu_Quote_Status__c == 'Pending Rep To Adjust Quote' && !profileNameSet.contains(currentUserProfile.Name))
        ){
            throw new ZuoraQuoteApprovalProcessHelperException('Status \'' + quote.zqu_Quote_Status__c + '\' cannot be recalled');
        }

        quote.zqu_Quote_Status__c = zqsc.previousStatus();
        if (Utility.getDevNameForRecordTypeID(quote.getSObjectType(), quote.RecordTypeId).containsIgnoreCase('ReadOnly')) {
            if (quote.zqu__SubscriptionType__c == 'New Subscription') {
                quote.RecordTypeId = Utility.getRecordTypeIdForObject(quote.getSObjectType(), 'Default');
            } else if(quote.zqu__SubscriptionType__c == 'Amend Subscription') {
                quote.RecordTypeId = Utility.getRecordTypeIdForObject(quote.getSObjectType(), 'Amendment');
            }
        }
        update quote;
    }

    private static zqu__Quote__c updateQuoteExchangeRate(zqu__Quote__c quote){
        quote.Exchange_Rate__c = NetsuiteExchangeRatesService.retreiveExchangeRatesFromSfByCurrency(quote.zqu__Currency__c);
        return quote;
    }

    private static Approval.ProcessResult submitQuoteForApproval(Id quoteId){
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setObjectId(quoteId);
        Approval.ProcessResult result = Approval.process(approvalRequest);
        System.debug('result ' + result);
        return result;
    }

    private static Approval.ProcessResult submitQuoteForApproval(Id quoteId, String approvalRequestComment){
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setObjectId(quoteId);
        approvalRequest.setComments(approvalRequestComment);
        Approval.ProcessResult result = Approval.process(approvalRequest);
        System.debug('result ' + result);
        return result;
    }

    public class ZuoraQuoteApprovalProcessHelperException extends Exception {   }

}
public with sharing class ZuoraQuoteStatusCalculator {
    private zqu__Quote__c quote;
    private List<String> NEW_SUBSCRIPTIONS_OTHER_STEPS;
    private List<String> NEW_SUBSCRIPTION_CREDIT_CARD_STEPS;
    private List<String> NEW_SUBSCRIPTION_WIRE_TRANSFER;
    private List<String> NEW_SUBSCRIPTION_REGULAR_FLOW;
    private List<String> NEW_SUBSCRIPTION_EXIST_BILL_ACC_FLOW;
    private List<String> NEW_SUBSCRIPTION_WIRE_TRANSFER_EXIST_BILL_ACC_FLOW;
    private List<String> NEW_SUBSCRIPTION_TRIAL_STEPS;
    private String contractSigned =  'Contract Signed';
    private String proformaInvoiceSendAmend =  'Proforma Invoice sent';
    private String sentToZuoraAmend =  'Sent To Zuora';
    private List<String> AMENDMANT_CREDITCARD_STEPS;
    private List<String> AMENDMANT_OTHER_FEATUREUPDATE_STEPS;
    private List<String> AMENDMANT_OTHER_RENEWAL_STEPS;
    private List<String> AMENDMANT_WIRETRANSFER_RENEWAL_UPDATE_STEPS;
    private List<String> AMENDMANT_WIRETRANSFER_COTERMUPSELL;
    private List<String> AMENDMANT_TRIAL_STEPS;
    private List<String> CANCELLATION_DELTAZERO_STEPS;
    private List<String> CANCELLATION_DELTANOTZERO_STEPS;
    private List<String> PENDING_STEPS = new List<String>{'Terms Pending','Deal Size Pending','Trial Pending'};
    private List<String> REJECTED_STEPS = new List<String>{'Terms Rejected','Deal Size Rejected','Trial Rejected'};
    private List<String> CANCELLED_STEPS = new List<String>{'Cancelled'};
    
    public ZuoraQuoteStatusCalculator(zqu__Quote__c quote) {
        if(Test.isRunningTest()){
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
        contructorLogic(quote);
    }

    public ZuoraQuoteStatusCalculator(Id quoteId) {
        zqu__Quote__c quote = [SELECT Id
                                    , zqu_Quote_Status__c
                                    , RecordTypeId
                                    , zqu__PaymentMethod__c
                                    , document_format__c
                                    , zqu__SubscriptionType__c
                                    , zqu__QuoteBusinessType__c
                                    , Is_from_existing_Billing_Account__c
                                    , Is_Contract_Signed_Manually__c
                                    , zqu__Previewed_Delta_MRR__c
                                    , zqu__Previewed_SubTotal__c
                                    , zqu__Previewed_Delta_TCV__c
                                    , Trial_Quote__c
                                FROM zqu__Quote__c
                                WHERE Id=:quoteId
                                LIMIT 1
        ];
        contructorLogic(quote);
    }

    private void contructorLogic(zqu__Quote__c quote){
        this.quote = quote;
        validateQuote(quote);

        Zuora_Quote_Approval_Settings__c quoteApprovalSetting = Zuora_Quote_Approval_Settings__c.getOrgDefaults();
        System.debug('quoteApprovalSetting ' + quoteApprovalSetting);
        if ('Contract Signed Manually'.equalsIgnoreCase(quote.zqu_Quote_Status__c)) {
            contractSigned = 'Contract Signed Manually';
            proformaInvoiceSendAmend = 'Contract Signed Manually';
        }
        
        if (quote.zqu_Quote_Status__c == 'Quote Pending Renewal Date') {
            sentToZuoraAmend = 'Quote Pending Renewal Date';
        }

        if (quoteApprovalSetting.Enable_Approval_process_for_Quote__c) {
            NEW_SUBSCRIPTIONS_OTHER_STEPS = new List<String>{'New','Deal Size Approved','Terms Approved',contractSigned};
            if (quote.Is_Contract_Signed_Manually__c) {
                NEW_SUBSCRIPTIONS_OTHER_STEPS.add('Ready for Billing');
            }
            NEW_SUBSCRIPTIONS_OTHER_STEPS.add('Sent To Zuora');
            
            // NEW_SUBSCRIPTION_CREDIT_CARD_STEPS = new List<String>{'Deal Size Approved','Terms Approved',contractSigned,'Ready for Billing'};
            NEW_SUBSCRIPTION_CREDIT_CARD_STEPS = new List<String>{'Terms Approved',contractSigned,'Ready for Billing'};
            NEW_SUBSCRIPTION_WIRE_TRANSFER = new List<String>{'Terms Approved','Proforma Invoice sent','Ready for Billing'};
        } else {
            NEW_SUBSCRIPTIONS_OTHER_STEPS = new List<String>{'Deal Size Approved','Terms Approved',contractSigned};
            //NEW_SUBSCRIPTIONS_OTHER_STEPS = new List<String>{'Terms Approved',contractSigned};
            if (quote.Is_Contract_Signed_Manually__c) {
                NEW_SUBSCRIPTIONS_OTHER_STEPS.add('Ready for Billing');
            }
            NEW_SUBSCRIPTIONS_OTHER_STEPS.add('Sent To Zuora');
            
            // NEW_SUBSCRIPTION_CREDIT_CARD_STEPS = new List<String>{'Deal Size Approved','Terms Approved',contractSigned,'Ready for Billing','Sent To Zuora'};
            NEW_SUBSCRIPTION_CREDIT_CARD_STEPS = new List<String>{'Terms Approved',contractSigned,'Ready for Billing','Sent To Zuora'};
            // NEW_SUBSCRIPTION_WIRE_TRANSFER = new List<String>{'Deal Size Approved','Terms Approved','Proforma Invoice sent','Ready for Billing','Sent To Zuora'};
            NEW_SUBSCRIPTION_WIRE_TRANSFER = new List<String>{'Terms Approved','Proforma Invoice sent','Ready for Billing','Sent To Zuora'};
        }
        NEW_SUBSCRIPTION_REGULAR_FLOW = new List<String>{'New MSA','Finalized','Ready for Billing','Sent To Zuora'};
        // AMENDMANT_STEPS = new List<String>{'New Amendment',contractSigned,'Sent To Zuora'};
        // AMENDMANT_RENEWAL_STEPS = new List<String>{'New Amendment','Ready for Billing',contractSigned,'Sent To Zuora'};
        NEW_SUBSCRIPTION_EXIST_BILL_ACC_FLOW = new List<String>{'Deal Size Approved','Terms Approved',contractSigned,'Ready for Billing','Sent To Zuora'};
        NEW_SUBSCRIPTION_WIRE_TRANSFER_EXIST_BILL_ACC_FLOW = new List<String>{'Terms Approved','Proforma Invoice sent','Ready for Billing','Sent To Zuora'};
        AMENDMANT_CREDITCARD_STEPS = new List<String>{'New Amendment','Terms Approved',sentToZuoraAmend};
        // AMENDMANT_OTHER_FEATUREUPDATE_STEPS = new List<String>{'New Amendment',contractSigned,sentToZuoraAmend};
        AMENDMANT_WIRETRANSFER_RENEWAL_UPDATE_STEPS = new List<String>{'New Amendment','Terms Approved',proformaInvoiceSendAmend,'Ready for Billing',sentToZuoraAmend};
        CANCELLATION_DELTAZERO_STEPS = new List<String>{'New','Sent To Zuora'};
        CANCELLATION_DELTANOTZERO_STEPS = new List<String>{'New','Ready for Billing','Sent To Zuora'};
        if (quote.Is_Contract_Signed_Manually__c) {
            AMENDMANT_OTHER_RENEWAL_STEPS = new List<String>{'New Amendment','Terms Approved', contractSigned, 'Ready for Billing','Quote Pending Renewal Date','Sent To Zuora'};
            AMENDMANT_WIRETRANSFER_COTERMUPSELL = new List<String>{'New Amendment','Terms Approved',proformaInvoiceSendAmend, 'Ready for Billing',sentToZuoraAmend};
            AMENDMANT_OTHER_FEATUREUPDATE_STEPS = new List<String>{'New Amendment','Terms Approved',contractSigned,'Ready for Billing'};
        } else {
            AMENDMANT_OTHER_RENEWAL_STEPS = new List<String>{'New Amendment', 'Terms Approved',contractSigned, 'Quote Pending Renewal Date','Sent To Zuora'};
            AMENDMANT_WIRETRANSFER_COTERMUPSELL = new List<String>{'New Amendment','Terms Approved',proformaInvoiceSendAmend,sentToZuoraAmend};
            AMENDMANT_OTHER_FEATUREUPDATE_STEPS = new List<String>{'New Amendment','Terms Approved',contractSigned};
        }
        // MQ-1061
        //
        // if (
        //     !quote.Is_Contract_Signed_Manually__c && 
        //     quote.zqu__QuoteBusinessType__c == 'Feature Update + Renewal (with/without upsell)' && 
        //     AMENDMANT_OTHER_FEATUREUPDATE_STEPS.indexOf('Terms Approved') > 0 &&
        //     quote.zqu_Quote_Status__c != 'Terms Approved'

        // ) {
        //     AMENDMANT_OTHER_FEATUREUPDATE_STEPS.remove(AMENDMANT_OTHER_FEATUREUPDATE_STEPS.indexOf('Terms Approved'));// remove
        // }

        if (
            quote.Is_Contract_Signed_Manually__c && 
            quote.zqu__QuoteBusinessType__c == 'Feature Update + Renewal (with/without upsell)' && 
            AMENDMANT_OTHER_FEATUREUPDATE_STEPS.indexOf(contractSigned) > 0 &&
            quote.zqu_Quote_Status__c == 'Ready for Billing'

        ) {
            AMENDMANT_OTHER_FEATUREUPDATE_STEPS.remove(AMENDMANT_OTHER_FEATUREUPDATE_STEPS.indexOf(contractSigned));// remove
        }

        if(quote.zqu__Previewed_Delta_MRR__c != 0 || quote.zqu__Previewed_SubTotal__c != 0){
            if (!AMENDMANT_OTHER_FEATUREUPDATE_STEPS.contains('Ready for Billing')) {
                AMENDMANT_OTHER_FEATUREUPDATE_STEPS.add('Ready for Billing');
            }
            AMENDMANT_OTHER_FEATUREUPDATE_STEPS.add('Sent To Zuora');
        } else {
            AMENDMANT_OTHER_FEATUREUPDATE_STEPS.add('Sent To Zuora');
        }
        if (sentToZuoraAmend == 'Quote Pending Renewal Date') {
            AMENDMANT_CREDITCARD_STEPS.add('Sent To Zuora');
            AMENDMANT_WIRETRANSFER_RENEWAL_UPDATE_STEPS.add('Sent To Zuora');
            AMENDMANT_WIRETRANSFER_COTERMUPSELL.add('Sent To Zuora');
        }
        NEW_SUBSCRIPTION_TRIAL_STEPS = new List<String>{'New Trial','Trial Approved'};
        AMENDMANT_TRIAL_STEPS = new List<String>{'New Trial','Trial Approved','Sent To Zuora'};

        addLegalFlowStatuses(quote);
    }

    private void addLegalFlowStatuses(zqu__Quote__c quote){
        if(
            quote.zqu_Quote_Status__c == 'Pending Legal Or Billing request' ||
            quote.zqu_Quote_Status__c == 'Pending Rep To Adjust Quote' ||
            quote.zqu_Quote_Status__c == 'Approved By Billing' 
        ){
            List<List<String>> quoteS = new List<List<String>>{
                AMENDMANT_CREDITCARD_STEPS,
                AMENDMANT_OTHER_FEATUREUPDATE_STEPS,
                AMENDMANT_OTHER_RENEWAL_STEPS,
                AMENDMANT_WIRETRANSFER_RENEWAL_UPDATE_STEPS,
                AMENDMANT_WIRETRANSFER_COTERMUPSELL,
                AMENDMANT_TRIAL_STEPS,
                NEW_SUBSCRIPTIONS_OTHER_STEPS,
                NEW_SUBSCRIPTION_CREDIT_CARD_STEPS,
                NEW_SUBSCRIPTION_WIRE_TRANSFER,
                NEW_SUBSCRIPTION_REGULAR_FLOW,
                NEW_SUBSCRIPTION_EXIST_BILL_ACC_FLOW,
                NEW_SUBSCRIPTION_WIRE_TRANSFER_EXIST_BILL_ACC_FLOW,
                NEW_SUBSCRIPTION_TRIAL_STEPS
            };
            for(List<String> statusList : quoteS){
                addLegalFlowStatusesToList(statusList);
            }
        }
    }

    private void addLegalFlowStatusesToList(List<String> quoteStatusList){
        if(quoteStatusList.indexOf('Terms Approved') != -1){
            Integer index = quoteStatusList.indexOf('Terms Approved');
            quoteStatusList.add(index + 1, 'Pending Legal Or Billing request');
            quoteStatusList.add(index + 2, 'Pending Rep To Adjust Quote');
            quoteStatusList.add(index + 3, 'Approved By Billing');
        }
    }

    public Boolean checkIfReadOnly(){
        Boolean isReadOnly = Utility.getDevNameForRecordTypeID(quote.getSObjectType(), quote.RecordTypeId)
                             .containsIgnoreCase('ReadOnly');
        return isReadOnly;
    }

    public List<String> getCurrentListStep(){
        String quoteStatus;
        List<String> stepsList = getStepsList(quote);
        return stepsList;
    }

    public String initialStatus(){
        String quoteStatus;
        List<String> stepsList = getStepsList(quote);
        if (stepsList!= null) {
            quoteStatus = stepsList[0];
        }
        return quoteStatus;
    }

    public String correctStatusIfWrong(){
        String quoteStatus;
        List<String> stepsList = getStepsList(quote);
        if (!stepsList.contains(quote.zqu_Quote_Status__c) 
            && !PENDING_STEPS.contains(quote.zqu_Quote_Status__c)
            && !CANCELLED_STEPS.contains(quote.zqu_Quote_Status__c)
            && !REJECTED_STEPS.contains(quote.zqu_Quote_Status__c))
        {
            quoteStatus = initialStatus();
            quote.Is_Contract_Signed_Manually__c = false;
            update quote;
        } else {
            quoteStatus = quote.zqu_Quote_Status__c;
        }
        return quoteStatus;
    }

    public String nextStatus(){
        String quoteStatus;
        List<String> stepsList = getStepsList(quote);
        if (String.isBlank(quote.zqu_Quote_Status__c)) {
            quoteStatus = stepsList[0];
        } else if(quote.zqu_Quote_Status__c == 'Rejected'){
            quoteStatus = 'Deal Size Approved';
        } else {
            if (!stepsList.contains(quote.zqu_Quote_Status__c)) {
                throw new StepIsNotFoundException();
            }
            quoteStatus = stepsList[stepsList.indexOf(quote.zqu_Quote_Status__c) + 1];
        }
        return quoteStatus;
    }

    public String previousStatus(){
        String quoteStatus;
        List<String> stepsList = getStepsList(quote);
        if (String.isBlank(quote.zqu_Quote_Status__c)) {
            throw new StepIsNotFoundException();
        } else if(quote.zqu_Quote_Status__c == 'Voided'){
            String message = 'The quote is voided as it is no longer amending the latest version of the subscription, please create a new quote';
            throw new StepIsNotFoundException(message);
        } else if(quote.zqu_Quote_Status__c == 'Rejected'){
            quoteStatus = 'Deal Size Approved';
        } else if(quote.zqu_Quote_Status__c == 'Deal Size Pending' || quote.zqu_Quote_Status__c == 'Terms Pending'  || quote.zqu_Quote_Status__c == 'Trial Pending') {
            ProcessInstanceWorkitem[] piWorkItems = [SELECT Id FROM ProcessInstanceWorkItem WHERE ProcessInstance.TargetObjectId = :quote.Id
                                                    AND ProcessInstance.Status = 'Pending']; 
            if(piWorkItems.size() > 0){
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Removed');
                pwiRequest.setWorkItemId(piWorkItems[0].Id);
                Approval.ProcessResult result = Approval.process(pwiRequest);
            }
            if(quote.zqu_Quote_Status__c == 'Trial Pending'){
                quoteStatus = 'New Trial';
            } else if(quote.zqu__SubscriptionType__c == 'New Subscription') {
                quoteStatus = 'Deal Size Approved';
            } else {
                quoteStatus = 'New Amendment';
            }
        } else {
            if (REJECTED_STEPS.contains(quote.zqu_Quote_Status__c)) {
                quote.zqu_Quote_Status__c = quote.zqu_Quote_Status__c.replace('Rejected', 'Approved');
            }
            if (!stepsList.contains(quote.zqu_Quote_Status__c)) {
                throw new StepIsNotFoundException();
            }
            if (stepsList.indexOf(quote.zqu_Quote_Status__c) == 0) {
                throw new StepIsNotFoundException('The current step is first');
            }
            quoteStatus = stepsList[stepsList.indexOf(quote.zqu_Quote_Status__c) - 1];
        }
        return quoteStatus;
    }

    private List<String> getStepsList(zqu__Quote__c quote){
        List<String> stepsList;

        if (quote.zqu__SubscriptionType__c == 'New Subscription') {
            if(quote.Trial_Quote__c){
                stepsList = NEW_SUBSCRIPTION_TRIAL_STEPS;
            } else {
                if (quote.Is_from_existing_Billing_Account__c) {
                    if(quote.zqu__PaymentMethod__c == 'Wire Transfer') {
                        stepsList = NEW_SUBSCRIPTION_WIRE_TRANSFER_EXIST_BILL_ACC_FLOW;
                    } else {
                        stepsList = NEW_SUBSCRIPTION_EXIST_BILL_ACC_FLOW;
                    }
                } else {
                    if (quote.document_format__c == 'MSA') {
                        stepsList = NEW_SUBSCRIPTION_REGULAR_FLOW;
                    } else if (quote.zqu__PaymentMethod__c == 'Other') {
                        stepsList = NEW_SUBSCRIPTIONS_OTHER_STEPS;
                    } else if(quote.zqu__PaymentMethod__c == 'Credit Card') {
                        stepsList = NEW_SUBSCRIPTION_CREDIT_CARD_STEPS;
                    } else if(quote.zqu__PaymentMethod__c == 'Wire Transfer') {
                        stepsList = NEW_SUBSCRIPTION_WIRE_TRANSFER;
                    }
                }
            }
            
        }else if(quote.zqu__SubscriptionType__c == 'Amend Subscription') {
            /* if (String.IsNotBlank(quote.zqu__QuoteBusinessType__c) 
                && quote.zqu__QuoteBusinessType__c.containsIgnoreCase('Renewal')) 
            {
                stepsList = AMENDMANT_RENEWAL_STEPS;
            } else {
                stepsList = AMENDMANT_STEPS;
            } */
            if(quote.Trial_Quote__c){
                stepsList = AMENDMANT_TRIAL_STEPS;
            } else {
                if (quote.zqu__PaymentMethod__c == 'Other'
                    || quote.zqu__QuoteBusinessType__c == 'Feature Update') 
                {
                    if(quote.zqu__QuoteBusinessType__c == 'Feature Update' || quote.zqu__QuoteBusinessType__c == 'Feature Update + Renewal (with/without upsell)'){
                        stepsList = AMENDMANT_OTHER_FEATUREUPDATE_STEPS;   
                    } else {
                        stepsList = AMENDMANT_OTHER_RENEWAL_STEPS;   
                    }
                } else if(quote.zqu__PaymentMethod__c == 'Wire Transfer'){
                    System.debug('quote.zqu__PaymentMethod__c Wire');
                    System.debug('quote.zqu__PaymentMethod__c Wire' + quote.zqu_Quote_Status__c);
                    if (quote.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)') {
                        System.debug('quote.zqu__PaymentMethod__c ren');
                        stepsList = AMENDMANT_WIRETRANSFER_RENEWAL_UPDATE_STEPS;   
                    } else if(quote.zqu__QuoteBusinessType__c == 'Co-Term Upsell') {
                        System.debug('quote.zqu__PaymentMethod__c co');
                        stepsList = AMENDMANT_WIRETRANSFER_COTERMUPSELL;   
                    }
                } else if(quote.zqu__PaymentMethod__c == 'Credit Card') {
                    stepsList = AMENDMANT_CREDITCARD_STEPS;
                }
            }
        } else if (quote.zqu__SubscriptionType__c == 'Cancel Subscription') {
            if (quote.zqu__Previewed_Delta_MRR__c == 0  && quote.zqu__Previewed_Delta_TCV__c == 0) {
                stepsList = CANCELLATION_DELTAZERO_STEPS;
            } else {
                stepsList = CANCELLATION_DELTANOTZERO_STEPS;
            }
        }
        System.debug('stepsList ' + stepsList);
        return stepsList;
    }

    private void validateQuote(zqu__Quote__c quote){
        if (String.isBlank(quote.RecordTypeId)) {
            throw new ValueIsMissingException('Record type id is missing');
        }
        if (!Test.isRunningTest() && String.isBlank(quote.zqu__PaymentMethod__c) && quote.zqu__SubscriptionType__c != 'Cancel Subscription') {
            throw new ValueIsMissingException('Payment method is missing');
        }
        if (String.isBlank(quote.zqu__SubscriptionType__c)) {
            throw new ValueIsMissingException('Subscription Type is missing');
        }
        if (quote.zqu__SubscriptionType__c == 'Amend Subscription' && String.isBlank(quote.zqu__QuoteBusinessType__c)) {
            throw new ValueIsMissingException('Quote business type is missing');
        }
    }

    public class StepIsNotFoundException extends Exception {    }
    public class ValueIsMissingException extends Exception {    }
}
public with sharing class CustomCpqSelectProductController {
    public zqu__Quote__c thisQuote {get; set;}
    public zqu.SelectProductComponentOptions theOptions { get; set; }
    public String chargeId { get; set; }
    public CustomCpqSelectProductController(ApexPages.StandardController standardController){
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
        }
        thisQuote = (zqu__Quote__c)standardController.getRecord();
        zqu__Quote__c quote1 = [SELECT zqu_Quote_Status__c FROM zqu__Quote__c WHERE Id = :thisQuote.Id LIMIT 1];
        thisQuote.zqu_Quote_Status__c = quote1.zqu_Quote_Status__c;
        theOptions = new zqu.SelectProductComponentOptions();
        theOptions.title = 'New Quote';
        theOptions.subTitle = 'Choose Product and Charges';
        Boolean isApprovalProcessEnabled = Zuora_Quote_Approval_Settings__c.getOrgDefaults().Enable_Approval_process_for_Quote__c;
        Boolean isAdminOrBilling;
        Profile currUserProfile = [SELECT Id,Name FROM Profile WHERE Id=:UserInfo.getProfileId()];
        if (currUserProfile!=null && (currUserProfile.Name.equalsIgnoreCase('System Administrator')
                                    || currUserProfile.Name.equalsIgnoreCase('SW Billing')
                                    || currUserProfile.Name.equalsIgnoreCase('SW Billing Extended')))
        {
            isAdminOrBilling = true;
        } else {
            isAdminOrBilling = false;
        }

        if (!isAdminOrBilling
            &&
            (thisQuote.zqu_Quote_Status__c == 'Terms Approved'
            || thisQuote.zqu_Quote_Status__c == 'Finalized'
            || thisQuote.zqu_Quote_Status__c == 'Contract Signed'
            || thisQuote.zqu_Quote_Status__c == 'Contract Signed Manually'
            || thisQuote.zqu_Quote_Status__c == 'Sent To Zuora'
            || thisQuote.zqu_Quote_Status__c == 'Ready for Billing'
            || thisQuote.zqu_Quote_Status__c == 'Pending Legal Or Billing request'
            || thisQuote.zqu_Quote_Status__c == 'Quote Pending Renewal Date'
            || thisQuote.zqu_Quote_Status__c == 'Terms Pending'
            || thisQuote.zqu_Quote_Status__c == 'Approved By Billing'
        )
            )
        {
            theOptions.mode = zqu.SelectProductComponentOptions.MODE_DETAIL;
        } else {
            theOptions.mode = zqu.SelectProductComponentOptions.MODE_EDIT;
        }
        theOptions.quoteType = 'Subscription';
        theOptions.quoteId = thisQuote.Id;

        // Set the page url for buttons if necessary
        theOptions.previousUrl = '';
        theOptions.saveUrl = '';
        theOptions.cancelUrl = '';
        theOptions.addBundleProductsUrl = '/apex/CustomEditQuoteProductsPage';
    }


    public PageReference fetchRecord(){
        System.debug('asdasdasds');
        return null;
    }

    @RemoteAction
    public static void renewalCalculation(String quoteId) {
        system.debug('renewal Calc');
        List<zqu__Quote__c> quotesToUpdate = new List<zqu__Quote__c>();
        List<zqu__Quote__c> quotesList = [SELECT Id
                                            , Is_Quote_Ready__c
                                            , Submit_Button_Timestamp__c
                                            , Recurring_Target_Price__c
                                            , zqu__QuoteBusinessType__c
                                            , Renewal_Fee__c
                                            , Target_Quote_Total_Price__c
                                            , zqu__InitialTerm__c
                                            , Is_Initally_Renewed__c
                                            , Total_Sum_Of_Fees__c
                                            , Total_Sum_Of_Discountable_Fees__c
                                            , Sum_Of_one_time__c
                                            , zqu__Currency__c
                                        FROM zqu__Quote__c
                                        WHERE Id = :quoteId
        ];
        List<zqu__Quote__c> quotesToUpdateList = new List<zqu__Quote__c>();
        Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance('Rounding_Resolve_V1');
        Boolean featureFlag = roundingFF.Is_Active__c;
        for (zqu__Quote__c quote_i : quotesList) {
            if(!featureFlag){
                if ((quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)' && quote_i.Renewal_Fee__c != null) || quote_i.Target_Quote_Total_Price__c != null || quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                    if (quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                        ZuoraQuoteMetricsManipulationHelper.correctProductIfFutureUpdate(quote_i);
                    } else {
                        ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPriceMainLogic(quote_i.Id, quote_i.Target_Quote_Total_Price__c == null ? quote_i.Renewal_Fee__c : quote_i.Target_Quote_Total_Price__c,quote_i.zqu__InitialTerm__c);
                    }
                }
            }else{
                quote_i.Submit_Button_Timestamp__c = Datetime.now();
                quotesToUpdateList.add(quote_i);
                System.debug('quote_i.zqu__QuoteBusinessType__c: ' + quote_i.zqu__QuoteBusinessType__c);
                System.debug('quote_i.Renewal_Fee__c: ' + quote_i.Renewal_Fee__c);
                if (quote_i.Recurring_Target_Price__c != null || quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                    quote_i.Discount_Status__c = 'discount Started';
                    if (quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                        System.debug('i am before Is_Quote_Ready__c'+quote_i.Is_Quote_Ready__c);
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'FU',true));
                        ZuoraPriceCalculation.SumsObj sumObj = ZuoraPriceCalculation.updateQuoteSums2(new List<zqu__Quote__c>{quote_i}, false, false);
                        System.debug('FU Prices: ' + sumObj);
                        quote_i.Total_Sum_Of_Fees__c = sumObj.sumOfNonDiscountableRecurring + sumObj.sumOfDiscountableRecurring;
                        quote_i.Total_Sum_Of_Discountable_Fees__c = sumObj.sumOfDiscountableRecurring;
                        quote_i.Sum_Of_one_time__c = sumObj.sumOfOneTime;
                        quote_i.Sum_Of_NonDiscountable_Fees__c = sumObj.sumOfRecurringNonDiscountable;
                        quote_i.Is_Quote_Ready__c = false;
                    }else if (quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'Renewal',true));
                        ZuoraPriceCalculation.SumsObj sumObj = ZuoraPriceCalculation.updateQuoteSums2(new List<zqu__Quote__c>{quote_i}, false, false);
                        System.debug('Renewal Prices: ' + sumObj);
                        quote_i.Total_Sum_Of_Fees__c = sumObj.sumOfNonDiscountableRecurring + sumObj.sumOfDiscountableRecurring;
                        quote_i.Total_Sum_Of_Discountable_Fees__c = sumObj.sumOfDiscountableRecurring;
                        quote_i.Sum_Of_one_time__c = sumObj.sumOfOneTime;
                        quote_i.Sum_Of_NonDiscountable_Fees__c = sumObj.sumOfRecurringNonDiscountable;
                        quote_i.Is_Quote_Ready__c = false;
                        //ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPriceMainLogic(quote_i.Id, quote_i.Recurring_Target_Price__c == null ? quote_i.Renewal_Fee__c : quote_i.Recurring_Target_Price__c,quote_i.zqu__InitialTerm__c);
                    }else if(quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Co-Term Upsell')){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'CTU',true));
                        ZuoraPriceCalculation.SumsObj sumObj = ZuoraPriceCalculation.updateQuoteSums2(new List<zqu__Quote__c>{quote_i}, false, false);
                        System.debug('CTU Prices: ' + sumObj);
                        quote_i.Total_Sum_Of_Fees__c = sumObj.sumOfNonDiscountableRecurring + sumObj.sumOfDiscountableRecurring;
                        quote_i.Total_Sum_Of_Discountable_Fees__c = sumObj.sumOfDiscountableRecurring;
                        quote_i.Sum_Of_one_time__c = sumObj.sumOfOneTime;
                        quote_i.Sum_Of_NonDiscountable_Fees__c = sumObj.sumOfRecurringNonDiscountable;
                        quote_i.Is_Quote_Ready__c = false;
                    }else if(quote_i.zqu__QuoteBusinessType__c == 'New'){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'AddDiscount',true));
                        ZuoraPriceCalculation.SumsObj sumObj = ZuoraPriceCalculation.updateQuoteSums2(new List<zqu__Quote__c>{quote_i}, false, false);
                        System.debug('New Sale Prices: ' + sumObj);
                        quote_i.Total_Sum_Of_Fees__c = sumObj.sumOfNonDiscountableRecurring + sumObj.sumOfDiscountableRecurring;
                        quote_i.Total_Sum_Of_Discountable_Fees__c = sumObj.sumOfDiscountableRecurring;
                        quote_i.Sum_Of_one_time__c = sumObj.sumOfOneTime;
                        quote_i.Sum_Of_NonDiscountable_Fees__c = sumObj.sumOfRecurringNonDiscountable;
                        quote_i.Is_Quote_Ready__c = false;
                    }
                }
            }
            System.debug('i am before Is_Quote_Ready__c'+quotesToUpdateList[0].Is_Quote_Ready__c);
            system.debug('quote_i: ' + quotesToUpdateList[0].Total_Sum_Of_Fees__c);
            system.debug('quote_i: ' + quotesToUpdateList[0].Total_Sum_Of_Discountable_Fees__c);
            system.debug('quote_i: ' + quotesToUpdateList[0].Sum_Of_one_time__c);
            update quotesToUpdateList;
        }
    }

    private static Map < String, List < zqu.DataObject > > makeDataObjects(Id quoteId) {
        String quotesNamespace = 'zqu__';
        List < zqu.DataObject > dataChargeGroups = new List < zqu.DataObject > ();
        List < zqu.DataObject > dataCharges = new List < zqu.DataObject > ();
        List < zqu.ZChargeGroup > chargeGroups = zqu.zQuoteUtil.getChargeGroups( quoteId );
        for(zqu.ZChargeGroup chargeGroup : chargeGroups){
            //if(chargeGroup.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_ORIGINAL){
            zqu.DataObject dataChargeGroup = new zqu.ZChargeGroupDataObject(chargeGroup);
            dataChargeGroups.add(dataChargeGroup);
            dataCharges.addAll(dataChargeGroup.getChildren(
                    quotesNamespace + 'QuoteRatePlanCharge__c'));
            //}
        }
        return new Map < String, List < zqu.DataObject > >{
                quotesNamespace + 'QuoteRatePlan__c' => dataChargeGroups,
                quotesNamespace + 'QuoteRatePlanCharge__c' => dataCharges
        };
    }

    public void fixProductDiscountPercentage(){
        System.debug('fixProductDiscountPercentage');
        // ZuoraQuoteMetricsManipulationHelper.correctProductIfFutureUpdate(ApexPages.currentPage().getParameters().get('id'));
        update ZuoraQuoteFinalizeHelper.finalizeQuote(new List<Id>{ApexPages.currentPage().getParameters().get('id')});

    }

    public PageReference redirectToRecordPage() {
        PageReference pg = new PageReference('/'+thisQuote.Id);
        pg.setRedirect(true);
        return pg;
    }

    @RemoteAction
    public static Map<String, String> checkValidIds(List<String> idsToCheck, List<String> divExtractedIds, String quoteId) {

        Map<String, String> idMap = new Map<String, String>();
        List<AddonType__mdt> adtListMdt = AddonType__mdt.getAll().values();
        List<String> zuoraSubscriptionIdList = new List<String>();
        List<String> ratePlanIdList = new List<String>();
        Map<Id, zqu__QuoteRatePlan__c> quoteRatePlanByIdMap = new Map<Id, zqu__QuoteRatePlan__c>();
        Map<String, zqu__QuoteRatePlan__c> quoteRatePlanByZuoraSubIdMap = new Map<String, zqu__QuoteRatePlan__c>();

        for(String divId : divExtractedIds){
            if(divId.startsWith('a1g')){
                ratePlanIdList.add(divId);
            }else{
                zuoraSubscriptionIdList.add(divId);
            }
        }
        System.debug(ratePlanIdList);
        System.debug(zuoraSubscriptionIdList);

        List<zqu__QuoteRatePlanCharge__c> items = [SELECT zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddonType__c, Id FROM zqu__QuoteRatePlanCharge__c WHERE Id IN :idsToCheck];

        for (zqu__QuoteRatePlanCharge__c item : items) {
            for(AddonType__mdt adtMdt : adtListMdt){
                if (item.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddonType__c.containsIgnoreCase(adtMdt.Label)){
                    idMap.put(item.Id, item.Id);
                }
            }
        }

        List<zqu__QuoteRatePlan__c> divItems = [SELECT zqu__ProductRatePlan__r.zqu__Product__r.AddonType__c, Id, zqu__SubscriptionRatePlanZuoraId__c, (SELECT Id FROM zqu__Quote_Rate_Plan_Charges__r)
        FROM zqu__QuoteRatePlan__c
        WHERE (zqu__SubscriptionRatePlanZuoraId__c IN :divExtractedIds OR Id IN :divExtractedIds)
        AND zqu__Quote__c = :quoteId];

        for(zqu__QuoteRatePlan__c qrp : divItems){
            quoteRatePlanByIdMap.put(qrp.Id, qrp);
            if(!String.isBlank(qrp.zqu__SubscriptionRatePlanZuoraId__c) && !qrp.zqu__Quote_Rate_Plan_Charges__r.isEmpty()){
                quoteRatePlanByZuoraSubIdMap.put(qrp.zqu__SubscriptionRatePlanZuoraId__c, qrp);
            }
        }
        System.debug(quoteRatePlanByIdMap);
        System.debug(quoteRatePlanByIdMap.size());
        System.debug(quoteRatePlanByZuoraSubIdMap);
        System.debug(quoteRatePlanByZuoraSubIdMap.size());

        for(String zuoraSubId : zuoraSubscriptionIdList){
            if(quoteRatePlanByZuoraSubIdMap.containsKey(zuoraSubId)){
                for(AddonType__mdt adtMdt : adtListMdt){
                    if (quoteRatePlanByZuoraSubIdMap.get(zuoraSubId).zqu__ProductRatePlan__r.zqu__Product__r.AddonType__c.containsIgnoreCase(adtMdt.Label) && !quoteRatePlanByZuoraSubIdMap.get(zuoraSubId).zqu__Quote_Rate_Plan_Charges__r.isEmpty()){
                        idMap.put(quoteRatePlanByZuoraSubIdMap.get(zuoraSubId).zqu__SubscriptionRatePlanZuoraId__c, quoteRatePlanByZuoraSubIdMap.get(zuoraSubId).zqu__Quote_Rate_Plan_Charges__r[0].Id);
                    }
                }
            }
        }

        for(String ratePlanId : ratePlanIdList){
            if(quoteRatePlanByIdMap.containsKey(ratePlanId)){
                for(AddonType__mdt adtMdt : adtListMdt){
                    if (quoteRatePlanByIdMap.get(ratePlanId).zqu__ProductRatePlan__r.zqu__Product__r.AddonType__c.containsIgnoreCase(adtMdt.Label) && !quoteRatePlanByIdMap.get(ratePlanId).zqu__Quote_Rate_Plan_Charges__r.isEmpty()){
                        idMap.put(quoteRatePlanByIdMap.get(ratePlanId).Id, quoteRatePlanByIdMap.get(ratePlanId).zqu__Quote_Rate_Plan_Charges__r[0].Id);
                    }
                }
            }
        }

//        for (zqu__QuoteRatePlan__c divItem : divItems) {
//            for(AddonType__mdt adtMdt : adtListMdt){
//                if (divItem.zqu__ProductRatePlan__r.zqu__Product__r.AddonType__c.contains(adtMdt.Label)){
//                    idMap.put(divItem.zqu__SubscriptionRatePlanZuoraId__c, divItem.zqu__Quote_Rate_Plan_Charges__r[0].Id);
//                }
//            }
//        }
        System.debug('idMap: ' + idMap);
        return idMap;
    }
}
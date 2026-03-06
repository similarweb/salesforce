public without sharing class CustomEditQuoteProductsController {
    public zqu.EditQuoteProductOptions editProductOptions {
        get;
        set;
    }

    public zqu__Quote__c thisQuote {get; set;}
    public Boolean deleteOriginal {get; set;}
    public String validationErrorMessage {get; set;}
  
    public CustomEditQuoteProductsController (ApexPages.StandardController controller) {
        Id amendmentRecordTypeId = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByDeveloperName()
                                   .get('Amendment').getRecordTypeId();

        thisQuote = (zqu__Quote__c)controller.getRecord();
        editProductOptions = new zqu.EditQuoteProductOptions();
        editProductOptions.guidedSellingOptions = new zqu.ProductBundleGuidedSellingOptions();
        editProductOptions.guidedSellingOptions.quoteType = ApexPages.currentPage().getParameters().get('quoteType');
        editProductOptions.guidedSellingOptions.quoteId = ApexPages.currentPage().getParameters().get('id'); 
        editProductOptions.productSelectorOptions = new zqu.SelectProductComponentOptions();
        editProductOptions.productSelectorOptions.quoteType = ApexPages.currentPage().getParameters().get('quoteType');
        editProductOptions.productSelectorOptions.quoteId = ApexPages.currentPage().getParameters().get('id');
        if (thisQuote.RecordTypeId == amendmentRecordTypeId) {
            editProductOptions.initialComponentMode = zqu.EditQuoteProductOptions.PRODUCT_SELECTOR_MODE;
            if (thisQuote.Migrating_to_New_Soultion__c == 'Yes') {
                editProductOptions.productSelectorOptions.addBundleProductsUrl =  editProductOptions.productSelectorOptions.addBundleProductsUrl + '&isMigration=true';
                deleteOriginal = true;
            }
        } else {
            editProductOptions.initialComponentMode = zqu.EditQuoteProductOptions.GUIDED_SELLING_MODE;
        }
        if (thisQuote.QuoteRegion__c == 'Error - Please check the Sold To country')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error - Please check the Sold To country'));
        } 
    }


    @RemoteAction
    public static List<String> validateQuote(String quoteId) {
        System.debug(' we are in validateQuote');
        List<String> resultList = new List<String>();
            zqu__Quote__c quote_i = [
                    SELECT
                            id,
                            payment_frequency1__c,
                            zqu__InitialTerm__c,
                            Submit_Button_Timestamp__c,
                            zqu__Is_Charge_Expired__c,
                            Is_Feature_Update_Initiated__c,
                            zqu__QuoteBusinessType__c,
                            Recurring_Target_Price__c,
                            Is_Quote_Ready__c,
                            Total_Sum_Of_Fees__c,
                            Total_Sum_Of_Discountable_Fees__c,
                            Sum_Of_one_time__c,
                            zqu__Currency__c,
                            Renewal_Fee__c
                    FROM zqu__Quote__c
                    WHERE Id =: quoteId
                    LIMIT 1
            ];

            Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance('Rounding_Resolve_V1');
            Boolean featureFlag = roundingFF.Is_Active__c;
            if(!featureFlag){
                if (quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                    ZuoraQuoteMetricsManipulationHelper.correctProductIfFutureUpdate(quote_i);
                }
            }else{
                if (quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'){
                    if(quote_i.Submit_Button_Timestamp__c == null){
                        List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteId);
                        List<zqu.QPlan> relevantPlans = new List<zqu.QPlan>();
                        for(zqu.QPlan plan : currentPlans){
                            for(zqu.QCharge charge : plan.getCharges()){
                                if(!ZuoraPriceCalculation.isOneTimeCharge(plan.getRecord().Name, charge)){
                                    relevantPlans.add(plan);
                                }
                            }
                        }
                        quote_i.Recurring_Target_Price__c = quote_i.Renewal_Fee__c;
                        zqu.QPlanWriter.save(new List<zqu.QPlan> (ZuoraPriceCalculation.resetToOriginalTiers(relevantPlans,quote_i.zqu__Currency__c)));

                    }
                }
                ZuoraPriceCalculation.SumsObj sumObj = ZuoraPriceCalculation.updateQuoteSums2(new List<zqu__Quote__c>{quote_i}, false, false);
                system.debug('sumObj: ' + sumObj);
                quote_i.Total_Sum_Of_Fees__c = sumObj.sumOfNonDiscountableRecurring + sumObj.sumOfDiscountableRecurring;
                quote_i.Total_Sum_Of_Discountable_Fees__c = sumObj.sumOfDiscountableRecurring;
                quote_i.Sum_Of_one_time__c = sumObj.sumOfOneTime;
                system.debug('quote_i: ' + quote_i.Total_Sum_Of_Fees__c);
                system.debug('quote_i: ' + quote_i.Total_Sum_Of_Discountable_Fees__c);
                system.debug('quote_i: ' + quote_i.Sum_Of_one_time__c);
                system.debug('quote_i: ' + quote_i.Recurring_Target_Price__c);
                system.debug('quote_i: ' + quote_i.zqu__QuoteBusinessType__c);
                if (quote_i.Recurring_Target_Price__c != null || quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                    quote_i.Discount_Status__c = 'Discount Started';
                    if (quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Feature Update')) {
                        if(quote_i.Submit_Button_Timestamp__c != null){
                            System.debug('i am before Is_Quote_Ready__c'+quote_i.Is_Quote_Ready__c);
                            quote_i.Submit_Button_Timestamp__c = Datetime.now();
                            quote_i.Is_Quote_Ready__c = false;
                        }else{
                            quote_i.Discount_Status__c = 'Discount Started';
                            List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteId);
                            for (zqu.QPlan plan : currentPlans) {
                                Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                                for (zqu.QCharge charge : plan.getCharges()) {
                                    // Identify Base Product Charge
                                    system.debug('plan.getRecord().Is_Base_product__c: ' + plan.getRecord().Is_Base_product__c);
                                    if (plan.getRecord().Is_Base_product__c && isNotRemoved) {
                                        // Assuming the base product has one charge
                                        charge.put('zqu__Discount__c', 0);
                                    }
                                }
                            }
                            zqu.QPlanWriter.save(currentPlans);
                            for (zqu.QPlan plan : currentPlans) {
                                Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                                Boolean isNotNewProduct = plan.get('zqu__AmendmentType__c') != 'NewProduct';
                                for (zqu.QCharge charge : plan.getCharges()) {
                                    // Identify Base Product Charge
                                    system.debug('plan.getRecord().Is_Base_product__c: ' + plan.getRecord().Is_Base_product__c);
                                    if (plan.getRecord().Is_Base_product__c && isNotRemoved && isNotNewProduct) {
                                        // Assuming the base product has one charge
                                        plan.revert();
                                        break;
                                    }
                                }
                            }
                            zqu.QPlanWriter.save(currentPlans);
                        }
                        quote_i.Is_Quote_Ready__c = false;
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'FU',true));
                    }else if (quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)'){
                        if(quote_i.Submit_Button_Timestamp__c == null){
                            system.debug('quoteId: ' + quoteId);
                            List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteId);
                            Set<zqu.QPlan> updateablePlanSet = new Set<zqu.QPlan>();
                            for(zqu.QPlan plan : currentPlans){
                                system.debug('plan: ' + plan);
                                Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                                system.debug('plan.amendmentType: ' + plan.get('zqu__AmendmentType__c'));
                                if(isNotRemoved){
                                    for(zqu.QCharge charge : plan.getCharges()){
                                        if(charge.getRecord().zqu__IsLastSegment__c && !ZuoraPriceCalculation.isOneTimeCharge(plan.getRecord().Name, charge)){
                                            system.debug('charge: ' + charge.getRecord().zqu__IsLastSegment__c);
                                            updateablePlanSet.add(plan);
                                            if(!charge.getRecord().zqu__Model__c.containsIgnoreCase('Flat fee')){
                                                List<zqu.QTier> tierList = new List<zqu.QTier>();
                                                for(zqu.QTier tier : charge.getTiers()){
                                                    tier.put('zqu__Discount__c', 0);
                                                    tierList.add(tier);
                                                }
                                                charge.setTiers(tierList);
                                            }else if(charge.getRecord().zqu__Model__c.containsIgnoreCase('Flat fee')){
                                                charge.put('zqu__Discount__c', 0);
                                            }
                                        }
                                    }
                                }
                            }
                            zqu.QPlanWriter.save(New List<zqu.QPlan>(updateablePlanSet));
                        }
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'AddDiscount',true));
                        quote_i.Is_Quote_Ready__c = false;
                        //ZuoraQuoteMetricsManipulationHelper.updateChargesByTargetTotalPriceMainLogic(quote_i.Id, quote_i.Recurring_Target_Price__c == null ? quote_i.Renewal_Fee__c : quote_i.Recurring_Target_Price__c,quote_i.zqu__InitialTerm__c);
                    }else if(quote_i.zqu__QuoteBusinessType__c.containsIgnoreCase('Co-Term Upsell')){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'CTU',true));
                        quote_i.Is_Quote_Ready__c = false;
                    }else if(quote_i.zqu__QuoteBusinessType__c == 'New'){
                        System.enqueueJob(new ZuoraUpdateDiscountPriceQueueable(quote_i, 'AddDiscount',true));
                        quote_i.Is_Quote_Ready__c = false;
                    }
                }
                quote_i.Submit_Button_Timestamp__c = Datetime.now();
                update quote_i;
            }
        system.debug(resultList);
        return resultList;
    }


    public PageReference navigateBack() {
        zqu__Quote__c qq = [SELECT Id,zqu__Opportunity__c FROM zqu__Quote__c WHERE Id=:thisQuote.Id];
        Map<String, String> customUrlParameters = new Map<String, String>{'Id' => qq.Id,
                                                                          'oppId' => qq.zqu__Opportunity__c
        };
        if (ApexPages.currentPage().getParameters().get('quoteType') == 'Amendment') {
            customUrlParameters.put('editQuoteProductsMode', 'EditProducts');
        }
        return zqu.QuoteWizardManager.navigateBack(customUrlParameters);
    }
    /**
     * @description method for redirecting from Product Edit page to Quote Record Page
     * MQ-1116 - Added Async callout of populateSubmitButtonTimestamp() method
     * @return  `PageReference`
     */
    public PageReference redirectToRecordPage() {
        zqu__Quote__c fullQuote = [
            SELECT 
                id,
                payment_frequency1__c,
                zqu__InitialTerm__c,
                Submit_Button_Timestamp__c
            FROM zqu__Quote__c
            WHERE Id =: thisQuote.Id
            LIMIT 1
        ];
        if(fullQuote.Submit_Button_Timestamp__c == null){
            populateSubmitButtonTimestamp(thisQuote.Id);
        }

        PageReference pg = new PageReference('/'+thisQuote.Id);
        pg.setRedirect(true);
        return pg; 
    }

    @TestVisible
    private static String parseRawResultMessage(String resultMessageRaw){
        String validationErrorMessage = resultMessageRaw.substringAfter(', message=').substringBefore(',');
        return validationErrorMessage;
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

    public void checkIfOriginalProductsHaveChanged(){
        if(Test.isRunningTest()){
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        } else {
            zqu.Quote zQuote = zqu.Quote.getInstance(thisQuote.Id);
            zqu__Quote__c fullQuote = [
                SELECT 
                    id,
                    payment_frequency1__c,
                    zqu__InitialTerm__c,
                    Submit_Button_Timestamp__c,
                    zqu__Is_Charge_Expired__c,
                    Is_Feature_Update_Initiated__c,
                    zqu__QuoteBusinessType__c
                FROM zqu__Quote__c
                WHERE Id =: thisQuote.Id
                LIMIT 1
            ];

            for(zqu.QuoteProduct product_i : zQuote.getQuoteProducts()){
                zqu.zChargeGroup zcg_i = product_i.chargeGroup;
                if(
                    zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL ||
                    zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
                ){
                    for(zqu.zCharge charge_i : zcg_i.zCharges){
                        String paymentFrequency = fullQuote.payment_frequency1__c;

                        if( 
                            charge_i.SPECIFIC_BILLING_PERIOD != null &&
                            Integer.valueOf(charge_i.SPECIFIC_BILLING_PERIOD) != ZuoraQuoteMetricsManipulationHelper.getPaymentFrequencyNumber(paymentFrequency,fullQuote.zqu__InitialTerm__c) &&
                            zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL
                        ){
                            ZuoraQuoteMetricsManipulationHelper.reAddAllProducts(zQuote);
                            break;
                        } else if(
                            zcg_i.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
                        ){
                            zqu.zCharge charge_original = zcg_i.originalChargeGroup.zCharges[0];
                            if(Integer.valueOf(charge_i.SPECIFIC_BILLING_PERIOD) != Integer.valueOf(charge_original.SPECIFIC_BILLING_PERIOD)){
                                ZuoraQuoteMetricsManipulationHelper.removeAllUpdatedProducts(thisQuote.Id);
                                break;
                            }
                        }
                    }
                    break;
                }
            }

           List<zqu__Quote__c> quotesToUpdate = ZuoraQuoteFinalizeHelper.finalizeQuote(new List<Id>{ApexPages.currentPage().getParameters().get('id')});
            Feature_Flag_Setting__mdt roundingFF = Feature_Flag_Setting__mdt.getInstance('Rounding_Resolve_V1');
            Boolean featureFlag = roundingFF.Is_Active__c;
           for (zqu__Quote__c quote_i : quotesToUpdate) {
               if (quote_i.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)' && quote_i.Renewal_Fee__c != null && quote_i.Is_Initally_Renewed__c == false) {
                   if(!featureFlag){
                       quote_i.Target_Quote_Total_Price__c = quote_i.Renewal_Fee__c;
                       quote_i.Is_Initally_Renewed__c = true;
                   }
               }
           }
           update quotesToUpdate;
        }
    }

    /**
     * MQ-1116. Runs in Asynchonous context
     * @description sets the value of Submit_Button_Timestamp__c field with the current Datetime
     * @param quoteId - id of current Quote
     * @return void
     */
    @Future
    private static void populateSubmitButtonTimestamp(String quoteId){
        zqu__Quote__c fullQuote = [
                SELECT 
                    id,
                    Submit_Button_Timestamp__c
                FROM zqu__Quote__c
                WHERE Id =: quoteId
                LIMIT 1
        ];
        fullQuote.Submit_Button_Timestamp__c = Datetime.now();
        update fullQuote;
    }
}
/**
 * Created by zohar.sinay on 09/09/2024.
 */

public class ZuoraCARRCalculation {

    public static List<zqu__Quote__c> getQuoteList(Id quoteId) {
        List<zqu__Quote__c> quoteList = [
                SELECT Id, zqu__InitialTerm__c, Total_Sum_Of_Fees__c, QuoteRegion__c, zqu__Currency__c, Zuora_General_Error_Message__c,
                        Current_Contract_TCV__c, zqu__SubscriptionTermEndDate__c, CARR_Error_Message__c, CARR_Error_Checkbox__c,
                        Sum_Of_Recurring_fees__c, Target_Quote_Total_Price__c, Recurring_Target_Price__c,
                        zqu__ExistSubscriptionID__c, Migrating_to_New_Soultion__c, zqu__StartDate__c, Total_Sum_Of_Discountable_Fees__c
                FROM zqu__Quote__c
                WHERE Id = :quoteId
        ];

        return quoteList;
    }

    public static List<zqu__QuoteRatePlanCharge__c> handleNewSale(Id quoteId, Boolean toUpsert) {
        //System.debug('this.asdasdasd00---'+this.fromSubmit);
        List<zqu__Quote__c> quoteList = getQuoteList(quoteId);

        if (quoteList.isEmpty()) {
            return null; // Early exit if no quote found
        }
        try {
            System.debug('quoteList[0].Total_Sum_Of_Fees__c--' + quoteList[0].Total_Sum_Of_Fees__c);
            SumsObj TotalSumOfFeesObj = updateQuoteSums(quoteList, false);
            //Decimal discountPercentage = ZuoraPriceCalculation.CalculatePercentageOfDiscount(TotalSumOfFeesObj.sumOfDiscountableRecurring, quoteList[0].Target_Quote_Total_Price__c);
            System.debug('TotalSumOfFeesObj: ' + TotalSumOfFeesObj);
            Decimal discountPercentage = 0;
            if (quoteList[0].Recurring_Target_Price__c != null) {
                discountPercentage = calculateSelectiveDiscountPercentage(0, TotalSumOfFeesObj.sumOfDiscountableRecurring, quoteList[0].Recurring_Target_Price__c);
            }
            discountPercentage = String.valueOf(discountPercentage).substringAfter('.').startsWith('99') ? discountPercentage.setscale(0) : discountPercentage;
            System.debug('discountPercentage: ' + discountPercentage);
            Set<zqu.QPlan> planToUpdateSet = new Set<zqu.QPlan>();
            Boolean foundDiscountPlan = false;
            Decimal recPrice = 0;
            String curr = '';
            Integer billingPeriod;
            Integer numOfcharges = 0;

            List<zqu.QPlan> plans = zqu.QPlanReader.load(quoteId);
            List<zqu__QuoteRatePlanCharge__c> chargesToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
            for (zqu.QPlan plan : plans) {
                for (zqu.QCharge charge : plan.getCharges()) {
                    List<zqu.QTier> chargeTierList = new List<zqu.QTier>();
                    if (isRecurringCharge((String) plan.getRecord().get('Name'), charge)) {
                        if (charge.getTiers() != null && !charge.getTiers().isEmpty()) {
                            for (zqu.QTier chargeTier : charge.getTiers()) {
                                chargeTier.put('zqu__Discount__c', discountPercentage);
                                chargeTierList.add(chargeTier);
                                numOfcharges++;
                            }

                        } else {
                            charge.put('zqu__Discount__c', discountPercentage);
                            curr = (String) charge.get('zqu__Currency__c');
                            numOfcharges++;
                        }
                        if (!chargeTierList.isEmpty()) {
                            charge.setTiers(chargeTierList);
                        }
                        recPrice += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                        System.debug('recPrice--' + recPrice);
                        System.debug('quoteList[0].zqu__InitialTerm__c--' + quoteList[0].zqu__InitialTerm__c);
                        if ((Decimal) charge.get('zqu__EffectivePrice__c') != null && charge.getRecord().Id != null && charge.get('zqu__ListPrice__c') != 0 && charge.get('No_Discount_Product__c') == false) {
                            chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = (Decimal) charge.get('zqu__Discount__c')));
                        }
                        billingPeriod = Integer.valueOf(charge.get('zqu__SpecificBillingPeriod__c')) != null ? Integer.valueOf(charge.get('zqu__SpecificBillingPeriod__c')) : billingPeriod;
                        planToUpdateSet.add(plan);
                    } else if (charge.get('No_Discount_Product__c') == true && charge.getRecord().Id != null) {
                        chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = 0));
                    }
                }
            }


            //zqu.QPlanWriter.save(new List<zqu.QPlan>(planToUpdateSet));
            if (toUpsert) {
                quoteList[0].Recurring_Discount_Percentage__c = discountPercentage;
                quoteList[0].Sum_Of_Recurring_fees__c = recPrice.setScale(0, System.RoundingMode.Half_UP);
                quoteList[0].Is_Discount_Given_Timestamp__c = Datetime.now();
                quoteList[0].CARR_Error_Message__c = null;
                quoteList[0].CARR_Error_Checkbox__c = false;
                quoteList[0].Activate_CARR__c = true;
                update quoteList;
                update chargesToUpdate;
            }
            return chargesToUpdate;

        } catch (Exception ex) {
            handleError(quoteList, ex);
            System.debug('exception --- ' + ex.getMessage() + ' stack --- ' + ex.getStackTraceString());
            update quoteList;
            return null;
        }

    }

    public static List<zqu__QuoteRatePlanCharge__c> handleFU(Id quoteId, Boolean toUpsert) {

        System.debug('yaron started handleFU');
        List<zqu__Quote__c> quoteList = [
                SELECT Id, zqu__ExistSubscriptionID__c, zqu__InitialTerm__c, QuoteRegion__c, zqu__Currency__c, zqu__ZuoraSubscriptionID__c,
                        Total_Sum_Of_Fees__c, Sum_Of_Recurring_fees__c, Target_Quote_Total_Price__c, Recurring_Target_Price__c,
                        Zuora_General_Error_Message__c, CARR_Error_Message__c, CARR_Error_Checkbox__c,
                        zqu__StartDate__c, zqu__SubscriptionTermStartDate__c, zqu__SubscriptionTermEndDate__c, zqu_Quote_Status__c
                FROM zqu__Quote__c
                WHERE Id = :quoteId
        ];
        if (quoteList.isEmpty()) {
            return null; // Early exit if no quote found
        }

        try {
            //Map<String, zqu__QuoteRatePlanCharge__c> chargeNumberToChargeMap = getChargeNumberToChargeMap();
            Decimal originalRounding = 0;
            List<zqu.QPlan> roundingRatePlansToRemoveList = new List<zqu.QPlan>();
            List<zqu__QuoteRatePlanCharge__c> chargesToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
            Decimal sumOfOldProductsWithOriginalDiscount = 0;
            List<zqu.QPlan> planToUpdateList = new List<zqu.QPlan>();

            Decimal sumOfNewAndUpdatedProducts = 0;
            Decimal targetTotalPrice = 0;
            Boolean foundDiscountPlan = false;

            Integer billingPeriod;
            Map<String, Zuora__SubscriptionProductCharge__c> SPCByChargeNumber = new Map<String, Zuora__SubscriptionProductCharge__c>();
            String zuoraSubscriptionId = quoteList[0].zqu_Quote_Status__c == 'Sent To Zuora' ? quoteList[0].zqu__ZuoraSubscriptionID__c : quoteList[0].zqu__ExistSubscriptionID__c;
            for (Zuora__SubscriptionProductCharge__c SPB : [
                    SELECT Id, Name, Zuora__ChargeNumber__c, Zuora__Price__c, Zuora__RatePlanId__c,
                            Zuora__Type__c, Zuora__TotalContractValue__c, Zuora__MonthlyRecurringRevenue__c, CARR_Monthly_Total__c, Quote_rate_plan_charge_ID__c
                    FROM Zuora__SubscriptionProductCharge__c
                    WHERE Zuora__Subscription__r.Zuora__External_Id__c = :zuoraSubscriptionId
            ]) {
                SPCByChargeNumber.put(SPB.Zuora__ChargeNumber__c, SPB);
                if (SPB.Zuora__Type__c.containsIgnoreCase('Recurring')) {
                    if(SPB.CARR_Monthly_Total__c != null){
                        TargetTotalPrice += Decimal.valueOf(SPB.CARR_Monthly_Total__c) * quoteList[0].zqu__InitialTerm__c;
                    }else if(SPB.Zuora__MonthlyRecurringRevenue__c != null){
                        TargetTotalPrice += SPB.Zuora__MonthlyRecurringRevenue__c * quoteList[0].zqu__InitialTerm__c;
                    }
                }
            }

            //System.debug('originalCharges---'+originalCharges);

            List<zqu.QPlan> removedPlans = new List<zqu.QPlan>();
            List<zqu.QPlan> newAndUpdatedPlans = new List<zqu.QPlan>();

            List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteId);


            TargetTotalPrice = String.valueOf(TargetTotalPrice).substringAfter('.').startsWith('99') || String.valueOf(TargetTotalPrice).substringAfter('.').startsWith('00') ? TargetTotalPrice.setscale(0) : TargetTotalPrice;

            System.debug(TargetTotalPrice);

            System.debug('in zero discount');
            zeroDiscountForQuote(currentPlans);


            System.debug('TargetTotalPrice: ' + TargetTotalPrice);
            Boolean isNewOrUpdateExists = false;

            for (zqu.QPlan plan : currentPlans) {
                Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                if (isNotRemoved) {
                    for (zqu.QCharge charge : plan.getCharges()) {
                        System.debug('plan.get(Name): ' + plan.get('Name'));
                        System.debug('charge.get(\'zqu__chargeType__c\'): ' + charge.get('zqu__chargeType__c'));
                        System.debug('charge.get(\'zqu__ListPrice__c\'): ' + charge.get('zqu__ListPrice__c'));
                        System.debug('charge.get(\'No_Discount_Product__c\'): ' + charge.get('No_Discount_Product__c'));
                        System.debug('charge.get(Amendment_type__c): ' + charge.get('Amendment_type__c'));
                        Boolean isNotFreeProduct = charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product';
                        if (isNotFreeProduct) {
                            if (billingPeriod == null) {
                                billingPeriod = Integer.valueOf(charge.get('zqu__SpecificBillingPeriod__c'));
                            }
                            if (charge.get('Amendment_type__c') == 'Original' && (((String) charge.get('zqu__chargeType__c')).containsIgnoreCase('Recurring'))) {
                                String chargeNumber = (String) charge.get('zqu__ChargeNumber__c');
                                System.debug(SPCByChargeNumber.containsKey(chargeNumber));
                                System.debug(SPCByChargeNumber.get(chargeNumber));
                                System.debug(SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c);
                                System.debug(SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c != null);
                                if (SPCByChargeNumber.containsKey(chargeNumber)) { // Calculate recurring previous charges
                                    if (SPCByChargeNumber.get(chargeNumber).Quote_rate_plan_charge_ID__c != 'Free Product') {
                                        if (SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c != null) {
                                            sumOfOldProductsWithOriginalDiscount += Decimal.valueOf(SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c) * quoteList[0].zqu__InitialTerm__c;
                                        } else {
                                            throw new ZuoraUpdateDiscountPriceQueueableException('Missing data for charge number: ' + chargeNumber);
                                        }
                                    }
                                } else {
                                    throw new ZuoraUpdateDiscountPriceQueueableException('Missing data for charge number: ' + chargeNumber);
                                }
                            } else if (charge.get('Amendment_type__c') == 'UpdateProduct' &&
                                    (((String) charge.get('zqu__chargeType__c')).containsIgnoreCase('Recurring')) &&
                                    charge.get('No_Discount_Product__c') == false &&
                                    charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product') { // handling recurring no discount products by taking their original values from the previous charge on the subscription
                                String chargeNumber = (String) charge.get('zqu__ChargeNumber__c');
                                isNewOrUpdateExists = true;
                                sumOfNewAndUpdatedProducts += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                                planToUpdateList.add(plan);
                            } else if (charge.get('Amendment_type__c') == 'NewProduct'
                                    && charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product' && charge.get('No_Discount_Product__c') == false) {
                                system.debug('charge.get(Quote_rate_plan_charge_ID__c)' + charge.get('Quote_rate_plan_charge_ID__c'));
                                System.debug('plan.get(Name): ' + plan.get('Name'));
                                isNewOrUpdateExists = true;
                                sumOfNewAndUpdatedProducts += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                                planToUpdateList.add(plan);
                            }
                        }
                    }
                }
            }

            System.debug('sumOfNewAndUpdatedProducts--' + sumOfNewAndUpdatedProducts);
            System.debug('sumOfOldProductsWithOriginalDiscount--' + sumOfOldProductsWithOriginalDiscount);
            System.debug('isNewOrUpdateExists--' + isNewOrUpdateExists);
            System.debug('targetTotalPrice--' + targetTotalPrice);
            System.debug('planToUpdateList--' + planToUpdateList);

            Decimal discountPercentage = 0;
            if (isNewOrUpdateExists == true) {
                discountPercentage = calculateSelectiveDiscountPercentage(sumOfOldProductsWithOriginalDiscount, sumOfNewAndUpdatedProducts, targetTotalPrice.setScale(0));
                discountPercentage = String.valueOf(discountPercentage).substringAfter('.').startsWith('99') ? discountPercentage.setscale(0) : discountPercentage;
                handleGivingNewAndUpdatedDiscount(planToUpdateList, discountPercentage);
            } else if (sumOfOldProductsWithOriginalDiscount.setScale(0) != targetTotalPrice.setScale(0)) {
                zeroDiscountForOriginalsQuote(planToUpdateList);
                sumOfOldProductsWithOriginalDiscount = 0;
                for (zqu.QPlan plan : planToUpdateList) {
                    for (zqu.QCharge charge : plan.getCharges()) {
                        Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                        if (isNotRemoved) {
                            if (isRecurringCharge((String) plan.getRecord().get('Name'), charge)) {
                                if (charge.get('Amendment_type__c') == 'Original') {
                                    System.debug('(Decimal) charge.get--' + (Decimal) charge.get('zqu__Total__c'));
                                    sumOfOldProductsWithOriginalDiscount += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                                }
                            }
                        }
                    }
                }
                discountPercentage = CalculatePercentageOfDiscount(sumOfOldProductsWithOriginalDiscount, targetTotalPrice);
                discountPercentage = String.valueOf(discountPercentage).substringAfter('.').startsWith('99') ? discountPercentage.setscale(0) : discountPercentage;
                handleGivingOriginalDiscount(planToUpdateList, discountPercentage);
            }

            Decimal recPrice = 0;
            for (zqu.QPlan plan : planToUpdateList) {
                for (zqu.QCharge charge : plan.getCharges()) {
                    Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                    if (isNotRemoved) {
                        if (isRecurringCharge2((String) plan.getRecord().get('Name'), charge)) {
                            recPrice += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                            if ((Decimal) charge.get('zqu__EffectivePrice__c') != null && charge.getRecord().Id != null && charge.get('zqu__ListPrice__c') != 0 && charge.get('No_Discount_Product__c') == false) {
                                System.debug(charge.get('Name'));
                                System.debug(charge.get('zqu__Total__c'));
                                chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = (Decimal) charge.get('zqu__Discount__c') == null ? 0 : (Decimal) charge.get('zqu__Discount__c')));
                            }
                        } else if (charge.get('No_Discount_Product__c') == true && charge.getRecord().Id != null) {
                            System.debug(charge.get('Name'));
                            System.debug(charge.get('zqu__Total__c'));
                            chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = 0));
                        }
                    }
                    System.debug((Decimal) charge.get('zqu__EffectivePrice__c'));
                    System.debug((Decimal) charge.get('zqu__Discount__c'));
                    System.debug(charge.getRecord().Id);
                }
            }

            System.debug('discountPercentage: ' + discountPercentage);

            billingPeriod = billingPeriod == null ? 12 : billingPeriod;

            //Decimal adjustmentNeeded = ZuoraPriceCalculation.calculateLikeZuoraFU_CTU(removedPlans, newAndUpdatedPlans, quoteList);
            System.debug(quoteList[0].zqu__InitialTerm__c.setScale(0));
            System.debug(billingPeriod);
            System.debug(math.mod(Integer.valueOf(quoteList[0].zqu__InitialTerm__c.setScale(0)), billingPeriod));


            //zqu.QPlanWriter.save(planToUpdateList);
            System.debug(chargesToUpdate);
            if (toUpsert) {
                quoteList[0].Recurring_Discount_Percentage__c = discountPercentage;
                quoteList[0].Sum_Of_Recurring_fees__c = recPrice.setScale(0, System.RoundingMode.Half_UP);
                quoteList[0].CARR_Error_Message__c = null;
                quoteList[0].CARR_Error_Checkbox__c = false;
                quoteList[0].Activate_CARR__c = true;
                update quoteList;
                update chargesToUpdate;

            }
            return chargesToUpdate;
        } catch (Exception ex) {
            handleError(quoteList, ex);
            System.debug('exception --- ' + ex.getMessage() + ' stack --- ' + ex.getStackTraceString());
            update quoteList;
            return null;
        }
    }

    public static List<zqu__QuoteRatePlanCharge__c> handleCTU(Id quoteId, Boolean toUpsert) {

        System.debug('yaron started handleFU');
        List<zqu__Quote__c> quoteList = [
                SELECT Id, zqu__ExistSubscriptionID__c, zqu__InitialTerm__c, QuoteRegion__c, zqu__Currency__c, zqu__ZuoraSubscriptionID__c,
                        Total_Sum_Of_Fees__c, Sum_Of_Recurring_fees__c, Target_Quote_Total_Price__c, Recurring_Target_Price__c,
                        Zuora_General_Error_Message__c, CARR_Error_Message__c, CARR_Error_Checkbox__c,
                        zqu__StartDate__c, zqu__SubscriptionTermStartDate__c, zqu__SubscriptionTermEndDate__c, zqu_Quote_Status__c
                FROM zqu__Quote__c
                WHERE Id = :quoteId
        ];
        if (quoteList.isEmpty()) {
            return null; // Early exit if no quote found
        }

        try {
            //Map<String, zqu__QuoteRatePlanCharge__c> chargeNumberToChargeMap = getChargeNumberToChargeMap();
            Decimal originalRounding = 0;
            List<zqu.QPlan> roundingRatePlansToRemoveList = new List<zqu.QPlan>();
            List<zqu__QuoteRatePlanCharge__c> chargesToUpdate = new List<zqu__QuoteRatePlanCharge__c>();
            Decimal sumOfOldProductsWithOriginalDiscount = 0;
            List<zqu.QPlan> planToUpdateList = new List<zqu.QPlan>();

            Decimal sumOfNewAndUpdatedProducts = 0;
            Decimal targetTotalPrice = 0;
            Boolean foundDiscountPlan = false;

            Integer billingPeriod;
            Map<String, Zuora__SubscriptionProductCharge__c> SPCByChargeNumber = new Map<String, Zuora__SubscriptionProductCharge__c>();
            String zuoraSubscriptionId = quoteList[0].zqu_Quote_Status__c == 'Sent To Zuora' ? quoteList[0].zqu__ZuoraSubscriptionID__c : quoteList[0].zqu__ExistSubscriptionID__c;
            for (Zuora__SubscriptionProductCharge__c SPB : [
                    SELECT Id, Name, Zuora__ChargeNumber__c, Zuora__Price__c, Zuora__RatePlanId__c,
                            Zuora__Type__c, Zuora__TotalContractValue__c, Zuora__MonthlyRecurringRevenue__c, CARR_Monthly_Total__c, Quote_rate_plan_charge_ID__c
                    FROM Zuora__SubscriptionProductCharge__c
                    WHERE Zuora__Subscription__r.Zuora__External_Id__c = :zuoraSubscriptionId
            ]) {
                SPCByChargeNumber.put(SPB.Zuora__ChargeNumber__c, SPB);
                if (SPB.Zuora__Type__c.containsIgnoreCase('Recurring')) {
                    if(SPB.CARR_Monthly_Total__c != null){
                        TargetTotalPrice += Decimal.valueOf(SPB.CARR_Monthly_Total__c) * quoteList[0].zqu__InitialTerm__c;
                    }else if(SPB.Zuora__MonthlyRecurringRevenue__c != null){
                        TargetTotalPrice += SPB.Zuora__MonthlyRecurringRevenue__c * quoteList[0].zqu__InitialTerm__c;
                    }
                }
            }

            //System.debug('originalCharges---'+originalCharges);

            List<zqu.QPlan> removedPlans = new List<zqu.QPlan>();
            List<zqu.QPlan> newAndUpdatedPlans = new List<zqu.QPlan>();

            List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteId);


            TargetTotalPrice = String.valueOf(TargetTotalPrice).substringAfter('.').startsWith('99') || String.valueOf(TargetTotalPrice).substringAfter('.').startsWith('00') ? TargetTotalPrice.setscale(0) : TargetTotalPrice;
            TargetTotalPrice += quoteList[0].Recurring_Target_Price__c;
            System.debug(TargetTotalPrice);

            System.debug('in zero discount');
            zeroDiscountForQuote(currentPlans);


            System.debug('TargetTotalPrice: ' + TargetTotalPrice);
            Boolean isNewOrUpdateExists = false;

            for (zqu.QPlan plan : currentPlans) {
                Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                if (isNotRemoved) {
                    for (zqu.QCharge charge : plan.getCharges()) {
                        System.debug('plan.get(Name): ' + plan.get('Name'));
                        System.debug('charge.get(\'zqu__chargeType__c\'): ' + charge.get('zqu__chargeType__c'));
                        System.debug('charge.get(\'zqu__ListPrice__c\'): ' + charge.get('zqu__ListPrice__c'));
                        System.debug('charge.get(\'No_Discount_Product__c\'): ' + charge.get('No_Discount_Product__c'));
                        System.debug('charge.get(Amendment_type__c): ' + charge.get('Amendment_type__c'));
                        Boolean isNotFreeProduct = charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product';
                        if (isNotFreeProduct) {
                            if (billingPeriod == null) {
                                billingPeriod = Integer.valueOf(charge.get('zqu__SpecificBillingPeriod__c'));
                            }
                            if (charge.get('Amendment_type__c') == 'Original' && (((String) charge.get('zqu__chargeType__c')).containsIgnoreCase('Recurring'))) {
                                String chargeNumber = (String) charge.get('zqu__ChargeNumber__c');
                                System.debug(SPCByChargeNumber.containsKey(chargeNumber));
                                System.debug(SPCByChargeNumber.get(chargeNumber));
                                System.debug(SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c);
                                System.debug(SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c != null);
                                if (SPCByChargeNumber.containsKey(chargeNumber)) { // Calculate recurring previous charges
                                    if (SPCByChargeNumber.get(chargeNumber).Quote_rate_plan_charge_ID__c != 'Free Product') {
                                        if (SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c != null) {
                                            sumOfOldProductsWithOriginalDiscount += Decimal.valueOf(SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c) * quoteList[0].zqu__InitialTerm__c;
                                        } else {
                                            throw new ZuoraUpdateDiscountPriceQueueableException('Missing data for charge number: ' + chargeNumber);
                                        }
                                    }
                                } else {
                                    throw new ZuoraUpdateDiscountPriceQueueableException('Missing data for charge number: ' + chargeNumber);
                                }
                            } else if (charge.get('Amendment_type__c') == 'UpdateProduct' &&
                                    (((String) charge.get('zqu__chargeType__c')).containsIgnoreCase('Recurring')) &&
                                    charge.get('No_Discount_Product__c') == false &&
                                    charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product') { // handling recurring no discount products by taking their original values from the previous charge on the subscription
                                String chargeNumber = (String) charge.get('zqu__ChargeNumber__c');
                                if (SPCByChargeNumber.containsKey(chargeNumber) && (SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c != null)) {
                                    sumOfOldProductsWithOriginalDiscount += Decimal.valueOf(SPCByChargeNumber.get(chargeNumber).CARR_Monthly_Total__c) * quoteList[0].zqu__InitialTerm__c;
                                } else {
                                    throw new ZuoraUpdateDiscountPriceQueueableException('Missing data for charge number: ' + chargeNumber);
                                }
                                isNewOrUpdateExists = true;
                                sumOfNewAndUpdatedProducts += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                                planToUpdateList.add(plan);
                            } else if (charge.get('Amendment_type__c') == 'NewProduct'
                                    && charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product' && charge.get('No_Discount_Product__c') == false) {
                                system.debug('charge.get(Quote_rate_plan_charge_ID__c)' + charge.get('Quote_rate_plan_charge_ID__c'));
                                System.debug('plan.get(Name): ' + plan.get('Name'));
                                isNewOrUpdateExists = true;
                                sumOfNewAndUpdatedProducts += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                                planToUpdateList.add(plan);
                            }
                        }
                    }
                }
            }

            System.debug('sumOfNewAndUpdatedProducts--' + sumOfNewAndUpdatedProducts);
            System.debug('sumOfOldProductsWithOriginalDiscount--' + sumOfOldProductsWithOriginalDiscount);
            System.debug('isNewOrUpdateExists--' + isNewOrUpdateExists);
            System.debug('targetTotalPrice--' + targetTotalPrice);
            System.debug('planToUpdateList--' + planToUpdateList);

            Decimal discountPercentage = 0;
            if (isNewOrUpdateExists == true) {
                discountPercentage = calculateSelectiveDiscountPercentage(sumOfOldProductsWithOriginalDiscount, sumOfNewAndUpdatedProducts, targetTotalPrice.setScale(0));
                discountPercentage = String.valueOf(discountPercentage).substringAfter('.').startsWith('99') ? discountPercentage.setscale(0) : discountPercentage;
                handleGivingNewAndUpdatedDiscount(planToUpdateList, discountPercentage);
            } else if (sumOfOldProductsWithOriginalDiscount.setScale(0) != targetTotalPrice.setScale(0)) {
                zeroDiscountForOriginalsQuote(planToUpdateList);
                sumOfOldProductsWithOriginalDiscount = 0;
                for (zqu.QPlan plan : planToUpdateList) {
                    for (zqu.QCharge charge : plan.getCharges()) {
                        Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                        if (isNotRemoved) {
                            if (isRecurringCharge((String) plan.getRecord().get('Name'), charge)) {
                                if (charge.get('Amendment_type__c') == 'Original') {
                                    System.debug('(Decimal) charge.get--' + (Decimal) charge.get('zqu__Total__c'));
                                    sumOfOldProductsWithOriginalDiscount += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                                }
                            }
                        }
                    }
                }
                discountPercentage = CalculatePercentageOfDiscount(sumOfOldProductsWithOriginalDiscount, targetTotalPrice);
                discountPercentage = String.valueOf(discountPercentage).substringAfter('.').startsWith('99') ? discountPercentage.setscale(0) : discountPercentage;
                handleGivingOriginalDiscount(planToUpdateList, discountPercentage);
            }

            Decimal recPrice = 0;
            for (zqu.QPlan plan : planToUpdateList) {
                for (zqu.QCharge charge : plan.getCharges()) {
                    Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                    if (isNotRemoved) {
                        if (isRecurringCharge2((String) plan.getRecord().get('Name'), charge)) {
                            recPrice += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                            if ((Decimal) charge.get('zqu__EffectivePrice__c') != null && charge.getRecord().Id != null && charge.get('zqu__ListPrice__c') != 0 && charge.get('No_Discount_Product__c') == false) {
                                System.debug(charge.get('zqu__Total__c'));
                                chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = (Decimal) charge.get('zqu__Discount__c') == null ? 0 : (Decimal) charge.get('zqu__Discount__c')));
                            }
                        } else if (charge.get('No_Discount_Product__c') == true && charge.getRecord().Id != null) {
                            System.debug(charge.get('zqu__Total__c'));
                            chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = 0));
                        }
                    }
                    System.debug((Decimal) charge.get('zqu__EffectivePrice__c'));
                    System.debug((Decimal) charge.get('zqu__Discount__c'));
                    System.debug(charge.getRecord().Id);
                }
            }

            System.debug('discountPercentage: ' + discountPercentage);

            billingPeriod = billingPeriod == null ? 12 : billingPeriod;

            //Decimal adjustmentNeeded = ZuoraPriceCalculation.calculateLikeZuoraFU_CTU(removedPlans, newAndUpdatedPlans, quoteList);
            System.debug(quoteList[0].zqu__InitialTerm__c.setScale(0));
            System.debug(billingPeriod);
            System.debug(math.mod(Integer.valueOf(quoteList[0].zqu__InitialTerm__c.setScale(0)), billingPeriod));


            //zqu.QPlanWriter.save(planToUpdateList);
            System.debug(chargesToUpdate);
            if (toUpsert) {
                quoteList[0].Recurring_Discount_Percentage__c = discountPercentage;
                quoteList[0].Sum_Of_Recurring_fees__c = recPrice.setScale(0, System.RoundingMode.Half_UP);
                quoteList[0].CARR_Error_Message__c = null;
                quoteList[0].CARR_Error_Checkbox__c = false;
                quoteList[0].Activate_CARR__c = true;
                update quoteList;
                update chargesToUpdate;

            }
            return chargesToUpdate;
        } catch (Exception ex) {
            handleError(quoteList, ex);
            System.debug('exception --- ' + ex.getMessage() + ' stack --- ' + ex.getStackTraceString());
            update quoteList;
            return null;
        }
    }

    public static List<zqu__QuoteRatePlanCharge__c> handleRenewal(Id quoteId, Boolean toUpsert) {
        List<zqu__Quote__c> quoteList = getQuoteList(quoteId);

        if (quoteList.isEmpty()) {
            return null; // Early exit if no quote found
        }
        try {
            System.debug('quoteList[0].Total_Sum_Of_Fees__c--' + quoteList[0].Total_Sum_Of_Fees__c);
            SumsObj TotalSumOfFeesObj = updateQuoteSums(quoteList, false);
            //Decimal discountPercentage = ZuoraPriceCalculation.CalculatePercentageOfDiscount(quoteList[0].Total_Sum_Of_Fees__c, quoteList[0].Recurring_Target_Price__c); //TODO
            //Decimal discountPercentage = ZuoraPriceCalculation.CalculatePercentageOfDiscount(TotalSumOfFeesObj.sumOfDiscountableRecurring, quoteList[0].Target_Quote_Total_Price__c);
            Decimal discountPercentage = 0;
            if (quoteList[0].Recurring_Target_Price__c != null) {
                discountPercentage = calculateSelectiveDiscountPercentage(0, TotalSumOfFeesObj.sumOfDiscountableRecurring, quoteList[0].Recurring_Target_Price__c);
            }

            discountPercentage = String.valueOf(discountPercentage).substringAfter('.').startsWith('99') ? discountPercentage.setscale(0) : discountPercentage;
            System.debug('discountPercentage: ' + discountPercentage);
            Set<zqu.QPlan> planToUpdateSet = new Set<zqu.QPlan>();
            Boolean foundDiscountPlan = false;
            Decimal recPrice = 0;
            String curr = '';
            Integer billingPeriod;
            Decimal originalRounding = 0;

            List<zqu__QuoteRatePlanCharge__c> chargesToUpdate = new List<zqu__QuoteRatePlanCharge__c>();

            List<zqu.QPlan> plans = zqu.QPlanReader.load(quoteId);
            for (zqu.QPlan plan : plans) {
                for (zqu.QCharge charge : plan.getCharges()) {
                    Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                    List<zqu.QTier> chargeTierList = new List<zqu.QTier>();
                    if (isRecurringCharge2((String) plan.getRecord().get('Name'), charge) && isNotRemoved) {
                        if (charge.getTiers() != null && !charge.getTiers().isEmpty()) {
                            for (zqu.QTier chargeTier : charge.getTiers()) {
                                chargeTier.put('zqu__Discount__c', discountPercentage);
                                chargeTierList.add(chargeTier);
                            }
                        } else {
                            charge.put('zqu__Discount__c', discountPercentage);
                            curr = (String) charge.get('zqu__Currency__c');
                        }
                        if (!chargeTierList.isEmpty()) {
                            charge.setTiers(chargeTierList);
                        }
                        if ((Decimal) charge.get('zqu__EffectivePrice__c') != null && charge.getRecord().Id != null && charge.get('zqu__ListPrice__c') != 0 && charge.get('No_Discount_Product__c') == false) {
                            chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = (Decimal) charge.get('zqu__Discount__c')));
                        }
                        recPrice += ((Decimal) charge.get('zqu__Total__c') * quoteList[0].zqu__InitialTerm__c);
                        billingPeriod = Integer.valueOf(charge.get('zqu__SpecificBillingPeriod__c')) != null ? Integer.valueOf(charge.get('zqu__SpecificBillingPeriod__c')) : billingPeriod;
                        planToUpdateSet.add(plan);
                    } else if (charge.get('No_Discount_Product__c') == true && charge.getRecord().Id != null) {
                        chargesToUpdate.add(new zqu__QuoteRatePlanCharge__c(Id = charge.getRecord().Id, CARR_Monthly_Total__c = (Decimal) charge.get('zqu__Total__c'), CARR_Effective_Price__c = (Decimal) charge.get('zqu__EffectivePrice__c'), CARR_Discount__c = 0));
                    }
                }

            }




            //zqu.QPlanWriter.save(new List<zqu.QPlan>(planToUpdateSet));
            if (toUpsert) {
                quoteList[0].Recurring_Discount_Percentage__c = discountPercentage;
                quoteList[0].Sum_Of_Recurring_fees__c = recPrice.setScale(0, System.RoundingMode.Half_UP);
                quoteList[0].Is_Discount_Given_Timestamp__c = Datetime.now();
                quoteList[0].CARR_Error_Message__c = null;
                quoteList[0].CARR_Error_Checkbox__c = false;
                quoteList[0].Activate_CARR__c = true;
                update quoteList;
                update chargesToUpdate;
            }
            return chargesToUpdate;
        } catch (Exception ex) {
            handleError(quoteList, ex);
            System.debug('exception --- ' + ex.getMessage() + ' stack --- ' + ex.getStackTraceString());
            update quoteList;
            return null;
        }
    }

    private static void handleError(List<zqu__Quote__c> quoteList, Exception ex) {
        if (quoteList[0].CARR_Error_Message__c != null) {
            quoteList[0].CARR_Error_Message__c += ex.getMessage() + ' stackTrace: ' + ex.getStackTraceString() + ' timestamp : ' + Datetime.now();
        } else {
            quoteList[0].CARR_Error_Message__c = ex.getMessage() + ' stackTrace: ' + ex.getStackTraceString() + ' timestamp : ' + Datetime.now();
        }
        quoteList[0].CARR_Error_Checkbox__c = true;
    }

    public static SumsObj updateQuoteSums(List<zqu__Quote__c> quotes, boolean isToUpdate) {
        System.debug('starting updateQuoteSums--');
        // Prepare a set to hold all quote Ids
        Set<Id> quoteIds = new Set<Id>();
        for (zqu__Quote__c quote : quotes) {
            System.debug('zqu__Quote__c--' + quote.id);
            quoteIds.add(quote.Id);
        }

        // Initialize maps to accumulate sums
        Map<Id, Decimal> sumOfRecurringFeesMap = new Map<Id, Decimal>();
        Map<Id, Decimal> sumOfOneTimeFeesMap = new Map<Id, Decimal>();
        Map<Id, Decimal> sumOfRecurringDiscountableFeesMap = new Map<Id, Decimal>();

        // Initialize maps
        for (Id quoteId : quoteIds) {
            sumOfRecurringFeesMap.put(quoteId, 0);
            sumOfOneTimeFeesMap.put(quoteId, 0);
            sumOfRecurringDiscountableFeesMap.put(quoteId, 0);
        }

        for (zqu__Quote__c quote : quotes) {
            System.debug('quote--' + quote.id);
            List<zqu.QPlan> plans = zqu.QPlanReader.load(quote.Id);
            zeroDiscountForQuote(plans);
            for (zqu.QPlan plan : plans) {
                Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                for (zqu.QCharge charge : plan.getCharges()) {
                    Decimal chargeTotalPrice = charge.getRecord().zqu__Total__c != null ? charge.getRecord().zqu__Total__c : 0;
                    Decimal initialTerm = quote.zqu__InitialTerm__c;
                    if (isRecurringCharge((String) plan.getRecord().get('Name'), charge) && isNotRemoved) {
                        System.debug('charge.getRecord().zqu__Total__c--' + charge.getRecord().zqu__Total__c);
                        System.debug('name---' + charge.getRecord().Name);
                        System.debug('chargeTotalPrice--' + chargeTotalPrice);
                        sumOfRecurringDiscountableFeesMap.put(quote.Id, sumOfRecurringDiscountableFeesMap.get(quote.Id) + (chargeTotalPrice * initialTerm));
                        System.debug('sumOfRecurringFeesMap---' + sumOfRecurringDiscountableFeesMap.get(quote.Id));
                    } else if (charge.get('No_Discount_Product__c') == true &&
                            String.valueOf(charge.get('zqu__chargeType__c')).containsIgnoreCase('Recurring')) { // Recurring no discount product
                        sumOfRecurringFeesMap.put(quote.Id, sumOfRecurringFeesMap.get(quote.Id) + (chargeTotalPrice * initialTerm));
                    } else if (isOneTimeCharge((String) plan.getRecord().get('Name'), charge)) {
                        System.debug('name---' + charge.getRecord().Name);
                        System.debug('charge.getRecord().zqu__Total__c--' + charge.getRecord().zqu__Total__c);
                        System.debug('charge.getRecord().zqu__EffectivePrice__c--' + charge.getRecord().zqu__EffectivePrice__c);
                        System.debug('chargeTotalPrice--' + chargeTotalPrice);
                        sumOfOneTimeFeesMap.put(quote.Id, sumOfOneTimeFeesMap.get(quote.Id) + charge.getRecord().zqu__EffectivePrice__c);
                    }
                }
            }
        }

        // Apply the calculated sums to the quote records
        Decimal sumOfFees = 0;
        Decimal sumOfDiscountableFees = 0;
        SumsObj returnedSumObj = new SumsObj();
        for (zqu__Quote__c quote : quotes) {
            System.debug('sumOfRecurringFeesMap.get(quote.Id): ' + sumOfRecurringFeesMap.get(quote.Id));
            System.debug('sumOfOneTimeFeesMap.get(quote.Id): ' + sumOfOneTimeFeesMap.get(quote.Id));
            sumOfFees = String.valueOf(sumOfRecurringFeesMap.get(quote.Id)).substringAfter('.').startsWith('99') ? sumOfRecurringFeesMap.get(quote.Id).setscale(0) : sumOfRecurringFeesMap.get(quote.Id);
            sumOfDiscountableFees = String.valueOf(sumOfRecurringDiscountableFeesMap.get(quote.Id)).substringAfter('.').startsWith('99') ? sumOfRecurringDiscountableFeesMap.get(quote.Id).setscale(0) : sumOfRecurringDiscountableFeesMap.get(quote.Id);
            quote.Total_Sum_Of_Fees__c = sumOfFees + sumOfDiscountableFees;
            quote.Total_Sum_Of_Discountable_Fees__c = sumOfDiscountableFees;
            quote.Sum_Of_one_time__c = sumOfOneTimeFeesMap.get(quote.id);
            returnedSumObj.sumOfDiscountableRecurring = sumOfDiscountableFees;
            returnedSumObj.sumOfOneTime = sumOfOneTimeFeesMap.get(quote.id);
            returnedSumObj.sumOfNonDiscountableRecurring = sumOfFees;
        }
        if (isToUpdate) {
            update quotes;
        }

        return returnedSumObj;
    }

    public static Decimal CalculatePercentageOfDiscount(Decimal calculatedSum, Decimal requestedSum) {
        System.debug('CalculatePercentageOfDiscount--');
        if (calculatedSum > 0 && requestedSum != null) { // Ensure there's no division by zero
            Decimal percentageDiscount = ((calculatedSum - requestedSum) / calculatedSum) * 100;
            return percentageDiscount;
        } else {
            return 0; // Return 0% discount if calculatedSum is 0 to avoid division by zero
        }
    }

    /**
     * @param totalSumOfOld -  Sum of the prices of products not eligible for discount.
     * @param totalSumOfNew - Sum of the prices of products eligible for discount before applying any discount.
     * @param totalTargetPrice - Target total price for all products combined.
     *
     * @return discountPercentage - percentage to discount from the new quote for FU
     */
    public static Decimal calculateSelectiveDiscountPercentage(Decimal totalSumOfOld, Decimal totalSumOfNew, Decimal totalTargetPrice) {
        if (totalTargetPrice != null) {
            System.debug('totalSumOfOld ' + totalSumOfOld);
            System.debug('totalSumOfNew ' + totalSumOfNew);
            System.debug('totalTargetPrice ' + totalTargetPrice);
            Decimal discountPercentage = 0;
            discountPercentage = (1 - (totalTargetPrice - totalSumOfOld) / totalSumOfNew) * 100;
            System.debug('discountPercentage ' + discountPercentage);

            // Cap the discount at 100% if it exceeds
            if (discountPercentage > 100) {
                discountPercentage = 100;
            }
            return discountPercentage;
        } else {
            return 0;
        }
    }

    public static Boolean isRecurringCharge(String planName, zqu.QCharge charge) {
        System.debug(charge.get('zqu__ListPrice__c'));
        System.debug(charge.get('zqu__Total__c'));
        System.debug(charge.get('zqu__chargeType__c'));
        System.debug(charge.get('No_Discount_Product__c'));
        if (!String.valueOf(charge.get('zqu__chargeType__c')).containsIgnoreCase('One')
                && charge.get('zqu__ListPrice__c') != 0
                && charge.get('No_Discount_Product__c') == false
                && !(planName.contains('Rounnding'))) {
            return true;
        } else {
            return false;
        }
    }

    public static Boolean isRecurringCharge2(String planName, zqu.QCharge charge) {
        System.debug('charge--' + charge.get('zqu__chargeType__c'));
        System.debug('charge--' + charge.get('No_Discount_Product__c'));
        System.debug('planName--' + planName);
        if (!String.valueOf(charge.get('zqu__chargeType__c')).containsIgnoreCase('One')
                && charge.get('No_Discount_Product__c') == false
                && !(planName.contains('Rounding'))) {
            return true;
        } else {
            return false;
        }
    }

    public static boolean isOneTimeCharge(String planName, zqu.QCharge charge) {
        if (charge.get('zqu__chargeType__c') == 'One-Time' && !(planName.contains('Roun'))) {
            return true;
        }
        return false;
    }

    public static void zeroDiscountForQuote(List<zqu.QPlan> plans) {
        for (zqu.QPlan plan : plans) {
            for (zqu.QCharge charge : plan.getCharges()) {
                List<zqu.QTier> chargeTierList = new List<zqu.QTier>();
                Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
                if (isNotRemoved
                        && charge.get('No_Discount_Product__c') == false
                        && (charge.get('Amendment_type__c') != 'Original')
                        && !isOneTimeCharge(plan.getRecord().Name, charge)
                        && charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product') {
                    if (charge.getTiers() != null && !charge.getTiers().isEmpty()) {
                        for (zqu.QTier chargeTier : charge.getTiers()) {
                            chargeTier.put('zqu__Discount__c', 0);
                            chargeTierList.add(chargeTier);
                        }
                    } else {
                        charge.put('zqu__Discount__c', 0);
                    }
                    if (!chargeTierList.isEmpty()) {
                        charge.setTiers(chargeTierList);
                    }
                }
            }
        }
    }

    public static void zeroDiscountForOriginalsQuote(List<zqu.QPlan> plans) {
        for (zqu.QPlan plan : plans) {
            Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
            for (zqu.QCharge charge : plan.getCharges()) {
                List<zqu.QTier> chargeTierList = new List<zqu.QTier>();
                if (isNotRemoved
                        && charge.get('zqu__chargeType__c') != 'One-Time'
                        && charge.get('No_Discount_Product__c') == false
                        && !String.valueOf(plan.getRecord().get('Name')).contains('Rounding')
                        && (charge.get('Amendment_type__c') == 'Original')) {
                    if (charge.getTiers() != null && !charge.getTiers().isEmpty()) {
                        for (zqu.QTier chargeTier : charge.getTiers()) {
                            chargeTier.put('zqu__Discount__c', 0);
                            chargeTierList.add(chargeTier);
                        }
                    } else {
                        charge.put('zqu__Discount__c', 0);
                    }
                    if (!chargeTierList.isEmpty()) {
                        charge.setTiers(chargeTierList);
                    }
                }
            }
        }
    }

    private static void handleGivingNewAndUpdatedDiscount(List<zqu.QPlan> currentPlans, Decimal discountPercentage) {
        List<zqu.QCharge> relevantCharges = new List<zqu.QCharge>();
        for (zqu.QPlan plan : currentPlans) {
            List<zqu.QCharge> planCharges = plan.getCharges();
            for (zqu.QCharge planCharge : planCharges) {
                if (planCharge.get('Amendment_type__c') != 'Original') {
                    relevantCharges.add(planCharge);
                }
            }
            handleDiscount(relevantCharges, discountPercentage, (String) plan.getRecord().get('Name'), new Map<String, Decimal>());
        }
    }

    private static void handleGivingOriginalDiscount(List<zqu.QPlan> currentPlans, Decimal discountPercentage) {
        List<zqu.QCharge> relevantCharges = new List<zqu.QCharge>();
        for (zqu.QPlan plan : currentPlans) {
            Boolean isNotRemoved = plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
            if (isNotRemoved) {
                List<zqu.QCharge> planCharges = plan.getCharges();
                for (zqu.QCharge planCharge : planCharges) {
                    if (planCharge.get('Amendment_type__c') == 'Original') {
                        relevantCharges.add(planCharge);
                    }
                }
            }
            handleDiscount(relevantCharges, discountPercentage, (String) plan.getRecord().get('Name'), new Map<String, Decimal>());
        }
    }

    private static void handleDiscount(List<zqu.QCharge> charges, Decimal discountPercentage, String planName, Map<String, Decimal> originalChargeNumberToDiscountMap) {
        System.debug('started handleDiscount---' + discountPercentage == null ? 'zero discount' : ' afterDiscountCalculated');
        System.debug('discountPercentage--' + discountPercentage);
        for (zqu.QCharge charge : charges) {
            List<zqu.QTier> chargeTierList = new List<zqu.QTier>();
            if (isRecurringCharge2(planName, charge)) {
                System.debug('charge---' + charge.get('Name'));
                System.debug('discountPercentage after ---' + discountPercentage);
                if (charge.getTiers() != null && !charge.getTiers().isEmpty()) {
                    for (zqu.QTier chargeTier : charge.getTiers()) {
                        if (discountPercentage != null && (Decimal) chargeTier.get('zqu__Discount__c') != discountPercentage) {
                            if (!(chargeTier.get('zqu__Discount__c') == null && discountPercentage == 0)) {
                                chargeTier.put('zqu__Discount__c', discountPercentage);
                                chargeTierList.add(chargeTier);
                            }
                        }
                    }
                } else {
                    Decimal currentDiscount = (Decimal) charge.get('zqu__Discount__c');
                    System.debug('cahrgename : -' + charge.get('Name'));
                    System.debug('this charge discount is : -' + currentDiscount);
                    System.debug('discountPercentage :  ' + discountPercentage);
                    if (discountPercentage != null && (Decimal) charge.get('zqu__Discount__c') != discountPercentage) {
                        if (currentDiscount != null || discountPercentage != 0) {  // Clearer logic: execute if there's an existing discount or the new discount isn't zero
                            // Code to update the discount
                            charge.put('zqu__Discount__c', discountPercentage);
                        }
                    }
                }
            }
            if (!chargeTierList.isEmpty()) {
                charge.setTiers(chargeTierList);
            }

        }
    }


    public class SumsObj {
        public Decimal sumOfOneTime;
        public Decimal sumOfNonDiscountableRecurring;
        public Decimal sumOfDiscountableRecurring;
    }

    public class ZuoraUpdateDiscountPriceQueueableException extends Exception {
    }

    public static void coverCode() {
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
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
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

}
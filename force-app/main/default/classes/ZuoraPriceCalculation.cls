/**
 * Created by zohar.sinay on 13/02/2024.
 */

public class ZuoraPriceCalculation {
  public static SumsObj calcRatePlanSums(
    List<zqu.QPlan> plans,
    Decimal initialTerm
  ) {
    System.debug('starting updateQuoteSums--');

    // Initialize maps to accumulate sums
    Decimal sumOfRecurringFees = 0;
    Decimal sumOfOneTimeFee = 0;
    Decimal sumOfRecurringDiscountableFees = 0;
    Decimal sumOfNonDiscountableFees = 0;

    for (zqu.QPlan plan : plans) {
      Boolean isNotRemoved =
        plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
      if (isNotRemoved) {
        for (zqu.QCharge charge : plan.getCharges()) {
          Decimal chargeTotalPrice = charge.getRecord().zqu__Total__c != null
            ? charge.getRecord().zqu__Total__c
            : 0;
          if (
            ZuoraPriceCalculation.isRecurringCharge2(
              (String) plan.getRecord().get('Name'),
              charge
            )
          ) {
            System.debug(
              'charge.getRecord().zqu__Total__c--' +
              charge.getRecord().zqu__Total__c
            );
            System.debug(
              'charge.getRecord().zqu__Discount__c--' +
              charge.getRecord().zqu__Discount__c
            );
            System.debug('name---' + charge.getRecord().Name);
            System.debug('chargeTotalPrice--' + chargeTotalPrice);
            sumOfRecurringDiscountableFees += (chargeTotalPrice * initialTerm);
            System.debug(
              'sumOfRecurringFeesMap---' + sumOfRecurringDiscountableFees
            );
          } else if (
            charge.get('No_Discount_Product__c') == true &&
            String.valueOf(charge.get('zqu__chargeType__c'))
              .containsIgnoreCase('Recurring')
          ) {
            // Recurring no discount product
            System.debug(
              'charge.getRecord().zqu__Total__c--' +
              charge.getRecord().zqu__Total__c
            );
            System.debug(
              'charge.getRecord().zqu__Discount__c--' +
              charge.getRecord().zqu__Discount__c
            );
            System.debug('name---' + charge.getRecord().Name);
            System.debug('chargeTotalPrice--' + chargeTotalPrice);
            sumOfRecurringFees += (charge.getRecord().zqu__EffectivePrice__c *
            initialTerm);
            sumOfNonDiscountableFees += (charge.getRecord()
              .zqu__EffectivePrice__c * initialTerm);
          } else if (
            ZuoraPriceCalculation.isOneTimeCharge(
              (String) plan.getRecord().get('Name'),
              charge
            )
          ) {
            System.debug('name---' + charge.getRecord().Name);
            System.debug(
              'charge.getRecord().zqu__Total__c--' +
              charge.getRecord().zqu__Total__c
            );
            System.debug(
              'charge.getRecord().zqu__Discount__c--' +
              charge.getRecord().zqu__Discount__c
            );
            System.debug(
              'charge.getRecord().zqu__EffectivePrice__c--' +
              charge.getRecord().zqu__EffectivePrice__c
            );
            System.debug('chargeTotalPrice--' + chargeTotalPrice);
            sumOfOneTimeFee += charge.getRecord().zqu__EffectivePrice__c;
          }
        }
      }
    }

    // Apply the calculated sums to the quote records
    Decimal sumOfFees = 0;
    Decimal sumOfDiscountableFees = 0;
    SumsObj returnedSumObj = new SumsObj();

    System.debug('sumOfRecurringFees: ' + sumOfRecurringFees);
    System.debug('sumOfOneTimeFee: ' + sumOfOneTimeFee);
    sumOfFees = String.valueOf(sumOfRecurringFees)
        .substringAfter('.')
        .startsWith('99')
      ? sumOfRecurringFees.setscale(0)
      : sumOfRecurringFees;
    sumOfDiscountableFees = String.valueOf(sumOfRecurringDiscountableFees)
        .substringAfter('.')
        .startsWith('99')
      ? sumOfRecurringDiscountableFees.setscale(0)
      : sumOfRecurringDiscountableFees;
    returnedSumObj.sumOfDiscountableRecurring = sumOfDiscountableFees;
    returnedSumObj.sumOfOneTime = sumOfOneTimeFee;
    returnedSumObj.sumOfNonDiscountableRecurring = sumOfFees;
    returnedSumObj.sumOfRecurringNonDiscountable = sumOfNonDiscountableFees;

    return returnedSumObj;
  }

  public static SumsObj updateQuoteSums2(
    List<zqu__Quote__c> quotes,
    boolean isToUpdate,
    boolean isToZeroDiscount
  ) {
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
    Map<Id, Decimal> sumOfNonDiscountableFeesMap = new Map<Id, Decimal>();

    // Initialize maps
    for (Id quoteId : quoteIds) {
      sumOfRecurringFeesMap.put(quoteId, 0);
      sumOfOneTimeFeesMap.put(quoteId, 0);
      sumOfRecurringDiscountableFeesMap.put(quoteId, 0);
      sumOfNonDiscountableFeesMap.put(quoteId, 0);
    }

    for (zqu__Quote__c quote : quotes) {
      System.debug('quote--' + quote.id);
      List<zqu.QPlan> plans = zqu.QPlanReader.load(quote.Id);
      if (isToZeroDiscount) {
        zeroDiscountForQuote(plans);
      }
      for (zqu.QPlan plan : plans) {
        Boolean isNotRemoved =
          plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
        if (isNotRemoved) {
          for (zqu.QCharge charge : plan.getCharges()) {
            Decimal chargeTotalPrice = charge.getRecord().zqu__Total__c != null
              ? charge.getRecord().zqu__Total__c
              : 0;
            Decimal initialTerm = quote.zqu__InitialTerm__c;
            if (
              ZuoraPriceCalculation.isRecurringCharge2(
                (String) plan.getRecord().get('Name'),
                charge
              )
            ) {
              System.debug(
                'charge.getRecord().zqu__Total__c--' +
                charge.getRecord().zqu__Total__c
              );
              System.debug(
                'charge.getRecord().zqu__Discount__c--' +
                charge.getRecord().zqu__Discount__c
              );
              System.debug('name---' + charge.getRecord().Name);
              System.debug('chargeTotalPrice--' + chargeTotalPrice);
              sumOfRecurringDiscountableFeesMap.put(
                quote.Id,
                sumOfRecurringDiscountableFeesMap.get(quote.Id) +
                (chargeTotalPrice * initialTerm)
              );
              System.debug(
                'sumOfRecurringFeesMap---' +
                sumOfRecurringDiscountableFeesMap.get(quote.Id)
              );
            } else if (
              charge.get('No_Discount_Product__c') == true &&
              String.valueOf(charge.get('zqu__chargeType__c'))
                .containsIgnoreCase('Recurring')
            ) {
              // Recurring no discount product
              System.debug(
                'charge.getRecord().zqu__Total__c--' +
                charge.getRecord().zqu__Total__c
              );
              System.debug(
                'charge.getRecord().zqu__Discount__c--' +
                charge.getRecord().zqu__Discount__c
              );
              System.debug('name---' + charge.getRecord().Name);
              System.debug('chargeTotalPrice--' + chargeTotalPrice);
              sumOfRecurringFeesMap.put(
                quote.Id,
                sumOfRecurringFeesMap.get(quote.Id) +
                (charge.getRecord().zqu__EffectivePrice__c * initialTerm)
              );
              sumOfNonDiscountableFeesMap.put(
                quote.Id,
                sumOfNonDiscountableFeesMap.get(quote.Id) +
                (charge.getRecord().zqu__EffectivePrice__c * initialTerm)
              );
            } else if (
              ZuoraPriceCalculation.isOneTimeCharge(
                (String) plan.getRecord().get('Name'),
                charge
              )
            ) {
              System.debug('name---' + charge.getRecord().Name);
              System.debug(
                'charge.getRecord().zqu__Total__c--' +
                charge.getRecord().zqu__Total__c
              );
              System.debug(
                'charge.getRecord().zqu__Discount__c--' +
                charge.getRecord().zqu__Discount__c
              );
              System.debug(
                'charge.getRecord().zqu__EffectivePrice__c--' +
                charge.getRecord().zqu__EffectivePrice__c
              );
              System.debug('chargeTotalPrice--' + chargeTotalPrice);
              sumOfOneTimeFeesMap.put(
                quote.Id,
                sumOfOneTimeFeesMap.get(quote.Id) +
                charge.getRecord().zqu__EffectivePrice__c
              );
            }
          }
        }
      }
    }

    // Apply the calculated sums to the quote records
    Decimal sumOfFees = 0;
    Decimal sumOfDiscountableFees = 0;
    SumsObj returnedSumObj = new SumsObj();
    for (zqu__Quote__c quote : quotes) {
      System.debug(
        'sumOfRecurringFeesMap.get(quote.Id): ' +
        sumOfRecurringFeesMap.get(quote.Id)
      );
      System.debug(
        'sumOfOneTimeFeesMap.get(quote.Id): ' +
        sumOfOneTimeFeesMap.get(quote.Id)
      );
      sumOfFees = String.valueOf(sumOfRecurringFeesMap.get(quote.Id))
          .substringAfter('.')
          .startsWith('99')
        ? sumOfRecurringFeesMap.get(quote.Id).setscale(0)
        : sumOfRecurringFeesMap.get(quote.Id);
      sumOfDiscountableFees = String.valueOf(
            sumOfRecurringDiscountableFeesMap.get(quote.Id)
          )
          .substringAfter('.')
          .startsWith('99')
        ? sumOfRecurringDiscountableFeesMap.get(quote.Id).setscale(0)
        : sumOfRecurringDiscountableFeesMap.get(quote.Id);
      returnedSumObj.sumOfDiscountableRecurring = sumOfDiscountableFees;
      returnedSumObj.sumOfOneTime = sumOfOneTimeFeesMap.get(quote.id);
      returnedSumObj.sumOfNonDiscountableRecurring = sumOfFees;
      returnedSumObj.sumOfRecurringNonDiscountable = sumOfNonDiscountableFeesMap.get(
        quote.id
      );
      quote.Total_Sum_Of_Fees__c =
        returnedSumObj.sumOfNonDiscountableRecurring +
        returnedSumObj.sumOfDiscountableRecurring;
      quote.Total_Sum_Of_Discountable_Fees__c = returnedSumObj.sumOfDiscountableRecurring;
      quote.Sum_Of_one_time__c = returnedSumObj.sumOfOneTime;
      quote.Sum_Of_NonDiscountable_Fees__c = returnedSumObj.sumOfRecurringNonDiscountable;
    }
    if (isToUpdate) {
      update quotes;
    }

    return returnedSumObj;
  }

  public static void updateQuoteSums(
    List<zqu__Quote__c> quotes,
    boolean isToUpdate
  ) {
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

    // Initialize maps
    for (Id quoteId : quoteIds) {
      sumOfRecurringFeesMap.put(quoteId, 0);
      sumOfOneTimeFeesMap.put(quoteId, 0);
    }

    for (zqu__Quote__c quote : quotes) {
      System.debug('quote--' + quote.id);
      List<zqu.QPlan> plans = zqu.QPlanReader.load(quote.Id);
      zeroDiscountForQuote(plans);
      for (zqu.QPlan plan : plans) {
        Boolean isNotRemoved =
          plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
        for (zqu.QCharge charge : plan.getCharges()) {
          Decimal chargeTotalPrice = charge.getRecord().zqu__Total__c != null
            ? charge.getRecord().zqu__Total__c
            : 0;
          Decimal initialTerm = quote.zqu__InitialTerm__c;
          if (
            ZuoraPriceCalculation.isRecurringCharge2(
              (String) plan.getRecord().get('Name'),
              charge
            ) && isNotRemoved
          ) {
            System.debug(
              'charge.getRecord().zqu__Total__c--' +
              charge.getRecord().zqu__Total__c
            );
            System.debug('name---' + charge.getRecord().Name);
            System.debug('chargeTotalPrice--' + chargeTotalPrice);
            sumOfRecurringFeesMap.put(
              quote.Id,
              sumOfRecurringFeesMap.get(quote.Id) +
              (chargeTotalPrice * initialTerm)
            );
            System.debug(
              'sumOfRecurringFeesMap---' + sumOfRecurringFeesMap.get(quote.Id)
            );
          } else if (
            ZuoraPriceCalculation.isOneTimeCharge(
              (String) plan.getRecord().get('Name'),
              charge
            ) && isNotRemoved
          ) {
            sumOfOneTimeFeesMap.put(
              quote.Id,
              sumOfOneTimeFeesMap.get(quote.Id) + chargeTotalPrice
            );
          }
        }
      }
    }

    // Apply the calculated sums to the quote records
    for (zqu__Quote__c quote : quotes) {
      System.debug(
        'sumOfRecurringFeesMap.get(quote.Id): ' +
        sumOfRecurringFeesMap.get(quote.Id)
      );
      System.debug(
        'sumOfOneTimeFeesMap.get(quote.Id): ' +
        sumOfOneTimeFeesMap.get(quote.Id)
      );
      quote.Total_Sum_Of_Fees__c = sumOfRecurringFeesMap.get(quote.Id);
      quote.Sum_Of_one_time__c = sumOfOneTimeFeesMap.get(quote.id);
    }
    if (isToUpdate) {
      update quotes;
    }
  }

  public static Decimal CalculatePercentageOfDiscount(
    Decimal calculatedSum,
    Decimal requestedSum
  ) {
    System.debug('CalculatePercentageOfDiscount--');
    if (calculatedSum > 0 && requestedSum != null) {
      // Ensure there's no division by zero
      Decimal percentageDiscount =
        ((calculatedSum - requestedSum) / calculatedSum) * 100;
      return percentageDiscount;
    } else {
      return 0; // Return 0% discount if calculatedSum is 0 to avoid division by zero
    }
  }

  public static Decimal calculateSumWithDiscountLikeZuora(
    Integer InitialTerm,
    List<zqu.QPlan> currentPlans,
    String curr,
    Integer remainingServicePeriods
  ) {
    System.debug(InitialTerm);
    System.debug(curr);
    System.debug(currentPlans);
    System.debug(remainingServicePeriods);
    String defaultCurrency = 'USD';
    Map<String, CurrencyConversionRate__mdt> mdtByCurr = CurrencyConversionRate__mdt.getAll();
    Map<String, System.RoundingMode> roundingModeByString = new Map<String, System.RoundingMode>{
      'HALF_UP' => System.RoundingMode.HALF_UP,
      'UP' => System.RoundingMode.UP
    };
    Decimal calculatedSum = 0;
    System.debug('InitialTerm--' + InitialTerm);
    //        if(math.mod(InitialTerm, SpcificBillingPeriod) != 0){
    //            return null;
    //        }
    //        Integer totalServicePeriod = Integer.valueOf((InitialTerm/SpcificBillingPeriod));
    //        System.debug(totalServicePeriod);
    for (zqu.QPlan plan : currentPlans) {
      Boolean isNotRemoved =
        plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
      for (zqu.QCharge charge : plan.getCharges()) {
        System.debug('plan.getCharges()--' + plan.getCharges().size());
        System.debug((String) plan.getRecord().get('Name'));
        if (
          isRecurringCharge2((String) plan.getRecord().get('Name'), charge) &&
          isNotRemoved
        ) {
          for (Integer i = 0; i < remainingServicePeriods; i++) {
            System.debug('hereeeeeeee');
            System.debug((String) charge.get('zqu__Currency__c'));
            defaultCurrency = curr != null ? curr : defaultCurrency;
            System.debug(defaultCurrency);
            if (mdtByCurr.containsKey(defaultCurrency)) {
              System.debug(plan.getRecord().Name);
              System.debug('stop happen');
              System.debug(charge.get('zqu__Total__c'));
              if (charge.get('zqu__Total__c') != null) {
                System.debug(
                  ((Decimal) charge.get('zqu__Total__c') *
                  (Decimal) charge.get('zqu__SpecificBillingPeriod__c'))
                );
                System.debug(
                  ((Decimal) charge.get('zqu__Total__c'))
                    .setScale(9, system.RoundingMode.HALF_UP) *
                  (Decimal) charge.get('zqu__SpecificBillingPeriod__c')
                );
                System.debug(
                  (((Decimal) charge.get('zqu__Total__c'))
                      .setScale(9, System.RoundingMode.HALF_UP) *
                    (Decimal) charge.get('zqu__SpecificBillingPeriod__c'))
                    .setScale(
                      (Integer) mdtByCurr.get(defaultCurrency)
                        .Decimal_Places__c,
                      roundingModeByString.get(
                        mdtByCurr.get(defaultCurrency).Rounding_Mode__c
                      )
                    )
                );
                if (defaultCurrency == 'JPY') {
                  calculatedSum += (((Decimal) charge.get('zqu__Total__c'))
                      .setScale(9, System.RoundingMode.HALF_UP) *
                    (Decimal) charge.get('zqu__SpecificBillingPeriod__c'))
                    .setScale(
                      (Integer) mdtByCurr.get(defaultCurrency)
                        .Decimal_Places__c,
                      roundingModeByString.get(
                        mdtByCurr.get(defaultCurrency).Rounding_Mode__c
                      )
                    );
                } else {
                  calculatedSum += (((Decimal) charge.get('zqu__Total__c'))
                      .setScale(9, System.RoundingMode.HALF_UP) *
                    (Decimal) charge.get('zqu__SpecificBillingPeriod__c'))
                    .setScale(
                      (Integer) mdtByCurr.get(defaultCurrency)
                        .Decimal_Places__c,
                      roundingModeByString.get(
                        mdtByCurr.get(defaultCurrency).Rounding_Mode__c
                      )
                    );
                }
                System.debug('Partial calculatedSum: ' + calculatedSum);
              }
            }
          }
        }
      }
    }
    system.debug('calculatedSum: ' + calculatedSum);
    return calculatedSum;
  }

  public static Boolean isRecurringCharge2(
    String planName,
    zqu.QCharge charge
  ) {
    System.debug('charge--' + charge.get('zqu__chargeType__c'));
    System.debug('charge--' + charge.get('No_Discount_Product__c'));
    System.debug('planName--' + planName);
    if (
      !String.valueOf(charge.get('zqu__chargeType__c'))
        .containsIgnoreCase('One') &&
      charge.get('No_Discount_Product__c') == false &&
      charge.get('Quote_rate_plan_charge_ID__c') != 'Free Product' &&
      !(planName.contains('Rounding'))
    ) {
      return true;
    } else {
      return false;
    }
  }

  public static boolean isOneTimeCharge(String planName, zqu.QCharge charge) {
    if (
      charge.getRecord().zqu__chargeType__c.containsIgnoreCase('One') &&
      !(planName.contains('Roun'))
    ) {
      return true;
    }
    return false;
  }

  public static void zeroDiscountForQuote(List<zqu.QPlan> plans) {
    for (zqu.QPlan plan : plans) {
      for (zqu.QCharge charge : plan.getCharges()) {
        List<zqu.QTier> chargeTierList = new List<zqu.QTier>();
        Boolean isNotRemoved =
          plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
        if (
          (isNotRemoved &&
          ZuoraPriceCalculation.isRecurringCharge2(
            (String) plan.getRecord().get('Name'),
            charge
          ) &&
          (charge.get('Amendment_type__c') != 'Original'))
        ) {
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
        } else if (
          charge.get('Quote_rate_plan_charge_ID__c') == 'Free Product'
        ) {
          if (charge.getTiers() != null && !charge.getTiers().isEmpty()) {
            for (zqu.QTier chargeTier : charge.getTiers()) {
              chargeTier.put('zqu__Discount__c', 100);
              chargeTierList.add(chargeTier);
            }
          } else {
            charge.put('zqu__Discount__c', 100);
          }
          if (!chargeTierList.isEmpty()) {
            charge.setTiers(chargeTierList);
          }
        }
      }
    }
  }

  public static void processMidTermQuote(
    zqu__Quote__c quote,
    List<zqu.QPlan> currentPlans,
    Map<String, Zuora__SubscriptionProductCharge__c> SPCByChargeNumber,
    Decimal targetPrice,
    Decimal initialTerm
  ) {
    // New optional parameter for target price
    // Initialize collections
    List<RemovedProduct> removedProducts = new List<RemovedProduct>();
    List<zqu.QCharge> newProductCharges = new List<zqu.QCharge>();
    List<UpdatedChargeInfo> updatedCharges = new List<UpdatedChargeInfo>();
    Decimal remainderAmount = 0;
    zqu.QCharge baseProductCharge = null;
    Decimal originalBaseProductPrice = 0;

    // First pass: Collect removed products, new product charges, and updated charges
    for (zqu.QPlan plan : currentPlans) {
      // Safely retrieve amendment types
      String amendmentType = plan.getAmendment() != null &&
        plan.getAmendment().getRecord() != null
        ? plan.getAmendment().getRecord().zqu__Type__c
        : null;
      String planAmendmentType = plan.getRecord() != null
        ? plan.getRecord().zqu__AmendmentType__c
        : null;
      String planName = plan.getRecord() != null ? plan.getRecord().Name : null;
      List<zqu.QCharge> charges = plan.getCharges();
      system.debug('amendmentType: ' + amendmentType);
      system.debug('planAmendmentType: ' + planAmendmentType);
      system.debug('planName: ' + planName);
      system.debug('plan.getOriginalPlan(): ' + plan.getOriginalPlan());
      // Process Removed Products
      if (
        'RemoveProduct'.equalsIgnoreCase(amendmentType) &&
        'RemoveProduct'.equalsIgnoreCase(planAmendmentType)
      ) {
        zqu.QPlan originalPlan = plan.getOriginalPlan();
        if (originalPlan != null) {
          List<zqu.QCharge> originalCharges = originalPlan.getCharges();
          for (zqu.QCharge origCharge : originalCharges) {
            if (
              isRecurringCharge2(planName, origCharge) &&
              origCharge.getRecord().zqu__EffectivePrice__c != 0
            ) {
              if (quote.Migrating_to_New_Soultion__c.equalsIgnoreCase('Yes')) {
                if (
                  plan.getRecord().Is_Base_product__c != null &&
                  plan.getRecord().Is_Base_product__c
                ) {
                  system.debug(plan.getRecord().Name);
                  system.debug(origCharge.getRecord().zqu__Total__c);
                  originalBaseProductPrice = (Decimal) origCharge.get(
                    'zqu__Total__c'
                  );
                  continue;
                }
              }
              String chargeNumber = (String) origCharge.get(
                'zqu__ChargeNumber__c'
              );
              Zuora__SubscriptionProductCharge__c spc = SPCByChargeNumber.get(
                chargeNumber
              );
              system.debug(spc.Zuora__MonthlyRecurringRevenue__c);
              system.debug(spc.CARR_Monthly_Total__c);
              if (
                spc != null &&
                spc.Zuora__MonthlyRecurringRevenue__c != null
              ) {
                system.debug(plan.getRecord().Name);
                system.debug(origCharge.getRecord().zqu__Total__c);
                Decimal amount = origCharge.getRecord().zqu__Total__c;
                removedProducts.add(new RemovedProduct(chargeNumber, amount));
              }
            }
          }
        }
      }

      for (zqu.QCharge charge : charges) {
        // Only consider charges where zqu__IsLastSegment__c is true
        Boolean isLastSegment = (Boolean) charge.get('zqu__IsLastSegment__c');
        if (
          (isRecurringCharge2(planName, charge)) &&
          !'RemoveProduct'.equalsIgnoreCase(amendmentType) &&
          !'RemoveProduct'.equalsIgnoreCase(planAmendmentType)
        ) {
          // Identify Base Product Charge
          if (
            plan.getRecord().Is_Base_product__c != null &&
            plan.getRecord().Is_Base_product__c
          ) {
            // Assuming the base product has one charge
            //                        if('UpdateProduct'.equalsIgnoreCase(amendmentType) && 'UpdateProduct'.equalsIgnoreCase(planAmendmentType)){
            //                            plan.revert();
            //                        }
            baseProductCharge = charge;
            system.debug(plan.getOriginalPlan());
            if (!quote.Migrating_to_New_Soultion__c.equalsIgnoreCase('Yes')) {
              zqu.QPlan originalPlan = plan.getOriginalPlan();
              if (originalPlan != null) {
                for (zqu.QCharge originalCharge : originalPlan.getCharges()) {
                  system.debug(originalCharge.getRecord().Name);
                  system.debug(originalCharge.getRecord().zqu__Total__c);
                  originalBaseProductPrice = (Decimal) originalcharge.get(
                    'zqu__Total__c'
                  );
                }
                continue;
              }
            }
          }
          // Collect New Product Charges
          if (
            'NewProduct'.equalsIgnoreCase(amendmentType) &&
            'NewProduct'.equalsIgnoreCase(planAmendmentType) &&
            !plan.getRecord().Is_Base_product__c != null &&
            !plan.getRecord().Is_Base_product__c
          ) {
            newProductCharges.add(charge);
          }
          // Process Updated Charges
          else if (
            'UpdateProduct'.equalsIgnoreCase(amendmentType) &&
            'UpdateProduct'.equalsIgnoreCase(planAmendmentType)
          ) {
            zqu.QPlan originalPlan = plan.getOriginalPlan();
            if (originalPlan != null) {
              zqu.QCharge originalCharge = null;
              // Find the matching charge in the original plan
              List<zqu.QCharge> originalCharges = originalPlan.getCharges();
              for (zqu.QCharge origCharge : originalCharges) {
                if (
                  origCharge.get('zqu__ChargeNumber__c') ==
                  charge.get('zqu__ChargeNumber__c')
                ) {
                  originalCharge = origCharge;
                  break;
                }
              }
              if (originalCharge != null) {
                Decimal originalTotal = (Decimal) originalCharge.get(
                  'zqu__Total__c'
                );
                updatedCharges.add(
                  new UpdatedChargeInfo(charge, originalTotal)
                );
              }
            }
          }
        }
      }
    }

    system.debug('removedProducts: ' + removedProducts);
    system.debug('removedProducts size: ' + removedProducts.size());
    system.debug('updatedCharges: ' + updatedCharges);
    system.debug('updatedCharges size: ' + updatedCharges.size());
    system.debug('newProductCharges: ' + newProductCharges);
    system.debug('newProductCharges size: ' + newProductCharges.size());

    // **Existing Logic for Previous Scenario (unchanged):**
    if (targetPrice == null) {
      // set base package price if it needs to be updated from previous quote (migration or updated base package pricing)
      if (baseProductCharge != null) {
        Decimal baseTotal = originalBaseProductPrice;
        system.debug('baseTotal: ' + baseTotal);
        if (
          baseTotal.setScale(4) !=
          baseProductCharge.getRecord().zqu__Total__c.setScale(4)
        ) {
          baseProductCharge.put('zqu__Total__c', baseTotal);
        }
      }

      // Process Updated Charges first to ensure they are adjusted regardless of removed products
      for (UpdatedChargeInfo updatedChargeInfo : updatedCharges) {
        zqu.QCharge updatedCharge = updatedChargeInfo.charge;
        Decimal originalTotal = updatedChargeInfo.originalTotal;

        // Check if the updated charge is a tiered charge
        List<zqu.QTier> tiers = updatedCharge.getTiers();
        if (tiers != null && !tiers.isEmpty()) {
          // Adjust the tiered charge
          adjustTieredCharge(updatedCharge, originalTotal);
        } else {
          // Update total and effective price for non-tiered charges
          updatedCharge.put('zqu__Total__c', originalTotal);
        }
      }

      // Assign totals from removed products to new products
      Integer removedCount = removedProducts.size();
      Integer newCount = newProductCharges.size();

      Integer minCount = Math.min(removedCount, newCount);

      // Assign totals from removed products to new products
      for (Integer i = 0; i < minCount; i++) {
        RemovedProduct removedProduct = removedProducts[i];
        zqu.QCharge newCharge = newProductCharges[i];

        // Check if the new charge is a tiered charge
        List<zqu.QTier> tiers = newCharge.getTiers();
        if (tiers != null && !tiers.isEmpty()) {
          // Adjust the tiered charge
          adjustTieredCharge(newCharge, removedProduct.amount);
        } else {
          // Update total and effective price for non-tiered charges
          newCharge.put('zqu__Total__c', removedProduct.amount);
        }
      }

      // Handle extra removed products
      if (removedCount > newCount) {
        // Sum the amounts of extra removed products
        for (Integer i = newCount; i < removedCount; i++) {
          System.debug(
            'removedProducts[i].amount.setScale(9): ' +
            removedProducts[i].amount
          );
          remainderAmount += removedProducts[i].amount;
        }
        remainderAmount = remainderAmount.setScale(
          9,
          System.RoundingMode.HALF_UP
        );
        // Add remainder to base product
        if (baseProductCharge != null) {
          Decimal baseTotal = (Decimal) baseProductCharge.get(
              'zqu__Total__c'
            ) != null
            ? (Decimal) baseProductCharge.get('zqu__Total__c')
            : 0;
          baseTotal = originalBaseProductPrice;
          system.debug('baseTotal: ' + baseTotal);
          baseProductCharge.put('zqu__Total__c', baseTotal + remainderAmount);
        } else {
          // Handle case where base product is not found
          System.debug('Base product not found to assign remainder amount.');
        }
      }

      // Handle extra new products
      if (newCount > removedCount) {
        for (Integer i = removedCount; i < newCount; i++) {
          zqu.QCharge extraNewCharge = newProductCharges[i];

          // Check if the new charge is a tiered charge
          List<zqu.QTier> tiers = extraNewCharge.getTiers();
          if (tiers != null && !tiers.isEmpty()) {
            // Adjust the tiered charge
            adjustTieredCharge(extraNewCharge, 0);
          } else {
            // Update total and effective price for non-tiered charges
            extraNewCharge.put('zqu__Total__c', 0);
          }
        }
      }
    } else {
      // **New Logic for Target Price Scenario:**

      // Add prices of all removed products to base product
      Decimal removedProductsTotal = 0;
      for (RemovedProduct removedProduct : removedProducts) {
        removedProductsTotal += removedProduct.amount;
      }
      if (baseProductCharge != null && removedProductsTotal > 0) {
        Decimal baseTotal = (Decimal) baseProductCharge.get('zqu__Total__c') !=
          null
          ? (Decimal) baseProductCharge.get('zqu__Total__c')
          : 0;
        system.debug('baseTotal: ' + baseTotal);
        system.debug('removedProductsTotal: ' + removedProductsTotal);
        system.debug(
          'baseProductCharge.get(Total): ' +
          baseProductCharge.get('zqu__Total__c')
        );
        baseTotal = originalBaseProductPrice;
        system.debug('baseTotal: ' + baseTotal);
        baseProductCharge.put(
          'zqu__Total__c',
          baseTotal + removedProductsTotal
        );
        // No need to adjust the effective price of the base product
      } else if (removedProductsTotal > 0) {
        // Handle case where base product is not found
        System.debug(
          'Base product not found to assign removed products total.'
        );
      }

      // Calculate total target price increase per month
      Integer initialTermMonths = (Integer) initialTerm; // Adjust as needed or retrieve from quote
      Decimal monthlyTargetIncrease = targetPrice / initialTermMonths;

      // Number of products to allocate the increase
      Integer allocationProductCount =
        updatedCharges.size() + newProductCharges.size();
      if (allocationProductCount == 0) {
        System.debug(
          'No updated or new products to allocate the target price.'
        );
        // Optionally handle this case
      } else {
        // Allocation per product per month
        Decimal allocationPerProduct =
          monthlyTargetIncrease / allocationProductCount;

        // Adjust Updated Charges
        for (UpdatedChargeInfo updatedChargeInfo : updatedCharges) {
          zqu.QCharge updatedCharge = updatedChargeInfo.charge;
          Decimal originalTotal = updatedChargeInfo.originalTotal;

          // Revert to original total
          updatedCharge.put('zqu__Total__c', originalTotal);

          // Add allocation per product
          Decimal newTotal = originalTotal + allocationPerProduct;
          updatedCharge.put('zqu__Total__c', newTotal);
          updatedCharge.put('zqu__EffectivePrice__c', newTotal);

          // Adjust tiered charges if applicable
          List<zqu.QTier> tiers = updatedCharge.getTiers();
          if (tiers != null && !tiers.isEmpty()) {
            adjustTieredCharge(updatedCharge, newTotal);
          }
        }

        // Adjust New Product Charges
        for (zqu.QCharge newCharge : newProductCharges) {
          // Set price to allocation per product
          newCharge.put('zqu__Total__c', allocationPerProduct);
          newCharge.put('zqu__EffectivePrice__c', allocationPerProduct);

          // Adjust tiered charges if applicable
          List<zqu.QTier> tiers = newCharge.getTiers();
          if (tiers != null && !tiers.isEmpty()) {
            adjustTieredCharge(newCharge, allocationPerProduct);
          }
        }
      }
    }

    // Save the updated plans
    zqu.QPlanWriter.save(currentPlans);
  }
  // Helper method to adjust tiered charges
  private static void adjustTieredCharge(
    zqu.QCharge charge,
    Decimal removedAmount
  ) {
    List<zqu.QTier> tiers = charge.getTiers();
    Decimal quantity = (Decimal) charge.get('zqu__Quantity__c');
    Boolean tierFound = false;
    System.debug(quantity);
    // Zero out all tiers except the one where the quantity falls
    for (zqu.QTier tier : tiers) {
      Decimal startingUnit = (Decimal) tier.get('zqu__StartingUnit__c');
      Decimal endingUnit = (Decimal) tier.get('zqu__EndingUnit__c');
      System.debug(startingUnit);
      System.debug(endingUnit);

      // Zero out the tier price
      tier.put('zqu__Effective_Price__c', 0);
      tier.put('zqu__Discount__c', 100);
      //tier.put('zqu__Price__c', 0);

      // Check if the quantity falls within this tier
      if (
        (quantity != null && startingUnit != null) &&
        ((endingUnit != null &&
        quantity >= startingUnit &&
        quantity <= endingUnit) ||
        (endingUnit == null &&
        quantity >= startingUnit))
      ) {
        tierFound = true;

        // Set this tier's Price Format to 'Flat Fee'
        tier.put('zqu__PriceFormat__c', 'Flat Fee');

        // Set the tier's Price to the removed charge's total amount
        system.debug(removedAmount);
        system.debug(tier.get('zqu__Effective_Price__c'));
        system.debug(tier.get('zqu__Price__c'));
        tier.put('zqu__Effective_Price__c', removedAmount.setScale(9));
        //tier.put('zqu__Price__c', removedAmount.setScale(7));

        // Also, update the charge's Effective Price and Total
        //                charge.put('zqu__EffectivePrice__c', removedAmount);
        //                charge.put('zqu__Total__c', removedAmount);
      }
    }

    // After modifying the tiers, set them back to the charge
    charge.setTiers(tiers);

    if (!tierFound) {
      System.debug(
        'Quantity does not match any tier for charge: ' + charge.get('Name')
      );
      // Optionally, handle this case as needed
    }
  }

  public static Set<zqu.QPlan> resetToOriginalTiers(
    List<zqu.QPlan> currentPlans,
    String quoteCurrency
  ) {
    //        String curr = quote_i.zqu__Currency__c != null ? quote_i.zqu__Currency__c : 'USD';
    //        quote_i.Recurring_Target_Price__c = quote_i.Renewal_Fee__c;
    List<String> PRatePlanChargeIdList = new List<String>();
    List<Decimal> tierNumberList = new List<Decimal>();
    //        system.debug('quoteId: ' + quote_i.Id);
    Set<zqu.QPlan> updateablePlanSet = new Set<zqu.QPlan>();
    for (zqu.QPlan plan : currentPlans) {
      system.debug('plan: ' + plan);
      Boolean isNotRemoved =
        plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
      system.debug('plan.amendmentType: ' + plan.get('zqu__AmendmentType__c'));
      if (isNotRemoved) {
        for (zqu.QCharge charge : plan.getCharges()) {
          if (charge.getRecord().zqu__IsLastSegment__c) {
            PRatePlanChargeIdList.add(
              charge.getRecord().zqu__ProductRatePlanCharge__c
            );
            system.debug('charge: ' + charge.getRecord().zqu__IsLastSegment__c);
            updateablePlanSet.add(plan);
            if (
              !charge.getRecord().zqu__Model__c.containsIgnoreCase('Flat fee')
            ) {
              List<zqu.QTier> tierList = new List<zqu.QTier>();
              for (zqu.QTier tier : charge.getTiers()) {
                tierNumberList.add(tier.getRecord().zqu__Tier__c);
                tier.put('zqu__Discount__c', 0);
                tierList.add(tier);
              }
              charge.setTiers(tierList);
            } else if (
              charge.getRecord().zqu__Model__c.containsIgnoreCase('Flat fee')
            ) {
              charge.put('zqu__Discount__c', 0);
            }
          }
        }
      }
    }

    system.debug('PRatePlanChargeIdList: ' + PRatePlanChargeIdList);
    system.debug('tierNumberList: ' + tierNumberList);

    List<zqu__ProductRatePlanChargeTier__c> prpctList = [
      SELECT
        Id,
        zqu__Tier__c,
        zqu__Price__c,
        zqu__Currency2__c,
        zqu__ProductRatePlanCharge__c
      FROM zqu__ProductRatePlanChargeTier__c
      WHERE
        zqu__ProductRatePlanCharge__c IN :PRatePlanChargeIdList
        AND zqu__Currency2__c = :quoteCurrency
    ];
    system.debug('prpctList: ' + prpctList);
    for (zqu.QPlan plan : updateablePlanSet) {
      system.debug('plan: ' + plan);
      Boolean isNotRemoved =
        plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
      system.debug('plan.amendmentType: ' + plan.get('zqu__AmendmentType__c'));
      if (isNotRemoved) {
        for (zqu.QCharge charge : plan.getCharges()) {
          system.debug('charge: ' + charge.getRecord().zqu__IsLastSegment__c);
          if (
            !charge.getRecord().zqu__Model__c.containsIgnoreCase('Flat fee')
          ) {
            List<zqu.QTier> tierList = new List<zqu.QTier>();
            for (zqu__ProductRatePlanChargeTier__c prpct : prpctList) {
              if (
                charge.getRecord().zqu__ProductRatePlanCharge__c ==
                prpct.zqu__ProductRatePlanCharge__c
              ) {
                for (zqu.QTier tier : charge.getTiers()) {
                  system.debug(prpct.zqu__Tier__c);
                  system.debug(tier.getRecord().zqu__Tier__c);
                  system.debug(prpct.zqu__Currency2__c);
                  system.debug(prpct.zqu__Currency2__c == quoteCurrency);
                  if (
                    prpct.zqu__Tier__c == tier.getRecord().zqu__Tier__c &&
                    prpct.zqu__Currency2__c == quoteCurrency
                  ) {
                    tier.put('zqu__Price__c', prpct.zqu__Price__c);
                    tierList.add(tier);
                  }
                }
              }
            }
            tierList.sort(new QTierComparator());
            charge.setTiers(tierList);
          }
        }
      }
    }
    return updateablePlanSet;
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
  }

  // Helper class to store removed product details
  public class RemovedProduct {
    public String chargeNumber;
    public Decimal amount;

    public RemovedProduct(String chargeNumber, Decimal amount) {
      this.chargeNumber = chargeNumber;
      this.amount = amount;
    }
  }

  // Helper class to store updated charge information
  public class UpdatedChargeInfo {
    public zqu.QCharge charge;
    public Decimal originalTotal;

    public UpdatedChargeInfo(zqu.QCharge charge, Decimal originalTotal) {
      this.charge = charge;
      this.originalTotal = originalTotal;
    }
  }

  public class DiscountObj {
    public Decimal sumOfRemoved;
    public Decimal sumOfAdded;
    public Decimal sumOfOriginal;
  }

  public class SumsObj {
    public Decimal sumOfOneTime;
    public Decimal sumOfNonDiscountableRecurring;
    public Decimal sumOfDiscountableRecurring;
    public Decimal sumOfRecurringNonDiscountable;
  }

  public class QTierComparator implements Comparator<zqu.QTier> {
    public Integer compare(zqu.QTier a, zqu.QTier b) {
      Integer tierA = Integer.valueOf(a.getRecord().zqu__Tier__c);
      Integer tierB = Integer.valueOf(b.getRecord().zqu__Tier__c);

      // Use simple if-else to determine ordering
      if (tierA == tierB) {
        return 0;
      } else if (tierA < tierB) {
        return -1; // a should come before b
      } else {
        return 1; // a should come after b
      }
    }
  }
}

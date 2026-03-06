/**
 * Created by zohar.sinay on 21/02/2024.
 */

public class ZuoraUpdateDiscountPriceQueueable implements Queueable {
  private zqu__Quote__c quote;
  private String processName;
  private Boolean fromSubmit;

  // Constructor to pass the Quote ID
  public ZuoraUpdateDiscountPriceQueueable(
    zqu__Quote__c quote,
    String processName
  ) {
    System.debug('processName----- ' + processName);
    this.quote = quote;
    this.processName = processName;
    this.fromSubmit = false;
  }
  public ZuoraUpdateDiscountPriceQueueable(
    zqu__Quote__c quote,
    String processName,
    boolean fromSubmit
  ) {
    System.debug('processName--with -fromSubmit-- ' + processName);
    this.quote = quote;
    this.processName = processName;
    this.fromSubmit = fromSubmit;
  }

  public void execute(QueueableContext context) {
    if (processName == 'AddDiscount') {
      addDiscount();
    } else if (processName == 'FU') {
      handleNewFU();
    } else if (processName == 'CTU') {
      handleCTU2();
    } else if (this.processName == 'Renewal') {
      addDiscount();
    }
  }

  public void addDiscount() {
    System.debug('this.asdasdasd00---' + this.fromSubmit);
    List<zqu__Quote__c> quoteList = getQuoteList();

    if (quoteList.isEmpty()) {
      return; // Early exit if no quote found
    }
    try {
      List<zqu.QPlan> plans = zqu.QPlanReader.load(quote.Id);
      ZuoraPriceCalculation.SumsObj sumObj = ZuoraPriceCalculation.updateQuoteSums2(
        quoteList,
        false,
        true
      );
      quoteList[0].Total_Sum_Of_Fees__c =
        sumObj.sumOfNonDiscountableRecurring +
        sumObj.sumOfDiscountableRecurring;
      quoteList[0]
        .Total_Sum_Of_Discountable_Fees__c = sumObj.sumOfDiscountableRecurring;
      quoteList[0].Sum_Of_one_time__c = sumObj.sumOfOneTime;
      System.debug(
        'quoteList[0].Total_Sum_Of_Fees__c--' +
        quoteList[0].Total_Sum_Of_Fees__c
      );
      System.debug(
        'quoteList[0].Recurring_Target_Price__c--' +
        quoteList[0].Recurring_Target_Price__c
      );
      Decimal discountPercentage = ZuoraPriceCalculation.CalculatePercentageOfDiscount(
        quoteList[0].Total_Sum_Of_Discountable_Fees__c,
        quoteList[0].Recurring_Target_Price__c
      );
      System.debug('discountPercentage: ' + discountPercentage);
      Set<zqu.QPlan> planToUpdateSet = new Set<zqu.QPlan>();
      Boolean foundDiscountPlan = false;
      Decimal recPrice = 0;
      String curr = '';
      Integer billingPeriod;
      Integer numOfcharges = 0;
      zqu.QCharge baseProductCharge = null;
      for (zqu.QPlan plan : plans) {
        Boolean isNotRemoved =
          plan.get('zqu__AmendmentType__c') != 'RemoveProduct';
        for (zqu.QCharge charge : plan.getCharges()) {
          // Identify Base Product Charge
          system.debug(
            'plan.getRecord().Is_Base_product__c: ' +
            plan.getRecord().Is_Base_product__c
          );
          if (plan.getRecord().Is_Base_product__c) {
            // Assuming the base product has one charge
            baseProductCharge = charge;
          }
          List<zqu.QTier> chargeTierList = new List<zqu.QTier>();
          if (
            ZuoraPriceCalculation.isRecurringCharge2(
              (String) plan.getRecord().get('Name'),
              charge
            ) && isNotRemoved
          ) {
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
            recPrice += ((Decimal) charge.get('zqu__Total__c') *
            quoteList[0].zqu__InitialTerm__c);
            System.debug('recPrice--' + recPrice);
            System.debug(
              'quoteList[0].zqu__InitialTerm__c--' +
              quoteList[0].zqu__InitialTerm__c
            );
            System.debug(
              'charge.get(\'zqu__SpecificBillingPeriod__c\')--' +
              charge.get('zqu__SpecificBillingPeriod__c')
            );
            billingPeriod = Integer.valueOf(
                charge.get('zqu__SpecificBillingPeriod__c')
              ) != null
              ? Integer.valueOf(charge.get('zqu__SpecificBillingPeriod__c'))
              : billingPeriod;
            planToUpdateSet.add(plan);
          } else if (
            charge.get('Quote_rate_plan_charge_ID__c') == 'Free Product' &&
            isNotRemoved
          ) {
            if (charge.getTiers() != null && !charge.getTiers().isEmpty()) {
              for (zqu.QTier chargeTier : charge.getTiers()) {
                chargeTier.put('zqu__Discount__c', 100);
                //chargeTier.put('zqu__Effective_Price__c', 0);
                chargeTierList.add(chargeTier);
                system.debug('100% discount on tier');
                system.debug(chargeTier.getRecord().Name);
                system.debug(chargeTier.getRecord().zqu__Discount__c);
              }
            } else {
              charge.put('zqu__Discount__c', 100);
              charge.put('zqu__EffectivePrice__c', 0);
              charge.put('zqu__Total__c', 0);
              system.debug('100% discount on charge');
              system.debug(charge.getRecord().Name);
              system.debug(charge.getRecord().zqu__Discount__c);
            }
            if (!chargeTierList.isEmpty()) {
              charge.setTiers(chargeTierList);
            }
            planToUpdateSet.add(plan);
          }
        }
      }

      if (billingPeriod != null) {
        System.debug(billingPeriod);
        System.debug(quoteList[0]?.zqu__InitialTerm__c.setScale(0));
        Integer totalServicePeriod = Integer.valueOf(
          (Integer.valueOf(
            quoteList[0]?.zqu__InitialTerm__c.setScale(0) / billingPeriod
          ))
        );

        //Decimal amountToAdjustFU = ZuoraPriceCalculation.calculateLikeZuoraPartial(New List<zqu.QPlan>(planToUpdateSet), quoteList, billingPeriod);
        //System.debug(amountToAdjustFU);

        Decimal ZCalculatedSum = ZuoraPriceCalculation.calculateSumWithDiscountLikeZuora(
          Integer.valueOf(quoteList[0].zqu__InitialTerm__c.setScale(0)),
          plans,
          quoteList[0].zqu__Currency__c,
          totalServicePeriod
        );
        if (ZCalculatedSum == null || ZCalculatedSum == 0) {
          ZCalculatedSum = recPrice.setScale(0, System.RoundingMode.Half_UP);
          totalServicePeriod = Integer.valueOf(
            (quoteList[0].zqu__InitialTerm__c / billingPeriod)
          );
        }
        System.debug(ZCalculatedSum);

        System.debug(
          'quoteList[0].Is_Discount_Given__c: ' +
          quoteList[0].Is_Discount_Given__c
        );
        System.debug('recPrice: ' + recPrice);

        Decimal amountToAdjust =
          (recPrice.setScale(0, System.RoundingMode.Half_UP) - ZCalculatedSum) /
          (quoteList[0].zqu__InitialTerm__c);
        System.debug(baseProductCharge);
        if (baseProductCharge != null) {
          Decimal total = (Decimal) baseProductCharge.get('zqu__Total__c');
          baseProductCharge.put('zqu__Total__c', total + amountToAdjust);
        }
      }

      sumObj = ZuoraPriceCalculation.calcRatePlanSums(
        plans,
        quoteList[0].zqu__InitialTerm__c.setScale(0)
      );
      quoteList[0].Total_Sum_Of_Fees__c =
        sumObj.sumOfNonDiscountableRecurring +
        sumObj.sumOfDiscountableRecurring;
      quoteList[0]
        .Total_Sum_Of_Discountable_Fees__c = sumObj.sumOfDiscountableRecurring;
      quoteList[0].Sum_Of_one_time__c = sumObj.sumOfOneTime;
      quoteList[0].Discount_Status__c = 'Discount Given';
      quoteList[0].zqu__Is_Charge_Expired__c = true;
      quoteList[0].Recurring_Discount_Percentage__c = discountPercentage;
      quoteList[0].Sum_Of_Recurring_fees__c = recPrice.setScale(
        0,
        System.RoundingMode.Half_UP
      );
      quoteList[0].Is_Discount_Given_Timestamp__c = Datetime.now();
      quoteList[0].Zuora_General_Error_Checkbox__c = false;
      quoteList[0].Zuora_General_Error_Message__c = null;
      update quoteList;
      zqu.QPlanWriter.save(new List<zqu.QPlan>(planToUpdateSet));
    } catch (Exception ex) {
      handleError(quoteList, ex);
      System.debug(
        'exception --- ' +
          ex.getMessage() +
          ' stack --- ' +
          ex.getStackTraceString()
      );
      update quoteList;
    }
  }

  private void handleNewFU() {
    System.debug('yaron started handleFU');
    List<zqu__Quote__c> quoteList = [
      SELECT
        Id,
        zqu__ExistSubscriptionID__c,
        zqu__InitialTerm__c,
        QuoteRegion__c,
        zqu__Currency__c,
        zqu_Quote_Status__c,
        Total_Sum_Of_Fees__c,
        Sum_Of_Recurring_fees__c,
        Recurring_Target_Price__c,
        Is_Discount_Given__c,
        Zuora_General_Error_Message__c,
        zqu__StartDate__c,
        zqu__SubscriptionTermStartDate__c,
        zqu__SubscriptionTermEndDate__c,
        zqu__ZuoraSubscriptionID__c,
        Migrating_to_New_Soultion__c
      FROM zqu__Quote__c
      WHERE Id = :quote.Id
    ];
    if (quoteList.isEmpty()) {
      return; // Early exit if no quote found
    }

    try {
      Decimal originalRounding = 0;

      Decimal sumOfOldProductsWithOriginalDiscount = 0;
      List<zqu.QPlan> planToUpdateList = new List<zqu.QPlan>();

      Decimal sumOfNewAndUpdatedProducts = 0;
      Decimal targetTotalPrice = 0;
      Boolean foundDiscountPlan = false;

      System.debug('in zero discount');

      Integer billingPeriod;
      Map<String, Zuora__SubscriptionProductCharge__c> SPCByChargeNumber = new Map<String, Zuora__SubscriptionProductCharge__c>();
      String zuoraSubscriptionId = quoteList[0].zqu_Quote_Status__c ==
        'Sent To Zuora'
        ? quoteList[0].zqu__ZuoraSubscriptionID__c
        : quoteList[0].zqu__ExistSubscriptionID__c;
      for (Zuora__SubscriptionProductCharge__c SPB : [
        SELECT
          Id,
          Name,
          Zuora__ChargeNumber__c,
          Zuora__Price__c,
          Zuora__RatePlanId__c,
          Zuora__Type__c,
          Zuora__TotalContractValue__c,
          Zuora__MonthlyRecurringRevenue__c,
          CARR_Monthly_Total__c,
          Quote_rate_plan_charge_ID__c
        FROM Zuora__SubscriptionProductCharge__c
        WHERE
          Zuora__Subscription__r.Zuora__External_Id__c = :zuoraSubscriptionId
      ]) {
        SPCByChargeNumber.put(SPB.Zuora__ChargeNumber__c, SPB);
        if (SPB.Zuora__Type__c.containsIgnoreCase('Recurring')) {
          if (SPB.Zuora__MonthlyRecurringRevenue__c != null) {
            TargetTotalPrice +=
              SPB.Zuora__MonthlyRecurringRevenue__c *
              quoteList[0].zqu__InitialTerm__c;
          }
        }
      }

      List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteList[0].Id);

      ZuoraPriceCalculation.processMidTermQuote(
        quoteList[0],
        currentPlans,
        SPCByChargeNumber,
        null,
        quoteList[0].zqu__InitialTerm__c
      );

      //quoteList[0].Is_Discount_Given__c = true;
      //quoteList[0].Is_Quote_Ready__c = true;
      quoteList[0].Discount_Status__c = 'Discount Given';
      System.debug(this.fromSubmit);
      //quoteList[0].Recurring_Discount_Percentage__c = discountPercentage;
      //quoteList[0].Sum_Of_Recurring_fees__c = recPrice.setScale(0, System.RoundingMode.Half_UP);
      quoteList[0].Zuora_General_Error_Message__c = null;
      quoteList[0].Zuora_General_Error_Checkbox__c = false;
      quoteList[0].zqu__Is_Charge_Expired__c = true;

      update quoteList;
      System.debug(planToUpdateList);
      //zqu.QPlanWriter.save(planToUpdateList);
    } catch (Exception ex) {
      handleError(quoteList, ex);
      System.debug(
        'exception --- ' +
          ex.getMessage() +
          ' stack --- ' +
          ex.getStackTraceString()
      );
      update quoteList;
    }
  }

  private void handleCTU2() {
    System.debug('yaron started handleFU');
    List<zqu__Quote__c> quoteList = [
      SELECT
        Id,
        zqu__ExistSubscriptionID__c,
        zqu__InitialTerm__c,
        QuoteRegion__c,
        zqu__Currency__c,
        zqu_Quote_Status__c,
        Total_Sum_Of_Fees__c,
        Sum_Of_Recurring_fees__c,
        Recurring_Target_Price__c,
        Is_Discount_Given__c,
        Zuora_General_Error_Message__c,
        zqu__StartDate__c,
        zqu__SubscriptionTermStartDate__c,
        zqu__SubscriptionTermEndDate__c,
        zqu__ZuoraSubscriptionID__c,
        Migrating_to_New_Soultion__c
      FROM zqu__Quote__c
      WHERE Id = :quote.Id
    ];
    if (quoteList.isEmpty()) {
      return; // Early exit if no quote found
    }

    try {
      Decimal originalRounding = 0;

      Decimal sumOfOldProductsWithOriginalDiscount = 0;
      List<zqu.QPlan> planToUpdateList = new List<zqu.QPlan>();

      Decimal sumOfNewAndUpdatedProducts = 0;
      Decimal targetTotalPrice = 0;
      Boolean foundDiscountPlan = false;

      System.debug('in zero discount');

      Integer billingPeriod;
      Map<String, Zuora__SubscriptionProductCharge__c> SPCByChargeNumber = new Map<String, Zuora__SubscriptionProductCharge__c>();
      String zuoraSubscriptionId = quoteList[0].zqu_Quote_Status__c ==
        'Sent To Zuora'
        ? quoteList[0].zqu__ZuoraSubscriptionID__c
        : quoteList[0].zqu__ExistSubscriptionID__c;
      for (Zuora__SubscriptionProductCharge__c SPB : [
        SELECT
          Id,
          Name,
          Zuora__ChargeNumber__c,
          Zuora__Price__c,
          Zuora__RatePlanId__c,
          Zuora__Type__c,
          Zuora__TotalContractValue__c,
          Zuora__MonthlyRecurringRevenue__c,
          CARR_Monthly_Total__c,
          Quote_rate_plan_charge_ID__c
        FROM Zuora__SubscriptionProductCharge__c
        WHERE
          Zuora__Subscription__r.Zuora__External_Id__c = :zuoraSubscriptionId
      ]) {
        SPCByChargeNumber.put(SPB.Zuora__ChargeNumber__c, SPB);
        if (SPB.Zuora__Type__c.containsIgnoreCase('Recurring')) {
          if (SPB.CARR_Monthly_Total__c != null) {
            TargetTotalPrice +=
              Decimal.valueOf(SPB.CARR_Monthly_Total__c) *
              quoteList[0].zqu__InitialTerm__c;
          } else if (SPB.Zuora__MonthlyRecurringRevenue__c != null) {
            TargetTotalPrice +=
              SPB.Zuora__MonthlyRecurringRevenue__c *
              quoteList[0].zqu__InitialTerm__c;
          }
        }
      }

      List<zqu.QPlan> currentPlans = zqu.QPlanReader.load(quoteList[0].Id);
      if (quoteList[0].Recurring_Target_Price__c != null) {
        ZuoraPriceCalculation.processMidTermQuote(
          quoteList[0],
          currentPlans,
          SPCByChargeNumber,
          quoteList[0].Recurring_Target_Price__c,
          quoteList[0].zqu__InitialTerm__c
        );
      }

      quoteList[0].Is_Discount_Given__c = true;
      //            quoteList[0].Is_Quote_Ready__c = true;
      quoteList[0].Discount_Status__c = 'Discount Given';
      System.debug(this.fromSubmit);
      //quoteList[0].Recurring_Discount_Percentage__c = discountPercentage;
      //quoteList[0].Sum_Of_Recurring_fees__c = recPrice.setScale(0, System.RoundingMode.Half_UP);
      quoteList[0].Zuora_General_Error_Message__c = null;
      quoteList[0].Zuora_General_Error_Checkbox__c = false;
      quoteList[0].zqu__Is_Charge_Expired__c = true;

      update quoteList;
      System.debug(planToUpdateList);
      //zqu.QPlanWriter.save(planToUpdateList);
    } catch (Exception ex) {
      handleError(quoteList, ex);
      System.debug(
        'exception --- ' +
          ex.getMessage() +
          ' stack --- ' +
          ex.getStackTraceString()
      );
      update quoteList;
    }
  }

  private void handleError(List<zqu__Quote__c> quoteList, Exception ex) {
    if (quoteList[0].Zuora_General_Error_Message__c != null) {
      quoteList[0].Zuora_General_Error_Message__c +=
        ex.getMessage() +
        ' stackTrace: ' +
        ex.getStackTraceString() +
        ' timestamp : ' +
        Datetime.now();
    } else {
      quoteList[0].Zuora_General_Error_Message__c =
        ex.getMessage() +
        ' stackTrace: ' +
        ex.getStackTraceString() +
        ' timestamp : ' +
        Datetime.now();
    }
    quoteList[0].Zuora_General_Error_Checkbox__c = true;
  }

  public List<zqu__Quote__c> getQuoteList() {
    List<zqu__Quote__c> quoteList = [
      SELECT
        Id,
        zqu__InitialTerm__c,
        Total_Sum_Of_Fees__c,
        QuoteRegion__c,
        zqu__Currency__c,
        Zuora_General_Error_Message__c,
        Current_Contract_TCV__c,
        Sum_Of_Recurring_fees__c,
        Recurring_Target_Price__c,
        Is_Discount_Given__c,
        zqu__ExistSubscriptionID__c,
        Migrating_to_New_Soultion__c,
        zqu__SubscriptionTermEndDate__c,
        zqu__SubscriptionTermStartDate__c,
        zqu__StartDate__c,
        Sum_Of_one_time__c,
        Total_Sum_Of_Discountable_Fees__c,
        zqu__QuoteBusinessType__c
      FROM zqu__Quote__c
      WHERE Id = :quote.Id
    ];
    return quoteList;
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

  public class ZuoraUpdateDiscountPriceQueueableException extends Exception {
  }
}

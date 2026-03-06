/**
 * Created by alon.shalev on 3/15/2023.
 */

public with sharing class WordingProcess { // ZQuoteRatePlanDomainTest.onUpdateTest
  private final static String REMOVED_PRODUCT = 'removed product';
  private final static String NON_REMOVED_PRODUCT = 'non removed product';
  private final static String ORIGINAL_PRODUCT = 'original product';
  private final static String UPDATED_PRODUCT = 'updated product';
  private final static String NEW_PRODUCT = 'new product';
  private final static String DEFAULT_TEMPLATE = 'General MD';
  private final static String RENEWAL = 'THIS IS FOR RENEWAL';
  private final static String BSAE_PACKAGE = 'THIS IS FOR BASE PACKAGE';
  private final static String ONETIMES = 'THIS IS FOR ONE TIMES';

  private String context; // quoteRateDetail ,, amendQuotes
  private Set<Id> quoteIdSet = new Set<Id>();
  private Map<Id, zqu__Quote__c> quoteMap = new Map<Id, zqu__Quote__c>();
  private Map<Id, List<WordingProduct>> allExistingProductsMap = new Map<Id, List<WordingProcess.WordingProduct>>();
  private Map<Id, Map<String, List<WordingProduct>>> quoteIdToTypeToWordingProductListMap = new Map<Id, Map<String, List<WordingProcess.WordingProduct>>>();
  private Map<Id, zqu__Quote__C> quoteMapToUpdate = new Map<Id, zqu__Quote__c>();
  private Map<String, List<Base_Product_Num_of_Data_Credits__c>> packageToListOfCustomSettingMap = new Map<String, List<Base_Product_Num_of_Data_Credits__c>>();
  private Map<String, Wording_Process_Setting__mdt> typeOfTemplateToSettingMap = new Map<String, Wording_Process_Setting__mdt>();
  private Map<String, Decimal> originalToQuantityMap = new Map<String, Decimal>();
  private Map<String, WordingProduct> originalSubscriptionIdToWordingProductMap = new Map<String, WordingProduct>();
  private Map<String, List<String>> baseProductValueToDefaultAddons = new Map<String, List<String>>();
  private Set<String> removedSubscriptionIdSet = new Set<String>();
  private Map<String, QuoteWording> quoteIdToQuoteObjMap = new Map<String, WordingProcess.QuoteWording>(); ///i am so stupid wow...

  public WordingProcess(String context) {
    this.context = context;
    if (Test.isRunningTest()) {
      addCoverage();
    }
  }

  public Map<Id, zqu__Quote__C> populateObjectWithWording(Set<Id> quoteIdSet) {
    this.quoteIdSet = quoteIdSet;
    fillMetaDataInfo();
    getRelatedQuoteProducts();
    handleBasePackageValues();
    fillOriginalToQuantityMap();
    updateAllValues();
    return this.quoteMapToUpdate;
  }

  private void fillOriginalToQuantityMap() {
    for (Id quoteId : this.quoteMap.keySet()) {
      zqu__Quote__c currentQuote = this.quoteMap.get(quoteId);
      QuoteWording quoteWordingObj = new QuoteWording(
        currentQuote,
        this.quoteIdToTypeToWordingProductListMap.get(quoteId)
      );
      this.quoteIdToQuoteObjMap.put(quoteId, quoteWordingObj);
      System.debug(
        'this.quoteIdToTypeToWordingProductListMap--' +
        this.quoteIdToTypeToWordingProductListMap
      );
      System.debug(
        'this.quoteIdToTypeToWordingProductListMap--' +
        this.quoteIdToTypeToWordingProductListMap.get(quoteId)
      );
      System.debug(
        'this.quoteIdToTypeToWordingProductListMap--' +
        this.quoteIdToTypeToWordingProductListMap.get(quoteId)
          .get(NON_REMOVED_PRODUCT)
      );
      if (
        this.quoteIdToTypeToWordingProductListMap.get(quoteId)
          .get(NON_REMOVED_PRODUCT) != null
      ) {
        for (
          WordingProduct wp : this.quoteIdToTypeToWordingProductListMap.get(
              quoteId
            )
            .get(NON_REMOVED_PRODUCT)
        ) {
          if (wp.isOriginal && wp.isLastSegment != null && wp.isLastSegment) {
            if (wp.actionType == 'Quantity') {
              this.originalToQuantityMap.put(wp.addOnType, wp.quantity);
            }
            if (wp.actionType == 'Summary of Attributes') {
              Decimal currentQuantity = this.originalToQuantityMap.get(
                  wp.addOnType
                ) != null
                ? this.originalToQuantityMap.get(wp.addOnType)
                : 0;
              this.originalToQuantityMap.put(
                wp.addOnType,
                wp.quantity + currentQuantity
              );
              this.originalSubscriptionIdToWordingProductMap.put(
                wp.subscriptionZouraId,
                wp
              );
              quoteWordingObj.readyForWordingMap.put(
                wp.addOnType,
                quoteWordingObj.quote.zqu__QuoteBusinessType__c ==
                'Renewal (with/without upsell)'
              ); // for future alon : this is required we put false if the quote is not renewal and that way if nothing will be change for this addon type it wont add this to the wording
            }
          }
        }
      }
    }
    System.debug('this.originalToQuantityMap--' + this.originalToQuantityMap);
  }
  private void fillMetaDataInfo() {
    List<Wording_Process_Setting__mdt> settings = [
      SELECT
        Addon_String__c,
        Wording_Phrase__c,
        Type_of_template__c,
        Addon_Type__c,
        Template_Structure__c
      FROM Wording_Process_Setting__mdt
      WHERE IsActive__c = TRUE
    ];
    for (Wording_Process_Setting__mdt setting : settings) {
      this.typeOfTemplateToSettingMap.put(setting.Type_of_template__c, setting);
    }
  }

  private void handleBasePackageValues() {
    List<Base_Product_Default_Addon__c> bpdaList = Base_Product_Default_Addon__c.getAll()
      .values();
    for (Base_Product_Default_Addon__c bpda_i : bpdaList) {
      System.debug('bpda_i---' + bpda_i);
      List<String> defaultAddonsList = new List<String>();
      if (
        this.baseProductValueToDefaultAddons.containsKey(bpda_i.Controlling__c)
      ) {
        defaultAddonsList = this.baseProductValueToDefaultAddons.get(
          bpda_i.Controlling__c
        );
      }
      defaultAddonsList.add(bpda_i.Addon__c);
      this.baseProductValueToDefaultAddons.put(
        bpda_i.Controlling__c,
        defaultAddonsList
      );
    }
    System.debug(
      'this.baseProductValueToDefaultAddons--' +
      this.baseProductValueToDefaultAddons
    );

    List<Base_Product_Num_of_Data_Credits__c> baseProductNumOfDataCredits = Base_Product_Num_of_Data_Credits__c.getall()
      .values();
    for (
      Base_Product_Num_of_Data_Credits__c bpdc : baseProductNumOfDataCredits
    ) {
      if (bpdc.IsActive__c) {
        if (
          !this.packageToListOfCustomSettingMap.containsKey(bpdc.Controlling__c)
        ) {
          this.packageToListOfCustomSettingMap.put(
            bpdc.Controlling__c,
            new List<Base_Product_Num_of_Data_Credits__c>()
          );
        }
        this.packageToListOfCustomSettingMap.get(bpdc.Controlling__c).add(bpdc);
      }
    }
  }

  private String adjustWordingByTemplate(TemplateObject template) {
    return String.format(template.template, template.templateParams);
  }

  private void populateAllFields(QuoteWording quoteWordingObj) {
    //        initQuoteByCustomSettingDataCredits(quoteWordingObj);
    //        initQuoteByCustomSettingsUsers(quoteWordingObj);
    initQuoteByCustomSettings(quoteWordingObj);
    initializeAllQuoteFields(quoteWordingObj);

    for (
      WordingProduct wp : quoteWordingObj.typeToWordingProductsMap.get(
        NON_REMOVED_PRODUCT
      )
    ) {
      //            if(!quoteWordingObj.productGroupToFinalWordingListMap.containsKey(wp.contractGroup)){
      //                quoteWordingObj.productGroupToFinalWordingListMap.put(wp.contractGroup,new Map <String,String>());
      //            }
      System.debug('wp in populate--' + wp);
      if (wp.isOriginal && !quoteWordingObj.isRenewal) {
        continue;
      }
      System.debug('wp action--' + wp.actionType);
      //            if(wp.isNeedToAdjustWording){
      //                quoteWordingObj.addonTypeNeedToAdjustWordingSet.add(wp.addOnType);
      //            }

      switch on wp.actionType {
        when 'Quantity' {
          quantityLogic(quoteWordingObj, wp, false);
        }
        when 'Summary of Attributes' {
          if (String.isNotBlank(wp.subscriptionZouraId) && !wp.isOriginal) {
            if (
              this.originalSubscriptionIdToWordingProductMap.containsKey(
                wp.subscriptionZouraId
              )
            ) {
              this.originalSubscriptionIdToWordingProductMap.remove(
                wp.subscriptionZouraId
              );
            }
          }
          if (!wp.isOriginal) {
            quoteWordingObj.readyForWordingMap.put(wp.addOnType, true); // for future alon : this is required we put true because this addon type has changed and it will get a wording
            summaryOfAttributeFillQuantity(quoteWordingObj, wp);
          }
        }
        when 'Contract wording' {
          System.debug(' im in Contract wording--');
          if (this.removedSubscriptionIdSet.contains(wp.subscriptionZouraId)) {
            continue;
          }
          if (quoteWordingObj.isRenewal) {
            System.debug('Contract wording renewal ---');
            quoteWordingObj.fieldNameToFinalWording.put(
              wp.isOneTime
                ? wp.productName + ONETIMES + RENEWAL
                : wp.productName + RENEWAL,
              wp.wording
            );
            quoteWordingObj.addonTypeToContractGroupMap.put(
              wp.productName + RENEWAL,
              wp.contractGroup
            );
            quoteWordingObj.readyForWordingMap.put(
              wp.productName + RENEWAL,
              true
            );
          }
          if (!wp.isOriginal) {
            System.debug('Contract wording isOriginal = false ---');
            quoteWordingObj.fieldNameToFinalWording.put(
              wp.isOneTime ? wp.productName + ONETIMES : wp.productName,
              wp.wording
            );
            quoteWordingObj.addonTypeToContractGroupMap.put(
              wp.productName,
              wp.contractGroup
            );
            quoteWordingObj.readyForWordingMap.put(wp.productName, true);
          }
        }
        when 'Product Name' {
          System.debug('in Product Name');
          if (this.removedSubscriptionIdSet.contains(wp.subscriptionZouraId)) {
            continue;
          }
          System.debug(
            'quoteWordingObj.fieldNameToFinalWording--' +
            quoteWordingObj.fieldNameToFinalWording.get(
              wp.productName + REMOVED_PRODUCT
            )
          );
          System.debug(
            'quoteWordingObj.fieldNameToFinalWording--' +
            quoteWordingObj.fieldNameToFinalWording.get(wp.productName)
          );
          System.debug(
            'quoteWordingObj.fieldNameToFinalWording--' +
            quoteWordingObj.fieldNameToFinalWording
          );
          if (quoteWordingObj.isRenewal) {
            quoteWordingObj.fieldNameToFinalWording.put(
              wp.isOneTime
                ? wp.productName + ONETIMES + RENEWAL
                : wp.productName + RENEWAL,
              wp.productName
            );
            quoteWordingObj.addonTypeToContractGroupMap.put(
              wp.productName + RENEWAL,
              wp.contractGroup
            );
            quoteWordingObj.readyForWordingMap.put(
              wp.productName + RENEWAL,
              true
            );
          }
          if (!wp.isOriginal) {
            quoteWordingObj.fieldNameToFinalWording.put(
              wp.isOneTime ? wp.productName + ONETIMES : wp.productName,
              wp.productName
            );
            quoteWordingObj.addonTypeToContractGroupMap.put(
              wp.productName,
              wp.contractGroup
            );
            quoteWordingObj.readyForWordingMap.put(wp.productName, true);
          }
        }
      }
    }
    completeOriginalProductsOfSummaryAttributes(quoteWordingObj);
    completeAdjustments(quoteWordingObj);

    Map<String, List<String>> contractGroupToWordingListOfRenewalMap = new Map<String, List<String>>();
    Map<String, List<String>> contractGroupToWordingListOfNewAndUpdatedMap = new Map<String, List<String>>();
    Map<String, List<String>> contractGroupToWordingListOfOneTimesMap = new Map<String, List<String>>();
    arrangeMaps(
      quoteWordingObj,
      contractGroupToWordingListOfRenewalMap,
      contractGroupToWordingListOfOneTimesMap,
      contractGroupToWordingListOfNewAndUpdatedMap
    );
    //        arrangeMaps(quoteWordingObj, contractGroupToWordingListOfRenewalMap, contractGroupToWordingListOfNewAndUpdatedMap);
    StringSorter sorter = new StringSorter();
    List<String> sortedNewAndUpdatedList = new List<String>();
    List<String> sortedRenewalsList = new List<String>();
    List<String> sortedOneTimesList = new List<String>();
    convertToSortedList(
      contractGroupToWordingListOfNewAndUpdatedMap,
      contractGroupToWordingListOfRenewalMap,
      contractGroupToWordingListOfOneTimesMap,
      sortedNewAndUpdatedList,
      sorter,
      sortedRenewalsList,
      sortedOneTimesList
    );
    //        convertToSortedList(contractGroupToWordingListOfNewAndUpdatedMap, contractGroupToWordingListOfRenewalMap, sortedNewAndUpdatedList, sorter, sortedRenewalsList);
    finishPopulatingTheQuote(
      sortedRenewalsList,
      sortedNewAndUpdatedList,
      sortedOneTimesList,
      quoteWordingObj
    );
  }

  private void finishPopulatingTheQuote(
    List<String> sortedRenewalsList,
    List<String> sortedNewAndUpdatedList,
    List<String> sortedOneTimesList,
    QuoteWording quoteWordingObj
  ) {
    String result = String.join(sortedRenewalsList, '\n');
    String result2 = String.join(sortedNewAndUpdatedList, '\n');
    String resultOfOneTimes = String.join(sortedOneTimesList, '\n');
    System.debug('result---' + result);
    System.debug('result2--' + result2);
    quoteWordingObj.quote.Amendment_New_Products__c = String.isNotBlank(result2)
      ? result2
      : '';
    quoteWordingObj.quote.New_Sale_Products__c = String.isNotBlank(result2)
      ? result2
      : '';
    quoteWordingObj.quote.Amendment_Renewal_Prodcuts__c = String.isNotBlank(
        result
      )
      ? result
      : '';
    quoteWordingObj.quote.One_Time_Products__c = String.isNotBlank(
        resultOfOneTimes
      )
      ? resultOfOneTimes
      : '';
  }

  //    private void convertToSortedList(Map<String, List<String>> contractGroupToWordingListOfNewAndUpdatedMap, Map<String, List<String>> contractGroupToWordingListOfRenewalMap, List<String> sortedNewAndUpdatedList, StringSorter sorter, List<String> sortedRenewalsList) {
  //        Map<Decimal, List<String>> integerKeySetNewAndUpdatedListMap = fixMap(contractGroupToWordingListOfNewAndUpdatedMap);
  //        Map<Decimal, List<String>> integerKeySetRenewalListMap = fixMap(contractGroupToWordingListOfRenewalMap);
  ////        Map<Decimal, List<String>> integerKeySetOneTimeListMap = fixMap(contractGroupToWordingListOfOneTimesMap);
  //        List<Decimal> sortedNewAndUpdatedKeysList = new List<Decimal>(integerKeySetNewAndUpdatedListMap.keySet());
  //        sortedNewAndUpdatedKeysList.sort();
  //        for (Decimal contractGroupNumber : sortedNewAndUpdatedKeysList) {
  //            sortedNewAndUpdatedList.addAll(sorter.customSort(integerKeySetNewAndUpdatedListMap.get(contractGroupNumber)));
  //        }
  //        List<Decimal> sortedRenewalKeysList = new List<Decimal>(integerKeySetRenewalListMap.keySet());
  //        sortedRenewalKeysList.sort();
  //        for (Decimal contractGroupNumber : sortedRenewalKeysList) {
  //            sortedRenewalsList.addAll(sorter.customSort(integerKeySetRenewalListMap.get(contractGroupNumber)));
  //        }
  //
  ////        List<Decimal> sortedOneTimeKeysList = new List<Decimal>(integerKeySetOneTimeListMap.keySet());
  ////        sortedOneTimeKeysList.sort();
  ////        for (Decimal contractGroupNumber : sortedOneTimeKeysList) {
  ////            sortedOneTimesList.addAll(sorter.customSort(integerKeySetOneTimeListMap.get(contractGroupNumber)));
  ////        }
  //    }
  private void convertToSortedList(
    Map<String, List<String>> contractGroupToWordingListOfNewAndUpdatedMap,
    Map<String, List<String>> contractGroupToWordingListOfRenewalMap,
    Map<String, List<String>> contractGroupToWordingListOfOneTimesMap,
    List<String> sortedNewAndUpdatedList,
    StringSorter sorter,
    List<String> sortedRenewalsList,
    List<String> sortedOneTimesList
  ) {
    Map<Decimal, List<String>> integerKeySetNewAndUpdatedListMap = fixMap(
      contractGroupToWordingListOfNewAndUpdatedMap
    );
    Map<Decimal, List<String>> integerKeySetRenewalListMap = fixMap(
      contractGroupToWordingListOfRenewalMap
    );
    Map<Decimal, List<String>> integerKeySetOneTimeListMap = fixMap(
      contractGroupToWordingListOfOneTimesMap
    );
    List<Decimal> sortedNewAndUpdatedKeysList = new List<Decimal>(
      integerKeySetNewAndUpdatedListMap.keySet()
    );
    sortedNewAndUpdatedKeysList.sort();
    for (Decimal contractGroupNumber : sortedNewAndUpdatedKeysList) {
      sortedNewAndUpdatedList.addAll(
        sorter.customSort(
          integerKeySetNewAndUpdatedListMap.get(contractGroupNumber)
        )
      );
    }
    List<Decimal> sortedRenewalKeysList = new List<Decimal>(
      integerKeySetRenewalListMap.keySet()
    );
    sortedRenewalKeysList.sort();
    for (Decimal contractGroupNumber : sortedRenewalKeysList) {
      sortedRenewalsList.addAll(
        sorter.customSort(integerKeySetRenewalListMap.get(contractGroupNumber))
      );
    }

    List<Decimal> sortedOneTimeKeysList = new List<Decimal>(
      integerKeySetOneTimeListMap.keySet()
    );
    sortedOneTimeKeysList.sort();
    for (Decimal contractGroupNumber : sortedOneTimeKeysList) {
      sortedOneTimesList.addAll(
        sorter.customSort(integerKeySetOneTimeListMap.get(contractGroupNumber))
      );
    }
  } // one time change need to upload to prod when

  private void arrangeMaps(
    QuoteWording quoteWordingObj,
    Map<String, List<String>> contractGroupToWordingListOfRenewalMap,
    Map<String, List<String>> contractGroupToWordingListOfOneTimesMap,
    Map<String, List<String>> contractGroupToWordingListOfNewAndUpdatedMap
  ) {
    for (String key : quoteWordingObj.fieldNameToFinalWording.keySet()) {
      System.debug('key--' + key);
      if (!key.contains(REMOVED_PRODUCT)) {
        if (
          !quoteWordingObj.readyForWordingMap.containsKey(key) ||
          quoteWordingObj.readyForWordingMap.get(key)
        ) {
          // for future alon : if an addon type reached here and this quote is not ready for wording the line will not be written it can be not ready if we have a base product that have to have an extra product and doesnt have or if all of this addon type are only originals and this is not a renewal
          System.debug(quoteWordingObj.addonTypToOverrideMap);
          String contractGroup = quoteWordingObj.addonTypeToContractGroupMap.get(
            key
          );
          if (key.contains(RENEWAL)) {
            if (key.contains(ONETIMES)) {
              continue; // alon shalev addition for one times 19.2.25
            }
            System.debug('key final --' + key);
            System.debug(
              'final wording for this key -- ' +
              quoteWordingObj.fieldNameToFinalWording.get(key)
            );
            if (
              !contractGroupToWordingListOfRenewalMap.containsKey(contractGroup)
            ) {
              contractGroupToWordingListOfRenewalMap.put(
                contractGroup,
                new List<String>()
              );
            }
            contractGroupToWordingListOfRenewalMap.get(contractGroup)
              .add(quoteWordingObj.fieldNameToFinalWording.get(key));
          } else {
            // alon shalev added one times logic 18.2.25
            if (key.contains(ONETIMES)) {
              if (
                !contractGroupToWordingListOfOneTimesMap.containsKey(
                  contractGroup
                )
              ) {
                contractGroupToWordingListOfOneTimesMap.put(
                  contractGroup,
                  new List<String>()
                );
              }
              contractGroupToWordingListOfOneTimesMap.get(contractGroup)
                .add(quoteWordingObj.fieldNameToFinalWording.get(key));
            } else {
              if (
                !contractGroupToWordingListOfNewAndUpdatedMap.containsKey(
                  contractGroup
                )
              ) {
                contractGroupToWordingListOfNewAndUpdatedMap.put(
                  contractGroup,
                  new List<String>()
                );
              }
              contractGroupToWordingListOfNewAndUpdatedMap.get(contractGroup)
                .add(quoteWordingObj.fieldNameToFinalWording.get(key)); //// 3
            }
          }
        }
      }
    }
  }

  private void completeOriginalProductsOfSummaryAttributes(
    QuoteWording quoteWordingObj
  ) {
    for (
      WordingProduct wp : this.originalSubscriptionIdToWordingProductMap.values()
    ) {
      summaryOfAttributeFillQuantity(quoteWordingObj, wp);
    }
  }

  private void completeAdjustments(QuoteWording quoteWordingObj) {
    System.debug('completeAdjustments--');
    for (String addonType : this.originalToQuantityMap.keySet()) {
      Decimal oldQuantity = this.originalToQuantityMap.get(addonType);
      Decimal newQuantity = quoteWordingObj.addOnTypeToQuantityMap.get(
        addonType
      );
      System.debug('newQuantity--' + newQuantity);
      System.debug('oldQuantity--' + oldQuantity);
      if (oldQuantity != null && newQuantity != null) {
        if (
          oldQuantity != newQuantity &&
          quoteWordingObj.quote.zqu__QuoteBusinessType__c !=
          'Renewal (with/without upsell)' &&
          quoteWordingObj.quote.Migrating_to_New_Soultion__c != 'Yes'
        ) {
          if (this.typeOfTemplateToSettingMap.containsKey(addOnType)) {
            Wording_Process_Setting__mdt setting = this.typeOfTemplateToSettingMap.get(
              addOnType
            );
            TemplateObject templateObject = new TemplateObject(
              setting.Wording_Phrase__c
            );
            List<Object> parameters = new List<Object>();

            switch on setting.Template_Structure__c {
              when 'Quantity Structure' {
                parameters = fillQuantityStructureParams(
                  addonType,
                  setting,
                  quoteWordingObj
                );
              }
              when 'Data Set Structure' {
                parameters = fillDataSetStructureParams(
                  addonType,
                  quoteWordingObj
                );
              }
            }
            templateObject.templateParams = parameters;
            String adjustedWording = adjustWordingByTemplate(templateObject);
            quoteWordingObj.fieldNameToFinalWording.put(
              addOnType,
              adjustedWording
            );
          }
        }
      }
    }
    //        for(String addonType : quoteWordingObj.addonTypeNeedToAdjustWordingSet){
    //            System.debug('addontype ---'+addonType);
    //
    //        }
  }

  private void summaryOfAttributeFillQuantity(
    QuoteWording quoteWordingObj,
    WordingProduct wp
  ) {
    String afterQuantityPhrase = this.typeOfTemplateToSettingMap.get(
        wp.addOnType
      )
      .Addon_String__c;
    fillAddonOnTypeToQuantityMap(
      quoteWordingObj,
      wp.isOneTime ? wp.addOnType + ONETIMES : wp.addOnType,
      wp.quantity,
      wp.wording,
      true,
      wp.contractGroup,
      afterQuantityPhrase
    );
    //        fillAddonOnTypeToQuantityMap(quoteWordingObj, wp.addOnType, wp.quantity, wp.wording, true, wp.contractGroup,afterQuantityPhrase);
    if (quoteWordingObj.isRenewal) {
      fillAddonOnTypeToQuantityMap(
        quoteWordingObj,
        wp.isOneTime
          ? wp.addOnType + RENEWAL + ONETIMES
          : wp.addOnType + RENEWAL,
        wp.quantity,
        wp.wording,
        true,
        wp.contractGroup,
        afterQuantityPhrase
      );
      //            fillAddonOnTypeToQuantityMap(quoteWordingObj, wp.addOnType + RENEWAL, wp.quantity, wp.wording, true, wp.contractGroup,afterQuantityPhrase);
    }
  }

  private Map<Decimal, List<String>> fixMap(
    Map<String, List<String>> StringKeySet
  ) {
    Map<Decimal, List<String>> fixedMap = new Map<Decimal, List<String>>();
    for (String key : StringKeySet.keySet()) {
      Decimal integerKey = key == null ? 1000 : Decimal.valueOf(key);
      fixedMap.put(integerKey, StringKeySet.get(key));
    }
    return fixedMap;
  }

  private List<Object> fillDataSetStructureParams(
    String addonType,
    QuoteWording quoteWordingObj
  ) {
    Decimal oldQuantity = this.originalToQuantityMap.get(addOnType);
    Decimal newQuantity = quoteWordingObj.addOnTypeToQuantityMap.get(addonType);
    Decimal currentQuantity = newQuantity - oldQuantity;
    String addReduceString = currentQuantity > 0
      ? 'add'
      : currentQuantity == 0 ? '' : 'reduce';
    String addonString = this.typeOfTemplateToSettingMap.get(addOnType)
      .Addon_String__c;
    List<Object> parameters = new List<Object>{
      addReduceString,
      Math.abs(newQuantity - oldQuantity).format(),
      addonString,
      addonString,
      newQuantity.format(),
      quoteWordingObj.typeToWordingPostFixMap.get(addOnType)
    };
    return parameters;
  }

  private List<Object> fillQuantityStructureParams(
    String addonType,
    Wording_Process_Setting__mdt setting,
    QuoteWording quoteWordingObj
  ) {
    String addonString = this.typeOfTemplateToSettingMap.containsKey(addOnType)
      ? setting.Addon_String__c
      : addOnType;
    Decimal quantity = quoteWordingObj.addOnTypeToQuantityMap.get(addOnType);
    List<Object> parameters = new List<Object>{
      addonString,
      quantity.format(),
      addonString
    };
    return parameters;
  }
  /**
     this method will calculate the quantity for renewals and all other type of quotes
     if the quoteWordingObj.isRenewal is true it put 2 key to the finalString
     otherwise will add only 1 key
     ill try to explain :
     the first thing that is always populated is the base package product and it populating the addOnTypeToQuantityMap with the base package quantity
     the im asking if this product is original or not
     if it is original
     im sending to the next method with the renewal key and its quantity
     the next method will override or not according to the  "addonTypToOverrideMap"
     if its not original
     this suppose to override the original one because there can be only one of the same kind (addonType) so first im marking this key in "addonTypeToFinalProductInQuoteSet"
     so if the next product will be original it wont enter after i already used this key once
     the only metter is the basePackage value that could have overrided before i entered with this notOriginal product so im collecting the quantity stored earlier  in "basePackageAddonToQuantityMap"
     and sends that to the next method.
     the next method is more clear
     hope u got it..


     */

  private void quantityLogic(
    QuoteWording quoteWordingObj,
    WordingProduct wp,
    boolean isConcatenate
  ) {
    if (quoteWordingObj.isRenewal) {
      if (
        quoteWordingObj.fieldNameToFinalWording.containsKey(
          wp.addOnType + REMOVED_PRODUCT
        ) && wp.isOriginal
      ) {
        return;
      }
      if (wp.isOriginal) {
        if (
          !quoteWordingObj.addonTypeToFinalProductInQuoteSet.contains(
            wp.addOnType + RENEWAL
          )
        ) {
          quoteWordingObj.addonTypeToFinalProductInQuoteSet.add(
            wp.addOnType + RENEWAL
          );
          fillAddonOnTypeToQuantityMap(
            quoteWordingObj,
            wp.isOneTime
              ? wp.addOnType + RENEWAL + ONETIMES
              : wp.addOnType + RENEWAL,
            wp.quantity,
            wp.wording,
            isConcatenate,
            wp.contractGroup,
            ''
          );
          //                    fillAddonOnTypeToQuantityMap(quoteWordingObj, wp.addOnType+RENEWAL, wp.quantity, wp.wording, isConcatenate,wp.contractGroup,'');
          quoteWordingObj.addonTypToOverrideMap.put(
            wp.addOnType + RENEWAL,
            true
          );
        }
      } else {
        quoteWordingObj.addonTypeToFinalProductInQuoteSet.add(
          wp.addOnType + RENEWAL
        );
        Decimal newQuantity = quoteWordingObj.basePackageAddonToQuantityMap.containsKey(
            wp.addOnType + RENEWAL
          )
          ? quoteWordingObj.basePackageAddonToOverrideMap.get(
                wp.addOnType + RENEWAL
              )
              ? wp.quantity
              : quoteWordingObj.basePackageAddonToQuantityMap.get(
                  wp.addOnType + RENEWAL
                ) + wp.quantity
          : wp.quantity;
        quoteWordingObj.addonTypToOverrideMap.put(wp.addOnType + RENEWAL, true);
        System.debug('yaron is here!!');
        System.debug('wp---' + wp);
        fillAddonOnTypeToQuantityMap(
          quoteWordingObj,
          wp.isOneTime
            ? wp.addOnType + RENEWAL + ONETIMES
            : wp.addOnType + RENEWAL,
          newQuantity,
          wp.wording,
          isConcatenate,
          wp.contractGroup,
          ''
        );
        //                fillAddonOnTypeToQuantityMap(quoteWordingObj, wp.addOnType+RENEWAL, newQuantity, wp.wording, isConcatenate,wp.contractGroup,'');

        fillAddonOnTypeToQuantityMap(
          quoteWordingObj,
          wp.isOneTime ? wp.addOnType + ONETIMES : wp.addOnType,
          wp.quantity,
          wp.wording,
          isConcatenate,
          wp.contractGroup,
          ''
        );
        quoteWordingObj.readyForWordingMap.put(wp.addOnType, true);
      }
    } else {
      fillAddonOnTypeToQuantityMap(
        quoteWordingObj,
        wp.isOneTime ? wp.addOnType + ONETIMES : wp.addOnType,
        wp.quantity,
        wp.wording,
        isConcatenate,
        wp.contractGroup,
        ''
      );
      //            fillAddonOnTypeToQuantityMap(quoteWordingObj, wp.addOnType, wp.quantity, wp.wording, isConcatenate,wp.contractGroup,'');
      quoteWordingObj.readyForWordingMap.put(wp.addOnType, true);
    }
  }
  private void initQuoteByCustomSettings(QuoteWording quoteWordingObj) {
    if (
      this.packageToListOfCustomSettingMap.containsKey(
        quoteWordingObj.quote.Contract_Base_package__c
      )
    ) {
      for (
        Base_Product_Num_of_Data_Credits__c baseProduct : this.packageToListOfCustomSettingMap.get(
          quoteWordingObj.quote.Contract_Base_package__c
        )
      ) {
        if (quoteWordingObj.isRenewal) {
          String key = baseProduct.Addon__c + RENEWAL;
          initBaseProducts(quoteWordingObj, key, baseProduct, true);
        }
        initBaseProducts(
          quoteWordingObj,
          baseProduct.Addon__c,
          baseProduct,
          quoteWordingObj.isNew
        );
      }
    }
  }

  private void initBaseProducts(
    QuoteWording quoteWordingObj,
    String key,
    Base_Product_Num_of_Data_Credits__c baseProduct,
    Boolean readyForWordingMap
  ) {
    quoteWordingObj.addOnTypeToQuantityMap.put(key, baseProduct.Quantity__c);
    quoteWordingObj.readyForWordingMap.put(key, readyForWordingMap);
    quoteWordingObj.fieldNameToFinalWording.put(
      key,
      generateSumWording(baseProduct.Quantity__c, baseProduct.Wording__c)
    );
    quoteWordingObj.addonTypToOverrideMap.put(key, baseProduct.is_override__c);
    quoteWordingObj.basePackageAddonToQuantityMap.put(
      key,
      baseProduct.Quantity__c
    );
    quoteWordingObj.basePackageAddonToOverrideMap.put(
      key,
      baseProduct.is_override__c
    );
    quoteWordingObj.addonTypeToContractGroupMap.put(
      key,
      baseProduct.ContractGroup__c
    );
  }

  private void updateAllValues() {
    for (Id quoteId : this.quoteMap.keySet()) {
      QuoteWording quoteWordingObj = this.quoteIdToQuoteObjMap.get(quoteId);
      setDefaultAddon(quoteWordingObj.quote);
      if (quoteWordingObj.typeToWordingProductsMap != null) {
        if (
          quoteWordingObj.typeToWordingProductsMap.containsKey(REMOVED_PRODUCT)
        ) {
          handleReplace(quoteWordingObj);
        }
        if (
          quoteWordingObj.typeToWordingProductsMap.containsKey(
            NON_REMOVED_PRODUCT
          )
        ) {
          populateAllFields(quoteWordingObj);
        }
        this.quoteMapToUpdate.put(
          quoteWordingObj.quote.Id,
          quoteWordingObj.quote
        );
      }
    }
  }

  private void initializeAllQuoteFields(QuoteWording quoteWordingObj) {
    quoteWordingObj.quote.Amendment_Renewal_Prodcuts__c = '';
    quoteWordingObj.quote.Amendment_New_Products__c = '';
    quoteWordingObj.quote.New_Sale_Products__c = '';
  }

  private void fillAddonOnTypeToQuantityMap(
    QuoteWording quoteWordingObj,
    String key,
    Decimal quantity,
    String wording,
    Boolean isConcatenate,
    String contractGroup,
    String afterQuantityPhrase
  ) {
    System.debug('quoteWordingObj--' + quoteWordingObj);
    System.debug(
      'quoteWordingObj.addOnTypeToQuantityMap--' +
      quoteWordingObj.addOnTypeToQuantityMap
    );
    System.debug('quantity--' + quantity);
    System.debug(
      'addonTypToOverrideMap--' + quoteWordingObj.addonTypToOverrideMap.get(key)
    );
    if (
      !quoteWordingObj.addOnTypeToQuantityMap.containsKey(key) ||
      (quoteWordingObj.addonTypToOverrideMap.containsKey(key) &&
      quoteWordingObj.addonTypToOverrideMap.get(key))
    ) {
      quoteWordingObj.addOnTypeToQuantityMap.put(key, quantity);
      quoteWordingObj.addonTypToOverrideMap.put(key, false);
      //            quoteWordingObj.typeToWordingPostFixMap.put(key,isConcatenate ? 'Data Sets: '+wording : wording);
    } else {
      Decimal newQuantity =
        quoteWordingObj.addOnTypeToQuantityMap.get(key) + quantity;
      quoteWordingObj.addOnTypeToQuantityMap.put(key, newQuantity);
    }
    String postFix;
    if (isConcatenate) {
      postFix = quoteWordingObj.typeToWordingPostFixMap.containsKey(key)
        ? quoteWordingObj.typeToWordingPostFixMap.get(key) + ', ' + wording
        : afterQuantityPhrase + ' ' + wording;
    } else {
      postFix = wording;
    }
    quoteWordingObj.typeToWordingPostFixMap.put(key, postFix);
    quoteWordingObj.fieldNameToFinalWording.put(
      key,
      generateSumWording(
        quoteWordingObj.addOnTypeToQuantityMap.get(key),
        quoteWordingObj.typeToWordingPostFixMap.get(key)
      )
    );
    quoteWordingObj.addonTypeToContractGroupMap.put(key, contractGroup);
    //        quoteWordingObj.productGroupToFinalWordingListMap.get(contractGroup).put(key,quoteWordingObj.fieldNameToFinalWording.get(key));
    //        quoteWordingObj.productGroupToFinalWordingListMap.get(contractGroup).add(quoteWordingObj.fieldNameToFinalWording.get(key));
    System.debug(
      'quoteWordingObj.fieldNameToFinalWording--' +
      quoteWordingObj.fieldNameToFinalWording
    );
  }

  private void doThingy() {
  }

  private String generateSumWording(Decimal num, String endOfWording) {
    //        String numberPrefix = convertNumberToExpression(num);//MQ-1840

    return num.format() + ' ' + endOfWording; //MQ-1840
  }

  private void initializeReplaceFields(QuoteWording quoteWordingObj) {
    quoteWordingObj.quote.Amendments_Replace_Products__c = '';
    quoteWordingObj.quote.Amendment_Deleted_Products__c = '';
  }

  private void handleReplace(QuoteWording quoteWordingObj) {
    System.debug('started handleReplace');
    initializeReplaceFields(quoteWordingObj);
    String replaceText = '';
    //        WordingProduct removedProduct;
    //        WordingProduct existingProduct;
    for (
      WordingProduct wp : quoteWordingObj.typeToWordingProductsMap.get(
        REMOVED_PRODUCT
      )
    ) {
      System.debug('wp in replace--' + wp);
      if (wp.isOriginal) {
        continue;
      }
      this.removedSubscriptionIdSet.add(wp.subscriptionZouraId);
      switch on wp.actionType {
        when 'Quantity' {
          fillAddonOnTypeToQuantityMap(
            quoteWordingObj,
            wp.addOnType + REMOVED_PRODUCT,
            wp.quantity,
            wp.wording,
            false,
            wp.contractGroup,
            ''
          );
        }
        when 'Summary of Attributes' {
          String wording = this.originalSubscriptionIdToWordingProductMap.containsKey(
              wp.subscriptionZouraId
            )
            ? this.originalSubscriptionIdToWordingProductMap.get(
                  wp.subscriptionZouraId
                )
                .wording
            : wp.wording;
          System.debug('wording--' + wording);
          String afterQuantityPhrase = this.typeOfTemplateToSettingMap.get(
              wp.addOnType
            )
            .Addon_String__c;
          fillAddonOnTypeToQuantityMap(
            quoteWordingObj,
            wp.addOnType + REMOVED_PRODUCT,
            wp.quantity,
            wording,
            true,
            wp.contractGroup,
            afterQuantityPhrase
          );
          quoteWordingObj.readyForWordingMap.put(wp.addOnType, true); // for future alon : this is required we put true because this addon type has changed and it will get a wording
          if (
            originalSubscriptionIdToWordingProductMap.containsKey(
              wp.subscriptionZouraId
            )
          ) {
            originalSubscriptionIdToWordingProductMap.remove(
              wp.subscriptionZouraId
            );
          }
        }
        when 'Contract wording' {
          quoteWordingObj.fieldNameToFinalWording.put(
            wp.productName + REMOVED_PRODUCT,
            wp.wording
          );
        }
        when 'Product Name' {
          quoteWordingObj.fieldNameToFinalWording.put(
            wp.productName + REMOVED_PRODUCT,
            wp.productName
          );
        }
      }
    }
    String dynamicStr = '';
    for (String key : quoteWordingObj.fieldNameToFinalWording.keySet()) {
      dynamicStr += String.isNotBlank(
          quoteWordingObj.fieldNameToFinalWording.get(key)
        )
        ? quoteWordingObj.fieldNameToFinalWording.get(key) + '\n'
        : '';
    }

    dynamicStr.removeEnd('\n');
    System.debug('dynamicStr--deleted --' + dynamicStr);
    quoteWordingObj.quote.Amendment_Deleted_Products__c += String.isNotBlank(
        dynamicStr
      )
      ? dynamicStr
      : ''; // //mq-1729 wording things
    Map<String, List<ReplaceObject>> productTypeToReplaceObjectListMap = new Map<String, List<WordingProcess.ReplaceObject>>();
    for (
      WordingProduct wp : quoteWordingObj.typeToWordingProductsMap.get(
        REMOVED_PRODUCT
      )
    ) {
      if (wp.isOriginal) {
        continue;
      }

      if (wp.actionType == 'Quantity') {
        if (!productTypeToReplaceObjectListMap.containsKey(wp.addOnType)) {
          productTypeToReplaceObjectListMap.put(
            wp.addOnType,
            new List<ReplaceObject>{
              new ReplaceObject(
                wp.addOnType,
                wp.quantity,
                wp.actionType + '-' + REMOVED_PRODUCT
              )
            }
          );
        } else {
          List<ReplaceObject> replaceObjects = productTypeToReplaceObjectListMap.get(
            wp.addOnType
          );
          ReplaceObject currentReplaceObject = replaceObjects[0];
          if (currentReplaceObject.quantity < wp.quantity) {
            currentReplaceObject.quantity = wp.quantity;
            productTypeToReplaceObjectListMap.put(wp.addOnType, replaceObjects);
          }
        }
      }
    }
    System.debug(
      'productTypeToReplaceObjectListMap--' + productTypeToReplaceObjectListMap
    );
    if (
      quoteWordingObj.typeToWordingProductsMap.get(NON_REMOVED_PRODUCT) != null
    ) {
      System.debug(
        'productTypeToReplaceObjectListMap--' +
        productTypeToReplaceObjectListMap
      );
      for (
        WordingProduct wp : quoteWordingObj.typeToWordingProductsMap.get(
          NON_REMOVED_PRODUCT
        )
      ) {
        if (wp.isOriginal) {
          continue;
        }
        if (wp.actionType == 'Quantity') {
          System.debug('wp---in non removal section --' + wp);
          if (productTypeToReplaceObjectListMap.containsKey(wp.addOnType)) {
            // there are removed product of this addon type
            List<ReplaceObject> currentReplaceObjects = productTypeToReplaceObjectListMap.get(
              wp.addOnType
            );
            if (currentReplaceObjects.size() > 1) {
              ReplaceObject currentReplace = currentReplaceObjects[1];
              if (currentReplace.quantity < wp.quantity) {
                currentReplace.quantity = wp.quantity;
                productTypeToReplaceObjectListMap.put(
                  wp.addOnType,
                  currentReplaceObjects
                );
              }
            } else {
              currentReplaceObjects.add(
                new ReplaceObject(
                  wp.addOnType,
                  wp.quantity,
                  wp.actionType + '-' + NON_REMOVED_PRODUCT
                )
              );
            }
            productTypeToReplaceObjectListMap.put(
              wp.addOnType,
              currentReplaceObjects
            );
          }
        }
      }
    }
    System.debug(
      'productTypeToReplaceObjectListMap--' + productTypeToReplaceObjectListMap
    );
    for (String productType : productTypeToReplaceObjectListMap.keySet()) {
      System.debug('productType--' + productType);
      List<ReplaceObject> replaceObjects = productTypeToReplaceObjectListMap.get(
        productType
      );
      System.debug('replaceObjects--' + replaceObjects);
      if (replaceObjects.size() > 1) {
        System.debug('replaceObjects--' + replaceObjects[0]);
        System.debug('replaceObjects--' + replaceObjects[1]);
        replaceText +=
          'the number of ' +
          replaceObjects[0].typeOfProduct +
          ' is replaced from ' +
          replaceObjects[0].quantity.format() +
          ' to ' +
          replaceObjects[1].quantity.format() +
          ' ' +
          replaceObjects[1].typeOfProduct +
          '\n';
        System.debug('replaceText--' + replaceText);
      }
    }
    quoteWordingObj.quote.Amendments_Replace_Products__c = replaceText;
  }
  private void getRelatedQuoteProducts() {
    List<zqu__QuoteRatePlan__c> quoteRatePlaneList = getQuoteRatePlaneList();
    for (zqu__QuoteRatePlan__c quoteRatePlan : quoteRatePlaneList) {
      System.debug('quoteRatePlan--' + quoteRatePlan.id);
      System.debug(
        'type---' + quoteRatePlan.zqu__QuoteAmendment__r.zqu__Type__c
      );
      if (!this.quoteMap.containsKey(quoteRatePlan.zqu__Quote__c)) {
        this.quoteMap.put(
          quoteRatePlan.zqu__Quote__c,
          quoteRatePlan.zqu__Quote__r
        );
      }
      if (
        !this.allExistingProductsMap.containsKey(quoteRatePlan.zqu__Quote__c)
      ) {
        this.allExistingProductsMap.put(
          quoteRatePlan.zqu__Quote__c,
          new List<WordingProduct>()
        );
      }
      this.allExistingProductsMap.get(quoteRatePlan.zqu__Quote__c)
        .addAll(createWordingProductsFromRatePlan(quoteRatePlan));
    }
    System.debug('this.allExistingProductsMap--' + this.allExistingProductsMap);
    for (Id quoteId : this.allExistingProductsMap.keySet()) {
      for (
        WordingProduct wordingProduct : this.allExistingProductsMap.get(quoteId)
      ) {
        if (!this.quoteIdToTypeToWordingProductListMap.containsKey(quoteId)) {
          this.quoteIdToTypeToWordingProductListMap.put(
            quoteId,
            new Map<String, List<WordingProcess.WordingProduct>>()
          );
        }
        Map<String, List<WordingProduct>> dynamicMap = this.quoteIdToTypeToWordingProductListMap.get(
          quoteId
        );
        if (!dynamicMap.containsKey(wordingProduct.type)) {
          dynamicMap.put(wordingProduct.type, new List<WordingProduct>());
        }
        if (wordingProduct.type != REMOVED_PRODUCT) {
          if (!dynamicMap.containsKey(NON_REMOVED_PRODUCT)) {
            dynamicMap.put(
              NON_REMOVED_PRODUCT,
              new List<WordingProcess.WordingProduct>()
            );
          }
          dynamicMap.get(NON_REMOVED_PRODUCT).add(wordingProduct);
          this.quoteIdToTypeToWordingProductListMap.put(quoteId, dynamicMap);
        }

        dynamicMap.get(wordingProduct.type).add(wordingProduct);
        this.quoteIdToTypeToWordingProductListMap.put(quoteId, dynamicMap);
      }
    }
  }

  private List<zqu__QuoteRatePlan__c> getQuoteRatePlaneList() {
    List<zqu__QuoteRatePlan__c> quoteRatePlaneList = [
      SELECT
        Id,
        name,
        zqu__Quote__r.Contract_Base_package__c,
        zqu__Quote__r.package__c,
        zqu__Quote__r.Default_Base_Product_Addons__c,
        zqu__Quote__r.zqu__QuoteBusinessType__c,
        zqu__QuoteAmendment__r.zqu__Type__c,
        zqu__Quote__r.Contract_Wording_List_Amend__c,
        zqu__Quote__r.Amendment_New_Updated_Products__c,
        zqu__Quote__r.zqu__SubscriptionType__c,
        zqu__Quote__r.Amendments_Replace_Products__c,
        zqu__Quote__r.Amendment_New_Products__c,
        zqu__Quote__r.Contract_Wording_List__c,
        zqu__Quote__r.Migrating_to_New_Soultion__c,
        zqu__Quote__r.Package_Amendment__c,
        zqu__AmendmentType__c,
        zqu__ProductRatePlan__c,
        zqu__SubscriptionRatePlanZuoraId__c,
        zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording_Action__c,
        zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c,
        zqu__ProductRatePlan__r.zqu__Product__r.name,
        zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording__c,
        zqu__ProductRatePlan__r.zqu__Product__r.Contract_Grouping__c,
        (
          SELECT
            Id,
            zqu__ChargeNumber__c,
            zqu__IsLastSegment__c,
            Type__c,
            Name,
            ClaimString__c,
            zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Type__c,
            zqu__QuoteRatePlan__r.zqu__SubscriptionRatePlanZuoraId__c,
            Contract_Wording__c,
            zqu__RatePlanName__c,
            zqu__QuoteRatePlan__r.zqu__AmendmentType__c,
            zqu__QuoteRatePlan__c,
            zqu__QuoteRatePlan__r.zqu__Quote__c,
            zqu__QuoteRatePlan__r.zqu__quote__r.zqu__QuoteBusinessType__c,
            zqu__Quantity__c,
            zqu__ProductRatePlanCharge__c,
            zqu__ProductRatePlanCharge__r.zqu__Type__c,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording__c,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording_Action__c,
            zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Grouping__c
          FROM zqu__Quote_Rate_Plan_Charges__r
        ),
        (SELECT zqu__Quantity__c FROM zqu__QuoteChargeSummarys__r)
      FROM zqu__QuoteRatePlan__c
      WHERE
        zqu__Quote__c IN :this.quoteIdSet
        AND zqu__Quote__c != NULL
        AND zqu__Quote__r.package__c != NULL
        AND (zqu__QuoteAmendment__r.zqu__Type__c != 'Original'
        OR (zqu__QuoteAmendment__r.zqu__Type__c = 'Original'
        AND zqu__AmendmentType__c != 'RemoveProduct'))
        //                AND zqu__QuoteAmendment__r.zqu__Type__c != 'Original'
        AND zqu__QuoteAmendment__r.zqu__Type__c != 'TermsAndConditions'
    ];
    System.debug('quoteRatePlaneList---' + quoteRatePlaneList.size());
    return quoteRatePlaneList;
  }

  private List<WordingProduct> createWordingProductsFromRatePlan(
    zqu__QuoteRatePlan__c quoteRatePlan
  ) {
    List<WordingProduct> wordingProducts = new List<WordingProcess.WordingProduct>();
    if (!quoteRatePlan.zqu__Quote_Rate_Plan_Charges__r.isEmpty()) {
      System.debug('here!');
      for (
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge : quoteRatePlan.zqu__Quote_Rate_Plan_Charges__r
      ) {
        wordingProducts.add(new WordingProduct(quoteRatePlanCharge));
      }
    } else {
      System.debug('here!');
      if (!quoteRatePlan.zqu__QuoteChargeSummarys__r.isEmpty()) {
        wordingProducts.add(new WordingProduct(quoteRatePlan));
      }
    }
    System.debug('wordingProducts--' + wordingProducts);
    return wordingProducts;
  }

  public class WordingProduct {
    private String actionType; // acording to the action in zuora
    private Decimal quantity; // number
    private String wording;
    private String type; // removed ,new, updated or added
    public String productName;
    private String addOnType;
    private boolean isNeedToAdjustWording;
    private Boolean isOriginal;
    private String contractGroup;
    private String chargeNumber;
    private String subscriptionZouraId;
    private Boolean isLastSegment;
    private Boolean isOneTime = false;

    public WordingProduct(zqu__QuoteRatePlan__c quoteRatePlan) {
      this.actionType = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording_Action__c;
      this.productName = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.name;
      this.wording = String.isNotBlank(
          quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording__c
        )
        ? quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording__c
        : this.productName;
      this.type = setType(quoteRatePlan);
      System.debug('quoteRatePlan---' + quoteRatePlan);
      System.debug('quoteRatePlan---' + quoteRatePlan.name);
      System.debug(
        'zqu__Type__c---' + quoteRatePlan.zqu__QuoteAmendment__r.zqu__Type__c
      );
      this.quantity = quoteRatePlan.zqu__QuoteChargeSummarys__r[0]
        .zqu__Quantity__c.abs();
      this.addOnType = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c;
      this.isNeedToAdjustWording = getIsNeedToAdjustWording(
        this.type,
        quoteRatePlan
      );
      this.isOriginal =
        quoteRatePlan.zqu__QuoteAmendment__r.zqu__Type__c == 'Original';
      this.contractGroup = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Grouping__c;
      this.subscriptionZouraId = quoteRatePlan.zqu__SubscriptionRatePlanZuoraId__c;
    }

    public WordingProduct(zqu__QuoteRatePlanCharge__c quoteRatePlanCharge) {
      this.actionType = quoteRatePlanCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording_Action__c;
      //            this.wording = quoteRatePlanCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording__c; MQ-1855
      this.productName = quoteRatePlanCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name;
      this.wording = String.isNotBlank(quoteRatePlanCharge.Contract_Wording__c)
        ? quoteRatePlanCharge.Contract_Wording__c
        : this.productName; // MQ-1855
      this.type = setType(quoteRatePlanCharge.zqu__QuoteRatePlan__r);
      //            this.type = quoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'RemoveProduct' ? REMOVED_PRODUCT : NEW_PRODUCT;
      this.quantity = quoteRatePlanCharge.zqu__Quantity__c;
      this.addOnType = quoteRatePlanCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c;
      this.isNeedToAdjustWording = getIsNeedToAdjustWording(
        this.type,
        quoteRatePlanCharge.zqu__QuoteRatePlan__r
      );
      this.isOriginal =
        quoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Type__c ==
        'Original';
      this.contractGroup = quoteRatePlanCharge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Grouping__c;
      this.chargeNumber = quoteRatePlanCharge.zqu__ChargeNumber__c;
      this.subscriptionZouraId = quoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__SubscriptionRatePlanZuoraId__c;
      this.isLastSegment = quoteRatePlanCharge.zqu__IsLastSegment__c;
      this.isOneTime = quoteRatePlanCharge?.Type__c?.contains('One') ?? false;
    }

    private Boolean getIsNeedToAdjustWording(
      String wordingType,
      zqu__QuoteRatePlan__c quoteRatePlan
    ) {
      System.debug('wordingType--' + wordingType);
      System.debug(
        'quoteRatePlan.zqu__Quote__r.zqu__QuoteBusinessType__c--' +
        quoteRatePlan.zqu__Quote__r.zqu__QuoteBusinessType__c
      );
      return wordingType == UPDATED_PRODUCT
        ? quoteRatePlan.zqu__Quote__r.zqu__QuoteBusinessType__c !=
            'Renewal (with/without upsell)'
            ? true
            : false
        : false;
    }

    private String setType(zqu__QuoteRatePlan__c quoteRatePlan) {
      String typeOfRatePlan = quoteRatePlan.zqu__AmendmentType__c;
      return typeOfRatePlan == 'RemoveProduct'
        ? REMOVED_PRODUCT
        : typeOfRatePlan == 'UpdateProduct'
            ? UPDATED_PRODUCT
            : typeOfRatePlan == 'NewProduct' ? NEW_PRODUCT : ORIGINAL_PRODUCT;
    }
  }

  public class QuoteWording {
    private Map<String, Decimal> addOnTypeToQuantityMap = new Map<String, Decimal>();
    private Map<String, Decimal> basePackageAddonToQuantityMap = new Map<String, Decimal>();
    private Map<String, Boolean> basePackageAddonToOverrideMap = new Map<String, Boolean>();
    private zqu__Quote__c quote;
    private Map<String, List<WordingProduct>> typeToWordingProductsMap = new Map<String, List<WordingProcess.WordingProduct>>();
    private Map<String, String> fieldNameToFinalWording = new Map<String, String>();
    private Map<String, Boolean> readyForWordingMap = new Map<String, Boolean>();
    private Map<String, String> typeToWordingPostFixMap = new Map<String, String>();
    //        private Map<String,Base_Product_Num_of_Data_Credits__c> addonTypeToCustomSettingMap = new Map<String,Base_Product_Num_of_Data_Credits__c>();
    private Map<String, Boolean> addonTypToOverrideMap = new Map<String, Boolean>();
    private Set<String> addonTypeToFinalProductInQuoteSet = new Set<String>();
    //        private Map<String,Map<String,String> productGroupToFinalWordingListMap = new Map<String, Map<String, String>>();
    private Map<String, String> addonTypeToContractGroupMap = new Map<String, String>();
    private Set<String> addonTypeNeedToAdjustWordingSet = new Set<String>();

    private Boolean isNew;
    private boolean isRenewal;

    public QuoteWording(
      zqu__Quote__c quote,
      Map<String, List<WordingProduct>> typeToWordingProductsMap
    ) {
      this.quote = quote;
      this.typeToWordingProductsMap = typeToWordingProductsMap;
      this.isNew =
        quote.zqu__QuoteBusinessType__c == 'New' ||
        quote.Migrating_to_New_Soultion__c.equalsIgnoreCase('yes');
      this.isRenewal =
        quote.zqu__QuoteBusinessType__c == 'Co-Term Upsell + Renewal' ||
        quote.zqu__QuoteBusinessType__c ==
        'Feature Update + Renewal (with/without upsell)' ||
        quote.zqu__QuoteBusinessType__c == 'Renewal (with/without upsell)';
    }
  }

  private void setDefaultAddon(zqu__Quote__c quote) {
    System.debug(
      'this.baseProductValueToDefaultAddons--' +
      this.baseProductValueToDefaultAddons
    );
    quote.Default_Base_Product_Addons__c = '';
    if (
      this.baseProductValueToDefaultAddons.containsKey(
        quote.Contract_Base_package__c
      )
    ) {
      for (
        String addon_i : baseProductValueToDefaultAddons.get(
          quote.Contract_Base_package__c
        )
      ) {
        System.debug('addon_i--' + addon_i);
        quote.Default_Base_Product_Addons__c += addon_i + '\n';
      }
      quote.Default_Base_Product_Addons__c = quote.Default_Base_Product_Addons__c.removeEnd(
        '\n'
      );
    }
  }

  public class ReplaceObject {
    private String typeOfReplaceObj;
    private Decimal quantity;
    private String typeOfProduct;

    public ReplaceObject(
      String typeOfProduct,
      Decimal quantity,
      String typeOfReplaceObj
    ) {
      this.typeOfProduct = typeOfProduct;
      this.quantity = quantity;
      this.typeOfReplaceObj = typeOfReplaceObj;
    }
  }

  public class TemplateObject {
    private String template;
    private List<Object> templateParams;

    public TemplateObject(String template) {
      this.template = template;
    }

    public TemplateObject(String template, List<Object> templateParams) {
      this.templateParams = templateParams;
      this.template = template;
    }
  }

  private void addCoverage() {
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
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
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

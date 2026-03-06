/**
 * @date 08/03/2020
 * @author Developer Synebo
 * @descrpiption Wrapper class for Quote Products
 */
public with sharing class ZuoraProductDataWrapper {
  private static Map<String, Zuora_ALL_WW_Product__mdt> skuSettingMap {
    get {
      if (skuSettingMap == null) {
        skuSettingMap = new Map<String, Zuora_ALL_WW_Product__mdt>();
        for (Zuora_ALL_WW_Product__mdt zawp_i : [
          SELECT
            Id,
            SKU_message__c,
            SKU_list__c,
            Type__c,
            Number_of_countries__c
          FROM Zuora_ALL_WW_Product__mdt
        ]) {
          for (String skuNumber_i : zawp_i.SKU_list__c.split(',')) {
            if (String.isNotBlank(skuNumber_i)) {
              skuSettingMap.put(skuNumber_i.toLowerCase(), zawp_i);
            }
          }
        }
      }
      return skuSettingMap;
    }
    private set;
  }

  private static Map<String, List<String>> clusterSettingMap {
    get {
      if (clusterSettingMap == null) {
        clusterSettingMap = new Map<String, List<String>>();
        for (Base_Product_Clusters_Setting__mdt bpcs_i : [
          SELECT Id, Cluster_name__c, Countries__c
          FROM Base_Product_Clusters_Setting__mdt
        ]) {
          clusterSettingMap.put(
            bpcs_i.Cluster_name__c,
            bpcs_i.Countries__c.split(',')
          );
        }
      }
      return clusterSettingMap;
    }
    private set;
  }

  public enum SimilarWebType {
    API_ONETIME,
    API_MOUNTHLY,
    DATA_CREDITS, // mq-1729 wording things
    BULK_API_ONETIME,
    BULK_API_MOUNTHLY,
    COUNTRY,
    COUNTRY_CLUSTER,
    COUNTRY_SKU,
    CLUSTER_5,
    PART_OF_CLUSTER_5,
    HISTORICAL_DATA,
    USERS,
    WEBSITE_RESULTS,
    DYNAMIC_COUNTRY,
    BASE_PRODUCT,
    OTHER
  }
  private static final List<String> internalCodeList = new List<String>{
    'SalIUResAM',
    'SalL500Res',
    'SalG500Res',
    'SalR500Res',
    'MktUnlmRes'
  };
  private static final List<String> skuHistoricalList = new List<String>{
    'sku-00000888',
    'sku-00001291',
    'sku-00001290',
    'sku-00001457',
    'sku-00001204',
    'sku-00001203',
    'sku-00000736',
    'sku-00000671'
  };
  private static final List<String> skuWebsiteResultList = new List<String>{
    'sku-00000533',
    'sku-00001292'
  };

  public SimilarWebType simWebType;
  public String amendType;
  public String name;
  public Boolean isCustom = false;
  public String clusterName;
  public Integer clusterWeight;
  public Decimal quantity;
  public Decimal diffQuantity;
  public String skuType;
  public Decimal productEffectivePrice;
  public String wording; // mq-1729 wording things

  private String originalId;
  private String skuNumber;
  private String zuoraType;
  public String addonType;
  private String ratePlanName;
  private String category;
  private String internalCode;
  private String groupCompatibility;
  private Boolean isPartOfCluster5;
  private List<ZuoraProductDataWrapper> productList;

  /**
   * @date 16/03/2020
   * @author Developer Synebo
   * @descrpiption class constructor
   * @param quoteRatePlan - zqu__QuoteRatePlan__c record which contains information about related product
   */
  public ZuoraProductDataWrapper(zqu__QuoteRatePlan__c quoteRatePlan) {
    system.debug('quoteRatePlan--' + quoteRatePlan.id);
    amendType = quoteRatePlan.zqu__AmendmentType__c;
    skuNumber = quoteRatePlan.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c.toLowerCase();
    zuoraType = quoteRatePlan.zqu__QuoteChargeSummarys__r[0].zqu__Type__c;
    addonType = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c;
    wording = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.Contract_Wording__c; // mq-1729 wording things
    ratePlanName = quoteRatePlan.Name;
    category = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c;
    internalCode = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c;
    groupCompatibility = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.GroupCompatibilityN__c;
    diffQuantity = quoteRatePlan.zqu__QuoteChargeSummarys__r[0]
      .zqu__Quantity__c;
    productList = new List<ZuoraProductDataWrapper>();
    isPartOfCluster5 = quoteRatePlan.zqu__QuoteChargeSummarys__r[0]
      .zqu__QuoteRatePlanCharge__r.Part_Of_Cluster_5__c; //Use Part_Of_Cluster_5__c checkbox field instead of IspartOfCluster5__c picklist
    System.debug('addonType--' + addonType);
    System.debug('groupCompatibility--' + groupCompatibility);
    if (
      quoteRatePlan.zqu__QuoteChargeSummarys__r[0]
        .zqu__QuoteRatePlanCharge__r != null
    ) {
      quantity = quoteRatePlan.zqu__QuoteChargeSummarys__r[0]
        .zqu__QuoteRatePlanCharge__r.zqu__Quantity__c;
      productEffectivePrice = quoteRatePlan.zqu__QuoteChargeSummarys__r[0]
        .zqu__QuoteRatePlanCharge__r.zqu__EffectivePrice__c;
    } else {
      quantity = 0;
      productEffectivePrice = 0;
    }

    name = quoteRatePlan.zqu__ProductRatePlan__r.zqu__Product__r.Name;

    if (isPartOfCluster5) {
      simWebType = SimilarWebType.PART_OF_CLUSTER_5;
    } else if (name.containsIgnoreCase('Cluster: 5')) {
      // update condition to take every product, which contains the 'Cluster: 5' string
      simWebType = SimilarWebType.CLUSTER_5;
    } else if (
      (addonType == 'DataCreditsAPI' || addonType == 'DataCreditsOneTimeAPI') &&
      groupCompatibility == 'API'
    ) {
      simWebType = SimilarWebType.DATA_CREDITS; // mq-1729 wording things
    } else if (
      (category == 'Add On Services' &&
      (addonType == 'API' ||
      addonType == 'APIOneTime')) ||
      (addonType == 'Migration' &&
      groupCompatibility == 'BulkAPI')
    ) {
      if (addonType == 'Migration' && groupCompatibility == 'BulkAPI') {
        simWebType = SimilarWebType.API_MOUNTHLY;
      } else if (groupCompatibility == 'API') {
        if (zuoraType == 'One-Time') {
          simWebType = SimilarWebType.API_ONETIME;
        } else if (zuoraType == 'Recurring') {
          simWebType = SimilarWebType.API_MOUNTHLY;
        }
      } else if (groupCompatibility == 'BulkAPI') {
        if (zuoraType == 'One-Time') {
          simWebType = SimilarWebType.BULK_API_ONETIME;
        } else if (zuoraType == 'Recurring') {
          simWebType = SimilarWebType.BULK_API_MOUNTHLY;
        }
      }
    } else if (
      addonType == 'History' ||
      (addonType == 'Migration' &&
      (internalCode == 'MktResM16' ||
      internalCode == 'MktResM18' ||
      internalCode == 'SalIntM25A' ||
      internalCode == 'SalIntM37A' ||
      internalCode == 'SalStrM25A' ||
      internalCode == 'SalStrM37A' ||
      internalCode == 'SalIntLM12' ||
      internalCode == 'SalgloLM12')) ||
      skuHistoricalList.contains(skuNumber)
    ) {
      simWebType = SimilarWebType.HISTORICAL_DATA;
    } else if (
      String.isNotBlank(skuNumber) &&
      skuSettingMap.containsKey(skuNumber.toLowerCase())
    ) {
      simWebType = SimilarWebType.COUNTRY_SKU;
      skuType = skuSettingMap.get(skuNumber.toLowerCase()).Type__c;
    } else if (
      name.containsIgnoreCase('Cluster') &&
      !name.containsIgnoreCase('Cluster: 5')
    ) {
      for (String clusterName_i : clusterSettingMap.keySet()) {
        if (name.containsIgnoreCase(clusterName_i)) {
          simWebType = SimilarWebType.COUNTRY_CLUSTER;
          break;
        }
      }
    } else if (name.containsIgnoreCase('Country filter')) {
      simWebType = SimilarWebType.COUNTRY;
    } else if (
      name.containsIgnoreCase('Additional Users') || addonType == 'ShopperUsers'
    ) {
      simWebType = SimilarWebType.USERS;
    } else if (
      internalCodeList.contains(internalCode) ||
      skuWebsiteResultList.contains(skuNumber)
    ) {
      simWebType = SimilarWebType.WEBSITE_RESULTS;
    } else if (category == 'Base Products') {
      simWebType = SimilarWebType.BASE_PRODUCT;
    } else {
      simWebType = SimilarWebType.OTHER;
    }
    system.debug('simWebType==' + simWebType);
  }

  /**
   * @date 08/03/2020
   * @author Developer Synebo
   * @descrpiption class constructor
   * @param quoteChargeDetail - zqu__QuoteChargeDetail__c record which contains information about related product
   * @param subProductCharge - Zuora__SubscriptionProductCharge__c record which contains information about product quantity and price
   */
  public ZuoraProductDataWrapper(
    zqu__QuoteChargeDetail__c quoteChargeDetail,
    Zuora__SubscriptionProductCharge__c subProductCharge
  ) {
    amendType = 'Original';
    skuNumber = quoteChargeDetail.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c.toLowerCase();
    zuoraType = quoteChargeDetail.zqu__ProductRatePlanCharge__r.zqu__Type__c;
    addonType = quoteChargeDetail.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.AddOnType__c;
    ratePlanName = quoteChargeDetail.zqu__ProductRatePlan__r.Name;
    category = quoteChargeDetail.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c;
    internalCode = quoteChargeDetail.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.InternalCode__c;
    groupCompatibility = quoteChargeDetail.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.GroupCompatibilityN__c;
    productList = new List<ZuoraProductDataWrapper>();
    isPartOfCluster5 = quoteChargeDetail.IsPartOfCluster5__c;
    if (subProductCharge != null) {
      quantity = subProductCharge.Zuora__Quantity__c;
      productEffectivePrice = subProductCharge.Zuora__Price__c;
    } else {
      quantity = 1;
      productEffectivePrice = 0;
    }
    diffQuantity = 0;

    name = quoteChargeDetail.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name;

    if (isPartOfCluster5) {
      simWebType = SimilarWebType.PART_OF_CLUSTER_5;
    } else if (name.containsIgnoreCase('Cluster: 5')) {
      // update condition to take every product, which contains the 'Cluster: 5' string
      simWebType = SimilarWebType.CLUSTER_5;
    } else if (
      category == 'Add On Services' &&
      (addonType == 'API' ||
      addonType == 'APIOneTime') ||
      (addonType == 'Migration' &&
      groupCompatibility == 'BulkAPI')
    ) {
      if (addonType == 'Migration' && groupCompatibility == 'BulkAPI') {
        simWebType = SimilarWebType.API_MOUNTHLY;
      } else if (groupCompatibility == 'API') {
        if (zuoraType == 'One-Time') {
          simWebType = SimilarWebType.API_ONETIME;
        } else if (zuoraType == 'Recurring') {
          simWebType = SimilarWebType.API_MOUNTHLY;
        }
      } else if (groupCompatibility == 'BulkAPI') {
        if (zuoraType == 'One-Time') {
          simWebType = SimilarWebType.BULK_API_ONETIME;
        } else if (zuoraType == 'Recurring') {
          simWebType = SimilarWebType.BULK_API_MOUNTHLY;
        }
      }
    } else if (
      addonType == 'History' ||
      (addonType == 'Migration' &&
      (internalCode == 'MktResM16' ||
      internalCode == 'MktResM18' ||
      internalCode == 'SalIntM25A' ||
      internalCode == 'SalIntM37A' ||
      internalCode == 'SalStrM25A' ||
      internalCode == 'SalStrM37A' ||
      internalCode == 'SalIntLM12' ||
      internalCode == 'SalgloLM12')) ||
      skuHistoricalList.contains(skuNumber)
    ) {
      simWebType = SimilarWebType.HISTORICAL_DATA;
    } else if (
      String.isNotBlank(skuNumber) &&
      skuSettingMap.containsKey(skuNumber.toLowerCase())
    ) {
      simWebType = SimilarWebType.COUNTRY_SKU;
    } else if (
      name.containsIgnoreCase('Cluster') &&
      !name.containsIgnoreCase('Cluster: 5')
    ) {
      simWebType = SimilarWebType.COUNTRY_CLUSTER;
    } else if (name.containsIgnoreCase('Country filter')) {
      simWebType = SimilarWebType.COUNTRY;
    } else if (name.containsIgnoreCase('Additional Users')) {
      simWebType = SimilarWebType.USERS;
    } else if (
      internalCodeList.contains(internalCode) ||
      skuWebsiteResultList.contains(skuNumber)
    ) {
      simWebType = SimilarWebType.WEBSITE_RESULTS;
    } else if (category == 'Base Products') {
      simWebType = SimilarWebType.BASE_PRODUCT;
    } else {
      simWebType = SimilarWebType.OTHER;
    }
  }

  /**
   * @date 08/03/2020
   * @author Developer Synebo
   * @descrpiption class constructor
   * @param simWebType - product type in SimilarWeb logic
   * @param name - related product name
   */
  public ZuoraProductDataWrapper(SimilarWebType simWebType, String name) {
    isCustom = true;
    amendType = 'Original';
    skuNumber = '-';
    zuoraType = 'Recurring';
    if (simWebType == SimilarWebType.API_MOUNTHLY) {
      addonType = 'API';
    } else if (simWebType == SimilarWebType.HISTORICAL_DATA) {
      addonType = 'History';
    } else if (simWebType == SimilarWebType.WEBSITE_RESULTS) {
      addonType = 'Website';
    } else {
      addonType = 'Other';
    }
    ratePlanName = name;
    category = '-';
    internalCode = '-';
    groupCompatibility = '-';
    quantity = 1;
    diffQuantity = 0;
    this.name = name;
    this.simWebType = simWebType;
  }

  /**
   * @date 08/03/2020
   * @author Developer Synebo
   * @descrpiption class constructor
   * @param simWebType - product type in SimilarWeb logic
   * @param numOfUsers - number of named users, uses to populate name field
   */
  public ZuoraProductDataWrapper(
    SimilarWebType simWebType,
    Integer numOfUsers
  ) {
    isCustom = true;
    amendType = 'Original';
    skuNumber = '-';
    zuoraType = 'Recurring';
    addonType = 'Other';
    ratePlanName = name;
    category = '-';
    internalCode = '-';
    groupCompatibility = '-';
    quantity = numOfUsers;
    diffQuantity = 0;
    this.name = numOfUsers + ' Named User' + (numOfUsers > 1 ? 's' : '');
    this.simWebType = simWebType;
  }

  /**
   * @date 16/03/2020
   * @author Developer Synebo
   * @descrpiption add all products which are part of cluster5 to the productList
   * @param existingPartOfClusterFiveList - all cluster5 products list
   * @return productList - list of all products
   */
  public List<ZuoraProductDataWrapper> addCluster5ProductList(
    List<ZuoraProductDataWrapper> existingPartOfClusterFiveList
  ) {
    productList.addAll(existingPartOfClusterFiveList);
    // for(ZuoraProductDataWrapper cfpl_i : existingPartOfClusterFiveList){
    //     productList.add(cfpl_i);
    // }
    return productList;
  }

  /**
   * @date 16/03/2020
   * @author Developer Synebo
   * @descrpiption calculate the number of hits for product
   * @return hitsNum - number of hits for product
   */
  public Decimal getNumberFromProductName() {
    if (
      simWebType == SimilarWebType.WEBSITE_RESULTS &&
      name.containsIgnoreCase('unlimited')
    ) {
      return -1;
    }
    //String regExp ='\\d{1,}K?M?';
    String regExp = '(?:[1-9][0-9]*|0)(?:\\.[1-9][0-9]*)?K?M?';
    Pattern p = Pattern.compile(regExp);
    Matcher m = p.matcher(name);
    if (!m.find()) {
      return -1;
    }
    String hitsStr = m.group();
    Integer multiplier = 1;
    if (hitsStr.endsWith('K')) {
      multiplier = 1000;
      hitsStr = hitsStr.removeEnd('K');
    } else if (hitsStr.endsWith('M')) {
      multiplier = 1000000;
      hitsStr = hitsStr.removeEnd('M');
    }
    Decimal hitsNum = Decimal.valueof(hitsStr) * multiplier;
    return hitsNum;
  }
  /**
   * @date 16/03/2020
   * @author Developer Synebo
   * @descrpiption get the Country Name for Product
   * @return clusterName - Country name of Product
   */
  public String getCountryName() {
    if (clusterName == null) {
      if (
        simWebType == SimilarWebType.COUNTRY ||
        simWebType == SimilarWebType.PART_OF_CLUSTER_5
      ) {
        clusterName = name.substringAfter('Country Filter');
      } else if (simWebType == SimilarWebType.COUNTRY_SKU) {
        if (skuSettingMap.containsKey(skuNumber)) {
          Zuora_ALL_WW_Product__mdt zawp = skuSettingMap.get(skuNumber);
          clusterName = zawp.SKU_message__c;
          clusterWeight = zawp.Number_of_countries__c.intValue();
        }
      } else if (simWebType == SimilarWebType.COUNTRY_CLUSTER) {
        for (String clusterName_i : clusterSettingMap.keySet()) {
          if (name.containsIgnoreCase(clusterName_i)) {
            clusterName =
              clusterName_i +
              ' (' +
              String.join(clusterSettingMap.get(clusterName_i), ', ') +
              ')';
            clusterWeight = clusterSettingMap.get(clusterName_i).size();
            break;
          }
        }
      } else if (simWebType == SimilarWebType.CLUSTER_5) {
        String prodCountryNames = '';
        Integer prodWeight = 0;
        for (ZuoraProductDataWrapper prod_i : productList) {
          prodCountryNames +=
            prod_i.name.substringAfter('Country Filter') + ', ';
          prodWeight += 1;
        }
        //Remove the last comma in country list
        if (productList.size() > 0) {
          prodCountryNames = prodCountryNames.removeEnd(', ');
        }

        clusterName = name + ' (' + prodCountryNames + ')';
        clusterWeight = prodWeight;
      }
    }
    return clusterName;
  }

  /**
   * @date 16/03/2020
   * @author Developer Synebo
   * @descrpiption get the Country Weight for Product
   * @return clusterWeight - Country weight of Product
   */
  public Integer getCountryWeight() {
    if (clusterWeight == null) {
      clusterWeight = 0;
      if (
        simWebType == SimilarWebType.COUNTRY ||
        simWebType == SimilarWebType.PART_OF_CLUSTER_5
      ) {
        clusterWeight = 1;
      } else if (simWebType == SimilarWebType.COUNTRY_SKU) {
        if (skuSettingMap.containsKey(skuNumber)) {
          Zuora_ALL_WW_Product__mdt zawp = skuSettingMap.get(skuNumber);
          clusterName = zawp.SKU_message__c;
          clusterWeight = zawp.Number_of_countries__c.intValue();
        }
      } else if (simWebType == SimilarWebType.COUNTRY_CLUSTER) {
        for (String clusterName_i : clusterSettingMap.keySet()) {
          if (name.containsIgnoreCase(clusterName_i)) {
            clusterName =
              clusterName_i +
              ' (' +
              String.join(clusterSettingMap.get(clusterName_i), ', ') +
              ')';
            clusterWeight = clusterSettingMap.get(clusterName_i).size();
            break;
          }
        }
      } else if (simWebType == SimilarWebType.CLUSTER_5) {
        String prodCountryNames = '';
        Integer prodWeight = 0;
        for (ZuoraProductDataWrapper prod_i : productList) {
          // if (name.containsIgnoreCase(prod_i.name)) {
          prodCountryNames +=
            prod_i.name.substringAfter('Country Filter') + ', ';
          prodWeight += 1;
          //     break;
          // }
        }
        //Remove the last comma in country list
        if (productList.size() > 0) {
          prodCountryNames = prodCountryNames.removeEnd(', ');
        }
        clusterName = name + ' (' + prodCountryNames + ')';
        clusterWeight = prodWeight;
      }
    }
    return clusterWeight;
  }
  /**
   * @date 16/03/2020
   * @author Developer Synebo
   * @descrpiption inner class that extends Exception class, uses for throw custom exception
   */
  public class ZuoraProductDataWrapperException extends Exception {
  }
}

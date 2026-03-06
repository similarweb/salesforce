/**
 * Created by zohar.sinay on 14/01/2024.
 */

global with sharing class ZuoraAddBasePackageCustomActionPlugin implements zqu.CustomActionPlugin {
  global void perform(
    zqu.DataObject masterObject,
    Map<String, Object> attributes,
    String[] logs
  ) {
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
    } else {
      // Read values from Quote Object
      String quoteId = (String) masterObject.get('Id');
      String attributeProductComp = (String) attributes.get(
        'Product Compatibility'
      );
      String attributeQuoteRegion = (String) attributes.get('QuoteRegion');
      String quoteString =
        'SELECT Id, ' +
        attributeProductComp +
        ', ' +
        attributeQuoteRegion +
        ' FROM zqu__quote__c WHERE Id = :quoteId';
      zqu__quote__c selectedQuote = Database.query(quoteString);

      Zrule_Product_Mapping__c productMapping = [
        SELECT Id, Product_Rate_Plan__c, Package_Name__c
        FROM Zrule_Product_Mapping__c
        WHERE
          Product_Compatibility__c = :selectedQuote.Product_Compatibility_Fromula__c
          AND Region__c = :selectedQuote.QuoteRegion__c
      ];
      logs.add('Adding -  Base Package - ' + productMapping.Package_Name__c);

      // logs.add(attributeMsg);// Read values from child objects.
      List<zqu.DataObject> plans = masterObject.getChildren(
        'zqu__QuoteRatePlan__c'
      );
      // logs.add('# of plans: ' + plans.size() );// Updating Charges and Tiers
      List<zqu.DataObject> charges = masterObject.getChildren(
        'zqu__QuoteRatePlanCharge__c'
      );
      // logs.add('# of charges: ' + plans.size() );// Add Product (Adds immediately, allows access to Charge details)
      zqu.DataObject addedPlan = new zqu.ZChargeGroupDataObject(
        masterObject,
        productMapping.Product_Rate_Plan__c
      ); // Set ProductRatePlan reference.
      if (!addedPlan.isRemoved() && !addedPlan.isAdded()) {
        zqu.ZChargeGroupDataObject cgForUpdate = (zqu.ZChargeGroupDataObject) addedPlan;
        zqu.zChargeGroup chGroup = cgForUpdate.getChargeGroup();
        System.debug('chGroup.groupType ' + chGroup.groupType);
        zqu__ProductRatePlan__c prp = new zqu__ProductRatePlan__c(
          Id = productMapping.Product_Rate_Plan__c
        );
        zqu.DataObject dataProductRatePlan = new zqu.CommittedDataObject(prp);
        addedPlan.putParent('zqu__ProductRatePlan__c', dataProductRatePlan);
        addedPlan.flagAdded();
        // zqu.ZQuoteUtil.addChargeGroup(chGroup);
        masterObject.addChild('zqu__QuoteRatePlan__c', addedPlan);
      }
    }
  }
  global Boolean isUpdateAction() {
    return true;
  }
  global Boolean isAddRemoveAction() {
    return true;
  }
  global Boolean isValidateAction() {
    return true;
  }
}

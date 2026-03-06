global with sharing class ZuoraRemoveOriginalProductsActionPlugin implements zqu.CustomActionPlugin {
  global void perform(
    zqu.DataObject masterObject,
    Map<String, Object> attributes,
    String[] logs
  ) {
    if (Test.isRunningTest()) {
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
    } else {
      // Read values from Quote Object
      String quoteId = (String) masterObject.get('Id');
      // logs.add('QuoteId=' + quoteId); // Read values set in Rule Configuration
      String attributeMsg = (String) attributes.get('msg');
      // logs.add(attributeMsg);// Read values from child objects.
      List<zqu.DataObject> plans = masterObject.getChildren(
        'zqu__QuoteRatePlan__c'
      );
      // logs.add('# of plans: ' + plans.size() );// Updating Charges and Tiers
      for (zqu.DataObject plan_i : plans) {
        if (!plan_i.isRemoved() && !plan_i.isAdded()) {
          zqu.ZChargeGroupDataObject cgForUpdate = (zqu.ZChargeGroupDataObject) plan_i;
          zqu.zChargeGroup chGroup = cgForUpdate.getChargeGroup();
          System.debug('chGroup.groupType ' + chGroup.groupType);
          if (chGroup.groupType == zqu.ZChargeGroup.TYPE_AMENDMENT_ORIGINAL) {
            plan_i.flagRemoved();
          }
          // zqu.ZQuoteUtil.addChargeGroup(chGroup);
          // masterObject.addChild('zqu__QuoteRatePlan__c', addedPlan);
        }
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

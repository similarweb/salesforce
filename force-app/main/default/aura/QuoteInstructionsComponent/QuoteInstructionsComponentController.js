({
  doInit: function (component, event, helper) {
    helper.getQuoteInstructions(component);
  },

  recordUpdated: function (component, event, helper) {
    var eventParams = event.getParams();
    var changeType = eventParams.changeType;

    if (changeType === "LOADED") {
      var record = component.get("v.record");
      component.set("v.quoteStatus", record.fields.zqu_Quote_Status__c.value);
      component.set(
        "v.quoteType",
        record.fields.zqu__SubscriptionType__c.value
      );
      component.set(
        "v.paymentMethod",
        record.fields.zqu__PaymentMethod__c.value
      );
      component.set("v.paymentType", record.fields.Payment_Type__c.value);
      component.set(
        "v.businessType",
        record.fields.zqu__QuoteBusinessType__c.value
      );
      component.set(
        "v.renewalConf",
        record.fields.Renewal_by_client_confirmation__c.value
      );
    } else if (changeType === "CHANGED") {
      var record = component.get("v.record");
      component.set("v.quoteStatus", record.fields.zqu_Quote_Status__c.value);
      component.set(
        "v.quoteType",
        record.fields.zqu__SubscriptionType__c.value
      );
      component.set(
        "v.paymentMethod",
        record.fields.zqu__PaymentMethod__c.value
      );
      component.set("v.paymentType", record.fields.Payment_Type__c.value);
      component.set(
        "v.businessType",
        record.fields.zqu__QuoteBusinessType__c.value
      );
      component.set(
        "v.renewalConf",
        record.fields.Renewal_by_client_confirmation__c.value
      );
    }
  }
});

({
  getQuoteValue: function (component, event, helper) {
    let action = component.get("c.getQuoteFields");
    action.setParams({
      quoteId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      let state = response.getState();
      let responseData = response.getReturnValue();
      if (state === "SUCCESS" && responseData.success !== false) {
        component.set(
          "v.targetPriceValue",
          responseData.content.targetPriceValue
        );
        component.set("v.renewalFeeValue", responseData.content.renewalFee);
        component.set(
          "v.oldTargetPriceValue",
          responseData.content.targetPriceValue
        );
        component.set(
          "v.previewedSubtotal",
          responseData.content.previewedSubtotal
        );
        component.set(
          "v.subscriptionType",
          responseData.content.subscriptionType
        );
        let quoteBusinessType = responseData.content.quoteBusinessType;
        component.set("v.quoteBusinessType", quoteBusinessType);
        helper.setFieldLabel(component, quoteBusinessType);
      } else if (responseData !== undefined) {
        helper.showToast("error", "Error!", responseData.message);
      } else {
        helper.showToast("error", "Error!", "Unexpected error");
      }
    });
    $A.enqueueAction(action);
  },
  insertRequest: function (component, event, helper) {
    let action = component.get("c.insertRequest");
    let oneTimeRequest = component.get("v.oneTimeRequest");
    let recurrencyRequest = component.get("v.recurrencyRequest");
    let targetPriceValue = component.get("v.targetPriceValue");
    let isApprovalFlow = component.get("v.isApprovalFlow");
    let renewalFeeValue = component.get("v.renewalFeeValue");
    let isGenerateContractFlow = component.get("v.isGenerateContractFlow");
    let subscriptionType = component.get("v.subscriptionType");
    let channel;
    if (subscriptionType == "Amend Subscription") {
      channel = component.get("v.amendQuoteIsChangedChannel");
    } else {
      channel = component.get("v.quoteIsChangedChannel");
    }
    if (
      (oneTimeRequest !== undefined && oneTimeRequest.length > 0) ||
      (recurrencyRequest !== undefined && recurrencyRequest.length > 0)
    ) {
      if (targetPriceValue != undefined && targetPriceValue > 0) {
        action.setParams({
          quoteId: component.get("v.recordId"),
          oneTimeRequestId: oneTimeRequest,
          recurrencyRequestId: recurrencyRequest,
          targetPriceValue: targetPriceValue,
          isApprovalFlow: isApprovalFlow,
          renewalFeeValue: renewalFeeValue
        });
        action.setCallback(this, function (response) {
          let state = response.getState();
          let responseData = response.getReturnValue();
          let metricsChanged = false;
          if (state === "SUCCESS" && responseData.success !== false) {
            component.set("v.oneTimeRequest", "");
            component.set("v.recurrencyRequest", "");
            metricsChanged = responseData.content.metricsChanged;
            if (isApprovalFlow || isGenerateContractFlow) {
              if (metricsChanged) {
                component.set(
                  "v.previewedSubtotal",
                  responseData.content.previewedSubtotal
                );
                const empApi = component.find("empApi");
                const replayId = -1;
                const errorHandler = function (message) {
                  console.error(
                    "AS MODAL Received error ",
                    JSON.stringify(message)
                  );
                };
                const channelCallback = function (message) {
                  console.log(
                    "AS MODAL Event Received : " + JSON.stringify(message)
                  );
                  helper.onReceiveNotification(component, helper, message);
                };
                empApi.onError($A.getCallback(errorHandler));
                empApi
                  .subscribe(channel, replayId, $A.getCallback(channelCallback))
                  .then(
                    $A.getCallback(function (newSubscription) {
                      console.log("AS modal Subscribed to channel " + channel);
                      component.set(
                        "v.quoteIsChangedSubscription",
                        newSubscription
                      );
                    })
                  );
              } else {
                component.set("v.isOpenModal", false);
                component.set("v.isSpinner", false);
                helper.fireASEvent(component);
              }
            }
          } else {
            component.set("v.isSpinner", false);
            if (responseData != undefined) {
              helper.showToast("error", "Error!", responseData.message);
            } else {
              helper.showToast("error", "Error!", "Unexpected error");
            }
          }
        });
        $A.enqueueAction(action);
        component.set("v.isSpinner", true);
      } else {
        helper.showToast("error", "Error!", "Incorrect Target Total value");
      }
    } else {
      helper.showToast(
        "error",
        "Error!",
        "Populate at least one of the request lookups"
      );
    }
  },
  showToast: function (type, title, message) {
    var toastEvent = $A.get("e.force:showToast");
    var params = {
      title: title,
      type: type
    };
    if (message) {
      params.message = message;
    }
    toastEvent.setParams(params);
    toastEvent.fire();
  },
  fireASEvent: function (component) {
    let isApprovalFlow = component.get("v.isApprovalFlow");
    let isGenerateContractFlow = component.get("v.isGenerateContractFlow");
    let message;
    if (isGenerateContractFlow) {
      message = "generate";
    } else if (isApprovalFlow) {
      message = "approved";
    }
    let asEvent = component.getEvent("asEvent");
    asEvent.setParams({
      message: message
    });
    asEvent.fire();
  },
  setFieldLabel: function (component, quoteBusinessType) {
    let targetPriceFiledLabel;
    let targetPriceFiledHelperLabel;
    console.log("QBT: " + quoteBusinessType);
    switch (quoteBusinessType) {
      case "New":
        targetPriceFiledLabel = "Total Deal Amount";
        targetPriceFiledHelperLabel = "Total ARR * Number of Years";
        break;
      case "Renewal (with/without upsell)":
        targetPriceFiledLabel = "Total Renewal Amount";
        targetPriceFiledHelperLabel = "Renewal ARR * Number of Years";
        break;
      case "Co-Term Upsell":
        targetPriceFiledLabel = "Additional Upsell Amount";
        targetPriceFiledHelperLabel = "Price Increas ARR * Number of Years";
        break;
      case "Co-Term Upsell + Renewal":
        targetPriceFiledLabel = "Additional Upsell Amount";
        targetPriceFiledHelperLabel = "Price Increas ARR * Number of Years";
        break;
      case "Feature Update + Renewal (with/without upsell)":
        targetPriceFiledLabel = "Total Renewal Amount";
        targetPriceFiledHelperLabel = "Renewal ARR * Number of Years";
        break;
      default:
        targetPriceFiledLabel = "Target Quote Total Price";
        targetPriceFiledHelperLabel = "";
    }
    component.set("v.targetPriceFiledLabel", targetPriceFiledLabel);
    component.set("v.targetPriceFiledHelperLabel", targetPriceFiledHelperLabel);
  },
  onReceiveNotification: function (component, helper, message) {
    console.log("AS MODAL onReceiveNotification: ");
    let currentRecord = component.get("v.recordId");
    let quoteId = message.data.payload.quoteId__c;
    if (currentRecord === quoteId) {
      let result = JSON.parse(message.data.payload.fieldsJson__c);
      let exceptionField = result.exceptionField;
      if (exceptionField !== undefined && exceptionField.length > 0) {
        component.set("v.isSpinner", false);
        helper.showToast("error", "Error!", exceptionField);
      } else {
        let newPreviewedSubtotal = result.zqu__Previewed_SubTotal__c;
        let oldPreviewedSubtotal = component.get("v.previewedSubtotal");
        if (oldPreviewedSubtotal !== newPreviewedSubtotal) {
          component.set("v.isOpenModal", false);
          component.set("v.isSpinner", false);
          helper.unsubscribeFromEvent(component);
          helper.fireASEvent(component);
          return;
        }
      }
    }
  },
  unsubscribeFromEvent: function (component) {
    // Get the empApi component
    const empApi = component.find("empApi");
    // Get the subscription that we saved when subscribing
    const subscription = component.get("v.quoteIsChangedSubscription");

    // Unsubscribe from event
    empApi.unsubscribe(
      subscription,
      $A.getCallback((unsubscribed) => {
        // Confirm that we have unsubscribed from the event channel
        console.log("Unsubscribed from channel " + unsubscribed.subscription);
        component.set("v.quoteIsChangedSubscription", null);
      })
    );
  }
});

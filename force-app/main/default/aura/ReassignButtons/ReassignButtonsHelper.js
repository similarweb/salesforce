({
  auraResponse: function (cmp, accountId, cmdName, fieldName) {
    //var txt = cmp.find('v.')
    console.log("auraResponse : start " + accountId);
    var action = cmp.get("c." + cmdName);
    if (typeof fieldName == "undefined") fieldName = "accountId";
    var paramsx = {};
    paramsx[fieldName] = accountId;
    console.log(paramsx);
    action.setParams(paramsx);
    console.log("auraResponse : action set");
    this.toggleSpinner(cmp);
    action.setCallback(this, function (a) {
      console.log("auraResponse : action return");
      if (a.error && a.error.length) {
        throw new Error("Unexpected error: " + a.error[0].message);
      }
      console.log("auraResponse :  action error passed");
      var result = a.getReturnValue();
      var state = a.getState();

      console.log("auraResponse : a " + JSON.stringify(a));
      console.log("auraResponse : result " + JSON.stringify(result));
      console.log("auraResponse : state " + state);
      if (state == "SUCCESS") {
        //window.location.reload();
        if (typeof result != "undefined") {
          //var q = '?';
          //cparams = this.getParams();
          //if ( typeof(cparams['source']) != 'undefined' ) q = q + 'source='+encodeURIComponent(cparams['source'])+'&'
          //q = q+ 'msg=1&title='+encodeURIComponent(result.title)+'&message='+encodeURIComponent(result.message)+'&confirm=';
          if (result.success) {
            //q = q+'1';
            window.location.reload();
            //this.createConfirm(cmp,'cmd_acknowledged',result.title,result.message);
          } else {
            //q=q+'0';
            console.log(
              "auraResponse : createError Reassign failed " + result.message
            );
            this.createError(
              cmp,
              "cmd_acknowledged",
              result.title,
              result.message
            );
          }
          //window.location.href = this.getBaseURL()+q+window.location.hash;
        }
      } else if (state === "ERROR") {
        console.log("failed to load");
      }
      this.toggleSpinner(cmp);
    });
    $A.enqueueAction(action);
  },
  generalResponse: function (
    cmp,
    cmdName,
    params,
    successFunction,
    failFunction
  ) {
    var action = cmp.get("c." + cmdName);

    action.setParams(params);
    console.log("auraResponse : action set");
    this.toggleSpinner(cmp);
    var helperx = this;
    action.setCallback(this, function (a) {
      console.log("auraResponse : action return");
      if (a.error && a.error.length) {
        throw new Error("Unexpected error: " + a.error[0].message);
      }
      console.log("auraResponse :  action error passed");
      var result = a.getReturnValue();
      var state = a.getState();
      if (state == "SUCCESS") {
        if (typeof successFunction == "function" && successFunction != null)
          successFunction(cmp, helperx, result, state, params);
      } else if (state === "ERROR") {
        if (typeof failFunction == "function" && failFunction != null)
          failFunction(cmp, helperx, result, state, params);
      }
      this.toggleSpinner(cmp);
    });
    $A.enqueueAction(action);
  },
  deleteComponent: function (cmp, aura_id) {
    var dynamicComponentsByAuraId = cmp.get("v.dynamicComponentsByAuraId");
    if (dynamicComponentsByAuraId == null) dynamicComponentsByAuraId = {};
    console.log(
      aura_id +
        " defined?: " +
        (typeof dynamicComponentsByAuraId[aura_id] != "undefined")
    );
    if (typeof dynamicComponentsByAuraId[aura_id] != "undefined") {
      dynamicComponentsByAuraId[aura_id].destroy();
      delete dynamicComponentsByAuraId[aura_id];
    }
    cmp.set("v.dynamicComponentsByAuraId", dynamicComponentsByAuraId);
  },
  registerComponent: function (cmp, aura_id, newCmp) {
    var dynamicComponentsByAuraId = cmp.get("v.dynamicComponentsByAuraId");
    if (dynamicComponentsByAuraId == null) dynamicComponentsByAuraId = {};
    dynamicComponentsByAuraId[aura_id] = newCmp;
    console.log(aura_id + " registered");
    cmp.set("v.dynamicComponentsByAuraId", dynamicComponentsByAuraId);
  },
  createError: function (cmp, aura_id, title, messageStr) {
    this.createToast(cmp, title, messageStr, "error");
    //this.createEmptyMessage(cmp,'createemptymessage');
  },
  createConfirm: function (cmp, aura_id, title, messageStr) {
    this.createToast(cmp, title, messageStr, "success");
    //this.createEmptyMessage(cmp,'createemptymessage');
  },
  createToast: function (cmp, title, messageStr, severity) {
    console.log("creating toast : " + title + "," + severity);
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: severity,
      title: title,
      message: messageStr,
      mode: "dismissible"
    });
    toastEvent.fire();
  },
  openModal: function (cmp) {
    this.generalResponse(
      cmp,
      "openModalServerSide",
      { oppId: this.getRecordId(cmp) },
      function (cmp, helper, result, state, params) {
        if (typeof result != "undefined") {
          if (result.success) {
            cmp.set("v.paymentMethod", result.message);
            cmp.set("v.isOpen", true);
          }
        }
      },
      null
    );
  },
  getRecordId: function (cmp) {
    var rid = cmp.get("v.recordId");
    console.log("v.recordId: " + rid);
    return rid;
  },
  createEmptyMessage: function (cmp, aura_id) {
    this.deleteComponent(cmp, aura_id);
    var this_helper = this;
    $A.createComponents(
      [
        [
          "ui:outputText",
          {
            value: ""
          }
        ]
      ],
      function (components, status, errorMessage) {
        console.log("auraResponse : createError in progress " + status);
        if (status === "SUCCESS") {
          var message = components[0];
          // set the body of the ui:message to be the ui:outputText
          console.log(
            "auraResponse : message set body, outputText " +
              JSON.stringify(outputText)
          );
          message.set("v.body", "");
          var cmpbdy = cmp.get("v.body");
          console.log(
            "auraResponse : cmpbdy push message " + JSON.stringify(message)
          );
          cmpbdy.push(message);
          this_helper.registerComponent(cmp, aura_id, message);
          console.log("auraResponse : cmp set body");
          cmp.set("v.body", cmpbdy);
          console.log("auraResponse : cmp set body complete");
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
          // Show offline error
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
          // Show error message
        }
      }
    );
  },
  createMessage: function (cmp, aura_id, title, messageStr, severity) {
    this.deleteComponent(cmp, aura_id);
    var this_helper = this;
    $A.createComponents(
      [
        [
          "ui:message",
          {
            "aura:id": aura_id,
            title: title,
            closable: true,
            severity: severity
          }
        ],
        [
          "ui:outputText",
          {
            value: messageStr
          }
        ]
      ],
      function (components, status, errorMessage) {
        console.log("auraResponse : createError in progress " + status);
        if (status === "SUCCESS") {
          var message = components[0];
          var outputText = components[1];
          // set the body of the ui:message to be the ui:outputText
          console.log(
            "auraResponse : message set body, outputText " +
              JSON.stringify(outputText)
          );
          message.set("v.body", outputText);
          var cmpbdy = cmp.get("v.body");
          console.log(
            "auraResponse : cmpbdy push message " + JSON.stringify(message)
          );
          cmpbdy.push(message);
          this_helper.registerComponent(cmp, aura_id, message);
          console.log("auraResponse : cmp set body");
          cmp.set("v.body", cmpbdy);
          console.log("auraResponse : cmp set body complete");
        } else if (status === "INCOMPLETE") {
          console.log("No response from server or client is offline.");
          // Show offline error
        } else if (status === "ERROR") {
          console.log("Error: " + errorMessage);
          // Show error message
        }
      }
    );
  },
  toggleSpinner: function (cmp) {
    var spinner = cmp.find("request_spinner");
    $A.util.toggleClass(spinner, "slds-hide");
  },
  getParams: function () {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
    var sURLVariables = sPageURL.split("&"); //Split by & so that you get the key value pairs separately in a list
    var sPageURLRaw = window.location.search.substring(1); //You get the whole decoded URL of the page.
    var sURLVariablesRaw = sPageURLRaw.split("&"); //Split by & so that you get the key value pairs separately in a list
    var sParameterName = {};
    var i;

    for (i = 0; i < sURLVariables.length; i++) {
      spparts = sURLVariables[i].split("="); //to split the key from the value.
      sppartsRaw = sURLVariablesRaw[i].split("="); //to split the key from the value.
      sParameterName[spparts[0]] = spparts[1];
    }
    return sParameterName;
  },
  getBaseURL: function () {
    var sPageURL = window.location.origin + window.location.pathname;
    return sPageURL;
  },

  navigateToQuoteDetail: function (cmp) {
    var opportunityId = cmp.get("v.recordId");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/apex/zqu__QuoteOption?scontrolCaching=1&id=" + opportunityId
    });
    urlEvent.fire();
  },

  calculateNewSubQuoteFlowMode: function (cmp, subscriptionType, documentType) {
    if (
      subscriptionType &&
      documentType &&
      subscriptionType.toLowerCase() == "new subscription"
    ) {
      if (documentType.toLowerCase() == "msa") {
        cmp.set("v.flowMode", "RegularFlow");
        console.log("RegularFlow");
      } else {
        cmp.set("v.flowMode", "NewFlow");
        console.log("NewFlow");
      }
    } else {
      console.log("NoOne");
    }
  },
  calculateAmendRenewalFlowMode: function (cmp, quoteBusinessType) {
    if (
      quoteBusinessType &&
      quoteBusinessType.toLowerCase().includes("renewal")
    ) {
      cmp.set("v.amendRenewalMode", true);
    } else {
      cmp.set("v.amendRenewalMode", false);
    }
  },
  calculateisDeltaZero: function (cmp, deltaMRR, deltaTCV) {
    if (deltaMRR == 0 && deltaTCV == 0) {
      cmp.set("v.isDeltaZero", true);
    } else {
      cmp.set("v.isDeltaZero", false);
    }
  },

  quoteInit: function (cmp, event, helper) {
    var sObjectType = cmp.get("v.sObjectType");
    if (sObjectType === "zqu__Quote__c") {
      var action = cmp.get("c.quoteInit");
      action.setParams({ quoteId: cmp.get("v.recordId") });
      action.setCallback(this, function (a) {
        if (a.error && a.error.length) {
          throw new Error("Unexpected error: " + a.error[0].message);
        }
        var resultValue = a.getReturnValue();
        var state = a.getState();
        console.log("state", state);
        if (state === "SUCCESS") {
          console.log("resultValue", resultValue);
          if (resultValue.success) {
            var result = resultValue.content;
            console.log("v.stepList", result.stepList);
            cmp.set("v.zuoraVisualforceUrl", result.zuoraVisualforcePageUrl);
            cmp.set("v.isQuoteApprovalEnabled", result.isQuoteApprovalEnabled);
            cmp.set("v.isHitwiseAccount", result.isHitwiseAccount);
            cmp.set("v.stepList", result.stepList);
            cmp.set(
              "v.isMsaSentToZuoraEnabled",
              result.isMsaSentToZuoraEnabled
            );
            cmp.set("v.isLegalFlowEnabled", result.isLegalFlowEnabled);
            cmp.set("v.isBalanceZero", result.isBalanceZero);
            cmp.set("v.isARenewal7day", result.isARenewal7day);
            cmp.set("v.isSalesOps", result.isSalesOps);
            cmp.set("v.isNewAmendProfiles", result.isNewAmendProfiles);
            cmp.set("v.isTrialQuote", result.isTrialQuote);
            cmp.set("v.hitwiseLink", result.Hitwise_Link__c);
            cmp.set(
              "v.isDeltaMrrOrSubGreaterThanZero",
              result.isDeltaMrrOrSubGreaterThanZero
            );
            cmp.set(
              "v.isCustomerRequestsToPayImmediately",
              result.isCustomerRequestsToPayImmediately
            );
            cmp.set(
              "v.isRenewalByClientConfirmation",
              result.isRenewalByClientConfirmation
            );
            cmp.set("v.isASproductExist", result.isASproductExist);
            cmp.set("v.isGreenLane", result.isGreenLane);
            cmp.set("v.isContactsProduct", result.isContactsProduct);
            cmp.set("v.isExceptionalProduct", result.isExceptionalProduct);
            cmp.set("v.isReady", result.isQuoteReady);
            console.log("result ", result);

            helper.recordIsUpdated(cmp, result.quoteRecord, helper);
            helper.createSubscription(cmp, event, helper);
          } else {
            helper.showToast("error", "Error!", resultValue.message);
          }
        } else {
          helper.showToast("error", "Error!", "Unexpected error");
        }
        //helper.toggleSpinner(cmp);
        cmp.set("v.isLoaded", true);
      });
      $A.enqueueAction(action);
    }
  },

  onReceiveNotification: function (component, message, helper) {
    let currentQuoteId = helper.getRecordId(component);
    let quoteId = message.data.payload.quoteId__c;
    if (currentQuoteId == quoteId) {
      var result = JSON.parse(message.data.payload.fieldsJson__c);
      console.log(result);
      helper.recordIsUpdated(component, result, helper);
      $A.get("e.force:refreshView").fire();
    }
  },

  createSubscription: function (cmp, event, helper) {
    var sObjectType = cmp.get("v.sObjectType");
    if (sObjectType === "zqu__Quote__c") {
      cmp.set("v.subscription", null);
      const empApi = cmp.find("empApi");
      const errorHandler = function (message) {
        console.error("Received error ", JSON.stringify(message));
      };
      empApi.onError($A.getCallback(errorHandler));
      helper.subscribe(cmp, event, helper);
    }
  },

  subscribe: function (component, event, helper) {
    const empApi = component.find("empApi");

    var subscriptionType = component.get("v.subscriptionType");
    let channel;
    console.log("subscriptionType: " + subscriptionType);
    if (subscriptionType == "Amend Subscription") {
      channel = component.get("v.amendChannel");
    } else {
      channel = component.get("v.channel");
    }

    const replayId = -1;
    const callback = function (message) {
      console.log("Event Received : " + JSON.stringify(message));
      helper.onReceiveNotification(component, message, helper);
    };
    empApi.subscribe(channel, replayId, $A.getCallback(callback)).then(
      $A.getCallback(function (newSubscription) {
        console.log("Subscribed to channel " + channel);
        component.set("v.subscription", newSubscription);
      })
    );
  },

  recordIsUpdated: function (component, result, helper) {
    var isBalanceZero = component.get("v.isBalanceZero");
    if (result.Sub_total__c != 0 && isBalanceZero == true) {
      component.set("v.isBalanceZero", false);
    }

    if (
      ((result.zqu__Previewed_Delta_MRR__c > 0.01 ||
        result.zqu__Previewed_Delta_MRR__c < -0.01) &&
        result.zqu__Previewed_Delta_MRR__c != null) ||
      ((result.zqu__Previewed_Delta_MRR__c > 0.01 ||
        result.zqu__Previewed_Delta_MRR__c < -0.01) &&
        result.zqu__Previewed_SubTotal__c != null)
    ) {
      component.set("v.isDeltaMrrOrSubGreaterThanZero", true);
    }
    let linkToSWSystem = result.Link_to_SW_System__c;
    if (linkToSWSystem != undefined && linkToSWSystem.length > 0) {
      if (linkToSWSystem.includes("_HL_")) {
        linkToSWSystem = linkToSWSystem.replace(/_HL_ENCODED_/g, "");
        linkToSWSystem = linkToSWSystem.replace(/_HL__blank_HL_/g, " ");
        linkToSWSystem = linkToSWSystem.replace(/_HL_/g, " ");
        let linksArray = linkToSWSystem.split(" ");
        linkToSWSystem =
          '<a href="' +
          linksArray[0] +
          '" target = "_blank">' +
          linksArray[0] +
          "</a>";
      }
    }
    component.set("v.paymentLink", linkToSWSystem);
    component.set("v.quoteStatus", result.zqu_Quote_Status__c);
    component.set("v.subscriptionType", result.zqu__SubscriptionType__c);
    component.set("v.documentType", result.document_format__c);
    component.set("v.paymentMethod", result.zqu__PaymentMethod__c);
    component.set("v.paymentFrequency", result.payment_frequency1__c);
    component.set("v.recordTypeId", result.RecordTypeId);
    component.set("v.quoteBusinessType", result.zqu__QuoteBusinessType__c);
    component.set(
      "v.isDiscountApprove",
      result.payment_frequency1__c == null &&
        result.zqu__PaymentTerm__c == null &&
        result.Irregular_Frequency__c == false
    );
    component.set(
      "v.isNewSubFromExistingAcc",
      result.Is_from_existing_Billing_Account__c
    );
    component.set(
      "v.isContractSignedManually",
      result.Is_Contract_Signed_Manually__c
    );
    component.set("v.isGreenLane", result.Q2C_Green_Lane__c);
    if (result.isQuoteReady != undefined && result.isQuoteReady != null) {
      component.set("v.isReady", result.isQuoteReady);
    }
    if (result.isARenewal7day !== undefined) {
      component.set("v.isARenewal7day", result.isARenewal7day);
    }
    if (
      result.zqu__Previewed_SubTotal__c !== undefined &&
      result.zqu__Previewed_SubTotal__c !== null
    ) {
      component.set("v.isSubTotalCalculated", true);
    } else {
      component.set("v.isSubTotalCalculated", false);
    }

    helper.calculateNewSubQuoteFlowMode(
      component,
      result.zqu__SubscriptionType__c,
      result.document_format__c
    );
    helper.calculateAmendRenewalFlowMode(
      component,
      result.zqu__QuoteBusinessType__c
    );
    helper.calculateisDeltaZero(
      component,
      result.zqu__Previewed_Delta_MRR__c,
      result.zqu__Previewed_Delta_TCV__c
    );

    var refreshEvent = $A.get("e.c:ApplicationRefresgEvent");
    refreshEvent.fire();
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
  }
});

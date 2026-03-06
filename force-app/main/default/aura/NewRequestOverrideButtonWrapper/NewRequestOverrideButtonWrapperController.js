({
  onInit: function (component, event, helper) {
    setTimeout(function () {
      var parentElem;
      var cardlist = document.getElementsByClassName(
        "forceRelatedListSingleContainer"
      );
      for (var i = 0; i < cardlist.length; i++) {
        if (cardlist[i].querySelector("span[title='Requests']") != null) {
          parentElem = cardlist[i];
        }
      }
      if (!parentElem) return;
      var parentHeader = parentElem.querySelector(
        "div[class='slds-card__header slds-grid']"
      );

      if (!parentHeader) return;

      var div = document.querySelector(
        "div[data-component-id='NewRequestOverrideButtonWrapper']"
      );
      div.classList.remove("flexipageComponent");
      if (parentHeader.childNodes && parentHeader.childNodes.length > 1) {
        var lastChild = parentHeader.lastChild;
        var replaceChild = parentHeader.replaceChild(
          div,
          parentHeader.lastChild
        );
        replaceChild.style.margin = "auto 0";
        parentHeader.appendChild(replaceChild);
      } else {
        parentHeader.appendChild(div);
      }
      component.set("v.loadFinished", true);
    }, 500);

    var action = component.get("c.obtainRequestRecordTypes");
    action.setParams({
      oppId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var response = JSON.parse(response.getReturnValue());
        component.set("v.picklistValues", response.rtwList);
        component.set("v.oppType", response.oppType);
      }
    });

    $A.enqueueAction(action);
  },

  openAction: function (component, event, helper) {
    component.set("v.actionOpen", true);
  },
  onClose: function (component, event, helper) {
    component.find("scrollerWrapper").scrollTo("top");
    helper.emitClose(component);
  },
  selectRecordType: function (component, event, helper) {
    document.getElementsByName("options").forEach(function (option) {
      if (option.checked) {
        component.set("v.selectedRecordType", option.value);
      }
    });
  },
  createRecord: function (component, event, helper) {
    var recordTypeId = component.get("v.selectedRecordType");
    var oppType = component.get("v.oppType");
    if (!!recordTypeId) {
      if (
        recordTypeId == "012b0000000UddJAAS" &&
        oppType != "Renewal" &&
        oppType != "Upsell" &&
        oppType != "New Sale"
      ) {
        //2021-02-11: added New Sale - Itzik Winograd
        helper.setError(
          component,
          "A Solution Consulting request may be created for New Sale, Renewal and Upsell opportunities types only"
        );
      } else if (
        recordTypeId == "0120O000000BvvsQAC" &&
        oppType != "New Sale" &&
        oppType != "Upsell"
      ) {
        helper.setError(
          component,
          "A Solution Engineering request may be created for New Sale and Upsell opportunities types only"
        );
      } else {
        component.set("v.actionOpen", false);
        helper.setError(component, "");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
          entityApiName: "Request__c",
          recordTypeId: recordTypeId,
          defaultFieldValues: {
            Opportunity__c: component.get("v.recordId")
          }
        });
        createRecordEvent.fire();
      }
    } else {
      helper.setError(component, "S");
    }
  },
  cancel: function (component, event, helper) {
    helper.setError(component, "");
    component.set("v.actionOpen", false);
    $A.get("e.force:closeQuickAction").fire();
    $A.get("e.force:refreshView").fire();
  }
});

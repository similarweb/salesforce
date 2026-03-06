({
  initHelper: function (component, helper) {
    var action = component.get("c.obtainInferredSolutionData");
    action.setParams({
      type: component.get("v.currentObject")
    });
    component.set("v.loaded", !component.get("v.loaded"));
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          debugger;
          var data = responseJson.content;
          component.set("v.picklistFieldMap", data.picklistFieldMap);
          component.set("v.defaultValue", data.defaultValue);
          var columns = [];
          data.fieldMetadata.forEach(function (elem_i) {
            var column = {};
            column.type = "text";
            //column.editable='true';
            column.fieldName = elem_i.fieldName;
            column.label = elem_i.label;
            column.sortable = true;
            columns.push(column);
          });
          component.set("v.fieldMetadataList", data.fieldMetadata);
          component.set("v.columnToRemove", data.fieldMetadata[0].fieldName);
          /*
                    var column={};
                    column.typeAttributes={};
                    column.type='button';
                    column.typeAttributes.name='removeRecord';
                    column.typeAttributes.title='removeRecord';
                    column.typeAttributes.disabled= false;
                    column.typeAttributes.value= 'test';
                    column.typeAttributes.variant= {fieldName: 'variantValue'};
                    column.typeAttributes.label='removeRecord';
                    columns.push(column);
                    */
          var actions = [
            {
              label: "Edit records",
              iconName: "utility:edit",
              name: "editRecord"
            },
            {
              label: "Delete record",
              iconName: "utility:delete",
              name: "removeRecord"
            }
          ];

          var column = {};
          column.typeAttributes = { rowActions: actions };
          column.type = "action";
          columns.push(column);

          component.set("v.columns", columns);
          component.set("v.data", data.records);
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  showToast: function (component, message, type) {
    var title = type == "success" ? "Success!" : "Error";
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      type: type
    });
    toastEvent.fire();
  },
  createRecord: function (component) {
    component.set("v.newRecord", {});
    component.set("v.recordCreateModalBody", []);

    function generateSelectField(elem_i) {
      var components = [];
      components.push([
        "lightning:select",
        {
          "aura:id": "findableAuraId",
          name: elem_i.fieldName,
          label: elem_i.label,
          value: component.getReference("v.newRecord." + elem_i.fieldName)
        }
      ]);
      var picklistFieldMap = component.get("v.picklistFieldMap");
      var options = picklistFieldMap[elem_i.fieldName.toLowerCase()];
      options.forEach(function (option_i) {
        components.push(["option", option_i]);
      });
      return components;
    }
    function generateBodyArray(components) {
      var result = [];
      for (var i = 1; i < components.length; i++) {
        result.push(components[i]);
      }
      return result;
    }

    var fieldMetadataList = component.get("v.fieldMetadataList");
    fieldMetadataList.forEach(function (elem_i) {
      $A.createComponents(
        generateSelectField(elem_i),

        function (components, status, errorMessage) {
          if (status === "SUCCESS") {
            components[0].set("v.body", generateBodyArray(components));
            var body = component.get("v.recordCreateModalBody");
            body.push(components[0]);
            component.set("v.recordCreateModalBody", body);
          } else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.");
          } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
          }
        }
      );
    });
  },
  editRecord: function (component, row) {
    component.set("v.editedRecord", row);
    component.set("v.recordCreateModalBody", []);

    function generateSelectField(elem_i) {
      var components = [];
      components.push([
        "lightning:select",
        {
          "aura:id": "findableAuraIdEdit",
          name: elem_i.fieldName,
          label: elem_i.label,
          value: component.getReference("v.editedRecord." + elem_i.fieldName)
        }
      ]);
      var picklistFieldMap = component.get("v.picklistFieldMap");
      var options = picklistFieldMap[elem_i.fieldName.toLowerCase()];
      options.forEach(function (option_i) {
        components.push(["option", option_i]);
      });
      return components;
    }
    function generateBodyArray(components) {
      var result = [];
      for (var i = 1; i < components.length; i++) {
        result.push(components[i]);
      }
      return result;
    }

    var fieldMetadataList = component.get("v.fieldMetadataList");
    fieldMetadataList.forEach(function (elem_i) {
      $A.createComponents(
        generateSelectField(elem_i),

        function (components, status, errorMessage) {
          if (status === "SUCCESS") {
            components[0].set("v.body", generateBodyArray(components));
            var body = component.get("v.recordCreateModalBody");
            body.push(components[0]);
            component.set("v.recordCreateModalBody", body);
          } else if (status === "INCOMPLETE") {
            console.log("No response from server or client is offline.");
          } else if (status === "ERROR") {
            console.log("Error: " + errorMessage);
          }
        }
      );
    });
  },
  saveRecord: function (component, recordsToSave, helper) {
    var action = component.get("c.saveInferredSolutionData");
    action.setParams({
      inferredSolutionDataRaw: JSON.stringify(recordsToSave),
      type: component.get("v.currentObject")
    });
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          component.find("datatable").set("v.draftValues", null);
          component.set("v.data", responseJson.content);
          helper.showToast(component, "Success!", "success");
        } else {
          helper.showToast(component, responseJson.message, "error");
          helper.initHelper(component, helper);
        }
      }
    });
    $A.enqueueAction(action);
  },
  removeRecord: function (component, rowName, helper) {
    var action = component.get("c.removeInferredSolutionRecord");
    action.setParams({
      csName: JSON.stringify(rowName),
      type: component.get("v.currentObject")
    });
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          component.set("v.data", responseJson.content);
          helper.showToast(component, "Success!", "success");
        } else {
          helper.showToast(component, responseJson.message, "error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  createColumn: function (component, helper) {
    var action = component.get("c.createInferredSolutionColumn");
    action.setParams({
      columnName: component.get("v.newColumn"),
      type: component.get("v.currentObject")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          var acc = component.get("c.recalculateIndex");
          acc.setParams({
            type: component.get("v.currentObject")
          });
          acc.setCallback(this, function (response) {
            component.set("v.loaded", !component.get("v.loaded"));
            var state = response.getState();
            if (state === "SUCCESS") {
              var responseJson = JSON.parse(response.getReturnValue());
              if (responseJson.success) {
                helper.showToast(component, "Success!", "success");
                helper.initHelper(component, helper);
              } else {
                helper.showToast(component, responseJson.message, "error");
              }
            }
          });
          $A.enqueueAction(acc);

          //helper.showToast(component,'Success!','success');
          //helper.initHelper(component,helper);
        } else {
          component.set("v.loaded", !component.get("v.loaded"));
          helper.showToast(component, responseJson.message, "error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  removeColumn: function (component, helper) {
    var action = component.get("c.removeInferredSolutionColumn");
    debugger;
    action.setParams({
      columnName: component.get("v.columnToRemove"),
      type: component.get("v.currentObject")
    });
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          helper.showToast(component, "Success!", "success");
          helper.initHelper(component, helper);
        } else {
          helper.showToast(component, responseJson.message, "error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  saveDefaultValue: function (component, helper) {
    var action = component.get("c.saveDefault");
    action.setParams({
      value: component.get("v.defaultValue")
    });
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          helper.showToast(component, "Success!", "success");
        } else {
          helper.showToast(component, responseJson.message, "error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  checkBatch: function (component, helper) {
    component.set("v.loaded", !component.get("v.loaded"));
    var action = component.get("c.checkIfBatchRunning");
    action.setParams({
      type: component.get("v.currentObject")
    });
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          component.set("v.isBatchRunning", responseJson.content);
        } else {
          helper.showToast(component, responseJson.message, "error");
        }
      }
    });
    $A.enqueueAction(action);
  },
  sortData: function (cmp, fieldName, sortDirection) {
    var data = cmp.get("v.data");
    var reverse = sortDirection !== "asc";
    //sorts the rows based on the column header that's clicked
    data.sort(this.sortBy(fieldName, reverse));
    cmp.set("v.data", data);
  },
  sortBy: function (field, reverse, primer) {
    var key = primer
      ? function (x) {
          return primer(x[field]);
        }
      : function (x) {
          return x[field];
        };
    //checks if the two rows should switch places
    reverse = !reverse ? 1 : -1;
    return function (a, b) {
      return ((a = key(a)), (b = key(b)), reverse * ((a > b) - (b > a)));
    };
  },
  checkCondition: function (component, helper) {
    var action = component.get("c.checkBatchCondition");
    action.setParams({
      type: component.get("v.currentObject"),
      condition: component.get("v.additionalCondition")
    });
    action.setCallback(this, function (response) {
      component.set("v.loaded", !component.get("v.loaded"));
      var state = response.getState();
      debugger;
      if (state === "SUCCESS") {
        var responseJson = JSON.parse(response.getReturnValue());
        if (responseJson.success) {
          component.set(
            "v.additionalConditionCheckMessage",
            responseJson.message
          );
          component.set("v.isConditionEnabled", true);
          component.set("v.modalMode", "runBatch");
          component.set("v.modalHeader", "Apply logic to all objects");
          helper.showToast(component, responseJson.message, "success");
        } else {
          component.set("v.isConditionEnabled", false);
          helper.showToast(component, responseJson.message, "error");
        }
      }
    });
    $A.enqueueAction(action);
  }
});

({
  doInit: function (cmp, event, helper) {
    helper.quoteInit(cmp, event, helper);
  },

  reassignSDR: function (cmp, event, helper) {
    helper.generalResponse(
      cmp,
      "assignSDR",
      { accountId: helper.getRecordId(cmp) },
      function (cmp, helper, result, state, params) {
        if (typeof result != "undefined") {
          if (result.success) {
            window.location.reload();
          } else {
            console.log(
              "auraResponse : createError Reassign failed " + result.message
            );
            helper.createError(
              cmp,
              "cmd_acknowledged",
              result.title,
              result.message
            );
          }
        }
      },
      null
    );
  },
  reassignSDRLeads: function (cmp, event, helper) {
    helper.auraResponse(cmp, helper.getRecordId(cmp), "assignSDRLeads");
  },
  reassignCSM: function (cmp, event, helper) {
    helper.auraResponse(cmp, helper.getRecordId(cmp), "assignCSM");
  },
  reassignSales: function (cmp, event, helper) {
    helper.auraResponse(cmp, helper.getRecordId(cmp), "assignSales");
  },
  finilaizeQuote: function (cmp, event, helper) {
    helper.auraResponse(cmp, helper.getRecordId(cmp), "finQuote", "QuoteId");
  },
  newQuote: function (cmp, event, helper) {
    helper.navigateToQuoteDetail(cmp);
  },
  closeModal: function (cmp, event, helper) {
    cmp.set("v.isOpen", false);
  },
  openModal: function (cmp, event, helper) {
    helper.openModal(cmp);
  }
});
